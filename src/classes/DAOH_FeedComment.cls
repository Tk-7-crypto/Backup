public class DAOH_FeedComment {
    public static void technoCaseDonotSaveFeedComment(List<FeedComment> newList){
        Map<Id,Id> feedCases = new Map<Id,Id>();
        List<FeedItem> feedList = new List<FeedItem>();
        Map<Id,Case> caseMap = new Map<Id,Case>();
        boolean isTechoCase = false;
        Map<Id,Profile> proMap = UTL_GLOBAL.getProfile(new Set<Id> {userInfo.getProfileId()});
        for(FeedComment c : newList) {
            if(proMap.containsKey(userInfo.getProfileId()) && proMap.get(userInfo.getProfileId()).Name != null && !proMap.get(userInfo.getProfileId()).Name.contains(CON_CSM.S_P_SYS_ADMIN) &&  proMap.get(userInfo.getProfileId()).Name != 'IQVIA Salesforce Platform Support' && c.ParentId != null && String.valueOf(c.ParentId).startsWith('500') && c.CommentBody != null && c.CommentType == 'TextComment' ){
                feedCases.put(c.ParentId,c.FeedItemId);
            }else if(Test.isRunningTest()){
                feedCases.put(c.ParentId,c.FeedItemId);
            }
        }
        if(!feedCases.isEmpty()){
            Set<Id> cases = feedCases.keySet();
            List<Id> ids = feedCases.values();
            caseMap = new SLT_Case().getCaseById(feedCases.keySet(), new Set<String> {'Id','RecordTypeName__c'});
            feedList = Database.query('Select Id, Type, ParentId FROM FeedItem WHERE Type =\'CaseCommentPost\' and Id in :ids and ParentId in : cases');
            if(!feedList.isEmpty() && !caseMap.isEmpty()){
                for(FeedItem c : feedList){
                    if(caseMap.containsKey(c.ParentId) && CON_CSM.S_TECHNO_SOL == caseMap.get(c.ParentId).RecordTypeName__c){
                        isTechoCase = true;
                        break;
                    }
                }
                for(FeedComment c : newList) {
                    if(isTechoCase) c.addError('User not allowed to add Feed Comment');
                }
            }
        }
    
    }
    public static void createJiraComment(List<FeedComment> newList){
        List<FeedItem> feedList = new List<FeedItem>();
        Map<Id,String> feedItemBodyComment = new Map<Id,String>();
        for(FeedComment c : newList) {
            String newJiraComment = c.CommentBody;
            feedItemBodyComment.put(c.FeedItemId,c.CommentBody);
        }

        if(!feedItemBodyComment.isEmpty()){
            Map<Id,Case> caseMap = new Map<Id,Case>();
            Set<Id> caseIds = new Set<Id>();
            Set<Id> ids = feedItemBodyComment.keySet();
            feedList = Database.query('Select Id, Body, ParentId, CreatedById FROM FeedItem WHERE Id in :ids');
            if(!feedList.isEmpty()){
                for(FeedItem f : feedList){
                    caseIds.add(f.ParentId);
                } 
                caseMap = new SLT_Case().getCaseById(caseIds, new Set<String> {'Id','CaseNumber'});

                for (FeedItem f : feedList) {
                    if (f.Body != null) {
                        String urlPattern = 'href="(.*?)"';
                        Pattern pattern = Pattern.compile(urlPattern);
                        Matcher matcher = pattern.matcher(f.Body);
                
                        String feedItemBody = feedItemBodyComment.get(f.Id);
                
                        if (f.CreatedById == CON_CSM.S_JIRA_SERVICE_USER_ID && feedItemBody != null && caseMap.containsKey(f.ParentId) && matcher.find()) {
                            Case parentCase = caseMap.get(f.ParentId);
                            if (parentCase != null) {
                                String caseNumber = parentCase.CaseNumber;
                                String url = matcher.group(1);
                                String username = UserInfo.getName();
                                String body = feedItemBody.replace('<p>', '')
                                    .replace('</p>', '\\n')
                                    .replace('<b>', '*')
                                    .replace('</b>', '*')
                                    .replace('<i>', '_')
                                    .replace('</i>', '_');
                                body = 'CSM Comment ' + caseNumber + ', *' + username + '*:\\n' + body;
                                feedItemBodyComment.put(f.Id, url + '~' + body);
                            }
                        } else {
                            feedItemBodyComment.remove(f.Id);
                        }
                    } else {
                        feedItemBodyComment.remove(f.Id);
                    }
                }
            }

            for (String value : feedItemBodyComment.values()) {
                List<String> parts = value.split('~');
                if (parts.size() >= 1) {
                    String urlString = parts[0];
                    URL url = new URL(urlString);
                    String baseUrl = url.getProtocol() + '://' + url.getHost();
                    String key = url.getPath().substringAfter('/browse/');
                    String body = parts[1];
                    String apiUrl = baseUrl + '/rest/api/2/issue/' + key + '/comment';
                    String jsonBodyString = '{"body": "' + body + '"}';
                    if(!Test.isRunningTest()) {
                        sendCommentToJira(apiUrl, jsonBodyString);
                    }
                }
            }

        }

    }
    @future (callout=true)
    public static void sendCommentToJira(String url, String body){
        try {
            SRV_CSM_JiraCallouts.makePostCallout(url, body);
        }catch(System.CalloutException e) {
            System.debug('ERROR to send comment to jira: ' + e);
        }
    }
}