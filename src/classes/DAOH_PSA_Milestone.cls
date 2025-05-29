/**
* This is the Miletone trigger handler class.
* version : 1.0
*/
public class DAOH_PSA_Milestone {
    
    /** This method is used to validate milestone deletion */
   
    public static void validateDeletion(List<pse__Milestone__c> deletedList) {
        Set<Id> milestoneIdSet = new Set<Id>();
        for(pse__Milestone__c milestone : deletedList){
            milestoneIdSet.add(milestone.Id);
        }
        if(milestoneIdSet.size() > 0){
            Map<Id,Integer> milestoneDeliverableMap = new Map<Id,Integer>();
            for(pse__Milestone__c milestone : [Select Id, (Select Id from pse__Project_Tasks__r 
                                                WHERE recordtype.name in ('RDS Deliverable','RDS Deliverable Task'))
                                                From pse__Milestone__c
                                                Where Id in: milestoneIdSet]) {
                milestoneDeliverableMap.put(milestone.Id,milestone.pse__Project_Tasks__r.size());                                     
            }     
            for(pse__Milestone__c milestone : deletedList){
                if(milestoneDeliverableMap.containsKey(milestone.Id) && milestoneDeliverableMap.get(milestone.Id) > 0){
                    milestone.addError('This Milestone cannot be deleted as there are deliverables associated with it');
                }
            }
        }
    }   

    /**
    * This method is used to set related deliverable billing fields
    */
    public static void updateProjectTaskBilling(List<pse__Milestone__c> newList, Map<Id, pse__Milestone__c> oldMap, Map<String,Set<String>> methodToRecordTypeMap) {
        Set<Id> serviceMilestoneIdSet = new Set<Id>();

        for(pse__Milestone__c ms : newList) {

            if ( methodToRecordTypeMap.get('updateProjectTaskBilling') == null || !methodToRecordTypeMap.get('updateProjectTaskBilling').contains(Schema.SObjectType.pse__Milestone__c.getRecordTypeInfosById().get(ms.RecordTypeId).getDeveloperName()) ) {
                continue;  //skip record if code not configured for recordtype
            }

            pse__Milestone__c oldMS = oldMap != null ? oldMap.get(ms.id) : null;

            if (oldMS.pse__Billing_Event__c != ms.pse__Billing_Event__c ||
                oldMS.pse__Billing_Event_Item__c != ms.pse__Billing_Event_Item__c ||
                oldMS.pse__Billed__c != ms.pse__Billed__c ||
                oldMS.pse__Invoiced__c != ms.pse__Invoiced__c) 
            {
                serviceMilestoneIdSet.add(ms.Service_Milestone__c);
            }
        }
        //Do rollup for these service milestones
        if (serviceMilestoneIdSet.size() > 0) {
            if (system.isFuture() || system.isBatch() || system.isScheduled()) {
                UTL_PSA_RollupActuals.refreshMilestoneActuals(serviceMilestoneIdSet);
            } else {
                UTL_PSA_RollupActuals.refreshMilestoneActuals_Future(serviceMilestoneIdSet);
            }
        }
    }

    /**
    * This method is used to copy  Service Line Lead field from the Project while inserting a new Milestone with blank SL Manager
    */
    public static void setServiceMilestoneFields(List<pse__Milestone__c> newList,Map<String,Set<String>> methodToRecordTypeMap) {
        
        Set<Id> projectIdSet = new Set<Id>();
        for(pse__Milestone__c milestone : newList) {  

            if ( methodToRecordTypeMap.get('setServiceMilestoneFields') == null || !methodToRecordTypeMap.get('setServiceMilestoneFields').contains(Schema.SObjectType.pse__Milestone__c.getRecordTypeInfosById().get(milestone.RecordTypeId).getDeveloperName()) ) {
                continue;
            }   

            if (milestone.pse__Project__c != null) {
                projectIdSet.add(milestone.pse__Project__c); 
            }      
        }      
  
        Map<Id, pse__Proj__c> projectMap = new SLT_Project(false, false).getProjectById(projectIdSet,new Set<String> {'Id','Name','Service_Line_Lead__c','pse__Project_Manager__c'});              
        
        for (pse__Milestone__c milestone : newList) {

            pse__Proj__c tempProj = projectMap.get(milestone.pse__Project__c);

            if (tempProj != null && tempProj.Service_Line_Lead__c != null) {
                milestone.Service_Line_Lead__c =  tempProj.Service_Line_Lead__c;
            }    
        }      
    }

