import { create } from 'zustand';
import { fetchNui } from '../lib/fivem';
import type { OwnedActionResponse, OwnedArsenalPayload, OwnedVipGrant, WeaponComponentMeta, WeaponTint } from '../types';

interface OwnedArsenalState {
  isOpen: boolean;
  ownerName: string;
  grants: OwnedVipGrant[];
  components: Record<string, WeaponComponentMeta>;
  tints: WeaponTint[];
  imageBase: string;
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
    set({
      ...patch,
      pending: false,
      lastMessage: response.ok
        ? { ok: true, text: 'Arma retirada y añadida a tu inventario.' }
        : { ok: false, text: response.reason === 'already_equipped' ? 'Esta arma ya está en tu inventario.' : 'No se pudo retirar el arma.' },
    });
  },

  setTint: async (id, tint) => {
    if (get().pending) return;
    set({ pending: true, lastMessage: null });
    const response = await fetchNui<OwnedActionResponse>('armasvip:ownedSetTint', { grantId: id, tint });
    const patch = response.context ? applyContext(response.context, id) : {};
    set({
      ...patch,
      pending: false,
      lastMessage: response.ok
        ? { ok: true, text: 'Camo aplicado y guardado.' }
        : { ok: false, text: response.reason === 'tint_locked' ? 'Ese camo todavía está bloqueado.' : 'No se pudo aplicar el camo.' },
    });
  },
}));
