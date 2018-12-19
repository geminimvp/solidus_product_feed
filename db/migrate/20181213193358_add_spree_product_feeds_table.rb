class AddSpreeProductFeedsTable < SolidusSupport::Migration[4.2][5.0][5.1]
  def change
    create_table :spree_product_feeds do |t|
      t.string :name
      t.string :feed_type
      t.references :product_catalog, index: true
      t.references :store, index: true

      t.timestamps
    end
  end
end
