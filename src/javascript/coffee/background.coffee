chrome.runtime.onMessage.addListener  (request, sender, sendResponse)->
  if request.action == "getEstimation"
    $.ajax "http://localhost:3000/estimations",
      data:
        boardId: request.boardId
        cardId: request.cardId
        email: "goesmeira@gmail.com"
      async: false,
      success: (response)->
        sendResponse estimation: response


