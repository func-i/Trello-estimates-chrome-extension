#
# Content script
#

sourceDir = "https://raw.githubusercontent.com/func-i/Trello-estimates-chrome-extension/load-files/dist"
cssPath   = sourceDir + "/css/styles.css"
jsPath    = sourceDir + "/js/app.js"

jsLoaded  = false # whether app.js has been loaded

# Send message to background.js to load CSS and JS files
chrome.runtime.sendMessage
  loadExternal: true
  css:  cssPath
  js:   jsPath
 , (response) ->
  jsLoaded = true

# Run app.js on tab (page) update
chrome.runtime.onMessage.addListener (message, sender, sendResponse) ->
  debugger

  return unless jsLoaded
  return unless message.runApp

  app = window.trelloEstimationApp

  if app.boardIsOpen()
    app.abortAjaxCalls()
    app.board.load()

  if app.cardIsOpen() && $(".js-add-estimation-menu").length == 0
    app.abortAjaxCalls()
    app.card.load()
