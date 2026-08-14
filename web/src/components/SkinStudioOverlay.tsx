import { useMemo, useState } from 'react';
import { Check, Lock, Palette, Sparkles, WandSparkles, X } from 'lucide-react';
import { AnimatePresence, motion } from 'framer-motion';
import { t } from '../lib/i18n';
import { useOwnedArsenalStore } from '../store/useOwnedArsenalStore';
import type { WeaponSkin } from '../types';

const rarityClass: Record<string, string> = {
  common: 'text-slate-300 border-slate-400/20 bg-slate-400/[0.07]',
  rare: 'text-sky-300 border-sky-400/20 bg-sky-400/[0.07]',
  epic: 'text-violet-300 border-violet-400/20 bg-violet-400/[0.07]',
  legendary: 'text-amber-300 border-amber-400/20 bg-amber-400/[0.07]',
};

function isCompatible(skin: WeaponSkin, weapon: string) {
  return skin.weapons === '*' || skin.weapons.some((name) => name.toUpperCase() === weapon.toUpperCase());
}

function SkinSwatch({ skin, className = '' }: { skin: WeaponSkin; className?: string }) {
  if (skin.source.type === 'procedural' && skin.source.preset) {
    return (
      <iframe
        title={`${skin.label} preview`}
        src={`./skin-renderer.html?preset=${encodeURIComponent(skin.source.preset)}`}
        className={`pointer-events-none border-0 ${className}`}
      />
    );
  }

  const source = skin.source.type === 'asset' ? skin.source.path : skin.source.type === 'url' ? skin.source.url : null;
  if (source) return <img src={source} alt="" className={`object-cover ${className}`} draggable={false} />;

  return (
    <div className={`flex items-center justify-center bg-gradient-to-br from-white/[0.06] to-black/20 ${className}`}>
      <Palette className="h-7 w-7 text-vip-muted/55" />
    </div>
  );
}

