import { useEffect, useRef } from 'react'

export function useNuiEvent<T = unknown>(action: string, handler: (data: T) => void) {
  const savedHandler = useRef(handler)
  savedHandler.current = handler

  useEffect(() => {
    const listener = (event: MessageEvent) => {
      if (event.data.action === action) {
        savedHandler.current(event.data as T)
      }
    }
    window.addEventListener('message', listener)
    return () => window.removeEventListener('message', listener)
  }, [action])
}

export async function fetchNui<T = unknown>(event: string, data?: unknown): Promise<T> {
  const resp = await fetch(`https://LcCore/${event}`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(data ?? {}),
  })
  return resp.json()
}
