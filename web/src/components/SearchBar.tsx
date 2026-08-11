import { Search } from 'lucide-react';
import { useArmasVipStore } from '../store/useArmasVipStore';

export function SearchBar() {
  const search = useArmasVipStore((s) => s.search);
  const setSearch = useArmasVipStore((s) => s.setSearch);

  return (
    <div className="relative">
      <Search className="pointer-events-none absolute left-3 top-1/2 h-4 w-4 -translate-y-1/2 text-vip-muted" />
      <input
        value={search}
        onChange={(e) => setSearch(e.target.value)}
        placeholder="Buscar arma..."
        className="w-full rounded-lg border border-vip-border bg-vip-panel-2 py-2 pl-9 pr-3 text-sm text-vip-text placeholder:text-vip-muted transition-colors duration-150 focus:border-vip-accent/50 focus:outline-none"
      />
    </div>
  );
}
