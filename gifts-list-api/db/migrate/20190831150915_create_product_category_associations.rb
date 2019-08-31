class CreateProductCategoryAssociations < ActiveRecord::Migration[6.0]
  def change
    create_table :product_category_associations do |t|
      t.integer :product_id
      t.integer :category_id

      t.timestamps
    end
  end
end
