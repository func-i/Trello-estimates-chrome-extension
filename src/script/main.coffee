app = window.trelloEstimationApp

chrome.runtime.onMessage.addListener (message, sender, sendResponse)->
  if app.boardIsOpen()
    app.abortAjaxCalls()
    app.loadBoard()

  if app.cardIsOpen() && $(".js-add-estimation-menu").length == 0
    app.abortAjaxCalls()
    app.loadCard()
