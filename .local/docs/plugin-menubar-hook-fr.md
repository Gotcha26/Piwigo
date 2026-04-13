# Hook admin_menubar_plugin_links — Documentation pour les développeurs de plugins

**Piwigo 14.0+**

## Vue d'ensemble

Le hook `admin_menubar_plugin_links` permet à votre plugin d'ajouter des entrées dans le menubar latéral de l'interface d'administration Piwigo. Cela offre à vos utilisateurs un accès direct au panneau d'administration de votre plugin sans navigation complexe.

### Avant / Après

**Avant** : Les utilisateurs doivent aller sur Admin > Plugins > Liste, puis cliquer sur votre plugin.

**Après** : Un simple clic dans le menubar latéral accède directement à votre panneau.

---

## Enregistrement du hook

### Syntaxe basique

Dans le fichier `main.inc.php` de votre plugin, enregistrez le hook :

```php
<?php
// plugins/mon_plugin/main.inc.php

defined('PHPWG_ROOT_PATH') or die('Hacking attempt!');

add_event_handler('admin_menubar_plugin_links', 'mon_plugin_menubar_register');

function mon_plugin_menubar_register($items)
{
  $items[] = array(
    'NAME' => 'Mon Plugin',
    'URL'  => get_admin_plugin_menu_link(MON_PLUGIN_PATH . 'admin.php'),
    'ICON' => 'icon-cog',
  );

  return $items;
}
?>
```

### Points importants

1. **Le hook est appelé à chaque chargement de la page admin** — assurez-vous que votre callback est performant
2. **Retournez toujours le tableau `$items`** — même si vous n'ajoutez qu'une seule entrée
3. **L'ordre d'enregistrement des plugins ne garantit pas l'ordre final** — l'administrateur peut réorganiser via Admin > Plugins > Menubar

---

## Structure des éléments de menu

Chaque élément du tableau `$items` doit respecter cette structure :

### Paramètres obligatoires

| Clé | Type | Description |
|-----|------|-------------|
| `NAME` | string | Nom affiché dans le menubar. Doit être court (< 30 caractères pour une bonne lisibilité) |
| `URL` | string | URL du panneau d'administration du plugin |

### Paramètres optionnels

| Clé | Type | Description |
|-----|------|-------------|
| `ICON` | string | Classe d'icône Font Awesome (ex: `icon-cog`, `icon-th`, `icon-sliders`). Défaut : `icon-puzzle` |
| `ID` | string | Identifiant unique pour gérer l'ordre et la visibilité. Auto-généré si absent, mais recommandé pour la stabilité |
| `PLUGIN_DIR` | string | Nom du dossier du plugin (ex: `basename(MY_PLUGIN_PATH)`). **Recommandé** pour éviter les doublons avec le fallback |

### Exemple complet

```php
function mon_plugin_menubar_register($items)
{
  $items[] = array(
    'NAME' => 'Mosaic',
    'URL'  => get_admin_plugin_menu_link(MOSAIC_PATH . 'admin.php'),
    'ICON' => 'icon-th',
    'ID'   => 'mosaic_plugin',
  );

  return $items;
}
```

---

## Bonnes pratiques

### 1. Idempotence : Vérifier si déjà enregistré

Si votre plugin est appelé plusieurs fois (cas rare mais possible), vérifiez que vous n'ajoutez pas l'entrée en double :

```php
function mon_plugin_menubar_register($items)
{
  // Vérifier que notre entrée n'existe pas déjà
  foreach ($items as $item)
  {
    if (isset($item['ID']) && $item['ID'] === 'mon_plugin')
    {
      return $items;  // Déjà enregistré
    }
  }

  $items[] = array(
    'ID'   => 'mon_plugin',
    'NAME' => 'Mon Plugin',
    'URL'  => get_admin_plugin_menu_link(MON_PLUGIN_PATH . 'admin.php'),
    'ICON' => 'icon-cog',
  );

  return $items;
}
```

### 2. Utiliser `get_admin_plugin_menu_link()`

Toujours utiliser cette fonction pour générer l'URL de votre panneau admin :

```php
'URL' => get_admin_plugin_menu_link(MON_PLUGIN_PATH . 'admin.php'),
```

Cela garantit la compatibilité avec les chemins de fichiers compliqués et les URL réécrites.

### 3. Inclure PLUGIN_DIR pour éviter les doublons

Incluez toujours le champ `PLUGIN_DIR` avec le nom de votre dossier plugin. Cela prévient les doublons si le fallback est activé :

