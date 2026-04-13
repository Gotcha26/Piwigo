# Demande de fonctionnalité Piwigo : Paramètre de sharpening pour les dérivés

**Auteur** : Gotcha (Piwigo Mosaic plugin)
**Date** : 2026-03-03
**Dépôt** : https://github.com/Piwigo/Piwigo
**Type** : Feature Request

---

## Résumé

Demander l'ajout d'un **paramètre configurable de sharpening (unsharp mask)** dans Piwigo lors de la génération des dérivés d'images. Cela améliorerait significativement la perception de qualité et de netteté des vignettes et images réduites sans dégradation majeure des performances.

---

## Contexte technique

### État actuel

Piwigo utilise actuellement une pipeline de traitement d'images basée sur GD ou ImageMagick :

1. **Chargement** de l'image source
2. **Rotation** (si nécessaire, via EXIF)
3. **Crop** (selon le mode de dérivé)
4. **Redimensionnement** (resampling via Lanczos/bicubic)
5. **Sharpening** (❌ **NON implémenté**)
6. **Watermark** (optionnel)
7. **Compression JPEG** et sauvegarde

### Problème observé

Après redimensionnement (étape 4), les images ressortent **molles** sans acuité visuelle, même avec :
- ImageMagick haute qualité (6.9.13+)
- Qualité JPEG élevée (90-98%)
- Algorithme Lanczos activé

**Cause technique** : Le resampling seul ne suffit pas. L'unsharp mask (sharpening) est le complément standard de tout pipeline de traitement professionnel pour retrouver l'acuité perdue lors de la réduction.

### Preuve de concept

Test de redimensionnement manuel avec **XnView** :
- Image source originale : 3840×2088
- Dérivé ciblé : 512×512 (Medium Piwigo)
- Resampling : Lanczos (identique à ImageMagick)
- **Résultat sans sharpening** : Mou, manque de piqué
- **Résultat avec unsharp mask (0.5×1+1.5+0.05)** : Bien défini, naturel, sans artefacts

**Conclusion** : L'ajout de sharpening fait une **différence perceptive majeure** et mesurable.

---

## Solution proposée

### 1. Ajouter un paramètre `image_sharpening`

Dans `Admin > Images`, ajouter un **sélecteur ou curseur** pour le sharpening :

```
Sharpening des dérivés
├─ Désactivé (défaut, compatibilité)
├─ Léger (unsharp 0.3)
├─ Modéré (unsharp 0.5) ← Recommandé
└─ Fort (unsharp 0.8)
```

Ou mode avancé avec 3 paramètres :
- **Radius** (0.5 à 2.0) — étendue du filtre
- **Amount** (0.5 à 2.0) — force du sharpening
- **Threshold** (0 à 0.1) — seuil anti-bruit

### 2. Où doivent apparaître ces régalages

Sur la page `/admin.php?page=configuration&section=sizes` lorsque l'on clique sur le bouton "Montrer les détails" doit apparaître les 4 paramètres.
De la même manière que le plugin Mosaic affiche des paramètres comme par exemple :
```php
{* Nombre de photos par page *}
<div class="ma-field">
  <div class="ma-field-label-col">
    <span class="ma-field-label">
      <span class="ma-tooltip-wrap">
        <button type="button" class="ma-tooltip-btn">i</button>
        <span class="ma-tooltip-text">{'mosaic_tp_nb_image_page'|@translate}</span>
      </span>
      {'Number of photos per page'|@translate}
    </span>
    <span class="ma-field-desc">{'mosaic_desc_nb_image_page'|@translate}</span>
  </div>
  <div class="ma-field-controls">
    <div class="ma-slider-wrap">
      <input type="range" class="ma-slider" id="nb_image_page_range"
              min="10" max="200" step="10" value="{$NB_IMAGE_PAGE}"
              oninput="syncSlider('nb_image_page_range','nb_image_page_val')">
      <input type="number" class="ma-input-num" id="nb_image_page_val"
              name="nb_image_page" min="10" max="200" step="10" value="{$NB_IMAGE_PAGE}"
              oninput="syncNum('nb_image_page_range','nb_image_page_val')">
      <span class="ma-unit">{'mosaic_unit_photos'|@translate}</span>
    </div>
  </div>
    <span class="ma-perf-badge ma-perf-med" title="{'mosaic_perf_med_page'|@translate}">{'mosaic_perf_label'|@translate}</span>
</div>
```

### 3. Implémentation dans `i.php`

Ajouter après l'étape de redimensionnement (ligne ~556 de i.php) :

```php
// Sharpening (après resize, avant watermark)
if ($params->sharpen && $changes)
{
  $changes += $image->sharpen($params->sharpen);
  $timing['sharpen'] = time_step($step);
}
```

Réutiliser la méthode `pwg_image::sharpen()` existante (déjà utilisée pour les dérivés personnalisés).

### 4. Configuration par dérivé (optionnel, futur)

Permettre des valeurs différentes par type de dérivé :
```php
$conf['derivative_sharpen'] = array(
  'thumbnail' => 0.3,  // Légèrement
  'small'     => 0.5,  // Modérément
  'medium'    => 0.6,  // Plus
  'large'     => 0.8,  // Fort
);
```

---

## Avantages

| Aspect | Détail |
|--------|--------|
| **Perceptif** | Amélioration **très visible** de la netteté, surtout pour galeries/portfolios |
| **Gratuit** | Aucune dépendance supplémentaire (ImageMagick le supporte nativement) |
| **Perf** | Impact CPU minimal (~+5-10% par dérivé, négligeable avec cache) |
| **Compatibilité** | Fonctionne avec GD ET ImageMagick (via convolution matrix) |
| **Reversible** | Param optionnel, désactivé par défaut → pas de breaking change |
| **Utilisateurs heureux** | Résout une frustration commune : "Mes images de galerie manquent de piqué" |

