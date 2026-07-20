const BULLET: string = '•';

export class DownloadQueueState {
  mode: string = 'stopped';
  pending: number = 0;
}

export function downloadQueueSubtitle(state: DownloadQueueState): string {
  if (state.mode === 'stopped') {
    return '';
  }
  if (state.mode === 'paused') {
    if (state.pending <= 0) {
      return 'Paused';
    }
    return `Paused ${BULLET} ${state.pending} remaining`;
  }
  return `${state.pending} remaining`;
}
