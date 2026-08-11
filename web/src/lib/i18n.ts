export type UiTranslations = Record<string, string>;

export function t(translations: UiTranslations, key: string, fallback?: string): string {
  return translations[key] ?? fallback ?? key;
}

export function tf(translations: UiTranslations, key: string, ...values: Array<string | number>): string {
  let value = t(translations, key);
  for (const replacement of values) value = value.replace('%s', String(replacement));
  return value;
}
