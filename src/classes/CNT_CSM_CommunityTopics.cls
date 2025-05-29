public without sharing class CNT_CSM_CommunityTopics {
    @AuraEnabled(cacheable=true)
    public static List<AggregateResult> getProductCommunityTopics(){
        List<AggregateResult> communityTopics = new List<AggregateResult>();
        List<User> users = new List<User>();
        if(UserInfo.getUserType().contains(CON_CSM.S_CUSTOMER_SUCCCESS) || UserInfo.getUserType().contains(CON_PEP.S_PEP_POWERPARTNER)) {
            users = new SLT_User().selectContactDetailByUser(new Set<Id> {userInfo.getUserId()}, new Set<String> {'Contact.Portal_Case_Type__c','Contact.Account.AccountCountry__c'});
            if (users.size() > 0 && users[0].Contact != null && users[0].Contact.Account != null) {
                List<CSM_QI_Data_Portal_Queue_User_details__c> dataList;
                List<Id> prodList;
                String pillar = users[0].Contact.Portal_Case_Type__c;
                pillar = '\'' + pillar.replace(';','\',\'') +'\'';
                dataList = new SLT_CSMDataPortalQueueUserdetails().getDataWithFilter(new Set<String> {'ProductId__c'},'ProductId__c != null AND Account__c=\''+ users[0].AccountId +'\' AND Type__c =\'Product Level Restriction\' AND ClientContact__c=\''+ users[0].ContactId +'\'');
                if(dataList != null && !dataList.isEmpty()) {
                    prodList = new List<Id>();
                    for(CSM_QI_Data_Portal_Queue_User_details__c s : dataList) {
                        prodList.add(s.ProductId__c);
                    }
                    communityTopics = Database.query('select MIN(Id) Id, Community_Topic__r.Name from Product2 where Id in(SELECT Product2Id FROM asset WHERE AccountId=\''+ users[0].AccountId +'\' AND Status !=\'Obsolete\' AND Topic_Visible_in_CSH_Homepage__c = true AND Product2Id in:prodList) and Community_Topic__r.Name !=null and Pillar__c Includes (' + pillar + ') group by Community_Topic__r.Name order by Community_Topic__r.Name  ASC');
                }else{
                    List<Id> removeProd = new List<Id>();
                    List<CSM_QI_Case_Categorization__c> prodDataList = new SLT_CaseCategorization().getProductLevelRestrict();
                    if(prodDataList != null){
                        for(CSM_QI_Case_Categorization__c p : prodDataList) {
                            removeProd.add(p.Product__c);
                        }    
                    }
                    if(!removeProd.isEmpty()) {
                        communityTopics = Database.query('select MIN(Id) Id, Community_Topic__r.Name from Product2 where Id in(SELECT Product2Id FROM asset WHERE AccountId=\''+ users[0].AccountId +'\' AND Status !=\'Obsolete\' AND Topic_Visible_in_CSH_Homepage__c = true and Product2Id not in :removeProd) and Community_Topic__r.Name !=null and Pillar__c Includes (' + pillar + ') group by Community_Topic__r.Name order by Community_Topic__r.Name  ASC');
                    }else{
                        communityTopics = Database.query('select MIN(Id) Id, Community_Topic__r.Name from Product2 where Id in(SELECT Product2Id FROM asset WHERE AccountId=\''+ users[0].AccountId +'\' AND Status !=\'Obsolete\' AND Topic_Visible_in_CSH_Homepage__c = true) and Community_Topic__r.Name !=null and Pillar__c Includes (' + pillar + ') group by Community_Topic__r.Name order by Community_Topic__r.Name  ASC');
                    }

                }

            }
        }else{
            List<Id> removeProd = new List<Id>();
            List<CSM_QI_Case_Categorization__c> prodDataList = new SLT_CaseCategorization().getProductLevelRestrict();
            for(CSM_QI_Case_Categorization__c p : prodDataList) {
                removeProd.add(p.Product__c);
            }
            if(!removeProd.isEmpty()) {
                communityTopics = Database.query('select MIN(Id) Id, Community_Topic__r.Name from Product2 where Id not in :removeProd and Community_Topic__r.Name !=null and Available_to_the_Guest_User__c=true group by Community_Topic__r.Name order by Community_Topic__r.Name  ASC');
            }else{
                communityTopics = Database.query('select MIN(Id) Id, Community_Topic__r.Name from Product2 where Community_Topic__r.Name !=null and Available_to_the_Guest_User__c=true group by Community_Topic__r.Name order by Community_Topic__r.Name  ASC');
            }
        }
        return communityTopics;
    }
}