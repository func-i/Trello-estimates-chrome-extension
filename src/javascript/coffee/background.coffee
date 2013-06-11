saveEstimation = (request, sendResponse)->
  alert "aaa"
  $.ajax "http://localhost:3000/estimations",
         method: "post"
         data:
           estimation: request.estimation
         async: false,
         success: (response)->
           sendResponse estimation: response

getEstimation = (request, sendResponse)->
  $.ajax "http://localhost:3000/estimations",
         data:
           boardId: request.boardId
           cardId: request.cardId
           username: request.username
         async: false,
         success: (response)->
           sendResponse estimation: response

chrome.runtime.onMessage.addListener  (request, sender, sendResponse)->
  switch request.action
    when "getEstimation" then getEstimation(request, sendResponse)
    when "saveEstimation" then saveEstimation(request, sendResponse)


