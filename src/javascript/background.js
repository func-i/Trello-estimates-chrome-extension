(function() {

  chrome.tabs.onUpdated.addListener(function(tabId, changeInfo, tab) {
    if (changeInfo.status === "complete" && tab.url !== void 0) {
      return chrome.tabs.sendMessage(tabId, tab.url);
    }
  });

}).call(this);
