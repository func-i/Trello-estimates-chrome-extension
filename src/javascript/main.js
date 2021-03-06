// Generated by CoffeeScript 1.10.0
(function() {
  var app;

  app = window.trelloEstimationApp;

  chrome.runtime.onMessage.addListener(function(message, sender, sendResponse) {
    if (app.boardIsOpen()) {
      app.abortAjaxCalls();
      app.loadBoard();
    }
    if (app.cardIsOpen() && $(".js-add-estimation-menu").length === 0) {
      app.abortAjaxCalls();
      return app.loadCard();
    }
  });

}).call(this);
