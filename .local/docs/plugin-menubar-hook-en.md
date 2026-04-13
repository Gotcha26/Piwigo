# Hook admin_menubar_plugin_links — Plugin Developer Guide

**Piwigo 14.0+**

## Overview

The `admin_menubar_plugin_links` hook allows your plugin to add entries to the Piwigo admin interface's sidebar menubar. This provides your users with direct access to your plugin's admin panel without complex navigation.

### Before / After

**Before** : Users navigate to Admin > Plugins > List, then click on your plugin.

**After** : A single click in the sidebar menubar accesses your admin panel directly.

---

## Registering the Hook

### Basic Syntax

In your plugin's `main.inc.php` file, register the hook:

```php
<?php
// plugins/my_plugin/main.inc.php

defined('PHPWG_ROOT_PATH') or die('Hacking attempt!');

add_event_handler('admin_menubar_plugin_links', 'my_plugin_menubar_register');

function my_plugin_menubar_register($items)
{
  $items[] = array(
    'NAME' => 'My Plugin',
    'URL'  => get_admin_plugin_menu_link(MY_PLUGIN_PATH . 'admin.php'),
    'ICON' => 'icon-cog',
  );

  return $items;
}
?>
```

### Important Notes

1. **The hook is called on every admin page load** — ensure your callback is performant
2. **Always return the `$items` array** — even if you only add entries
3. **Plugin order is not guaranteed** — administrators can reorganize via Admin > Plugins > Menubar

---

## Menu Item Structure

Each element in the `$items` array must follow this structure:

### Required Parameters

| Key | Type | Description |
|-----|------|-------------|
| `NAME` | string | Display name in the menubar. Keep it short (< 30 characters for readability) |
| `URL` | string | URL to your plugin's admin panel |

### Optional Parameters

| Key | Type | Description |
|-----|------|-------------|
| `ICON` | string | Font Awesome icon class (e.g., `icon-cog`, `icon-th`, `icon-sliders`). Default: `icon-puzzle` |
| `ID` | string | Unique identifier for order and visibility management. Auto-generated if omitted, but recommended for stability |
| `PLUGIN_DIR` | string | Plugin folder name (e.g., `basename(MY_PLUGIN_PATH)`). **Recommended** to prevent duplicates with fallback |

### Complete Example

```php
function my_plugin_menubar_register($items)
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

## Best Practices

### 1. Idempotence: Check if Already Registered

If your plugin is called multiple times (rare but possible), verify you don't add duplicate entries:

```php
function my_plugin_menubar_register($items)
{
  // Check if our entry already exists
  foreach ($items as $item)
  {
    if (isset($item['ID']) && $item['ID'] === 'my_plugin')
    {
      return $items;  // Already registered
    }
  }

  $items[] = array(
    'ID'   => 'my_plugin',
    'NAME' => 'My Plugin',
    'URL'  => get_admin_plugin_menu_link(MY_PLUGIN_PATH . 'admin.php'),
    'ICON' => 'icon-cog',
  );

  return $items;
}
```

### 2. Use `get_admin_plugin_menu_link()`

Always use this function to generate your admin panel URL:

```php
'URL' => get_admin_plugin_menu_link(MY_PLUGIN_PATH . 'admin.php'),
```

This ensures compatibility with complex file paths and URL rewrites.

### 3. Include PLUGIN_DIR to Prevent Duplicates

Always include the `PLUGIN_DIR` field with your plugin folder name. This prevents duplicates if fallback is enabled:

```php
$items[] = array(
  'ID'         => 'my_plugin',
  'NAME'       => 'My Plugin',
  'URL'        => get_admin_plugin_menu_link(MY_PLUGIN_PATH . 'admin.php'),
  'ICON'       => 'icon-cog',
  'PLUGIN_DIR' => basename(MY_PLUGIN_PATH), // IMPORTANT
);
```

`basename(MY_PLUGIN_PATH)` returns your folder name (e.g., `my_plugin_folder`).

### 4. Follow ID Naming Conventions

Use a prefixed format to avoid collisions:

```php
'ID' => 'my_plugin',               // Good
'ID' => 'mosaic_images_layout',    // Good (descriptive)
'ID' => 'foo_bar_baz_123',         // Valid but verbose
```

IDs must be alphanumeric + underscore: `[a-zA-Z0-9_]`

### 5. Choose an Appropriate Icon

Some popular icon suggestions:

```php
'ICON' => 'icon-cog',              // Settings / configuration
'ICON' => 'icon-th',               // Gallery / mosaic
'ICON' => 'icon-sliders',          // Adjustments / filters
'ICON' => 'icon-palette',          // Colors / theme
'ICON' => 'icon-file-image',       // Images
'ICON' => 'icon-users',            // Users
'ICON' => 'icon-lock',             // Security / permissions
'ICON' => 'icon-puzzle',           // Default (if no icon fits)
```

Check the full Font Awesome icon list for Piwigo compatibility.

### Accessing the Complete Fontello Icon List

Piwigo includes a **customized Fontello icon font**. To explore all available icons:

#### Option 1: Consult the demo.html File (Local)

1. Navigate to: `admin/themes/default/fontello/demo.html`
2. Open the file in your web browser
3. You'll see the complete icon gallery with their names (e.g., `icon-cog`, `icon-th`, etc.)

#### Option 2: Inspect the CSS File

Icon definitions are located in:

```
admin/themes/default/fontello/css/fontello.css
```

You'll find lines like:

```css
.icon-cog:before { content: '\f013'; } /* '' */
.icon-th:before { content: '\f009'; } /* '' */
.icon-lock:before { content: '\f023'; } /* '' */
```

Each class corresponds to a Unicode character rendered by the Fontello font.

#### Option 3: Use Browser DevTools (F12)

1. Open any Piwigo admin page
2. Press **F12** to open devtools
3. Use the inspector to target an element with an icon (e.g., `<i class="icon-cog">`)
4. In the **Styles** tab, you'll see the icon class and rendered character
5. Consult the CSS source file to see all available icons

#### Example: Adding a Custom Icon

If you want a specific icon (e.g., users, lock, images, etc.):

1. **Consult `demo.html`** to list all available icons
2. **Copy the exact name** (e.g., `icon-users`, `icon-lock`, `icon-file-image`)
3. **Use it in your hook**:

```php
$items[] = array(
  'NAME' => 'User Management',
  'URL'  => get_admin_plugin_menu_link(MY_PLUGIN_PATH . 'admin.php'),
  'ICON' => 'icon-users',  // Users icon
  'ID'   => 'my_plugin_users',
);
```

### 6. Avoid Expensive Operations

The hook fires on every admin page load. Avoid:

```php
// ❌ BAD: Database query on every page load
function my_plugin_menubar_register($items)
{
  $count = pwg_query("SELECT COUNT(*) FROM ..."); // SLOW
  $items[] = array('NAME' => "My Plugin ($count)", ...);
  return $items;
}

