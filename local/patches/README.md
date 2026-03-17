# Piwigo Patches

Patches d'évolutions pour Piwigo en attente d'intégration au core ou refusées par la communauté.

## 2534 - Admin Menubar Hook for Plugins

**Branche** : `2534---Hook-for-Adding-Plugin-Submenu-to-Admin-Menubar`

**Description** : Ajoute un hook natif `admin_menubar_plugin_links` permettant aux plugins d'ajouter leurs propres entrées dans la barre de menu admin, avec gestion drag & drop et persistance.

**Fichiers modifiés** : 8 fichiers core + 4 fichiers créés
- admin.php
- admin/include/functions.php
- admin/include/add_core_tabs.inc.php
- admin/themes/default/template/admin.tpl
- admin/themes/default/theme.css
- include/config_default.inc.php
- language/en_UK/admin.lang.php
- language/fr_FR/admin.lang.php
- admin/plugins_menubar.php (NEW)
- admin/themes/default/template/plugins_menubar.tpl (NEW)
- local/docs/plugin-menubar-hook-en.md (NEW)
- local/docs/plugin-menubar-hook-fr.md (NEW)

### Application du patch

#### Cas général (local ou serveur git)

```bash
cd /chemin/vers/piwigo
git apply < local/patches/2534-admin-menubar-hook.patch
```

#### Cas o2switch (méthode recommandée)

**Pré-requis** :
- Avoir accès SSH établi vers o2switch (ex: `ssh gotcha@o2switch`)
- `patch` installé sur le serveur (généralement présent par défaut)

Supposons votre Piwigo installée à `/home/gotcha/galerie.julien-moreau.fr` :

**Étape 1 : Téléverser le patch**

```bash
# Depuis votre machine locale
scp local/patches/2534-admin-menubar-hook.patch gotcha@o2switch:/home/gotcha/
```

**Étape 2 : Sauvegarder les fichiers avant modification**

```bash
ssh gotcha@o2switch
cd /home/gotcha/galerie.julien-moreau.fr

# Créer un backup des fichiers qui vont être modifiés
mkdir -p .backups/2534-admin-menubar-hook
cp admin.php .backups/2534-admin-menubar-hook/
cp admin/include/functions.php .backups/2534-admin-menubar-hook/
cp admin/include/add_core_tabs.inc.php .backups/2534-admin-menubar-hook/
cp admin/themes/default/template/admin.tpl .backups/2534-admin-menubar-hook/
cp admin/themes/default/theme.css .backups/2534-admin-menubar-hook/
cp include/config_default.inc.php .backups/2534-admin-menubar-hook/
cp language/en_UK/admin.lang.php .backups/2534-admin-menubar-hook/
cp language/fr_FR/admin.lang.php .backups/2534-admin-menubar-hook/
```

**Étape 3 : Appliquer le patch**

```bash
cd /home/gotcha/galerie.julien-moreau.fr
patch -p1 < /home/gotcha/2534-admin-menubar-hook.patch
```

**Étape 4 : Vérifier l'application**

```bash
# Vérifier les 4 nouveaux fichiers créés
ls -la admin/plugins_menubar.php
ls -la admin/themes/default/template/plugins_menubar.tpl
ls -la local/docs/plugin-menubar-hook-*.md

# Vérifier qu'aucun fichier n'a échoué (.rej)
find . -name "*.rej" 2>/dev/null
```

**Étape 5 : Tester dans Piwigo**

```bash
# Accédez à https://galerie.julien-moreau.fr/admin.php
# → Admin > Plugins
# → Vérifier la présence du nouvel onglet "Menubar"
```

### Vérification

Après application, vérifiez que :
1. Un nouvel onglet **"Menubar"** apparaît dans la page **Admin > Plugins**
2. Les entrées de plugin s'y affichent avec drag & drop
3. Aucun changement visuel si aucun plugin n'utilise le hook

### Utilisation dans un plugin

