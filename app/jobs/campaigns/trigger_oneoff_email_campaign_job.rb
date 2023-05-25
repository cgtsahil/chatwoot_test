class Campaigns::TriggerOneoffEmailCampaignJob < ApplicationJob
  queue_as :low

  def perform(campaign)
    campaign.email_trigger!
  end
end
