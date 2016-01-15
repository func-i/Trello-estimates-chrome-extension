// Generated by CoffeeScript 1.10.0
(function() {
  window.trelloEstimationApp = {
    serverURL: "https://estimation-fi.herokuapp.com",
    ajaxCalls: [],
    ajaxErrorAlert: function(jqXHR) {
      return alert("Error: " + jqXHR.responseText);
    },
    abortAjaxCalls: function() {
      var ajaxCall, i, len, ref, results;
      ref = this.ajaxCalls;
      results = [];
      for (i = 0, len = ref.length; i < len; i++) {
        ajaxCall = ref[i];
        results.push(ajaxCall.abort());
      }
      return results;
    },
    getTargetId: function(targetPattern) {
      return document.URL.match(targetPattern)[1];
    },
    getUsername: function() {
      var beginParenthesis, endParenthesis, userFullName;
      userFullName = $.trim(this.getMemberTag().attr("title"));
      beginParenthesis = userFullName.lastIndexOf("(");
      endParenthesis = userFullName.lastIndexOf(")");
      userFullName = userFullName.substr(beginParenthesis + 1);
      return userFullName.substr(0, userFullName.length - 1);
    },
    getMemberTag: function() {
      var memberTag;
      memberTag = $(".header-member").find(".member-initials");
      if (memberTag.length === 0) {
        memberTag = $(".header-member").find(".member-avatar");
      }
      return memberTag;
    }
  };

}).call(this);
