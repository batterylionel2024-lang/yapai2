class ContactMessage < ApplicationRecord
  after_commit :clear_dashboard_cache

  validates :name, presence: true
  validates :email, presence: true
  validates :subject, presence: true
  validates :message, presence: true

  private

  def clear_dashboard_cache
    Rails.cache.delete("admin_messages_count")
    Rails.cache.delete("admin_unread_messages_count")
  end
end
