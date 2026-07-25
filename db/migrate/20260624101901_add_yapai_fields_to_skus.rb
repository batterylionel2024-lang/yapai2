class AddYapaiFieldsToSkus < ActiveRecord::Migration[8.1]
  def change
    add_column :skus, :item_no, :string
    add_column :skus, :material, :string
    add_column :skus, :specification, :string
    add_column :skus, :head_circumference, :string
    add_column :skus, :brim_length, :string
    add_column :skus, :closure_type, :string
    add_column :skus, :embroidery_print, :string
    add_column :skus, :color, :string
    add_column :skus, :moq, :string
    add_column :skus, :sample_time, :string
    add_column :skus, :production_lead_time, :string
    add_column :skus, :packing, :string
    add_column :skus, :carton_size, :string
    add_column :skus, :gross_weight, :string
  end
end
