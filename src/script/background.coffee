#
# Script on event (background) page
#

# Load styles.css and content.js from external source and inject them
# into Trello page
chrome.runtime.onMessage.addListener (message, sender, sendResponse) ->
  debugger
  return unless message.loadExternal

  chrome.tabs.insertCSS null, { file: message.css }

  chrome.tabs.executeScript null, { file: message.js }, sendResponse


# Send message to content script via tab (page) when the tab is updated
# to run app.js
chrome.tabs.onUpdated.addListener  (tabId, changeInfo, tab) ->
  if changeInfo.status == "complete" && tab.url != undefined
    chrome.tabs.sendMessage tabId, { runApp: true }

