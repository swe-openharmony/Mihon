// Page: StatisticsPage

import { router } from '@kit.ArkUI';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { RetainedBottomNav } from '../common/RetainedBottomNav';
import { MockDataSource } from '../common/MockDataSource';

const TAG = 'StatisticsPage';

interface StatCell {
  value: string;
  label: string;
}

interface StatSection {
  title: string;
  cells: StatCell[];
}

interface StatisticsFile {
  sections: StatSection[];
}

@Entry
@Component
struct StatisticsPage {
  @State private sections: StatSection[] = [];

  // Deterministic mock heights for the per-source bar chart placeholder.
  private chartBars: number[] = [120, 80, 160, 60, 100, 140, 90];
  private chartLabels: string[] = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  aboutToAppear(): void {
    hilog.info(0x0000, TAG, 'StatisticsPage mounted');
    this.loadSections();
  }

  private async loadSections(): Promise<void> {
    try {
      const data = await MockDataSource.loadJson<StatisticsFile>(this, 'mock_statistics.json');
      this.sections = data.sections;
      hilog.info(0x0000, TAG, 'loaded %{public}d stat sections from rawfile', this.sections.length);
    } catch (e) {
      hilog.error(0x0000, TAG, 'load failed: %{public}s', String(e));
      this.sections = [];
    }
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
      .key('navigate_up')
      .accessibilityText('Navigate up')
      .onClick(() => this.onBack());

      Text('Statistics')
        .key('page_statistics')
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

  @Builder
  private ChartPlaceholder() {
    Column() {
      Text('Read per day')
        .fontSize(14)
        .fontColor('#666666')
        .alignSelf(ItemAlign.Start)
        .margin({ bottom: 12 });

      Row() {
        ForEach(this.chartBars, (h: number, idx: number) => {
          Column() {
            Column()
              .width(20)
              .height(h)
              .borderRadius(4)
              .backgroundColor('#1976D2');
            Text(this.chartLabels[idx])
              .fontSize(11)
              .fontColor('#666666')
              .margin({ top: 6 });
          }
          .layoutWeight(1)
          .alignItems(HorizontalAlign.Center)
          .justifyContent(FlexAlign.End);
        }, (_h: number, idx: number) => `bar_${idx}`);
      }
      .width('100%')
      .height(180)
      .alignItems(VerticalAlign.Bottom);
    }
    .width('100%')
    .margin({ left: 16, right: 16, top: 16 })
    .padding(16)
    .borderRadius(12)
    .backgroundColor('#F6F6F6');
  }

  build() {
    Column() {
      this.TopBar();

      Scroll() {
        Column() {
          ForEach(this.sections, (sec: StatSection) => {
            this.SectionTitle(sec.title);
            this.StatRow(sec.cells);
          }, (sec: StatSection) => sec.title);

          this.ChartPlaceholder();

          // Spacer at bottom
          Column().width('100%').height(40);
        }
        .width('100%')
        .alignItems(HorizontalAlign.Start);
      }
      .layoutWeight(1)
      .width('100%')
      .scrollBar(BarState.Auto);
      RetainedBottomNav();
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#FFFFFF');
  }
}
