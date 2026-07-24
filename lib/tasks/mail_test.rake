namespace :mail_test do
  desc "Check mailer configuration and test sending"
  task check: :environment do
    puts "--- Mailer Configuration Check ---"
    puts "Delivery Method: #{Rails.application.config.action_mailer.delivery_method}"
    puts "Resend API Key present: #{ENV['RESEND_API_KEY'].present?}"
    puts "Mailer From: #{ENV['MAILER_FROM'] || 'Not set (using default)'}"
    puts "Contact Form To: #{ENV['CONTACT_FORM_TO'] || 'Not set (using default: Caroline@yapaibattery.com)'}"
    puts "Queue Adapter: #{Rails.application.config.active_job.queue_adapter}"
    
    if ENV['RESEND_API_KEY'].blank?
      puts "CRITICAL: RESEND_API_KEY is missing!"
    end
    
    if ENV['MAILER_FROM'].blank?
      puts "WARNING: MAILER_FROM is missing. Defaulting to onboarding@resend.dev (may only work for registered email)."
    end
  end

  desc "Send a test email manually"
  task send_test: :environment do
    begin
      message = ContactMessage.new(
        name: "Diagnostic Test",
        email: "test@example.com",
        subject: "System Diagnostic",
        message: "This is a test message to verify mailer configuration."
      )
      
      puts "Attempting to send test email to #{ENV.fetch("CONTACT_FORM_TO", "Caroline@yapaibattery.com")}..."
      NotificationMailer.contact_notification(message).deliver_now
      puts "SUCCESS: Email sent successfully (deliver_now)!"
    rescue => e
      puts "FAILED: #{e.class} - #{e.message}"
      puts e.backtrace.first(5)
    end
  end
end
