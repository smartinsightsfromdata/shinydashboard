/*jshint browser:true, jquery:true, indent:2*/

$(function() {
  // This function handles a special case in the AdminLTE sidebar: when there
  // is a sidebar-menu with items, and one of those items has sub-items, and
  // they are used for tab navigation. Normally, if one of the items is
  // selected and then a sub-item is clicked, both the item and sub-item will
  // retain the "active" class, so they will both be highlighted. This happens
  // because they're not designed to be used together for tab panels. This
  // code ensures that only one item will have the "active" class.
  var deactivateOtherTabs = function() {
    var $this = $(this);

    // Find all tab links under sidebar-menu
    var $tablinks = $this.closest("ul.sidebar-menu").find("a[data-toggle='tab']");

    // If any other items are active, deactivate them
    $tablinks.not($this).parent("li").removeClass("active");
  };

  $(document).on('shown.bs.tab', '.sidebar-menu a[data-toggle="tab"]',
                 deactivateOtherTabs);


  // When document is ready, if there is a sidebar menu with no activated tabs,
  // activate the first one.
  var ensureActivatedTab = function() {
    var $tablinks = $("ul.sidebar-menu").find("a[data-toggle='tab']");

    if (! $tablinks.parent("li").hasClass("active") ) {
      $tablinks.first().tab("show");
    }
  };

  ensureActivatedTab();

  // Optionally disable sidebar
  if ($("section.sidebar").data("disable")) {
    $(".left-side").addClass("collapse-left");
    $(".right-side").addClass("strech");
    $(".navbar > .sidebar-toggle").hide();
  }
});
