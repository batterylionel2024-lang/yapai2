class AddIndexesToOptimizeDashboard < ActiveRecord::Migration[7.1]
  def change
    add_index :visit_records, :visit_time unless index_exists?(:visit_records, :visit_time)
    add_index :skus, :status unless index_exists?(:skus, :status)
    add_index :contact_messages, :read unless index_exists?(:contact_messages, :read)
  end
end
