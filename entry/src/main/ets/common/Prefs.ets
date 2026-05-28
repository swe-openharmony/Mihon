// ====================================================================
// Prefs — thin wrapper over @kit.ArkData Preferences for the two global
// MoreTab switches. Values persist across tab switches and cold restarts
// (spec 场景二 4.1 / 4.2).
// ====================================================================

import { preferences } from '@kit.ArkData';
import { common } from '@kit.AbilityKit';

const STORE_NAME = 'mihon_more_prefs';

export const KEY_DOWNLOADED_ONLY = 'downloaded_only';
export const KEY_INCOGNITO = 'incognito_mode';

export class Prefs {
  private static store: preferences.Preferences | null = null;

  private static async open(ctx: object): Promise<preferences.Preferences> {
    if (Prefs.store) {
      return Prefs.store;
    }
    const ability = getContext(ctx) as common.UIAbilityContext;
    Prefs.store = await preferences.getPreferences(ability, { name: STORE_NAME });
    return Prefs.store;
  }

  static async getBool(ctx: object, key: string, def: boolean): Promise<boolean> {
    const s = await Prefs.open(ctx);
    const v = await s.get(key, def);
    return v as boolean;
  }

  static async setBool(ctx: object, key: string, val: boolean): Promise<void> {
    const s = await Prefs.open(ctx);
    await s.put(key, val);
    await s.flush();
  }
}
