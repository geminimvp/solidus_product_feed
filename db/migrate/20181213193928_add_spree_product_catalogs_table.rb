class AddSpreeProductCatalogsTable < SolidusSupport::Migration[4.2][5.0][5.1]
  def change
    create_table :spree_product_catalogs do |t|
      t.string :name
      t.string :item_ids
      t.references :store, index: true

      t.timestamps
    end
  end
end
