class TriggerManageSubscriptionsJob < ApplicationJob
  queue_as :scheduled_jobs
  def perform
    # trigger the scheduled email campaign jobs
    # Contact.where(mail_subscription: "subscribed").each do |contact|
    # contact.coversation.last
    # message = contact.conversations&.last&.messages&where.last
    Rails.logger.debug('============')
    # end
  end
end
