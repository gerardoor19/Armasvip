import { useMemo, useState } from 'react';
import {
  Check,
  ChevronRight,
  Crosshair,
  Crown,
  Lock,
  PackageCheck,
  PackageOpen,
  ShieldCheck,
  Sparkles,
  X,
} from 'lucide-react';
import { motion } from 'framer-motion';
import { fetchNui } from '../lib/fivem';
import { tintColors } from '../lib/constants';
import { t } from '../lib/i18n';
import { useOwnedArsenalStore } from '../store/useOwnedArsenalStore';

export function OwnedArsenal() {
  const ownerName = useOwnedArsenalStore((s) => s.ownerName);
  const grants = useOwnedArsenalStore((s) => s.grants);
  const components = useOwnedArsenalStore((s) => s.components);
  const tints = useOwnedArsenalStore((s) => s.tints);
  const imageBase = useOwnedArsenalStore((s) => s.imageBase);
  const selectedGrantId = useOwnedArsenalStore((s) => s.selectedGrantId);
  const selectGrant = useOwnedArsenalStore((s) => s.selectGrant);
  const equip = useOwnedArsenalStore((s) => s.equip);
  const setTint = useOwnedArsenalStore((s) => s.setTint);
  const pending = useOwnedArsenalStore((s) => s.pending);
  const lastMessage = useOwnedArsenalStore((s) => s.lastMessage);
  const close = useOwnedArsenalStore((s) => s.close);
  const translations = useOwnedArsenalStore((s) => s.translations);
  const [imgError, setImgError] = useState(false);

  const selected = useMemo(
    () => grants.find((grant) => grant.id === selectedGrantId) ?? grants[0] ?? null,
    [grants, selectedGrantId],
  );

  const unlocked = useMemo(() => new Set(selected?.unlockedTints ?? []), [selected]);
  const installed = selected?.installedComponents ?? [];

  const closeNui = () => {
    void fetchNui('armasvip:close');
    close();
  };

  if (!selected) return null;

  return (
    <motion.section
      initial={{ opacity: 0, scale: 0.975, y: 12 }}
      animate={{ opacity: 1, scale: 1, y: 0 }}
      exit={{ opacity: 0, scale: 0.975, y: 12 }}
      transition={{ duration: 0.16, ease: 'easeOut' }}
      className="relative flex h-[min(720px,92vh)] w-[min(1180px,95vw)] overflow-hidden rounded-[22px] border border-white/[0.07] bg-[#0b0e13]/94 shadow-[0_22px_70px_rgba(0,0,0,.42)]"
    >
      <div className="pointer-events-none absolute inset-x-0 top-0 h-px bg-gradient-to-r from-transparent via-[#ff7a00]/65 to-transparent" />

      <aside className="flex w-[270px] shrink-0 flex-col border-r border-white/[0.06] bg-[#090c11]/78">
        <div className="px-5 pb-4 pt-5">
          <div className="flex items-center gap-2.5">
            <div className="flex h-9 w-9 items-center justify-center rounded-xl border border-[#ff7a00]/25 bg-[#ff7a00]/10">
              <Crown className="h-[18px] w-[18px] text-[#ff8a1f]" />
            </div>
            <div>
              <p className="text-[10px] font-bold uppercase tracking-[0.24em] text-[#ff8a1f]">{t(translations, 'ui_owned_my_arsenal')}</p>
              <p className="text-[11px] text-vip-muted">{t(translations, 'ui_owned_personal_collection')}</p>
            </div>
          </div>

          <div className="mt-5 flex items-center justify-between rounded-xl border border-white/[0.05] bg-white/[0.025] px-3 py-2.5">
            <div className="min-w-0">
              <p className="truncate text-[11px] font-semibold text-vip-text">{ownerName || t(translations, 'ui_owned_owner_default')}</p>
              <p className="mt-0.5 text-[9px] uppercase tracking-[0.14em] text-vip-muted">{grants.length} {grants.length === 1 ? t(translations, 'ui_owned_weapon_singular') : t(translations, 'ui_owned_weapon_plural')}</p>
            </div>
            <ShieldCheck className="h-4 w-4 shrink-0 text-[#21d4f4]" />
          </div>
        </div>

        <div className="px-5 pb-2">
          <p className="text-[9px] font-bold uppercase tracking-[0.18em] text-vip-muted">{t(translations, 'ui_owned_your_weapons')}</p>
        </div>

        <div className="min-h-0 flex-1 space-y-2 overflow-y-auto px-3 pb-4">
          {grants.map((grant) => {
            const active = grant.id === selected.id;
            return (
              <button
                key={grant.id}
                onClick={() => {
                  selectGrant(grant.id);
                  setImgError(false);
                }}
                className={`group relative w-full overflow-hidden rounded-xl border px-3 py-3 text-left transition-all duration-150 ${
                  active
                    ? 'border-[#ff7a00]/55 bg-[#ff7a00]/[0.075]'
                    : 'border-white/[0.045] bg-white/[0.018] hover:border-white/[0.11] hover:bg-white/[0.035]'
                }`}
              >
                {active && <span className="absolute bottom-2 left-0 top-2 w-0.5 rounded-r bg-[#ff7a00]" />}
                <div className="flex items-center gap-3">
                  <div className="relative flex h-12 w-[68px] shrink-0 items-center justify-center rounded-lg border border-white/[0.04] bg-black/20">
                    <div className="pointer-events-none absolute inset-0 bg-[radial-gradient(circle_at_center,rgba(255,122,0,.08),transparent_70%)]" />
                    <img src={`${imageBase}${grant.weapon}.png`} alt="" className="relative max-h-9 max-w-[58px] object-contain" draggable={false} />
                  </div>
                  <div className="min-w-0 flex-1">
                    <p className="truncate text-[12px] font-semibold text-vip-text">{grant.label}</p>
                    <div className="mt-1.5 flex items-center gap-1.5">
                      <span className={`h-1.5 w-1.5 rounded-full ${grant.inInventory ? 'bg-emerald-400' : 'bg-[#21d4f4]'}`} />
                      <span className={`text-[9px] font-medium ${grant.inInventory ? 'text-emerald-400' : 'text-[#75e8fa]'}`}>
                        {grant.inInventory ? t(translations, 'ui_owned_in_inventory') : t(translations, 'ui_owned_available')}
                      </span>
                    </div>
                  </div>
                  <ChevronRight className={`h-4 w-4 shrink-0 transition-all ${active ? 'translate-x-0 text-[#ff8a1f]' : '-translate-x-1 text-vip-muted/40 group-hover:translate-x-0 group-hover:text-vip-muted'}`} />
                </div>
              </button>
            );
          })}
        </div>

        <div className="border-t border-white/[0.05] px-5 py-4">
          <div className="flex items-start gap-2 text-[9px] leading-relaxed text-vip-muted">
            <ShieldCheck className="mt-0.5 h-3.5 w-3.5 shrink-0 text-[#21d4f4]" />
            <span>{t(translations, 'ui_owned_permanent_notice')}</span>
          </div>
        </div>
      </aside>

      <main className="flex min-w-0 flex-1 flex-col">
        <header className="flex h-[72px] shrink-0 items-center justify-between border-b border-white/[0.055] px-6">
          <div className="min-w-0">
            <div className="flex items-center gap-2">
              <p className="text-[9px] font-semibold uppercase tracking-[0.2em] text-vip-muted">{t(translations, 'ui_owned_selected_weapon')}</p>
              <span className="h-1 w-1 rounded-full bg-[#ff7a00]" />
              <p className="text-[9px] font-semibold uppercase tracking-[0.16em] text-[#ff9a3c]">VIP Edition</p>
            </div>
            <h1 className="mt-1 truncate text-[22px] leading-none text-vip-text">{selected.label}</h1>
          </div>

          <button onClick={closeNui} aria-label={t(translations, 'ui_owned_close')} className="flex h-9 w-9 items-center justify-center rounded-lg border border-white/[0.07] bg-white/[0.025] text-vip-muted transition-all duration-150 hover:border-white/[0.14] hover:bg-white/[0.05] hover:text-vip-text">
            <X className="h-4 w-4" />
          </button>
        </header>

        <div className="grid min-h-0 flex-1 grid-cols-[minmax(0,1fr)_330px]">
          <section className="flex min-h-0 flex-col px-7 pb-6 pt-5">
            <div className="relative flex min-h-[290px] flex-1 items-center justify-center overflow-hidden rounded-2xl border border-white/[0.055] bg-[#080b0f]/62">
              <div className="pointer-events-none absolute inset-0 bg-[radial-gradient(ellipse_at_50%_48%,rgba(255,122,0,.13),transparent_48%),radial-gradient(circle_at_78%_18%,rgba(33,212,244,.05),transparent_28%)]" />
              <div className="pointer-events-none absolute inset-x-[18%] bottom-[16%] h-px bg-gradient-to-r from-transparent via-white/[0.09] to-transparent" />

              <div className="absolute left-5 top-5 flex items-center gap-2">
                <span className="inline-flex items-center gap-1.5 text-[9px] font-bold uppercase tracking-[0.16em] text-[#ff9b3d]"><Crown className="h-3.5 w-3.5" /> VIP Edition</span>
              </div>

              <div className="absolute right-5 top-5 flex items-center gap-2 text-[9px] font-medium text-vip-muted">
                <span className={`h-1.5 w-1.5 rounded-full ${selected.inInventory ? 'bg-emerald-400' : 'bg-[#21d4f4]'}`} />
                {selected.inInventory ? t(translations, 'ui_owned_current_inventory') : t(translations, 'ui_owned_available_withdraw')}
              </div>

              {imgError ? <Crosshair className="relative h-20 w-20 text-vip-muted/35" /> : (
                <motion.img key={selected.id} initial={{ opacity: 0, x: 12, scale: 0.97 }} animate={{ opacity: 1, x: 0, scale: 1 }} transition={{ duration: 0.18 }} src={`${imageBase}${selected.weapon}.png`} alt={selected.label} onError={() => setImgError(true)} className="relative z-10 max-h-[230px] max-w-[82%] object-contain drop-shadow-[0_18px_25px_rgba(0,0,0,.55)]" draggable={false} />
              )}

              <div className="absolute bottom-5 left-5 right-5 flex items-end justify-between gap-4">
                <div>
                  <p className="text-[9px] font-medium uppercase tracking-[0.16em] text-vip-muted">{t(translations, 'ui_owned_property')}</p>
                  <div className="mt-1 flex items-center gap-2"><ShieldCheck className="h-4 w-4 text-[#21d4f4]" /><span className="text-[11px] font-semibold text-vip-text">{t(translations, 'ui_owned_permanent_nontransferable')}</span></div>
                </div>
                <div className="text-right">
                  <p className="text-[9px] font-medium uppercase tracking-[0.16em] text-vip-muted">{t(translations, 'ui_owned_durability')}</p>
                  <div className="mt-1 flex items-center justify-end gap-2"><span className="h-1.5 w-16 overflow-hidden rounded-full bg-white/[0.07]"><span className="block h-full w-full rounded-full bg-emerald-400" /></span><span className="text-[10px] font-semibold text-emerald-400">{t(translations, 'ui_owned_no_wear')}</span></div>
                </div>
              </div>
            </div>

            <div className="mt-5 grid grid-cols-[1fr_auto] items-end gap-4">
              <div className="min-w-0">
                <div className="flex items-center gap-2"><h3 className="text-[11px] text-vip-text">{t(translations, 'ui_owned_installed_components')}</h3><span className="rounded-md bg-white/[0.045] px-1.5 py-0.5 text-[9px] text-vip-muted">{installed.length}</span></div>
                {installed.length > 0 ? (
                  <div className="mt-2.5 flex max-h-[74px] flex-wrap gap-2 overflow-y-auto pr-1">
                    {installed.map((name) => <span key={name} className="inline-flex items-center gap-1.5 rounded-lg border border-white/[0.055] bg-white/[0.025] px-2.5 py-1.5 text-[10px] text-vip-text"><Check className="h-3 w-3 text-emerald-400" />{components[name]?.label ?? name}</span>)}
                  </div>
                ) : (
                  <p className="mt-2 text-[10px] leading-relaxed text-vip-muted">{selected.inInventory ? t(translations, 'ui_owned_no_components_current') : selected.initialDelivered ? t(translations, 'ui_owned_components_not_restored') : t(translations, 'ui_owned_components_first_delivery')}</p>
                )}
              </div>

              <button disabled={selected.inInventory || pending} onClick={() => void equip(selected.id)} className="group flex min-w-[190px] items-center justify-center gap-2 rounded-xl bg-gradient-to-b from-[#ff8a00] to-[#f26900] px-5 py-3.5 text-[10px] font-bold uppercase tracking-[0.12em] text-white shadow-[0_10px_28px_rgba(255,112,0,.18)] transition-all duration-150 hover:-translate-y-px hover:brightness-110 disabled:translate-y-0 disabled:cursor-default disabled:from-white/[0.055] disabled:to-white/[0.055] disabled:text-vip-muted disabled:shadow-none">
                {selected.inInventory ? <PackageCheck className="h-4 w-4" /> : <PackageOpen className="h-4 w-4" />}
                {selected.inInventory ? t(translations, 'ui_owned_in_inventory_button') : pending ? t(translations, 'ui_owned_withdrawing') : t(translations, 'ui_owned_withdraw_weapon')}
              </button>
            </div>
          </section>

          <aside className="flex min-h-0 flex-col border-l border-white/[0.055] bg-[#0a0d12]/72 px-5 pb-5 pt-5">
            <div className="flex items-center justify-between">
              <div><p className="text-[9px] font-bold uppercase tracking-[0.2em] text-[#21d4f4]">{t(translations, 'ui_owned_customization')}</p><h2 className="mt-1 text-[17px] leading-none text-vip-text">{t(translations, 'ui_owned_camos_finishes')}</h2></div>
              <Sparkles className="h-[18px] w-[18px] text-[#21d4f4]" />
            </div>

            <p className="mt-3 text-[10px] leading-relaxed text-vip-muted">{t(translations, 'ui_owned_camos_help')}</p>

            <div className="mt-4 flex min-h-0 flex-1 flex-col">
              <div className="flex items-center justify-between border-b border-white/[0.05] pb-2.5"><span className="text-[9px] font-semibold uppercase tracking-[0.16em] text-vip-muted">{t(translations, 'ui_owned_collection')}</span><span className="text-[9px] text-vip-muted">{unlocked.size}/{tints.length} {t(translations, 'ui_owned_unlocked')}</span></div>
              <div className="mt-3 grid min-h-0 grid-cols-2 gap-2 overflow-y-auto pr-1">
                {tints.map((tint) => {
                  const isUnlocked = unlocked.has(tint.index);
                  const active = selected.tint === tint.index;
                  const color = tintColors[tint.index] ?? '#6b7280';
                  return (
                    <button key={tint.index} disabled={!isUnlocked || pending} onClick={() => void setTint(selected.id, tint.index)} className={`relative min-h-[82px] overflow-hidden rounded-xl border p-3 text-left transition-all duration-150 ${active ? 'border-[#ff7a00]/65 bg-[#ff7a00]/[0.075] shadow-[inset_0_0_0_1px_rgba(255,122,0,.08)]' : isUnlocked ? 'border-white/[0.055] bg-white/[0.022] hover:border-white/[0.13] hover:bg-white/[0.04]' : 'border-white/[0.04] bg-black/15 opacity-45'}`}>
                      <div className="flex items-start justify-between">
                        <span className="relative h-7 w-7 rounded-full border-2 border-white/15 shadow-[0_4px_12px_rgba(0,0,0,.35)]" style={{ backgroundColor: color }}><span className="absolute inset-[3px] rounded-full border border-black/10" /></span>
                        {!isUnlocked ? <Lock className="h-3.5 w-3.5 text-vip-muted" /> : active ? <span className="flex h-5 w-5 items-center justify-center rounded-full bg-[#ff7a00] text-white"><Check className="h-3 w-3" /></span> : null}
                      </div>
                      <p className="mt-3 truncate text-[10px] font-semibold text-vip-text">{tint.label}</p>
                      <p className={`mt-0.5 text-[8px] uppercase tracking-[0.11em] ${active ? 'text-[#ff9b3d]' : isUnlocked ? 'text-[#75e8fa]' : 'text-vip-muted'}`}>{active ? t(translations, 'ui_owned_equipped') : isUnlocked ? t(translations, 'ui_owned_available') : t(translations, 'ui_owned_locked')}</p>
                    </button>
                  );
                })}
              </div>
            </div>

            <div className="mt-4 border-t border-white/[0.05] pt-4">
              <div className="flex items-center justify-between text-[9px]"><span className="text-vip-muted">{t(translations, 'ui_owned_active_finish')}</span><span className="font-semibold text-[#ff9b3d]">{tints.find((tint) => tint.index === selected.tint)?.label ?? t(translations, 'ui_owned_default')}</span></div>
              {lastMessage && (
                <motion.div initial={{ opacity: 0, y: 4 }} animate={{ opacity: 1, y: 0 }} className={`mt-3 flex items-center gap-2 rounded-lg border px-3 py-2.5 text-[10px] ${lastMessage.ok ? 'border-emerald-500/15 bg-emerald-500/[0.07] text-emerald-400' : 'border-red-500/15 bg-red-500/[0.07] text-red-400'}`}>
                  {lastMessage.ok ? <Check className="h-3.5 w-3.5 shrink-0" /> : <X className="h-3.5 w-3.5 shrink-0" />}<span>{lastMessage.text}</span>
                </motion.div>
              )}
            </div>
          </aside>
        </div>
      </main>
    </motion.section>
  );
}
