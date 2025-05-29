/*
 * @author Leo De Bruyn <ldebruyn@cldpartners.com>
 * Apex support methods for Target Grid Lightning Web Component
 */
public with sharing class CNT_PSA_TargetGrid {

    /*
     * Gets all projects on a program and their project codes
     */
    @AuraEnabled(cacheable=true)
    public static List<pse__Proj__c> getProjectsForProgram(String programId){
        return new SLT_Project().selectByProgramId(new Set<Id>{programId}, new Set<String>{'Id', 'Name', 'Project_Code__c'});
    }

    /*
     * Gets all targets on a program
     */
    @AuraEnabled
    public static List<Target__c> getTargets(String programId, String recordTypeId){
        Map<String,Set<String>> recordTypeToFieldsMap = new Map<String,Set<String>>();
        recordTypeToFieldsMap.put('default', new Set<String>{'Id', 'Name'});
        recordTypeToFieldsMap.put(CON_PSA.TARGET_REC_TYPE_RDS_PROTOCOL, new Set<String>{'Id', 'Name', 'Protocol_Number__c', 'Therapeutic_Area__c', 'Indication__c', 'Investigational_Product_Id__c', 'Clinical_Phase__c'});
        recordTypeToFieldsMap.put(CON_PSA.TARGET_REC_TYPE_RDS_PRODUCT_LINE, new Set<String>{'Id', 'Name', 'API__c', 'Trade_Name__c', 'Generic_Name__c', 'Strength__c', 'Dosage_Form__c', 'Single_Country__c'});
        recordTypeToFieldsMap.put(CON_PSA.TARGET_REC_TYPE_RDS_COUNTRY, new Set<String>{'Id', 'Name'});
        recordTypeToFieldsMap.put(CON_PSA.TARGET_REC_TYPE_RDS_PV_AGREEMENT, new Set<String>{'Id', 'Name', 'Customer_Reference_Number__c', 'Partner__c', 'Agreement_Status__c'});

        String recordTypeName = Schema.SObjectType.Target__c.getRecordTypeInfosById().get(recordTypeId).getName();
        Set<String> fields = recordTypeToFieldsMap.get(recordTypeName);
        if(fields == null){
            fields = recordTypeToFieldsMap.get('default');
        }

        return new SLT_Target().getTargetByProgram(programId, recordTypeId, fields);
    }

    /*
     * Gets all project targets on a project or else on a service line
     */
    @AuraEnabled
    public static List<Project_Target__c> getProjectTargets(String mode, List<Id> projectIds){
        if( mode == 'project'){
            return new SLT_Project_Target().getProjectTargetByProject(new Set<Id>(projectIds), new Set<String>{'Id', 'Project__c', 'Target__c'});
        }
        if( mode == 'serviceLine'){
            return new SLT_Project_Target().getProjectTargetByServiceLineProject(new Set<Id>(projectIds), new Set<String>{'Id', 'Project__c', 'Service_Line_Project__c', 'Target__c'});
        }

        //Only these two modes are allowed-- exceptions for others
        String INVLAID_MODE = mode+' is not a valid project grid type.';
        AuraHandledException ahe = new AuraHandledException(INVLAID_MODE);
        ahe.setMessage(INVLAID_MODE);
        throw ahe;
    }

    /*
     * Gets the service line projects for a program
     */
    @AuraEnabled(cacheable=true)
    public static List<pse__Proj__c> getServiceLines(String programId){
        Set<String> fieldsToGet = new Set<String>{'Id', 'Name', 'Service_Line__r.Service_Line_Code__c', 'pse__Parent_Project__c', 'pse__Parent_Project__r.Project_Code__c'};
        return new SLT_Project().selectChildsByProgramId(new Set<Id>{programId},fieldsToGet);
    }

    /*
     * Creates a project target for a target, project, and optional service line 
     */
    @AuraEnabled
    public static Project_Target__c createProjectTarget(String projectId, String serviceLineProjectId, String targetId, Boolean isActive){
        Date Activated_Date = System.today();
        Project_Target__c pt = new Project_Target__c(Project__c=projectId, Service_Line_Project__c=serviceLineProjectId, Target__c=targetId, Active__c=isActive, Activated_Date__c=Activated_Date); 
        insert pt;
        return pt;
    }

    /*
     * update a project target on inactive
     */
    @AuraEnabled
    public static string updateProjectTarget(String projectTargetId, Boolean isActive){
        String result = '';
        Boolean isChange = FALSE;
        // for get Target active field value
        for(  Project_Target__c getPT : [ SELECT Id, Target__r.Active__c FROM Project_Target__c WHERE Id =: projectTargetId ]){
            if( getPT.Target__r.Active__c == TRUE ){
                isChange = TRUE;
            }
        }
        if( isChange ){
            Project_Target__c pt;
            if(isActive){
                Date Activated_Date = System.today();
                pt = new Project_Target__c(Id=projectTargetId,Active__c=isActive,Activated_Date__c=Activated_Date);
            }
            else{
                Date Deactivated_Date = System.today();
                pt = new Project_Target__c(Id=projectTargetId,Active__c=isActive,Deactivated_Date__c=Deactivated_Date);   
            }
            update pt;
            result = 'success'; 
        }else{
            result = 'You cannot set this target as active here because this target is inactive.';
        }
        return result;
    }

    /*
     * Deletes a project target
     */
     /*
    @AuraEnabled
    public static string deleteProjectTarget(String projectTargetId){
       Project_Target__c pt = new Project_Target__c(Id=projectTargetId);
       delete pt;
       return 'success'; 
    }
    */
}