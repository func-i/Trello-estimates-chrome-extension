// Generated by CoffeeScript 1.6.3
(function() {
  var ajaxCalls, cardDetailsIsOpen, loadCode, serverURL;

  ajaxCalls = [];

  serverURL = "https://localhost:3000";

  cardDetailsIsOpen = function() {
    return document.URL.indexOf("trello.com/c/") >= 0;
  };

  loadCode = function() {
    var bindEstimationModalEvents, buildEstimationObject, cardInProgress, cardPattern, cardUnderestimated, createCardEstimationButton, createCardEstimationModal, createDisplayEstimations, generateHTMLCode, getCardId, getUsername, loadEstimationTimeTrackerBar, matchPattern, populateEstimationSection, sendEstimation, setEstimationTime, userNamePattern;
    cardPattern = /^https:\/\/trello.com\/c\/(\S+)\/(\S+)$/;
    userNamePattern = /^\(\S*\)/;
    matchPattern = function(string, pattern) {
      return string.match(pattern);
    };
    getCardId = function() {
      return matchPattern(document.URL, cardPattern)[1];
    };
    getUsername = function() {
      var beginParenthesis, endParenthesis, userFullName;
      userFullName = $.trim($(".header-auth").find(".member-avatar").attr("title"));
      beginParenthesis = userFullName.lastIndexOf("(");
      endParenthesis = userFullName.lastIndexOf(")");
      userFullName = userFullName.substr(beginParenthesis + 1);
      return userFullName.substr(0, userFullName.length - 1);
    };
    setEstimationTime = function(time) {
      return $("#estimation_time").val(time);
    };
    buildEstimationObject = function() {
      var estimation;
      return estimation = {
        card_id: getCardId(),
        user_time: $("#estimation_time").val(),
        user_username: getUsername(),
        is_manager: $("#manager_estimation").prop('checked')
      };
    };
    sendEstimation = function() {
      return ajaxCalls.push($.ajax("" + serverURL + "/estimations", {
        method: "post",
        dataType: "json",
        data: {
          estimation: buildEstimationObject()
        },
        async: false,
        success: function(response) {
          $("#estimation_section").remove();
          createDisplayEstimations();
          $("#estimation_time").val("");
          return $("#estimation_dialog").dialog("close");
        },
        error: function(jqXHR, textStatus, errorThrown) {
          return alert("You don't have manager's privilege");
        }
      }));
    };
    bindEstimationModalEvents = function() {
      return $("#estimation_modal_btn").click(function(e) {
        e.preventDefault();
        e.stopPropagation();
        sendEstimation();
        return false;
      });
    };
    createCardEstimationModal = function() {
      return ajaxCalls.push($.ajax(chrome.extension.getURL("src/html/estimation_modal.html"), {
        dataType: 'html',
        success: function(html) {
          $("body").append(html);
          bindEstimationModalEvents();
          return $("#estimation_dialog").dialog({
            autoOpen: false,
            modal: true,
            dialogClass: "estimation_custom_dialog",
            title: "Estimate time for this card"
          });
        }
      }));
    };
    createCardEstimationButton = function() {
      return ajaxCalls.push($.ajax(chrome.extension.getURL("src/html/card_estimation_btn.html"), {
        dataType: 'html',
        success: function(html) {
          $(".other-actions").find(".clearfix").prepend(html);
          if ($("#estimation_dialog").length === 0) {
            createCardEstimationModal();
          }
          return $(".js-add-estimation-menu").on("click", function() {
            return $("#estimation_dialog").dialog("open");
          });
        }
      }));
    };
    cardUnderestimated = function() {
      $("#estimation_progress").addClass("bar-danger");
      return $("#estimation_progress").css("width", "100%");
    };
    cardInProgress = function(total_worked) {
      $("#estimation_progress").css("width", "" + total_worked + "%");
      return $("#estimation_progress").closest(".progress").attr("title", "Card " + (total_worked.toFixed(2)) + "% done");
    };
    loadEstimationTimeTrackerBar = function(total_tracked_time, total_estimation_time) {
      var total_worked;
      if (total_tracked_time > total_estimation_time) {
        return cardUnderestimated();
      } else {
        total_worked = (100 * total_tracked_time) / total_estimation_time;
        return cardInProgress(total_worked);
      }
    };
    populateEstimationSection = function() {
      return ajaxCalls.push($.ajax("" + serverURL + "/estimations", {
        data: {
          cardId: getCardId(),
          member_name: getUsername()
        },
        success: function(response) {
          var estimation, html, is_manager, total_estimation, _i, _len, _ref;
          total_estimation = response.estimations.reduce((function(total, estimation) {
            if (estimation.is_manager === null || estimation.is_manager === false) {
              return total + estimation.user_time;
            } else {
              return total;
            }
          }), 0);
          loadEstimationTimeTrackerBar(response.total_tracked_time, total_estimation);
          _ref = response.estimations;
          for (_i = 0, _len = _ref.length; _i < _len; _i++) {
            estimation = _ref[_i];
            is_manager = "";
            if (estimation.is_manager) {
              is_manager = "(M)";
            }
            html = "<tr><td>" + is_manager + " " + estimation.user_name + "</td><td>" + estimation.user_time + "</td></tr>";
            $(".estimations").find("tbody").append(html);
          }
          $("#floatingCirclesG").hide();
          $("#estimations_content").show();
          $("#estimated_time_span").text("Estimated Time: " + total_estimation).css("font-weight", "bold");
          return $("#tracked_time_span").text("Tracked Time: " + response.total_tracked_time).css("font-weight", "bold");
        }
      }));
    };
    createDisplayEstimations = function() {
      return ajaxCalls.push($.ajax(chrome.extension.getURL("src/html/estimations.html"), {
        dataType: 'html',
        success: function(html) {
          $(".card-detail-metadata").prepend(html);
          return populateEstimationSection();
        }
      }));
    };
    generateHTMLCode = function() {
      createCardEstimationButton();
      return createDisplayEstimations();
    };
    return generateHTMLCode();
  };

  chrome.runtime.onMessage.addListener(function(message, sender, sendResponse) {
    var ajaxCall, _i, _len;
    if (cardDetailsIsOpen() && $(".js-add-estimation-menu").length === 0) {
      for (_i = 0, _len = ajaxCalls.length; _i < _len; _i++) {
        ajaxCall = ajaxCalls[_i];
        ajaxCall.abort();
      }
      return loadCode();
    }
  });

}).call(this);
