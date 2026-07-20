interface RetainedNavTab {
  label: string;
  glyph: string;
}

@Component
export struct RetainedBottomNav {
  private tabs: RetainedNavTab[] = [
    { label: 'Library', glyph: '📚' },
    { label: 'Updates', glyph: '↻' },
    { label: 'History', glyph: '⏱' },
    { label: 'Browse', glyph: '🌐' },
    { label: 'More', glyph: '⋯' },
  ];

  build() {
    Row() {
      ForEach(this.tabs, (tab: RetainedNavTab) => {
        Column() {
          Text(tab.glyph).fontSize(20).fontColor(tab.label === 'More' ? '#1976D2' : '#666666');
          Text(tab.label)
            .key(tab.label === 'More' ? 'nav_more_selected' : `retained_nav_${tab.label}`)
            .fontSize(11)
            .fontColor(tab.label === 'More' ? '#1976D2' : '#666666');
        }
        .layoutWeight(1)
        .height('100%')
        .justifyContent(FlexAlign.Center);
      }, (tab: RetainedNavTab) => tab.label);
    }
    .width('100%')
    .height(64)
    .backgroundColor('#FFFFFF')
    .border({ width: { top: 0.5 }, color: '#E0E0E0' });
  }
}
