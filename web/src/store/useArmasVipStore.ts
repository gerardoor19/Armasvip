import { create } from 'zustand';
import { fetchNui } from '../lib/fivem';
import type { UiTranslations } from '../lib/i18n';
import type { ArmasVipPayload, SkinContextResponse, Weapon, WeaponCategory, WeaponComponentMeta, WeaponSkin, WeaponTint } from '../types';

interface ArmasVipState {
  isOpen: boolean;
  categories: WeaponCategory[];
  weapons: Weapon[];
  components: Record<string, WeaponComponentMeta>;
  tints: WeaponTint[];
  skins: WeaponSkin[];
  defaultSkins: string[];
  imageBase: string;
  translations: UiTranslations;
  activeCategory: string | null;
  search: string;
  selectedWeapon: Weapon | null;
  selectedComponents: string[];
  selectedTint: number;
  selectedSkins: string[];
  isEquipping: boolean;
  lastResult: { ok: boolean; label: string } | null;
  open: (payload: ArmasVipPayload) => void;
  close: () => void;
  setCategory: (id: string) => void;
  setSearch: (value: string) => void;
  selectWeapon: (weapon: Weapon | null) => void;
  toggleComponent: (name: string) => void;
  setTint: (index: number) => void;
  toggleSkin: (id: string) => void;
  loadSkins: () => Promise<void>;
  equip: () => Promise<void>;
  clearResult: () => void;
}

const normalizeDefaults = (values?: string[]) => {
  const unique = Array.from(new Set((values ?? ['default']).filter((value) => typeof value === 'string' && value.length > 0)));
  return unique.includes('default') ? unique : ['default', ...unique];
};

export const useArmasVipStore = create<ArmasVipState>((set, get) => ({
  isOpen: false,
  categories: [],
  weapons: [],
  components: {},
  tints: [],
  skins: [],
  defaultSkins: ['default'],
  imageBase: '',
  translations: {},
  activeCategory: null,
  search: '',
  selectedWeapon: null,
  selectedComponents: [],
  selectedTint: 0,
  selectedSkins: ['default'],
  isEquipping: false,
  lastResult: null,

  open: (payload) => {
    const defaultSkins = normalizeDefaults(payload.defaultSkins);
    set({
      isOpen: true,
      categories: payload.categories,
      weapons: payload.weapons,
      components: payload.components,
      tints: payload.tints,
      defaultSkins,
      imageBase: payload.imageBase,
      translations: payload.translations ?? {},
      activeCategory: payload.categories[0]?.id ?? null,
      search: '',
      selectedWeapon: null,
      selectedComponents: [],
      selectedTint: 0,
      selectedSkins: defaultSkins,
      lastResult: null,
    });
    void get().loadSkins();
  },

  close: () => set({ isOpen: false, selectedWeapon: null }),
  setCategory: (id) => set({ activeCategory: id, selectedWeapon: null }),
  setSearch: (value) => set({ search: value }),
  selectWeapon: (weapon) => set((state) => ({ selectedWeapon: weapon, selectedComponents: [], selectedTint: 0, selectedSkins: [...state.defaultSkins] })),
  toggleComponent: (name) => set((state) => ({ selectedComponents: state.selectedComponents.includes(name) ? state.selectedComponents.filter((c) => c !== name) : [...state.selectedComponents, name] })),
  setTint: (index) => set({ selectedTint: index }),
  toggleSkin: (id) => set((state) => {
    if (state.defaultSkins.includes(id)) return state;
    return { selectedSkins: state.selectedSkins.includes(id) ? state.selectedSkins.filter((skin) => skin !== id) : [...state.selectedSkins, id] };
  }),
  loadSkins: async () => {
    const response = await fetchNui<SkinContextResponse>('armasvip:getSkinContext');
    if (response?.ok) set({ skins: response.catalog ?? [], translations: { ...get().translations, ...(response.translations ?? {}) } });
  },

  equip: async () => {
    const { selectedWeapon, selectedComponents, selectedTint, selectedSkins } = get();
    if (!selectedWeapon || get().isEquipping) return;
    set({ isEquipping: true, lastResult: null });
    const ok = await fetchNui<boolean>('armasvip:equip', {
      weapon: selectedWeapon.name,
      components: selectedComponents,
      tint: selectedTint,
      skins: selectedSkins,
    });
    set({ isEquipping: false, lastResult: { ok, label: selectedWeapon.label } });
  },

  clearResult: () => set({ lastResult: null }),
}));
