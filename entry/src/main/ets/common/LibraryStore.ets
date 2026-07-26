import { common } from '@kit.AbilityKit';
import { preferences } from '@kit.ArkData';

const LIBRARY_STORE = 'mihon_library';
const MANGA_KEY = 'manga';
const LOCAL_TITLES_KEY = 'local_titles';
const TRACKERS_KEY = 'logged_in_tracker_ids';

export interface LocalChapter {
  number: number;
  name: string;
  content: string;
}

export interface LocalTitleRecord {
  id: number;
  title: string;
  chapters: LocalChapter[];
}

export type TrackerScoreKind = 'ten_point' | 'hundred_point' | 'five_star' | 'decimal';

export interface TrackerBinding {
  trackerId: number;
  score: number;
  scoreKind: TrackerScoreKind;
}

export interface MangaRecord {
  id: number;
  title: string;
  source: string;
  status: string;
  totalChapters: number;
  readChapters: number;
  downloadedChapters: number;
  globalUpdate: boolean;
  readTimeMilliseconds: number;
  tracks: TrackerBinding[];
}

export interface LibraryState {
  loggedInTrackerIds: number[];
  manga: MangaRecord[];
}

export class LibraryStore {
  private static async store(ctx: object): Promise<preferences.Preferences> {
    const context = getContext(ctx) as common.UIAbilityContext;
    return await preferences.getPreferences(context, { name: LIBRARY_STORE });
  }

  static async state(ctx: object): Promise<LibraryState> {
    const store = await LibraryStore.store(ctx);
    const rawManga: string = await store.get(MANGA_KEY, '[]') as string;
    const rawTrackerIds: string = await store.get(TRACKERS_KEY, '[]') as string;
    const state: LibraryState = {
      loggedInTrackerIds: JSON.parse(rawTrackerIds) as number[],
      manga: JSON.parse(rawManga) as MangaRecord[],
    };
    return state;
  }

  static async localTitles(ctx: object): Promise<LocalTitleRecord[]> {
    const store = await LibraryStore.store(ctx);
    const raw: string = await store.get(LOCAL_TITLES_KEY, '[]') as string;
    return JSON.parse(raw) as LocalTitleRecord[];
  }

  static async localTitle(ctx: object, id: number): Promise<LocalTitleRecord | undefined> {
    const titles: LocalTitleRecord[] = await LibraryStore.localTitles(ctx);
    return titles.find((item: LocalTitleRecord) => item.id === id);
  }

  static async discoverLocalTitle(ctx: object, title: LocalTitleRecord): Promise<void> {
    const store = await LibraryStore.store(ctx);
    const current: LocalTitleRecord[] = await LibraryStore.localTitles(ctx);
    const retained: LocalTitleRecord[] = current.filter((item: LocalTitleRecord) => item.id !== title.id);
    await store.put(LOCAL_TITLES_KEY, JSON.stringify(retained.concat(title)));
    await store.flush();
  }

  static async addLocalTitle(ctx: object, title: LocalTitleRecord): Promise<void> {
    const state: LibraryState = await LibraryStore.state(ctx);
    if (state.manga.some((item: MangaRecord) => item.id === title.id)) {
      return;
    }
    const record: MangaRecord = {
      id: title.id,
      title: title.title,
      source: 'local',
      status: 'ongoing',
      totalChapters: title.chapters.length,
      readChapters: 0,
      downloadedChapters: 0,
      globalUpdate: true,
      readTimeMilliseconds: 0,
      tracks: [],
    };
    await LibraryStore.save(ctx, {
      loggedInTrackerIds: state.loggedInTrackerIds,
      manga: state.manga.concat(record),
    });
  }

  static async recordChapterRead(ctx: object, id: number, chapterNumber: number,
    elapsedMilliseconds: number): Promise<void> {
    const state: LibraryState = await LibraryStore.state(ctx);
    const elapsed: number = Math.max(0, Math.floor(elapsedMilliseconds));
    const manga: MangaRecord[] = state.manga.map((item: MangaRecord) => {
      if (item.id !== id) {
        return item;
      }
      const updated: MangaRecord = {
        id: item.id,
        title: item.title,
        source: item.source,
        status: item.status,
        totalChapters: item.totalChapters,
        readChapters: Math.min(item.totalChapters, Math.max(item.readChapters, chapterNumber)),
        downloadedChapters: item.downloadedChapters,
        globalUpdate: item.globalUpdate,
        readTimeMilliseconds: item.readTimeMilliseconds + elapsed,
        tracks: item.tracks,
      };
      return updated;
    });
    await LibraryStore.save(ctx, { loggedInTrackerIds: state.loggedInTrackerIds, manga: manga });
  }

  private static async save(ctx: object, state: LibraryState): Promise<void> {
    const store = await LibraryStore.store(ctx);
    await store.put(MANGA_KEY, JSON.stringify(state.manga));
    await store.put(TRACKERS_KEY, JSON.stringify(state.loggedInTrackerIds));
    await store.flush();
  }
}
