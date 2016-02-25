(function() {
  chrome.runtime.onMessage.addListener(function(message, sender, sendResponse) {
    debugger;
    if (!message.loadExternal) {
      return;
    }
    chrome.tabs.insertCSS(null, {
      file: message.css
    });
    return chrome.tabs.executeScript(null, {
      file: message.js
    }, sendResponse);
  });

  chrome.tabs.onUpdated.addListener(function(tabId, changeInfo, tab) {
    if (changeInfo.status === "complete" && tab.url !== void 0) {
      return chrome.tabs.sendMessage(tabId, {
        runApp: true
      });
    }
  });

}).call(this);
