import { useEffect } from 'react';

declare global {
  interface Window {
    GetParentResourceName?: () => string;
  }
}

export const isEnvBrowser = (): boolean => !window.GetParentResourceName;

const resourceName = (): string => window.GetParentResourceName?.() ?? 'armasvip';

export async function fetchNui<TResponse = unknown>(
  eventName: string,
  data: unknown = {},
): Promise<TResponse> {
  if (isEnvBrowser()) {
    return data as TResponse;
  }

  const resp = await fetch(`https://${resourceName()}/${eventName}`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json; charset=UTF-8' },
    body: JSON.stringify(data),
  });

  return (await resp.json()) as TResponse;
}

export function useNuiEvent<TData = unknown>(
  action: string,
  handler: (data: TData) => void,
): void {
  useEffect(() => {
    const listener = (event: MessageEvent<{ action: string; data: TData }>) => {
      const { action: eventAction, data } = event.data;
      if (eventAction === action) handler(data);
    };

    window.addEventListener('message', listener);
    return () => window.removeEventListener('message', listener);
  }, [action, handler]);
}
