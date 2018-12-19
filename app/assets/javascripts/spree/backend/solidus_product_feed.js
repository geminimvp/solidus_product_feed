Spree.ready(function() {
  'use strict';

  var selectUnselectAll = function(selected) {
    $('.item_ids').map(function(i, item) {
      $(item).prop('checked', selected);
    })
  };

  var allChecked = function() {
    return $('.item_ids:checked').length === $('.item_ids').length;
  }

  $('#product-list-select-all').on('click', function(e) {
    e.preventDefault()

    if (allChecked() === true) {
      selectUnselectAll(false);
    } else {
      selectUnselectAll(true);
    }
  });
});
