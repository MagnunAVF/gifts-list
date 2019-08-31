class CreateProductListAssociations < ActiveRecord::Migration[6.0]
  def change
    create_table :product_list_associations do |t|
      t.integer :product_id
      t.integer :list_id

      t.timestamps
    end
  end
end
