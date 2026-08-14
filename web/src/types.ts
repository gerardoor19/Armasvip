import type { UiTranslations } from './lib/i18n';

export interface WeaponCategory {
  id: string;
  label: string;
  icon: string;
}

export interface WeaponComponentMeta {
  label: string;
  type: string;
}

export interface Weapon {
  name: string;
  label: string;
  category: string;
  ammoname: string | null;
  throwable: boolean;
  components: string[];
  skinSupported?: boolean;
}

export interface WeaponTint {
  index: number;
  label: string;
}

export interface WeaponSkinSource {
  type: 'none' | 'procedural' | 'asset' | 'url';
  preset?: string;
  path?: string;
  url?: string;
}

export interface WeaponSkin {
  id: string;
  label: string;
  description: string;
  rarity: 'common' | 'rare' | 'epic' | 'legendary' | string;
  animated: boolean;
  weapons: '*' | string[];
  source: WeaponSkinSource;
}

export interface SkinGrantState {
  activeSkin: string;
  unlockedSkins: string[];
  supported: boolean;
}

export interface SkinContextResponse {
  ok: boolean;
  reason?: string;
  catalog?: WeaponSkin[];
  states?: Record<string, SkinGrantState>;
  translations?: UiTranslations;
}

export interface ArmasVipPayload {
  categories: WeaponCategory[];
  weapons: Weapon[];
  components: Record<string, WeaponComponentMeta>;
  tints: WeaponTint[];
  defaultSkins?: string[];
  imageBase: string;
  translations: UiTranslations;
}

export interface EquipRequest {
  weapon: string;
  components: string[];
  tint: number;
  skins?: string[];
}

export interface OwnedVipGrant {
  id: number;
  weapon: string;
  label: string;
  category: string;
  tint: number;
  unlockedTints: number[];
  components: string[];
  installedComponents: string[];
  initialDelivered: boolean;
  inInventory: boolean;
  slot?: number | null;
  durability?: number | null;
  expiresAt?: string | null;
  activeSkin?: string;
  unlockedSkins?: string[];
  skinSupported?: boolean;
}

export interface OwnedArsenalPayload {
  ownerName?: string;
  grants: OwnedVipGrant[];
  components: Record<string, WeaponComponentMeta>;
  tints: WeaponTint[];
  imageBase: string;
  translations: UiTranslations;
}

export interface OwnedActionResponse {
  ok: boolean;
  reason?: string;
  context?: OwnedArsenalPayload | null;
}

export interface SkinActionResponse {
  ok: boolean;
  reason?: string;
  state?: SkinGrantState;
}
