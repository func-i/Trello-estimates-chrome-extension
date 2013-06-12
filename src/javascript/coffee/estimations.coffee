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

  #  loadEstimationForCurrentUser = ()->
  #    chrome.runtime.sendMessage
  #      action: "getEstimation"
  #      boardId: getBoardId()
  #      cardId: getCardId()
  #      username: getUsername()
  #      (response)->
  #        setEstimationTime response.estimation.time if response.estimation

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
             $("#estimation_dialog").dialog("close")

  createBoardEstimationButton = ()->
    $.ajax chrome.extension.getURL("src/html/estimation_btn.html"),
           dataType: 'html'
           success: (html)->
             $(".list-card .badges").each ()->
             $(this).append(html)

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


  createCardEstimationButton = ()->
    $.ajax chrome.extension.getURL("src/html/card_estimation_btn.html"),
           dataType: 'html'
           success: (html)->
             $(".other-actions").find(".clearfix").prepend(html)
             createCardEstimationModal()
             $(".js-add-estimation-menu").on "click", ()->
               $("#estimation_dialog").dialog("open")
  #               loadEstimationForCurrentUser()

  populateEstimationSection = ()->
    $.ajax "http://localhost:3000/estimations",
           data:
             boardId: getBoardId()
             cardId: getCardId()
           async: false,
           success: (response)->
             for estimation in response
               is_manager = ""
               is_manager = "(M)" if response.is_manager?

               html = "<tr><td>#{is_manager}#{estimation.user_name}</td><td>#{estimation.user_time}</td></tr>"
               $(".estimations").find("tbody").append(html)

  createDisplayEstimations = ()->
    $.ajax chrome.extension.getURL("src/html/estimations.html"),
           dataType: 'html'
           success: (html)->
             $(".card-detail-metadata").prepend(html)
             populateEstimationSection()

  generateHTMLCode = ()->
    createBoardEstimationButton()
    if cardDetailsIsOpen()
      createCardEstimationButton()
      createDisplayEstimations()

  generateHTMLCode()


timer = setInterval(
  ()->
    if $(".other-actions").length > 0
      loadCode()
      clearInterval timer

, 250)