export function SkinStudioOverlay() {
  const [open, setOpen] = useState(false);
  const grants = useOwnedArsenalStore((s) => s.grants);
  const skins = useOwnedArsenalStore((s) => s.skins);
  const selectedGrantId = useOwnedArsenalStore((s) => s.selectedGrantId);
  const setSkin = useOwnedArsenalStore((s) => s.setSkin);
  const pending = useOwnedArsenalStore((s) => s.pending);
  const translations = useOwnedArsenalStore((s) => s.translations);
  const imageBase = useOwnedArsenalStore((s) => s.imageBase);

  const selectedGrant = useMemo(
    () => grants.find((grant) => grant.id === selectedGrantId) ?? grants[0] ?? null,
    [grants, selectedGrantId],
  );

  const compatibleSkins = useMemo(
    () => selectedGrant ? skins.filter((skin) => isCompatible(skin, selectedGrant.weapon)) : [],
    [skins, selectedGrant],
  );

  const activeSkin = compatibleSkins.find((skin) => skin.id === selectedGrant?.activeSkin) ?? compatibleSkins[0] ?? null;
  const unlocked = new Set(selectedGrant?.unlockedSkins ?? []);

  if (!selectedGrant || skins.length === 0) return null;

  return (
    <>
      <button
        type="button"
        onClick={() => setOpen(true)}
        className="absolute bottom-[calc(4vh+18px)] right-[calc(2.5vw+18px)] z-20 flex items-center gap-2 rounded-xl border border-[#ff7a00]/35 bg-[#11151c]/95 px-4 py-3 text-[10px] font-bold uppercase tracking-[0.13em] text-[#ff9b3d] shadow-[0_14px_34px_rgba(0,0,0,.38)] backdrop-blur-md transition hover:-translate-y-px hover:border-[#ff7a00]/60 hover:bg-[#171b23]"
      >
        <WandSparkles className="h-4 w-4" />
        {t(translations, 'ui_skin_open')}
      </button>

      <AnimatePresence>
        {open && (
          <motion.div
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            exit={{ opacity: 0 }}
            className="absolute inset-0 z-40 flex items-center justify-center bg-black/72 p-5 backdrop-blur-sm"
          >
            <motion.section
              initial={{ opacity: 0, scale: 0.97, y: 12 }}
              animate={{ opacity: 1, scale: 1, y: 0 }}
              exit={{ opacity: 0, scale: 0.97, y: 12 }}
              transition={{ duration: 0.16 }}
              className="flex h-[min(720px,93vh)] w-[min(1160px,96vw)] overflow-hidden rounded-[22px] border border-white/[0.08] bg-[#090c12] shadow-[0_28px_90px_rgba(0,0,0,.6)]"
            >
              <aside className="flex w-[360px] shrink-0 flex-col border-r border-white/[0.06] bg-[#080b10]">
                <div className="border-b border-white/[0.06] p-5">
                  <div className="flex items-start justify-between gap-4">
                    <div>
                      <p className="text-[9px] font-bold uppercase tracking-[0.22em] text-[#ff8a1f]">{t(translations, 'ui_skin_studio')}</p>
                      <h2 className="mt-1 text-[20px] font-semibold text-vip-text">{selectedGrant.label}</h2>
                      <p className="mt-2 text-[10px] leading-relaxed text-vip-muted">{t(translations, 'ui_skin_studio_subtitle')}</p>
                    </div>
                    <button onClick={() => setOpen(false)} className="flex h-9 w-9 shrink-0 items-center justify-center rounded-lg border border-white/[0.08] text-vip-muted transition hover:bg-white/[0.05] hover:text-white" aria-label={t(translations, 'ui_skin_close')}>
                      <X className="h-4 w-4" />
                    </button>
                  </div>
                </div>

                <div className="flex min-h-0 flex-1 flex-col p-4">
                  <div className="mb-3 flex items-center justify-between px-1">
                    <span className="text-[9px] font-semibold uppercase tracking-[0.16em] text-vip-muted">{t(translations, 'ui_skin_collection')}</span>
                    <span className="text-[9px] text-vip-muted">{unlocked.size}/{compatibleSkins.length}</span>
                  </div>
                  <div className="min-h-0 flex-1 space-y-2 overflow-y-auto pr-1">
                    {compatibleSkins.map((skin) => {
                      const isUnlocked = unlocked.has(skin.id);
                      const isActive = selectedGrant.activeSkin === skin.id;
                      return (
                        <button
                          key={skin.id}
                          disabled={!isUnlocked || pending || selectedGrant.skinSupported === false}
                          onClick={() => void setSkin(selectedGrant.id, skin.id)}
                          className={`group grid w-full grid-cols-[74px_1fr_auto] items-center gap-3 rounded-xl border p-2.5 text-left transition ${
                            isActive
                              ? 'border-[#ff7a00]/60 bg-[#ff7a00]/[0.075]'
                              : isUnlocked
                                ? 'border-white/[0.055] bg-white/[0.02] hover:border-white/[0.14] hover:bg-white/[0.04]'
                                : 'border-white/[0.04] bg-black/20 opacity-45'
                          }`}
                        >
                          <div className="h-12 w-[74px] overflow-hidden rounded-lg border border-white/[0.05] bg-black/30">
                            <SkinSwatch skin={skin} className="h-full w-full" />
                          </div>
                          <div className="min-w-0">
                            <div className="flex items-center gap-2">
                              <p className="truncate text-[11px] font-semibold text-vip-text">{skin.label}</p>
                              {skin.animated && <Sparkles className="h-3 w-3 shrink-0 text-[#21d4f4]" />}
                            </div>
                            <div className="mt-1 flex items-center gap-1.5">
                              <span className={`rounded-md border px-1.5 py-0.5 text-[7px] font-bold uppercase tracking-[0.11em] ${rarityClass[skin.rarity] ?? rarityClass.common}`}>
                                {t(translations, `ui_skin_rarity_${skin.rarity}`)}
                              </span>
                              <span className="text-[8px] text-vip-muted">{skin.animated ? t(translations, 'ui_skin_animated') : t(translations, 'ui_skin_static')}</span>
                            </div>
                          </div>
                          <div className="pr-1">
                            {!isUnlocked ? <Lock className="h-4 w-4 text-vip-muted" /> : isActive ? <span className="flex h-6 w-6 items-center justify-center rounded-full bg-[#ff7a00] text-white"><Check className="h-3.5 w-3.5" /></span> : null}
                          </div>
                        </button>
                      );
                    })}
                  </div>
                </div>
              </aside>

              <main className="flex min-w-0 flex-1 flex-col p-6">
                {selectedGrant.skinSupported === false ? (
                  <div className="flex flex-1 items-center justify-center text-center">
                    <div className="max-w-sm">
                      <Palette className="mx-auto h-12 w-12 text-vip-muted/35" />
                      <h3 className="mt-4 text-lg font-semibold text-vip-text">{t(translations, 'ui_skin_not_supported')}</h3>
                    </div>
                  </div>
                ) : activeSkin ? (
                  <>
                    <div className="relative flex min-h-0 flex-1 items-center justify-center overflow-hidden rounded-2xl border border-white/[0.06] bg-[#05070b]">
                      <div className="absolute inset-0 opacity-70">
                        <SkinSwatch skin={activeSkin} className="h-full w-full" />
                      </div>
                      <div className="absolute inset-0 bg-[radial-gradient(ellipse_at_center,rgba(0,0,0,.12),rgba(0,0,0,.82)_72%)]" />
                      <motion.img
                        key={`${selectedGrant.id}-${activeSkin.id}`}
                        initial={{ opacity: 0, scale: 0.95, y: 8 }}
                        animate={{ opacity: 1, scale: 1, y: 0 }}
                        src={`${imageBase}${selectedGrant.weapon}.png`}
                        alt={selectedGrant.label}
                        className="relative z-10 max-h-[300px] max-w-[82%] object-contain drop-shadow-[0_26px_34px_rgba(0,0,0,.72)]"
                        draggable={false}
                      />
                      <div className="absolute left-5 top-5 z-20 flex items-center gap-2 rounded-lg border border-white/[0.08] bg-black/45 px-3 py-2 backdrop-blur-sm">
                        {activeSkin.animated && <Sparkles className="h-3.5 w-3.5 text-[#21d4f4]" />}
                        <span className="text-[9px] font-bold uppercase tracking-[0.14em] text-white">{activeSkin.animated ? t(translations, 'ui_skin_animated') : t(translations, 'ui_skin_static')}</span>
                      </div>
                    </div>

                    <div className="mt-5 grid grid-cols-[1fr_auto] items-end gap-5">
                      <div>
                        <div className="flex items-center gap-2">
                          <h3 className="text-[24px] font-semibold text-vip-text">{activeSkin.label}</h3>
                          <span className={`rounded-lg border px-2 py-1 text-[8px] font-bold uppercase tracking-[0.12em] ${rarityClass[activeSkin.rarity] ?? rarityClass.common}`}>
                            {t(translations, `ui_skin_rarity_${activeSkin.rarity}`)}
                          </span>
                        </div>
                        <p className="mt-2 max-w-[620px] text-[11px] leading-relaxed text-vip-muted">{activeSkin.description}</p>
                        <p className="mt-3 text-[9px] text-[#75e8fa]">{t(translations, 'ui_skin_inspect_hint')}</p>
                      </div>
                      <div className="flex items-center gap-2 rounded-xl border border-[#ff7a00]/25 bg-[#ff7a00]/[0.06] px-4 py-3 text-[10px] font-bold uppercase tracking-[0.12em] text-[#ff9b3d]">
                        <Check className="h-4 w-4" />
                        {t(translations, 'ui_skin_equipped')}
                      </div>
                    </div>
                  </>
                ) : null}
              </main>
            </motion.section>
          </motion.div>
        )}
      </AnimatePresence>
    </>
  );
}
