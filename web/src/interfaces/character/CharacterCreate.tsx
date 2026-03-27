import { useMemo } from 'react'
import { fetchNui } from '../../hooks/useNui'
import Menu from '../menu/Menu'
import type { MenuItem } from '../menu/Menu'

const NATIONALITIES = ['Américain', 'Mexicain', 'Irlandais', 'Anglais', 'Français', 'Allemand', 'Italien', 'Chinois', 'Autochtone']
const BLOOD_TYPES = ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-']
const HEIGHTS = ['1m60', '1m65', '1m70', '1m75', '1m80', '1m85', '1m90', '1m95', '2m00']

export default function CharacterCreate() {
  const randomBlood = useMemo(() => BLOOD_TYPES[Math.floor(Math.random() * BLOOD_TYPES.length)], [])

  const items: MenuItem[] = [
    { label: 'Prénom', type: 'text' },
    { label: 'Nom', type: 'text' },
    { label: 'Date de naissance', type: 'text' },
    { label: 'Nationalité', values: NATIONALITIES, defaultIndex: 1 },
    { label: 'Groupe sanguin', rightLabel: randomBlood, disabled: true },
    { label: 'Taille', values: HEIGHTS, defaultIndex: 5 },
    { type: 'separator', label: '' },
    { label: 'Confirmer', description: 'Valider la création du personnage' },
  ]

  const handleSelect = (index: number, scrollIndex: number) => {
    if (index !== items.length - 1) return

    // Recup les valeurs des champs text via les inputs DOM
    const inputs = document.querySelectorAll<HTMLInputElement>('input[type="text"]')
    const firstname = inputs[0]?.value?.trim() || ''
    const lastname = inputs[1]?.value?.trim() || ''
    const dateOfBirth = inputs[2]?.value?.trim() || ''

    if (!firstname || !lastname) return

    fetchNui('createChar', {
      firstname,
      lastname,
      dateOfBirth,
      nationality: NATIONALITIES[scrollIndex] || NATIONALITIES[0],
      bloodType: randomBlood,
      height: HEIGHTS[scrollIndex] || HEIGHTS[4],
    })
  }

  return (
    <Menu
      title="Création"
      subtitle="Nouveau personnage"
      items={items}
      canClose={false}
      onSelect={handleSelect}
    />
  )
}
