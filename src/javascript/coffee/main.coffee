chrome.runtime.onMessage.addListener (message, sender, sendResponse)->
  if boardIsOpen()
    abortAjaxCalls
    loadBoard()

  if cardDetailsIsOpen() && $(".js-add-estimation-menu").length == 0
    abortAjaxCalls
    loadCard()
