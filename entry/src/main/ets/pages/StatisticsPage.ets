// Page: StatisticsPage

import { router } from '@kit.ArkUI';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { StatisticsRepo, StatCell, StatSection } from '../common/StatisticsRepo';

const TAG = 'StatisticsPage';

@Entry
@Component
struct StatisticsPage {
  @State private sections: StatSection[] = [];
  @State private loading: boolean = true;

  aboutToAppear(): void {
    hilog.info(0x0000, TAG, 'StatisticsPage mounted');
    this.loadStats();
  }

  // Recompute on every entry so the values reflect the current library
  // (spec 场景二: re-entering after the library changes shows new values).
  private async loadStats(): Promise<void> {
    this.loading = true;
    try {
      const lib = await StatisticsRepo.loadLibrary(this);
      this.sections = StatisticsRepo.aggregate(lib);
      hilog.info(0x0000, TAG, 'aggregated %{public}d sections from library', this.sections.length);
    } catch (e) {
      hilog.error(0x0000, TAG, 'load failed: %{public}s', String(e));
      this.sections = [];
    }
    this.loading = false;
  }

  private onBack(): void {
    router.back();
  }

  @Builder
  private TopBar() {
    Row() {
      Button({ type: ButtonType.Circle, stateEffect: true }) {
        Text('←').fontSize(22).fontColor('#1F1F1F');
      }
      .width(40).height(40).backgroundColor(Color.Transparent)
      .accessibilityText('Navigate up')
      .onClick(() => this.onBack());

      Text('Statistics')
        .fontSize(20)
        .fontWeight(FontWeight.Medium)
        .fontColor('#1F1F1F')
        .layoutWeight(1)
        .margin({ left: 16 });
    }
    .width('100%')
    .height(56)
    .padding({ left: 8, right: 8 })
    .alignItems(VerticalAlign.Center)
    .backgroundColor('#FFFFFF');
  }

  @Builder
  private SectionTitle(title: string) {
    Text(title)
      .fontSize(16)
      .fontWeight(FontWeight.Bold)
      .fontColor('#1F1F1F')
      .padding({ left: 24, right: 24, top: 24, bottom: 8 });
  }

  @Builder
  private StatRow(cells: StatCell[]) {
    Row() {
      ForEach(cells, (cell: StatCell, idx: number) => {
        Column() {
          Text(cell.value)
            .fontSize(22)
            .fontWeight(FontWeight.Bold)
            .fontColor('#1F1F1F');
          Text(cell.label)
            .fontSize(13)
            .fontColor('#666666')
            .margin({ top: 6 })
            .textAlign(TextAlign.Center);
        }
        .layoutWeight(1)
        .padding({ top: 24, bottom: 24 });
      }, (cell: StatCell, idx: number) => `${cell.label}_${idx}`);
    }
    .width('100%')
    .margin({ left: 16, right: 16 })
    .borderRadius(12)
    .backgroundColor('#F6F6F6');
  }

  build() {
    Column() {
      this.TopBar();

      if (this.loading) {
        // Loading state while the library is aggregated (spec 场景一 step 2).
        Column() {
          LoadingProgress().width(48).height(48).color('#1976D2');
          Text('Loading…').fontSize(14).fontColor('#666666').margin({ top: 12 });
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center);
      } else {
        Scroll() {
          Column() {
            ForEach(this.sections, (sec: StatSection) => {
              this.SectionTitle(sec.title);
              this.StatRow(sec.cells);
            }, (sec: StatSection) => sec.title);

            // Bottom spacer
            Column().width('100%').height(40);
          }
          .width('100%')
          .alignItems(HorizontalAlign.Start);
        }
        .layoutWeight(1)
        .width('100%')
        .scrollBar(BarState.Auto);
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#FFFFFF');
  }
}
