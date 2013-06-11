$()->
  setEstimationTime = (time)->
    $("#estimation_time").val(time)

  loadEstimationForCurrentUser = ()->
    chrome.runtime.sendMessage
      action: "getEstimatio n"
      boardId: "50059cc127cbbd457b7457fd"
      cardId: "5",
      (response)->
        setEstimationTime response.estimation.time if response.estimation

  createBoardEstimationButton = ()->
    $.ajax chrome.extension.getURL("src/html/estimation_btn.html"),
           dataType: 'html'
           success: (html)->
             $(".list-card .badges").each ()->
             $(this).append(html)

  createCardEstimationModal = ()->
    $.ajax chrome.extension.getURL("src/html/estimation_modal.html"),
           dataType: 'html'
           success: (html)->
             $("body").append(html)
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
               loadEstimationForCurrentUser()

  cardDetailsIsOpen = ()->
    document.URL.indexOf("trello.com/card/") >= 0

  generateHTMLCode = ()->
    createBoardEstimationButton()
    createCardEstimationButton() if cardDetailsIsOpen()

  generateHTMLCode()