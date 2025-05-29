/*
 * @author Leo De Bruyn <ldebruyn@cldpartners.com>
 * Apex support methods for Manage Deliverables Lightning Web Component
 */

public with sharing class CNT_PSA_ManageDeliverables {
    public CNT_PSA_ManageDeliverables() {

    }

    @AuraEnabled(cacheable=true)
    public static List<pse__Project_Task__c> getProjectTasksByMilestone(String milestoneId, List<String> additionalFields){
        pse__Milestone__c milestone = new SLT_Milestone().getMilestoneById(new Set<Id>{milestoneId}, new Set<String>{'Service_Line__r.Service_Line_Code__c','Service_Code__c'}).get(milestoneId);
        String serviceCode = milestone.Service_Code__c;
        String serviceLineCode = milestone.Service_Line__r.Service_Line_Code__c;
        List<String> generalFieldsList = CNT_PSA_ManageDeliverables.getGeneralDeliverableFields();
        List<String> billingFieldsList = CNT_PSA_ManageDeliverables.getBillingDeliverableFields();
        List<String> serviceLineFieldsList = CNT_PSA_ManageDeliverables.getServiceLineDeliverableFields(serviceCode, serviceLineCode);
        List<String> fieldsToGetList = new List<String>();

        fieldsToGetList.addAll(generalFieldsList);
        fieldsToGetList.addAll(billingFieldsList);
        fieldsToGetList.addAll(serviceLineFieldsList);
        if(additionalFields != null){
            fieldsToGetList.addAll(additionalFields);
        }
        
        return new SLT_Project_Task().getProjectTasksByMilestone(new Set<Id>{milestoneId},new Set<String>(fieldsToGetList));
    }

    @AuraEnabled(cacheable=true)
    public static List<pse__Project_Task_Assignment__c> getTaskAssignmentsByMilestone(String milestoneId, List<String> fields){
        Map<Id,pse__Project_Task__c> idToTaskMap = new Map<Id,pse__Project_Task__c>(new SLT_Project_Task().getProjectTasksByMilestone(new Set<Id>{milestoneId},new Set<String>{'Id'}));
        return new SLT_Project_Task_Assignment().getTaskAssignmentsByTask(new Set<Id>(idToTaskMap.keySet()),new Set<String>(fields));
    }

    /**
     */
    @AuraEnabled(cacheable=true)
    public static List<String> getServiceLineDeliverableFields(String serviceCode, String serviceLineCode){
        Set<String> fieldsetNames = new Set<String>();
        List<String> fieldNames = new List<String>();
        List<PSA_Service_Line_Task_Field_Set_Mapping__mdt> taskFieldSetMappings = new SLT_PSAServiceLineTaskFieldSetMapping().getFieldSetMappingsByCode(serviceCode, serviceLineCode);

        if(taskFieldSetMappings.size() == 0 && CON_PSA.srvcLineToFieldMap.get(serviceCode) == null){
            return fieldNames;
        }else if(taskFieldSetMappings.size() > 0){            
            for(PSA_Service_Line_Task_Field_Set_Mapping__mdt mapping : taskFieldSetMappings) {
                fieldsetNames.add(mapping.Field_Set_Name__c);
            }    
            fieldNames = new SLT_Project_Task().getFieldListByFieldSetName(fieldsetNames);
        } else{
            fieldNames = CON_PSA.srvcLineToFieldMap.get(serviceCode);
        }

        
        return fieldNames; 
    }

    @AuraEnabled(cacheable=true)
    public static List<String> getGeneralDeliverableFields(){
        return  getGeneralDeliverableFields('');
    }

    @AuraEnabled(cacheable=true)
    public static List<String> getGeneralDeliverableFields( String serviceLineCode ){
        if( serviceLineCode == 'PVA' ){
            return new SLT_Project_Task().getFieldListByFieldSetName('PSA_RDS_Deliverable_General_PVA');
        }
            return new SLT_Project_Task().getFieldListByFieldSetName('PSA_RDS_Deliverable_General');
    }

    @AuraEnabled(cacheable=true)
    public static List<String> getBillingDeliverableFields(){
        return getBillingDeliverableFields( '' );
    }

    @AuraEnabled(cacheable=true)
    public static List<String> getBillingDeliverableFields(String serviceLineCode){
        return new SLT_Project_Task().getFieldListByFieldSetName('PSA_RDS_Deliverable_Billing');
    }

    @AuraEnabled(cacheable=true)
    public static List<String> getServiceLineTaskFields(Id serviceLineId){
        Service_Line__c serviceLine = getServiceLineInfo(serviceLineId);
        String serviceCode = serviceLine.Service_Line_Code__c;
        List<String> fieldNames = new List<String>();
        String fieldSetName;
        List<PSA_Service_Line_Task_Field_Set_Mapping__mdt> taskFieldSetMappings = [
                SELECT Field_Set_Name__c, Field_Set_Type__c, Service_Line_Code__c 
                FROM PSA_Service_Line_Task_Field_Set_Mapping__mdt
                WHERE Service_Line_Code__c = :serviceCode 
                AND Field_Set_Type__c = 'Task' AND Form_Section__c = 'Service Line'];
        if(taskFieldSetMappings.size() == 0){
            return fieldNames;
        } else {
            fieldSetName = taskFieldSetMappings.get(0).Field_Set_Name__c;
        }
        return new SLT_Project_Task().getFieldListByFieldSetName(fieldSetName);
    }

    @AuraEnabled(cacheable=true)
    public static List<String> getGeneralTaskFields(){
        return getGeneralTaskFields( '' );
    }

    @AuraEnabled(cacheable=true)
    public static List<String> getGeneralTaskFields( String serviceLineCode ){
        if( serviceLineCode == 'PVA' ){
            return new SLT_Project_Task().getFieldListByFieldSetName('PSA_RDS_Task_General_PVA');
        }

        return new SLT_Project_Task().getFieldListByFieldSetName('PSA_RDS_Task_General');
    }

    @AuraEnabled(cacheable=true)
    public static Service_Line__c getServiceLineInfo(Id serviceLineId){
        return new SLT_Service_Line().selectById(new Set<Id>{serviceLineId}, new Set<String>{'Id', 'Name', 'Service_Line_Code__c'}).get(0);
    }

    @AuraEnabled
    public static List<Target__c> getTargetsByProgram(Id programId){
       return new SLT_Target().getTargetByProgram(programId);
    }

    @AuraEnabled(cacheable=true)
    public static Lightning_Filter__c getLightningFilterByProgram(Id programId){
        return new SLT_Lightning_Filter().getLightningFilterByProgram(programId, new Set<String>{'Id','Program__c','Target__c'});
    }

    @AuraEnabled
    public static Lightning_Filter__c createLightningFilter(Id programId){
        if(programId == null){
            return null;
        }
        Lightning_Filter__c filter = new Lightning_Filter__c(Program__c=programId);
        insert filter;
        return filter;
    }

    @AuraEnabled
    public static List<pse__Proj__c>  getProjectsByProgram(Id programId){

        List<pse__Proj__c> projectList =  new SLT_Project().selectChildsByProgramId(new Set<Id>{programId}, new Set<String>{'Id', 'Name', 'pse__Parent_Project__r.Name', 'pse__Start_Date__c', 'pse__End_Date__c', 'pse__Stage__c', 'Service_Line__r.Service_Line_Code__c'} );
        List<pse__Proj__c> returnList = new List<pse__Proj__c>();
        for (pse__Proj__c p : projectList){
           if((p.pse__Stage__c == CON_PSA.PROJ_STAGE_STARTUP || p.pse__Stage__c == CON_PSA.PROJ_STAGE_CONDUCT || p.pse__Stage__c == CON_PSA.PROJ_STAGE_ON_HOLD) 
           && p.Service_Line__r.Service_Line_Code__c == 'PVA'){
                returnList.add(p);
            }
        }
        return returnList;
    }

    @AuraEnabled
    public static List<pse__Milestone__c>  getMilestonesByProject(Id projectId){

        List<pse__Milestone__c> msList =  new SLT_Milestone().selectMilestoneByRDSServiceProjectId(new Set<Id>{projectId}, new Set<String>{'Id', 'Name', 'pse__Project__r.Name', 'pse__Status__c', 'pse__Target_Date__c', 'Closed_for_Unit_Entry__c'} );
        List<pse__Milestone__c> returnList = new List<pse__Milestone__c>();
        for (pse__Milestone__c m : msList){

            if (!m.Closed_for_Unit_Entry__c){
                returnList.add(m);
            }
        }
        return returnList;

        
    }

    @AuraEnabled
    public static Map<String, Object> checkDateOffset(String serviceLineCode, String serviceCode, Id programId, Date clientNotificationDate,
    Date endDate, Date draftDueDate ){
        List<PSA_Date_Offset__c> offsetList = SRV_PSA_Date_Offset.fetchDateOffsets( pse__Project_Task__c.sObjectType, new Set<Id>{programId} );

        String dueDateKey = serviceCode + String.valueOf(programId) + 'Client_Notification_Date__c' + 'Draft_Due_Date__c';
        String endDateKey = serviceCode + String.valueOf(programId) + 'Client_Notification_Date__c' + 'End_Date_Planned__c';
        Map<String, PSA_Date_Offset__c> offsetMap = new Map<String, PSA_Date_Offset__c>();

        for(PSA_Date_Offset__c offSet : offsetList){

            if( offset.Type_Field__c == 'Service_Code__c' ) {
                String key = String.valueOf(offSet.Type_Value__c) 
                            + String.valueOf(offSet.Program__c) +
                            offSet.Source_Date_Field__c + offSet.Target_Date_Field__c;
                offsetMap.put(key, offSet);
            }
        }
       Date returnDate = null;
       Date returnDatetime = null;
        if (draftDueDate == null){
            returnDate =  DAOH_PSA_Project_Task.updateDateToOffset(clientNotificationDate, offsetMap, dueDateKey);
        }
        if(endDate== null){
            returnDatetime =  DAOH_PSA_Project_Task.updateDateToOffset(clientNotificationDate, offsetMap, endDateKey);
        }
        
        
        Map<String, Object> dateMap = new Map<String, Object>();
        dateMap.put('Draft_Due_Date__c', returnDate);
        dateMap.put('End_Date_Planned__c', returnDatetime);
        return dateMap;

        
    }
    
    /**
     * Retrieves editable fields according to permission set assigned to user.
     */
    @AuraEnabled(cacheable=true)
    public static boolean getFieldIsEditableForBillingSection() {
        boolean isFieldDisabled = true;
        List<PermissionSetAssignment> permissionSetList = new list<PermissionSetAssignment>();
        permissionSetList = [SELECT  PermissionSet.Name FROM PermissionSetAssignment WHERE AssigneeId = :UserInfo.getUserId()];
        for(PermissionSetAssignment perRec: permissionSetList){
            if(perRec.PermissionSet.Name == 'RDS_ADMIN' || perRec.PermissionSet.Name == 'RDS_Project_Manager_and_Functional_Lead'){
                isFieldDisabled = false;
                break;
            }    
        }
        return isFieldDisabled;  
    }
    
}