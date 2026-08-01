class CreateFaqs < ActiveRecord::Migration[8.1]
  def change
    create_table :faqs do |t|
      t.string :question
      t.text :answer
      t.references :faq_category, null: false, foreign_key: true
      t.integer :position, default: 0

      t.timestamps
    end
  end
end
