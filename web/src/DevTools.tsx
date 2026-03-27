const mockCharacters = [
  {
    charId: 1,
    firstname: 'Jean',
    lastname: 'Dupont',
    job: { name: 'sheriff', grade: 2, label: 'Shérif' },
    money: 1250.50,
    gold: 15.0,
  },
  {
    charId: 2,
    firstname: 'Marie',
    lastname: 'Lafleur',
    job: { name: 'doctor', grade: 1, label: 'Médecin' },
    money: 800.0,
    gold: 5.0,
  },
]

const mockMenu = {
  title: 'Général',
  subtitle: 'Options',
  items: [
    { label: 'Option simple' },
    { label: 'Avec valeurs', values: ['Choix A', 'Choix B', 'Choix C'], defaultIndex: 1 },
    { label: 'Checkbox', checked: false },
    { type: 'separator' as const, label: 'Catégorie' },
    { label: 'Avec description', description: 'Ceci est une description qui apparaît en bas du menu.' },
    { label: 'Désactivé', disabled: true },
    { label: 'Right label', rightLabel: '$150.00' },
    { label: 'Saisie texte', type: 'text' as const },
  ],
}

function send(action: string, data: Record<string, unknown> = {}) {
  window.postMessage({ action, ...data }, '*')
}

export default function DevTools() {
  return (
    <div style={{
      position: 'fixed',
      bottom: 10,
      right: 10,
      zIndex: 9999,
      display: 'flex',
      gap: 6,
      padding: 8,
      background: 'rgba(0,0,0,0.85)',
      borderRadius: 6,
      flexWrap: 'wrap',
      maxWidth: 400,
    }}>
      <button onClick={() => send('showSelection', { characters: mockCharacters, maxCharacters: 3 })}
        style={btnStyle}>Sélection</button>
      <button onClick={() => send('showCreation')}
        style={btnStyle}>Création</button>
      <button onClick={() => send('openMenu', mockMenu)}
        style={btnStyle}>Menu test</button>
      <button onClick={() => send('hide')}
        style={btnStyle}>Fermer</button>
    </div>
  )
}

const btnStyle: React.CSSProperties = {
  padding: '6px 12px',
  background: '#333',
  color: '#fff',
  border: '1px solid #555',
  borderRadius: 4,
  cursor: 'pointer',
  fontFamily: 'sans-serif',
  fontSize: 12,
}
