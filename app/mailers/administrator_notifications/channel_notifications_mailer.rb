class AdministratorNotifications::ChannelNotificationsMailer < ApplicationMailer
  def slack_disconnect
    return unless smtp_config_set_or_development?

    subject = 'Tu integración de Slack ha caducado'
    @action_url = "#{ENV.fetch('FRONTEND_URL', nil)}/app/accounts/#{Current.account.id}/settings/integrations/slack"
    send_mail_with_liquid(to: admin_emails, subject: subject) and return
  end

  def dialogflow_disconnect
    return unless smtp_config_set_or_development?

    subject = 'Tu integración de Dialogflow fue desconectada'
    send_mail_with_liquid(to: admin_emails, subject: subject) and return
  end

  def facebook_disconnect(inbox)
    return unless smtp_config_set_or_development?

    subject = 'La conexión a tu página de Facebook ha caducado'
    @action_url = "#{ENV.fetch('FRONTEND_URL', nil)}/app/accounts/#{Current.account.id}/settings/inboxes/#{inbox.id}"
    send_mail_with_liquid(to: admin_emails, subject: subject) and return
  end

  def whatsapp_disconnect(inbox)
    return unless smtp_config_set_or_development?

    subject = 'Tu conexión de Whatsapp ha caducado'
    @action_url = "#{ENV.fetch('FRONTEND_URL', nil)}/app/accounts/#{Current.account.id}/settings/inboxes/#{inbox.id}"
    send_mail_with_liquid(to: admin_emails, subject: subject) and return
  end

  def email_disconnect(inbox)
    return unless smtp_config_set_or_development?

    subject = 'Su bandeja de entrada de correo electrónico ha sido desconectada. Actualice las credenciales para SMTP/IMAP.'
    @action_url = "#{ENV.fetch('FRONTEND_URL', nil)}/app/accounts/#{Current.account.id}/settings/inboxes/#{inbox.id}"
    send_mail_with_liquid(to: admin_emails, subject: subject) and return
  end

  def contact_import_complete(resource)
    return unless smtp_config_set_or_development?

    subject = 'Importación de contactos completada'

    @action_url = Rails.application.routes.url_helpers.rails_blob_url(resource.failed_records) if resource.failed_records.attached?
    @action_url ||= "#{ENV.fetch('FRONTEND_URL', nil)}/app/accounts/#{resource.account.id}/contacts"
    @meta = {}
    @meta['failed_contacts'] = resource.total_records - resource.processed_records
    @meta['imported_contacts'] = resource.processed_records
    send_mail_with_liquid(to: admin_emails, subject: subject) and return
  end

  def contact_export_complete(file_url)
    return unless smtp_config_set_or_development?

    @action_url = file_url
    subject = "El archivo de exportación de su contacto está disponible para descargar."
    send_mail_with_liquid(to: admin_emails, subject: subject) and return
  end

  private

  def admin_emails
    Current.account.administrators.pluck(:email)
  end

  def liquid_locals
    super.merge({ meta: @meta })
  end
end
