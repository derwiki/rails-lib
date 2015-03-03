module AgentDetection
  def user_agent
    request.headers['HTTP_USER_AGENT']
  end

  MOBILE_UA_RE = /\b(?:android|iphone|ipod|blackberry|windows phone)\b/i
  def mobile_user_agent?(user_agent_string = user_agent)
    return @mobile_user_agent unless @mobile_user_agent.nil?
    @mobile_user_agent = (MOBILE_UA_RE =~ user_agent_string).present?
  end

  TABLET_UA_RE = /\b(?:ipad)\b/i
  def tablet_user_agent?(user_agent_string = user_agent)
    return @tablet_user_agent unless @tablet_user_agent.nil?
    @tablet_user_agent = (TABLET_UA_RE =~ user_agent_string).present?
  end

  IOS_UA_RE = /\b(?:iphone|ipod|ipad)\b/i
  def ios_user_agent?(user_agent_string = user_agent)
    return @ios_user_agent unless @ios_user_agent.nil?
    @ios_user_agent = (IOS_UA_RE =~ user_agent_string).present?
  end
end
