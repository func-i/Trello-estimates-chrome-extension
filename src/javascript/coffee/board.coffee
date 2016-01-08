app = window.trelloEstimationApp
serverURL       = app.serverURL
ajaxCalls       = app.ajaxCalls
ajaxErrorAlert  = app.ajaxErrorAlert

boardPattern  = /^https:\/\/trello.com\/b\/(\S+)\/(\S+)$/

boardCards =
  estimates: []
  trackings: []

cardStatsHtml = (stats)->
  "<span class='card-fi-estimate'>estimate: #{stats.estimate}</span> | " +
  "<span class='card-fi-tracked'>tracked: #{stats.tracked}</span>"

showUpdatedCards = (cards)->
  cardTitles = $(".list-card-title")

  for id, stats of cards
    cardTitle = cardTitles.filter("a[href^='/c/#{id}/']")
    statsHtml = cardStatsHtml(stats)

    statsDiv  = cardTitle.next(".card-fi-stats")
    if statsDiv.length == 0
      statsHtml = "<div class='card-fi-stats'>" + statsHtml + "</div>"
      cardTitle.append(statsHtml)
    else
      statsDiv.empty().append(statsHtml)
  
updateCards = (response)->
  oldCards = JSON.parse(JSON.stringify(boardCards))
  showUpdatedCards(
    "59Ye2V1l":
      estimate: 4.5
      tracked: 1.2
    "UOggq4d8":
      estimate: 3.2
      tracked: 4.8
  )

getCardsOnBoard = ()->
  ajaxCalls.push $.ajax "#{serverURL}/estimations",
    data:
      board_id: app.getTargetId(boardPattern)
      member_name: app.getUsername()
    success: updateCards
    error: ajaxErrorAlert

### App-level functions ###

app.boardIsOpen = ()->
  document.URL.indexOf("trello.com/b/") >= 0

app.loadBoard = ()->
  getCardsOnBoard()
