class SiteConfig < ApplicationRecord
  has_one_attached :logo
  has_one_attached :favicon
  has_one_attached :sitemap
  has_one_attached :robots
  
  has_one_attached :infra_image_1
  has_one_attached :infra_image_2
  has_one_attached :infra_image_3
  has_one_attached :infra_image_4
  has_one_attached :strength_image
  has_many_attached :factory_images

  def self.get
    first_or_create!(name: "Yapai")
  end
end
