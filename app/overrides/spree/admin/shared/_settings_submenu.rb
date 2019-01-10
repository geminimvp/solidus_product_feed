Deface::Override.new(
  virtual_path: 'spree/admin/shared/_settings_sub_menu',
  name: 'product_feed_submenu_admin_configurations_menu',
  insert_bottom: "[data-hook='admin_settings_sub_tabs']",
  disabled: false,
  partial: 'spree/admin/shared/product_feed_settings_submenu'
)
