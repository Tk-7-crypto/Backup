public without sharing class CNT_CSM_CommunityArticleDetail {
    @AuraEnabled(cacheable=true)
    public static Knowledge__kav getArtcilesByIdForCurrentUser(String articleId){
        List<Knowledge__kav> articles = new List<Knowledge__kav>();
        String fields = 'Id, KnowledgeArticleId, ArticleNumber, Case_CategorizationId__c, ProductName__c, Device__c, SubType1__c, SubType2__c, SubType3__c, PublishStatus, Pillar__c, Title, Content__c, Question__c, Answer__c, RecordTypeId, LastPublishedDate';
        String category_conditions = '';
        List<User> users = new List<User>();
        if(UserInfo.getUserType().contains(CON_CSM.S_CUSTOMER_SUCCCESS)) {
            users = new SLT_User().selectContactDetailByUser(new Set<Id> {userInfo.getUserId()}, new Set<String>  {'Contact.Portal_Case_Type__c','Contact.Contact_User_Type__c','AccountId', 'Contact.Remove_KB_Access__c','Contact.KB_Location__c'});
            if (users.size() > 0 && users[0].Contact != null && users[0].AccountId != null && users[0].Contact.Remove_KB_Access__c != true) {
                String pillar = users[0].Contact.Portal_Case_Type__c;
                pillar = '\'' + pillar.replace(';','\',\'') +'\'';
                String userType = users[0].Contact.Contact_User_Type__c;
                String contact_role_conditions = '';
                if (userType == 'Rep User') {
                    contact_role_conditions =' (Contact_Role__c = \'\' or Contact_Role__c = \'Rep User\') and ';
                }
                String KB_Location = users[0].Contact.KB_Location__c;
                String location_condition = '';
                if (KB_Location != null) {
                    KB_Location = '\'' + KB_Location.replace(';','\',\'') +'\'';
                    location_condition = ' OR Location__r.Location__c  in ('+ KB_Location +')';
                }
                String ids ='';
                List<asset> assets = new SLT_Asset().getAssetsWithFilter(new Set<String> {'Product2Id'}, 'AccountId=\''+ users[0].AccountId +'\' AND Status !=\'Obsolete\' AND Product2Id !=\'\'');
                for (Integer i=0; i<assets.size(); i++) {
                    ids += '\''+ assets[i].Product2Id+'\'';
                    if(i < assets.size()-1){
                        ids += ',';
                    }
                }
                if (ids !='') {
                    if(pillar.indexOf('R&D') != -1) {
                        ids += ',\'\'';
                    }
                    category_conditions = 'Product__c in ('+ ids +') and ';
                }
                articles = Database.query('select '+ fields +' from Knowledge__kav where ' + category_conditions + contact_role_conditions + ' Pillar__c in (' + pillar + ') and  Id = \''+ articleId +'\' and PublishStatus =\'Online\' and IsVisibleInCsp = true and Id in  (select Knowledge__c  from Knowledge_Account_RelationShip__c where Account__c =\'' + users[0].AccountId +'\' AND (Location__c = \'\' ' + location_condition + ' )) LIMIT 1');
                if(articles.size()==0) {
                    articles = Database.query('select '+ fields +' from Knowledge__kav where ' + category_conditions + contact_role_conditions + ' Pillar__c in (' + pillar + ') and Id = \''+ articleId +'\' and PublishStatus =\'Online\' and IsVisibleInCsp = true and Id NOT in  (select Knowledge__c  from Knowledge_Account_RelationShip__c) LIMIT 1');
                }
            }
        } else {
            category_conditions = 'Product__r.Available_to_the_Guest_User__c=true and';
            articles = Database.query('select '+ fields +' from Knowledge__kav where ' + category_conditions + ' Id = \''+ articleId +'\' and PublishStatus =\'Online\' and IsVisibleInCsp = true and Id NOT in  (select Knowledge__c  from Knowledge_Account_RelationShip__c) LIMIT 1');   
        }
        return articles[0];
    }


    @AuraEnabled(cacheable=true)
    public static Knowledge__kav getArtcilesByIdForCurrentPRMUser(String articleId)
    {
        List<Knowledge__kav> articles=new SLT_Knowledge().selectByArticleId(articleId);
        return articles[0];
    }
}
