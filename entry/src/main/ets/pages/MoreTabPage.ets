// Page: MoreTabPage

import { router } from '@kit.ArkUI';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { common, Want } from '@kit.AbilityKit';
import { MockDataSource } from '../common/MockDataSource';
import { Prefs, KEY_DOWNLOADED_ONLY, KEY_INCOGNITO } from '../common/Prefs';
import { DownloadQueueState, downloadQueueSubtitle } from '../common/DownloadQueueStore';

const TAG = 'MoreTabPage';
const HELP_URL = 'https://mihon.app/docs/guides/troubleshooting/';

interface MoreTabFile {
  prefRows: PrefRow[];
  bottomTabs: NavTab[];
}

interface PrefRow {
  id: string;
  label: string;
  glyph: string;       // text glyph stand-in (we avoid sys.media.*)
  routePath?: string;
}

interface NavTab {
  id: string;
  label: string;
  glyph: string;
}

@Entry
@Component
struct MoreTabPage {
  @State private downloadedOnly: boolean = false;
  @State private incognito: boolean = false;
  @State private selectedTab: string = 'more';

  // Live download-queue state → drives the "Download queue" row subtitle.
  @State private dlState: DownloadQueueState = new DownloadQueueState();

  // Bottom navigation: 5 tabs (More selected). Loaded from rawfile.
  @State private tabs: NavTab[] = [];

  // Preference rows loaded from rawfile/mock_more_tab.json.
  @State private rows: PrefRow[] = [];

  aboutToAppear(): void {
    hilog.info(0x0000, TAG, 'MoreTabPage mounted');
    this.loadMoreTab();
    this.loadPrefs();
  }

  onPageShow(): void {
    // Re-read on return from a pushed sub-page so toggles reflect the latest
    // persisted values (spec 整页约束: 返回后开关反映最新持久化值).
    this.loadPrefs();
  }

  private async loadMoreTab(): Promise<void> {
    try {
      const data = await MockDataSource.loadJson<MoreTabFile>(this, 'mock_more_tab.json');
      this.rows = data.prefRows;
      this.tabs = data.bottomTabs;
      hilog.info(0x0000, TAG, 'loaded %{public}d pref rows and %{public}d tabs from rawfile',
        this.rows.length, this.tabs.length);
    } catch (e) {
      hilog.error(0x0000, TAG, 'load failed: %{public}s', String(e));
      this.rows = [];
      this.tabs = [];
    }
  }

  private async loadPrefs(): Promise<void> {
    try {
      this.downloadedOnly = await Prefs.getBool(this, KEY_DOWNLOADED_ONLY, false);
      this.incognito = await Prefs.getBool(this, KEY_INCOGNITO, false);
    } catch (e) {
      hilog.error(0x0000, TAG, 'prefs load failed: %{public}s', String(e));
    }
  }

  // Flip + persist. Each switch is symmetric and independent (spec 场景二).
  private async flipDownloadedOnly(): Promise<void> {
    const next = !this.downloadedOnly;
    this.downloadedOnly = next;
    hilog.info(0x0000, TAG, 'Downloaded only -> %{public}s', `${next}`);
    await Prefs.setBool(this, KEY_DOWNLOADED_ONLY, next);
  }

  private async flipIncognito(): Promise<void> {
    const next = !this.incognito;
    this.incognito = next;
    hilog.info(0x0000, TAG, 'Incognito -> %{public}s', `${next}`);
    await Prefs.setBool(this, KEY_INCOGNITO, next);
  }

  private subtitleFor(row: PrefRow): string {
    // Only the download-queue row carries a dynamic subtitle (spec 场景三).
    return row.id === 'download_queue' ? downloadQueueSubtitle(this.dlState) : '';
  }

  private onRowClick(row: PrefRow): void {
    if (row.id === 'help') {
      // Help opens the external help site (spec 场景四: out of scope, but wired).
      const ctx = getContext(this) as common.UIAbilityContext;
      const want: Want = { action: 'ohos.want.action.viewData', uri: HELP_URL };
      ctx.startAbility(want).catch((e: Object) => {
        hilog.error(0x0000, TAG, 'open help failed: %{public}s', String(e));
      });
      return;
    }
    if (row.routePath) {
      router.pushUrl({ url: row.routePath });
      return;
    }
    hilog.info(0x0000, TAG, 'pref row tapped (no route): %{public}s', row.id);
  }

