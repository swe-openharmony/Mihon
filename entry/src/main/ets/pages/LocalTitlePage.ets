import { router } from '@kit.ArkUI';
import { LibraryState, LibraryStore, LocalChapter, LocalTitleRecord, MangaRecord } from '../common/LibraryStore';

@Entry
@Component
struct LocalTitlePage {
  @State private titleRecord: LocalTitleRecord | undefined = undefined;
  @State private inLibrary: boolean = false;
  @State private readChapters: number = 0;
  private mangaId: number = 0;

  aboutToAppear(): void {
    const params = router.getParams() as Record<string, number> | undefined;
    this.mangaId = params ? params['mangaId'] : 0;
    this.refreshState();
  }

  onPageShow(): void {
    this.refreshState();
  }

  private async refreshState(): Promise<void> {
    if (this.mangaId <= 0) {
      return;
    }
    this.titleRecord = await LibraryStore.localTitle(this, this.mangaId);
    const state: LibraryState = await LibraryStore.state(this);
    const record: MangaRecord | undefined = state.manga.find(
      (item: MangaRecord) => item.id === this.mangaId);
    this.inLibrary = record !== undefined;
    this.readChapters = record ? record.readChapters : 0;
  }

  private async addToLibrary(): Promise<void> {
    if (!this.titleRecord) {
      return;
    }
    await LibraryStore.addLocalTitle(this, this.titleRecord);
    await this.refreshState();
  }

  private openChapter(chapter: LocalChapter): void {
    if (!this.inLibrary || !this.titleRecord) {
      return;
    }
    router.pushUrl({
      url: 'pages/ReaderPage',
      params: { mangaId: this.mangaId, chapter: chapter.number },
    });
  }

  @Builder
  private TopBar() {
    Row() {
      Button({ type: ButtonType.Circle, stateEffect: true }) {
        Text('←').fontSize(22).fontColor('#1F1F1F');
      }
      .width(40).height(40).backgroundColor(Color.Transparent)
      .accessibilityText('Navigate up')
      .onClick(() => router.back());
      Text(this.titleRecord ? this.titleRecord.title : 'Local title')
        .fontSize(20).fontWeight(FontWeight.Medium).fontColor('#1F1F1F')
        .layoutWeight(1).margin({ left: 16 });
    }
    .width('100%').height(56).padding({ left: 8, right: 8 })
    .alignItems(VerticalAlign.Center).backgroundColor('#FFFFFF');
  }

  build() {
    Column() {
      this.TopBar();
      if (!this.titleRecord) {
        Column() {
          Text('Local title unavailable').fontSize(18).fontColor('#555555');
        }.layoutWeight(1).justifyContent(FlexAlign.Center);
      } else {
        Column() {
          Text('▧').fontSize(72).fontColor('#777777');
          Text(this.titleRecord.title).fontSize(22).fontWeight(FontWeight.Bold).margin({ top: 16 });
          Button(this.inLibrary ? 'In library' : 'Add to library')
            .enabled(!this.inLibrary).margin({ top: 20 })
            .onClick(() => this.addToLibrary());
        }
        .width('100%').padding({ top: 28, bottom: 24 });
        Divider().strokeWidth(0.5).color('#E0E0E0');
        List() {
          ForEach(this.titleRecord.chapters, (chapter: LocalChapter) => {
            ListItem() {
              Row() {
                Column() {
                  Text(chapter.name).fontSize(17).fontWeight(FontWeight.Medium);
                  Text(this.inLibrary
                    ? (this.readChapters >= chapter.number ? 'Read' : 'Ready to read')
                    : 'Add title to library first')
                    .fontSize(13).fontColor('#666666').margin({ top: 4 });
                }
                .layoutWeight(1).alignItems(HorizontalAlign.Start);
                Text('›').fontSize(24).fontColor('#777777');
              }
              .width('100%').padding({ left: 24, right: 24, top: 18, bottom: 18 })
              .enabled(this.inLibrary).opacity(this.inLibrary ? 1 : 0.45)
              .onClick(() => this.openChapter(chapter));
            }
          }, (chapter: LocalChapter) => `${chapter.number}|${chapter.name}`);
        }
        .layoutWeight(1).width('100%');
      }
      Row() {
        Text('Library').layoutWeight(1).textAlign(TextAlign.Center)
          .onClick(() => router.replaceUrl({ url: 'pages/Index' }));
        Text('Updates').layoutWeight(1).textAlign(TextAlign.Center);
        Text('History').layoutWeight(1).textAlign(TextAlign.Center);
        Text('Browse').layoutWeight(1).textAlign(TextAlign.Center);
        Text('More').layoutWeight(1).textAlign(TextAlign.Center)
          .onClick(() => router.pushUrl({ url: 'pages/MoreTabPage' }));
      }
      .width('100%').height(64).alignItems(VerticalAlign.Center).backgroundColor('#EDEAF3');
    }
    .width('100%').height('100%').backgroundColor('#FFFFFF');
  }
}
