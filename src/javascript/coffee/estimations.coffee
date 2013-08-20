ajaxCalls = []
serverURL = "http://estimation-fi.herokuapp.com"

cardDetailsIsOpen = ()->
  document.URL.indexOf("trello.com/c/") >= 0

loadCode = ()->
  cardPattern = /^https:\/\/trello.com\/c\/(\S+)\/(\S+)$/
  userNamePattern = /^\(\S*\)/

  matchPattern = (string, pattern)->
    string.match(pattern)

  getBoardId = ()->
    matchPattern(document.URL, cardPattern)[1]

  getCardId = ()->
    matchPattern(document.URL, cardPattern)[2]

  getUsername = ()->
    #TODO: REGEX NEEDS TO BE CHANGED LATER
    userFullName = $.trim($(".header-auth").find(".member-avatar").attr("title"))
    #  matchPattern(userFullName, userNamePattern)
    beginParenthesis = userFullName.lastIndexOf("(")
    endParenthesis = userFullName.lastIndexOf(")")
    userFullName = userFullName.substr(beginParenthesis + 1)
    userFullName.substr(0, userFullName.length - 1)

  setEstimationTime = (time)->
    $("#estimation_time").val(time)

  buildEstimationObject = ()->
    estimation =
      board_id: getBoardId()
      card_id: getCardId()
      user_time: $("#estimation_time").val()
      user_username: getUsername()
      is_manager: $("#manager_estimation").prop('checked')

  sendEstimation = ()->
    ajaxCalls.push $.ajax "#{serverURL}/estimations",
                          method: "post"
                          data:
                            estimation: buildEstimationObject()
                          async: false,
                          success: (response)->
                            $("#estimation_section").remove()
                            createDisplayEstimations()
                            $("#estimation_time").val("")
                            $("#estimation_dialog").dialog("close")
                          error: (jqXHR, textStatus, errorThrown)->
                            alert textStatus
                            alert "You don't have manager's privilege"


  bindEstimationModalEvents=()->
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
                            $(".other-actions").find(".clearfix").prepend(html)
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
                            boardId: getBoardId()
                            cardId: getCardId()
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

                            $("#estimated_time_span").text("Estimated Time: #{total_estimation}")
                            $("#tracked_time_span").text("Tracked Time: #{response.total_tracked_time}")

  createDisplayEstimations = ()->
    ajaxCalls.push $.ajax chrome.extension.getURL("src/html/estimations.html"),
                          dataType: 'html'
                          success: (html)->
                            $(".card-detail-metadata").prepend(html)
                            populateEstimationSection()

  generateHTMLCode = ()->
    createCardEstimationButton()
    createDisplayEstimations()

  generateHTMLCode()

chrome.runtime.onMessage.addListener (message, sender, sendResponse)->
  if cardDetailsIsOpen() && $(".js-add-estimation-menu").length == 0
    for ajaxCall in ajaxCalls
      ajaxCall.abort()
    loadCode()

