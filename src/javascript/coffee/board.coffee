app = window.trelloEstimationApp
serverURL       = app.serverURL
ajaxCalls       = app.ajaxCalls
ajaxErrorAlert  = app.ajaxErrorAlert

boardPattern  = /^https:\/\/trello.com\/b\/(\S+)\/(\S+)$/

boardCards = {}

cardStatsHtml = (stats)->
  html = ""
  if stats.estimate
    html += "<span class='card-fi-estimate'>estimate: #{stats.estimate}</span>"
    html += " | " if stats.tracked

  if stats.tracked
    html += "<span class='card-fi-tracked'>tracked: #{stats.tracked}</span>"
  html

showUpdatedStats = (cards)->
  cardTitles = $(".list-card-title")

  for id, stats of cards
    cardTitle = cardTitles.filter("a[href^='/c/#{id}/']")
    statsDiv  = cardTitle.next(".card-fi-stats")
    statsHtml = cardStatsHtml(stats)

    if statsDiv.length == 0
      statsHtml = "<div class='card-fi-stats'>" + statsHtml + "</div>"
      cardTitle.append(statsHtml)
    else
      statsDiv.empty().append(statsHtml)

# compare the estimated/tracked times from server with the cards' stats
# on client side. return the cards whose stats have changed 
compareCardStats = (oldCards, newCards)->
  for newId, newStats of newCards
    oldStats = oldCards[newId]
    # if !oldStats || 

  
updateCards = (response)->
  # oldCards    = JSON.parse(JSON.stringify(boardCards))
  # boardCards  = response
  # diffCards   = compareCardStats(oldCards, boardCards)
  # showUpdatedStats(diffCards)
  showUpdatedStats(
    "59Ye2V1l":
      estimate: 4.5
      tracked: 1.2
    "UOggq4d8":
      estimate: 3.2
    "5NbyoIDi":
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
