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
}

export interface WeaponTint {
  index: number;
  label: string;
}

export interface ArmasVipPayload {
  categories: WeaponCategory[];
  weapons: Weapon[];
  components: Record<string, WeaponComponentMeta>;
  tints: WeaponTint[];
  imageBase: string;
  translations: UiTranslations;
}

export interface EquipRequest {
  weapon: string;
  components: string[];
  tint: number;
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
