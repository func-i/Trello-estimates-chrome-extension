chrome.runtime.onMessage.addListener (message, sender, sendResponse)->
  if app.boardIsOpen()
    app.abortAjaxCalls()
    board.load()

  if app.cardIsOpen() && $(".js-add-estimation-menu").length == 0
    app.abortAjaxCalls()
    card.load()
