# serverURL = "http://estimation-fi.herokuapp.com"
serverURL = "https://localhost:5000"

ajaxCalls = []

abortAjaxCalls = ()->
  for ajaxCall in ajaxCalls
    ajaxCall.abort()

# target is board or card
# returns the shortLink field instead of the Trello id
getTargetId = (targetPattern)->
  document.URL.match(targetPattern)[1]

getUsername = ()->
  userFullName = $.trim($(".header-member").find(".member-initials").attr("title"))
  beginParenthesis = userFullName.lastIndexOf("(")
  endParenthesis = userFullName.lastIndexOf(")")
  userFullName = userFullName.substr(beginParenthesis + 1)
  userFullName.substr(0, userFullName.length - 1)
