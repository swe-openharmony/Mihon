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

  // AppStorage is the queue owner written by EntryAbility fixture/service events.
  @StorageLink('queue_mode') private queueMode: string = 'stopped';
  @StorageLink('queue_pending') private queuePending: number = 0;

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
    if (row.id !== 'download_queue') {
      return '';
    }
    const state: DownloadQueueState = new DownloadQueueState();
    state.mode = this.queueMode;
    state.pending = this.queuePending;
    return downloadQueueSubtitle(state);
  }

  private onRowClick(row: PrefRow): void {
    if (row.id === 'help') {
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
          .key(id === 'incognito' ? 'toggle_incognito_title' : 'toggle_downloaded_only_title')
          .fontSize(16)
          .fontColor('#1F1F1F')
          .fontWeight(FontWeight.Medium);
        Text(subtitle)
          .key(id === 'incognito' ? 'toggle_incognito_subtitle' : 'toggle_downloaded_only_subtitle')
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
        .key(id === 'incognito' ? 'toggle_incognito' : 'toggle_downloaded_only')
        .hitTestBehavior(HitTestMode.None);
    }
    .key(id === 'incognito' ? 'row_incognito' : 'row_downloaded_only')
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
          .key(`entry_title_${this.rows.indexOf(row)}`)
          .fontSize(16)
          .fontColor('#1F1F1F');
        Text(this.subtitleFor(row))
          .key(row.id === 'download_queue' ? 'queue_subtitle' : `subtitle_${row.id}`)
          .fontSize(13)
          .fontColor('#666666')
          .visibility(this.subtitleFor(row).length > 0 ? Visibility.Visible : Visibility.Hidden)
          .margin({ top: this.subtitleFor(row).length > 0 ? 2 : 0 });
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1);
    }
    .key(`row_${row.id}`)
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
            .key(tab.id === 'more' && this.selectedTab === 'more' ? 'nav_more_selected' : `nav_${tab.id}`)
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
      Text('').key('page_more').height(0);
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
