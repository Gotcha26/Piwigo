{combine_script id='jquery.sort' load='footer' path='themes/default/js/plugins/jquery.sort.js'}
{combine_script id='common' load='footer' path='admin/themes/default/js/common.js'}
{combine_script id='jquery.jgrowl' load='footer' require='jquery' path='themes/default/js/plugins/jquery.jgrowl_minimized.js'}
{combine_css path="themes/default/js/plugins/jquery.jgrowl.css"}

{footer_script require='jquery.ui.sortable,jquery.jgrowl,jquery.sort'}
var dragIconSrc = '{$themeconf.admin_icon_dir}/cat_move.png';
var successHead = '{'Update Complete'|@translate|@escape:'javascript'}';
var strSortAtoZ = '{'Sort A to Z'|@translate|@escape:'javascript'}';
var strSortZtoA = '{'Sort Z to A'|@translate|@escape:'javascript'}';
{if isset($save_success)}
var jGrowlSuccessMsg = '{$save_success|escape:'javascript'}';
{/if}
{literal}
jQuery(document).ready(function() {
  jQuery(".pluginMenuLi").css("cursor", "move");

  jQuery(".pluginMenuUl").sortable({
    axis: "y",
    opacity: 0.8,
    handle: ".drag_button",
    placeholder: "ui-state-highlight",
    update: function() {
      updateOrder();
    }
  });

  jQuery("input[name^='hide_']").click(function() {
    var id = this.name.replace('hide_', '');
    if (this.checked) {
      jQuery("#menu_" + id).addClass('menuLi_hidden');
    } else {
      jQuery("#menu_" + id).removeClass('menuLi_hidden');
    }
  });

  jQuery("#addSeparator").click(function(e) {
    e.preventDefault();
    var sepId = 'separator_' + Date.now();
    var html = '<li class="pluginMenuLi pluginMenuSeparator" id="menu_' + sepId + '">'
      + '<p>'
      + '<img src="' + dragIconSrc + '" class="drag_button" alt="Drag to re-order" title="Drag to re-order">'
      + '<span class="separator-line"><hr></span>'
      + '<a href="#" class="removeSeparator" title="Remove separator"><i class="icon-cancel"></i></a>'
      + '</p>'
      + '</li>';
    jQuery(".pluginMenuUl").append(html);
    jQuery(".pluginMenuUl").sortable("refresh");
    updateOrder();
  });

  jQuery(document).on("click", ".removeSeparator", function(e) {
    e.preventDefault();
    jQuery(this).closest("li").remove();
    updateOrder();
  });

  jQuery("#pluginMenubarForm").submit(function() {
    updateOrder();
  });

  // Search filter
  jQuery('#menubar-search').on('input', function() {
    var term = this.value.toUpperCase();
    jQuery('.pluginMenuLi:not(.pluginMenuSeparator)').each(function() {
      var name = jQuery(this).find('strong').text().toUpperCase();
      jQuery(this).toggle(term === '' || name.indexOf(term) !== -1);
    });
    jQuery('.search-cancel').toggle(term !== '');
  });

  jQuery('.search-cancel').on('click', function() {
    jQuery('#menubar-search').val('').trigger('input');
  });

  // Sort A→Z / Z→A toggle
  var sortAscending = true;
  jQuery('#menubar-sort-az').on('click', function(e) {
    e.preventDefault();
    var $btn = jQuery(this);
    jQuery('.pluginMenuUl li.pluginMenuLi:not(.pluginMenuSeparator)').sortElements(function(a, b) {
      var comparison = jQuery(a).find('strong').text() > jQuery(b).find('strong').text() ? 1 : -1;
      return sortAscending ? comparison : -comparison;
    });
    sortAscending = !sortAscending;
    // Update button label and icon
    if (sortAscending) {
      $btn.find('i').removeClass('sort-desc');
      $btn.find('.sort-label').text(strSortAtoZ);
    } else {
      $btn.find('i').addClass('sort-desc');
      $btn.find('.sort-label').text(strSortZtoA);
    }
    updateOrder();
  });

  function updateOrder() {
    var ids = [];
    jQuery(".pluginMenuUl").find("li.pluginMenuLi").each(function() {
      var id = this.id.replace('menu_', '');
      ids.push(id);
    });
    jQuery("#menubar_items_order").val(ids.join(','));
  }

  if (typeof jGrowlSuccessMsg !== 'undefined') {
    jQuery.jGrowl(jGrowlSuccessMsg, { theme: 'success', header: successHead, life: 4000, sticky: false });
  }

  const targetNode = document.getElementById("theAdminPage");
  const observer = new MutationObserver(function(mutationList) {
    for (const mutation of mutationList) {
      if (mutation.type === "childList") {
        let popup = jQuery("#jGrowl").children();
        for (let i = 0; i < popup.length; i++) {
          if ((jQuery(popup[i])).hasClass("success")) {
            if (!((jQuery(popup[i]).children(":first")).hasClass("jGrowl-popup-icon icon-ok"))) {
              jQuery(popup[i]).prepend('<div class="jGrowl-popup-icon icon-ok"></div>');
            }
          }
        }
      }
    }
  });
  if (targetNode) {
    observer.observe(targetNode, { attributes: false, childList: true, subtree: true });
  }
});
{/literal}{/footer_script}

