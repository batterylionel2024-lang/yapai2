class User < ApplicationRecord
  after_commit :clear_dashboard_cache

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :rememberable, :validatable, :lockable

  def super_admin?
    role == 'super_admin' || admin
  end

  def editor?
    role == 'editor'
  end

  def admin_role?
    ['super_admin', 'admin', 'editor'].include?(role)
  end

  def user?
    role == 'user'
  end

  private

  def clear_dashboard_cache
    Rails.cache.delete("admin_users_count")
  end
end
