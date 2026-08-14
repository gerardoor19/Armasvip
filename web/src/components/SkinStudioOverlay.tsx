import { useEffect, useMemo, useState, type CSSProperties } from 'react';
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

  const source = skin.source.type === 'asset'
    ? skin.source.path
    : skin.source.type === 'url'
      ? skin.source.url
      : null;

  if (source) return <img src={source} alt="" className={`object-cover ${className}`} draggable={false} />;

  return (
    <div className={`flex items-center justify-center bg-gradient-to-br from-white/[0.06] to-black/20 ${className}`}>
      <Palette className="h-7 w-7 text-vip-muted/55" />
    </div>
  );
}

function WeaponSkinPreview({ skin, image, label }: { skin: WeaponSkin; image: string; label: string }) {
  const maskStyle: CSSProperties = {
    WebkitMaskImage: `url(${image})`,
    WebkitMaskRepeat: 'no-repeat',
    WebkitMaskPosition: 'center',
    WebkitMaskSize: 'contain',
    maskImage: `url(${image})`,
    maskRepeat: 'no-repeat',
    maskPosition: 'center',
    maskSize: 'contain',
  };

  return (
    <div className="relative h-full w-full">
      <img
        src={image}
        alt={label}
        className={`absolute inset-0 h-full w-full object-contain drop-shadow-[0_28px_38px_rgba(0,0,0,.78)] ${skin.source.type === 'none' ? 'opacity-100' : 'opacity-28'}`}
        draggable={false}
      />

      {skin.source.type !== 'none' && (
        <div className="absolute inset-[8%]" style={maskStyle}>
          <SkinSwatch skin={skin} className="h-full w-full" />
        </div>
      )}

      {skin.source.type !== 'none' && (
        <img
          src={image}
          alt=""
          className="pointer-events-none absolute inset-0 h-full w-full object-contain opacity-35 mix-blend-screen"
          draggable={false}
        />
      )}
    </div>
  );
}

