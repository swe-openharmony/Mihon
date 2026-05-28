// ====================================================================
// StatisticsRepo — aggregates the manga library into the four statistics
// sections (spec 场景一). Values are COMPUTED from the library, not hard
// coded: an empty library yields all-zero counts (spec 场景三), and a
// changed library yields changed values on re-entry (spec 场景二).
//
// Library source resolution:
//   1. filesDir/library_override.json  — runtime/test-controlled override
//   2. bundled rawfile mock_library.json — default populated fixture
// (The override lets a test push a different / empty library to exercise
//  场景二/三 without an in-app library-management UI.)
// ====================================================================

import { MockDataSource } from './MockDataSource';

export interface Manga {
  id: number;
  source: string;            // 'local' marks a local-source entry
  status: string;            // 'completed' | 'ongoing'
  totalChapters: number;
  readChapters: number;
  downloadedChapters: number;
  globalUpdate: boolean;
  readTimeMinutes: number;
  tracked: boolean;
  score: number;             // 10-pt; 0 = unscored
}

export interface LibraryFile {
  loggedInTrackers: number;
  manga: Manga[];
}

export interface StatCell {
  value: string;
  label: string;
}

export interface StatSection {
  title: string;
  cells: StatCell[];
}

export class StatisticsRepo {
  /** Load the manga library from the bundled fixture, then aggregate.
   * (A production build would source this from an RDB / Preferences-backed
   * library; the page re-loads on every entry so values track the library —
   * spec 场景二. aggregate() yields all-zero counts for an empty library —
   * spec 场景三.) */
  static async loadLibrary(ctx: object): Promise<LibraryFile> {
    // Deterministic test selector (EntryAbility.captureTestParams ← `--ps libstate`):
    //   'empty' → empty library (场景三: all-zero stats)
    //   'alt'   → a different library fixture (场景二: values track the library)
    //   else    → the default populated fixture
    const sel: string | undefined = AppStorage.Get<string>('test_libstate');
    if (sel === 'empty') {
      const empty: LibraryFile = { loggedInTrackers: 0, manga: [] };
      return empty;
    }
    const file: string = sel === 'alt' ? 'mock_library_alt.json' : 'mock_library.json';
    return await MockDataSource.loadJson<LibraryFile>(ctx, file);
  }

  /** Aggregate the library into the four spec sections (12 stats total). */
  static aggregate(lib: LibraryFile): StatSection[] {
    const m: Manga[] = lib.manga ? lib.manga : [];
    const loggedInTrackers: number = lib.loggedInTrackers ? lib.loggedInTrackers : 0;

    let readMinutes = 0;
    let completed = 0;
    let inGlobalUpdate = 0;
    let started = 0;
    let local = 0;
    let totalCh = 0;
    let readCh = 0;
    let dlCh = 0;
    let trackedEntries = 0;
    let scoreSum = 0;
    let scoreCount = 0;

    for (const x of m) {
      readMinutes += x.readTimeMinutes;
      if (x.status === 'completed' && x.readChapters >= x.totalChapters) {
        completed += 1;
      }
      if (x.globalUpdate) {
        inGlobalUpdate += 1;
      }
      if (x.readChapters > 0) {
        started += 1;
      }
      if (x.source === 'local') {
        local += 1;
      }
      totalCh += x.totalChapters;
      readCh += x.readChapters;
      dlCh += x.downloadedChapters;
      if (x.tracked) {
        trackedEntries += 1;
        if (x.score > 0) {
          scoreSum += x.score;
          scoreCount += 1;
        }
      }
    }

    const meanScore: string = scoreCount > 0
      ? `${(scoreSum / scoreCount).toFixed(2)} ★`
      : '';

    return [
      StatisticsRepo.section('Overview', [
        StatisticsRepo.cell(`${m.length}`, 'In library'),
        StatisticsRepo.cell(StatisticsRepo.fmtDuration(readMinutes), 'Read duration'),
        StatisticsRepo.cell(`${completed}`, 'Completed entries'),
      ]),
      StatisticsRepo.section('Entries', [
        StatisticsRepo.cell(`${inGlobalUpdate}`, 'In global update'),
        StatisticsRepo.cell(`${started}`, 'Started'),
        StatisticsRepo.cell(`${local}`, 'Local'),
      ]),
      StatisticsRepo.section('Chapters', [
        StatisticsRepo.cell(`${totalCh}`, 'Total'),
        StatisticsRepo.cell(`${readCh}`, 'Read'),
        StatisticsRepo.cell(`${dlCh}`, 'Downloaded'),
      ]),
      StatisticsRepo.section('Trackers', [
        StatisticsRepo.cell(`${trackedEntries}`, 'Tracked entries'),
        StatisticsRepo.cell(meanScore, 'Mean score'),
        StatisticsRepo.cell(`${loggedInTrackers}`, 'Used'),
      ]),
    ];
  }

  static fmtDuration(min: number): string {
    if (min <= 0) {
      return '0m';
    }
    const d: number = Math.floor(min / 1440);
    const h: number = Math.floor((min % 1440) / 60);
    const mm: number = min % 60;
    if (d > 0) {
      return `${d}d ${h}h`;
    }
    if (h > 0) {
      return `${h}h ${mm}m`;
    }
    return `${mm}m`;
  }

  private static cell(value: string, label: string): StatCell {
    const c: StatCell = { value: value, label: label };
    return c;
  }

  private static section(title: string, cells: StatCell[]): StatSection {
    const s: StatSection = { title: title, cells: cells };
    return s;
  }
}
