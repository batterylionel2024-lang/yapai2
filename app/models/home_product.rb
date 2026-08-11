class HomeProduct < ApplicationRecord
  has_one_attached :image
  
  validates :title, presence: true
  validates :row, presence: true, inclusion: { in: [1, 2] }
  
  scope :active, -> { where(active: true) }
  scope :row_1, -> { where(row: 1).order(:position) }
  scope :row_2, -> { where(row: 2).order(:position) }
end