    /**
    * This method is used roll up milestone values to the Service Line Projects
    */
    public static void rollUpActuals(List<pse__Milestone__c> newList, Map<Id, pse__Milestone__c> oldMap, Map<String, Set<String>> methodToRecordTypeMap) {
        Set<Id> projectIdSet = new Set<Id>();

        for(pse__Milestone__c ms : newList) {

            pse__Milestone__c oldms = oldMap != null ? oldMap.get(ms.id) : null;

            if ( methodToRecordTypeMap.get('rollUpActuals') == null || !methodToRecordTypeMap.get('rollUpActuals').contains(Schema.SObjectType.pse__Milestone__c.getRecordTypeInfosById().get(ms.RecordTypeId).getDeveloperName()) ) {
                continue;  //skip record if code not configured for recordtype
            }
           
            if ((ms.pse__Project__c != null && oldMap == null) 
                || ( oldMap != null && ms.Budget_Amount__c != oldms.Budget_Amount__c && ms.pse__Project__c !=  null)
                || ( oldMap != null && ms.Budget_Hours__c != oldms.Budget_Hours__c && ms.pse__Project__c !=  null))
            {
                projectIdSet.add(ms.pse__Project__c);
            }
        }

        if (projectIdSet.size() > 0) {
            if (system.isFuture() || system.isBatch() || system.isScheduled()) {
                UTL_PSA_RollupActuals.refreshSLProjectActuals(projectIdSet);
            } else {
                UTL_PSA_RollupActuals.refreshSLProjectActuals_Future(projectIdSet);
            }
        }
    }

    /**
    * This method is used to apply template metrics when an update is needed outside of project creation scenario
    */
    public static void applyTemplateMetrics(List<pse__Milestone__c> newList, Map<Id,pse__Milestone__c> oldMap, Map<String, Set<String>> methodToRecordTypeMap) {
        List<pse__Milestone__c> inScopeList = new List<pse__Milestone__c>();

        for (pse__Milestone__c updatedRecord : newList) {  
            
            //skip record if code not configured for recordtype
            if ( methodToRecordTypeMap.get('QUE_PSA_ApplyRDSMetricTemplates') == null || !methodToRecordTypeMap.get('QUE_PSA_ApplyRDSMetricTemplates').contains(Schema.SObjectType.pse__Milestone__c.getRecordTypeInfosById().get(updatedRecord.RecordTypeId).getDeveloperName()) ) {
                continue;
            }   

            if (oldMap != null && oldMap.get(updatedRecord.id) != null) {
                boolean oldActionApplyMetrics = oldMap.get(updatedRecord.id).Action_Apply_Standard_Metrics__c;
                  
                if (updatedRecord.Action_Apply_Standard_Metrics__c && !oldActionApplyMetrics){
                    inScopeList.add(updatedRecord);
                    updatedRecord.Action_Apply_Standard_Metrics__c = false;
                }       
            } 
        }

        if (inScopeList.size() > 0) {
            System.enqueueJob(new QUE_PSA_ApplyRDSMetricTemplates(inScopeList));
        }
    }
    public static void setFieldsOnUpdate(List<pse__Milestone__c> newList, Map<Id,pse__Milestone__c> oldMap) {
        for(pse__Milestone__c mls : newList){
            if(mls.RecordTypeId == CON_PSA.MILESTONE_REC_TYPE_ID_RDS_BILLING){ 
                if(trigger.isInsert || (trigger.isUpdate && mls.pse__Milestone_Amount__c != oldMap.get(mls.id).pse__Milestone_Amount__c)){
                    if( mls.pse__Milestone_Amount__c == 0 ){
                        mls.pse__Exclude_from_Billing__c = true;
                    }
                    else if(mls.pse__Milestone_Amount__c != 0){
                        mls.pse__Exclude_from_Billing__c = false;
                    }
                }
                if(trigger.isInsert || (trigger.isUpdate && mls.pse__Status__c != oldMap.get(mls.id).pse__Status__c)){
                    if( mls.pse__Status__c == 'Approved' ){
                        mls.pse__Include_In_Financials__c = true;
                        mls.pse__Approved__c = true;
                    }
                    else if( mls.pse__Status__c != 'Approved' ){
                        mls.pse__Include_In_Financials__c = false;
                        mls.pse__Approved__c = false;
                    }
                }
            }
        }
    }
}
