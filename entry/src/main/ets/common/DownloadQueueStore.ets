// ====================================================================
// DownloadQueueStore — models the live download-queue state that drives
// the "Download queue" row subtitle (spec 场景三).
//
// Two inputs: isRunning (downloader active?) and pending (N items queued).
// In this shell there is no real downloader, so the state defaults to idle
// (N=0). A real integration would push updates from the download service;
// the row re-renders reactively because the page holds this as @State.
// ====================================================================

const BULLET = '•'; // U+2022 middle dot, per spec subtitle template

export class DownloadQueueState {
  isRunning: boolean = false;
  pending: number = 0; // N — non-negative queued-item count
}

/**
 * Three-state subtitle derivation (spec 场景三):
 *   N == 0                 → '' (idle, subtitle not rendered)
 *   N > 0 && !isRunning     → 'Paused • <N> remaining'
 *   N > 0 && isRunning      → '<N> remaining'
 */
export function downloadQueueSubtitle(state: DownloadQueueState): string {
  if (state.pending <= 0) {
    return '';
  }
  if (!state.isRunning) {
    return `Paused ${BULLET} ${state.pending} remaining`;
  }
  return `${state.pending} remaining`;
}
