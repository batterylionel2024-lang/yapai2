class SiteConfig < ApplicationRecord
  has_one_attached :logo
  has_one_attached :favicon
  has_one_attached :sitemap
  has_one_attached :robots

  def self.get
    first_or_create!(name: "Yapai")
  end
end
