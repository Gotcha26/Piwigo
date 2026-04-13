# Demande de fonctionnalité Piwigo : Hook pour ajouter un sous-menu aux Plugins dans le menubar admin

**Auteur** : Gotcha (Piwigo Mosaic plugin)
**Date** : 2026-03-03
**Dépôt** : https://github.com/Piwigo/Piwigo
**Type** : Feature Request

---

## Résumé

Ajouter un **hook `admin_menubar_plugin_links`** permettant à un plugin d'injecter des entrées dans un sous-menu dépliable sous la section "Plugins" du menubar latéral de l'interface admin Piwigo. Cela offrirait aux plugins une meilleure intégration UI sans manipulation DOM et rendrait le menubar **extensible et maintenable**.

---

## Problème actuel

### État du menubar admin

Le menubar latéral admin (`admin/themes/default/template/admin.tpl`) est constitué de sections dépliables (`<dl>`) statiques, hardcodées dans le template. Chaque section suit le pattern :

```html
<dl>
  <dt>
    <i class="icon-xxx"></i>
    <span>Titre</span>
    <i class="icon-down-open open-menu"></i>
  </dt>
  <dd>
    <ul>
      <li><a href="...">Lien</a></li>
    </ul>
  </dd>
</dl>
```

**Problème** : La section "Plugins" est actuellement **simplifiée** — elle n'a **pas de `<dd>`** et fonctionne comme un simple lien :

```html
<dl>
  <dt>
    <a href="{$U_PLUGINS}" class="admin-main">
      <i class="icon-puzzle"></i>
      <span>Plugins</span>
    </a>
  </dt>
</dl>
```

### Situation avec les plugins

Il n'existe **aucun mécanisme natif** permettant à un plugin d'ajouter des entrées au menubar latéral admin. Les hooks disponibles sont **insuffisants** :

| Hook | Utilité actuelle |
|------|-----------------|
| `get_admin_plugin_menu_links` | Ajoute des liens sur la *page liste des plugins*, pas dans le menubar |
| `loc_begin_admin` | Exécuté avant le rendu admin, pas d'accès au template menubar |
| `loc_begin_admin_page` | Permet injecter du HTML/JS, mais nécessite manipulation DOM (fragile) |
| `loc_end_admin` | Exécuté après le rendu, trop tard pour certaines opérations |

**Conséquence** : Les plugins comme **Mosaic** ne peuvent pas afficher leur menu dans le menubar sans :
1. **Manipulation DOM en JavaScript** (fragile, non pérenne)
2. **Modification du thème admin** (compliqué, peu évolutif)
3. **Plugin tiers pour l'injection** (complexité accrue)

---

## Solution proposée

### 1. Nouveau hook : `admin_menubar_plugin_links`

Ajouter un hook dans `admin.php` (après l'assignation de `$U_PLUGINS`) :

```php
// Appel du hook pour récupérer les items de sous-menu
$plugins_menu_items = trigger_change('admin_menubar_plugin_links', array());
$template->assign('PLUGINS_MENU_ITEMS', $plugins_menu_items);
```

### 2. Modification du template `admin.tpl`

Remplacer la section Plugins statique par une section dynamique :

```smarty
<dl id="menubar-plugins">
  <dt>
    {if $PLUGINS_MENU_ITEMS}
      <i class="icon-puzzle"></i>
      <span>{'Plugins'|@translate}&nbsp;</span>
      <i class="icon-down-open open-menu"></i>
    {else}
      <a href="{$U_PLUGINS}" class="admin-main">
        <i class="icon-puzzle"></i>
        <span>{'Plugins'|@translate}&nbsp;</span>
      </a>
    {/if}
  </dt>
  {if $PLUGINS_MENU_ITEMS}
  <dd>
    <ul>
      <li><a href="{$U_PLUGINS}"><i class="icon-list"></i>{'Manage'|@translate}</a></li>
      {foreach from=$PLUGINS_MENU_ITEMS item=item}
      <li><a href="{$item.URL}"><i class="{$item.ICON|default:'icon-puzzle'}"></i>{$item.NAME}</a></li>
      {/foreach}
    </ul>
  </dd>
  {/if}
</dl>
```

### 3. Usage par un plugin (exemple : Mosaic)

Un plugin peut simplement enregistrer son hook :

```php
add_event_handler('admin_menubar_plugin_links', 'Mosaic_menubar_link');

function Mosaic_menubar_link($items)
{
  $items[] = array(
    'NAME' => 'Mosaic',
    'URL'  => get_admin_plugin_menu_link(MOSAIC_PATH . 'admin.php'),
    'ICON' => 'icon-th',
  );
  return $items;
}
```

---

## Avantages de cette approche

| Aspect | Détail |
|--------|--------|
| **Propreté** | Aucune manipulation DOM — rendu serveur, pas de JavaScript fragile |
| **Rétrocompatibilité** | Sans plugin, la section reste un simple lien (comportement inchangé) |
| **Extensibilité** | Chaque plugin ajoute sa ligne indépendamment, sans collision |
| **Maintenabilité** | Modification centralisée dans `admin.php` et `admin.tpl` |
| **Thèmes** | Compatible avec tous les thèmes admin (pas limité à `default`) |
| **Flexibilité** | Support futur du flag `$ACTIVE_MENU` pour highlighter la section |

---

## Pas de breaking change

- **Par défaut** : Sans plugin, `$PLUGINS_MENU_ITEMS` est vide → comportement identique à aujourd'hui
- **Avec plugin** : Le hook ajoute les entrées et active le sous-menu → expérience utilisateur améliorée
- **Thèmes personnalisés** : Les thèmes qui n'implémentent pas le template modifié conservent leur comportement actuel

---

## Implémentation estimée

| Élément | Effort |
|---------|--------|
| Ajout du hook dans `admin.php` | ~5 min |
| Modification du template `admin.tpl` | ~10 min |
| Gestion `$ACTIVE_MENU` (optionnel) | ~15 min |
| **Total** | ~30 min (très chirurgical) |

---

## Cas d'usage prioritaire

1. **Mosaic** — Afficher un lien vers l'admin du plugin directement dans le menubar
2. **Plugins layout** — Intégrer leurs panels dans le menubar pour meilleur UX
3. **Plugins d'administration** — centralAdmin, etc., peuvent exposer leurs menus facilement

---

## Suggestions de priorité

- **Priorité** : Moyenne (amélioration UX, pas critique mais très désirée)
- **Complexité** : Très basse (~30 minutes de dev)
- **Risque** : Nul (modification chirurgicale, rétrocompatible)

---

## Points de discussion (optionnels)

- Faut-il un second hook `admin_menubar_before_plugins` pour ajouter des sections **avant** Plugins ?
- Faut-il supporter un flag `active` sur chaque item pour highlighter automatiquement ?
- Faut-il exposer un helper `get_plugin_menu_item()` pour normaliser la structure ?

---

## Conclusion

L'ajout du hook `admin_menubar_plugin_links` est une **demande légitime** pour améliorer l'intégration des plugins dans l'interface admin. C'est une modification **mineure et pérenne** qui résout un problème de design UI sans impacter les performances ou la compatibilité.

**Vote recommandé** : ⭐ Accepter (30 min d'implémentation, gain UX immédiat pour plugins et utilisateurs)