```php
add_event_handler('admin_menubar_plugin_links', 'my_plugin_menubar');

function my_plugin_menubar($items) {
  $items[] = array(
    'ID'   => 'my_plugin',
    'NAME' => 'My Plugin',
    'URL'  => get_admin_plugin_menu_link(MY_PLUGIN_PATH . 'admin.php'),
    'ICON' => 'icon-cog',
  );
  return $items;
}
```

### Distribution du patch

Pour partager avec d'autres utilisateurs/hébergeurs :

```bash
# Depuis votre repo local
scp local/patches/2534-admin-menubar-hook.patch user@host:/chemin/piwigo/
ssh user@host "cd /chemin/piwigo && git apply < 2534-admin-menubar-hook.patch"

# Ou pour GitHub, ajouter au repo et partager via une release
git add local/patches/2534-admin-menubar-hook.patch
git commit -m "Add patch: admin menubar hook (#2534)"
git push
```

### Rollback (revenir en arrière)

Si le patch cause des problèmes :

```bash
cd /home/gotcha/galerie.julien-moreau.fr

# Option 1 : Restaurer depuis le backup créé
cp .backups/2534-admin-menubar-hook/* .
# (attention : adapter les chemins)

# Option 2 : Utiliser patch en reverse
patch -p1 -R < /home/gotcha/2534-admin-menubar-hook.patch

# Option 3 : Supprimer les fichiers NEW créés
rm -f admin/plugins_menubar.php
rm -f admin/themes/default/template/plugins_menubar.tpl
rm -f local/docs/plugin-menubar-hook-en.md
rm -f local/docs/plugin-menubar-hook-fr.md

# Puis restaurer les fichiers modifiés depuis le backup
cp .backups/2534-admin-menubar-hook/* .
```

### Après une mise à jour du core Piwigo

Si vous faites `git pull` ou mettez à jour Piwigo manuellement sur o2switch :

**Cas 1 : Mise à jour mineure (bugfix)**
- Le patch devrait rester compatible
- Testez simplement dans Admin > Plugins > Menubar

**Cas 2 : Mise à jour majeure**
- Le patch pourrait générer des conflits (fichiers `.rej`)
- Solution :
  1. Sauvegarder votre config Piwigo (`local/config/`)
  2. Téléverser la nouvelle version de Piwigo
  3. Réappliquer le patch
  4. Restaurer votre config

```bash
# Sauvegarder avant la MAJ
cp -r local/config .backups/config-avant-maj

# Après la MAJ, réappliquer le patch
patch -p1 < /home/gotcha/2534-admin-menubar-hook.patch

# Vérifier qu'aucun conflit n'a eu lieu
find . -name "*.rej" 2>/dev/null
```

**Cas 3 : Le patch ne s'applique plus**
- Vérifiez les lignes de contexte dans `.rej`
- Appliquez les changements manuellement (voir liste des fichiers ci-dessus)
- Contactez l'auteur du patch pour une mise à jour

### Branche source

Le patch est généré depuis la branche :
```
2534---Hook-for-Adding-Plugin-Submenu-to-Admin-Menubar
```

Il est appliqué **sur `master`** (version actuelle stable de Piwigo).

### Notes

- ✅ Entièrement rétro-compatible (pas de `<dd>` si aucun plugin ne s'inscrit)
- ✅ Suit les patterns existants de Piwigo (menubar.php, config_default.inc.php)
- ✅ Traductions EN + FR incluses
- ℹ️ Patch appliquable à tout moment sur master, indépendamment du statut PR
- ⚠️ Si votre installation o2switch a des modifications locales, le patch peut générer des conflits (`.rej`)
- 🔄 Testée sur master actuel — compatible pour mises à jour futures si Piwigo core ne change pas trop

---

**Source patch** : https://github.com/Gotcha26/Piwigo (fork personnel)
**Fichier patch** : `local/patches/2534-admin-menubar-hook.patch`
**Generated**: 2026-03-17
