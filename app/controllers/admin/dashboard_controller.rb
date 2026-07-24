class Admin::DashboardController < Admin::BaseController
  def index
    @users_count = Rails.cache.fetch("admin_users_count", expires_in: 1.hour) { User.count }
    @total_skus = Rails.cache.fetch("admin_total_skus_count", expires_in: 1.hour) { Sku.count }
    @active_skus = Rails.cache.fetch("admin_active_skus_count", expires_in: 1.hour) { Sku.where(status: 'active').count }
    @messages_count = Rails.cache.fetch("admin_messages_count", expires_in: 1.hour) { ContactMessage.count }
    @today_visits = Rails.cache.fetch("admin_today_visits_count", expires_in: 10.minutes) do
      VisitRecord.where("visit_time >= ?", Time.current.beginning_of_day).count
    end
    @total_visits = Rails.cache.fetch("admin_total_visits_count", expires_in: 1.hour) { VisitRecord.count }
    
    # 诊断信息
    @storage_writable = File.writable?("/app/storage") rescue false
    @vips_installed = system("vips --version") rescue false
  end
end