```php
$items[] = array(
  'ID'         => 'mon_plugin',
  'NAME'       => 'Mon Plugin',
  'URL'        => get_admin_plugin_menu_link(MON_PLUGIN_PATH . 'admin.php'),
  'ICON'       => 'icon-cog',
  'PLUGIN_DIR' => basename(MON_PLUGIN_PATH), // IMPORTANT
);
```

`basename(MON_PLUGIN_PATH)` retourne le nom du dossier (ex: `mon_plugin_folder`).

### 4. Respecter les conventions de nommage pour les IDs

Utilisez un format préfixé pour éviter les collisions :

```php
'ID' => 'mon_plugin',          // Bon
'ID' => 'mosaic_images_layout', // Bon (descriptif)
'ID' => 'foo_bar_baz_123',      // Valide mais un peu long
```

Les IDs doivent être alphanumériques + underscore : `[a-zA-Z0-9_]`

### 5. Choisir une icône appropriée

Quelques suggestions d'icônes populaires :

```php
'ICON' => 'icon-cog',             // Paramètres / configuration
'ICON' => 'icon-th',              // Galerie / mosaïque
'ICON' => 'icon-sliders',         // Réglages / filtres
'ICON' => 'icon-palette',         // Couleurs / thème
'ICON' => 'icon-file-image',      // Images
'ICON' => 'icon-users',           // Utilisateurs
'ICON' => 'icon-lock',            // Sécurité / permissions
'ICON' => 'icon-puzzle',          // Défaut (si aucune icône appropriée)
```

Consultez la liste complète des icônes Font Awesome compatibles.

### Accéder à la liste complète des icônes Fontello

Piwigo embarque une **police d'icônes Fontello customisée**. Pour explorer toutes les icônes disponibles :

#### Option 1 : Consulter le fichier demo.html (local)

1. Navigez vers : `admin/themes/default/fontello/demo.html`
2. Ouvrez le fichier dans votre navigateur web
3. Vous verrez la galerie complète des icônes avec leurs noms (ex: `icon-cog`, `icon-th`, etc.)

#### Option 2 : Inspecter le fichier CSS

Les définitions des icônes se trouvent dans :

```
admin/themes/default/fontello/css/fontello.css
```

Vous y trouverez des lignes comme :

```css
.icon-cog:before { content: '\f013'; } /* '' */
.icon-th:before { content: '\f009'; } /* '' */
.icon-lock:before { content: '\f023'; } /* '' */
```

Chaque classe correspond à un caractère Unicode spécifique rendu par la police Fontello.

#### Option 3 : Utiliser les devtools du navigateur (F12)

1. Ouvrez une page d'administration Piwigo
2. Appuyez sur **F12** pour ouvrir les devtools
3. Utilisez l'inspecteur pour cibler un élément avec une icône (ex: `<i class="icon-cog">`)
4. Dans l'onglet **Styles**, vous verrez la classe d'icône et le caractère rendu
5. Consultez le fichier CSS source pour voir toutes les icônes disponibles

#### Exemple : Ajouter une icône personnalisée

Si vous voulez une icône spécifique (ex: icônes utilisateur, cadenas, images, etc.) :

1. **Consultez `demo.html`** pour lister toutes les icônes disponibles
2. **Copiez le nom exact** (ex: `icon-users`, `icon-lock`, `icon-file-image`)
3. **Utilisez-le dans votre hook** :

```php
$items[] = array(
  'NAME' => 'User Management',
  'URL'  => get_admin_plugin_menu_link(MY_PLUGIN_PATH . 'admin.php'),
  'ICON' => 'icon-users',  // Icône utilisateurs
  'ID'   => 'my_plugin_users',
);
```

### 6. Éviter les opérations coûteuses

Le hook est déclenché à chaque chargement de page admin. Évitez :

```php
// ❌ MAUVAIS : requête SQL à chaque chargement
function mon_plugin_menubar_register($items)
{
  $count = pwg_query("SELECT COUNT(*) FROM ..."); // LENT
  $items[] = array('NAME' => "Mon Plugin ($count)", ...);
  return $items;
}

// ✅ BON : informations statiques uniquement
function mon_plugin_menubar_register($items)
{
  $items[] = array('NAME' => 'Mon Plugin', ...);
  return $items;
}
```

---

## Gestion des préférences (Admin > Plugins > Menubar)

Les administrateurs Piwigo peuvent gérer vos entrées via **Admin > Plugins > Menubar** :

- **Réordonner** : Glisser-déposer pour changer l'ordre
- **Masquer** : Décocher pour masquer une entrée sans la supprimer
- **Ajouter des séparateurs** : Grouper les entrées visuellement

Votre plugin n'a rien à faire — ces préférences sont gérées automatiquement.

---

