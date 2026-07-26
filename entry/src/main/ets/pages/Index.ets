import { router } from '@kit.ArkUI';
import { LibraryState, LibraryStore, MangaRecord } from '../common/LibraryStore';

interface BottomTab {
  id: string;
  label: string;
  glyph: string;
}

@Entry
@Component
struct Index {
  @State private selectedTab: string = 'library';
  @State private library: MangaRecord[] = [];
  private tabs: BottomTab[] = [
    { id: 'library', label: 'Library', glyph: '📚' },
    { id: 'updates', label: 'Updates', glyph: '❗' },
    { id: 'history', label: 'History', glyph: '🕘' },
    { id: 'browse', label: 'Browse', glyph: '🧭' },
    { id: 'more', label: 'More', glyph: '⋯' },
  ];

  aboutToAppear(): void {
    this.refreshLibrary();
  }

  onPageShow(): void {
    this.refreshLibrary();
  }

  private async refreshLibrary(): Promise<void> {
    const state: LibraryState = await LibraryStore.state(this);
    this.library = state.manga.slice();
  }

  private onTabClick(tab: BottomTab): void {
    if (tab.id === 'more') {
      router.pushUrl({ url: 'pages/MoreTabPage' });
      return;
    }
    this.selectedTab = tab.id;
    if (tab.id === 'library') {
      this.refreshLibrary();
    }
  }

  private onLibraryTitle(item: MangaRecord): void {
    router.pushUrl({ url: 'pages/LocalTitlePage', params: { mangaId: item.id } });
  }

  @Builder
  private BottomNav() {
    Row() {
      ForEach(this.tabs, (tab: BottomTab) => {
        Column() {
          Text(tab.glyph)
            .fontSize(20)
            .fontColor(this.selectedTab === tab.id ? '#3A5BCF' : '#555555');
          Text(tab.label)
            .fontSize(11)
            .fontColor(this.selectedTab === tab.id ? '#3A5BCF' : '#555555');
        }
        .layoutWeight(1)
        .height(64)
        .justifyContent(FlexAlign.Center)
        .onClick(() => this.onTabClick(tab));
      }, (tab: BottomTab) => tab.id);
    }
    .width('100%')
    .height(64)
    .backgroundColor('#EDEAF3');
  }

  @Builder
  private LibraryView() {
    Column() {
      Text('Library').fontSize(24).margin({ top: 18, bottom: 8 });
      Text(`${this.library.length} entries`).fontSize(15).fontColor('#666666');
      if (this.library.length === 0) {
        Column() {
          Text('(╬ಠ益ಠ)').fontSize(52).fontColor('#888888');
          Text('Your library is empty').fontSize(16).fontColor('#555555').margin({ top: 16 });
        }
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center);
      } else {
        List() {
          ForEach(this.library, (item: MangaRecord) => {
            ListItem() {
              Column() {
                Text(item.title).fontSize(17).fontWeight(FontWeight.Medium);
                Text(`${item.readChapters}/${item.totalChapters} chapters read`)
                  .fontSize(13).fontColor('#666666').margin({ top: 4 });
              }
              .width('100%')
              .alignItems(HorizontalAlign.Start)
              .padding({ left: 24, right: 24, top: 16, bottom: 16 })
              .onClick(() => this.onLibraryTitle(item));
            }
          }, (item: MangaRecord) => `${item.id}|${item.readChapters}|${item.readTimeMilliseconds}`);
        }
        .layoutWeight(1)
        .width('100%');
      }
    }
    .layoutWeight(1)
    .width('100%');
  }

  @Builder
  private BrowseView() {
    Column() {
      Text('Browse').fontSize(24).margin({ top: 18, bottom: 18 });
      Row() {
        Text('▣').fontSize(22).width(48).textAlign(TextAlign.Center);
        Column() {
          Text('Local source').fontSize(17).fontWeight(FontWeight.Medium);
          Text('Import titles stored on this device').fontSize(13).fontColor('#666666').margin({ top: 3 });
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start);
      }
      .width('100%')
      .height(72)
      .padding({ left: 12, right: 24 })
      .onClick(() => router.pushUrl({ url: 'pages/LocalSourcePage' }));
      Column().layoutWeight(1);
    }
    .layoutWeight(1)
    .width('100%');
  }

  build() {
    Column() {
      if (this.selectedTab === 'browse') {
        this.BrowseView();
      } else {
        this.LibraryView();
      }
      this.BottomNav();
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F3F1F8');
  }
}
