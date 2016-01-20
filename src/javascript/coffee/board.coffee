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
  html += "#{stats.estimate} hrs" if stats.estimate
  html += " / "
  html += "#{stats.tracked} hrs" if stats.tracked
  html += "]"

addCardStats = (cardTitle, stats)->
  statsDiv  = cardTitle.next(".card-fi-stats")
  statsHtml = cardStatsHtml(stats)

  if statsDiv.length == 0
    statsHtml = "<div class='card-fi-stats'>" + statsHtml + "</div>"
    cardTitle.after(statsHtml)
  else
    statsDiv.empty().append(statsHtml)

setCardBackground = (cardTitle, stats)->
  card = cardTitle.parent()
  lowerBound = stats.estimate * 0.85
  upperBound = stats.estimate * 1.15

  card.removeClass("fi-card-estimate fi-card-warning fi-card-overtime")

  if stats.estimate
    if not stats.tracked or stats.tracked < lowerBound
      card.addClass("fi-card-estimate")
    else if stats.tracked > upperBound
      card.addClass("fi-card-overtime")
    else # stats.tracked between lowerBound and upperBound
      card.addClass("fi-card-warning")

showUpdatedCards = (cards)->
  cardTitles = $(".list-card-title")

  for id, stats of cards
    cardTitle = cardTitles.filter("a[href^='/c/#{id}/']")
    addCardStats(cardTitle, stats)
    setCardBackground(cardTitle, stats)

updateCards = (response)->
  oldCards    = JSON.parse(JSON.stringify(boardCards))
  boardCards  = response
  diffCards   = compareCardStats(oldCards, boardCards)
  showUpdatedCards(diffCards)

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
