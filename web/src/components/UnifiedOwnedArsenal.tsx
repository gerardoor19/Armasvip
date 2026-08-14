import { useEffect, useMemo, useState } from 'react';
import { Check, ChevronRight, Crown, Lock, PackageCheck, PackageOpen, Palette, ShieldCheck, Sparkles, X } from 'lucide-react';
import { motion } from 'framer-motion';
import { fetchNui } from '../lib/fivem';
import { tintColors } from '../lib/constants';
import { t } from '../lib/i18n';
import { useOwnedArsenalStore } from '../store/useOwnedArsenalStore';
import type { WeaponSkin } from '../types';

function compatible(skin: WeaponSkin, weapon: string) {
  return skin.weapons === '*' || skin.weapons.some((name) => name.toUpperCase() === weapon.toUpperCase());
}

function SkinTexture({ skin, className = '' }: { skin: WeaponSkin; className?: string }) {
  if (skin.source.type === 'procedural' && skin.source.preset) {
    return <iframe title={skin.label} src={`./skin-renderer.html?preset=${encodeURIComponent(skin.source.preset)}`} className={`pointer-events-none border-0 ${className}`} />;
  }
  const source = skin.source.type === 'asset' ? skin.source.path : skin.source.type === 'url' ? skin.source.url : null;
  return source ? <img src={source} alt="" className={`object-cover ${className}`} draggable={false} /> : <div className={`bg-white/[0.03] ${className}`} />;
}

