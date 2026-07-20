// Page: DataStoragePage — Settings' "Data and storage" subpage (spec 场景四: 直达)

import { router } from '@kit.ArkUI';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { RetainedBottomNav } from '../common/RetainedBottomNav';

const TAG = 'DataStoragePage';

@Entry
@Component
struct DataStoragePage {
  private rows: string[] = [
    'Storage usage',
    'Clear chapter cache',
    'Clear cookies',
    'Clear database',
    'Auto-download while reading',
  ];

  aboutToAppear(): void {
    hilog.info(0x0000, TAG, 'DataStoragePage mounted');
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
      .onClick(() => router.back());

      Text('Data and storage')
        .key('page_data_storage')
        .fontSize(20).fontWeight(FontWeight.Medium).fontColor('#1F1F1F')
        .layoutWeight(1).margin({ left: 16 });
    }
    .width('100%').height(56).padding({ left: 8, right: 8 })
    .alignItems(VerticalAlign.Center).backgroundColor('#FFFFFF');
  }

  build() {
    Column() {
      this.TopBar();
      List() {
        ForEach(this.rows, (r: string) => {
          ListItem() {
            Text(r).fontSize(16).fontColor('#1F1F1F')
              .width('100%').height(56)
              .padding({ left: 24, right: 24 });
          }
        }, (r: string) => r);
      }
      .layoutWeight(1).width('100%')
      .divider({ strokeWidth: 0.5, color: '#F0F0F0' });
      RetainedBottomNav();
    }
    .width('100%').height('100%').backgroundColor('#FFFFFF');
  }
}
