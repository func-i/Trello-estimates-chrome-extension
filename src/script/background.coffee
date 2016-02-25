#
# Script on event (background) page
#

# Send message to content script via tab (page) when the tab is updated
# to run app.js
chrome.tabs.onUpdated.addListener  (tabId, changeInfo, tab) ->
  if changeInfo.status == "complete" && tab.url != undefined
    chrome.tabs.sendMessage tabId, { runApp: true }

# Load app.js from external source
chrome.runtime.onMessage.addListener (message, sender, sendResponse) ->
  loadExternal(sendResponse) if message.injectJS

loadExternal = (callback) ->
  sourceDir = "https://raw.githubusercontent.com/func-i/Trello-estimates-chrome-extension/load-files/dist/js/"

  $.ajax sourceDir + "app.js",
    success: (jsCode) ->
      chrome.tabs.executeScript { code: jsCode }, callback
    error: (jqXHR) ->
      alert "Error: #{jqXHR.responseText}"
