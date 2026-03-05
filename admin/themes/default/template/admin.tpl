{footer_script}
jQuery.fn.lightAccordion = function(options) {
  var settings = $.extend({
    header: 'dt',
    content: 'dd',
    active: 0
  }, options);

  return this.each(function() {
    var self = jQuery(this);

    var contents = self.find(settings.content),
        headers = self.find(settings.header);

    // Mark initially active dl as open
    var activeDl = headers.eq(settings.active).closest('dl');
    activeDl.addClass('is-open');
    contents.not(contents[settings.active]).hide();

    // If plugins submenu is pinned open, force it open regardless of active index
    {if $PLUGINS_MENU_ALWAYS_OPEN}
    var pluginsDl = jQuery('#menubar-plugins');
    pluginsDl.find('dd').show();
    pluginsDl.addClass('is-open');
    {/if}

    self.on('click', settings.header, function(e) {
        if (jQuery(e.target).closest('.dt-label').length) {
          return; // let the link navigate normally
        }
        var dl = jQuery(this).closest('dl');
        var content = jQuery(this).next(settings.content);
        if (content.is(':visible')) {
          content.slideUp();
          dl.removeClass('is-open');
        } else {
          content.slideDown();
          dl.addClass('is-open');
          // Close others (but not pinned-open plugins submenu)
          contents.not(content).each(function() {
            var otherDl = jQuery(this).closest('dl');
            {if $PLUGINS_MENU_ALWAYS_OPEN}
            if (otherDl.is('#menubar-plugins')) { return; }
            {/if}
            jQuery(this).slideUp();
            otherDl.removeClass('is-open');
          });
        }
    });
  });
};

$('#menubar').lightAccordion({
  active: {$ACTIVE_MENU}
});

// Plugin menubar name display mode
jQuery(document).ready(function() {
  jQuery('#menubar-plugins dd li a').each(function() {
    var $a = jQuery(this);
    // Wrap text node in .menubar-name (the scrolling element)
    $a.contents().filter(function() { return this.nodeType === 3; }).wrap('<span class="menubar-name"></span>');
    var $name = $a.find('.menubar-name');
    // Wrap .menubar-name in .menubar-name-clip (the clipping container)
    $name.wrap('<span class="menubar-name-clip"></span>');
    {if $PLUGINS_MENU_TRUNCATE_NAMES}
    // Measure actual text width (temporarily unconstrained)
    var fullWidth = $name[0].scrollWidth;
    if (fullWidth > 154) {
      $name.addClass('name-overflow');
      var scrollDist = fullWidth - 154;
      $a[0].style.setProperty('--scroll-dist', '-' + scrollDist + 'px');
      // 40px per second, min 1.5s
      $a[0].style.setProperty('--scroll-duration', Math.max(1.5, scrollDist / 40) + 's');
    }
    {/if}
  });
});

/* in case we have several infos/errors/warnings display bullets */
jQuery(document).ready(function() {
  var eiw = ["infos","erros","warnings", "messages"];

  for (var i = 0; i < eiw.length; i++) {
    var boxType = eiw[i];

    if (jQuery("."+boxType+" ul li").length > 1) {
      jQuery("."+boxType+" ul li").css("list-style-type", "square");
      jQuery("."+boxType+" .eiw-icon").css("margin-right", "20px");
    }
  }

  if (jQuery('h2').length > 0) {
    jQuery('h1').html(jQuery('h2').html());
  }
});
{/footer_script}

