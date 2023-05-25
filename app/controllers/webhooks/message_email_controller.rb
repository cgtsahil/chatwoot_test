class Webhooks::MessageEmailController < ActionController::API
  respond_to :json

  def perform
    response_data = params['_json']
    return unless valid_webhook_token

    # if valid_webhook_token
    response_data.each do |response|
      case response['event']
      when 'open'
        on_open(response)
      when 'delivered'
        on_deliver(response)
      when 'spamreport', 'unsubscribe'
        unsubscribe_mail(response)
      else
        true
      end
    end
    render json: {}, status: :ok
  end

  private

  def valid_webhook_token
    params[:token] == ENV['SENDGRID_WEBHOOK_TOKEN']
  end

  def on_deliver(response)
    message = Message.where(source_id: response['smtp-id'][1..-2]).last
    message.update(mail_message_id: response['sg_message_id']) if message.present?
  end

  def on_open(response)
    message = Message.where(mail_message_id: response['sg_message_id']).last
    message.update(mail_status: response['event']) if message.present? && message.mail_status != 'open'
  end

  def unsubscribe_mail(response)
    message = Message.where(mail_message_id: response['sg_message_id']).last
    return if message.blank?

    # if message.present?
    message.update(mail_status: response['event'])
    message.conversation.contact.update(mail_subscription: 'unsubscribed')
    # end
  end
end
