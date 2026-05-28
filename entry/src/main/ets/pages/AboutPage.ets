// Page: AboutPage — Settings' About subpage (spec 场景四: "About" 直达)

import { router } from '@kit.ArkUI';
import { hilog } from '@kit.PerformanceAnalysisKit';

const TAG = 'AboutPage';

interface AboutEntry {
  label: string;
  value: string;
}

@Entry
@Component
struct AboutPage {
  private entries: AboutEntry[] = [
    { label: 'Version', value: 'Stable 0.16.4' },
    { label: 'Build time', value: '2024-09-01 12:00' },
    { label: 'Check for updates', value: '' },
    { label: "What's new", value: '' },
    { label: 'Open source licenses', value: '' },
  ];

  aboutToAppear(): void {
    hilog.info(0x0000, TAG, 'AboutPage mounted');
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

      Text('About')
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

  build() {
    Column() {
      this.TopBar();

      List() {
        ForEach(this.entries, (e: AboutEntry) => {
          ListItem() {
            Column() {
              Text(e.label).fontSize(16).fontColor('#1F1F1F');
              if (e.value.length > 0) {
                Text(e.value).fontSize(13).fontColor('#666666').margin({ top: 2 });
              }
            }
            .alignItems(HorizontalAlign.Start)
            .width('100%')
            .padding({ left: 24, right: 24, top: 14, bottom: 14 });
          }
        }, (e: AboutEntry) => e.label);
      }
      .layoutWeight(1)
      .width('100%')
      .divider({ strokeWidth: 0.5, color: '#F0F0F0' });
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#FFFFFF');
  }
}
