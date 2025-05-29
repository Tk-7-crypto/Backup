/*
 * Version       : 1.0
 * Description   : Apex Controller for LXC_CSM_News Lightning component 
 */ 
public class  CNT_CSM_CSMNews {
    /**
     * This method used to return List<CSM_QI_News__c>
     * @return  List<CSM_QI_News__c>
     */  
    @AuraEnabled
    public static List<CSM_QI_News__c> getUnuseCSMNews(){
        List<CSM_QI_News__c> news = new List<CSM_QI_News__c>();  
        news = new SLT_CSM_QI_News().selectAllNews(new Set<String>{'Id', 'Name','CreatedDate','LastModifiedDate' ,'News__c','Mode__c'}); //[ select Id, OwnerId, IsDeleted, Name, CurrencyIsoCode, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp, News__c,Mode__c from CSM_QI_News__c  order by CreatedDate DESC];
        return news;
    }
    
    /**
     * This method used to return List<CSM_QI_News__c>
     * @params  module
     * @return  List<CSM_QI_News__c>
     */  
    @AuraEnabled
    public static List<CSM_QI_News__c> getCSMNews(String module,string type){
        List<CSM_QI_News__c> news = new List<CSM_QI_News__c>();  
        news = new SLT_CSM_QI_News().selectNewsByModule(new Set<String>{'Id', 'Name','CreatedDate','LastModifiedDate' ,'News__c','Mode__c', 'Module__c'}, module,type); //[ select Id, OwnerId, IsDeleted, Name, CurrencyIsoCode, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp, News__c,Mode__c from CSM_QI_News__c  order by CreatedDate DESC];
        return news;
    }

    @AuraEnabled
    public static String getUserProfileId(){ 
        return userinfo.getProfileId(); 
    }

    @AuraEnabled
    public static List<PermissionSet> getUserPermissionSets() {
        Id currentUserId = UserInfo.getUserId();

        List<PermissionSet> userPermissionSets = [
            SELECT Id, Name, Label
            FROM PermissionSet
            WHERE Id IN (
                SELECT PermissionSetId 
                FROM PermissionSetAssignment
                WHERE AssigneeId = :currentUserId
            )
        ];
        
        return userPermissionSets;
    }
}