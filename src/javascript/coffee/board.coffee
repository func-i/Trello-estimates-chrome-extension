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
    html += "#{stats.estimate} hrs"
    html += " / " if stats.tracked

  if stats.tracked
    html += "#{stats.tracked} hrs"
  html += "]"

addCardStats = (cardTitle, stats)->
  statsDiv  = cardTitle.next(".card-fi-stats")
  statsHtml = cardStatsHtml(stats)

  if statsDiv.length == 0
    statsHtml = "<div class='card-fi-stats'>" + statsHtml + "</div>"
    cardTitle.after(statsHtml)
  else
    statsDiv.empty().append(statsHtml)

# add one of "fi-card-estimate fi-card-warning fi-card-overtime" to the card and
# remove all other classes. Or add none and remove all
assignCardClass = (card, cardClass)->
  classArr = ["fi-card-estimate", "fi-card-warning", "fi-card-overtime"]
  if cardClass
    # remove cardClass from classAarr
    classArr.splice(classArr.indexOf(cardClass), 1)
    card.addClass(cardClass)

  card.removeClass(classArr.join(" "))

setCardBackground = (cardTitle, stats)->
  card = cardTitle.parent()
  lowerBound = stats.estimate * 0.85
  upperBound = stats.estimate * 1.15

  if stats.estimate
    if not stats.tracked or stats.tracked < lowerBound
      assignCardClass(card, "fi-card-estimate")
    else if stats.tracked > upperBound
      assignCardClass(card, "fi-card-overtime")
    else # stats.tracked between lowerBound and upperBound
      assignCardClass(card, "fi-card-warning")

  else # card has no estimate
    assignCardClass(card, null)

showUpdatedCards = (cards)->
  cardTitles = $(".list-card-title")

  for id, stats of cards
    cardTitle = cardTitles.filter("a[href^='/c/#{id}/']")
    addCardStats(cardTitle, stats)
    # setCardBackground(cardTitle, stats)

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