---

## Restrictions & limitations

### Librairies graphiques

| Librairie | Support | Détail |
|-----------|---------|--------|
| **ImageMagick CLI** (ext_imagick) | ✅ Natif | Via `-sharpen` ou `-unsharp` |
| **Imagick PHP** (imagick) | ✅ Natif | Via `Imagick::sharpenImage()` |
| **GD** | ⚠️ Limité | Via `imageconvolution()` (convolution matrix) |

### GD : limitations

GD n'a pas de fonction unsharp mask native, faut utiliser `imageconvolution()` avec une matrice :
```php
// Matrice de sharpening simple
$kernel = array(
  array(0, -1, 0),
  array(-1, 5, -1),
  array(0, -1, 0)
);
imageconvolution($image, $kernel, 1, 0);
```

**Problème** : Moins flexible et moins précis qu'ImageMagick. Avec GD, le sharpening peut créer des **halos** ou **artefacts** si mal dosé.

**Recommandation** :
- ImageMagick/Imagick → plein support
- GD → désactiver le sharpening ou utiliser une version très légère

### Risques d'artefacts

Un sharpening mal configuré crée des **halos** et des **artefacts** visibles autour des bords. D'où l'importance du **threshold** (seuil anti-bruit) pour éviter d'amplifier le bruit JPEG.

**Exemple d'unsharp mask sûr** : `-unsharp 0.5x1+1.5+0.05`
- Radius : 0.5 (petit, local)
- Sigma : 1
- Amount : 1.5 (modéré)
- Threshold : 0.05 (anti-bruit)

---

## Impact de performance

### Cache et i.php

Le sharpening s'applique **une seule fois** lors de la génération du dérivé (dans i.php). Le fichier est ensuite **mis en cache** et réutilisé. Donc :

- 1ère requête pour une image → sharpening appliqué (~+50-100ms avec ImageMagick)
- Requêtes suivantes → lecture du cache (pas de surcharge)

**Impact réel** : Négligeable pour les installations avec cache fonctionnel.

### Cas limite : Régénération massive

Si on force la régénération de tous les dérivés (après changement du paramètre), le coût serveur augmente mais reste acceptable :
- Galerie de 10 000 images × 4 dérivés = 40 000 fichiers
- À ~80ms par sharpening → ~55 minutes en mono-thread
- Avec parallelization → ~10-15 minutes

Viable avec une tâche CRON ou un admin job.

---

## Avant/Après

### Sans sharpening (état actuel)

```
Image redimensionnée 512×512 (Medium)
├─ Compression JPEG 95%
├─ Resampling Lanczos
└─ Résultat : Mou, manque de définition
```

### Avec sharpening (proposé)

```
Image redimensionnée 512×512 (Medium)
├─ Compression JPEG 95%
├─ Resampling Lanczos
├─ Unsharp mask (0.5×1+1.5+0.05)
└─ Résultat : Bien défini, acuité restaurée, naturel
```

---

## Implémentation estimée

| Phase | Effort | Détail |
|-------|--------|--------|
| **Conception UI** | 2h | Ajouter le param dans Admin > Images |
| **Code i.php** | 1h | Intégrer l'appel au sharpening |
| **Gestion GD** | 2h | Implémenter fallback convolution matrix |
| **Tests** | 3h | Cas GD, ImageMagick, GD+sharpening, perf |
| **Docs** | 1h | Documenter le paramètre, recommandations |
| **Total** | ~9h | Réaliste pour une PR |

---

## Cas d'usage prioritaire

1. **Galeries photo/portfolio** — sharpen par défaut désactivé, activable pour meilleur rendu
2. **Plugins layout (comme Mosaic)** — bénéficient automatiquement de meilleures vignettes
3. **Hébergements partagés** — option "Performance vs Qualité" visible dans l'admin

---

## Suggestions d'implémentation

### Option 1 : Simple (recommandée pour MVP)

- Un seul paramètre : `image_sharpening` (0 = off, 1 = moderate)
- Valeurs pré-configurées, pas de contrôle fin
- Support ImageMagick prioritaire, GD optionnel

### Option 2 : Avancée (future)

- 3 curseurs : radius, amount, threshold
- Aperçu temps réel dans l'admin
- Configuration par type de dérivé
- Pré-sets sauvegardables

---

## Points de discussion

- **Compatibilité ascendante** : Désactiver par défaut, opt-in uniquement
- **Valeur par défaut** : Quel preset recommander (léger/modéré) ?
- **GD** : Supporter ou désactiver pour GD ?
- **Régénération** : Interface pour régénérer les dérivés existants avec nouveau sharpening ?

---

## Références externes

- **ImageMagick unsharp mask** : https://imagemagick.org/script/command-line-options.php#sharpen
- **Gimp unsharp mask** : https://docs.gimp.org/2.10/en/gimp-filters-enhance-sharpen.html
- **Adobe Lightroom sharpening** : Utilise unsharp mask en post-processing systématique

---

## Conclusion

L'ajout d'un paramètre de sharpening est une **demande légitime** pour améliorer la qualité perceptive des images sans impact majeur sur les performances ou la compatibilité. C'est un complément naturel et attendu d'une pipeline de traitement d'images modernes.

Piwigo manque actuellement d'une étape standard présente dans tous les outils pro (Lightroom, Photoshop, même Gimp l'intègrent).

**Vote recommandé** : ⭐ Priorité Moyenne (amélioration UX non-critique mais très demandée)
