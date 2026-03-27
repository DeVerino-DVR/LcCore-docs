import { fetchNui } from '../../hooks/useNui'
import Menu from '../menu/Menu'
import type { MenuItem } from '../menu/Menu'

interface Character {
  charId: number
  firstname: string
  lastname: string
  job: { name: string; grade: number; label: string }
  money: number
  gold: number
}

interface Props {
  characters: Character[]
  maxCharacters: number
  onGoToCreate: () => void
}

export default function CharacterSelect({ characters, maxCharacters, onGoToCreate }: Props) {
  const items: MenuItem[] = [
    ...characters.map((char) => ({
      label: `${char.firstname} ${char.lastname}`,
      rightLabel: char.job.label,
      description: `$${char.money.toFixed(2)} | Or: ${char.gold.toFixed(2)}`,
    })),
    ...(characters.length < maxCharacters
      ? [{ label: 'Nouveau personnage', description: 'Créer un nouveau personnage' }]
      : []),
  ]

  const handleSelect = (index: number) => {
    if (index < characters.length) {
      fetchNui('selectChar', { charId: characters[index].charId })
    } else {
      onGoToCreate()
    }
  }

  return (
    <Menu
      title="Personnages"
      subtitle="Sélection"
      items={items}
      canClose={false}
      onSelect={handleSelect}
    />
  )
}
