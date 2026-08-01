class Post < ApplicationRecord
  has_rich_text :content
  has_one_attached :cover_image do |attachable|
    attachable.variant :thumb, resize_to_limit: [400, 300], format: :webp, saver: { quality: 80 }
    attachable.variant :large, resize_to_limit: [1200, 800], format: :webp, saver: { quality: 85 }
  end

  CATEGORIES = %w[enterprise_updates industry_news].freeze

  validates :title, presence: true
  validates :status, inclusion: { in: %w[draft published] }
  validates :category, presence: true, inclusion: { in: CATEGORIES }

  scope :published, -> { where(status: "published").order(published_at: :desc) }
  scope :enterprise_updates, -> { where(category: "enterprise_updates") }
  scope :industry_news, -> { where(category: "industry_news") }

  def published?
    status == "published"
  end
end
