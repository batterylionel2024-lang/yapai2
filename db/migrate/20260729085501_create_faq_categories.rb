class CreateFaqCategories < ActiveRecord::Migration[8.1]
  def change
    create_table :faq_categories do |t|
      t.string :name
      t.integer :position, default: 0

      t.timestamps
    end
  end
end