// ✅ GOOD: Static information only
function my_plugin_menubar_register($items)
{
  $items[] = array('NAME' => 'My Plugin', ...);
  return $items;
}
```

---

## Preference Management (Admin > Plugins > Menubar)

Piwigo administrators can manage your entries via **Admin > Plugins > Menubar**:

- **Reorder** : Drag-and-drop to change order
- **Hide** : Uncheck to hide an entry without removing it
- **Add separators** : Group entries visually

Your plugin doesn't need to do anything — these preferences are handled automatically.

---

## Real-World Example: Mosaic Plugin

```php
<?php
// plugins/mosaic/main.inc.php

defined('PHPWG_ROOT_PATH') or die('Hacking attempt!');

// ... plugin code ...

add_event_handler('admin_menubar_plugin_links', 'mosaic_menubar_register');

/**
 * Registers the Mosaic entry in the admin menubar
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

## Troubleshooting

### My entry doesn't appear

1. **Verify your plugin is enabled** — the hook only fires for active plugins
2. **Check syntax** — the callback must return the `$items` array
3. **Verify admin panel exists** — `admin.php` must exist in your plugin folder
4. **Check permissions** — only administrators see the menubar

### My icon doesn't display correctly

- Ensure the icon class is correct (e.g., `icon-cog`, not `cog`)
- Icons are from Font Awesome (Piwigo-compatible)
- When in doubt, omit `ICON` to use the default

### Entry order keeps changing

This is normal! Administrators can reorganize entries via the management panel. For initial ordering, use consistent IDs.

---

## Typical Use Cases

### Gallery Layout Plugin

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

### Security Plugin

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

### Plugin with Multiple Sections (Multiple Entries)

```php
add_event_handler('admin_menubar_plugin_links', 'my_plugin_menubar');

function my_plugin_menubar($items)
{
  $base_url = get_admin_plugin_menu_link(MY_PLUGIN_PATH);

  // Check that entries don't already exist
  $ids = array();
  foreach ($items as $item) {
    if (isset($item['ID'])) {
      $ids[] = $item['ID'];
    }
  }

  // Add main entries
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

## Resources

- **Piwigo Hooks** : https://piwigo.org/en/doc/doku.php?id=dev:plugins:events
- **Font Awesome Icons** : https://fontawesome.io/icons/
- **Piwigo Plugin Development** : https://piwigo.org/en/doc/doku.php?id=dev:plugins

---

## Change Log

| Version | Date | Change |
|---------|------|--------|
| 2.0 | 2026-04-01 | Added `PLUGIN_DIR` support to prevent duplicates ; fixed menubar scrolling ; optimized styling |
| 1.0 | 2026-03-04 | Initial documentation |

---

## Support

If you have questions about this hook, consult:

1. Source code: `admin/include/add_core_tabs.inc.php` (tab registration)
2. Processing file: `admin/plugins_menubar.php` (preference management)
3. Piwigo forums/issues

---

**Author** : Gotcha
**License** : Same as Piwigo (GPLv2)