{html_style}{literal}
.pluginMenuUl {
  list-style: none;
  margin: 0;
  padding: 0;
}

.pluginMenuLi {
  background: #f5f5f5;
  border: 1px solid #ddd;
  margin: 2px 0;
  padding: 8px 12px;
  border-radius: 3px;
}

.pluginMenuLi p {
  margin: 0;
  display: flex;
  align-items: center;
  gap: 10px;
}

.pluginMenuLi .drag_button {
  cursor: move;
  opacity: 0.6;
}

.pluginMenuLi .drag_button:hover {
  opacity: 1;
}

.pluginMenuLi_hidden,
.menuLi_hidden {
  opacity: 0.4;
}

.pluginMenuLi strong {
  flex: 1;
}

.pluginMenuLi span {
  margin-left: auto;
  flex-shrink: 0;
}

.pluginMenuLi i[class^="icon-"] {
  font-size: 16px;
  margin-right: 5px;
}

.pluginMenuSeparator .separator-line {
  flex: 1;
}

.pluginMenuSeparator .separator-line hr {
  margin: 0;
  border: none;
  border-top: 1px dashed #999;
}

.removeSeparator {
  color: #c00;
}

.removeSeparator:hover {
  color: #f00;
}

.ui-state-highlight {
  height: 36px;
  border: 2px solid green;
  background: #ffc;
  margin: 2px 0;
}

.no-items-notice {
  padding: 20px;
  text-align: center;
  color: #666;
  font-style: italic;
}

.no-items-notice i {
  font-size: 48px;
  display: block;
  margin-bottom: 10px;
  color: #ccc;
}

#addSeparator {
  margin: 10px 0;
  display: inline-block;
}

#menubar-sort-az i {
  display: inline-block;
  transition: transform 0.2s ease;
}

#menubar-sort-az i.sort-desc {
  transform: scaleY(-1);
}


{/literal}{/html_style}

