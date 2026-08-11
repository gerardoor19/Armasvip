import { useCallback, useEffect } from 'react';
import { AnimatePresence, motion } from 'framer-motion';
import { fetchNui, useNuiEvent } from './lib/fivem';
import { useArmasVipStore } from './store/useArmasVipStore';
import type { ArmasVipPayload, OwnedArsenalPayload } from './types';
import { Header } from './components/Header';
import { CategorySidebar } from './components/CategorySidebar';
import { SearchBar } from './components/SearchBar';
import { WeaponGrid } from './components/WeaponGrid';
import { WeaponDetail } from './components/WeaponDetail';
import { OwnedArsenal } from './components/OwnedArsenal';
import { useOwnedArsenalStore } from './store/useOwnedArsenalStore';

export default function App() {
  const isOpen = useArmasVipStore((s) => s.isOpen);
  const open = useArmasVipStore((s) => s.open);
  const close = useArmasVipStore((s) => s.close);
  const ownedOpen = useOwnedArsenalStore((s) => s.isOpen);
  const openOwned = useOwnedArsenalStore((s) => s.open);
  const closeOwned = useOwnedArsenalStore((s) => s.close);

  useNuiEvent<ArmasVipPayload>('open', (payload) => { closeOwned(); open(payload); });
  useNuiEvent<OwnedArsenalPayload>('openOwned', (payload) => { close(); openOwned(payload); });
  useNuiEvent('close', () => { close(); closeOwned(); });

  const handleEscape = useCallback(
    (e: KeyboardEvent) => {
      if (e.key === 'Escape' && (isOpen || ownedOpen)) {
        void fetchNui('armasvip:close');
        close();
        closeOwned();
      }
    },
    [isOpen, ownedOpen, close, closeOwned],
  );

  useEffect(() => {
    window.addEventListener('keydown', handleEscape);
    return () => window.removeEventListener('keydown', handleEscape);
  }, [handleEscape]);

  return (
    <AnimatePresence>
      {ownedOpen && (
        <motion.div
          key="owned"
          initial={{ opacity: 0 }}
          animate={{ opacity: 1 }}
          exit={{ opacity: 0 }}
          className="vip-backdrop flex h-full w-full items-center justify-center"
        >
          <OwnedArsenal />
        </motion.div>
      )}
      {isOpen && (
        <motion.div
          initial={{ opacity: 0 }}
          animate={{ opacity: 1 }}
          exit={{ opacity: 0 }}
          className="vip-backdrop flex h-full w-full items-center justify-center"
        >
          <motion.div
            initial={{ opacity: 0, scale: 0.96, y: 10 }}
            animate={{ opacity: 1, scale: 1, y: 0 }}
            exit={{ opacity: 0, scale: 0.96, y: 10 }}
            transition={{ duration: 0.18, ease: 'easeOut' }}
            className="flex h-[min(640px,90vh)] w-[min(980px,94vw)] overflow-hidden rounded-2xl border border-vip-border bg-vip-panel/85 shadow-[0_18px_55px_rgba(0,0,0,0.35)]"
          >
            <div className="flex min-w-0 flex-1 flex-col">
              <Header />
              <div className="flex min-h-0 flex-1">
                <CategorySidebar />
                <div className="flex min-w-0 flex-1 flex-col gap-3 p-5">
                  <SearchBar />
                  <WeaponGrid />
                </div>
                <WeaponDetail />
              </div>
            </div>
          </motion.div>
        </motion.div>
      )}
    </AnimatePresence>
  );
}
