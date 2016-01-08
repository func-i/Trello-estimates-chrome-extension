// Generated by CoffeeScript 1.4.0
(function() {
  var ajaxCalls, ajaxErrorAlert, app, boardCards, boardPattern, cardStatsHtml, getCardsOnBoard, serverURL, showUpdatedCards, updateCards;

  app = window.trelloEstimationApp;

  serverURL = app.serverURL;

  ajaxCalls = app.ajaxCalls;

  ajaxErrorAlert = app.ajaxErrorAlert;

  boardPattern = /^https:\/\/trello.com\/b\/(\S+)\/(\S+)$/;

  boardCards = {
    estimates: [],
    trackings: []
  };

  cardStatsHtml = function(stats) {
    return ("<span class='card-fi-estimate'>estimate: " + stats.estimate + "</span> | ") + ("<span class='card-fi-tracked'>tracked: " + stats.tracked + "</span>");
  };

  showUpdatedCards = function(cards) {
    var cardTitle, cardTitles, id, stats, statsDiv, statsHtml, _results;
    cardTitles = $(".list-card-title");
    _results = [];
    for (id in cards) {
      stats = cards[id];
      cardTitle = cardTitles.filter("a[href^='/c/" + id + "/']");
      statsHtml = cardStatsHtml(stats);
      statsDiv = cardTitle.next(".card-fi-stats");
      if (statsDiv.length === 0) {
        statsHtml = "<div class='card-fi-stats'>" + statsHtml + "</div>";
        _results.push(cardTitle.append(statsHtml));
      } else {
        _results.push(statsDiv.empty().append(statsHtml));
      }
    }
    return _results;
  };

  updateCards = function(response) {
    var oldCards;
    oldCards = JSON.parse(JSON.stringify(boardCards));
    return showUpdatedCards({
      "59Ye2V1l": {
        estimate: 4.5,
        tracked: 1.2
      },
      "UOggq4d8": {
        estimate: 3.2,
        tracked: 4.8
      }
    });
  };

  getCardsOnBoard = function() {
    return ajaxCalls.push($.ajax("" + serverURL + "/estimations", {
      data: {
        board_id: app.getTargetId(boardPattern),
        member_name: app.getUsername()
      },
      success: updateCards,
      error: ajaxErrorAlert
    }));
  };

  /* App-level functions
  */


  app.boardIsOpen = function() {
    return document.URL.indexOf("trello.com/b/") >= 0;
  };

  app.loadBoard = function() {
    return getCardsOnBoard();
  };

}).call(this);
