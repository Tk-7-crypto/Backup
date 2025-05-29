public with sharing class CNT_PEP_CaseList {
    @AuraEnabled
    public static List<PRM_Community_List_View_Config__c> getPRMCommunityListViewConfig(){   
        List<PRM_Community_List_View_Config__c> values= new List<PRM_Community_List_View_Config__c>();
        values =  PRM_Community_List_View_Config__c.getall().values();
        return values;
    }
    
    @AuraEnabled
    public static List<Contact> getUserContact(){
        List<User> users = new List<User>();
        users = new SLT_User().selectById(new Set<Id> {userInfo.getUserId()});
        List<Contact> contacts=new List<Contact>();
        if(users != null && users.size() > 0)
            contacts = new SLT_Contact().selectByContactIdList(new Set<Id> {users[0].ContactId}, new Set<String>{'Portal_Case_Type__c','AccountId'});
        return contacts;
    }
}