<div id="menubar">
  <div id="adminHome"><a href="{$U_ADMIN}" class="admin-main"><i class="icon-television"></i> {'Dashboard'|@translate}</a></div>

	<dl>
		<dt><i class="icon-picture"> </i><span>{'Photos'|@translate}&nbsp;</span><i class="icon-down-open open-menu"></i></dt>
		<dd>
			<ul>
				<li><a href="{$U_ADD_PHOTOS}"><i class="icon-plus-circled"></i>{'Add'|@translate}</a></li>
{if $SHOW_RATING}
        <li><a href="{$U_RATING}"><i class="icon-star"></i>{'Rating'|@translate}</a></li>
{/if}
				<li><a href="{$U_TAGS}"><i class="icon-tags"></i>{'Tags'|@translate}</a></li>
				<li><a href="{$U_RECENT_SET}"><i class="icon-clock"></i>{'Recent photos'|@translate}</a></li>
				<li><a href="{$U_BATCH}"><i class="icon-th"></i>{'Batch Manager'|@translate}</a></li>
{if $NB_PHOTOS_IN_CADDIE > 0}
				<li><a href="{$U_CADDIE}"><i class="icon-flag"></i>{'Caddie'|@translate}<span class="adminMenubarCounter">{$NB_PHOTOS_IN_CADDIE}</span></a></li>
{/if}
{if $NB_ORPHANS > 0}
				<li><a href="{$U_ORPHANS}"><i class="icon-heart-broken"></i>{'Orphans'|@translate}<span class="adminMenubarCounter">{$NB_ORPHANS}</span></a></li>
{/if}
			</ul>
		</dd>
  </dl>
  <dl>
		<dt><i class="icon-sitemap"> </i><span>{'Albums'|@translate}&nbsp;</span><i class="icon-down-open open-menu"></i></dt>
    <dd>
      <ul>
        <li><a href="{$U_ALBUMS}"><i class="icon-folder-open"></i>{'Manage'|@translate}</a></li>
        <li><a href="{$U_CAT_OPTIONS}"><i class="icon-pencil"></i>{'Properties'|@translate}</a></li>
      </ul>
    </dd>
  </dl>
  <dl>
		<dt><i class="icon-users"> </i><span>{'Users'|@translate}&nbsp;</span><i class="icon-down-open open-menu"></i></dt>
		<dd>
      <ul>
        <li><a href="{$U_USERS}"><i class="icon-user-add"></i>{'Manage'|@translate}</a></li>
        <li><a href="{$U_GROUPS}"><i class="icon-group"></i>{'Groups'|@translate}</a></li>
				<li><a href="{$U_NOTIFICATION_BY_MAIL}"><i class="icon-mail-1"></i>{'Notification'|@translate}</a></li>
      </ul>
		</dd>
  </dl>
  <dl id="menubar-plugins">
    <dt>
    {if $PLUGINS_MENU_ITEMS|@count > 0}
      <a href="{$U_PLUGINS}" class="admin-main dt-label"><i class="icon-puzzle"> </i><span>{'Plugins'|@translate}&nbsp;</span></a>
      <i class="icon-down-open open-menu"></i>
    {else}
      <a href="{$U_PLUGINS}" class="admin-main">
        <i class="icon-puzzle"> </i>
        <span>{'Plugins'|@translate}&nbsp;</span>
      </a>
    {/if}
    </dt>
    {if $PLUGINS_MENU_ITEMS|@count > 0}
    <dd>
      <ul>
        {foreach from=$PLUGINS_MENU_ITEMS item=item}
        {if isset($item.TYPE) && $item.TYPE == 'separator'}
        <li class="menubar-separator"><hr></li>
        {else}
        <li><a href="{$item.URL}"><i class="{$item.ICON|default:'icon-puzzle'}"></i>{$item.NAME}</a></li>
        {/if}
        {/foreach}
      </ul>
    </dd>
    {/if}
  </dl>
  <dl>
		<dt><i class="icon-wrench"> </i><span>{'Tools'|@translate}&nbsp;</span><i class="icon-down-open open-menu"></i></dt>
		<dd>
      <ul>
{if $ENABLE_SYNCHRONIZATION}
        <li><a href="{$U_CAT_UPDATE}"><i class="icon-exchange"></i>{'Synchronize'|@translate}</a></li>
{/if}
				<li><a href="{$U_HISTORY_STAT}"><i class="icon-signal"></i>{'History'|@translate}</a></li>
				<li><a href="{$U_MAINTENANCE}"><i class="icon-tools"></i>{'Maintenance'|@translate}</a></li>
{if isset($U_COMMENTS)}
				<li><a href="{$U_COMMENTS}"><i class="icon-chat"></i>{'Comments'|@translate}
        {if isset($NB_PENDING_COMMENTS) and $NB_PENDING_COMMENTS > 0}
          <span class="adminMenubarCounter" title="{'%d waiting for validation'|translate:$NB_PENDING_COMMENTS}">{$NB_PENDING_COMMENTS}</span>
        {/if}</a></li>
{/if}
{if isset($U_UPDATES)}
        <li><a href="{$U_UPDATES}"><i class="icon-arrows-cw"></i>{'Updates'|@translate}</a></li>
{/if}
      </ul>
		</dd>
  </dl>
  <dl>
		<dt><i class="icon-cog"> </i><span>{'Configuration'|@translate}&nbsp;</span><i class="icon-down-open open-menu"></i></dt>
		<dd>
      <ul>
        <li><a href="{$U_CONFIG_GENERAL}"><i class="icon-cog-alt"></i>{'Options'|@translate}</a></li>
        <li><a href="{$U_CONFIG_MENUBAR}"><i class="icon-menu"></i>{'Menu Management'|@translate}</a></li>
        {if {$U_SHOW_TEMPLATE_TAB}}
          <li><a href="{$U_CONFIG_EXTENTS}"><i class="icon-code"></i>{'Templates'|@translate}</a></li>
        {/if}
				<li><a href="{$U_CONFIG_LANGUAGES}"><i class="icon-language"></i>{'Languages'|@translate}</a></li>
        <li><a href="{$U_CONFIG_THEMES}"><i class="icon-brush"></i>{'Themes'|@translate}</a></li>
      </ul>
    </dd>
  </dl>
</div> <!-- menubar -->

<div id="content" class="content">

  <h1>{$ADMIN_PAGE_TITLE}<span class="admin-object-id">{$ADMIN_PAGE_OBJECT_ID}</span></h1>

  {if isset($TABSHEET)}
  {$TABSHEET}
  {/if}
  {if isset($U_HELP)}
  {include file='include/colorbox.inc.tpl'}
{footer_script}
  jQuery('.help-popin').colorbox({ width:"500px" });
{/footer_script}
  <ul class="HelpActions">
    <li><a href="{$U_HELP}&amp;output=content_only" title="{'Help'|@translate}" class="help-popin"><span class="icon-help-circled"></span></a></li>
  </ul>
  {/if}

<div class="eiw">
  {if isset($errors)}
  <div class="errors">
    <ul>
      {foreach from=$errors item=error}
      <li><i class="eiw-icon icon-cancel"></i>{$error}</li>
      {/foreach}
    </ul>
  </div>
  {/if}

  {if isset($infos)}
  <div class="infos">
    <ul>
      {foreach from=$infos item=info}
      <li><i class="eiw-icon icon-ok-circled"></i>{$info}</li>
      {/foreach}
    </ul>
  </div>
  {/if}

  {if isset($warnings)}
  <div class="warnings">
    <ul>
      {foreach from=$warnings item=warning}
      <li><i class="eiw-icon icon-attention"></i>{$warning}</li>
      {/foreach}
    </ul>
  </div>
  {/if}

  {if isset($messages)}
  <div class="messages">
    <ul>
      {foreach from=$messages item=message}
          <li><i class="eiw-icon icon-info-circled-1"></i>{$message}</li>
      {/foreach}
    </ul>
  </div>
  {/if}

</div> {* .eiw *}

  {$ADMIN_CONTENT}
</div>
