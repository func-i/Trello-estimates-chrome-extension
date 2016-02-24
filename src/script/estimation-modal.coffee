# Estimation Modal on each Trello Card
estimationModal =
  card: null

  buildEstimationObject: () ->
    estimation =
      card_id: app.getTargetId(@card.urlPattern)
      user_time: $("#estimation_time").val()
      user_username: app.getUsername()
      # is_manager: $("#manager_estimation").prop("checked")
      is_manager: false

  closeEstimationModal: (response) ->
    $("#estimation_section").remove()
    @card.loadEstimationsList()
    $("#estimation_time").val("")
    $("#estimation_dialog").dialog("close")

  sendEstimation: () ->
    ajaxCall = $.ajax "#{app.serverURL}/estimations",
      method: "post"
      dataType: "json"
      data:
        estimation: this.buildEstimationObject()
      success: this.closeEstimationModal
      error: app.ajaxErrorAlert

    app.ajaxCalls.push ajaxCall

  bindEvents: () ->
    $("#estimation_modal_btn").click (e) =>
      e.preventDefault()
      e.stopPropagation()
      this.sendEstimation()
      false

  open: (html) ->
    $("body").append(html)
    estimationModal.bindEvents()

    $("#estimation_dialog").dialog
      autoOpen: false
      modal: true
      dialogClass: "estimation_custom_dialog"
      title: "Estimate time for this card"

  load: (card) ->
    @card     = card
    htmlPath  = chrome.extension.getURL("#{app.htmlDir}/estimation_modal.html")
    ajaxCall  = $.ajax htmlPath,
      dataType: "html"
      success: this.open

    app.ajaxCalls.push ajaxCall