## Exemple réel : Plugin Mosaic

```php
<?php
// plugins/mosaic/main.inc.php

defined('PHPWG_ROOT_PATH') or die('Hacking attempt!');

// ... code du plugin ...

add_event_handler('admin_menubar_plugin_links', 'mosaic_menubar_register');

/**
 * Enregistre l'entrée Mosaic dans le menubar admin
 */
function mosaic_menubar_register($items)
{
  $items[] = array(
    'ID'   => 'mosaic_plugin',
    'NAME' => 'Mosaic',
    'URL'  => get_admin_plugin_menu_link(MOSAIC_PATH . 'admin.php'),
    'ICON' => 'icon-th',
  );

  return $items;
}
?>
```

---

## Dépannage

### Mon entrée n'apparaît pas

1. **Vérifiez que votre plugin est activé** — le hook ne se déclenche que pour les plugins actifs
2. **Vérifiez la syntaxe** — le callback doit retourner le tableau `$items`
3. **Vérifiez que votre panneau d'admin existe** — `admin.php` doit exister dans le dossier du plugin
4. **Vérifiez les permissions** — seul un administrateur peut voir le menubar

### Mon icône n'apparaît pas correctement

- Assurez-vous que la classe d'icône est correcte (ex: `icon-cog`, pas `cog`)
- Les icônes proviennent de Font Awesome (compatible Piwigo)
- En cas de doute, omettez `ICON` pour utiliser le défaut

### L'ordre de mes entrées change

C'est normal ! L'administrateur peut réorganiser les entrées via le panneau de gestion. Pour un ordre initial, utilisez des IDs cohérents.

---

## Cas d'usage typiques

### Plugin de galerie (layout)

```php
add_event_handler('admin_menubar_plugin_links', 'my_gallery_menubar');

function my_gallery_menubar($items)
{
  $items[] = array(
    'NAME' => 'My Gallery Layout',
    'URL'  => get_admin_plugin_menu_link(MY_GALLERY_PATH . 'admin.php'),
    'ICON' => 'icon-th-large',
    'ID'   => 'my_gallery_layout',
  );
  return $items;
}
```

### Plugin de sécurité

```php
add_event_handler('admin_menubar_plugin_links', 'security_plugin_menubar');

function security_plugin_menubar($items)
{
  $items[] = array(
    'NAME' => 'Security',
    'URL'  => get_admin_plugin_menu_link(SECURITY_PLUGIN_PATH . 'admin.php'),
    'ICON' => 'icon-lock',
    'ID'   => 'security_admin',
  );
  return $items;
}
```

### Plugin avec plusieurs sections (ajouter plusieurs entrées)

```php
add_event_handler('admin_menubar_plugin_links', 'my_plugin_menubar');

function my_plugin_menubar($items)
{
  $base_url = get_admin_plugin_menu_link(MY_PLUGIN_PATH);

  // Vérifier que les entrées n'existent pas déjà
  $ids = array();
  foreach ($items as $item) {
    if (isset($item['ID'])) {
      $ids[] = $item['ID'];
    }
  }

  // Ajouter les entrées principales
  if (!in_array('my_plugin_settings', $ids)) {
    $items[] = array(
      'ID'   => 'my_plugin_settings',
      'NAME' => 'Settings',
      'URL'  => $base_url . 'admin_settings.php',
      'ICON' => 'icon-cog',
    );
  }

  if (!in_array('my_plugin_logs', $ids)) {
    $items[] = array(
      'ID'   => 'my_plugin_logs',
      'NAME' => 'Logs',
      'URL'  => $base_url . 'admin_logs.php',
      'ICON' => 'icon-list',
    );
  }

  return $items;
}
```

---

## Ressources

- **Hooks Piwigo** : https://piwigo.org/en/doc/doku.php?id=dev:plugins:events
- **Font Awesome Icons** : https://fontawesome.io/icons/
- **Piwigo Plugin Development** : https://piwigo.org/en/doc/doku.php?id=dev:plugins

---

## Historique des modifications

| Version | Date | Changement |
|---------|------|-----------|
| 2.0 | 2026-04-01 | Support `PLUGIN_DIR` pour éviter doublons ; scroll pagine menubar ; style optimisé |
| 1.0 | 2026-03-04 | Documentation initiale |

---

## Support

Si vous avez des questions sur ce hook, consultez :

1. Le code source : `admin/include/add_core_tabs.inc.php` (enregistrement du tab)
2. Le fichier de traitement : `admin/plugins_menubar.php` (gestion des préférences)
3. Les forums/issues Piwigo

---

**Auteur** : Gotcha
**Licence** : Même licence que Piwigo (GPLv2)
