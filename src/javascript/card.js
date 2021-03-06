// Generated by CoffeeScript 1.10.0
(function() {
  var add_estimation_to_list, ajaxCalls, ajaxErrorAlert, app, bindEstimationModalEvents, buildEstimationObject, calc_total_estimation, cardInProgress, cardPattern, cardUnderestimated, closeEstimationModal, createEstimationButton, getEstimations, loadEstimationButton, loadEstimationModal, loadEstimationTimeTrackerBar, loadEstimationsList, openEstimationModal, populateEstimationSection, sendEstimation, serverURL;

  app = window.trelloEstimationApp;

  serverURL = app.serverURL;

  ajaxCalls = app.ajaxCalls;

  ajaxErrorAlert = app.ajaxErrorAlert;

  cardPattern = /^https:\/\/trello.com\/c\/(\S+)\/(\S+)$/;

  buildEstimationObject = function() {
    var estimation;
    return estimation = {
      card_id: app.getTargetId(cardPattern),
      user_time: $("#estimation_time").val(),
      user_username: app.getUsername(),
      is_manager: false
    };
  };

  closeEstimationModal = function(response) {
    $("#estimation_section").remove();
    loadEstimationsList();
    $("#estimation_time").val("");
    return $("#estimation_dialog").dialog("close");
  };

  sendEstimation = function() {
    return ajaxCalls.push($.ajax(serverURL + "/estimations", {
      method: "post",
      dataType: "json",
      data: {
        estimation: buildEstimationObject()
      },
      success: closeEstimationModal,
      error: ajaxErrorAlert
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

  openEstimationModal = function(html) {
    $("body").append(html);
    bindEstimationModalEvents();
    return $("#estimation_dialog").dialog({
      autoOpen: false,
      modal: true,
      dialogClass: "estimation_custom_dialog",
      title: "Estimate time for this card"
    });
  };

  loadEstimationModal = function() {
    return ajaxCalls.push($.ajax(chrome.extension.getURL("src/html/estimation_modal.html"), {
      dataType: 'html',
      success: openEstimationModal
    }));
  };

  createEstimationButton = function(html) {
    var actions, sidebar;
    sidebar = $(".window-sidebar");
    actions = sidebar.children(".other-actions");
    if (actions.length === 0) {
      actions = sidebar.children(".window-module").eq(0);
    }
    actions.children(".u-clearfix").prepend(html);
    if ($("#estimation_dialog").length === 0) {
      loadEstimationModal();
    }
    return $(".js-add-estimation-menu").on("click", function() {
      return $("#estimation_dialog").dialog("open");
    });
  };

  loadEstimationButton = function() {
    return ajaxCalls.push($.ajax(chrome.extension.getURL("src/html/card_estimation_btn.html"), {
      dataType: 'html',
      success: createEstimationButton
    }));
  };

  cardUnderestimated = function() {
    $("#estimation_progress").addClass("bar-danger");
    return $("#estimation_progress").css("width", "100%");
  };

  cardInProgress = function(total_worked) {
    $("#estimation_progress").css("width", total_worked + "%");
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

  calc_total_estimation = function(estimations) {
    var reduce_func;
    reduce_func = function(total, estimation) {
      if (estimation.is_manager === null || estimation.is_manager === false) {
        return total + estimation.user_time;
      } else {
        return total;
      }
    };
    return estimations.reduce(reduce_func, 0);
  };

  add_estimation_to_list = function(estimation) {
    var html, is_manager;
    is_manager = "";
    if (estimation.is_manager) {
      is_manager = "(M)";
    }
    html = "<tr><td>" + is_manager + " " + estimation.user_name + "</td><td>" + estimation.user_time + "</td></tr>";
    return $(".estimations").find("tbody").append(html);
  };

  populateEstimationSection = function(response) {
    var estimation, i, len, ref, total_estimation;
    total_estimation = calc_total_estimation(response.estimations);
    loadEstimationTimeTrackerBar(response.total_tracked_time, total_estimation);
    ref = response.estimations;
    for (i = 0, len = ref.length; i < len; i++) {
      estimation = ref[i];
      add_estimation_to_list(estimation);
    }
    $("#floatingCirclesG").hide();
    $("#estimations_content").show();
    $("#estimated_time_span").text("Estimated Total: " + total_estimation).css("font-weight", "bold");
    return $("#tracked_time_span").text("Tracked Total: " + response.total_tracked_time).css("font-weight", "bold");
  };

  getEstimations = function() {
    return ajaxCalls.push($.ajax(serverURL + "/estimations", {
      data: {
        card_id: app.getTargetId(cardPattern),
        member_name: app.getUsername()
      },
      success: populateEstimationSection,
      error: ajaxErrorAlert
    }));
  };

  loadEstimationsList = function() {
    return ajaxCalls.push($.ajax(chrome.extension.getURL("src/html/estimations.html"), {
      dataType: 'html',
      success: function(html) {
        $(".card-detail-data").prepend(html);
        return getEstimations();
      }
    }));
  };


  /* App-level functions */

  app.cardIsOpen = function() {
    return document.URL.indexOf("trello.com/c/") >= 0;
  };

  app.loadCard = function() {
    loadEstimationButton();
    return loadEstimationsList();
  };

}).call(this);
