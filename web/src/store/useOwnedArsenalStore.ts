import { create } from 'zustand';
import { fetchNui } from '../lib/fivem';
import { t } from '../lib/i18n';
import type { UiTranslations } from '../lib/i18n';
import type { OwnedActionResponse, OwnedArsenalPayload, OwnedVipGrant, WeaponComponentMeta, WeaponTint } from '../types';

interface OwnedArsenalState {
  isOpen: boolean;
  ownerName: string;
  grants: OwnedVipGrant[];
  components: Record<string, WeaponComponentMeta>;
  tints: WeaponTint[];
  imageBase: string;
  translations: UiTranslations;
  selectedGrantId: number | null;
  pending: boolean;
  lastMessage: { ok: boolean; text: string } | null;
  open: (payload: OwnedArsenalPayload) => void;
  close: () => void;
  selectGrant: (id: number) => void;
  equip: (id: number) => Promise<void>;
  setTint: (id: number, tint: number) => Promise<void>;
}

const applyContext = (context: OwnedArsenalPayload, selectedGrantId: number | null) => ({
  ownerName: context.ownerName ?? '',
  grants: context.grants,
  components: context.components,
  tints: context.tints,
  imageBase: context.imageBase,
  translations: context.translations ?? {},
  selectedGrantId: context.grants.some((g) => g.id === selectedGrantId)
    ? selectedGrantId
    : context.grants[0]?.id ?? null,
});

export const useOwnedArsenalStore = create<OwnedArsenalState>((set, get) => ({
  isOpen: false,
  ownerName: '',
  grants: [],
  components: {},
  tints: [],
  imageBase: '',
  translations: {},
  selectedGrantId: null,
  pending: false,
  lastMessage: null,

  open: (payload) => set({ isOpen: true, pending: false, lastMessage: null, ...applyContext(payload, null) }),
  close: () => set({ isOpen: false, pending: false, lastMessage: null }),
  selectGrant: (id) => set({ selectedGrantId: id, lastMessage: null }),

  equip: async (id) => {
    if (get().pending) return;
    set({ pending: true, lastMessage: null });
    const response = await fetchNui<OwnedActionResponse>('armasvip:ownedEquip', { grantId: id });
    const patch = response.context ? applyContext(response.context, id) : {};
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
    const patch = response.context ? applyContext(response.context, id) : {};
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
}));
