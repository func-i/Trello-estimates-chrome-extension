chrome.tabs.onUpdated.addListener  (tabId, changeInfo, tab)->
  if changeInfo.status == "complete" && tab.url != undefined
    chrome.tabs.sendMessage tabId, tab.url