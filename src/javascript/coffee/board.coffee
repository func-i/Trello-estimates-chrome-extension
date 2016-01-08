app = window.trelloEstimationApp
serverURL = app.serverURL
ajaxCalls = app.ajaxCalls

boardPattern  = /^https:\/\/trello.com\/b\/(\S+)\/(\S+)$/

boardStats =
  estimates: []
  trackings: []

app.boardIsOpen = ()->
  document.URL.indexOf("trello.com/b/") >= 0

app.loadBoard = ()->
  getCardsOnBoard = ()->
    ajaxCalls.push $.ajax "#{serverURL}/estimations",
      data:
        board_id: app.getTargetId(boardPattern)
        member_name: app.getUsername()
      success: (response)->
        console.log(response)

  getCardsOnBoard()
