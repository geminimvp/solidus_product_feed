Deface::Override.new(
  virtual_path: 'spree/admin/shared/_configuration_menu',
  name: 'product_feed_admin_configurations_menu',
  insert_bottom: "[data-hook='admin_configurations_sidebar_menu']",
  disabled: true,
  partial: 'spree/admin/shared/configuration_menu'
)
