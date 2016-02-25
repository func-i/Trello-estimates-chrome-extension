(function() {
  var app, board, card, estimationModal;

  app = {
    serverURL: "https://estimation-fi.herokuapp.com",
    htmlDir: "dist/html",
    ajaxCalls: [],
    ajaxErrorAlert: function(jqXHR) {
      return alert("Error: " + jqXHR.responseText);
    },
    abortAjaxCalls: function() {
      var ajaxCall, i, len, ref, results;
      ref = this.ajaxCalls;
      results = [];
      for (i = 0, len = ref.length; i < len; i++) {
        ajaxCall = ref[i];
        results.push(ajaxCall.abort());
      }
      return results;
    },
    getTargetId: function(targetPattern) {
      return document.URL.match(targetPattern)[1];
    },
    getUsername: function() {
      var beginParenthesis, endParenthesis, userFullName;
      userFullName = $.trim(this.getMemberTag().attr("title"));
      beginParenthesis = userFullName.lastIndexOf("(");
      endParenthesis = userFullName.lastIndexOf(")");
      userFullName = userFullName.substr(beginParenthesis + 1);
      return userFullName.substr(0, userFullName.length - 1);
    },
    getMemberTag: function() {
      var memberTag;
      memberTag = $(".header-member").find(".member-initials");
      if (memberTag.length === 0) {
        memberTag = $(".header-member").find(".member-avatar");
      }
      return memberTag;
    },
    boardIsOpen: function() {
      return document.URL.indexOf("trello.com/b/") >= 0;
    },
    cardIsOpen: function() {
      return document.URL.indexOf("trello.com/c/") >= 0;
    }
  };

  window.trelloEstimationApp = app;

  board = {
    urlPattern: /^https:\/\/trello.com\/b\/(\S+)\/(\S+)$/,
    cards: {},
    compareCardStats: function(oldCards, newCards) {
      var diffCards, id, oldStats, stats;
      diffCards = {};
      for (id in newCards) {
        stats = newCards[id];
        oldStats = oldCards[id];
        if (!oldStats || oldStats.estimate !== stats.estimate || oldStats.tracked !== stats.tracked) {
          diffCards[id] = stats;
        }
      }
      console.log(diffCards);
      return diffCards;
    },
    cardStatsHtml: function(stats) {
      var html;
      html = "[";
      if (stats.estimate) {
        html += stats.estimate + " hrs";
      }
      html += " / ";
      if (stats.tracked) {
        html += stats.tracked + " hrs";
      }
      return html += "]";
    },
    addCardStats: function(cardTitle, stats) {
      var statsDiv, statsHtml;
      statsDiv = cardTitle.next(".card-fi-stats");
      statsHtml = this.cardStatsHtml(stats);
      if (statsDiv.length === 0) {
        statsHtml = "<div class='card-fi-stats'>" + statsHtml + "</div>";
        return cardTitle.after(statsHtml);
      } else {
        return statsDiv.empty().append(statsHtml);
      }
    },
    setCardBackground: function(cardTitle, stats) {
      var card, lowerBound, upperBound;
      card = cardTitle.parent();
      lowerBound = stats.estimate * 0.85;
      upperBound = stats.estimate * 1.15;
      card.removeClass("fi-card-estimate fi-card-warning fi-card-overtime");
      if (stats.estimate) {
        if (!stats.tracked || stats.tracked < lowerBound) {
          return card.addClass("fi-card-estimate");
        } else if (stats.tracked > upperBound) {
          return card.addClass("fi-card-overtime");
        } else {
          return card.addClass("fi-card-warning");
        }
      }
    },
    showUpdatedCards: function(cards) {
      var cardTitle, cardTitles, id, results, stats;
      cardTitles = $(".list-card-title");
      results = [];
      for (id in cards) {
        stats = cards[id];
        cardTitle = cardTitles.filter("a[href^='/c/" + id + "/']");
        this.addCardStats(cardTitle, stats);
        results.push(this.setCardBackground(cardTitle, stats));
      }
      return results;
    },
    updateCards: function(response) {
      var _this, diffCards, oldCards;
      _this = board;
      oldCards = JSON.parse(JSON.stringify(_this.cards));
      _this.cards = response;
      diffCards = _this.compareCardStats(oldCards, _this.cards);
      return _this.showUpdatedCards(diffCards);
    },
    getCardsOnBoard: function() {
      var ajaxCall;
      ajaxCall = $.ajax(app.serverURL + "/estimations", {
        data: {
          board_id: app.getTargetId(this.urlPattern),
          member_name: app.getUsername()
        },
        success: this.updateCards,
        error: app.ajaxErrorAlert
      });
      return app.ajaxCalls.push(ajaxCall);
    },
    load: function() {
      return this.getCardsOnBoard();
    }
  };

  app.board = board;

  card = {
    urlPattern: /^https:\/\/trello.com\/c\/(\S+)\/(\S+)$/,
    addEstimationButton: function(html) {
      var actions, sidebar;
      sidebar = $(".window-sidebar");
      actions = sidebar.children(".other-actions");
      if (actions.length === 0) {
        actions = sidebar.children(".window-module").eq(0);
      }
      actions.children(".u-clearfix").prepend(html);
      if ($("#estimation_dialog").length === 0) {
        estimationModal.load(this);
      }
      return $(".js-add-estimation-menu").on("click", function() {
        return $("#estimation_dialog").dialog("open");
      });
    },
    loadEstimationButton: function() {
      var ajaxCall, htmlPath;
      htmlPath = chrome.extension.getURL(app.htmlDir + "/card_estimation_btn.html");
      ajaxCall = $.ajax(htmlPath, {
        dataType: "html",
        success: this.addEstimationButton
      });
      return app.ajaxCalls.push(ajaxCall);
    },
    cardUnderestimated: function() {
      $("#estimation_progress").addClass("bar-danger");
      return $("#estimation_progress").css("width", "100%");
    },
    cardInProgress: function(trackedRatio) {
      $("#estimation_progress").css("width", trackedRatio + "%");
      return $("#estimation_progress").closest(".progress").attr("title", "Card " + (trackedRatio.toFixed(2)) + "% done");
    },
    loadTimeBar: function(trackedTime, estimatedTime) {
      var trackedRatio;
      if (trackedTime > estimatedTime) {
        return this.cardUnderestimated();
      } else {
        trackedRatio = (100 * trackedTime) / estimatedTime;
        return this.cardInProgress(trackedRatio);
      }
    },
    totalEstimation: function(estimations) {
      var reduce_func;
      reduce_func = function(total, estimation) {
        if (estimation.is_manager === null || estimation.is_manager === false) {
          return total + estimation.user_time;
        } else {
          return total;
        }
      };
      return estimations.reduce(reduce_func, 0);
    },
    insertEstimation: function(estimation) {
      var html, is_manager;
      is_manager = "";
      if (estimation.is_manager) {
        is_manager = "(M)";
      }
      html = "<tr><td>" + is_manager + " " + estimation.user_name + "</td><td>" + estimation.user_time + "</td></tr>";
      return $(".estimations").find("tbody").append(html);
    },
    populateEstimationSection: function(response) {
      var _this, estimatedTime, estimation, i, len, ref;
      _this = card;
      estimatedTime = _this.totalEstimation(response.estimations);
      _this.loadTimeBar(response.total_tracked_time, estimatedTime);
      ref = response.estimations;
      for (i = 0, len = ref.length; i < len; i++) {
        estimation = ref[i];
        _this.insertEstimation(estimation);
      }
      $("#floatingCirclesG").hide();
      $("#estimations_content").show();
      $("#estimated_time_span").text("Estimated Total: " + estimatedTime).css("font-weight", "bold");
      return $("#tracked_time_span").text("Tracked Total: " + response.total_tracked_time).css("font-weight", "bold");
    },
    getEstimations: function() {
      var ajaxCall;
      ajaxCall = $.ajax(app.serverURL + "/estimations", {
        data: {
          card_id: app.getTargetId(this.urlPattern),
          member_name: app.getUsername()
        },
        success: this.populateEstimationSection,
        error: app.ajaxErrorAlert
      });
      return app.ajaxCalls.push(ajaxCall);
    },
    loadEstimationsList: function() {
      var ajaxCall, htmlPath;
      htmlPath = chrome.extension.getURL(app.htmlDir + "/estimations.html");
      ajaxCall = $.ajax(htmlPath, {
        dataType: "html",
        success: (function(_this) {
          return function(html) {
            $(".card-detail-data").prepend(html);
            return _this.getEstimations();
          };
        })(this)
      });
      return app.ajaxCalls.push(ajaxCall);
    },
    load: function() {
      this.loadEstimationButton();
      return this.loadEstimationsList();
    }
  };

  app.card = card;

  estimationModal = {
    card: null,
    buildEstimationObject: function() {
      var estimation;
      return estimation = {
        card_id: app.getTargetId(this.card.urlPattern),
        user_time: $("#estimation_time").val(),
        user_username: app.getUsername(),
        is_manager: false
      };
    },
    closeEstimationModal: function(response) {
      $("#estimation_section").remove();
      this.card.loadEstimationsList();
      $("#estimation_time").val("");
      return $("#estimation_dialog").dialog("close");
    },
    sendEstimation: function() {
      var ajaxCall;
      ajaxCall = $.ajax(app.serverURL + "/estimations", {
        method: "post",
        dataType: "json",
        data: {
          estimation: this.buildEstimationObject()
        },
        success: this.closeEstimationModal,
        error: app.ajaxErrorAlert
      });
      return app.ajaxCalls.push(ajaxCall);
    },
    bindEvents: function() {
      return $("#estimation_modal_btn").click((function(_this) {
        return function(e) {
          e.preventDefault();
          e.stopPropagation();
          _this.sendEstimation();
          return false;
        };
      })(this));
    },
    open: function(html) {
      $("body").append(html);
      estimationModal.bindEvents();
      return $("#estimation_dialog").dialog({
        autoOpen: false,
        modal: true,
        dialogClass: "estimation_custom_dialog",
        title: "Estimate time for this card"
      });
    },
    load: function(card) {
      var ajaxCall, htmlPath;
      this.card = card;
      htmlPath = chrome.extension.getURL(app.htmlDir + "/estimation_modal.html");
      ajaxCall = $.ajax(htmlPath, {
        dataType: "html",
        success: this.open
      });
      return app.ajaxCalls.push(ajaxCall);
    }
  };

}).call(this);
