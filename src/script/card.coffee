app = window.trelloEstimationApp
serverURL       = app.serverURL
ajaxCalls       = app.ajaxCalls
ajaxErrorAlert  = app.ajaxErrorAlert

cardPattern = /^https:\/\/trello.com\/c\/(\S+)\/(\S+)$/

buildEstimationObject = ()->
  estimation =
    card_id: app.getTargetId(cardPattern)
    user_time: $("#estimation_time").val()
    user_username: app.getUsername()
    # is_manager: $("#manager_estimation").prop('checked')
    is_manager: false

closeEstimationModal = (response)->
  $("#estimation_section").remove()
  loadEstimationsList()
  $("#estimation_time").val("")
  $("#estimation_dialog").dialog("close")

sendEstimation = ()->
  ajaxCalls.push $.ajax "#{serverURL}/estimations",
    method: "post"
    dataType: "json"
    data:
      estimation: buildEstimationObject()
    success: closeEstimationModal
    error: ajaxErrorAlert

bindEstimationModalEvents = ()->
  $("#estimation_modal_btn").click (e)->
    e.preventDefault()
    e.stopPropagation()
    sendEstimation()
    false

openEstimationModal = (html)->
  $("body").append(html)
  bindEstimationModalEvents()

  $("#estimation_dialog").dialog
    autoOpen: false
    modal: true
    dialogClass: "estimation_custom_dialog"
    title: "Estimate time for this card"

loadEstimationModal = ()->
  ajaxCalls.push $.ajax chrome.extension.getURL("dist/html/estimation_modal.html"),
    dataType: 'html'
    success: openEstimationModal

createEstimationButton = (html)->
  sidebar = $(".window-sidebar")
  actions = sidebar.children(".other-actions") # only board owner
  if actions.length == 0
    actions = sidebar.children(".window-module").eq(0)

  actions.children(".u-clearfix").prepend(html)
  loadEstimationModal() if $("#estimation_dialog").length == 0

  $(".js-add-estimation-menu").on "click", ()->
    $("#estimation_dialog").dialog("open")

loadEstimationButton = ()->
  ajaxCalls.push $.ajax chrome.extension.getURL("dist/html/card_estimation_btn.html"),
    dataType: 'html'
    success: createEstimationButton

cardUnderestimated = ()->
  $("#estimation_progress").addClass("bar-danger")
  $("#estimation_progress").css("width", "100%")

cardInProgress = (total_worked)->
  $("#estimation_progress").css("width", "#{total_worked}%")
  $("#estimation_progress").closest(".progress").attr("title", "Card #{total_worked.toFixed(2)}% done")

loadEstimationTimeTrackerBar = (total_tracked_time, total_estimation_time)->
  if total_tracked_time > total_estimation_time
    cardUnderestimated()
  else
    total_worked = (100 * total_tracked_time) / total_estimation_time
    cardInProgress(total_worked)

calc_total_estimation = (estimations)->
  reduce_func = (total, estimation)->
    if estimation.is_manager == null || estimation.is_manager == false
      total + estimation.user_time
    else
      total
  estimations.reduce(reduce_func, 0)

add_estimation_to_list = (estimation)->
  is_manager = ""
  is_manager = "(M)" if estimation.is_manager

  html = "<tr><td>#{is_manager} #{estimation.user_name}</td><td>#{estimation.user_time}</td></tr>"
  $(".estimations").find("tbody").append(html)

populateEstimationSection = (response)->
  total_estimation = calc_total_estimation(response.estimations)
  loadEstimationTimeTrackerBar(response.total_tracked_time, total_estimation)

  for estimation in response.estimations
    add_estimation_to_list(estimation)

  $("#floatingCirclesG").hide()
  $("#estimations_content").show()

  $("#estimated_time_span")
    .text("Estimated Total: #{total_estimation}")
    .css("font-weight", "bold")

  $("#tracked_time_span")
    .text("Tracked Total: #{response.total_tracked_time}")
    .css("font-weight", "bold")

getEstimations = ()->
  ajaxCalls.push $.ajax "#{serverURL}/estimations",
    data:
      card_id: app.getTargetId(cardPattern)
      member_name: app.getUsername()
    success: populateEstimationSection
    error: ajaxErrorAlert

loadEstimationsList = ()->
  ajaxCalls.push $.ajax chrome.extension.getURL("dist/html/estimations.html"),
    dataType: 'html'
    success: (html)->
      $(".card-detail-data").prepend(html)
      getEstimations()

### App-level functions ###

app.cardIsOpen = ()->
  document.URL.indexOf("trello.com/c/") >= 0

app.loadCard = ()->
  loadEstimationButton()
  loadEstimationsList()
