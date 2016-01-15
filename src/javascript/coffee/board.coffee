app = window.trelloEstimationApp
serverURL       = app.serverURL
ajaxCalls       = app.ajaxCalls
ajaxErrorAlert  = app.ajaxErrorAlert

boardPattern  = /^https:\/\/trello.com\/b\/(\S+)\/(\S+)$/

boardCards = {}

# compare the estimated/tracked times from server with the cards' stats
# on client side. return the cards whose stats have changed
compareCardStats = (oldCards, newCards)->
  diffCards = {}
  for id, stats of newCards
    oldStats = oldCards[id]

    if !oldStats ||
       oldStats.estimate != stats.estimate || oldStats.tracked != stats.tracked
      diffCards[id] = stats
  console.log(diffCards)
  diffCards

cardStatsHtml = (stats)->
  html = "["
  if stats.estimate
    html += "<span class='card-fi-estimate'>#{stats.estimate} hrs</span>"
    html += " / " if stats.tracked

  if stats.tracked
    trackClass = "card-fi-tracked"
    if stats.estimate && stats.tracked > stats.estimate
      trackClass += " tracked-over-estimate"
    html += "<span class='#{trackClass}'>#{stats.tracked} hrs</span>"
  html += "]"

showUpdatedStats = (cards)->
  cardTitles = $(".list-card-title")

  for id, stats of cards
    cardTitle = cardTitles.filter("a[href^='/c/#{id}/']")
    statsDiv  = cardTitle.next(".card-fi-stats")
    statsHtml = cardStatsHtml(stats)

    if statsDiv.length == 0
      statsHtml = "<div class='card-fi-stats'>" + statsHtml + "</div>"
      cardTitle.after(statsHtml)
    else
      statsDiv.empty().append(statsHtml)

updateCards = (response)->
  oldCards    = JSON.parse(JSON.stringify(boardCards))
  boardCards  = response
  diffCards   = compareCardStats(oldCards, boardCards)
  showUpdatedStats(diffCards)

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
