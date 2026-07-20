import { router } from '@kit.ArkUI';
import { LibraryState, LibraryStore } from '../common/LibraryStore';

interface BottomTab {
  id: string;
  label: string;
  glyph: string;
}

@Entry
@Component
struct Index {
  @State private libraryCount: number = 0;
  private tabs: BottomTab[] = [
    { id: 'library', label: 'Library', glyph: '📚' },
    { id: 'updates', label: 'Updates', glyph: '❗' },
    { id: 'history', label: 'History', glyph: '🕘' },
    { id: 'browse', label: 'Browse', glyph: '🧭' },
    { id: 'more', label: 'More', glyph: '⋯' },
  ];

  aboutToAppear(): void {
    this.refreshCount();
  }

  private refreshCount(): void {
    const state: LibraryState = LibraryStore.state();
    this.libraryCount = state.manga.length;
  }

  build() {
    Column() {
      Text('Library').key('page_library').fontSize(24).margin({ top: 18, bottom: 8 });
      Text(`${this.libraryCount} entries`).fontSize(15).fontColor('#666666');
      Column()
        .layoutWeight(1);
      Row() {
        ForEach(this.tabs, (tab: BottomTab) => {
          Column() {
            Text(tab.glyph).fontSize(20);
            Text(tab.label).fontSize(11);
          }
          .key(`nav_${tab.id}`)
          .layoutWeight(1)
          .height(64)
          .justifyContent(FlexAlign.Center)
          .onClick(() => {
            if (tab.id === 'more') router.pushUrl({ url: 'pages/MoreTabPage' });
          });
        }, (tab: BottomTab) => tab.id);
      }
      .width('100%')
      .height(64)
      .backgroundColor('#EDEAF3');
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F3F1F8');
  }
}