export function UnifiedOwnedArsenal() {
  const ownerName = useOwnedArsenalStore((s) => s.ownerName);
  const grants = useOwnedArsenalStore((s) => s.grants);
  const tints = useOwnedArsenalStore((s) => s.tints);
  const skins = useOwnedArsenalStore((s) => s.skins);
  const imageBase = useOwnedArsenalStore((s) => s.imageBase);
  const selectedGrantId = useOwnedArsenalStore((s) => s.selectedGrantId);
  const selectGrant = useOwnedArsenalStore((s) => s.selectGrant);
  const equip = useOwnedArsenalStore((s) => s.equip);
  const setTint = useOwnedArsenalStore((s) => s.setTint);
  const setSkin = useOwnedArsenalStore((s) => s.setSkin);
  const loadSkinContext = useOwnedArsenalStore((s) => s.loadSkinContext);
  const skinContextLoading = useOwnedArsenalStore((s) => s.skinContextLoading);
  const pending = useOwnedArsenalStore((s) => s.pending);
  const translations = useOwnedArsenalStore((s) => s.translations);
  const close = useOwnedArsenalStore((s) => s.close);
  const [tab, setTab] = useState<'camos' | 'skins'>('camos');
  const [previewSkinId, setPreviewSkinId] = useState<string | null>(null);

  const selected = useMemo(() => grants.find((g) => g.id === selectedGrantId) ?? grants[0] ?? null, [grants, selectedGrantId]);
  const compatibleSkins = useMemo(() => {
    if (!selected || selected.skinSupported === false) return [];
    return skins.filter((skin) => compatible(skin, selected.weapon));
  }, [skins, selected]);
  const previewSkin = compatibleSkins.find((skin) => skin.id === previewSkinId) ?? compatibleSkins.find((skin) => skin.id === selected?.activeSkin) ?? null;
  const unlockedTints = new Set(selected?.unlockedTints ?? []);
  const unlockedSkins = new Set(selected?.unlockedSkins ?? []);

  useEffect(() => {
    if (skins.length === 0 && !skinContextLoading) void loadSkinContext();
  }, [skins.length, skinContextLoading, loadSkinContext]);

  useEffect(() => {
    setPreviewSkinId(selected?.activeSkin ?? null);
    if (selected) void fetchNui('armasvip:cancelSkinPreview', { grantId: selected.id });
  }, [selected?.id, selected?.activeSkin]);

  const chooseSkin = (skin: WeaponSkin) => {
    if (!selected || selected.skinSupported === false) return;
    setPreviewSkinId(skin.id);
    void fetchNui('armasvip:previewSkin', { grantId: selected.id, weapon: selected.weapon, skinId: skin.id });
  };

  const closeNui = () => {
    if (selected) void fetchNui('armasvip:cancelSkinPreview', { grantId: selected.id });
    void fetchNui('armasvip:close');
    close();
  };

  if (!selected) return null;

  return (
    <motion.section initial={{ opacity: 0, scale: .975, y: 10 }} animate={{ opacity: 1, scale: 1, y: 0 }} className="flex h-[min(760px,93vh)] w-[min(1320px,96vw)] overflow-hidden rounded-[22px] border border-white/[0.07] bg-[#0b0e13]/96 shadow-[0_22px_70px_rgba(0,0,0,.45)]">
      <aside className="flex w-[270px] shrink-0 flex-col border-r border-white/[0.06] bg-[#090c11]">
        <div className="p-5"><div className="flex items-center gap-3"><Crown className="h-5 w-5 text-[#ff8a1f]" /><div><p className="text-[10px] font-bold uppercase tracking-[.2em] text-[#ff8a1f]">{t(translations,'ui_owned_my_arsenal')}</p><p className="text-[10px] text-vip-muted">{ownerName}</p></div></div></div>
        <div className="min-h-0 flex-1 space-y-2 overflow-y-auto px-3 pb-4">
          {grants.map((grant) => <button key={grant.id} onClick={() => selectGrant(grant.id)} className={`w-full rounded-xl border p-3 text-left ${grant.id===selected.id?'border-[#ff7a00]/55 bg-[#ff7a00]/[.08]':'border-white/[.05] bg-white/[.02]'}`}><div className="flex items-center gap-3"><img src={`${imageBase}${grant.weapon}.png`} className="h-10 w-16 object-contain" alt=""/><div className="min-w-0 flex-1"><p className="truncate text-[11px] font-semibold text-vip-text">{grant.label}</p><p className="text-[9px] text-vip-muted">{grant.inInventory?t(translations,'ui_owned_in_inventory'):t(translations,'ui_owned_available')}</p></div><ChevronRight className="h-4 w-4 text-vip-muted"/></div></button>)}
        </div>
        <div className="border-t border-white/[.05] p-4 text-[9px] text-vip-muted"><ShieldCheck className="mr-2 inline h-3.5 w-3.5 text-[#21d4f4]"/>{t(translations,'ui_owned_permanent_notice')}</div>
      </aside>

      <main className="flex min-w-0 flex-1 flex-col">
        <header className="flex h-[72px] items-center justify-between border-b border-white/[.055] px-6"><div><p className="text-[9px] uppercase tracking-[.18em] text-vip-muted">{t(translations,'ui_owned_selected_weapon')}</p><h1 className="mt-1 text-[22px] text-vip-text">{selected.label}</h1></div><button onClick={closeNui} className="flex h-9 w-9 items-center justify-center rounded-lg border border-white/[.08] text-vip-muted"><X className="h-4 w-4"/></button></header>
        <div className="grid min-h-0 flex-1 grid-cols-[minmax(0,1fr)_390px]">
          <section className="flex min-h-0 flex-col p-6">
            <div className="relative flex min-h-[360px] flex-1 items-center justify-center overflow-hidden rounded-2xl border border-white/[.06] bg-[#06090d]">
              {tab==='skins' && previewSkin && previewSkin.id!=='default' && <div className="absolute inset-[10%] opacity-90" style={{ WebkitMaskImage:`url(${imageBase}${selected.weapon}.png)`, maskImage:`url(${imageBase}${selected.weapon}.png)`, WebkitMaskRepeat:'no-repeat', maskRepeat:'no-repeat', WebkitMaskPosition:'center', maskPosition:'center', WebkitMaskSize:'contain', maskSize:'contain' }}><SkinTexture skin={previewSkin} className="h-full w-full"/></div>}
              {(tab!=='skins' || !previewSkin || previewSkin.id==='default') && <img src={`${imageBase}${selected.weapon}.png`} alt={selected.label} className="relative z-10 max-h-[260px] max-w-[82%] object-contain drop-shadow-[0_20px_28px_rgba(0,0,0,.65)]"/>}
              <div className="absolute bottom-5 left-5 text-[9px] uppercase tracking-[.14em] text-vip-muted">{selected.inInventory?t(translations,'ui_owned_current_inventory'):t(translations,'ui_owned_available_withdraw')}</div>
            </div>
            <div className="mt-5 flex items-center justify-between gap-4"><div className="text-[10px] text-vip-muted">{previewSkin && tab==='skins' ? previewSkin.description : t(translations,'ui_owned_camos_help')}</div><button disabled={selected.inInventory||pending} onClick={() => void equip(selected.id)} className="flex min-w-[190px] items-center justify-center gap-2 rounded-xl bg-gradient-to-b from-[#ff8a00] to-[#f26900] px-5 py-3 text-[10px] font-bold uppercase text-white disabled:bg-white/[.06] disabled:text-vip-muted">{selected.inInventory?<PackageCheck className="h-4 w-4"/>:<PackageOpen className="h-4 w-4"/>}{selected.inInventory?t(translations,'ui_owned_in_inventory_button'):t(translations,'ui_owned_withdraw_weapon')}</button></div>
          </section>

          <aside className="flex min-h-0 flex-col border-l border-white/[.055] bg-[#0a0d12] p-5">
            <div className="grid grid-cols-2 rounded-xl border border-white/[.06] bg-black/20 p-1"><button onClick={() => { setTab('camos'); void fetchNui('armasvip:cancelSkinPreview',{grantId:selected.id}); }} className={`rounded-lg px-3 py-2 text-[10px] font-bold uppercase ${tab==='camos'?'bg-[#ff7a00]/15 text-[#ff9b3d]':'text-vip-muted'}`}><Palette className="mr-1 inline h-3.5 w-3.5"/>{t(translations,'ui_owned_camos_finishes')}</button><button onClick={() => setTab('skins')} className={`rounded-lg px-3 py-2 text-[10px] font-bold uppercase ${tab==='skins'?'bg-[#21d4f4]/10 text-[#75e8fa]':'text-vip-muted'}`}><Sparkles className="mr-1 inline h-3.5 w-3.5"/>{t(translations,'ui_skin_collection')}</button></div>

            {tab==='camos' ? <div className="mt-5 min-h-0 flex-1 overflow-y-auto"><h2 className="text-[16px] text-vip-text">{t(translations,'ui_owned_camos_finishes')}</h2><div className="mt-4 grid grid-cols-2 gap-2">{tints.map((tint) => { const unlocked=unlockedTints.has(tint.index); const active=selected.tint===tint.index; return <button key={tint.index} disabled={!unlocked||pending} onClick={() => void setTint(selected.id,tint.index)} className={`rounded-xl border p-3 text-left ${active?'border-[#ff7a00] bg-[#ff7a00]/10':'border-white/[.06] bg-white/[.02]'} ${!unlocked?'opacity-45':''}`}><div className="flex items-center justify-between"><span className="h-7 w-7 rounded-full border border-white/10" style={{backgroundColor:tintColors[tint.index]??'#777'}}/>{!unlocked?<Lock className="h-3.5 w-3.5"/>:active?<Check className="h-4 w-4 text-[#ff8a1f]"/>:null}</div><p className="mt-2 text-[10px] text-vip-text">{tint.label}</p></button>})}</div></div> : (
              <div className="mt-5 min-h-0 flex-1 overflow-y-auto">
                <div className="flex items-center justify-between"><h2 className="text-[16px] text-vip-text">{t(translations,'ui_skin_collection')}</h2><span className="text-[9px] text-vip-muted">{selected.skinSupported === false ? '0/0' : `${unlockedSkins.size}/${compatibleSkins.length}`}</span></div>
                {selected.skinSupported === false ? (
                  <p className="mt-5 text-[10px] leading-relaxed text-vip-muted">{t(translations,'ui_skin_not_supported')}</p>
                ) : skinContextLoading && skins.length===0 ? (
                  <p className="mt-5 text-[10px] text-vip-muted">{t(translations,'ui_skin_loading')}</p>
                ) : skins.length===0 ? (
                  <div className="mt-5"><p className="text-[10px] text-vip-muted">{t(translations,'ui_skin_load_failed')}</p><button onClick={() => void loadSkinContext()} className="mt-3 rounded-lg border border-white/[.08] px-3 py-2 text-[9px] uppercase text-vip-text">{t(translations,'ui_skin_retry')}</button></div>
                ) : (
                  <div className="mt-4 space-y-2">{compatibleSkins.map((skin)=>{const unlocked=unlockedSkins.has(skin.id); const active=selected.activeSkin===skin.id; const preview=previewSkinId===skin.id; return <button key={skin.id} onClick={()=>chooseSkin(skin)} className={`grid w-full grid-cols-[72px_1fr_auto] items-center gap-3 rounded-xl border p-2 text-left ${preview?'border-[#21d4f4]/55 bg-[#21d4f4]/[.06]':'border-white/[.06] bg-white/[.02]'}`}><div className="h-11 overflow-hidden rounded-lg"><SkinTexture skin={skin} className="h-full w-full"/></div><div><p className="text-[10px] font-semibold text-vip-text">{skin.label}</p><p className="text-[8px] uppercase text-vip-muted">{skin.animated?t(translations,'ui_skin_animated'):t(translations,'ui_skin_static')}</p></div>{!unlocked?<Lock className="h-3.5 w-3.5 text-vip-muted"/>:active?<Check className="h-4 w-4 text-[#21d4f4]"/>:null}</button>})}</div>
                )}
                {selected.skinSupported !== false && skins.length>0 && <button disabled={!previewSkin||!unlockedSkins.has(previewSkin.id)||selected.activeSkin===previewSkin.id||pending} onClick={()=>previewSkin&&void setSkin(selected.id,previewSkin.id)} className="mt-4 w-full rounded-xl bg-[#21d4f4]/12 px-4 py-3 text-[10px] font-bold uppercase text-[#75e8fa] disabled:opacity-35">{previewSkin&&selected.activeSkin===previewSkin.id?t(translations,'ui_skin_equipped'):t(translations,'ui_skin_apply')}</button>}
              </div>
            )}
          </aside>
        </div>
      </main>
    </motion.section>
  );
}
