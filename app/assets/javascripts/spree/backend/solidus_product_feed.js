Spree.ready(function() {
  'use strict';

  $('.item_ids').on('change', function(e) {
    e.preventDefault();

    var $el = $(e.currentTarget);
    var $itemIds = $('#product_catalog_item_ids');
    var ids = JSON.parse($itemIds.val());

    if ($el.prop('checked') === true) {
      ids.push($el.val());
    } else {
      var idIndex = null;
      $.each(ids, function(index, value) {
        if (value === $el.val()) {
          idIndex = index;
        }
      })
      ids.splice(idIndex, 1);
    }

    $itemIds.val(JSON.stringify(ids));
  })

  var selectUnselectAll = function(selected) {
    var ids = [];
    var $itemIds = $('#product_catalog_item_ids');

    $('.item_ids').map(function(i, item) {
      $(item).prop('checked', selected);

      if (selected === true) {
        ids.push($(item).val());
      }
    })

    $itemIds.val(JSON.stringify(ids));
  };

  var allChecked = function() {
    return $('.item_ids:checked').length === $('.item_ids').length;
  };

  $('#product_feed_options_color_fill').on('change', function(e) {
    var $el = $(e.currentTarget);

    if ($el.prop('checked') === true) {
      $('#product_feed_options_color').removeClass('hidden');
      $('#product_feed_options_affine_clamp').removeAttr('checked');
      $('#product_feed_options_affine_clamp_value').val('false');
      $('#product_feed_options_color_fill_value').val('true');
    } else {
      $('#product_feed_options_color').addClass('hidden');
      $('#product_feed_options_color').val('').prop('required', false).trigger('change');
      $('#product_feed_options_affine_clamp_value').val('true');
      $('#product_feed_options_color_fill_value').val('false');
    }
  });

  $('#product_feed_options_affine_clamp').on('change', function(e) {
    var $el = $(e.currentTarget);

    if ($el.prop('checked') === true) {
      $('#product_feed_options_color').addClass('hidden');
      $('#product_feed_options_color').val('').prop('required', false).trigger('change');
      $('#product_feed_options_color_fill').removeAttr('checked');
      $('#product_feed_options_color_fill_value').val('false');
      $('#product_feed_options_affine_clamp_value').val('true');
    } else {
      $('#product_feed_options_color').removeClass('hidden');
      $('#product_feed_options_color').prop('required', true).trigger('change');
      $('#product_feed_options_color_fill_value').val('true');
      $('#product_feed_options_affine_clamp_value').val(false);
    };
  });

  $('#product-list-select-all').on('click', function(e) {
    e.preventDefault();

    if (allChecked() === true) {
      selectUnselectAll(false);
    } else {
      selectUnselectAll(true);
    }
  });

  $('.image_selection').on('click', function(e) {
    e.preventDefault();
    e.stopPropagation();

    var $el = $(e.currentTarget);

    if ($el.hasClass('selected')) {
      $('.image_selection').removeClass('selected');
      $('.image_selection').find('.select_image').removeClass('active').addClass('hidden');
      $el.removeClass('selected').find('.select_image').removeClass('active').addClass('hidden');
      $('#product_feed_overlay_image_id').val('');
    } else {
      $('.image_selection').removeClass('selected');
      $('.image_selection').find('.select_image').removeClass('active').addClass('hidden');
      $el.addClass('selected').find('.select_image').removeClass('hidden').addClass('active');
      $('#product_feed_overlay_image_id').val($el.attr('id'));
    }
  })

  $('#product_feed_attachment').on('change', function(e) {
    e.preventDefault();
    e.stopPropagation();

    var producFeedId = $('#product_feed_id').val();
    var file = e.currentTarget.files[0];

    if (file) {
      var formData = new FormData();
      formData.append('product_feed_image[image][attachment]', file);

      $.ajax({
        type: 'post',
        url: 'images',
        data: formData,
        contentType: false,
        processData: false,
        success: function(data) {
          location.reload();
        },
        error: function(xhr) {
          console.error(xhr.responseText);
        },
      });
    }
  })

  $('.remove_image').on('click', function(e) {
    e.preventDefault();
    e.stopPropagation();

    var producFeedId = $('#product_feed_id').val();
    var producFeedImageId = $(e.currentTarget).attr('id');

    if (producFeedImageId) {
      var formData = new FormData();
      formData.append('product_feed_id', producFeedImageId);

      $.ajax({
        type: 'delete',
        url: '/admin/product_feeds/' + producFeedId + '/images/' + producFeedImageId,
        data: formData,
        contentType: false,
        processData: false,
        success: function(data) {
          location.reload();
        },
        error: function(xhr) {
          console.error(xhr.responseText);
        },
      });
    }
  })
});
