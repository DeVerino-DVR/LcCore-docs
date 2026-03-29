# Base de donnees

## Schema

3 tables, pas plus. Toutes les donnees complexes sont en JSON. L'inventaire est gere par la resource separee `dvr_inventory`.

### players

Table principale, contient tout le personnage.

| Colonne | Type | Default | Description |
|---|---|---|---|
| `id` | INT (PK, auto) | - | charId |
| `discord` | VARCHAR(50) | - | Discord ID du joueur |
| `group` | VARCHAR(50) | 'user' | user/admin/superadmin |
| `firstname` | VARCHAR(50) | '' | Prenom |
| `lastname` | VARCHAR(50) | '' | Nom |
| `job` | JSON | `{"name":"unemployed","grade":0,"label":"Sans emploi"}` | Job actuel |
| `gang` | VARCHAR(50) | 'none' | Gang |
| `money` | DOUBLE | 50.0 | Argent |
| `gold` | DOUBLE | 0.0 | Or |
| `skin` | JSON | `{}` | Donnees skin |
| `coords` | JSON | `{"x":...,"y":...,"z":...}` | Position |
| `slots` | INT | 50 | Slots inventaire |
| `isdead` | TINYINT(1) | 0 | Est mort |
| `xp` | INT | 0 | Experience |

Index sur `discord` pour les lookups rapides.

### bans

| Colonne | Type | Description |
|---|---|---|
| `id` | INT (PK, auto) | - |
| `discord` | VARCHAR(50) | Discord ID du banni |
| `reason` | VARCHAR(255) | Raison |
| `expire` | DATETIME | Date d'expiration (NULL = permanent) |
| `banned_by` | VARCHAR(50) | Discord ID de l'admin |
| `created_at` | TIMESTAMP | Date du ban |

### counties

| Colonne | Type | Description |
|---|---|---|
| `id` | VARCHAR(50) (PK) | ex: 'new_hanover' |
| `name` | VARCHAR(100) | Nom court |
| `label` | VARCHAR(100) | Nom affiche |
| `tax` | DOUBLE | Taux de taxe (%) |
| `mayor` | INT (FK) | charId du maire |

## Installation

Executer le fichier `sql/database.sql` dans ta base de donnees.
