chrome.runtime.onMessage.addListener (message, sender, sendResponse)->
  if app.boardIsOpen()
    app.abortAjaxCalls()
    loadBoard()

  if app.cardIsOpen() && $(".js-add-estimation-menu").length == 0
    app.abortAjaxCalls()
    loadCard()
