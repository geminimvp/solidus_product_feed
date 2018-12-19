Deface::Override.new(
  virtual_path: 'spree/admin/stores/edit',
  name: 'product_feeds_admin_edit',
  insert_before: "erb[silent]:contains('if can? :update, @store')",
  disabled: false,
  partial: 'spree/admin/stores/feed_format_input',
  original: 'ec1cf2b5f26ce7fd92ae1335e2f420ec94c2f4e6'
)
