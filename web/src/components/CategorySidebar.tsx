import { categoryIcons } from '../lib/icons';
import { useArmasVipStore } from '../store/useArmasVipStore';

export function CategorySidebar() {
  const categories = useArmasVipStore((s) => s.categories);
  const weapons = useArmasVipStore((s) => s.weapons);
  const activeCategory = useArmasVipStore((s) => s.activeCategory);
  const setCategory = useArmasVipStore((s) => s.setCategory);

  return (
    <nav className="flex w-56 shrink-0 flex-col gap-1 border-r border-vip-border p-3">
      <span className="mb-1 px-3 text-[10px] font-semibold uppercase tracking-[0.14em] text-vip-muted">
        Categorías
      </span>
      {categories.map((category) => {
        const Icon = categoryIcons[category.icon] ?? categoryIcons.Crosshair;
        const isActive = category.id === activeCategory;
        const count = weapons.filter((w) => w.category === category.id).length;

        return (
          <button
            key={category.id}
            onClick={() => setCategory(category.id)}
            className={`group relative flex items-center gap-3 rounded-lg py-2.5 pl-3.5 pr-3 text-left text-sm transition-colors ${
              isActive
                ? 'bg-vip-accent/10 text-vip-accent-soft'
                : 'text-vip-muted hover:bg-vip-panel-2 hover:text-vip-text'
            }`}
          >
            {isActive && (
              <span className="absolute left-0 top-1/2 h-4 w-[3px] -translate-y-1/2 rounded-full bg-vip-accent-soft" />
            )}
            <Icon
              className={`h-4 w-4 shrink-0 ${isActive ? 'text-vip-accent-soft' : 'text-vip-muted group-hover:text-vip-text'}`}
            />
            <span className="flex-1 truncate font-medium">{category.label}</span>
            <span
              className={`rounded-full px-1.5 py-0.5 text-[10px] ${
                isActive ? 'bg-vip-accent/20 text-vip-accent-soft' : 'bg-vip-panel-2 text-vip-muted'
              }`}
            >
              {count}
            </span>
          </button>
        );
      })}
    </nav>
  );
}
