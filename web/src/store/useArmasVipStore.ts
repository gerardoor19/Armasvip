import { create } from 'zustand';
import { fetchNui } from '../lib/fivem';
import type { ArmasVipPayload, Weapon, WeaponCategory, WeaponComponentMeta, WeaponTint } from '../types';

interface ArmasVipState {
  isOpen: boolean;
  categories: WeaponCategory[];
  weapons: Weapon[];
  components: Record<string, WeaponComponentMeta>;
  tints: WeaponTint[];
  imageBase: string;
  activeCategory: string | null;
  search: string;
  selectedWeapon: Weapon | null;
  selectedComponents: string[];
  selectedTint: number;
  isEquipping: boolean;
  lastResult: { ok: boolean; label: string } | null;
  open: (payload: ArmasVipPayload) => void;
  close: () => void;
  setCategory: (id: string) => void;
  setSearch: (value: string) => void;
  selectWeapon: (weapon: Weapon | null) => void;
  toggleComponent: (name: string) => void;
  setTint: (index: number) => void;
  equip: () => Promise<void>;
  clearResult: () => void;
}

export const useArmasVipStore = create<ArmasVipState>((set, get) => ({
  isOpen: false,
  categories: [],
  weapons: [],
  components: {},
  tints: [],
  imageBase: '',
  activeCategory: null,
  search: '',
  selectedWeapon: null,
  selectedComponents: [],
  selectedTint: 0,
  isEquipping: false,
  lastResult: null,

  open: (payload) => set({
    isOpen: true,
    categories: payload.categories,
    weapons: payload.weapons,
    components: payload.components,
    tints: payload.tints,
    imageBase: payload.imageBase,
    activeCategory: payload.categories[0]?.id ?? null,
    search: '',
    selectedWeapon: null,
    selectedComponents: [],
    selectedTint: 0,
    lastResult: null,
  }),

  close: () => set({ isOpen: false, selectedWeapon: null }),
  setCategory: (id) => set({ activeCategory: id, selectedWeapon: null }),
  setSearch: (value) => set({ search: value }),
  selectWeapon: (weapon) => set({ selectedWeapon: weapon, selectedComponents: [], selectedTint: 0 }),
  toggleComponent: (name) => set((state) => ({
    selectedComponents: state.selectedComponents.includes(name)
      ? state.selectedComponents.filter((c) => c !== name)
      : [...state.selectedComponents, name],
  })),
  setTint: (index) => set({ selectedTint: index }),

  equip: async () => {
    const { selectedWeapon, selectedComponents, selectedTint } = get();
    if (!selectedWeapon || get().isEquipping) return;
    set({ isEquipping: true, lastResult: null });
    const ok = await fetchNui<boolean>('armasvip:equip', {
      weapon: selectedWeapon.name,
      components: selectedComponents,
      tint: selectedTint,
    });
    set({ isEquipping: false, lastResult: { ok, label: selectedWeapon.label } });
  },

  clearResult: () => set({ lastResult: null }),
}));
