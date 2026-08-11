import { useMemo, useState } from 'react';
import { AnimatePresence, motion } from 'framer-motion';
import { Check, Crosshair, Loader2, Sparkles } from 'lucide-react';
import { useArmasVipStore } from '../store/useArmasVipStore';
import { componentTypeOrder, componentTypeTranslationKeys, tintColors } from '../lib/constants';
import { t } from '../lib/i18n';

export function WeaponDetail() {
  const selectedWeapon = useArmasVipStore((s) => s.selectedWeapon);
  const imageBase = useArmasVipStore((s) => s.imageBase);
  const categories = useArmasVipStore((s) => s.categories);
  const componentsMeta = useArmasVipStore((s) => s.components);
  const selectedComponents = useArmasVipStore((s) => s.selectedComponents);
  const toggleComponent = useArmasVipStore((s) => s.toggleComponent);
  const tints = useArmasVipStore((s) => s.tints);
  const selectedTint = useArmasVipStore((s) => s.selectedTint);
  const setTint = useArmasVipStore((s) => s.setTint);
  const isEquipping = useArmasVipStore((s) => s.isEquipping);
  const lastResult = useArmasVipStore((s) => s.lastResult);
  const equip = useArmasVipStore((s) => s.equip);
  const translations = useArmasVipStore((s) => s.translations);
  const [imgError, setImgError] = useState(false);

  const groupedComponents = useMemo(() => {
    if (!selectedWeapon) return [];
    const byType = new Map<string, string[]>();
    for (const name of selectedWeapon.components) {
      const type = componentsMeta[name]?.type ?? 'other';
      if (!byType.has(type)) byType.set(type, []);
      byType.get(type)!.push(name);
    }
    return componentTypeOrder.filter((type) => byType.has(type)).map((type) => ({ type, items: byType.get(type)! }));
  }, [selectedWeapon, componentsMeta]);

  const categoryLabel = useMemo(
    () => (selectedWeapon ? categories.find((c) => c.id === selectedWeapon.category)?.label ?? selectedWeapon.category : ''),
    [selectedWeapon, categories],
  );

  if (!selectedWeapon) {
    return (
      <div className="flex w-80 shrink-0 flex-col items-center justify-center gap-3 border-l border-vip-border p-6 text-center">
        <span className="flex h-11 w-11 items-center justify-center rounded-full bg-vip-panel-2 text-vip-muted"><Sparkles className="h-5 w-5" /></span>
        <div>
          <p className="text-sm font-medium text-vip-text">{t(translations, 'ui_no_weapon_selected')}</p>
          <p className="mt-1 text-xs text-vip-muted">{t(translations, 'ui_select_weapon_hint')}</p>
        </div>
      </div>
    );
  }

  return (
    <motion.aside key={selectedWeapon.name} initial={{ opacity: 0, x: 24 }} animate={{ opacity: 1, x: 0 }} transition={{ duration: 0.18 }} className="flex w-80 shrink-0 flex-col border-l border-vip-border p-5">
      <div className="relative flex h-32 items-center justify-center overflow-hidden rounded-xl bg-vip-panel-2/60">
        <div className="pointer-events-none absolute inset-0 bg-[radial-gradient(circle_at_50%_35%,rgba(255,122,0,0.1),transparent_65%)]" />
        {imgError ? <Crosshair className="h-12 w-12 text-vip-muted" /> : (
          <img src={`${imageBase}${selectedWeapon.name}.png`} alt={selectedWeapon.label} className="relative h-32 max-w-full object-contain drop-shadow-[0_6px_16px_rgba(0,0,0,0.6)]" onError={() => setImgError(true)} draggable={false} />
        )}
      </div>
      <h2 className="mt-3 text-center text-base tracking-wide text-vip-text">{selectedWeapon.label}</h2>
      <p className="text-center text-[11px] uppercase tracking-wide text-vip-cyan/80">{categoryLabel}</p>

      <div className="mt-4 flex-1 space-y-4 overflow-y-auto pr-1">
        {groupedComponents.length === 0 ? <p className="text-center text-xs text-vip-muted">{t(translations, 'ui_no_components')}</p> : groupedComponents.map(({ type, items }) => (
          <div key={type}>
            <h3 className="mb-1.5 text-[11px] font-semibold uppercase tracking-wide text-vip-muted">
              {t(translations, componentTypeTranslationKeys[type] ?? 'ui_component_other', type)}
            </h3>
            <div className="flex flex-wrap gap-1.5">
              {items.map((name) => {
                const isActive = selectedComponents.includes(name);
                return (
                  <button key={name} onClick={() => toggleComponent(name)} className={`flex items-center gap-1.5 rounded-lg border px-2.5 py-1.5 text-xs transition-colors duration-150 ${isActive ? 'border-vip-accent/60 bg-vip-accent/15 text-vip-accent-soft' : 'border-vip-border bg-vip-panel-2 text-vip-muted hover:text-vip-text'}`}>
                    {isActive && <Check className="h-3 w-3" strokeWidth={3} />}{componentsMeta[name]?.label ?? name}
                  </button>
                );
              })}
            </div>
          </div>
        ))}

        <div>
          <h3 className="mb-1.5 text-[11px] font-semibold uppercase tracking-wide text-vip-muted">{t(translations, 'ui_tint')}</h3>
          <div className="flex flex-wrap gap-2">
            {tints.map((tint) => (
              <button key={tint.index} onClick={() => setTint(tint.index)} title={tint.label} className={`relative flex h-6 w-6 items-center justify-center rounded-full border-2 transition-transform ${selectedTint === tint.index ? 'scale-110 border-vip-accent' : 'border-vip-border hover:scale-105'}`} style={{ backgroundColor: tintColors[tint.index] ?? '#6b7280' }}>
                {selectedTint === tint.index && <span className="flex h-3.5 w-3.5 items-center justify-center rounded-full bg-black/45"><Check className="h-2.5 w-2.5 text-white" strokeWidth={3} /></span>}
              </button>
            ))}
          </div>
        </div>
      </div>

      <AnimatePresence>
        {lastResult && (
          <motion.div initial={{ opacity: 0, y: 6 }} animate={{ opacity: 1, y: 0 }} exit={{ opacity: 0 }} className={`mb-2 rounded-lg px-3 py-2 text-xs ${lastResult.ok ? 'bg-emerald-500/15 text-emerald-400' : 'bg-red-500/15 text-red-400'}`}>
            {lastResult.ok ? `${lastResult.label} ${t(translations, 'ui_selection_success')}` : t(translations, 'ui_selection_failed')}
          </motion.div>
        )}
      </AnimatePresence>

      <button onClick={() => void equip()} disabled={isEquipping} className="flex items-center justify-center gap-2 rounded-lg bg-gradient-to-b from-[#ff8a00] to-[#ff6a00] py-3 text-sm font-bold uppercase tracking-wide text-white shadow-[0_10px_30px_rgba(255,115,0,0.2)] transition-all duration-150 hover:-translate-y-px hover:brightness-110 disabled:translate-y-0 disabled:opacity-60 disabled:hover:brightness-100">
        {isEquipping ? <Loader2 className="h-4 w-4 animate-spin" /> : <Check className="h-4 w-4" />}
        {isEquipping ? t(translations, 'ui_opening_assignment') : t(translations, 'ui_assign_weapon')}
      </button>
    </motion.aside>
  );
}
