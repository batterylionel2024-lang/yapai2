class AddInfrastructureFieldsToSiteConfigs < ActiveRecord::Migration[8.1]
  def change
    add_column :site_configs, :infra_title, :string
    add_column :site_configs, :infra_subtitle, :string
    
    # We will use Active Storage for the 4 images and 1 strength image
    # But we need columns for the labels and values
    (1..4).each do |i|
      add_column :site_configs, "infra_label_#{i}", :string
      add_column :site_configs, "infra_value_#{i}", :string
    end
  end
end
