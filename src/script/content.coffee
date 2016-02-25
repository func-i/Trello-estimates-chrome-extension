#
# Content script
#

# whether app.js has been injected on the current page
jsInjected = false

runApp = () ->
  app = window.trelloEstimationApp

  if app.boardIsOpen()
    app.abortAjaxCalls()
    app.board.load()

  if app.cardIsOpen() && $(".js-add-estimation-menu").length == 0
    app.abortAjaxCalls()
    app.card.load()


# Run app.js on page update message from background.js
chrome.runtime.onMessage.addListener (message, sender, sendResponse) ->
  return unless message.runApp

  runApp() # development only, remove this and uncomment code below to deploy

  # if jsInjected
  #   runApp()
  # else
  #   # Send message to background.js to inject app.js
  #   chrome.runtime.sendMessage { injectJS: true }, () ->
  #     jsInjected = true
  #     runApp()
