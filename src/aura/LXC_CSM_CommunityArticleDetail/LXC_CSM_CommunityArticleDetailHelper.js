({
    getArtcilesByIdForCurrentUser: function (component) {
        component.set("v.isLoading", true);
        var partnerURL = component.get("v.partnerURL");
        var action;
        if (partnerURL == true) {
            action = component.get("c.getArtcilesByIdForCurrentPRMUser");
        }
        else {
            action = component.get("c.getArtcilesByIdForCurrentUser");
        }

        action.setParams({
            "articleId": component.get("v.articleId")
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                if (response.getReturnValue() != null) {
                    component.set("v.allowed", true);
                    component.set("v.articleObj", response.getReturnValue());
                    var articleContent = response.getReturnValue().Content__c;
                    var articleQuestion = response.getReturnValue().Question__c;
                    var articleAnswer = response.getReturnValue().Answer__c;
                    var articleTitle = response.getReturnValue().Title;
                    if (partnerURL == true) {
                        if (typeof articleContent !== "undefined") {
                            articleContent = articleContent.replace(/articles\/(\w|\/)*Knowledge/gi, 's/article');
                        }
                        if (typeof articleQuestion !== "undefined") {
                            articleQuestion = articleQuestion.replace(/articles\/(\w|\/)*Knowledge/gi, 's/article');
                        }
                        if (typeof articleAnswer !== "undefined") {
                            articleAnswer = articleAnswer.replace(/articles\/(\w|\/)*Knowledge/gi, 's/article');
                        }
                    } else {
                        articleTitle = this.replaceWithMarks(articleTitle);
                        if (typeof articleContent !== "undefined") {
                            articleContent = articleContent.replace(/support\/articles\/(\w|\/)*Knowledge/gi, 'support/s/article');
                            articleContent = articleContent.replace(/articles\/(\w|\/)*Knowledge/gi, 'support/s/article');
                            articleContent = articleContent.replace(/sfc\/servlet.shepherd/gi, 'support/sfc/servlet.shepherd');
                            articleContent = articleContent.replaceAll(/\[\[video/g, '<video').replaceAll(/video\]\]/g, '></video>');
                            articleContent = this.replaceWithMarks(articleContent);
                        }
                        if (typeof articleQuestion !== "undefined") {
                            articleQuestion = articleQuestion.replace(/support\/articles\/(\w|\/)*Knowledge/gi, 'support/s/article');
                            articleQuestion = articleQuestion.replace(/articles\/(\w|\/)*Knowledge/gi, 'support/s/article');
                            articleQuestion = articleQuestion.replace(/sfc\/servlet.shepherd/gi, 'support/sfc/servlet.shepherd');
                            articleQuestion = articleQuestion.replaceAll(/\[\[video/g, '<video').replaceAll(/video\]\]/g, '></video>');
                            articleQuestion = this.replaceWithMarks(articleQuestion);
                        }
                        if (typeof articleAnswer !== "undefined") {
                            articleAnswer = articleAnswer.replace(/support\/articles\/(\w|\/)*Knowledge/gi, 'support/s/article');
                            articleAnswer = articleAnswer.replace(/articles\/(\w|\/)*Knowledge/gi, 'support/s/article');
                            articleAnswer = articleAnswer.replace(/sfc\/servlet.shepherd/gi, 'support/sfc/servlet.shepherd');
                            articleAnswer = articleAnswer.replaceAll(/\[\[video/g, '<video').replaceAll(/video\]\]/g, '></video>');
                            articleAnswer = this.replaceWithMarks(articleAnswer);
                        }
                    }
                    component.set("v.article", { 'sobjectType': 'Knowledge__kav', 'ArticleNumber': response.getReturnValue().ArticleNumber, 'RecordTypeId': response.getReturnValue().RecordTypeId, 'Content__c': articleContent, 'Question__c': articleQuestion, 'Answer__c': articleAnswer, 'Device__c': response.getReturnValue().Device__c, 'Title': articleTitle, 'LastPublishedDate': response.getReturnValue().LastPublishedDate, 'KnowledgeArticleId': response.getReturnValue().KnowledgeArticleId, 'PRM_Sales_Collateral__c':  response.getReturnValue().PRM_Sales_Collateral__c  });
                } else {
                    component.set("v.allowed", false);
                }
            } else {
                console.log("ERROR", JSON.stringify(response.getError()));
                component.set("v.allowed", false);
            }
            component.set("v.isLoading", false);
        });
        $A.enqueueAction(action);
    },
    
    replaceWithMarks: function (value) {
      const queryParams = new URLSearchParams(window.location.search);
      const searchWords = queryParams.get("searchword");
      if (searchWords) {
        const words = searchWords.split(" ");
        words.forEach(word => {
          const markTag = '<mark>$&</mark>';
          value = value.replace(new RegExp(`(${word})`, 'ig'), markTag);
        });
      }
      return value;
    }

})