module MacroFormatHelper
  def macro_message_formatter(conversation, content)
    return content unless content.present? && content.include?('}}')

    format_content(content, conversation)
  end

  def format_content(content, conversation)
    string_between_markers(content).each do |macro|
      content = content.gsub("{{#{macro}}}", format_macros(macro.strip, conversation).to_s)
    end
    content
  end

  def format_macros(macro, conversation)
    model = macro.split('.')[0]
    macro_value = macro.split('.')[1]
    macro_attribute = macro_value == 'custom_attributes' ? macro.split('.')[2] : nil
    case model
    when 'agent'
      format_agent_macros(conversation, macro_value)
    when 'contact'
      format_contact_macros(conversation, macro_value, macro_attribute)
    when 'account'
      format_account_macros(conversation, macro_value)
    end
  end

  def format_agent_macros(conversation, macro_value)
    return '' if conversation.blank?

    macro_present = conversation.assignee.has_attribute?(macro_value)
    macro_value = conversation.assignee[macro_value].presence || ''
    macro_present ? macro_value : ''
  end

  def format_contact_macros(conversation, macro_value, macro_attribute)
    return '' if conversation.blank?

    macro_present = conversation.contact.has_attribute?(macro_value)
    macro_value = if macro_attribute.present?
                    conversation.contact[macro_value][macro_attribute].presence || ''
                  else
                    conversation.contact[macro_value].presence || ''
                  end
    macro_present ? macro_value : ''
  end

  def format_account_macros(conversation, macro_value)
    return '' if conversation.blank?

    macro_present = conversation.account.has_attribute?(macro_value)
    macro_value = conversation.account[macro_value].presence || ''
    macro_present ? macro_value : ''
  end

  def string_between_markers(content)
    macros = []
    message_string = content.split('}}')
    message_string.each do |string|
      macros << string.split('{{').last
    end
    macros
  end
end
