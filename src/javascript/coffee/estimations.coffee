cardDetailsIsOpen = ()->
  document.URL.indexOf("trello.com/card/") >= 0

loadCode = ()->
  cardPattern = /^https:\/\/trello.com\/card\/(\S+)\/(\S+)\/(\d+)$/
  userNamePattern = /^\(\S*\)/

  matchPattern = (string, pattern)->
    string.match(pattern)

  getBoardId = ()->
    matchPattern(document.URL, cardPattern)[2]

  getCardId = ()->
    matchPattern(document.URL, cardPattern)[3]

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

  sendEstimation = ()->
    $.ajax "http://localhost:3000/estimations",
           method: "post"
           data:
             estimation: buildEstimationObject()
           async: false,
           success: (response)->
             $("#estimation_section").remove()
             createDisplayEstimations()
             $("#estimation_time").val("")
             $("#estimation_dialog").dialog("close")

  bindEstimationModalEvents=()->
    $("#estimation_modal_btn").click (e)->
      e.preventDefault()
      e.stopPropagation()
      sendEstimation()
      false

  createCardEstimationModal = ()->
    $.ajax chrome.extension.getURL("src/html/estimation_modal.html"),
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
    $.ajax chrome.extension.getURL("src/html/card_estimation_btn.html"),
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

  loadEstimationTimeTrackerBar = (total_tracked_time, total_estimation_time)->
    if total_tracked_time > total_estimation_time
      cardUnderestimated()
    else
      total_worked = (100*total_tracked_time)/total_estimation_time
      cardInProgress(total_worked)

  bindGeneralEstimationEvents = ()->
    $("#estimation_details").on "click", ()->
      $estimationsSection = $(".estimations")
      if $estimationsSection.css("display") == "none"
        $estimationsSection.show()
        $("#estimation_details").text("Hide Details")
      else
        $estimationsSection.hide()
        $("#estimation_details").text("More Details")

  populateEstimationSection = ()->
    $.ajax "http://localhost:3000/estimations",
           data:
             boardId: getBoardId()
             cardId: getCardId()
           success: (response)->
             total_estimation = response.estimations.reduce ((total, estimation)-> total + estimation.user_time), 0
             total_estimation = total_estimation/ (response.estimations.length * 1.0) if response.estimations.length > 0

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

             bindGeneralEstimationEvents()

  createDisplayEstimations = ()->
    $.ajax chrome.extension.getURL("src/html/estimations.html"),
           dataType: 'html'
           success: (html)->
             $(".card-detail-metadata").prepend(html)
             populateEstimationSection()

  generateHTMLCode = ()->
      createCardEstimationButton()
      createDisplayEstimations()

  generateHTMLCode()

chrome.runtime.onMessage.addListener (message, sender, sendResponse)->
  loadCode() if cardDetailsIsOpen() && $(".js-add-estimation-menu").length == 0

