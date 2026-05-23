// Page: MoreTabPage

import { router } from '@kit.ArkUI';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { MockDataSource } from '../common/MockDataSource';

const TAG = 'MoreTabPage';

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

interface ToggleRow {
  id: string;
  label: string;
  subtitle: string;
  isOn: boolean;
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

  // Bottom navigation: 5 tabs (More selected). Loaded from rawfile.
  @State private tabs: NavTab[] = [];

  // Preference rows loaded from rawfile/mock_more_tab.json.
  @State private rows: PrefRow[] = [];

  aboutToAppear(): void {
    hilog.info(0x0000, TAG, 'MoreTabPage mounted');
    this.loadMoreTab();
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

  private onToggleDownloadedOnly(on: boolean): void {
    this.downloadedOnly = on;
    hilog.info(0x0000, TAG, 'Downloaded only -> %{public}s', `${on}`);
  }

  private onToggleIncognito(on: boolean): void {
    this.incognito = on;
    hilog.info(0x0000, TAG, 'Incognito -> %{public}s', `${on}`);
  }

  private onRowClick(row: PrefRow): void {
    if (row.routePath) {
      router.pushUrl({ url: row.routePath });
      return;
    }
    hilog.info(0x0000, TAG, 'pref row tapped: %{public}s', row.id);
  }

  private onTabClick(tab: NavTab): void {
    this.selectedTab = tab.id;
    hilog.info(0x0000, TAG, 'nav tab -> %{public}s', tab.id);
  }

  @Builder
  private ToggleRowView(label: string, subtitle: string, isOn: boolean, onChange: (v: boolean) => void) {
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

      Toggle({ type: ToggleType.Switch, isOn: isOn })
        .onChange((v: boolean) => onChange(v));
    }
    .width('100%')
    .padding({ left: 24, right: 24, top: 16, bottom: 16 })
    .alignItems(VerticalAlign.Center);
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

      Text(row.label)
        .fontSize(16)
        .fontColor('#1F1F1F')
        .layoutWeight(1);
    }
    .width('100%')
    .height(56)
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
            'Downloaded only',
            'Filters all entries in your library',
            this.downloadedOnly,
            (v: boolean) => this.onToggleDownloadedOnly(v)
          );
          this.ToggleRowView(
            'Incognito mode',
            'Pauses reading history',
            this.incognito,
            (v: boolean) => this.onToggleIncognito(v)
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
