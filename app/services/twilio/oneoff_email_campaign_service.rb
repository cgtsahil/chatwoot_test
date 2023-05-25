class Twilio::OneoffEmailCampaignService
  pattr_initialize [:campaign!]
  include ::MacroFormatHelper
  include ::EmailCampaignHelper

  def perform
    raise "Invalid campaign #{campaign.id}" if campaign.inbox.inbox_type != 'Email' || !campaign.one_off?
    raise 'Completed Campaign' if campaign.completed?

    # process_audience
    case campaign.custom_attributes['action']
    when 1
      send_new_mail
    when 2, 3
      reply_to_mail
    else
      raise 'Invalid Campaign'
    end
  end

  private

  delegate :inbox, to: :campaign
  delegate :channel, to: :inbox

  def send_new_mail
    campaign.completed!
    contacts = campaign.account.contacts.where(mail_subscription: 'subscribed').where.not(email: nil)
    contacts.each do |contact|
      next if contact.email.blank?

      conversation = contact.conversations.where(inbox_id: campaign.inbox_id).last
      if conversation.blank? || conversation.email_campaigns.present?
        create_conversation(contact)
        next
      end

      update_conversation(conversation, contact)
    end
  end

  def create_conversation(contact)
    contact_inbox = ContactInbox.find_or_create_by!(contact_id: contact.id, inbox_id: campaign.inbox_id, source_id: contact.email)
    conversation = ::Conversation.create!(
      account_id: campaign.account_id, inbox_id: campaign.inbox_id,
      contact_id: contact.id, contact_inbox_id: contact_inbox.id,
      campaign_id: campaign.id
    )
    update_conversation(conversation, contact)
    # send_mail(conversation, campaign.id)
    # update_email_campaigns(conversation, contact)
  end

  def update_conversation(conversation, contact)
    send_mail(conversation, campaign.id)
    # update_email_campaigns(conversation, contact)
    conversation.email_campaigns << campaign.id
    conversation.save!
    contact.email_campaigns << campaign.id
    contact.save!
  end

  # def update_email_campaigns(conversation, contact)
  #   conversation.email_campaigns << campaign.id
  #   conversation.save!
  #   contact.email_campaigns << campaign.id
  #   contact.save!
  # end

  def reply_to_mail
    contacts = campaign.inbox.contacts.where(mail_subscription: 'subscribed').where.not(email: nil)
                       .where("'#{campaign.custom_attributes['selected_mail']}' = ANY (email_campaigns)")
    contacts.each do |contact|
      conversation = contact&.conversations&.where('email_campaigns && ?', "{#{campaign.custom_attributes['selected_mail']}}")
      check_preferances(conversation&.last) if conversation.present?
    end
  end

  def check_preferances(conversation)
    selected_mail = campaign.custom_attributes['selected_mail'].to_s
    case campaign.custom_attributes['preference']
    when 1
      first_reply(conversation, selected_mail)
    when 2
      second_reply(conversation, selected_mail)
    when 3
      third_reply(conversation, selected_mail)
    when 4
      fourth_reply(conversation, selected_mail)
    else
      true
    end
  end

  def first_reply(conversation, selected_mail)
    send_first_reply(conversation, selected_mail) if campaign.custom_attributes['action'] == 2
    send_first_reply_if_unresponded(conversation, "#{selected_mail}oa") if campaign.custom_attributes['action'] == 3
  end

  def second_reply(conversation, selected_mail)
    send_reply(conversation, "#{selected_mail}_a", "#{selected_mail}_b") if campaign.custom_attributes['action'] == 2
    send_reply(conversation, "#{selected_mail}oa", "#{selected_mail}ob") if campaign.custom_attributes['action'] == 3
  end

  def third_reply(conversation, selected_mail)
    send_reply(conversation, "#{selected_mail}_b", "#{selected_mail}_c") if campaign.custom_attributes['action'] == 2
    send_reply(conversation, "#{selected_mail}ob", "#{selected_mail}oc") if campaign.custom_attributes['action'] == 3
  end

  def fourth_reply(conversation, selected_mail)
    send_last_reply(conversation, selected_mail) if campaign.custom_attributes['action'] == 2
    send_last_reply_if_unresponded(conversation, selected_mail) if campaign.custom_attributes['action'] == 3
  end
end
