module ConversationControllerHelper
  def block_conversation(conversation)
    conversation.update(blocked: true)
    conversation.messages.create(content: "Conversation is blocked by #{Current.user.name}", account_id: conversation.account_id,
                                 inbox_id: conversation.inbox_id, conversation_id: conversation.id, message_type: 'activity')
    head :ok
  end

  def unblock_conversation(conversation)
    conversation.update(blocked: false)
    conversation.messages.create(content: "Conversation is unblocked by #{Current.user.name}", account_id: conversation.account_id,
                                 inbox_id: conversation.inbox_id, conversation_id: conversation.id, message_type: 'activity')
    head :ok
  end
end
