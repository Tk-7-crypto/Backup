({
    loadData: function (component, object) {
        component.set("v.isLoading", true);
        var limit = component.get("v.limit");
        switch (object) {
            case 'Knowledge__kav':
                var offset = component.get("v.articleOffSet");
                break;
            case 'Case':
                var offset = component.get("v.caseOffSet");
                break;
            case 'FeedItem':
                var offset = component.get("v.groupOffSet");
                break;
        }
        var searchText = component.get("v.searchText");
        var searchForPrd = component.get("v.searchForPrd");
        var action = component.get("c.searchForIds");
        action.setParams({
            searchText: searchText,
            searchForPrd: searchForPrd,
            searchObject: object,
            rowLimit: limit,
            rowOffset: offset
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var datas = response.getReturnValue();
                switch (object) {
                    case 'Knowledge__kav':
                        if ((datas.filter(data => (data.objName === "Knowledge__kav")).length > 0)) {
                            var jsonResult = JSON.stringify(datas);
                            offset = offset + limit;
                            component.set("v.articleOffSet", offset);
                            this.fetchDatas(component, jsonResult);
                        } else {
                            component.set("v.articleLoadMore", false);
                        }
                        break;
                    case 'Case':
                        if ((datas.filter(data => (data.objName === "Case")).length > 0)) {
                            var jsonResult = JSON.stringify(datas);
                            offset = offset + limit;
                            component.set("v.caseOffSet", offset);
                            this.fetchDatas(component, jsonResult);
                        } else {
                            component.set("v.caseLoadMore", false);
                        }
                        break;
                    case 'FeedItem':
                        if ((datas.filter(data => (data.objName === "FeedItem")).length > 0)) {
                            var jsonResult = JSON.stringify(datas);
                            offset = offset + limit;
                            component.set("v.groupOffSet", offset);
                            this.fetchDatas(component, jsonResult);
                        } else {
                            component.set("v.groupLoadMore", false);
                        }
                        break;
                }
            } else if (state === "ERROR") {
                console.log("ERROR: " + JSON.stringify(response.getError()));
            }
            component.set("v.isLoading", false);
        });
        $A.enqueueAction(action);
    },

    fetchDatas: function (component, jsonResult) {
        if (!$A.util.isUndefinedOrNull(jsonResult)) {
            var results = JSON.parse(jsonResult);
            var articleRecords = [];
            var caseRecords = [];
            var groupRecords = [];
            var searchText = component.get("v.searchText");
            const words = searchText.trim().split(/\s+/);
            if (Object.keys(results).length > 0) {
                results.forEach(result => {
                    if (result.objName === 'Knowledge__kav') {
                        result.sobj.fieldUrl = '/support/s/kb?u=' + result.sobj.UrlName;
                        result.sobj.Content = '';
                        if (result.sobj.RecordTypeId === '0126A000000hC38QAE') {
                            if (result.sobj.Content__c)
                                result.sobj.Content = result.sobj.Content__c.replace(/(<([^>]+)>)/ig, '');
                        } else {
                            if (result.sobj.Answer__c)
                                result.sobj.Content = result.sobj.Answer__c.replace(/(<([^>]+)>)/ig, '');
                        }

                        for (let i = 0; i < words.length; i++) {
                            const word = words[i];
                            result.sobj.Title = result.sobj.Title.replaceAll(new RegExp(word, 'ig'), '<mark>' + word + '</mark>');
                            if (result.sobj.Question__c)
                                result.sobj.Question__c = result.sobj.Question__c.replaceAll(new RegExp(word, 'ig'), '<mark>' + word + '</mark>');
                            result.sobj.Content = result.sobj.Content.replaceAll(new RegExp(word, 'ig'), '<mark>' + word + '</mark>');
                        }

                        const blocs = result.sobj.Content.match(/.{0,300}/g);
                        var count = 0;
                        for (let i = 0; i < blocs.length; i++) {
                            const bloc = blocs[i];
                            if ((bloc.match(/mark/g) || []).length > count) {
                                count = (bloc.match(/mark/g) || []).length;
                                result.sobj.Content = bloc;
                            }
                        }

                        if (count < 1)
                            result.sobj.Content = '';

                        articleRecords.push(result.sobj);
                    } else if (result.objName === 'Case') {
                        result.sobj.fieldUrl = '/support/s/case/' + result.id;
                        caseRecords.push(result.sobj);
                    } else if (result.objName === 'FeedItem') {
                        result.sobj.fieldUrl = '/support/s/group/' + result.sobj.ParentId;
                        result.sobj.groupName = result.sobj.Parent.Name;
                        if (result.sobj.BestComment) {
                            var bestComment = result.sobj.BestComment.CommentBody;
                            bestComment = bestComment.replace(/<\/?[^>]+>/ig, " ");
                            result.sobj.bestAnswer = bestComment;
                        }
                        groupRecords.push(result.sobj);
                    }
                });

                var currentCaseData = component.get("v.caseDatas");
                var currentArticleData = component.get("v.articleDatas");
                var currentGroupData = component.get("v.groupDatas");
                if (currentCaseData != null) {
                    caseRecords = currentCaseData.concat(caseRecords);
                }
                if (currentArticleData != null) {
                    articleRecords = currentArticleData.concat(articleRecords);
                }
                if (currentGroupData != null) {
                    groupRecords = currentGroupData.concat(groupRecords);
                }
                component.set("v.caseDatas", caseRecords);
                component.set("v.articleDatas", articleRecords);
                component.set("v.groupDatas", groupRecords);
            } else {
                component.set("v.displayAlert", true);
            }
        }
    }
})