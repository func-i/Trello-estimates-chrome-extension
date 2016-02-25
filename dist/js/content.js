(function() {
  var jsInjected, runApp;

  jsInjected = false;

  runApp = function() {
    var app;
    app = window.trelloEstimationApp;
    if (app.boardIsOpen()) {
      app.abortAjaxCalls();
      app.board.load();
    }
    if (app.cardIsOpen() && $(".js-add-estimation-menu").length === 0) {
      app.abortAjaxCalls();
      return app.card.load();
    }
  };

  chrome.runtime.onMessage.addListener(function(message, sender, sendResponse) {
    if (!message.runApp) {
      return;
    }
    if (jsInjected) {
      return runApp();
    } else {
      return chrome.runtime.sendMessage({
        injectJS: true
      }, function() {
        jsInjected = true;
        console.log("injectJS");
        return runApp();
      });
    }
  });

}).call(this);
