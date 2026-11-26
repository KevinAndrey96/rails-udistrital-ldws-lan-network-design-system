# Outgoing mail is delivered over SMTP only when SMTP_ADDRESS is configured;
# otherwise ActionMailer keeps its per-environment default (log or :test).
if ENV['SMTP_ADDRESS'].present?
  ActionMailer::Base.delivery_method = :smtp
  ActionMailer::Base.smtp_settings = {
    address:              ENV['SMTP_ADDRESS'],
    port:                 ENV.fetch('SMTP_PORT', 587).to_i,
    domain:               ENV.fetch('SMTP_DOMAIN', 'localhost'),
    user_name:            ENV['SMTP_USERNAME'],
    password:             ENV['SMTP_PASSWORD'],
    authentication:       'plain',
    enable_starttls_auto: true
  }
end
