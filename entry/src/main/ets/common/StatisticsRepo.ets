import {
  LibraryState, LibraryStore, MangaRecord, TrackerBinding, TrackerScoreKind,
} from './LibraryStore';

export interface StatCell {
  key: string;
  value: string;
  label: string;
}

export interface StatSection {
  title: string;
  cells: StatCell[];
}

export class StatisticsRepo {
  static async loadLibrary(ctx: object): Promise<LibraryState> {
    return await LibraryStore.state(ctx);
  }

  static aggregate(lib: LibraryState): StatSection[] {
    const manga: MangaRecord[] = lib.manga;
    const loggedInTrackerIds: Set<number> = new Set<number>(lib.loggedInTrackerIds);
    let readMilliseconds: number = 0;
    let completed: number = 0;
    let inGlobalUpdate: number = 0;
    let started: number = 0;
    let local: number = 0;
    let totalChapters: number = 0;
    let readChapters: number = 0;
    let downloadedChapters: number = 0;
    let trackedEntries: number = 0;
    let titleScoreSum: number = 0;
    let scoredTitleCount: number = 0;
    for (const item of manga) {
      readMilliseconds += item.readTimeMilliseconds;
      if (item.status === 'completed' && item.readChapters >= item.totalChapters) completed += 1;
      if (item.globalUpdate) inGlobalUpdate += 1;
      if (item.readChapters > 0) started += 1;
      if (item.source === 'local') local += 1;
      totalChapters += item.totalChapters;
      readChapters += item.readChapters;
      downloadedChapters += item.downloadedChapters;
      const activeTracks: TrackerBinding[] = item.tracks.filter(
        (track: TrackerBinding) => loggedInTrackerIds.has(track.trackerId));
      if (activeTracks.length > 0) {
        trackedEntries += 1;
      }
      const scores: number[] = activeTracks
        .map((track: TrackerBinding) => StatisticsRepo.toTenPoint(track))
        .filter((score: number) => score > 0);
      if (scores.length > 0) {
        titleScoreSum += scores.reduce((sum: number, score: number) => sum + score, 0) / scores.length;
        scoredTitleCount += 1;
      }
    }
    const meanScore: string = scoredTitleCount > 0
      ? `${(titleScoreSum / scoredTitleCount).toFixed(2)} ★`
      : 'N/A';
    return [
      StatisticsRepo.section('Overview', [
        StatisticsRepo.cell('stat_in_library', `${manga.length}`, 'In library'),
        StatisticsRepo.cell('stat_read_duration', StatisticsRepo.fmtDuration(readMilliseconds), 'Read duration'),
        StatisticsRepo.cell('stat_completed_entries', `${completed}`, 'Completed entries'),
      ]),
      StatisticsRepo.section('Entries', [
        StatisticsRepo.cell('stat_global_update', `${inGlobalUpdate}`, 'In global update'),
        StatisticsRepo.cell('stat_started', `${started}`, 'Started'),
        StatisticsRepo.cell('stat_local', `${local}`, 'Local'),
      ]),
      StatisticsRepo.section('Chapters', [
        StatisticsRepo.cell('stat_total', `${totalChapters}`, 'Total'),
        StatisticsRepo.cell('stat_read', `${readChapters}`, 'Read'),
        StatisticsRepo.cell('stat_downloaded', `${downloadedChapters}`, 'Downloaded'),
      ]),
      StatisticsRepo.section('Trackers', [
        StatisticsRepo.cell('stat_tracked_entries', `${trackedEntries}`, 'Tracked entries'),
        StatisticsRepo.cell('stat_mean_score', meanScore, 'Mean score'),
        StatisticsRepo.cell('stat_used', `${lib.loggedInTrackerIds.length}`, 'Used'),
      ]),
    ];
  }

  private static toTenPoint(track: TrackerBinding): number {
    // Mirror tracker-service conversions instead of assuming every service has a
    // linearly described arbitrary scale. Credential-free scenario 2 supplies no
    // bindings; these branches preserve Android semantics when real account-backed
    // tracker records are available through an ordinary product flow.
    const kind: TrackerScoreKind = track.scoreKind;
    if (kind === 'hundred_point') return track.score / 10;
    if (kind === 'five_star') return track.score * 2;
    if (kind === 'decimal') return track.score;
    return track.score;
  }

  static fmtDuration(milliseconds: number): string {
    if (milliseconds <= 0) return 'None';
    const totalSeconds: number = Math.floor(milliseconds / 1000);
    const days: number = Math.floor(totalSeconds / 86400);
    const hours: number = Math.floor((totalSeconds % 86400) / 3600);
    const remainingMinutes: number = Math.floor((totalSeconds % 3600) / 60);
    const seconds: number = totalSeconds % 60;
    if (days > 0) return `${days}d ${hours}h`;
    if (hours > 0) return `${hours}h ${remainingMinutes}m`;
    if (seconds > 0) return `${remainingMinutes}m ${seconds}s`;
    return `${remainingMinutes}m`;
  }

  private static cell(key: string, value: string, label: string): StatCell {
    const cell: StatCell = { key: key, value: value, label: label };
    return cell;
  }

  private static section(title: string, cells: StatCell[]): StatSection {
    const section: StatSection = { title: title, cells: cells };
    return section;
  }
}
