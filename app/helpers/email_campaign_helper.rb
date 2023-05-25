module EmailCampaignHelper
  def send_first_reply_if_unresponded(conversation, selected_mail)
    return if conversation&.email_campaigns&.include?(selected_mail)

    campaign_message = conversation.messages.where(email_campaign_id: campaign.custom_attributes['selected_mail']).last
    return if campaign_message.blank? || campaign_message.mail_status != 'open'

    last_message = conversation.messages.last
    send_message(conversation, selected_mail) if ((Time.now.utc - last_message.created_at) / 60) > campaign.custom_attributes['selected_time']

    # send_first_message_if_unresponsed(conversation, selected_mail)
  end

  # def send_first_message_if_unresponsed(conversation, selected_mail)
  #   return if last_message.blank?
  #   # last_message.update(email_campaign_id: nil) if last_message.email_campaign_id != campaign.custom_attributes['selected_mail']
  #  return send_message(conversation, selected_mail) if ((Time.now.utc - last_message.created_at) / 60) > campaign.custom_attributes['selected_time']
  # end

  def send_first_reply(conversation, selected_mail)
    return unless conversation&.email_campaigns&.include?(selected_mail) && !conversation&.email_campaigns&.include?("#{selected_mail}_a")

    send_first_message_if_unopened(conversation, selected_mail)
  end

  def send_first_message_if_unopened(conversation, selected_mail)
    last_message = conversation.messages.last
    return if last_message.blank?

    if (last_message.email_campaign_id == selected_mail || last_message.email_campaign_id == "#{selected_mail}_d") &&
       last_message.mail_status == 'unread' && ((Time.now.utc - last_message.created_at) / 60) > campaign.custom_attributes['selected_time']
      send_message(conversation, "#{selected_mail}_a")
    end
  end

  def send_reply(conversation, mail_included, mail_excluded)
    return unless conversation&.email_campaigns&.include?(mail_included) && !conversation&.email_campaigns&.include?(mail_excluded)

    check_last_message(conversation, mail_included, mail_excluded)
  end

  def check_last_message(conversation, mail_included, mail_excluded)
    last_message = conversation.messages.last
    return if campaign.custom_attributes['action'] == 2 && last_message.mail_status != 'unread'
    return unless ((Time.now.utc - last_message.created_at) / 60) > campaign.custom_attributes['selected_time'] &&
                  last_message.email_campaign_id == mail_included

    # return send_reply_if_opened(conversation,mail_excluded) if campaign.custom_attributes['action'] == 3
    # return unless last_message.email_campaign_id == mail_included && last_message.mail_status == 'unread'
    send_message(conversation, mail_excluded)
  end

  def send_last_reply_if_unresponded(conversation, selected_mail)
    return unless conversation&.email_campaigns&.include?("#{selected_mail}oc")

    send_last_message_if_unresponded(conversation, selected_mail)
  end

  def send_last_message_if_unresponded(conversation, selected_mail)
    last_message = conversation.messages.last
    return if last_message.blank?
    return unless last_message.email_campaign_id == "#{selected_mail}oc" &&
                  ((Time.now.utc - last_message.created_at) / 60) > campaign.custom_attributes['selected_time']

    conversation.email_campaigns.delete_if do |i|
      ["#{selected_mail}oa", "#{selected_mail}ob", "#{selected_mail}oc"].include?(i)
    end
    conversation.save!
    send_mail(conversation, "#{selected_mail}od")
  end

  def send_last_reply(conversation, selected_mail)
    return unless conversation&.email_campaigns&.include?("#{selected_mail}_c")

    send_last_message_if_unopened(conversation, selected_mail)
  end

  def send_last_message_if_unopened(conversation, selected_mail)
    last_message = conversation.messages.last
    return unless last_message.email_campaign_id == "#{selected_mail}_c" && last_message.mail_status == 'unread'
    return unless ((Time.now.utc - last_message.created_at) / 60) > campaign.custom_attributes['selected_time']

    send_last_message_mail(conversation, selected_mail)
  end

  def send_last_message_mail(conversation, selected_mail)
    conversation.email_campaigns.delete_if do |i|
      ["#{selected_mail}_a", "#{selected_mail}_b", "#{selected_mail}_c"].include?(i)
    end
    conversation.save!
    send_mail(conversation, "#{selected_mail}_d")
  end

  def send_message(conversation, mail_campaign_id)
    send_mail(conversation, mail_campaign_id)
    conversation.email_campaigns << (mail_campaign_id)
    conversation.save!
  end

  def send_mail(conversation, mail_campaign_id)
    content = macro_message_formatter(conversation, campaign.message)
    conversation.messages.create!(
      content: content, account_id: campaign.account_id,
      inbox_id: campaign.inbox_id, conversation_id: conversation.id,
      message_type: 'outgoing', email_campaign_id: mail_campaign_id,
      mail_subject: campaign.custom_attributes['mail_subject']
    )
  end
end
