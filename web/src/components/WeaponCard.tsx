import { useState } from 'react';
import { motion } from 'framer-motion';
import { Check, Crosshair } from 'lucide-react';
import type { Weapon } from '../types';

interface WeaponCardProps {
  weapon: Weapon;
  imageBase: string;
  categoryLabel: string;
  isSelected: boolean;
  onSelect: () => void;
}

export function WeaponCard({ weapon, imageBase, categoryLabel, isSelected, onSelect }: WeaponCardProps) {
  const [imgError, setImgError] = useState(false);

  return (
    <motion.button
      layout
      onClick={onSelect}
      whileHover={{ y: -2 }}
      whileTap={{ scale: 0.97 }}
      transition={{ duration: 0.15 }}
      className={`relative flex flex-col overflow-hidden rounded-xl border text-left transition-colors duration-150 ${
        isSelected
          ? 'border-vip-accent/55 bg-vip-accent/10 shadow-[0_10px_28px_-12px_rgba(255,122,0,0.4)]'
          : 'border-vip-border bg-vip-panel-2 hover:border-vip-accent/30 hover:bg-[#20242e]'
      }`}
    >
      {isSelected && (
        <span className="absolute right-2 top-2 z-10 flex h-5 w-5 items-center justify-center rounded-full bg-vip-accent-soft">
          <Check className="h-3 w-3 text-vip-bg" strokeWidth={3} />
        </span>
      )}
      <div className="relative flex aspect-square items-center justify-center bg-vip-bg/40">
        <div className="pointer-events-none absolute top-0 right-0 bottom-0 left-0 bg-[radial-gradient(circle_at_center,rgba(255,122,0,0.07),transparent_65%)]" />
        {imgError ? (
          <Crosshair className="relative h-10 w-10 text-vip-muted" />
        ) : (
          <img
            src={`${imageBase}${weapon.name}.png`}
            alt={weapon.label}
            className="relative h-full w-full object-contain p-4 drop-shadow-[0_4px_10px_rgba(0,0,0,0.5)]"
            onError={() => setImgError(true)}
            draggable={false}
          />
        )}
      </div>
      <div className="flex flex-col gap-0.5 p-3 text-center">
        <span className="line-clamp-2 text-xs font-medium leading-tight text-vip-text">
          {weapon.label}
        </span>
        <span className="text-[10px] uppercase tracking-wide text-vip-cyan/80">{categoryLabel}</span>
      </div>
    </motion.button>
  );
}