{if $HAS_ITEMS}
<form id="pluginMenubarForm" action="{$F_ACTION}" method="post">

  <input type="hidden" name="menubar_items_order" id="menubar_items_order" value="">

  <div class="titrePage">
    <div class="sort">
      <div class="sort-actions">
        <a href="#" id="menubar-sort-az" class="buttonLike" title="{'Sort A to Z'|@translate}"><i class="icon-sort-name-up"></i> <span class="sort-label">{'Sort A to Z'|@translate}</span></a>
        <div id="search-plugin">
          <span class="icon-search search-icon"> </span>
          <span class="icon-cancel search-cancel"></span>
          <input class="search-input" type="text" placeholder="{'Search'|@translate}" id="menubar-search">
        </div>
      </div>
    </div>
  </div>

  <fieldset>
    <legend><i class="icon-puzzle"></i> {'Plugin Menubar'|@translate} &mdash; {'Manage entries'|@translate}</legend>

    <p>
      <a href="#" id="addSeparator"><i class="icon-plus-circled"></i> {'Add a separator'|@translate}</a>
    </p>

    <ul class="pluginMenuUl">
      {foreach from=$DISPLAY_ITEMS item=item}
      {if isset($item.TYPE) && $item.TYPE == 'separator'}
      <li class="pluginMenuLi pluginMenuSeparator" id="menu_{$item.ID}">
        <p>
          <img src="{$themeconf.admin_icon_dir}/cat_move.png" class="drag_button" alt="{'Drag to re-order'|@translate}" title="{'Drag to re-order'|@translate}">
          <span class="separator-line"><hr></span>
          <a href="#" class="removeSeparator" title="{'Remove separator'|@translate}"><i class="icon-cancel"></i></a>
        </p>
      </li>
      {else}
      <li class="pluginMenuLi {if $item.HIDDEN}menuLi_hidden{/if}" id="menu_{$item.ID}">
        <p>
          <img src="{$themeconf.admin_icon_dir}/cat_move.png" class="drag_button" alt="{'Drag to re-order'|@translate}" title="{'Drag to re-order'|@translate}">
          <i class="{$item.ICON|default:'icon-puzzle'}"></i>
          <strong>{$item.NAME}</strong>
          <span>
            <label class="font-checkbox">
              <span class="icon-check"></span>
              <input type="checkbox" name="hide_{$item.ID}" {if $item.HIDDEN}checked="checked"{/if}>
              {'Hide'|@translate}
            </label>
          </span>
        </p>
      </li>
      {/if}
      {/foreach}
    </ul>
  </fieldset>

  <fieldset>
    <legend><i class="icon-cog"></i> {'Menubar settings'|@translate}</legend>

    <div style="display:flex; flex-direction:column; gap:12px; padding:8px 0;">

      <div style="display:flex; align-items:center; gap:12px;">
        <label class="switch" title="{'When enabled, the plugin list stays open in the sidebar regardless of which section is active.'|@translate}">
          <input type="checkbox" name="always_open" {if $ALWAYS_OPEN}checked="checked"{/if}>
          <span class="slider round"></span>
        </label>
        <span>{'Keep plugin submenu always expanded'|@translate}</span>
      </div>

      <div style="display:flex; align-items:center; gap:12px;">
        <label class="switch" title="{'When enabled, names exceeding 23 characters are truncated with ellipsis and scroll on hover. When disabled, names wrap to the next line.'|@translate}">
          <input type="checkbox" name="truncate_names" id="truncate_names" {if $TRUNCATE_NAMES}checked="checked"{/if}>
          <span class="slider round"></span>
        </label>
        <span>{'Truncate long names'|@translate}</span>
      </div>

    </div>
  </fieldset>

  <div class="savebar-footer">
    <div class="savebar-footer-start"></div>
    <div class="savebar-footer-end">
      <div class="savebar-footer-block">
        <button class="buttonLike" type="submit" name="submit" {if $isWebmaster != 1}disabled{/if}><i class="icon-floppy"></i> {'Save Settings'|@translate}</button>
      </div>
    </div>
  </div>

</form>
{else}
<div class="no-items-notice">
  <i class="icon-puzzle"></i>
  <p>{'No plugin has registered a menubar entry.'|@translate}</p>
  <p>{'Plugins can register entries using the %s hook.'|@translate|@sprintf:'<code>admin_menubar_plugin_links</code>'}</p>
</div>
{/if}
