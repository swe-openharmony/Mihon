// Page: CategoriesPage — 分类管理页 (spec 场景四: "Categories")

import { router } from '@kit.ArkUI';
import { hilog } from '@kit.PerformanceAnalysisKit';

const TAG = 'CategoriesPage';

@Entry
@Component
struct CategoriesPage {
  aboutToAppear(): void {
    hilog.info(0x0000, TAG, 'CategoriesPage mounted');
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

      Text('Categories')
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
        Text('☰').fontSize(56).fontColor('#BBBBBB').margin({ bottom: 16 });
        Text('No categories').fontSize(16).fontColor('#666666');
      }
      .layoutWeight(1).width('100%')
      .justifyContent(FlexAlign.Center).alignItems(HorizontalAlign.Center);
    }
    .width('100%').height('100%').backgroundColor('#FFFFFF');
  }
}
