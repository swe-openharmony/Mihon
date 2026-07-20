import { LibraryState, LibraryStore, MangaRecord } from './LibraryStore';

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
  static loadLibrary(): LibraryState {
    return LibraryStore.state();
  }

  static aggregate(lib: LibraryState): StatSection[] {
    const manga: MangaRecord[] = lib.manga;
    let readMinutes: number = 0;
    let completed: number = 0;
    let inGlobalUpdate: number = 0;
    let started: number = 0;
    let local: number = 0;
    let totalChapters: number = 0;
    let readChapters: number = 0;
    let downloadedChapters: number = 0;
    let trackedEntries: number = 0;
    let scoreSum: number = 0;
    let scoreCount: number = 0;
    for (const item of manga) {
      readMinutes += item.readTimeMinutes;
      if (item.status === 'completed' && item.readChapters >= item.totalChapters) completed += 1;
      if (item.globalUpdate) inGlobalUpdate += 1;
      if (item.readChapters > 0) started += 1;
      if (item.source === 'local') local += 1;
      totalChapters += item.totalChapters;
      readChapters += item.readChapters;
      downloadedChapters += item.downloadedChapters;
      if (item.tracked) {
        trackedEntries += 1;
        if (item.score > 0) {
          scoreSum += item.score;
          scoreCount += 1;
        }
      }
    }
    const meanScore: string = scoreCount > 0 ? `${(scoreSum / scoreCount).toFixed(2)} ★` : 'N/A';
    return [
      StatisticsRepo.section('Overview', [
        StatisticsRepo.cell('stat_in_library', `${manga.length}`, 'In library'),
        StatisticsRepo.cell('stat_read_duration', StatisticsRepo.fmtDuration(readMinutes), 'Read duration'),
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
        StatisticsRepo.cell('stat_used', `${lib.loggedInTrackers}`, 'Used'),
      ]),
    ];
  }

  static fmtDuration(minutes: number): string {
    if (minutes <= 0) return 'None';
    const totalSeconds: number = Math.round(minutes * 60);
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
