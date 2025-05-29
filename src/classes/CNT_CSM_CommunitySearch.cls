public class CNT_CSM_CommunitySearch {
    public class WRP_CSM_SearchResult {
        @AuraEnabled
        public String id {get; set;}
        @AuraEnabled
        public String objName {get; set;}
        @AuraEnabled
        public SObject sobj {get; set;}
    }
    @AuraEnabled(cacheable=true)
    public static List<WRP_CSM_SearchResult> searchForIds(String searchText, String searchForPrd, String searchObject, Integer rowLimit, Integer rowOffset) {
        List<User> users = new List<User>();
        List<WRP_CSM_SearchResult> srList = new List<WRP_CSM_SearchResult>();
        List<asset> assets = new List<asset>();
        String searchForPrdCond = '';
        String prodIds = '',removeProd = '';
        if(UserInfo.getUserType().contains(CON_CSM.S_CUSTOMER_SUCCCESS)) {
            users = new SLT_User().selectContactDetailByUser(new Set<Id> {userInfo.getUserId()}, new Set<String>  {'ContactId','Contact.Portal_Case_Type__c','Contact.Contact_User_Type__c','AccountId','Contact.Remove_KB_Access__c','Contact.KB_Location__c'});
            if (users.size() > 0 && users[0].Contact != null && users[0].AccountId != null) {
                Set<String> pillarList = new Set<String>(users[0].Contact.Portal_Case_Type__c.split(';'));
                String pillar = users[0].Contact.Portal_Case_Type__c;
                pillar = '\'' + pillar.replace(';','\',\'') +'\'';
                String userType = users[0].Contact.Contact_User_Type__c;
                Set<String> ids = new Set<String>();
                List<Id> prodList = new List<Id>();
                List<Id> rmprodList = new List<Id>();
                List<Id> groupList = new List<Id>();
                if (searchForPrd != '') {
                    searchForPrdCond = ' AND ProductId__c = \''+ searchForPrd+'\' ';
                }
                List<CSM_QI_Data_Portal_Queue_User_details__c> dataList = new SLT_CSMDataPortalQueueUserdetails().getDataWithFilter(new Set<String> {'ProductId__c'},'ProductId__c != null AND Account__c=\''+ users[0].AccountId +'\' AND Type__c =\'Product Level Restriction\' AND ClientContact__c=\''+ users[0].ContactId +'\'' + searchForPrdCond);
                if(dataList != null && !dataList.isEmpty()) {
                    for (Integer i=0; i<dataList.size(); i++) {
                        prodList.add(dataList[i].ProductId__c);
                        prodIds += '\''+ dataList[i].ProductId__c+'\',';
                    }
                    prodIds = prodIds.removeEnd(',');
                    assets = new SLT_Asset().getAssetsWithFilter(new Set<String> {'Product2Id'}, 'AccountId=\''+ users[0].AccountId +'\' AND Status !=\'Obsolete\' AND Product2Id in ('+prodIds+') AND Product2.Pillar__c Includes (' + pillar + ')');
                }else{
                    if (searchForPrd != '') {
                        searchForPrdCond = ' AND Product2Id = \''+ searchForPrd+'\' ';
                    }
                    List<CSM_QI_Case_Categorization__c> prodDataList = new SLT_CaseCategorization().getProductLevelRestrict();
                    for (Integer i=0; i<prodDataList.size(); i++) {
                        rmprodList.add(prodDataList[i].Product__c);
                        removeProd += '\''+ prodDataList[i].Product__c+'\',';
                    }
                    if(removeProd.length()>1) {
                        removeProd = removeProd.removeEnd(',');
                        assets = new SLT_Asset().getAssetsWithFilter(new Set<String> {'Product2Id'}, 'AccountId=\''+ users[0].AccountId +'\' AND Status !=\'Obsolete\' AND Product2Id not in ('+removeProd+')  AND Product2.Pillar__c Includes (' + pillar + ')' +searchForPrdCond);
                    }else{
                        assets = new SLT_Asset().getAssetsWithFilter(new Set<String> {'Product2Id'}, 'AccountId=\''+ users[0].AccountId +'\' AND Status !=\'Obsolete\' AND Product2Id !=\'\' AND Product2.Pillar__c Includes (' + pillar + ')' + searchForPrdCond);
                    }
                }

                for (Integer i=0; i<assets.size(); i++) {
                    ids.add(assets[i].Product2Id);
                }
                if(users[0].Contact.Portal_Case_Type__c.indexOf('R&D') != -1) {
                    ids.add('');
                }
                String contact_role_conditions = '';
                if (userType == 'Rep User') {
                    contact_role_conditions ='(Contact_Role__c = \'\' or Contact_Role__c = \'Rep User\') AND '; 
                }
                String KB_Location = users[0].Contact.KB_Location__c;
                String location_condition = '';
                if (KB_Location != null) {
                    KB_Location = '\'' + KB_Location.replace(';','\',\'') +'\'';
                    location_condition = ' OR Location__r.Location__c  in ('+ KB_Location +')';
                }

                List<List<SObject> > results = new List<List<SObject> >();
                if((searchObject == '' || searchObject == 'Knowledge__kav') && users[0].Contact.Remove_KB_Access__c != true) {
                        String q1 = 'FIND :searchText IN ALL FIELDS RETURNING Knowledge__kav(Id, RecordTypeId, ArticleNumber, Content__c, Question__c, Answer__c, Title, LastPublishedDate, ProductName__c, SubType1__c, SubType2__c, SubType3__c, UrlName, Contact_Role__c, Device__c WHERE Product__c in :ids AND Pillar__c in :pillarList AND PublishStatus =\'Online\' AND Language = \'en_US\' AND IsVisibleInCsp = true AND ' + contact_role_conditions + 'Id in (select Knowledge__c from Knowledge_Account_RelationShip__c where Account__c =\''+ users[0].AccountId +'\' AND (Location__c = \'\' ' + location_condition + ' )) LIMIT '+ rowLimit +' OFFSET ' + rowOffset +' )';         
                        List<List<SObject> > results1 =  search.query(q1); 
                        String q2 = 'FIND :searchText IN ALL FIELDS RETURNING Knowledge__kav(Id, RecordTypeId, ArticleNumber, Content__c, Question__c, Answer__c, Title, LastPublishedDate, ProductName__c, SubType1__c, SubType2__c, SubType3__c, UrlName, Contact_Role__c, Device__c WHERE Product__c in :ids AND Pillar__c in :pillarList AND PublishStatus =\'Online\' AND Language = \'en_US\' AND IsVisibleInCsp = true AND '+ contact_role_conditions + 'Id NOT in (select Knowledge__c from Knowledge_Account_RelationShip__c) LIMIT '+ rowLimit +' OFFSET ' + rowOffset +' )';         
                        List<List<SObject> > results2 =  search.query(q2); 
                        results.addAll(results1);
                        results.addAll(results2);
                }
                if((searchObject == '' || searchObject == 'Case') && prodList != null && !prodList.isEmpty()) {
                    String q3 = 'FIND :searchText IN ALL FIELDS RETURNING Case(Id, CaseNumber, Subject, Status, Priority, ProductName__c, SubType1__c, SubType2__c, SubType3__c WHERE CaseSource__c = \'Customer\' and AssetId != null AND Asset.Product2Id in:prodList AND Asset.Product2Id in:ids LIMIT '+ rowLimit +' OFFSET ' + rowOffset +' )';
                    List<List<SObject> > results3 =  search.query(q3);
                    results.addAll(results3);
                }else if((searchObject == '' || searchObject == 'Case') && !rmprodList.isEmpty()) {
                    String q3 = 'FIND :searchText IN ALL FIELDS RETURNING Case(Id, CaseNumber, Subject, Status, Priority, ProductName__c, SubType1__c, SubType2__c, SubType3__c WHERE CaseSource__c = \'Customer\' and AssetId != null AND Asset.Product2Id NOT in:rmprodList AND Asset.Product2Id in:ids LIMIT '+ rowLimit +' OFFSET ' + rowOffset +' )';
                    List<List<SObject> > results3 =  search.query(q3);
                    results.addAll(results3);
                }else if((searchObject == '' || searchObject == 'Case') && (users[0].Contact.Portal_Case_Type__c.indexOf('R&D') == -1 || pillarList.size() > 1)) {
                    String q3 = 'FIND :searchText IN ALL FIELDS RETURNING Case(Id, CaseNumber, Subject, Status, Priority, ProductName__c, SubType1__c, SubType2__c, SubType3__c WHERE CaseSource__c = \'Customer\' and AssetId != null AND Asset.Product2Id in:ids LIMIT '+ rowLimit +' OFFSET ' + rowOffset +' )';
                    List<List<SObject> > results3 =  search.query(q3);
                    results.addAll(results3);
                }
                if(searchObject == '' || searchObject == 'FeedItem') {
                    for(Product_Group_Relationship__c pgr: [select Id, Collaboration_Group_Id__c from Product_Group_Relationship__c where Product__c in:ids ]) {
                        groupList.add(pgr.Collaboration_Group_Id__c);
                    }
                }
                if(groupList != null && !groupList.isEmpty()) {
                    String q4 = 'FIND :searchText IN ALL FIELDS RETURNING FeedItem (Id, Title, ParentId, BestComment.CommentBody, Parent.Name WHERE Type=\'QuestionPost\' and ParentId in:groupList LIMIT '+ rowLimit +' OFFSET ' + rowOffset +' )';
                    List<List<SObject> > results4 =  search.query(q4);
                    results.addAll(results4);
                }
                
                for (List<SObject> sobjs : results) {
                    for (SObject sobj : sobjs) {
                        WRP_CSM_SearchResult sr = new WRP_CSM_SearchResult();
                        sr.id = sobj.Id;
                        sr.objName = string.valueOf(sobj.Id.getsobjecttype());
                        sr.sobj = sobj;
                        srList.add(sr);
                    }
                }
            }
        } else {
            List<List<SObject> > results = new List<List<SObject> >();
            if (searchForPrd != '') {
                searchForPrdCond = ' AND Product__r.Name = \''+ searchForPrd+'\' ';
            }
            String q1 = 'FIND :searchText IN ALL FIELDS RETURNING Knowledge__kav(Id, RecordTypeId, ArticleNumber, Content__c, Question__c, Answer__c, Title, LastPublishedDate, ProductName__c, SubType1__c, SubType2__c, SubType3__c, UrlName, Contact_Role__c, Device__c WHERE Product__r.Available_to_the_Guest_User__c=true AND PublishStatus =\'Online\' AND Language = \'en_US\' AND IsVisibleInCsp = true '+ searchForPrdCond +' AND Id NOT in (select Knowledge__c from Knowledge_Account_RelationShip__c) LIMIT '+ rowLimit +' OFFSET ' + rowOffset +' )';         
            List<List<SObject> > results1 =  search.query(q1); 
            results.addAll(results1);
            for (List<SObject> sobjs : results) {
                for (SObject sobj : sobjs) {
                    WRP_CSM_SearchResult sr = new WRP_CSM_SearchResult();
                    sr.id = sobj.Id;
                    sr.objName = string.valueOf(sobj.Id.getsobjecttype());
                    sr.sobj = sobj;
                    srList.add(sr);
                }
            }
        }
        return srList;
    }

    @AuraEnabled(cacheable=true)
    public static List<Contact> getUserContact(){
        List<User> users = new List<User>();
        users = new SLT_User().selectById(new Set<Id> {userInfo.getUserId()});
        List<Contact> contacts=new List<Contact>();
        contacts = new SLT_Contact().selectByContactIdList(new Set<Id> {users[0].ContactId}, new Set<String> {'Portal_Case_Type__c','AccountId','Contact_User_Type__c','MikadoServiceLevel__c', 'Remove_KB_Access__c', 'Remove_Case_Creation__c'});
        return contacts;
    }

    @AuraEnabled(cacheable=true)
    public static List<AggregateResult> getProductCommunityTopics(){
        List<AggregateResult> communityTopics = new List<AggregateResult>();
        List<User> users = new List<User>();
        List<Id> removeProd = new List<Id>();
        if(UserInfo.getUserType().contains(CON_CSM.S_CUSTOMER_SUCCCESS) || UserInfo.getUserType().contains(CON_PEP.S_PEP_POWERPARTNER)) {
            users = new SLT_User().selectContactDetailByUser(new Set<Id> {userInfo.getUserId()}, new Set<String> {'Contact.Portal_Case_Type__c','Contact.Account.AccountCountry__c'});
            if (users.size() > 0 && users[0].Contact != null && users[0].Contact.Account != null) {
                String pillar = users[0].Contact.Portal_Case_Type__c;
                pillar = '\'' + pillar.replace(';','\',\'') +'\'';
                List<CSM_QI_Data_Portal_Queue_User_details__c> dataList = new SLT_CSMDataPortalQueueUserdetails().getDataWithFilter(new Set<String> {'ProductId__c'},'ProductId__c != null AND Account__c=\''+ users[0].AccountId +'\' AND Type__c =\'Product Level Restriction\' AND ClientContact__c=\''+ users[0].ContactId +'\'');
                if(dataList != null && !dataList.isEmpty()) {
                    List<Id> prodList = new List<Id>();
                    for(CSM_QI_Data_Portal_Queue_User_details__c s : dataList) {
                        prodList.add(s.ProductId__c);
                    }
                    communityTopics = Database.query('select Id, Community_Topic__r.Name from Product2 where Id in(SELECT Product2Id FROM asset WHERE AccountId=\''+ users[0].AccountId +'\' AND Status !=\'Obsolete\' AND Topic_Visible_in_CSH_Homepage__c = true AND Product2Id in:prodList) and Community_Topic__r.Name !=null and Pillar__c Includes (' + pillar + ') group by Id, Community_Topic__r.Name order by Community_Topic__r.Name  ASC');
                }else{
                    List<CSM_QI_Case_Categorization__c> prodDataList = new SLT_CaseCategorization().getProductLevelRestrict();
                    for(CSM_QI_Case_Categorization__c p : prodDataList) {
                        removeProd.add(p.Product__c);
                    }
                    if(!removeProd.isEmpty()) {
                        communityTopics = Database.query('select Id, Community_Topic__r.Name from Product2 where Id in(SELECT Product2Id FROM asset WHERE AccountId=\''+ users[0].AccountId +'\' AND Status !=\'Obsolete\' AND Topic_Visible_in_CSH_Homepage__c = true and Product2Id not in :removeProd) and Community_Topic__r.Name !=null and Pillar__c Includes (' + pillar + ') group by Id, Community_Topic__r.Name order by Community_Topic__r.Name  ASC');
                    }else{
                        communityTopics = Database.query('select Id, Community_Topic__r.Name from Product2 where Id in(SELECT Product2Id FROM asset WHERE AccountId=\''+ users[0].AccountId +'\' AND Status !=\'Obsolete\' AND Topic_Visible_in_CSH_Homepage__c = true) and Community_Topic__r.Name !=null and Pillar__c Includes (' + pillar + ') group by Id, Community_Topic__r.Name order by Community_Topic__r.Name  ASC');
                    }

                }
            }
        } else {
            List<CSM_QI_Case_Categorization__c> prodDataList = new SLT_CaseCategorization().getProductLevelRestrict();
            for(CSM_QI_Case_Categorization__c p : prodDataList) {
                removeProd.add(p.Product__c);
            }
            if(!removeProd.isEmpty()) {
                communityTopics = Database.query('select Id, Community_Topic__r.Name from Product2 where id not in :removeProd and Available_to_the_Guest_User__c=true and Community_Topic__r.Name !=null group by Id, Community_Topic__r.Name order by Community_Topic__r.Name  ASC');
            }else{
                communityTopics = Database.query('select Id, Community_Topic__r.Name from Product2 where Available_to_the_Guest_User__c=true and Community_Topic__r.Name !=null group by Id, Community_Topic__r.Name order by Community_Topic__r.Name  ASC');
            }
        }
        return communityTopics;
    }
}