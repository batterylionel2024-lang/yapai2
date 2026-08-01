class Faq < ApplicationRecord
  belongs_to :faq_category
  validates :question, :answer, presence: true
end
