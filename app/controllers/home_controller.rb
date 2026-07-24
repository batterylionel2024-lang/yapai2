class HomeController < ApplicationController
  before_action :check_submission_rate_limit, only: [:create_contact]

  def index
    @featured_categories = Category.unscoped.where(featured: true).order(featured_position: :asc, id: :desc).with_attached_image
  end

  def all_products
    @skus_by_category = Sku.where(status: 'active').order(position: :asc, created_at: :desc).group_by(&:category_id)
    @root_categories = Category.where(parent_id: nil).includes(children: { children: { children: :children } })
  end

  def contact
    @contact_message = ContactMessage.new
  end

  def about
    @featured_categories = Category.unscoped.where(featured: true).order(featured_position: :asc, id: :desc).with_attached_image
  end

  def privacy
  end

  def factory
  end

  def create_contact
    # Cloudflare Turnstile Verification
    unless verify_turnstile(params["cf-turnstile-response"])
      redirect_to contact_path, alert: t('home.contact.form.verification_failed')
      return
    end

    if params[:privacy_agreement] != "1"
      redirect_to contact_path, alert: t('home.contact.form.privacy_error')
      return
    end

    @contact_message = ContactMessage.new(contact_params)
    if @contact_message.save
      begin
        # 记录调试信息到日志
        Rails.logger.info "[Mailer Debug] Attempting to send contact notification for Message ID: #{@contact_message.id}"
        Rails.logger.info "[Mailer Debug] From: #{ENV['MAILER_FROM'] || 'onboarding@resend.dev'}"
        Rails.logger.info "[Mailer Debug] API Key exists: #{ENV['RESEND_API_KEY'].present?}"

        # 使用 deliver_now 强制同步发送，以便在日志中捕获即时错误
        NotificationMailer.contact_notification(@contact_message).deliver_now
        
        Rails.logger.info "[Mailer Debug] Mail sent successfully."
      rescue => e
        Rails.logger.error "[Mailer Error] Delivery failed: #{e.class} - #{e.message}"
        Rails.logger.error e.backtrace.first(10).join("\n")
      end
      redirect_to contact_path, notice: t('home.contact.success_notice')
    else
      render :contact, status: :unprocessable_entity
    end
  end

  def robots
    config = SiteConfig.get
    if config.robots.attached?
      render plain: config.robots.download, content_type: 'text/plain'
    else
      # 默认 robots.txt 内容
      render plain: "User-agent: *\nAllow: /\nDisallow: /admin/\nDisallow: /users/\nDisallow: /up\n\nSitemap: #{root_url}sitemap.xml", content_type: 'text/plain'
    end
  end

  def sitemap
    config = SiteConfig.get
    if config.sitemap.attached?
      render xml: config.sitemap.download
    elsif File.exist?(Rails.root.join('public', 'sitemap.xml'))
      render xml: File.read(Rails.root.join('public', 'sitemap.xml'))
    else
      render xml: "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<urlset xmlns=\"http://www.sitemaps.org/schemas/sitemap/0.9\">\n  <url>\n    <loc>#{root_url}</loc>\n    <priority>1.0</priority>\n  </url>\n</urlset>", status: :not_found
    end
  end

  private

  def verify_turnstile(token)
    return false if token.blank?

    secret_key = ENV.fetch("CLOUDFLARE_TURNSTILE_SECRET_KEY", "1x0000000000000000000000000000000AA")
    uri = URI.parse("https://challenges.cloudflare.com/turnstile/v0/siteverify")
    response = Net::HTTP.post_form(uri, {
      'secret' => secret_key,
      'response' => token,
      'remoteip' => request.remote_ip
    })

    outcome = JSON.parse(response.body)
    outcome["success"] == true
  end

  def check_submission_rate_limit
    last_submission = session[:last_submission_time]
    if last_submission.present? && Time.parse(last_submission) > 1.minute.ago
      redirect_to contact_path, alert: t('home.submission_limit')
      return
    end
    session[:last_submission_time] = Time.current.to_s
  end

  def contact_params
    params.require(:contact_message).permit(:name, :email, :subject, :message)
  end
end
