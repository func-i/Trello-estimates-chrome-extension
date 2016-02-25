(function() {
  var loadExternal;

  chrome.tabs.onUpdated.addListener(function(tabId, changeInfo, tab) {
    if (changeInfo.status === "complete" && tab.url !== void 0) {
      return chrome.tabs.sendMessage(tabId, {
        runApp: true
      });
    }
  });

  chrome.runtime.onMessage.addListener(function(message, sender, sendResponse) {
    if (message.injectJS) {
      return loadExternal(sendResponse);
    }
  });

  loadExternal = function(callback) {
    var sourceDir;
    sourceDir = "https://raw.githubusercontent.com/func-i/Trello-estimates-chrome-extension/load-files/dist/js/";
    $.ajax(sourceDir + "app.js", {
      success: function(jsCode) {
        return chrome.tabs.executeScript({
          code: jsCode
        }, callback);
      },
      error: function(jqXHR) {
        return alert("Error: " + jqXHR.responseText);
      }
    });
    return true;
  };

}).call(this);
