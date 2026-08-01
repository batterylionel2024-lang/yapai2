class Partner < ApplicationRecord
  has_one_attached :logo

  validates :name, presence: true
  validates :logo, presence: true
end
