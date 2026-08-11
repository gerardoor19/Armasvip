import { X, Crown } from 'lucide-react';
import { fetchNui } from '../lib/fivem';
import { t } from '../lib/i18n';
import { useArmasVipStore } from '../store/useArmasVipStore';

export function Header() {
  const close = useArmasVipStore((s) => s.close);
  const translations = useArmasVipStore((s) => s.translations);

  const handleClose = () => {
    void fetchNui('armasvip:close');
    close();
  };

  return (
    <div className="flex items-center justify-between border-b border-vip-border px-6 py-4">
      <div className="flex items-center gap-3">
        <div className="flex h-11 w-11 items-center justify-center rounded-xl bg-gradient-to-br from-vip-accent to-vip-accent-soft shadow-[0_0_14px_rgba(255,122,0,0.3)]">
          <Crown className="h-5 w-5 text-vip-bg" strokeWidth={2.5} />
        </div>
        <div>
          <span className="block text-[10px] font-bold uppercase tracking-[0.18em] text-vip-accent-soft">
            {t(translations, 'ui_exclusive_arsenal')}
          </span>
          <h1 className="text-[26px] leading-none tracking-[-0.04em] text-vip-text">
            {t(translations, 'ui_weapons')} <span className="text-vip-accent-soft">VIP</span>
          </h1>
        </div>
      </div>

      <button
        onClick={handleClose}
        className="flex h-9 w-9 items-center justify-center rounded-lg border border-vip-border bg-vip-panel-2 text-vip-muted transition-colors hover:border-red-500/50 hover:text-red-400"
        aria-label={t(translations, 'ui_close')}
      >
        <X className="h-4 w-4" />
      </button>
    </div>
  );
}
