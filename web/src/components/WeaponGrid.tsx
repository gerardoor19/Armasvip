import { useMemo } from 'react';
import { PackageSearch } from 'lucide-react';
import { t } from '../lib/i18n';
import { useArmasVipStore } from '../store/useArmasVipStore';
import { WeaponCard } from './WeaponCard';

export function WeaponGrid() {
  const weapons = useArmasVipStore((s) => s.weapons);
  const activeCategory = useArmasVipStore((s) => s.activeCategory);
  const search = useArmasVipStore((s) => s.search);
  const imageBase = useArmasVipStore((s) => s.imageBase);
  const categories = useArmasVipStore((s) => s.categories);
  const selectedWeapon = useArmasVipStore((s) => s.selectedWeapon);
  const selectWeapon = useArmasVipStore((s) => s.selectWeapon);
  const translations = useArmasVipStore((s) => s.translations);

  const categoryLabels = useMemo(() => Object.fromEntries(categories.map((c) => [c.id, c.label])), [categories]);

  const filtered = useMemo(() => {
    const term = search.trim().toLowerCase();
    return weapons.filter((w) => {
      const matchesCategory = !activeCategory || w.category === activeCategory;
      const matchesSearch = !term || w.label.toLowerCase().includes(term);
      return matchesCategory && matchesSearch;
    });
  }, [weapons, activeCategory, search]);

  if (filtered.length === 0) {
    return (
      <div className="flex flex-1 flex-col items-center justify-center gap-2 text-center text-vip-muted">
        <PackageSearch className="h-6 w-6" />
        <div>
          <p className="text-sm font-medium text-vip-text">{t(translations, 'ui_empty_title')}</p>
          <p className="mt-1 text-xs text-vip-muted">{t(translations, 'ui_empty_subtitle')}</p>
        </div>
      </div>
    );
  }

  return (
    <div className="grid flex-1 auto-rows-min grid-cols-[repeat(auto-fill,minmax(140px,1fr))] gap-4 overflow-y-auto pr-1">
      {filtered.map((weapon) => (
        <WeaponCard
          key={weapon.name}
          weapon={weapon}
          imageBase={imageBase}
          categoryLabel={categoryLabels[weapon.category] ?? weapon.category}
          isSelected={selectedWeapon?.name === weapon.name}
          onSelect={() => selectWeapon(weapon)}
        />
      ))}
    </div>
  );
}
