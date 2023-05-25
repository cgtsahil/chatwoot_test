class CampaignMailer < ApplicationMailer
  def send_campaign_one_off_mails(contact, campaign)
    mail({
           to: contact.email,
           from: 'akshat@codegaragetech.com',
           subject: campaign.title,
           body: campaign.message
         })
  end
end