export function SkinStudioOverlay() {
  const [open, setOpen] = useState(false);
  const [previewSkinId, setPreviewSkinId] = useState<string | null>(null);
  const grants = useOwnedArsenalStore((s) => s.grants);
  const skins = useOwnedArsenalStore((s) => s.skins);
  const selectedGrantId = useOwnedArsenalStore((s) => s.selectedGrantId);
  const setSkin = useOwnedArsenalStore((s) => s.setSkin);
  const loadSkinContext = useOwnedArsenalStore((s) => s.loadSkinContext);
  const skinContextLoading = useOwnedArsenalStore((s) => s.skinContextLoading);
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

  useEffect(() => {
    setPreviewSkinId(selectedGrant?.activeSkin ?? compatibleSkins[0]?.id ?? null);
  }, [selectedGrant?.id, selectedGrant?.activeSkin, compatibleSkins]);

  const previewSkin = compatibleSkins.find((skin) => skin.id === previewSkinId)
    ?? compatibleSkins.find((skin) => skin.id === selectedGrant?.activeSkin)
    ?? compatibleSkins[0]
    ?? null;

  const unlocked = new Set(selectedGrant?.unlockedSkins ?? []);
  const previewUnlocked = previewSkin ? unlocked.has(previewSkin.id) : false;
  const previewActive = previewSkin?.id === selectedGrant?.activeSkin;

  if (!selectedGrant) return null;

  const weaponImage = `${imageBase}${selectedGrant.weapon}.png`;

  const openStudio = () => {
    setPreviewSkinId(selectedGrant.activeSkin ?? compatibleSkins[0]?.id ?? null);
    setOpen(true);
    if (skins.length === 0 && !skinContextLoading) void loadSkinContext();
  };

  return (
    <>
      <button
        type="button"
        onClick={openStudio}
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
                      const isPreview = previewSkin?.id === skin.id;
                      return (
                        <button
                          key={skin.id}
                          disabled={selectedGrant.skinSupported === false}
                          onClick={() => setPreviewSkinId(skin.id)}
                          className={`group grid w-full grid-cols-[74px_1fr_auto] items-center gap-3 rounded-xl border p-2.5 text-left transition ${
                            isPreview
                              ? 'border-[#ff7a00]/60 bg-[#ff7a00]/[0.075]'
                              : isUnlocked
                                ? 'border-white/[0.055] bg-white/[0.02] hover:border-white/[0.14] hover:bg-white/[0.04]'
                                : 'border-white/[0.04] bg-black/20 opacity-55'
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
                {skinContextLoading && skins.length === 0 ? (
                  <div className="flex flex-1 items-center justify-center text-center">
                    <div className="max-w-sm">
                      <Sparkles className="mx-auto h-12 w-12 animate-pulse text-[#21d4f4]/60" />
                      <h3 className="mt-4 text-lg font-semibold text-vip-text">{t(translations, 'ui_skin_loading')}</h3>
                    </div>
                  </div>
                ) : skins.length === 0 ? (
                  <div className="flex flex-1 items-center justify-center text-center">
                    <div className="max-w-sm">
                      <Palette className="mx-auto h-12 w-12 text-vip-muted/35" />
                      <h3 className="mt-4 text-lg font-semibold text-vip-text">{t(translations, 'ui_skin_load_failed')}</h3>
                      <button type="button" onClick={() => void loadSkinContext()} className="mt-4 rounded-lg border border-white/[0.08] px-4 py-2 text-[10px] font-semibold uppercase tracking-[0.1em] text-vip-text hover:bg-white/[0.05]">
                        {t(translations, 'ui_skin_retry')}
                      </button>
                    </div>
                  </div>
                ) : selectedGrant.skinSupported === false ? (
                  <div className="flex flex-1 items-center justify-center text-center">
                    <div className="max-w-sm">
                      <Palette className="mx-auto h-12 w-12 text-vip-muted/35" />
                      <h3 className="mt-4 text-lg font-semibold text-vip-text">{t(translations, 'ui_skin_not_supported')}</h3>
                    </div>
                  </div>
                ) : previewSkin ? (
                  <>
                    <div className="relative flex min-h-0 flex-1 items-center justify-center overflow-hidden rounded-2xl border border-white/[0.06] bg-[radial-gradient(circle_at_center,#151a22_0%,#080b10_52%,#040609_100%)]">
                      <div className="absolute inset-x-[10%] inset-y-[12%] z-10">
                        <WeaponSkinPreview skin={previewSkin} image={weaponImage} label={selectedGrant.label} />
                      </div>
                      <div className="absolute left-5 top-5 z-20 flex items-center gap-2 rounded-lg border border-white/[0.08] bg-black/45 px-3 py-2 backdrop-blur-sm">
                        {previewSkin.animated && <Sparkles className="h-3.5 w-3.5 text-[#21d4f4]" />}
                        <span className="text-[9px] font-bold uppercase tracking-[0.14em] text-white">{previewSkin.animated ? t(translations, 'ui_skin_animated') : t(translations, 'ui_skin_static')}</span>
                      </div>
                    </div>

                    <div className="mt-5 grid grid-cols-[1fr_auto] items-end gap-5">
                      <div>
                        <div className="flex items-center gap-2">
                          <h3 className="text-[24px] font-semibold text-vip-text">{previewSkin.label}</h3>
                          <span className={`rounded-lg border px-2 py-1 text-[8px] font-bold uppercase tracking-[0.12em] ${rarityClass[previewSkin.rarity] ?? rarityClass.common}`}>
                            {t(translations, `ui_skin_rarity_${previewSkin.rarity}`)}
                          </span>
                        </div>
                        <p className="mt-2 max-w-[620px] text-[11px] leading-relaxed text-vip-muted">{previewSkin.description}</p>
                        <p className="mt-3 text-[9px] text-[#75e8fa]">{t(translations, 'ui_skin_inspect_hint')}</p>
                      </div>
                      <button
                        type="button"
                        disabled={!previewUnlocked || previewActive || pending}
                        onClick={() => void setSkin(selectedGrant.id, previewSkin.id)}
                        className="flex min-w-[150px] items-center justify-center gap-2 rounded-xl bg-gradient-to-b from-[#ff8a00] to-[#f26900] px-5 py-3.5 text-[10px] font-bold uppercase tracking-[0.12em] text-white shadow-[0_10px_28px_rgba(255,112,0,.18)] transition hover:-translate-y-px hover:brightness-110 disabled:translate-y-0 disabled:cursor-default disabled:from-white/[0.055] disabled:to-white/[0.055] disabled:text-vip-muted disabled:shadow-none"
                      >
                        {!previewUnlocked ? <Lock className="h-4 w-4" /> : <Check className="h-4 w-4" />}
                        {!previewUnlocked ? t(translations, 'ui_skin_locked') : previewActive ? t(translations, 'ui_skin_equipped') : t(translations, 'ui_skin_apply')}
                      </button>
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
