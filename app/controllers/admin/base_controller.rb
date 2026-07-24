class Admin::BaseController < ApplicationController
  before_action :authenticate_user!
  before_action :check_admin
  before_action :set_unread_count

  layout "admin"

  after_action :track_operation, if: -> { request.post? || request.patch? || request.put? || request.delete? }

  private

  def track_operation
    # 忽略某些不需要追踪的操作
    return if response.status >= 400
    
    # 提取真实 IP
    forwarded_for = request.env['HTTP_X_FORWARDED_FOR']
    real_ip = if forwarded_for.present?
                forwarded_for.split(',').first&.strip
              else
                request.env['HTTP_X_REAL_IP'] || request.remote_ip
              end

    details = {
      path: request.path,
      params: filter_sensitive_params(params.to_unsafe_h.except("controller", "action")),
      method: request.method,
      status: response.status
    }

    OperationLog.create(
      user: current_user,
      action: "#{controller_name}##{action_name}",
      resource_type: controller_name.classify,
      details: details.to_json,
      ip_address: real_ip
    )
  end

  def filter_sensitive_params(params)
    sensitive_keys = %w[password password_confirmation token secret]
    params.each do |k, v|
      if v.is_a?(Hash)
        filter_sensitive_params(v)
      elsif v.is_a?(Array)
        v.each { |item| filter_sensitive_params(item) if item.is_a?(Hash) }
      elsif sensitive_keys.include?(k.to_s)
        params[k] = "[FILTERED]"
      end
    end
    params
  end

  def set_unread_count
    @unread_messages_count = Rails.cache.fetch("admin_unread_messages_count", expires_in: 5.minutes) do
      ContactMessage.where(read: false).count
    end
  end
  
  def check_admin
    unless current_user.admin_role?
      redirect_to root_path, alert: "您没有权限访问该页面。"
    end
  end

  def require_super_admin
    unless current_user.super_admin?
      redirect_to admin_root_path, alert: "只有大管理员才有权访问该模块。"
    end
  end
end
