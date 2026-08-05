class CreateOrders < ActiveRecord::Migration[8.0]
  def change
    create_table :orders do |t|
      t.string :name
      t.string :country
      t.string :phone
      t.string :email
      t.string :status

      t.timestamps
    end

    create_table :order_items do |t|
      t.references :order, null: false, foreign_key: true
      t.references :sku, null: false, foreign_key: true
      t.integer :quantity

      t.timestamps
    end
  end
end
