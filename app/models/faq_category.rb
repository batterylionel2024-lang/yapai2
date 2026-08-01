class FaqCategory < ApplicationRecord
  has_many :faqs, -> { order(position: :asc) }, dependent: :destroy
  validates :name, presence: true
end
