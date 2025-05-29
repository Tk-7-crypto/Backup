/**
** This is a controller class to Aura Component - LXC_PSA_HA_Website_Review
**/
public with sharing class CNT_PSA_HA_Websites_Review {

    @AuraEnabled
    public static Map<string,string> autoPopulateFields(String projectId){
        
        list<pse__Proj__c> projRecord  = new SLT_Project().selectSignalManagementProjectById(new Set<Id>{projectID}, new Set<String>{'pse__Account__c', 'pse__Parent_Project__r.Project_Code__c' });
        Map<string,string> projDetail = new Map<string,string>();
        if(projRecord.size()>0){
            projDetail.put('account',projRecord[0].pse__Account__c);
            projDetail.put('projectCode',projRecord[0].pse__Parent_Project__r.Project_Code__c);
        }
        return projDetail;
    }
    
    @AuraEnabled
    public static Map<String,Date> populatePublishDateFields(String hrId){
        
        list<HA_Websites_Review__c> hawrList  = [SELECT Id, Project__r.Service_Line__r.name,Date_Published_On_Website__c,
                                                 Due_Date_HA_Topic_Presented_to_Client__c
                                                 FROM HA_Websites_Review__c
                                                 WHERE Id =: hrId];
        Map<String,Date> hrDetail = new Map<String,Date>();
        if(hawrList.size()>0){
            hrDetail.put('datePublishedOnWebsiteResult',hawrList[0].Date_Published_On_Website__c);
            hrDetail.put('dueDateResult',hawrList[0].Due_Date_HA_Topic_Presented_to_Client__c);
        }
        return hrDetail;
    }
    
    @AuraEnabled
    public static boolean hasHAPermissionCreate(string projectID){
        boolean hasPermission = false;
        boolean hasSMEdit = false;
        boolean hasPMandFunctionalLead = false;
        List<PermissionSetAssignment> permissionSetList = new list<PermissionSetAssignment>();
        permissionSetList = [SELECT  PermissionSet.Name FROM PermissionSetAssignment WHERE AssigneeId = :UserInfo.getUserId()];
        for(PermissionSetAssignment perRec: permissionSetList){
            if(perRec.PermissionSet.Name == 'RDS_ADMIN'){
                hasPermission = true;
                break;
            }
            if(perRec.PermissionSet.Name == 'RDS_SM_Edit') {
                hasSMEdit = true;
            }   
            if(perRec.PermissionSet.Name == 'RDS_Project_Manager_and_Functional_Lead'){
                hasPMandFunctionalLead = true;
            }
        }
        if(hasSMEdit && hasPMandFunctionalLead){
            hasPermission = true;
        }
        list<pse__Proj__c> projRec  = new SLT_Project().selectSignalManagementProjectById(new Set<Id>{projectID}, new Set<String>{'Service_Line__c'});
        if(hasPermission && projRec.size()>0){
            return true;  
        }
        else{
            return false;
        }
    }
    
    @AuraEnabled
    public static boolean hasHAPermissionEdit(string hawrId){
        boolean hasPermission = false;
        boolean hasSMEdit = false;
        boolean hasPMandFunctionalLead = false;
        List<PermissionSetAssignment> permissionSetList = new list<PermissionSetAssignment>();
        permissionSetList = [SELECT  PermissionSet.Name FROM PermissionSetAssignment WHERE AssigneeId = :UserInfo.getUserId()];
        for(PermissionSetAssignment perRec: permissionSetList){
            if(perRec.PermissionSet.Name == 'RDS_ADMIN'){
                hasPermission = true;
                break;
            }   
            if(perRec.PermissionSet.Name == 'RDS_SM_Edit') {
                hasSMEdit = true;
            }   
            if(perRec.PermissionSet.Name == 'RDS_Project_Manager_and_Functional_Lead'){
                hasPMandFunctionalLead = true;
            }
        }
        if(hasSMEdit && hasPMandFunctionalLead){
            hasPermission = true;
        }
        
        list<HA_Websites_Review__c> hawrList  = [SELECT Id, Project__r.Service_Line__r.name
                                                FROM HA_Websites_Review__c
                                                WHERE Id =: hawrId];
        if(hasPermission && hawrList.size()>0 ){
            return true;  
        }
        else{
            return false;
        }
    }
    
    @AuraEnabled
    public static string haGetProjectId(string hawrId){
        
        list<HA_Websites_Review__c> hawrList  = [SELECT Id, Project__c
                                                FROM HA_Websites_Review__c
                                                WHERE Id =: hawrId];
        if(hawrList.size()>0 ){
            string recId =  hawrList[0].Project__c;
            return recId;
        }
        else{
            return null;
        }
    }
    
    @AuraEnabled
    public static Date populateDate(Date dueDate){
        Date updatedDate = dueDate.addDays(15);
        return updatedDate;
    }
    
    @AuraEnabled
    public static string populateCountries(String targetId){
        List<Target__c> targetList = new List<Target__c>([SELECT Id,Single_Country__c, Countries__c 
                                                         FROM Target__c
                                                         WHERE id =: targetId]);
                                                      
        String countries;
        if(targetList.size() > 0) {
            if(targetList[0].Single_Country__c != '' && targetList[0].Single_Country__c != null){
                countries = targetList[0].Single_Country__c;
        }
            else if(targetList[0].Countries__c != '' && targetList[0].Countries__c != null){
                countries = targetList[0].Countries__c;
            }
            else{
                countries = '';
            }
        }                                     
        return countries;
    }
    
    @AuraEnabled
    public static List<Target__c> getTargetRecords(string projectID){
        List<Target__c> activeTargetsList = new List<Target__c>();
        activeTargetsList = UTL_PSA.getTargetRecords(projectID);
        
        return activeTargetsList;
    }      
    @AuraEnabled
    public static boolean hasRDSAdminPermission(string hrId){
        boolean hasPermission = false;
        List<PermissionSetAssignment> permissionSetList = new list<PermissionSetAssignment>();
        permissionSetList = [SELECT  PermissionSet.Name FROM PermissionSetAssignment WHERE AssigneeId = :UserInfo.getUserId()];
        for(PermissionSetAssignment perRec: permissionSetList){
            if(perRec.PermissionSet.Name == 'RDS_ADMIN'){
                hasPermission = true;
                break;
            }
        }
        if(hasPermission){
            return true;
        }
        else{
            return false;
        }       
    }
}