import { common } from '@kit.AbilityKit';
import { fileIo as fs, picker } from '@kit.CoreFileKit';
import { util } from '@kit.ArkTS';
import { router } from '@kit.ArkUI';
import { LocalChapter, LocalTitleRecord, LibraryStore } from '../common/LibraryStore';

interface ImportDocument {
  title: string;
  chapters: ImportChapter[];
}

interface ImportChapter {
  name: string;
  content: string;
}

@Entry
@Component
struct LocalSourcePage {
  @State private titles: LocalTitleRecord[] = [];
  @State private importError: string = '';

  aboutToAppear(): void {
    this.refreshTitles();
  }

  onPageShow(): void {
    this.refreshTitles();
  }

  private async refreshTitles(): Promise<void> {
    this.titles = (await LibraryStore.localTitles(this)).slice();
  }

  private titleId(title: string): number {
    let hash: number = 2166136261;
    for (let index: number = 0; index < title.length; index += 1) {
      hash ^= title.charCodeAt(index);
      hash = Math.imul(hash, 16777619);
    }
    return Math.abs(hash) || 1;
  }

  private readDocument(uri: string): string {
    const file: fs.File = fs.openSync(uri, fs.OpenMode.READ_ONLY);
    try {
      const size: number = fs.statSync(file.fd).size;
      if (size <= 0 || size > 1024 * 1024) {
        throw new Error('Local title document must contain 1 byte to 1 MiB');
      }
      const buffer: ArrayBuffer = new ArrayBuffer(size);
      const destination: Uint8Array = new Uint8Array(buffer);
      let bytesCopied: number = 0;
      while (bytesCopied < size) {
        const chunkSize: number = Math.min(64 * 1024, size - bytesCopied);
        const chunk: ArrayBuffer = new ArrayBuffer(chunkSize);
        const bytesRead: number = fs.readSync(file.fd, chunk, { length: chunkSize });
        if (bytesRead <= 0) {
          throw new Error(`Local title document ended after ${bytesCopied} of ${size} bytes`);
        }
        destination.set(new Uint8Array(chunk, 0, bytesRead), bytesCopied);
        bytesCopied += bytesRead;
      }
      const decoder = util.TextDecoder.create('utf-8', { ignoreBOM: true });
      return decoder.decodeToString(new Uint8Array(buffer, 0, bytesCopied));
    } finally {
      fs.closeSync(file);
    }
  }

  private parseDocument(text: string): LocalTitleRecord {
    const imported: ImportDocument = JSON.parse(text) as ImportDocument;
    const title: string = imported.title ? imported.title.trim() : '';
    const inputChapters: ImportChapter[] = imported.chapters || [];
    if (!title || inputChapters.length === 0) {
      throw new Error('The selected document needs a title and at least one chapter');
    }
    const chapters: LocalChapter[] = inputChapters.map((chapter: ImportChapter, index: number) => {
      const name: string = chapter.name ? chapter.name.trim() : '';
      const content: string = chapter.content ? chapter.content.trim() : '';
      if (!name || !content) {
        throw new Error('Every chapter needs a name and content');
      }
      const localChapter: LocalChapter = { number: index + 1, name: name, content: content };
      return localChapter;
    });
    const result: LocalTitleRecord = { id: this.titleId(title), title: title, chapters: chapters };
    return result;
  }

  private async importDocument(): Promise<void> {
    this.importError = '';
    try {
      const context = this.getUIContext().getHostContext() as common.UIAbilityContext;
      const documentPicker = new picker.DocumentViewPicker(context);
      const selected: string[] = await documentPicker.select({
        maxSelectNumber: 1,
        fileSuffixFilters: ['Local title JSON|.json'],
      });
      if (selected.length === 0) {
        return;
      }
      const title: LocalTitleRecord = this.parseDocument(this.readDocument(selected[0]));
      await LibraryStore.discoverLocalTitle(this, title);
      await this.refreshTitles();
    } catch (e) {
      this.importError = `Import failed: ${String(e)}`;
    }
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
      Text('Local source')
        .fontSize(20).fontWeight(FontWeight.Medium).fontColor('#1F1F1F')
        .layoutWeight(1).margin({ left: 16 });
    }
    .width('100%').height(56).padding({ left: 8, right: 8 })
    .alignItems(VerticalAlign.Center).backgroundColor('#FFFFFF');
  }

  build() {
    Column() {
      this.TopBar();
      Button('Import local title')
        .width('88%').margin({ top: 18, bottom: 10 })
        .onClick(() => this.importDocument());
      if (this.importError) {
        Text(this.importError).fontSize(13).fontColor('#B3261E').padding({ left: 24, right: 24, bottom: 8 });
      }
      Text('On device')
        .fontSize(14).fontColor('#666666')
        .width('100%').padding({ left: 24, top: 10, bottom: 8 });
      if (this.titles.length === 0) {
        Column() {
          Text('No local titles found').fontSize(16).fontColor('#555555');
          Text('Import a public JSON document to discover a title')
            .fontSize(13).fontColor('#777777').margin({ top: 8 });
        }
        .layoutWeight(1).justifyContent(FlexAlign.Center);
      } else {
        List() {
          ForEach(this.titles, (title: LocalTitleRecord) => {
            ListItem() {
              Row() {
                Column() {
                  Text(title.title).fontSize(17).fontWeight(FontWeight.Medium);
                  Text(`${title.chapters.length} chapter`)
                    .fontSize(13).fontColor('#666666').margin({ top: 4 });
                }
                .layoutWeight(1).alignItems(HorizontalAlign.Start);
                Text('›').fontSize(24).fontColor('#777777');
              }
              .width('100%').padding({ left: 24, right: 24, top: 16, bottom: 16 })
              .onClick(() => router.pushUrl({
                url: 'pages/LocalTitlePage', params: { mangaId: title.id },
              }));
            }
          }, (title: LocalTitleRecord) => `${title.id}|${title.title}`);
        }
        .layoutWeight(1).width('100%');
      }
    }
    .width('100%').height('100%').backgroundColor('#FFFFFF');
  }
}
