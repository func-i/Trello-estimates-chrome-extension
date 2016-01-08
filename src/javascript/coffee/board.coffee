app = window.trelloEstimationApp
serverURL = app.serverURL
ajaxCalls = app.ajaxCalls

boardPattern  = /^https:\/\/trello.com\/b\/(\S+)\/(\S+)$/

boardStats =
  estimates: []
  trackings: []

getCardsOnBoard = ()->
  ajaxCalls.push $.ajax "#{serverURL}/estimations",
    data:
      board_id: app.getTargetId(boardPattern)
      member_name: app.getUsername()
    success: (response)->
      console.log(response)

### App-level functions ###
 
app.boardIsOpen = ()->
  document.URL.indexOf("trello.com/b/") >= 0

app.loadBoard = ()->
  getCardsOnBoard()