  private onTabClick(tab: NavTab): void {
    this.selectedTab = tab.id;
    hilog.info(0x0000, TAG, 'nav tab -> %{public}s', tab.id);
  }

  @Builder
  private ToggleRowView(id: string, label: string, subtitle: string) {
    Row() {
      Column() {
        Text(label)
          .fontSize(16)
          .fontColor('#1F1F1F')
          .fontWeight(FontWeight.Medium);
        Text(subtitle)
          .fontSize(13)
          .fontColor('#666666')
          .margin({ top: 2 });
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1);

      // isOn reads the @State DIRECTLY inside the @Builder (not via a value
      // param) so it stays reactive — a value-type @Builder param would not
      // re-render the Toggle when the state flips. Display-only: taps pass
      // through to the row so the whole row triggers one flip path (场景二).
      Toggle({ type: ToggleType.Switch, isOn: id === 'incognito' ? this.incognito : this.downloadedOnly })
        .hitTestBehavior(HitTestMode.None);
    }
    .width('100%')
    .padding({ left: 24, right: 24, top: 16, bottom: 16 })
    .alignItems(VerticalAlign.Center)
    .onClick(() => {
      if (id === 'incognito') {
        this.flipIncognito();
      } else {
        this.flipDownloadedOnly();
      }
    });
  }

  @Builder
  private PrefRowView(row: PrefRow) {
    Row() {
      Text(row.glyph)
        .fontSize(20)
        .fontColor('#666666')
        .width(40)
        .textAlign(TextAlign.Center)
        .margin({ left: 16 });

      Column() {
        Text(row.label)
          .fontSize(16)
          .fontColor('#1F1F1F');
        // Dynamic subtitle: rendered only when non-empty (download-queue, N>0).
        if (this.subtitleFor(row).length > 0) {
          Text(this.subtitleFor(row))
            .fontSize(13)
            .fontColor('#666666')
            .margin({ top: 2 });
        }
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1);
    }
    .width('100%')
    .constraintSize({ minHeight: 56 })
    .padding({ top: 8, bottom: 8 })
    .alignItems(VerticalAlign.Center)
    .backgroundColor('#FFFFFF')
    .onClick(() => this.onRowClick(row));
  }

  @Builder
  private BottomNav() {
    Row() {
      ForEach(this.tabs, (tab: NavTab) => {
        Column() {
          Text(tab.glyph)
            .fontSize(20)
            .fontColor(this.selectedTab === tab.id ? '#1976D2' : '#666666');
          Text(tab.label)
            .fontSize(11)
            .fontColor(this.selectedTab === tab.id ? '#1976D2' : '#666666')
            .margin({ top: 2 });
        }
        .layoutWeight(1)
        .height('100%')
        .justifyContent(FlexAlign.Center)
        .onClick(() => this.onTabClick(tab));
      }, (tab: NavTab) => tab.id);
    }
    .width('100%')
    .height(64)
    .backgroundColor('#FFFFFF')
    .border({ width: { top: 0.5 }, color: '#E0E0E0' });
  }

  build() {
    Column() {
      // Scrollable content area.
      Scroll() {
        Column() {
          this.ToggleRowView(
            'downloaded_only',
            'Downloaded only',
            'Filters all entries in your library'
          );
          this.ToggleRowView(
            'incognito',
            'Incognito mode',
            'Pauses reading history'
          );

          // Divider before preference rows.
          Divider().strokeWidth(0.5).color('#E0E0E0').margin({ top: 4, bottom: 4 });

          // Preference rows.
          List() {
            ForEach(this.rows, (row: PrefRow) => {
              ListItem() {
                this.PrefRowView(row);
              }
            }, (row: PrefRow) => row.id);
          }
          .width('100%')
          .divider({ strokeWidth: 0.5, color: '#F0F0F0' });
        }
        .width('100%');
      }
      .layoutWeight(1)
      .width('100%');

      // Bottom navigation bar (Library / Updates / History / Browse / More).
      this.BottomNav();
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#FFFFFF');
  }
}
