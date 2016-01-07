ajaxCalls = []
# serverURL = "http://estimation-fi.herokuapp.com"
serverURL = "https://localhost:5000"

abortAjaxCalls = ()->
  for ajaxCall in ajaxCalls
    ajaxCall.abort()

boardIsOpen = ()->
  document.URL.indexOf("trello.com/b/") >= 0

cardDetailsIsOpen = ()->
  document.URL.indexOf("trello.com/c/") >= 0

matchPattern = (string, pattern)->
  string.match(pattern)

getUsername = ()->
  #TODO: REGEX NEEDS TO BE CHANGED LATER
  userFullName = $.trim($(".header-member").find(".member-initials").attr("title"))
  #  matchPattern(userFullName, userNamePattern)
  beginParenthesis = userFullName.lastIndexOf("(")
  endParenthesis = userFullName.lastIndexOf(")")
  userFullName = userFullName.substr(beginParenthesis + 1)
  userFullName.substr(0, userFullName.length - 1)

loadBoard = ()->
  console.log("loadBoard")

loadCard = ()->
  cardPattern = /^https:\/\/trello.com\/c\/(\S+)\/(\S+)$/
  userNamePattern = /^\(\S*\)/

  getCardId = ()->
    matchPattern(document.URL, cardPattern)[1]

  setEstimationTime = (time)->
    $("#estimation_time").val(time)

  buildEstimationObject = ()->
    estimation =
      card_id: getCardId()
      user_time: $("#estimation_time").val()
      user_username: getUsername()
      # is_manager: $("#manager_estimation").prop('checked')
      is_manager: false

  sendEstimation = ()->
    ajaxCalls.push $.ajax "#{serverURL}/estimations",
      method: "post",
      dataType: "json",
      data:
        estimation: buildEstimationObject()
      async: false,
      success: (response)->
        $("#estimation_section").remove()
        createDisplayEstimations()
        $("#estimation_time").val("")
        $("#estimation_dialog").dialog("close")
      error: (jqXHR)->
        alert "Error: #{jqXHR.responseText}"

  bindEstimationModalEvents = ()->
    $("#estimation_modal_btn").click (e)->
      e.preventDefault()
      e.stopPropagation()
      sendEstimation()
      false

  createCardEstimationModal = ()->
    ajaxCalls.push $.ajax chrome.extension.getURL("src/html/estimation_modal.html"),
      dataType: 'html'
      success: (html)->
        $("body").append(html)
        bindEstimationModalEvents()
        $("#estimation_dialog").dialog
          autoOpen: false
          modal: true
          dialogClass: "estimation_custom_dialog"
          title: "Estimate time for this card"

  createCardEstimationButton = ()->
    ajaxCalls.push $.ajax chrome.extension.getURL("src/html/card_estimation_btn.html"),
      dataType: 'html'
      success: (html)->
        sidebar = $(".window-sidebar")
        actions = sidebar.children(".other-actions") # only board owner
        if actions.length == 0
          actions = sidebar.children(".window-module").eq(0)
        
        actions.children(".u-clearfix").prepend(html)
        createCardEstimationModal() if $("#estimation_dialog").length == 0
        
        $(".js-add-estimation-menu").on "click", ()->
          $("#estimation_dialog").dialog("open")


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

  populateEstimationSection = ()->
    ajaxCalls.push $.ajax "#{serverURL}/estimations",
      data:
        cardId: getCardId()
        member_name: getUsername()
      success: (response)->
        total_estimation = response.estimations.reduce ((total, estimation)->
          if estimation.is_manager == null || estimation.is_manager == false
            total + estimation.user_time
          else
            total
        ), 0

        loadEstimationTimeTrackerBar(response.total_tracked_time, total_estimation)

        for estimation in response.estimations
          is_manager = ""
          is_manager = "(M)" if estimation.is_manager

          html = "<tr><td>#{is_manager} #{estimation.user_name}</td><td>#{estimation.user_time}</td></tr>"
          $(".estimations").find("tbody").append(html)

        $("#floatingCirclesG").hide()
        $("#estimations_content").show()

        $("#estimated_time_span")
          .text("Estimated Total: #{total_estimation}")
          .css("font-weight", "bold")

        $("#tracked_time_span")
          .text("Tracked Total: #{response.total_tracked_time}")
          .css("font-weight", "bold")


  createDisplayEstimations = ()->
    ajaxCalls.push $.ajax chrome.extension.getURL("src/html/estimations.html"),
      dataType: 'html'
      success: (html)->
        $(".card-detail-data").prepend(html)
        populateEstimationSection()

  generateHTMLCode = ()->
    createCardEstimationButton()
    createDisplayEstimations()

  generateHTMLCode()


chrome.runtime.onMessage.addListener (message, sender, sendResponse)->
  if boardIsOpen()
    abortAjaxCalls
    loadBoard()

  if cardDetailsIsOpen() && $(".js-add-estimation-menu").length == 0
    abortAjaxCalls
    loadCard()
