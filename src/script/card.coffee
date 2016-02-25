card =
  urlPattern: /^https:\/\/trello.com\/c\/(\S+)\/(\S+)$/

  addEstimationButton: (html) ->
    sidebar = $(".window-sidebar")
    actions = sidebar.children(".other-actions") # only board owner
    if actions.length == 0
      actions = sidebar.children(".window-module").eq(0)

    actions.children(".u-clearfix").prepend(html)
    estimationModal.load() if $("#estimation_dialog").length == 0

    $(".js-add-estimation-menu").on "click", () ->
      $("#estimation_dialog").dialog("open")

  loadEstimationButton: () ->
    htmlPath = chrome.extension.getURL("#{app.htmlDir}/card_estimation_btn.html")
    ajaxCall = $.ajax htmlPath,
      dataType: "html"
      success: this.addEstimationButton

    app.ajaxCalls.push ajaxCall

  cardUnderestimated: () ->
    $("#estimation_progress").addClass("bar-danger")
    $("#estimation_progress").css("width", "100%")

  cardInProgress: (trackedRatio) ->
    $("#estimation_progress").css("width", "#{trackedRatio}%")
    $("#estimation_progress").closest(".progress").attr("title", "Card #{trackedRatio.toFixed(2)}% done")

  loadTimeBar: (trackedTime, estimatedTime) ->
    if trackedTime > estimatedTime
      this.cardUnderestimated()
    else
      trackedRatio = (100 * trackedTime) / estimatedTime
      this.cardInProgress(trackedRatio)

  totalEstimation: (estimations) ->
    reduce_func = (total, estimation) ->
      if estimation.is_manager == null || estimation.is_manager == false
        total + estimation.user_time
      else
        total
    estimations.reduce(reduce_func, 0)

  insertEstimation: (estimation) ->
    is_manager = ""
    is_manager = "(M)" if estimation.is_manager

    html = "<tr><td>#{is_manager} #{estimation.user_name}</td><td>#{estimation.user_time}</td></tr>"
    $(".estimations").find("tbody").append(html)

  populateEstimationSection: (response) ->
    _this = card
    estimatedTime = _this.totalEstimation(response.estimations)
    _this.loadTimeBar(response.total_tracked_time, estimatedTime)

    for estimation in response.estimations
      _this.insertEstimation(estimation)

    $("#floatingCirclesG").hide()
    $("#estimations_content").show()

    $("#estimated_time_span")
      .text("Estimated Total: #{estimatedTime}")
      .css("font-weight", "bold")

    $("#tracked_time_span")
      .text("Tracked Total: #{response.total_tracked_time}")
      .css("font-weight", "bold")

  getEstimations: () ->
    ajaxCall = $.ajax "#{app.serverURL}/estimations",
      data:
        card_id: app.getTargetId(@urlPattern)
        member_name: app.getUsername()
      success: this.populateEstimationSection
      error: app.ajaxErrorAlert

    app.ajaxCalls.push ajaxCall

  loadEstimationsList: () ->
    htmlPath = chrome.extension.getURL("#{app.htmlDir}/estimations.html")
    ajaxCall = $.ajax htmlPath,
      dataType: "html"
      success: (html) =>
        $(".card-detail-data").prepend(html)
        this.getEstimations()

    app.ajaxCalls.push ajaxCall

  load: () ->
    this.loadEstimationButton()
    this.loadEstimationsList()

app.card = card
