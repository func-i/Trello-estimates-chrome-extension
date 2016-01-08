boardPattern  = /^https:\/\/trello.com\/b\/(\S+)\/(\S+)$/

boardStats =
  estimates: []
  trackings: []

boardIsOpen = ()->
  document.URL.indexOf("trello.com/b/") >= 0

loadBoard = ()->
  getCardsOnBoard = ()->
    ajaxCalls.push $.ajax "#{serverURL}/estimations",
      data:
        board_id: getTargetId(boardPattern)
        member_name: getUsername()
      success: (response)->
        console.log(response)

  getCardsOnBoard()
