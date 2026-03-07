<?php
// +-----------------------------------------------------------------------+
// | This file is part of Piwigo.                                          |
// |                                                                       |
// | For copyright and license information, please view the COPYING.txt    |
// | file that was distributed with this source code.                      |
// +-----------------------------------------------------------------------+

if (!defined('PHPWG_ROOT_PATH'))
{
  die ("Hacking attempt!");
}

if (!is_webmaster())
{
  $page['warnings'][] = str_replace('%s', l10n('user_status_webmaster'), l10n('%s status is required to edit parameters.'));
}

// Collect plugin menubar items (hook + fallback for plugins with Has Settings)
$plugins_menu_items = get_admin_menubar_plugin_links();

// Ensure each item has an ID (safety net for hook items without ID)
foreach ($plugins_menu_items as $idx => &$item)
{
  if (!isset($item['ID']))
  {
    $item['ID'] = 'plugin_' . $idx;
  }
}
unset($item);

// Load current preferences
$menubar_order = $conf['admin_menubar_order'];
if (is_string($menubar_order))
{
  $menubar_order = unserialize($menubar_order);
}
if (!is_array($menubar_order))
{
  $menubar_order = array();
}

$menubar_hidden = $conf['admin_menubar_hidden'];
if (is_string($menubar_hidden))
{
  $menubar_hidden = unserialize($menubar_hidden);
}
if (!is_array($menubar_hidden))
{
  $menubar_hidden = array();
}

$menubar_separators = $conf['admin_menubar_separators'];
if (is_string($menubar_separators))
{
  $menubar_separators = unserialize($menubar_separators);
}
if (!is_array($menubar_separators))
{
  $menubar_separators = array();
}

// +-----------------------------------------------------------------------+
// | Process form submission                                               |
// +-----------------------------------------------------------------------+

if (isset($_POST['submit']) and is_webmaster())
{
  // Read order from hidden input (comma-separated IDs)
  $new_order = array();
  if (!empty($_POST['menubar_items_order']))
  {
    $new_order = explode(',', $_POST['menubar_items_order']);
    $new_order = array_map('trim', $new_order);
    // Validate IDs: alphanumeric + underscore only
    $new_order = array_filter($new_order, function($id) {
      return preg_match('/^[a-zA-Z0-9_]+$/', $id);
    });
    $new_order = array_values($new_order);
  }

  // Read hidden items
  $new_hidden = array();
  foreach ($plugins_menu_items as $item)
  {
    if (isset($_POST['hide_' . $item['ID']]))
    {
      $new_hidden[] = $item['ID'];
    }
  }

  // Read separators
  $new_separators = array();
  foreach ($new_order as $id)
  {
    if (strpos($id, 'separator_') === 0)
    {
      $new_separators[$id] = array();
    }
  }

  // Save to config
  conf_update_param('admin_menubar_order', $new_order, true);
  conf_update_param('admin_menubar_hidden', $new_hidden, true);
  conf_update_param('admin_menubar_separators', $new_separators, true);
  conf_update_param('admin_menubar_always_open', !empty($_POST['always_open']));
  conf_update_param('admin_menubar_truncate_names', !empty($_POST['truncate_names']));
  conf_update_param('admin_menubar_align_icons', !empty($_POST['align_icons']));
  conf_update_param('admin_menubar_fallback_plugins', !empty($_POST['fallback_plugins']));

  // Redirect to GET to avoid browser "resend form" dialog
  redirect(get_root_url().'admin.php?page=plugins&tab=menubar&saved=1');
}

// +-----------------------------------------------------------------------+
// | Build the display list                                                |
// +-----------------------------------------------------------------------+

// Build sorted list: ordered items first, then unordered
$display_items = array();
$indexed_items = array();

foreach ($plugins_menu_items as $item)
{
  $indexed_items[$item['ID']] = $item;
}

if (!empty($menubar_order))
{
  foreach ($menubar_order as $id)
  {
    if (isset($indexed_items[$id]))
    {
      $entry = $indexed_items[$id];
      $entry['HIDDEN'] = in_array($id, $menubar_hidden);
      $display_items[] = $entry;
      unset($indexed_items[$id]);
    }
    elseif (strpos($id, 'separator_') === 0)
    {
      $display_items[] = array(
        'ID' => $id,
        'TYPE' => 'separator',
        'HIDDEN' => false,
      );
    }
  }
}

// Append remaining items not in order
foreach ($indexed_items as $item)
{
  $item['HIDDEN'] = in_array($item['ID'], $menubar_hidden);
  $display_items[] = $item;
}

// +-----------------------------------------------------------------------+
// | Template                                                              |
// +-----------------------------------------------------------------------+

$template->assign(array(
  'DISPLAY_ITEMS' => $display_items,
  'HAS_ITEMS' => count($plugins_menu_items) > 0,
  'F_ACTION' => get_root_url() . 'admin.php?page=plugins&amp;tab=menubar',
  'isWebmaster' => (is_webmaster()) ? 1 : 0,
  'ALWAYS_OPEN' => !empty($conf['admin_menubar_always_open']),
  'TRUNCATE_NAMES' => !empty($conf['admin_menubar_truncate_names']),
  'ALIGN_ICONS' => !empty($conf['admin_menubar_align_icons']),
  'FALLBACK_PLUGINS' => !empty($conf['admin_menubar_fallback_plugins']),
));

if (!empty($_GET['saved']))
{
  $template->assign('save_success', l10n('Order of menubar items has been updated successfully.'));
}

$template->assign('ADMIN_PAGE_TITLE', l10n('Plugins') . ' &rsaquo; ' . l10n('Plugin Menubar'));

$template->set_filename('plugins_menubar', 'plugins_menubar.tpl');
$template->assign_var_from_handle('ADMIN_CONTENT', 'plugins_menubar');
?>
