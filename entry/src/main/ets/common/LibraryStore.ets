export interface MangaRecord {
  id: number;
  source: string;
  status: string;
  totalChapters: number;
  readChapters: number;
  downloadedChapters: number;
  globalUpdate: boolean;
  readTimeMinutes: number;
  tracked: boolean;
  score: number;
}

export interface LibraryState {
  loggedInTrackers: number;
  manga: MangaRecord[];
}

export class LibraryStore {
  static seedLocalRead(): void {
    const manga: MangaRecord[] = [
      { id: 1, source: 'local', status: 'ongoing', totalChapters: 1,
        readChapters: 1, downloadedChapters: 0, globalUpdate: true,
        readTimeMinutes: 134 / 60, tracked: false, score: 0 },
    ];
    AppStorage.SetOrCreate<MangaRecord[]>('library_manga', manga);
    AppStorage.SetOrCreate<number>('logged_in_trackers', 0);
  }

  static state(): LibraryState {
    const manga: MangaRecord[] = AppStorage.Get<MangaRecord[]>('library_manga') || [];
    const trackers: number = AppStorage.Get<number>('logged_in_trackers') || 0;
    const state: LibraryState = { loggedInTrackers: trackers, manga: manga };
    return state;
  }

  static clearLibrary(): void {
    const manga: MangaRecord[] = [];
    AppStorage.SetOrCreate<MangaRecord[]>('library_manga', manga);
    AppStorage.SetOrCreate<number>('logged_in_trackers', 0);
  }
}
