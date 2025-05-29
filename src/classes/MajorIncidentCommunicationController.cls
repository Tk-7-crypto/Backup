public with sharing class MajorIncidentCommunicationController {
    
    @AuraEnabled
    public static List<Major_Incident__c> getAllInternalCommunications(){
        Set<String> statusSet = new Set<String>();
        statusSet.add(CON_CSM.S_IN_PROGRESS);
        statusSet.add(CON_CSM.S_RESOLVED);
        List<Major_Incident__c> majorList = [SELECT Major_Incident_Internal_Communication__c, Status__c FROM Major_Incident__c WHERE Status__c IN :statusSet];
        return majorList;
    }
    
    @AuraEnabled
    public static Profile getUserProfile(){
        Id profileId = UserInfo.getProfileId();
        Profile userProfile = [SELECT Name FROM Profile WHERE Id = :profileId];
        return userProfile;
    }
    
    @AuraEnabled
    public static List<CSM_MI_List_View_Setting__c> getListViewRelatedIds(){
        List<CSM_MI_List_View_Setting__c> MIViewList = CSM_MI_List_View_Setting__c.getall().values();
        return MIViewList;
    }
}