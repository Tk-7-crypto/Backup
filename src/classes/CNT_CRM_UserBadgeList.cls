public class CNT_CRM_UserBadgeList {
    
    @AuraEnabled
    public static List<trailheadapp__User_Badge__c> getUserBadgeList() {
        Annual_Performance_Chart__c ac = Annual_Performance_Chart__c.getInstance();
        List<String> statusSet = (List<String>) JSON.deserialize(ac.UserBadge_StatusSelected__c,List<String>.class);
        return [SELECT Id, trailheadapp__Badge__r.Name, trailheadapp__Status__c, trailheadapp__Assigned_Date__c, trailheadapp__Due_Date__c, trailheadapp__Finished_Date__c, trailheadapp__URL__c  FROM trailheadapp__User_Badge__c 
                WHERE trailheadapp__Badge__r.trailheadapp__Archived__c= false AND trailheadapp__Badge__r.trailheadapp__Namespace__c ='IQVIA' AND trailheadapp__User__c = :UserInfo.getUserId() AND trailheadapp__Status__c IN :statusSet ORDER BY trailheadapp__Assigned_Date__c ASC LIMIT 10];
    }
    
    @AuraEnabled
    public static Map<String, Object> getMetaData(){
        Map<String, Object> returnMap = new Map<String, Object>();
        String profileName = [SELECT Id, Name FROM Profile WHERE Id = :UserInfo.getProfileId() ].Name;
        Annual_Performance_Chart__c ac = Annual_Performance_Chart__c.getInstance();
        List<String> status =(List<String>) JSON.deserialize(ac.UserBadge_StatusSelected__c,List<String>.class);
        returnMap.put('status',status);
        returnMap.put('profile',profileName);
        return returnMap;
    }
    
    @AuraEnabled
    public static void setMetaData(String statusSet){
        Annual_Performance_Chart__c ac = Annual_Performance_Chart__c.getInstance(UserInfo.getUserId());
        ac.UserBadge_StatusSelected__c = statusSet;
        upsert ac;
    }
    
}