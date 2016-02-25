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
    return runApp();
  });

}).call(this);
