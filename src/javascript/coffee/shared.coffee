window.trelloEstimationApp =
  serverURL: "https://estimation-fi.herokuapp.com"
  # serverURL: "https://localhost:5000"

  ajaxCalls: []

  ajaxErrorAlert: (jqXHR)->
    alert "Error: #{jqXHR.responseText}"

  abortAjaxCalls: ()->
    for ajaxCall in this.ajaxCalls
      ajaxCall.abort()

  # target is board or card
  # returns the shortLink field instead of the Trello id
  getTargetId: (targetPattern)->
    document.URL.match(targetPattern)[1]

  getUsername: ()->
    userFullName = $.trim(this.getMemberTag().attr("title"))
    beginParenthesis = userFullName.lastIndexOf("(")
    endParenthesis = userFullName.lastIndexOf(")")
    userFullName = userFullName.substr(beginParenthesis + 1)
    userFullName.substr(0, userFullName.length - 1)

  # find the span.member-initials or img.member-avatar in the Trello board/card page header
  getMemberTag: ()->
    memberTag = $(".header-member").find(".member-initials")
    if memberTag.length == 0
      memberTag = $(".header-member").find(".member-avatar")
    memberTag
