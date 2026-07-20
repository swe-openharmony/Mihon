// Page: SettingsPage — Settings root (spec 场景四: "Settings" → 设置主页默认根入口)

import { router } from '@kit.ArkUI';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { RetainedBottomNav } from '../common/RetainedBottomNav';

const TAG = 'SettingsPage';

interface SettingEntry {
  label: string;
  glyph: string;
  routePath?: string;
}

@Entry
@Component
struct SettingsPage {
  private entries: SettingEntry[] = [
    { label: 'Appearance', glyph: '🎨' },
    { label: 'Library', glyph: '📚' },
    { label: 'Reader', glyph: '📖' },
    { label: 'Downloads', glyph: '↓' },
    { label: 'Tracking', glyph: '🔖' },
    { label: 'Browse', glyph: '🌐' },
    { label: 'Data and storage', glyph: '💾', routePath: 'pages/DataStoragePage' },
    { label: 'Security and privacy', glyph: '🔒' },
    { label: 'Advanced', glyph: '⚙' },
    { label: 'About', glyph: 'ⓘ', routePath: 'pages/AboutPage' },
  ];

  aboutToAppear(): void {
    hilog.info(0x0000, TAG, 'SettingsPage mounted');
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

      Text('Settings')
        .key('page_settings')
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
        ForEach(this.entries, (e: SettingEntry) => {
          ListItem() {
            Row() {
              Text(e.glyph)
                .fontSize(20).fontColor('#666666')
                .width(40).textAlign(TextAlign.Center).margin({ left: 16 });
              Text(e.label)
                .fontSize(16).fontColor('#1F1F1F').layoutWeight(1);
            }
            .width('100%').height(56).alignItems(VerticalAlign.Center)
            .onClick(() => {
              if (e.routePath) {
                router.pushUrl({ url: e.routePath });
              }
            });
          }
        }, (e: SettingEntry) => e.label);
      }
      .layoutWeight(1)
      .width('100%')
      .divider({ strokeWidth: 0.5, color: '#F0F0F0' });
      RetainedBottomNav();
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#FFFFFF');
  }
}
