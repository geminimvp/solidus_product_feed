Deface::Override.new(
  virtual_path: 'spree/admin/shared/_settings_sub_menu',
  name: 'submenu_admin_configurations_menu',
  insert_bottom: "[data-hook='admin_settings_sub_tabs']",
  disabled: true,
  partial: 'spree/admin/shared/settings_submenu'
)
