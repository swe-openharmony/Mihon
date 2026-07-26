import { systemDateTime } from '@kit.BasicServicesKit';
import { router } from '@kit.ArkUI';
import { LibraryStore, LocalChapter, LocalTitleRecord } from '../common/LibraryStore';

@Entry
@Component
struct ReaderPage {
  @State private title: string = '';
  @State private chapterName: string = '';
  @State private content: string = '';
  @State private elapsedSeconds: number = 0;
  @State private saved: boolean = false;
  private mangaId: number = 0;
  private chapterNumber: number = 0;
  private startedAtMilliseconds: number = 0;
  private elapsedTimer: number = -1;

  aboutToAppear(): void {
    const params = router.getParams() as Record<string, number> | undefined;
    this.mangaId = params ? params['mangaId'] : 0;
    this.chapterNumber = params ? params['chapter'] : 0;
    this.startedAtMilliseconds = Math.floor(systemDateTime.getUptime(systemDateTime.TimeType.ACTIVE));
    this.saved = false;
    this.elapsedSeconds = 0;
    this.loadChapter();
    this.elapsedTimer = setInterval(() => {
      const now: number = Math.floor(systemDateTime.getUptime(systemDateTime.TimeType.ACTIVE));
      this.elapsedSeconds = Math.max(0, Math.floor((now - this.startedAtMilliseconds) / 1000));
    }, 250);
  }

  aboutToDisappear(): void {
    this.stopTimer();
    this.saveReadSession();
  }

  onBackPress(): boolean {
    this.back();
    return true;
  }

  private async loadChapter(): Promise<void> {
    const record: LocalTitleRecord | undefined = await LibraryStore.localTitle(this, this.mangaId);
    if (!record) {
      return;
    }
    const chapter: LocalChapter | undefined = record.chapters.find(
      (item: LocalChapter) => item.number === this.chapterNumber);
    this.title = record.title;
    if (chapter) {
      this.chapterName = chapter.name;
      this.content = chapter.content;
    }
  }

  private stopTimer(): void {
    if (this.elapsedTimer >= 0) {
      clearInterval(this.elapsedTimer);
      this.elapsedTimer = -1;
    }
  }

  private elapsedMilliseconds(): number {
    return Math.max(0, this.elapsedSeconds * 1000);
  }

  private elapsedText(): string {
    const minutes: number = Math.floor(this.elapsedSeconds / 60);
    const seconds: number = this.elapsedSeconds % 60;
    return `Elapsed ${minutes}m ${seconds}s`;
  }

  private saveReadSession(): void {
    if (this.saved || this.startedAtMilliseconds <= 0 || this.mangaId <= 0 || this.chapterNumber <= 0) {
      return;
    }
    this.saved = true;
    LibraryStore.recordChapterRead(this, this.mangaId, this.chapterNumber, this.elapsedMilliseconds());
  }

  private async back(): Promise<void> {
    if (!this.saved && this.startedAtMilliseconds > 0) {
      this.stopTimer();
      this.saved = true;
      await LibraryStore.recordChapterRead(
        this, this.mangaId, this.chapterNumber, this.elapsedMilliseconds());
    }
    router.back();
  }

  build() {
    Column() {
      Row() {
        Button({ type: ButtonType.Circle, stateEffect: true }) {
          Text('←').fontSize(22).fontColor('#FFFFFF');
        }
        .width(40).height(40).backgroundColor(Color.Transparent)
        .accessibilityText('Navigate up').onClick(() => this.back());
        Column() {
          Text(this.chapterName || 'Chapter').fontSize(19).fontWeight(FontWeight.Medium).fontColor('#FFFFFF');
          Text(this.title || 'Local title').fontSize(12).fontColor('#DDDDDD').margin({ top: 2 });
        }
        .layoutWeight(1).alignItems(HorizontalAlign.Start).margin({ left: 12 });
      }
      .width('100%').height(64).padding({ left: 8, right: 16 })
      .alignItems(VerticalAlign.Center).backgroundColor('#222222');
      Column() {
        Text(this.chapterNumber > 0 ? `${this.chapterNumber}` : '—').fontSize(64).fontColor('#555555');
        Text(this.content || 'Loading local chapter…')
          .fontSize(16).fontColor('#555555').margin({ top: 16 })
          .padding({ left: 32, right: 32 }).textAlign(TextAlign.Center);
      }
      .layoutWeight(1).width('100%').justifyContent(FlexAlign.Center).backgroundColor('#F4F4F4');
      Text(this.elapsedText())
        .fontSize(14).fontColor('#FFFFFF').textAlign(TextAlign.Center)
        .width('100%').padding({ top: 8, bottom: 10 }).backgroundColor('#222222');
    }
    .width('100%').height('100%');
  }
}
