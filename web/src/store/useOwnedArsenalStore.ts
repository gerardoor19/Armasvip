import { create } from 'zustand';
import { fetchNui } from '../lib/fivem';
import { t } from '../lib/i18n';
import type { UiTranslations } from '../lib/i18n';
import type {
  OwnedActionResponse,
  OwnedArsenalPayload,
  OwnedVipGrant,
  SkinActionResponse,
  SkinContextResponse,
  WeaponComponentMeta,
  WeaponSkin,
  WeaponTint,
} from '../types';

interface OwnedArsenalState {
  isOpen: boolean;
  ownerName: string;
  grants: OwnedVipGrant[];
  components: Record<string, WeaponComponentMeta>;
  tints: WeaponTint[];
  skins: WeaponSkin[];
  imageBase: string;
  translations: UiTranslations;
  selectedGrantId: number | null;
  pending: boolean;
  skinContextLoading: boolean;
  lastMessage: { ok: boolean; text: string } | null;
  open: (payload: OwnedArsenalPayload) => void;
  close: () => void;
  selectGrant: (id: number) => void;
  equip: (id: number) => Promise<void>;
  setTint: (id: number, tint: number) => Promise<void>;
  loadSkinContext: () => Promise<void>;
  setSkin: (id: number, skinId: string) => Promise<void>;
}

const mergeGrants = (incoming: OwnedVipGrant[], previous: OwnedVipGrant[] = []) => {
  const old = new Map(previous.map((grant) => [grant.id, grant]));
  return incoming.map((grant) => ({ ...old.get(grant.id), ...grant }));
};

const applyContext = (
  context: OwnedArsenalPayload,
  selectedGrantId: number | null,
  previous: OwnedVipGrant[] = [],
) => {
  const grants = mergeGrants(context.grants, previous);
  return {
    ownerName: context.ownerName ?? '',
    grants,
    components: context.components,
    tints: context.tints,
    imageBase: context.imageBase,
    translations: context.translations ?? {},
    selectedGrantId: grants.some((g) => g.id === selectedGrantId)
      ? selectedGrantId
      : grants[0]?.id ?? null,
  };
};

export const useOwnedArsenalStore = create<OwnedArsenalState>((set, get) => ({
  isOpen: false,
  ownerName: '',
  grants: [],
  components: {},
  tints: [],
  skins: [],
  imageBase: '',
  translations: {},
  selectedGrantId: null,
  pending: false,
  skinContextLoading: false,
  lastMessage: null,

  open: (payload) => {
    set({
      isOpen: true,
      pending: false,
      skinContextLoading: false,
      lastMessage: null,
      skins: [],
      ...applyContext(payload, null),
    });
    void get().loadSkinContext();
  },
  close: () => set({ isOpen: false, pending: false, skinContextLoading: false, lastMessage: null }),
  selectGrant: (id) => set({ selectedGrantId: id, lastMessage: null }),

  equip: async (id) => {
    if (get().pending) return;
    set({ pending: true, lastMessage: null });
    const response = await fetchNui<OwnedActionResponse>('armasvip:ownedEquip', { grantId: id });
    const patch = response.context ? applyContext(response.context, id, get().grants) : {};
    const translations = response.context?.translations ?? get().translations;
    set({
      ...patch,
      pending: false,
      lastMessage: response.ok
        ? { ok: true, text: t(translations, 'ui_owned_withdraw_success') }
        : { ok: false, text: response.reason === 'already_equipped'
          ? t(translations, 'ui_owned_already_inventory')
          : t(translations, 'ui_owned_withdraw_failed') },
    });
  },

  setTint: async (id, tint) => {
    if (get().pending) return;
    set({ pending: true, lastMessage: null });
    const response = await fetchNui<OwnedActionResponse>('armasvip:ownedSetTint', { grantId: id, tint });
    const patch = response.context ? applyContext(response.context, id, get().grants) : {};
    const translations = response.context?.translations ?? get().translations;
    set({
      ...patch,
      pending: false,
      lastMessage: response.ok
        ? { ok: true, text: t(translations, 'ui_owned_tint_saved') }
        : { ok: false, text: response.reason === 'tint_locked'
          ? t(translations, 'ui_owned_tint_locked')
          : t(translations, 'ui_owned_tint_failed') },
    });
  },

  loadSkinContext: async () => {
    if (get().skinContextLoading) return;
    set({ skinContextLoading: true });

    const response = await fetchNui<SkinContextResponse>('armasvip:getSkinContext');
    if (!response?.ok) {
      set({ skinContextLoading: false });
      return;
    }

    const states = response.states ?? {};
    const grants = get().grants.map((grant) => {
      const state = states[String(grant.id)];
      return state
        ? {
            ...grant,
            activeSkin: state.activeSkin,
            unlockedSkins: state.unlockedSkins,
            skinSupported: state.supported,
          }
        : grant;
    });

    set({
      grants,
      skins: response.catalog ?? [],
      translations: { ...get().translations, ...(response.translations ?? {}) },
      skinContextLoading: false,
    });
  },

  setSkin: async (id, skinId) => {
    if (get().pending) return;
    set({ pending: true, lastMessage: null });

    const response = await fetchNui<SkinActionResponse>('armasvip:ownedSetSkin', { grantId: id, skinId });
    const translations = get().translations;

    if (response?.ok) {
      set({
        grants: get().grants.map((grant) => grant.id === id
          ? {
              ...grant,
              activeSkin: response.state?.activeSkin ?? skinId,
              unlockedSkins: response.state?.unlockedSkins ?? grant.unlockedSkins,
              skinSupported: response.state?.supported ?? grant.skinSupported,
            }
          : grant),
        pending: false,
        lastMessage: { ok: true, text: t(translations, 'ui_skin_saved') },
      });
      return;
    }

    set({
      pending: false,
      lastMessage: {
        ok: false,
        text: response?.reason === 'skin_locked'
          ? t(translations, 'ui_skin_locked')
          : response?.reason === 'skin_not_compatible'
            ? t(translations, 'ui_skin_not_supported')
            : t(translations, 'ui_skin_failed'),
      },
    });
  },
}));
