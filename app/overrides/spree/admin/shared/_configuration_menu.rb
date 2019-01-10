Deface::Override.new(
  virtual_path: 'spree/admin/shared/_configuration_menu',
  name: 'admin_product_feed_configurations_menu',
  insert_bottom: "[data-hook='admin_configurations_sidebar_menu']",
  disabled: false,
  partial: 'spree/admin/shared/product_feed_configuration_menu'
)
