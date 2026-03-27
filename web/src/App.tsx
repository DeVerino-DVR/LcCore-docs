import { useState } from 'react'
import { useNuiEvent } from './hooks/useNui'
import CharacterSelect from './interfaces/character/CharacterSelect'
import CharacterCreate from './interfaces/character/CharacterCreate'
import Menu from './interfaces/menu/Menu'
import type { MenuProps } from './interfaces/menu/Menu'
import DevTools from './DevTools'
import './styles/global.css'

const isDev = import.meta.env.DEV

/*
  Routing par interface NUI.
  Chaque SendNUIMessage({ action: '...', ... }) affiche l'interface correspondante.

  Pour ajouter une nouvelle interface :
  1. Creer le composant dans src/interfaces/
  2. Ajouter le type dans ActiveInterface
  3. Ajouter le useNuiEvent + le case dans le switch
*/

type ActiveInterface =
  | null
  | { type: 'characterSelect'; data: CharacterSelectData }
  | { type: 'characterCreate' }
  | { type: 'menu'; data: MenuProps }

interface CharacterSelectData {
  characters: {
    charId: number
    firstname: string
    lastname: string
    job: { name: string; grade: number; label: string }
    money: number
    gold: number
  }[]
  maxCharacters: number
}

export default function App() {
  const [active, setActive] = useState<ActiveInterface>(null)

  // Character
  useNuiEvent<CharacterSelectData>('showSelection', (data) => {
    setActive({ type: 'characterSelect', data })
  })

  useNuiEvent('showCreation', () => {
    setActive({ type: 'characterCreate' })
  })

  // Menu generique (appele depuis Lua: LcCore.Menu.Open)
  useNuiEvent<MenuProps>('openMenu', (data) => {
    setActive({ type: 'menu', data })
  })

  // Hide
  useNuiEvent('hideSelection', () => setActive(null))
  useNuiEvent('closeMenu', () => setActive(null))
  useNuiEvent('hide', () => setActive(null))

  const goToCreate = () => {
    setActive({ type: 'characterCreate' })
  }

  const content = (() => {
    if (!active) return null
    switch (active.type) {
      case 'characterSelect':
        return <CharacterSelect {...active.data} onGoToCreate={goToCreate} />
      case 'characterCreate':
        return <CharacterCreate />
      case 'menu':
        return <Menu {...active.data} onClose={() => setActive(null)} />
      default:
        return null
    }
  })()

  return (
    <>
      {content}
      {isDev && <DevTools />}
    </>
  )
}
