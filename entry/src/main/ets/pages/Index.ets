// Page: Index

import { router } from '@kit.ArkUI';
import { hilog } from '@kit.PerformanceAnalysisKit';

const TAG = 'MihonIndex';

interface BottomTab {
  id: string;
  label: string;
  glyph: string;
}

@Entry
@Component
struct Index {
  @State private currentTab: string = 'library';

  private tabs: BottomTab[] = [
    { id: 'library',  label: 'Library',  glyph: '📚' },
    { id: 'updates',  label: 'Updates',  glyph: '❗' },
    { id: 'history',  label: 'History',  glyph: '🕘' },
    { id: 'browse',   label: 'Browse',   glyph: '🧭' },
    { id: 'more',     label: 'More',     glyph: '⋯' },
  ];

  aboutToAppear(): void {
    hilog.info(0x0000, TAG, 'Mihon L0 home mounted');
  }

  private onTabTap(tab: BottomTab): void {
    hilog.info(0x0000, TAG, 'tab tapped: %{public}s', tab.id);
    this.currentTab = tab.id;
    if (tab.id === 'more') {
      router.pushUrl({ url: 'pages/MoreTabPage' });
    } else {
      console.info(`TODO: tab ${tab.id}`);
    }
  }

  @Builder
  private TopBar() {
    Row() {
      Text('Library')
        .fontSize(24)
        .fontWeight(FontWeight.Regular)
        .fontColor('#1F1F1F')
        .layoutWeight(1)
        .margin({ left: 16 });
      Text('🔍').fontSize(20).width(44).height(44).textAlign(TextAlign.Center)
        .onClick(() => console.info('TODO: search'));
      Text('▽').fontSize(20).width(44).height(44).textAlign(TextAlign.Center)
        .onClick(() => console.info('TODO: filter'));
      Text('⋮').fontSize(22).width(40).height(44).textAlign(TextAlign.Center)
        .onClick(() => console.info('TODO: overflow'));
    }
    .width('100%').height(56)
    .padding({ right: 8 })
    .alignItems(VerticalAlign.Center)
    .backgroundColor('#F3F1F8');
  }

  @Builder
  private EmptyState() {
    Column() {
      Text('(╬ಠ益ಠ)')
        .fontSize(64)
        .fontColor('#888888')
        .margin({ bottom: 24 });
      Text('Your library is empty')
        .fontSize(16)
        .fontColor('#555555')
        .margin({ bottom: 28 });
      Column() {
        Text('?')
          .fontSize(20)
          .fontColor('#3A5BCF')
          .width(28).height(28)
          .textAlign(TextAlign.Center)
          .borderRadius(14)
          .borderWidth(1.5)
          .borderColor('#3A5BCF')
          .margin({ bottom: 6 });
        Text('Getting started guide')
          .fontSize(15)
          .fontWeight(FontWeight.Medium)
          .fontColor('#3A5BCF');
      }
      .padding({ top: 12, bottom: 12, left: 24, right: 24 })
      .onClick(() => {
        hilog.info(0x0000, TAG, 'getting started guide tapped');
        console.info('TODO: open getting started guide');
      });
    }
    .width('100%')
    .layoutWeight(1)
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center);
  }

  @Builder
  private BottomNav() {
    Row() {
      ForEach(this.tabs, (tab: BottomTab) => {
        Column() {
          Text(tab.glyph)
            .fontSize(20)
            .fontColor(this.currentTab === tab.id ? '#3A5BCF' : '#555555')
            .margin({ bottom: 2 });
          Text(tab.label)
            .fontSize(11)
            .fontColor(this.currentTab === tab.id ? '#3A5BCF' : '#555555');
        }
        .layoutWeight(1)
        .height(60)
        .justifyContent(FlexAlign.Center)
        .onClick(() => this.onTabTap(tab));
      }, (tab: BottomTab) => tab.id);
    }
    .width('100%')
    .height(64)
    .backgroundColor('#EDEAF3')
    .alignItems(VerticalAlign.Center);
  }

  build() {
    Column() {
      this.TopBar();
      this.EmptyState();
      this.BottomNav();
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F3F1F8');
  }
}
