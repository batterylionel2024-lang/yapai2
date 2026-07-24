class DropAboutCarousels < ActiveRecord::Migration[8.1]
  def change
    drop_table :about_carousels do |t|
      t.string :title
      t.text :description
      t.string :link
      t.integer :position
      t.boolean :active
      t.timestamps
    end
  end
end
