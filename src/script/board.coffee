board =
  urlPattern: /^https:\/\/trello.com\/b\/(\S+)\/(\S+)$/

  cards: {}

  # compare the estimated/tracked times from server with the cards' stats
  # on client side. return the cards whose stats have changed
  compareCardStats: (oldCards, newCards) ->
    diffCards = {}
    for id, stats of newCards
      oldStats = oldCards[id]

      if !oldStats ||
         oldStats.estimate != stats.estimate || oldStats.tracked != stats.tracked
        diffCards[id] = stats
    console.log(diffCards)
    diffCards

  buildStatsHtml: (stats) ->
    html = "["
    html += "#{stats.estimate} hrs" if stats.estimate
    html += " / "
    html += "#{stats.tracked} hrs" if stats.tracked
    html += "]"

  addCardStats: (cardTitle, stats) ->
    statsDiv  = cardTitle.next(".card-fi-stats")
    statsHtml = this.buildStatsHtml(stats)

    if statsDiv.length == 0
      statsHtml = "<div class='card-fi-stats'>" + statsHtml + "</div>"
      cardTitle.after(statsHtml)
    else
      statsDiv.empty().append(statsHtml)

  setCardBackground: (cardTitle, stats) ->
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

  showUpdatedCards: (cards) ->
    cardTitles = $(".list-card-title")

    for id, stats of cards
      cardTitle = cardTitles.filter("a[href^='/c/#{id}/']")
      this.addCardStats(cardTitle, stats)
      this.setCardBackground(cardTitle, stats)

  calcListStats: (list, cardStatRE) ->
    listEstimate = 0
    listTracked  = 0

    list.find(".card-fi-stats").each (i, cardStat) ->
      stats = $(cardStat).text().match(cardStatRE)
      if stats
        listEstimate += parseFloat(stats[1].slice(0, -4)) if stats[1]
        listTracked  += parseFloat(stats[2].slice(0, -4)) if stats[2]

    { estimate: listEstimate, tracked: listTracked }

  addListStats: (elemAbove, listStats) ->
    statsDiv  = elemAbove.next(".list-fi-stats")
    statsHtml = this.buildStatsHtml(listStats)

    if statsDiv.length == 0
      statsHtml = "<div class='list-fi-stats'>" + statsHtml + "</div>"
      elemAbove.after(statsHtml)
    else
      statsDiv.empty().append(statsHtml)

  updateLists: () ->
    cardStatRE = /^\[(\d*\.?\d+ hrs)? \/ (\d*\.?\d+ hrs)?\]$/

    $(".list.js-list-content").each (index, listElem) =>
      list = $(listElem)
      elemAbove = list.find(".list-header-num-cards")
      listStats = this.calcListStats(list, cardStatRE)
      this.addListStats(elemAbove, listStats)

  updateCards: (response) ->
    _this       = board
    oldCards    = JSON.parse(JSON.stringify(_this.cards))
    _this.cards = response
    diffCards   = _this.compareCardStats(oldCards, _this.cards)
    _this.showUpdatedCards(diffCards)
    _this.updateLists()

  getCardsOnBoard: () ->
    ajaxCall = $.ajax "#{app.serverURL}/estimations",
      data:
        board_id: app.getTargetId(@urlPattern)
        member_name: app.getUsername()
      success: this.updateCards
      error: app.ajaxErrorAlert

    app.ajaxCalls.push ajaxCall

  load: () ->
    this.getCardsOnBoard()

app.board = board
