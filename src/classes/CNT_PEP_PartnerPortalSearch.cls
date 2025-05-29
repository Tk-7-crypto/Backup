public class CNT_PEP_PartnerPortalSearch { 
    public class PEP_SearchResult {
    @AuraEnabled
    public String id {get; set;}
    @AuraEnabled
    public String objName {get; set;}
    @AuraEnabled
    public SObject sobj {get; set;}
    }
    @AuraEnabled
    public static List<PEP_SearchResult> searchForIds(String searchText, String searchObject, Integer rowLimit, Integer rowOffset) {
        List<User> users = new List<User>();
        String partnerType = '';
        List<PEP_SearchResult> srList = new List<PEP_SearchResult>();
        users = new SLT_User().selectContactDetailByUser(new Set<Id> {userInfo.getUserId()}, new Set<String>  {'Contact.Portal_Case_Type__c','Contact.Contact_User_Type__c','AccountId','Contact.Partner_Type__c'});
        partnerType = users[0].Contact.Partner_Type__c;
        partnerType = '\'' + partnerType.replace(';','\',\'') +'\'';
        if (users.size() > 0 && users[0].Contact != null && users[0].AccountId != null) {
            Set<String> pillar = new Set<String>(users[0].Contact.Portal_Case_Type__c.split(';'));
            String userType = users[0].Contact.Contact_User_Type__c;
            Set<String> ids = new Set<String>();
            List<asset> assets = new SLT_Asset().getAssetsWithFilter(new Set<String>{'Product2Id'}, 'AccountId=\''+ users[0].AccountId +'\' AND Status !=\'Obsolete\' AND Product2Id !=\'\'');
            for (Integer i=0; i<assets.size(); i++) {
                ids.add(assets[i].Product2Id);
            }
            List<List<SObject>> results = new List<List<SObject>>();            
            if(searchObject == '' || searchObject == 'Case') {
                List<List<SObject>> results1 = new SLT_Case().getSearchResults(searchText, pillar, users[0].AccountId,ids, partnerType, rowLimit, rowOffset);           
                results.addAll(results1);
            }
            if(searchObject == '' || searchObject == 'Knowledge__kav') {
                List<List<SObject>> results2 = new SLT_Knowledge().getSearchResultsPRM1(searchText, pillar, users[0].AccountId, ids, partnerType, rowLimit, rowOffset);
                List<List<SObject>> results3 = new SLT_Knowledge().getSearchResultsPRM2(searchText, pillar, users[0].AccountId, ids, partnerType, rowLimit, rowOffset);
                results.addAll(results2);
                results.addAll(results3);
            }
            
            if(searchObject == '' || searchObject == 'ContentDocument') {
                List<List<SObject>> results4 = new SLT_ContentDocument().getSearchResultsContentDocument(searchText, rowLimit, rowOffset);
                results.addAll(results4);
            }
            
            System.debug('Articles result : ' + results);
            for (List<SObject> sobjs : results) {
                for (SObject sobj : sobjs) {
                    PEP_SearchResult sr = new PEP_SearchResult();
                    sr.id = sobj.Id;
                    sr.objName = string.valueOf(sobj.Id.getsobjecttype());
                    sr.sobj = sobj;
                    if( sr.objName == 'Knowledge__kav') {
                        srList.add(sr);
                    }else if(sr.objName == 'Case'){
                        srList.add(sr);
                    }else{
                        srList.add(sr);
                    }
                }
            }
        }
        return srList;
    }
}
