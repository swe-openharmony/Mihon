// Page: SupportUsPage — 支持我们页 (spec 场景四: "Support Us")

import { router } from '@kit.ArkUI';
import { hilog } from '@kit.PerformanceAnalysisKit';

const TAG = 'SupportUsPage';

@Entry
@Component
struct SupportUsPage {
  aboutToAppear(): void {
    hilog.info(0x0000, TAG, 'SupportUsPage mounted');
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

      Text('Support Us')
        .fontSize(20).fontWeight(FontWeight.Medium).fontColor('#1F1F1F')
        .layoutWeight(1).margin({ left: 16 });
    }
    .width('100%').height(56).padding({ left: 8, right: 8 })
    .alignItems(VerticalAlign.Center).backgroundColor('#FFFFFF');
  }

  build() {
    Column() {
      this.TopBar();
      Column() {
        Text('♥').fontSize(56).fontColor('#E53935').margin({ bottom: 20 });
        Text('Support the project')
          .fontSize(18).fontWeight(FontWeight.Medium).fontColor('#1F1F1F')
          .margin({ bottom: 12 });
        Text('Mihon is free and open source. Your support keeps development going.')
          .fontSize(14).fontColor('#666666')
          .textAlign(TextAlign.Center)
          .padding({ left: 32, right: 32 });
      }
      .layoutWeight(1).width('100%')
      .justifyContent(FlexAlign.Center).alignItems(HorizontalAlign.Center);
    }
    .width('100%').height('100%').backgroundColor('#FFFFFF');
  }
}
