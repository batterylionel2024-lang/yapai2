class NotificationMailer < ApplicationMailer
  default from: ENV.fetch("MAILER_FROM", "Yapai <onboarding@resend.dev>")

  def contact_notification(contact_message)
    # 强制在发送前再次确保 API Key 被注入
    Resend.api_key = ENV["RESEND_API_KEY"] if ENV["RESEND_API_KEY"].present?
    
    @contact_message = contact_message
    recipients = ENV.fetch("CONTACT_FORM_TO", "Caroline@yapaibattery.com").split(",")
    
    mail(
      to: recipients,
      subject: "New Contact Message: #{@contact_message.subject}"
    )
  end
end
