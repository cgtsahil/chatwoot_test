class TriggerScheduledEmailJob < ApplicationJob
  queue_as :scheduled_jobs

  def perform
    # trigger the scheduled email campaign jobs
    Campaign.where(campaign_type: :one_off, campaign_status: :active).where(scheduled_at: 3.days.ago..Time.current).all.each do |campaign|
      Campaigns::TriggerOneoffEmailCampaignJob.perform_later(campaign)
    end
  end
end
