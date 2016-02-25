(function() {
  var cssPath, jsLoaded, jsPath, sourceDir;

  sourceDir = "https://raw.githubusercontent.com/func-i/Trello-estimates-chrome-extension/load-files/dist";

  cssPath = sourceDir + "/css/styles.css";

  jsPath = sourceDir + "/js/app.js";

  jsLoaded = false;

  chrome.runtime.sendMessage({
    loadExternal: true,
    css: cssPath,
    js: jsPath
  }, function(response) {
    return jsLoaded = true;
  });

  chrome.runtime.onMessage.addListener(function(message, sender, sendResponse) {
    debugger;
    var app;
    if (!jsLoaded) {
      return;
    }
    if (!message.runApp) {
      return;
    }
    app = window.trelloEstimationApp;
    if (app.boardIsOpen()) {
      app.abortAjaxCalls();
      app.board.load();
    }
    if (app.cardIsOpen() && $(".js-add-estimation-menu").length === 0) {
      app.abortAjaxCalls();
      return app.card.load();
    }
  });

}).call(this);
