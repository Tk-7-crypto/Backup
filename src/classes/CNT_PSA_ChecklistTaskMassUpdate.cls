/*
* @author Vikas Soni
* Apex support methods for Checklist Task Mass Update Lightning Web Component
*/

public with sharing class CNT_PSA_ChecklistTaskMassUpdate {
    
    private final static Integer MAX_CONTACT_RECORDS = 5;
    
    /* 
* get whether logged in user having permission set IN 
* RDS_Admin
* RDS_Project_Manager_and_Functional_Lead
* RDS_Resource
* RDS_Resource_and_Line_Manager
*/
    @AuraEnabled
    public static Boolean isUserHavingEditablePermissionSet(){
        Boolean havePermission = false;
        List<String> listEditablePermissionSets = new List<String>{'RDS_Admin','RDS_Project_Manager_and_Functional_Lead','RDS_Resource','RDS_Resource_and_Line_Manager'};
            List<PermissionSetAssignment> listcurrentUserPerSet =    [SELECT Id, PermissionSet.Name,AssigneeId
                                                                      FROM PermissionSetAssignment
                                                                      WHERE AssigneeId = :Userinfo.getUserId() AND PermissionSet.Name IN :listEditablePermissionSets];
        
        if(listcurrentUserPerSet.size() > 0){
            //User have edit permission
            havePermission = true;
        }else{
            //User does not have edit permission
            havePermission = false;
        }
        
        return havePermission;
    }
    
    
    //Updating Selected Tasks
    @AuraEnabled
    public static String updateChecklistTasks(List<pse__Project_Task__c> updatedTaskList, String startDate, String endDate, String status, String description, String resourceId){
        List<pse__Project_Task__c> taskList = new List<pse__Project_Task__c>();
        
        for(pse__Project_Task__c task : updatedTaskList){            
            if(startDate != null && !String.isBlank(startDate)){
                string[] splittedStartDate = startDate.split('\\-');
                datetime startDateTime = datetime.newInstance(Integer.valueOf(splittedStartDate[0]), Integer.valueOf(splittedStartDate[1]), Integer.valueOf(splittedStartDate[2]));
                task.pse__Start_Date_Time__c = startDateTime;
            }
            if(endDate != null  && !String.isBlank(endDate)){
                string[] splittedEndDate = endDate.split('\\-');
                datetime endDateTime = datetime.newInstance(Integer.valueOf(splittedEndDate[0]), Integer.valueOf(splittedEndDate[1]), Integer.valueOf(splittedEndDate[2]));
                task.pse__End_Date_Time__c = endDateTime;
            }
            if(status !=null){
                task.pse__Status__c = status;
            }
            if(description != null){
                if(description != ''){
                    task.pse__Long_Description__c = description;
                }
            }
            if(resourceId != null && resourceId != ''){
                task.Resource__c = Id.valueOf(resourceId);
            }
            taskList.add(task);
        }
        update taskList;
        return 'success';
    }
    
    //Calling method based on project RDS/Service Line
    @AuraEnabled(cacheable=true)
    public static List<pse__Project_Task__c> getProjectTasks(String rdsProjectId, String serviceLineProjectId, List<String> fieldsList){
        if(serviceLineProjectId!=null){
            return getServiceLineProjectTasks(serviceLineProjectId, fieldsList);
        }else{
            return getTasksByRdsProject(rdsProjectId, fieldsList);
        }
    }
    
    //Getting RDS Project Tasks
    @AuraEnabled(cacheable=true)
    public static List<pse__Project_Task__c> getTasksByRdsProject(String projectId, List<String> fieldsList){
        return new SLT_Project_Task().getRDSRecordTypeProjectTasksByRDSProject(new Set<Id>{projectId}, new Set<String>(fieldsList));
    }
    
    //Getting Service Line Project Tasks
    @AuraEnabled(cacheable=true)
    public static List<pse__Project_Task__c> getServiceLineProjectTasks(String projectId, List<String> fieldsList){
        return new SLT_Project_Task().getRDSRecordTypeProjectTasksByServiceLineProject(new Set<Id>{projectId}, new Set<String>(fieldsList));
    }
    
    /*
    * Search resource(contact record) from org.
    * @param searchKey = String value of contact name.
    */
    @AuraEnabled(Cacheable=true)
    public static List<UTL_LookupSearchResult> findContactsBySearchKey(String searchKey) {
        searchKey += '*';
        List<List<SObject>> contactRecordsList = [
            FIND :searchKey
            IN Name Fields
            RETURNING
            Contact(Id, Name)
            LIMIT :MAX_CONTACT_RECORDS
        ];
        List<UTL_LookupSearchResult> lookupSearchResultWrapperObjectsList = new List<UTL_LookupSearchResult>();
        String contactIcon = 'standard:contact';
        for (Contact resource: (List<Contact>) contactRecordsList[0]) {
            lookupSearchResultWrapperObjectsList.add(
                new UTL_LookupSearchResult(
                    resource.Id,
                    'Contact',
                    contactIcon,
                    resource.Name,
                    'Contact'
                )
            );
        }
        lookupSearchResultWrapperObjectsList.sort();
        return lookupSearchResultWrapperObjectsList;
    }
}