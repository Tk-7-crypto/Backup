/**
* This is Project Task trigger handler class.
* version : 1.0
*/
public class DAOH_PSA_Project_Task {

    private static Map<Id, List<pse__Project_Task__c>> deletedParentToSubTasksMap = new Map<Id, List<pse__Project_Task__c>>();
    private static Set<Id> pastDueWorkflowProcessedIds = new Set<Id>();
    private static Set<Id> projectTaskIdsForUpdatingWorkflowCondition = new Set<Id>();
    
    //This method inserts a record in Audit log on deletion of Project Task
    public static void insertAuditLog(List<pse__Project_Task__c> insertList, String operation, Map<String, Set<String>> methodToRecordTypeMap){
        List<pse__Project_Task__c> inScopeTaskList = new List<pse__Project_Task__c>();
        
        for(pse__Project_Task__c pt : insertList){
            if(methodToRecordTypeMap == null ||
                 methodToRecordTypeMap.get('allAuditMethods') == null || 
                 pt.RecordTypeId == null ||
                 Schema.SObjectType.pse__Project_Task__c.getRecordTypeInfosById().get(pt.RecordTypeId) == null || 
                 !methodToRecordTypeMap.get('allAuditMethods').contains(Schema.SObjectType.pse__Project_Task__c.getRecordTypeInfosById().get(pt.RecordTypeId).getDeveloperName())){
                continue;  //skip record if code not configured for recordtype
            }

            inScopeTaskList.add(pt);
        }

        if(inScopeTaskList.size() > 0){
            SRV_PSA_AuditLog.setAuditLogOnDeleteUnDelete(inScopeTaskList,operation);
        }
    }

    public static void insertAuditLogOnUpdate(List<pse__Project_Task__c> updatedList, Map<Id,pse__Project_Task__c> existingRecords, Map<String, Set<String>> methodToRecordTypeMap){
        List<pse__Project_Task__c> inScopeTaskList = new List<pse__Project_Task__c>();
        Map<Id, pse__Project_Task__c> inScopeExistingTaskMap;
        
        if(trigger.isUpdate){
            inScopeExistingTaskMap = new Map<Id,pse__Project_Task__c>();
        } 
        
        for(pse__Project_Task__c pt : updatedList){
            if(methodToRecordTypeMap == null ||
                methodToRecordTypeMap.get('allAuditMethods') == null || 
                pt.RecordTypeId == null ||
                Schema.SObjectType.pse__Project_Task__c.getRecordTypeInfosById().get(pt.RecordTypeId) == null || 
                methodToRecordTypeMap.get('allAuditMethods') == null || !methodToRecordTypeMap.get('allAuditMethods').contains(Schema.SObjectType.pse__Project_Task__c.getRecordTypeInfosById().get(pt.RecordTypeId).getDeveloperName())){
                	continue;  //skip record if code not configured for recordtype
            }

            inScopeTaskList.add(pt);
            if(trigger.isUpdate){
                inScopeExistingTaskMap.put(pt.id, existingRecords.get(pt.id));
            } 
        }

        if(inScopeTaskList.size() > 0){
            SRV_PSA_AuditLog.setAuditOnInsertUpdate(inScopeTaskList, inScopeExistingTaskMap);
        }
    }

    /**
    * This method is used set and perform field updates
    */
    public static void setFieldUpdates(List<pse__Project_Task__c> newList, Map<Id, pse__Project_Task__c> oldMap, Map<String, Set<String>> methodToRecordTypeMap){
        Set<Id> milestoneIdSet = new Set<Id>();
        Set<Id> targetIdSet = new Set<Id>();
        List<pse__Project_Task__c> inScopeTaskList = new List<pse__Project_Task__c>();
        Set<String> activityControllingPicklistValues;

        for(pse__Project_Task__c pt : newList){
            if(pt.RecordTypeId == null || methodToRecordTypeMap == null || methodToRecordTypeMap.get('setFieldUpdates') == null 
               || !methodToRecordTypeMap.get('setFieldUpdates').contains(Schema.SObjectType.pse__Project_Task__c.getRecordTypeInfosById().get(pt.RecordTypeId).getDeveloperName())){
                	continue;  //skip record if code not configured for recordtype
            }

            if(pt.pse__Milestone__c != null){
                milestoneIdSet.add(pt.pse__Milestone__c);
                inScopeTaskList.add(pt);
            }
            if(pt.Target__c != null){
                targetIdSet.add(pt.Target__c);
            }
        }

        if(inScopeTaskList.size() > 0){
            Map<Id, pse__Milestone__c> milestoneMap = new SLT_Milestone().getMilestoneById(milestoneIdSet, new Set<String>{'Id', 'Name', 'Unit_Price__c', 'Service__c', 'Service_Line__c', 'Service_Line__r.Service_Line_Code__c', 'CurrencyIsoCode', 'pse__Project__c', 'pse__Project__r.pse__Parent_Project__c', 'pse__Project__r.pse__Is_Billable__c'});
            Map<Id, Target__c> targetMap = new Map<Id, Target__c>([SELECT Id, Name FROM Target__c WHERE Id in: targetIdSet]);

            for(pse__Project_Task__c pt : inScopeTaskList){
                string recordtypeName = Schema.SObjectType.pse__Project_Task__c.getRecordTypeInfosById().get(pt.RecordTypeId).getDeveloperName();
                string targetName = ' ';
                string drugName = pt.drug_name__c != null ? pt.drug_name__c : ' ';

                if(pt.Target__c != null){
                    targetName = targetMap.get(pt.Target__c).Name;
                }
                
                if(recordtypeName == 'RDS_Deliverable'){
                    pse__Milestone__c taskMilestone = milestoneMap.get(pt.pse__Milestone__c);
                    string milestoneName = taskMilestone != null ? taskMilestone.Name : '' ;
                    string concatMilestoneName = milestoneName.length() >= 34 ? milestoneName.subString(0,33) : milestoneName;
                    string concatTargetName = targetName.length() >=  34 ? targetName.subString(0,33) : targetName;
                    string concatDrugName = drugName.length() >=  34 ? drugName.subString(0,33) : drugName;
                    string concatEndDateTime = '';

                    if(taskMilestone.Service_Line__r.Service_Line_Code__c != 'PVA'){
                        concatEndDateTime = pt.End_Date_Planned__c == null ? '' : UTL_PSA.getString(String.valueOf(pt.End_Date_Planned__c));
                    }else{
                        concatEndDateTime = pt.pse__End_Date__c == null ? '' : UTL_PSA.getString(String.valueOf(pt.pse__End_Date__c));
                    }
                    if(pt.drug__c == null && taskMilestone.Service_Line__r.Service_Line_Code__c != 'SM'){
                        pt.Name =  trigger.isInsert ? concatMilestoneName + ' ' +  concatTargetName + ' ' + concatEndDateTime : pt.name;
                    } 
                    /*
                    Manually Create SM deliverables When Service Line Code equal to SM 
                    */
                    else if(taskMilestone.Service_Line__r.Service_Line_Code__c == 'SM'){
                        if(pt.Name == null){
                            if(pt.drug__c == null){
                                pt.Name =  trigger.isInsert ? concatMilestoneName + ' ' +  concatTargetName + ' ' + concatEndDateTime : pt.name; 
                            }else if(pt.Target__c == null){
                                pt.Name =  trigger.isInsert ? concatMilestoneName + ' ' +  concatDrugName + ' ' + concatEndDateTime : pt.name;
                            }else{
                                pt.Name =  trigger.isInsert ? concatMilestoneName : pt.name;
                            }
                        }else{
                            pt.Name = trigger.isInsert ? pt.name : pt.name; 
                        }   
                    }else{
                        pt.Name =  trigger.isInsert ? concatMilestoneName + ' ' +  concatDrugName + ' ' + concatEndDateTime : pt.name;
                    }

                    pt.Include_in_Financials__c = (pt.pse__Status__c == 'Complete' || pt.pse__Status__c == 'Ready for Billing') ? true : false;

                    //Make sure Service, Currency, and Unit Price stay synced
                    pse__Milestone__c ms = milestoneMap.get(pt.pse__Milestone__c);
                    pt.Service__c = ms.Service__c;
                    pt.Service_Line__c = ms.Service_Line__c;
                    pt.CurrencyIsoCode = ms.CurrencyIsoCode;
                    pt.Unit_Price__c = ms.Unit_Price__c;

                    if(pt.pse__project__c == null || pt.Parent_Project__c == null){
                        pt.pse__Project__c = ms.pse__Project__c;
                        pt.Parent_Project__c = ms.pse__Project__r.pse__Parent_Project__c;
                        pt.Billable__c = ms.pse__Project__r.pse__Is_Billable__c;
                    }
                }
                
                if(recordtypeName == 'RDS_Deliverable' || recordtypeName == 'RDS_Deliverable_Task'){
                    //Hidden controlling picklist for Activity should stay in sync with the service line code
                    if(pt.Activity_Controlling_Picklist__c == null){
                        if(activityControllingPicklistValues == null){
                            activityControllingPicklistValues = new Set<String>();
                            List<Schema.PicklistEntry> picklistValues = pse__Project_Task__c.fields.Activity_Controlling_Picklist__c.getDescribe().getpicklistvalues();
                            for( Schema.PicklistEntry entry : picklistValues){
                                activityControllingPicklistValues.add(entry.getValue());
                            }
                        }
                        if(activityControllingPicklistValues.contains(pt.Service_Code__c)){
                            pt.Activity_Controlling_Picklist__c = pt.Service_Code__c;
                        }
                    }
                }

                if(pt.pse__Status__c == 'Complete'){
                    pt.pse__Completed__c = true;
                    pt.pse__Started__c = true;
                }else if(pt.pse__Status__c == 'In Progress'){
                    pt.pse__Completed__c = false;
                    pt.pse__Started__c = true;
                }else if(pt.pse__Status__c == 'Planned'){
                    pt.pse__Completed__c = false;
                    pt.pse__Started__c = false;
                }else{
                    pt.pse__Completed__c = false;
                }

                // check for completed update
                if(pt.pse__Status__c == 'Complete' && pt.End_Date_Actual__c == null
                    && oldMap != null && oldMap.get(pt.id).pse__Status__c != 'Complete'){
                    pt.End_Date_Actual__c = System.Date.Today();
                }
                
                // check for started update -- PVA Only
                if(pt.pse__Status__c == 'In Progress' && pt.Start_Date_Actual__c == null
                    && oldMap != null && oldMap.get(pt.id).pse__Status__c == 'Planned'){
                    pt.Start_Date_Actual__c = System.Date.Today();
                }else if(pt.pse__Status__c == 'In Progress' && pt.Start_Date_Actual__c == null && oldMap == null){
                    pt.Start_Date_Actual__c = System.Date.Today();
                }

                // check for started update -- Not PVA
                if(pt.pse__Status__c == 'In Progress' && pt.pse__Actual_Start_Date__c == null
                    && oldMap != null && oldMap.get(pt.id).pse__Status__c == 'Planned'){
                    pt.pse__Actual_Start_Date_Time__c = System.Date.Today();
                }else if(pt.pse__Status__c == 'In Progress' && pt.pse__Actual_Start_Date__c == null && oldMap == null){
                    pt.pse__Actual_Start_Date_Time__c = System.Date.Today();
                }

                // trigger past due workflow - insert
                if(oldMap == null && pt.pse__Status__c != 'Complete' && pt.End_Date_Planned__c <= Date.Today() && pt.Resource__c != null && !pt.Trigger_Past_Due_Workflow__c && !pastDueWorkflowProcessedIds.contains(pt.id)
                    && (recordtypeName == 'RDS_Deliverable' || recordtypeName == 'RDS_Deliverable_Task')){
                    pt.Trigger_Past_Due_Workflow__c = true;
                    pastDueWorkflowProcessedIds.add(pt.id);
                } 
                // trigger past due workflow - update
                if(oldMap != null){
                    pse__Project_Task__c oldTask = oldMap.get(pt.id);

                    if(pt.pse__Status__c != 'Complete' && (pt.End_Date_Planned__c <= Date.Today() || pt.pse__End_Date__c <= Date.Today()) && pt.Resource__c != null && !pt.Trigger_Past_Due_Workflow__c 
                        && !(oldTask.Trigger_Past_Due_Workflow__c == true && pt.Trigger_Past_Due_Workflow__c == false) && !pastDueWorkflowProcessedIds.contains(pt.id)
                        && (recordtypeName== 'RDS_Deliverable' || recordtypeName == 'RDS_Deliverable_Task')
                        && (oldTask.pse__Status__c == 'Complete' || oldTask.End_Date_Planned__c > Date.Today() || oldTask.pse__End_Date__c > Date.Today() || oldTask.Resource__c == null)){
                        pt.Trigger_Past_Due_Workflow__c = true; 
                        pastDueWorkflowProcessedIds.add(pt.id);
                    } 
                }
            }
        }
    }

    /**
     * Checks to make sure Aggregate Reports get a lookup filled when a project task is added to them
     */
    public static void crossReferenceAggregateReports(List<pse__Project_Task__c> newList, Map<Id, pse__Project_Task__c> oldMap, Map<String, Set<String>> methodToRecordTypeMap){
        Map<Id,Id> aggregateReportToTaskMap;
        for(pse__Project_Task__c pt : newList){

            if(methodToRecordTypeMap == null ||
                methodToRecordTypeMap.get('crossReferenceAggregateReports') == null || 
                pt.RecordTypeId == null || 
                Schema.SObjectType.pse__Project_Task__c.getRecordTypeInfosById().get(pt.RecordTypeId) == null || 
                !methodToRecordTypeMap.get('crossReferenceAggregateReports').contains(Schema.SObjectType.pse__Project_Task__c.getRecordTypeInfosById().get(pt.RecordTypeId).getDeveloperName())){
                    continue;  //skip record if code not configured for recordtype
            }

            if(aggregateReportToTaskMap == null){
                aggregateReportToTaskMap = new Map<Id,Id>();
            }

            if(pt.Aggregate_Report__c != null){
                aggregateReportToTaskMap.put(pt.Aggregate_Report__c, pt.Id);
            }
        }

        if(aggregateReportToTaskMap != null && aggregateReportToTaskMap.size() > 0){
            List<Aggregate_Report__c> agReports = new SLT_Aggregate_Report().selectAggregateReportsById(aggregateReportToTaskMap.keySet(), new Set<String>{'Id','Deliverable__c'});
            for(Aggregate_Report__c agReport : agReports){
                if(agReport.Deliverable__c == null){
                    agReport.Deliverable__c = aggregateReportToTaskMap.get(agReport.Id);
                }
            }
            fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(new Schema.SObjectType[] {Aggregate_Report__c.SObjectType});
            uow.registerDirty(agReports);
            uow.commitWork();
        }
    }

    /**
    * This method will add deliverable tasks that have their parent deliverable deleted to a static map to faciliate sub task deletion
    **/
    public static void captureTopLevelDeletion(List<pse__Project_Task__c> newList, Map<Id, pse__Project_Task__c> oldMap, Map<String, Set<String>> methodToRecordTypeMap){
        for(pse__Project_Task__c pt : newList){

            if(methodToRecordTypeMap == null ||
                methodToRecordTypeMap.get('captureTopLevelDeletion') == null || 
                pt.RecordTypeId == null || 
                Schema.SObjectType.pse__Project_Task__c.getRecordTypeInfosById().get(pt.RecordTypeId) == null || 
                !methodToRecordTypeMap.get('captureTopLevelDeletion').contains(Schema.SObjectType.pse__Project_Task__c.getRecordTypeInfosById().get(pt.RecordTypeId).getDeveloperName())){
                	continue;  //skip record if code not configured for recordtype
            }
           
            pse__Project_Task__c oldPT = oldMap.get(pt.id);

            if(oldPT.pse__Top_Level_Parent_Task__c != null && pt.pse__Top_Level_Parent_Task__c != oldPT.pse__Top_Level_Parent_Task__c){
                List<pse__Project_Task__c> tempList = deletedParentToSubTasksMap.get(oldPT.pse__Top_Level_Parent_Task__c);
                if(tempList != null){
                    tempList.add(pt);
                    deletedParentToSubTasksMap.put(oldPT.pse__Top_Level_Parent_Task__c, tempList);
                }else{
                    deletedParentToSubTasksMap.put(oldPT.pse__Top_Level_Parent_Task__c, new List<pse__Project_Task__c>{pt});
                }
            }
        }
    }
    
    /**
    * This method will delete deliverable sub-tasks
    **/
    public static void deleteDeliverableTasks(List<pse__Project_Task__c> newList, Map<Id, pse__Project_Task__c> oldMap, Map<String, Set<String>> methodToRecordTypeMap){

        List<pse__Project_Task__c> inScopeTaskList = new List<pse__Project_Task__c>();
        fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(new Schema.SObjectType[] {pse__Project_Task__c.SObjectType});

        for(pse__Project_Task__c pt : newList){

            if(methodToRecordTypeMap == null ||
               methodToRecordTypeMap.get('deleteDeliverableTasks') == null || 
               pt.RecordTypeId == null ||
               Schema.SObjectType.pse__Project_Task__c.getRecordTypeInfosById().get(pt.RecordTypeId) == null ||
               methodToRecordTypeMap.get('deleteDeliverableTasks') == null || !methodToRecordTypeMap.get('deleteDeliverableTasks').contains(Schema.SObjectType.pse__Project_Task__c.getRecordTypeInfosById().get(pt.RecordTypeId).getDeveloperName())){
                   continue;  //skip record if code not configured for recordtype
            }
           
            if(trigger.isDelete){
                inScopeTaskList.add(pt);
            }
        }

        if(inScopeTaskList.size() > 0){
            for(pse__Project_Task__c pt : inScopeTaskList){
                List<pse__Project_Task__c> tempList = deletedParentToSubTasksMap.get(pt.id);

                if(tempList != null){
                    for(pse__Project_Task__c subPT : tempList){
                        subPT.Reason_for_Deletion__c = 'Auto Deleted with Parent Deliverable. Reason given: ' + UTL_PSA.getString(pt.Reason_for_Deletion__c).left(200);
                        uow.registerDirty(subPT);
                        uow.registerDeleted(subPT);
                    }
                }
            }
        }
        uow.commitWork();
    }

    /**
    * This method will validate on deletion validation rules
    **/
    public static void taskValidationsRDS(List<pse__Project_Task__c> newList, Map<Id, pse__Project_Task__c> oldMap, Map<String, Set<String>> methodToRecordTypeMap){
        // recursion control
        if(DAO_Project_Task.taskValidationRanOnce){ 
            return; 
        }
        DAO_Project_Task.taskValidationRanOnce = true;

        Set<Id> milestoneIdSet = new Set<Id>();
        Set<Id> projectIdSet = new Set<Id>();
        Set<Id> resourceIdSet = new Set<Id>();
        Set<Id> setProgramIds = new Set<Id>();
        Set<Id> drugIdSet = new Set<Id>();
        Set<String> setProgramTargetKeys = new Set<String>();
        Set<String> setTaskTargetKeys = new Set<String>();
        List<pse__Project_Task__c> inScopeTaskList = new List<pse__Project_Task__c>();
        Map<Id, pse__Milestone__c> milestoneMap = new Map<Id, pse__Milestone__c>();
        Map<Id, List<Target__c>> mapProgramTargets = new Map<Id, List<Target__c>>();
        Map<String, pse__Assignment__c> assignmentActiveMap = new Map<String, pse__Assignment__c>();
        Map<String, pse__Assignment__c> assignmentTrainingMap = new Map<String, pse__Assignment__c>();
        Map<String, pse__Assignment__c> assignmentAllMap = new Map<String, pse__Assignment__c>();
        Map<String, pse__Permission_Control__c> permissionControlMap = new Map<String, pse__Permission_Control__c>();
        Map<String, String> projectTaskToServiceCode = new Map<String, String>();
        Map<Id,Drug__c> drugMap = new Map<Id,Drug__c>();

        Boolean hasAdminPermission = FeatureManagement.checkPermission('RDS_Admin');
        Boolean userHasPermissionControl = false;
        PSA_RDS_Settings__c rdsSettings= PSA_RDS_Settings__c.getInstance();
        Id rdsTemplateProjectId =rdsSettings.Task_Template_ID__c;
        Id userID = system.UserInfo.getUserId();

        Contact runningUserResource = [SELECT Id FROM Contact WHERE pse__Salesforce_User__c = : userId];
        resourceIdSet.add(runningUserResource.id);

        for(pse__Permission_Control__c pc : [  SELECT Id, pse__Cascading_Permission__c, pse__Region__c, pse__Practice__c, pse__Group__c, pse__Project__c, pse__Resource__c
                                                FROM pse__Permission_Control__c
                                                WHERE pse__User__c = :userID
                                                and Unit_Entry_Ops_Edit__c = true])
        {
            if(pc.pse__Region__c != null){
                permissionControlMap.put(pc.pse__Region__c, pc);
            }
            if(pc.pse__Practice__c != null){
                permissionControlMap.put(pc.pse__Practice__c, pc);
            }
            if(pc.pse__Group__c != null){
                permissionControlMap.put(pc.pse__Group__c, pc);
            }
            if(pc.pse__Project__c != null){
                permissionControlMap.put(pc.pse__Project__c, pc);
            }
            if(pc.pse__Resource__c != null){
                permissionControlMap.put(pc.pse__Resource__c, pc);
            }
        }

        for(pse__Project_Task__c pt : newList){
            if(methodToRecordTypeMap == null ||
                methodToRecordTypeMap.get('taskValidationsRDS') == null || 
                pt.RecordTypeId == null ||
                Schema.SObjectType.pse__Project_Task__c.getRecordTypeInfosById().get(pt.RecordTypeId) == null ||
                !methodToRecordTypeMap.get('taskValidationsRDS').contains(Schema.SObjectType.pse__Project_Task__c.getRecordTypeInfosById().get(pt.RecordTypeId).getDeveloperName())){
                	continue;  //skip record if code not configured for recordtype
            }

            inScopeTaskList.add(pt);
            if(pt.pse__Milestone__c != null){
                milestoneIdSet.add(pt.pse__Milestone__c);
            }
            if(pt.pse__Project__c != null){
                projectIdSet.add(pt.pse__Project__c);
            }
            if(pt.Resource__c != null){
                resourceIdSet.add(pt.Resource__c);
            }
            if(pt.Service_Code__c != null){
                projectTaskToServiceCode.put(pt.id, pt.Service_Code__c);
            }
            if(pt.Drug__c != null){
                drugIdSet.add(pt.Drug__c);
            }
        }

        for(pse__Assignment__c assign :  [SELECT Id, Active__c, Closed_for_Unit_Entry__c, pse__Project__c, pse__Resource__c, Training_Completed__c
                                            FROM pse__Assignment__c
                                            WHERE pse__Resource__c in :resourceIdSet 
                                            and pse__Project__c in :projectIdSet])
        {
            if(assign.Active__c){
                assignmentActiveMap.put(assign.pse__Resource__c + '-' + assign.pse__Project__c, assign);
            }
            if(assign.Training_Completed__c){
                assignmentTrainingMap.put(assign.pse__Resource__c + '-' + assign.pse__Project__c, assign);
            }
            assignmentAllMap.put(assign.pse__Resource__c + '-' + assign.pse__Project__c, assign);
        }	
        if(drugIdSet.size() > 0){
            drugMap = new SLT_Drug(false,false).getDrugById(drugIdSet,new Set<String>{'Id','Service_Lines__c'});
        }
        if(inScopeTaskList.size() > 0){
            Set<String> fields = new Set<String>{   'Id', 
                                                    'Name', 
                                                    'Closed_for_Unit_Entry__c', 
                                                    'Validate_Product_Line__c',
                                                    'pse__Project__r.pse__Parent_Project__c',
                                                    'pse__Project__r.Closed_for_Unit_Entry__c', 
                                                    'pse__Project__r.pse__Parent_Project__r.Closed_for_Unit_Entry__c', 
                                                    'pse__Project__r.pse__Region__c',
                                                    'pse__Project__r.pse__Practice__c',
                                                    'pse__Project__r.pse__Group__c',
                                                    'pse__Project__r.pse__Region__r.pse__Region_Id_Chain__c',
                                                    'pse__Project__r.pse__Practice__r.pse__Practice_Id_Chain__c',
                                                    'pse__Project__r.pse__Group__r.pse__Group_Id_Chain__c',
                                                    'pse__Project__r.pse__Parent_Project__r.Program__c',
                									'pse__Project__r.Service_Line__r.Name'
                                                };

            milestoneMap = new SLT_Milestone().getMilestoneById(milestoneIdSet, fields);

            //get list of progrmas for milestones that require product line validation
            for(pse__Milestone__c ms : milestoneMap.values()){
                if(ms.Validate_Product_Line__c && ms.pse__Project__r.pse__Parent_Project__r.Program__c != null){
                    setProgramIds.add(ms.pse__Project__r.pse__Parent_Project__r.Program__c);
                }
            }

            fields = new Set<String>{ 'Id', 'Program__c', 'Drug__c', 'Trade_Name__c', 'Formulation__c', 'Single_Country__c'};
            mapProgramTargets = new SLT_Target().getTargetByProgram(setProgramIds, CON_PSA.TARGET_REC_TYPE_ID_RDS_PRODUCT_LINE, fields);
            
            //set keys for all targets to be used in validation
            string targetKey;
            for(Id key : mapProgramTargets.keyset()){
                targetKey = '';
                for(Target__c tar : mapProgramTargets.get(key)){
                    targetKey = UTL_PSA.getString(tar.Program__c) + UTL_PSA.getString(tar.Drug__c);
                    targetKey = tar.Drug_Trade_Name__c != null ? targetKey + tar.Drug_Trade_Name__c : targetKey + '*';
                    targetKey = tar.Formulation__c != null ? targetKey + tar.Formulation__c : targetKey + '*';
                    targetKey = tar.Single_Country__c != null ? targetKey + tar.Single_Country__c : targetKey + '*';
                    setProgramTargetKeys.add(targetKey);
                }
            }
            
            // adding validation of service line fields
            Map<String, PSA_Service_Line_Task_Field_Set_Mapping__mdt> serviceCodeToFieldSetMappings = new Map<String, PSA_Service_Line_Task_Field_Set_Mapping__mdt>();
            for(PSA_Service_Line_Task_Field_Set_Mapping__mdt m : [SELECT Id, Field_Set_Name__c, Service_Code__c, Form_Section__c, Field_Set_Type__c from PSA_Service_Line_Task_Field_Set_Mapping__mdt WHERE Service_Code__c in :projectTaskToServiceCode.values()]){
                if(m.Form_Section__c == 'Service Line'){
                    serviceCodeToFieldSetMappings.put(m.Service_Code__c, m);
                }
            }
            List<String> graServiceCodes = new List<String>();
            for(Service__c s : [SELECT Id, Function__c, Service_Code__c from Service__c WHERE Service_Code__c in :projectTaskToServiceCode.values()]){
                if(s.Function__c == 'RADDS'){
                    graServiceCodes.add(s.Service_Code__c);
                }
            }

            Map<String, Schema.FieldSet> fieldSetMap = Schema.SObjectType.pse__Project_Task__c.fieldSets.getMap();

            for(pse__Project_Task__c pt : newList){
                String recordTypeName = Schema.SObjectType.pse__Project_Task__c.getRecordTypeInfosById().get(pt.RecordTypeId).getDeveloperName();
                pse__Milestone__c currentMilestone = milestoneMap.get(pt.pse__Milestone__c);
            
                if(recordTypeName == 'RDS_Deliverable' || recordTypeName == 'RDS_Deliverable_Task'){
                    if (currentMilestone == null) {
                        pt.addError('Deliverables and their tasks are required to be associated with a Milestone.');
                    }
                    userHasPermissionControl = hasPermissionControl(pt, currentMilestone, permissionControlMap);
                }

                if(!trigger.isDelete && recordTypeName != 'RDS_Template_Task' && pt.pse__Project__c == rdsTemplateProjectId){
                    pt.addError('Only tasks with the record type RDS Template Task can be added to this project.');
                } 

                if(!hasAdminPermission && pt.pse__Project__c == rdsTemplateProjectId){
                    pt.addError('Only users with RDS Admin permission can delete or edit RDS Template Tasks');
                } 
                
                if(trigger.isUpdate && !hasAdminPermission && pt.pse__Project__c == rdsTemplateProjectId && oldMap != null){
                    pse__Project_Task__c oldProjTask = oldMap.get(pt.id);
                    if(oldProjTask != null){
                        if(oldProjTask.Trigger_Email_Notification__c != pt.Trigger_Email_Notification__c){
                            pt.addError('This field can only be edited by RDS admin');
                        }
                    }
                }

                if(CON_PSA.PROJ_TASK_FLAG == true && (!hasAdminPermission && recordTypeName == 'RDS_Project_Task' 
                    && (pt.Type__c == 'Start-up' || pt.Type__c == 'Close-out' || pt.Type__c == 'Maintenance')
                    && trigger.isDelete)){
                    pt.addError('Checklist tasks cannot be deleted. Change the status to Not Applicable and populate the reason in the Description.');
                }

                if(pt.Billed_f__c && trigger.isDelete){
                    pt.addError('Billed Project Tasks cannot be deleted.');
                }

                if(trigger.isDelete && (recordTypeName == CON_PSA.RECORD_TYPE_RDS_DELIVERABLE || recordTypeName == CON_PSA.RECORD_TYPE_RDS_DELIVERABLE_TASK)){ 
                    if(pt.Reason_for_Deletion__c  == null){
                        pt.addError('This Project Task cannot be deleted. Please enter the Reason For Deletion before you delete');
                    }
                }

                if((recordTypeName == CON_PSA.RECORD_TYPE_RDS_DELIVERABLE ) && (currentMilestone.Closed_for_Unit_Entry__c || currentMilestone.pse__Project__r.Closed_for_Unit_Entry__c)){                    
                     pt.addError('Deliverables cannot be added or modified if Service Milestone or Project is Closed for Unit Entry');                    
                }
                
                if(trigger.isInsert && (recordTypeName == CON_PSA.RECORD_TYPE_RDS_DELIVERABLE ) && currentMilestone.pse__Project__r.pse__Parent_Project__r.Closed_for_Unit_Entry__c){                    
                     pt.addError('Deliverables cannot be added if the related RDS Project is Closed for Unit Entry.');                    
                }

                if(!userHasPermissionControl && !assignmentActiveMap.containsKey(runningUserResource.Id + '-' + pt.pse__Project__c) && (recordTypeName == 'RDS_Deliverable' || recordTypeName == 'RDS_Deliverable_Task')){
                    pt.addError('An active assignment on the project or permission control is required in order to create or edit Deliverables.');
                }

                if(recordTypeName == 'RDS_Deliverable' || recordTypeName == 'RDS_Deliverable_Task'){
                    pse__Assignment__c assign = assignmentActiveMap.get(runningUserResource.Id + '-' + pt.pse__Project__c);
                    boolean closedForUnitEntry = assign != null && assign.Closed_for_Unit_Entry__c ? true : false;
                                  
                    if(closedForUnitEntry){
                        pt.addError('Deliverables cannot be added or modified if your Assignment is Closed for Unit Entry');
                    }
                }
                
                if(pt.Resource__c != null && !assignmentAllMap.containsKey(pt.Resource__c + '-' + pt.pse__Project__c) && (recordTypeName == 'RDS_Deliverable' || recordTypeName == 'RDS_Deliverable_Task')){
                    pt.addError('The resource specified does not have an assignment on this project.');
                }

                if(pt.Assignment_Requires_Training__c && !assignmentTrainingMap.containsKey(runningUserResource.Id + '-' + pt.pse__Project__c) 
                    && (recordTypeName == CON_PSA.RECORD_TYPE_RDS_DELIVERABLE || recordTypeName == CON_PSA.RECORD_TYPE_RDS_DELIVERABLE_TASK) 
                    && !hasAdminPermission){
                    	pt.addError('An assignment marked as Training Complete is required for this service.');
                }

                if(currentMilestone != null && currentMilestone.Validate_Product_Line__c && recordTypeName == 'RDS_Deliverable'){
                    setTaskTargetKeys = getDeliverableTargetKeys(pt);
                    
                    //all countries need to be validated if any
                    List<String> countryString = new List<String>();
                    if(pt.Countries__c != null){
                        countryString = pt.Countries__c.split(';');
                    }
                    
                    integer numCountries = countryString.size();
                    integer numCountriesValidated = 0;
                    boolean successfulMatch = false;

                    //compare keys from program to actual task key
                    for(String programTargetKey : setProgramTargetKeys){
                        for(String deliverableKey : setTaskTargetKeys){
                            if(programTargetKey == deliverableKey && numCountries != 0){
                                numCountriesValidated ++;
                            }

                            //if the keys match and all countries have been validated OR the target has no country restriction specifieid
                            if(programTargetKey == deliverableKey && ( numCountriesValidated == numCountries || programTargetKey.right(1) == '*')){
                                successfulMatch = true;
                            } 
                        }
                    }

                    if(!successfulMatch){
                        pt.addError('The combination of Drug, Trade Name, Formulation and Country is not valid based on the Product Line validation.');
                    }
                }
                //Validate if the Drug__c linked with Deliverable is of same service line.
                if((recordTypeName == 'RDS_Deliverable' || recordTypeName == 'RDS_Deliverable_Task')
                   && (drugMap.containsKey(pt.Drug__c) 
                       && drugMap.get(pt.Drug__c).Service_Lines__c != null
                       && currentMilestone != null 
                       && !drugMap.get(pt.Drug__c).Service_Lines__c.contains(currentMilestone.pse__project__r.Service_Line__r.Name))){
                           pt.addError('The selected Drug is not associated with the related Project\'s Service Line. Please select another Drug.');                         
                }
                
                // validation of service line fields
                // list of fields excluded from check
                Set<String> excludedFields = new Set<String>{'Health_Authority_Deadline__c', 'Date_HA_Approval_Notified__c', 'HA_Rejection_Date__c', 'HA_Approval_Date__c'};
                PSA_Service_Line_Task_Field_Set_Mapping__mdt fieldSetRecord = serviceCodeToFieldSetMappings.get(projectTaskToServiceCode.get(pt.id));
                if(fieldSetRecord != null){
                    List<Schema.FieldSetMember> fieldNames = fieldSetMap.get(fieldSetRecord.Field_Set_Name__c).getFields();
                    for(Schema.FieldSetMember field : fieldNames){
                        if((pt.get(field.getFieldPath()) == null || pt.get(field.getFieldPath()) == '') && 
                        ((recordTypeName == 'RDS_Deliverable' && fieldSetRecord.Field_Set_Type__c == 'Deliverable') 
                        || (recordTypeName == 'RDS_Deliverable_Task' && fieldSetRecord.Field_Set_Type__c == 'Task' )) && 
                        pt.pse__Status__c == 'Complete' && graServiceCodes.contains(pt.Service_Code__c) && !excludedFields.contains(field.getFieldPath())){
                            pt.addError('Service Line fields must not be empty when the RADDS Deliverable Status is Complete');
                        }
                    }
                }
            }
        }
    }

    /**
    * This method is used roll up completed deliverables to the actual quantity on the milestone
    */
    public static void rollUpActuals(List<pse__Project_Task__c> newList, Map<Id, pse__Project_Task__c> oldMap, Map<String, Set<String>> methodToRecordTypeMap){
        Set<Id> milestoneIdSet = new Set<Id>();

        for(pse__Project_Task__c pt : newList){
            pse__Project_Task__c oldTask = oldMap != null ? oldMap.get(pt.id) : null;
            if(methodToRecordTypeMap == null ||
                methodToRecordTypeMap.get('rollUpActuals') == null || 
                pt.RecordTypeId == null ||
                Schema.SObjectType.pse__Project_Task__c.getRecordTypeInfosById().get(pt.RecordTypeId) == null || 
                !methodToRecordTypeMap.get('rollUpActuals').contains(Schema.SObjectType.pse__Project_Task__c.getRecordTypeInfosById().get(pt.RecordTypeId).getDeveloperName())){
                	continue;  //skip record if code not configured for recordtype
            }
           
            if((pt.pse__Milestone__c != null && pt.pse__Status__c == 'Complete' && oldMap == null) 
                || ( oldMap != null && pt.pse__Status__c == 'Complete' && oldTask.pse__Status__c != 'Complete' && pt.pse__Milestone__c != null)
                || ( oldMap != null && pt.pse__Status__c != 'Complete' && oldTask.pse__Status__c == 'Complete' && pt.pse__Milestone__c != null)
                || ( pt.pse__Milestone__c != null && pt.Billed_f__c && oldMap == null) 
                || ( oldMap != null && pt.Billed_f__c && !oldTask.Billed_f__c && pt.pse__Milestone__c != null)
                || ( oldMap != null && !pt.Billed_f__c  && oldTask.Billed_f__c && pt.pse__Milestone__c != null)
                || ( Trigger.isDelete && pt.pse__Status__c == 'Complete')){
                	milestoneIdSet.add(pt.pse__Milestone__c);
            }
        }

        if(milestoneIdSet.size() > 0){
            if(system.isFuture() || system.isBatch() || system.isScheduled()){
                UTL_PSA_RollupActuals.refreshMilestoneActuals(milestoneIdSet);
            }else{
                UTL_PSA_RollupActuals.refreshMilestoneActuals_Future(milestoneIdSet);
            }
        }
    }

    /**
    * This method is used to find any template tasks assocaiated with the pricing tasks
    * used for the deliverable and add as subtasks.
    */
    public static void addPricingTaskTemplateTasks(List<pse__Project_Task__c> newList, Map<Id, pse__Project_Task__c> oldMap, Map<String, Set<String>> methodToRecordTypeMap){
        Set<String> pricingTaskIdSet = new Set<String>();
        List<pse__Project_Task__c> projectTaskInsertList = new List<pse__Project_Task__c>();
        Map<String, List<pse__Project_Task__c>> templateTaskMap = new Map<String ,List<pse__Project_Task__c>>();
        List<pse__Project_Task__c> inScopeTaskList = new List<pse__Project_Task__c>();

        for(pse__Project_Task__c pt : newList){
            if(methodToRecordTypeMap == null ||
                methodToRecordTypeMap.get('addPricingTaskTemplateTasks') == null || 
                pt.RecordTypeId == null ||
                Schema.SObjectType.pse__Project_Task__c.getRecordTypeInfosById().get(pt.RecordTypeId) == null ||
                !methodToRecordTypeMap.get('addPricingTaskTemplateTasks').contains(Schema.SObjectType.pse__Project_Task__c.getRecordTypeInfosById().get(pt.RecordTypeId).getDeveloperName())){
                continue;  //skip record if code not configured for recordtype
            } 

            if(pt.Pricing_Task_ID__c != null){
                string pricingTaskSubstring = pt.Pricing_Task_ID__c.mid(pt.Pricing_Task_ID__c.indexOf('-')+1,80);
                pricingTaskIdSet.add(pricingTaskSubstring);
                inScopeTaskList.add(pt);
            }else{
                continue;
            }
        }

        templateTaskMap = new SLT_Project_Task().selectByPricingTaskId(pricingTaskIdSet, new Set<String>{'Id', 'Name', 'Role__c', 'Pricing_Task_ID__c'});

        for(pse__Project_Task__c pt : inScopeTaskList){
            string pricingTaskSubstring = pt.Pricing_Task_ID__c.mid(pt.Pricing_Task_ID__c.indexOf('-')+1,80);
            List<pse__Project_Task__c> templateTaskList = templateTaskMap.get(pricingTaskSubstring);

            if(templateTaskList != null){
                for(pse__Project_Task__c templateTask : templateTaskList){
                    pse__Project_Task__c newTask = cloneTemplateTask(pt, templateTask);
                    projectTaskInsertList.add(newTask);
                }
            }
        }

        if(projectTaskInsertList.size() > 0){
            insert projectTaskInsertList;
        }
    }

    /**
    * This method is used to find the associated pricing tasks used for the deliverable and 
    * create copies of the pricing tasks and link to the deliverable task as sub-tasks
    */
    public static void addPricingTasks(List<pse__Project_Task__c> newList, Map<Id, pse__Project_Task__c> oldMap, Map<String, Set<String>> methodToRecordTypeMap){
        
        Set<String> serviceCodeSet = new Set<String>();
        Set<String> serviceLineSet = new Set<String>();
        Set<Id> projectIdSet = new Set<Id>();
        Set<Id> parentProjectIdSet = new Set<Id>();
        Set<Id> milestoneIdSet = new Set<Id>();
        List<pse__Project_Task__c> projectTaskInsertList = new List<pse__Project_Task__c>();
        List<pse__Project_Task__c> inScopeTaskList = new List<pse__Project_Task__c>();
        List<pse__Project_Task__c> serviceTemplateTaskList = new List<pse__Project_Task__c>();
        List<pse__Project_Task__c> serviceLineTemplateTaskList = new List<pse__Project_Task__c>();

        //key is projectId + Service Code
        Map<String, List<Pricing_Task__c>> keyToPricingTaskListMap = new Map<String, List<Pricing_Task__c>>();

        for(pse__Project_Task__c pt : newList){

            if(methodToRecordTypeMap == null ||
                methodToRecordTypeMap.get('addPricingTasks') == null || 
                pt.RecordTypeId == null ||
                Schema.SObjectType.pse__Project_Task__c.getRecordTypeInfosById().get(pt.RecordTypeId) == null ||
                !methodToRecordTypeMap.get('addPricingTasks').contains(Schema.SObjectType.pse__Project_Task__c.getRecordTypeInfosById().get(pt.RecordTypeId).getDeveloperName()) ) {
                	continue;  //skip record if code not configured for recordtype
            } 
            inScopeTaskList.add(pt);

            if(pt.Service_Code__c != null){
                serviceCodeSet.add(pt.Service_Code__c);
            }
            if(pt.Service_Line__c != null){
                serviceLineSet.add(pt.Service_Line__c);
            }
            if(pt.pse__Project__c != null){
                projectIdSet.add(pt.pse__Project__c);
            }
            if(pt.pse__Milestone__c != null){
                milestoneIdSet.add(pt.pse__Milestone__c);
            }
        }

        if(inScopeTaskList.Size() > 0){

            Map<Id, pse__Proj__c> projectMap = new SLT_Project(false, false).getProjectById(projectIdSet, new Set<String>{'Id', 'pse__Parent_Project__c'});

            for(pse__Proj__c proj : projectMap.values()){
                if(proj.pse__Parent_Project__c != null){
                    parentProjectIdSet.add(proj.pse__Parent_Project__c);
                }
            }

            keyToPricingTaskListMap = new SLT_Pricing_Task().selectTasksByProjectAndServiceCode(parentProjectIdSet, serviceCodeSet);
            serviceTemplateTaskList = new SLT_Project_Task().getTemplateTasksByServiceCode(serviceCodeSet, new Set<String>{'Id', 'Name', 'Service_Line__c', 'Service_Code__c', 'pse__Parent_Task__c', 'Role__c'});
            serviceLineTemplateTaskList = new SLT_Project_Task().getTemplateTasksByServiceLine(serviceLineSet, new Set<String>{'Id', 'Name', 'Service_Line__c', 'Service_Code__c', 'pse__Parent_Task__c', 'Role__c'});
            Map<Id, pse__Milestone__c> milestoneMap = new SLT_Milestone().getMilestoneById(milestoneIdSet, new Set<String>{'Id', 'Service__c', 'Service_Code__c', 'Quantity__c', 'Include_Tasks_On_Deliverables__c'});
            Map<String, String> taskToParentMap = new Map<String, String>();
            
            for(pse__Project_Task__c pt : inScopeTaskList){
                Boolean isEligible = milestoneMap.get(pt.pse__Milestone__c).Include_Tasks_On_Deliverables__c;
                Id parentProjectId = projectMap.get(pt.pse__Project__c).pse__Parent_Project__c;

                if(isEligible && parentProjectId != null){
                    string key = parentProjectId + '-' + pt.Service_Code__c;
                    List<Pricing_Task__c> pricingTaskList = keyToPricingTaskListMap.get(key);
    
                    if(pricingTaskList != null){
                        for(Pricing_Task__c pricingTask : pricingTaskList){
                            pse__Project_Task__c newTask = createTaskFromPricingTask(pricingTask, pt);
                            Decimal soldQuantity = milestoneMap.get(pt.pse__Milestone__c).Quantity__c;
                            newTask.Budgeted_Hours__c =  soldQuantity != null ? newTask.Budgeted_Hours__c / soldQuantity : 0;
                            
                            projectTaskInsertList.add(newTask);
                        }
                    }

                    //add any template tasks associated with the service as well
                    if(serviceTemplateTaskList.size() > 0){
                        for(pse__Project_Task__c projTask : serviceTemplateTaskList){
                            if(pt.Service_Code__c == projTask.Service_Code__c  && pt.Service_Code__c != null){
                                pse__Project_Task__c newTask = cloneTemplateTask(pt, projTask);
                                projectTaskInsertList.add(newTask);
                            }
                        }
                    }

                    //add any template tasks associated with the service lineas well
                    if(serviceLineTemplateTaskList.size() > 0){
                        for(pse__Project_Task__c projTask : serviceLineTemplateTaskList){
                            if(pt.Service_Line__c == projTask.Service_Line__c  && pt.Service_Line__c != null){
                                pse__Project_Task__c newTask = cloneTemplateTask(pt, projTask);
                                taskToParentMap.put(projTask.id, projTask.pse__Parent_Task__c);
                                projectTaskInsertList.add(newTask);
                            }
                        }
                    }
                }
            }

            if(projectTaskInsertList.Size() > 0){
                Savepoint sp = Database.setSavePoint();
                try{
                    insert projectTaskInsertList;

                    //set map for hierarchy lookup
                    Map<String, String> taskTemplateIdToIdMap = new Map<String, String>();
                    for(pse__Project_Task__c pt : projectTaskInsertList){
                        taskTemplateIdToIdMap.put(pt.Template_Task_ID__c, pt.id);
                    }

                    // set parent task and hierarchy
                    for(pse__Project_Task__c pt : projectTaskInsertList){
                        String parentTemplateTask = taskToParentMap.get(pt.Template_Task_ID__c);

                        if(parentTemplateTask != null){
                            pt.pse__Parent_Task__c = taskTemplateIdToIdMap.get(parentTemplateTask);
                        }
                    }
                    update projectTaskInsertList;
                    
                }catch(exception ex){
                    Database.rollback(sp);
                    throw new GeneralException('Error: ' + ex.getMessage());
                }
            }
        }
    }
    
    /**
     * This method updates date offsets for dates the user may have set
     */
    public static List<pse__Project_Task__c> applyDateOffsets(List<pse__Project_Task__c> projectTasks, Map<String, Set<String>> methodToRecordTypeMap){
        List<pse__Project_Task__c> tasksToOffset = new List<pse__Project_Task__c>();
        for(pse__Project_Task__c pt : projectTasks){
            if(methodToRecordTypeMap == null ||
                methodToRecordTypeMap.get('applyDateOffsets') == null || 
                pt.RecordTypeId == null || 
                Schema.SObjectType.pse__Project_Task__c.getRecordTypeInfosById().get(pt.RecordTypeId) == null || 
                !methodToRecordTypeMap.get('applyDateOffsets').contains(Schema.SObjectType.pse__Project_Task__c.getRecordTypeInfosById().get(pt.RecordTypeId).getDeveloperName()) ) {
                	continue;  //skip record if code not configured for recordtype
            } 
            tasksToOffset.add(pt);
        }

        if(tasksToOffset.size() > 0){
            List<pse__Project_Task__c> offsettedTasksList = new List<pse__Project_Task__c>();
            offsettedTasksList = (List<pse__Project_Task__c>)SRV_PSA_Date_Offset.applyDateOffsets(tasksToOffset);
        }
        return projectTasks;
    }

    public static Date updateDateToOffset(Date source, Map<String, PSA_Date_Offset__c> offsetMap, String key){

        Date target = null;
        PSA_Date_Offset__c offSet = offsetMap.get(key);
        if(offSet != null){
            if(offSet.Unit_Type__c == 'Weekday'){
                target = UTL_PSA.calculateEndDate(source, offSet.Offset__c.intValue());
            }else if(offSet.Unit_Type__c == 'Months'){
                target = source.addMonths(offset.Offset__c.intValue());
            }else if(offSet.Unit_Type__c == 'Years'){
                target = source.addYears(offset.Offset__c.intValue());
            }
        }

        return target;

    }

    private static boolean hasPermissionControl(pse__Project_Task__c task, pse__Milestone__c milestone, Map<String, pse__Permission_Control__c> pcMap) {
        boolean userHasPermissionControl = false;
        
        for(pse__Permission_Control__c pc : pcMap.values()){
            if(pc.pse__Project__c != null && pc.pse__Resource__c == task.Resource__c){ 
                userHasPermissionControl = true;
                break;
            }else if(pc.pse__Project__c != null && pc.pse__Project__c == task.pse__Project__c){
                userHasPermissionControl = true;
                break;
            }else if(pc.pse__Project__c != null && pc.pse__Project__c == milestone.pse__Project__r.pse__Parent_Project__c){
                userHasPermissionControl = true;
                break;
            }else if(pc.pse__Region__c != null && pc.pse__Region__c == milestone.pse__Project__r.pse__Region__c){
                userHasPermissionControl = true;
                break;
            }else if(pc.pse__Practice__c != null && pc.pse__Practice__c == milestone.pse__Project__r.pse__Practice__c){
                userHasPermissionControl = true;
                break;
            }else if(pc.pse__Group__c != null && pc.pse__Group__c == milestone.pse__Project__r.pse__Group__c){
                userHasPermissionControl = true;
                break;
            }else if(pc.pse__Region__c != null && pc.pse__Cascading_Permission__c && milestone.pse__Project__r.pse__Region__r.pse__Region_Id_Chain__c.contains(pc.pse__Region__c)){
                userHasPermissionControl = true;
                break;
            }else if(pc.pse__Practice__c != null && pc.pse__Cascading_Permission__c && milestone.pse__Project__r.pse__Practice__r.pse__Practice_Id_Chain__c.contains(pc.pse__Practice__c)){
                userHasPermissionControl = true;
                break;
            }else if(pc.pse__Group__c != null && pc.pse__Cascading_Permission__c && milestone.pse__Project__r.pse__Group__r.pse__Group_Id_Chain__c.contains(pc.pse__Group__c)){
                userHasPermissionControl = true;
                break;
            }
        }

        return userHasPermissionControl;
    }

    private static pse__Project_Task__c createTaskFromPricingTask(Pricing_Task__c pricingTask, pse__Project_Task__c parentTask){
        pse__Project_Task__c returnPT = new pse__Project_Task__c();
        returnPT.recordtypeId = Schema.SObjectType.pse__Project_Task__c.getRecordTypeInfosByDeveloperName().get('RDS_Deliverable_Task').getRecordTypeId();
        returnPT.Name = pricingTask.Name;
        returnPT.pse__Project__c = parentTask.pse__Project__c;
        returnPT.Parent_Project__c = pricingTask.Project__c;
        returnPT.Budgeted_Hours__c = pricingTask.Budget_Hours__c;
        returnPT.Pricing_Task_Id__c = pricingTask.Task_Id__c;
        returnPT.pse__Parent_Task__c = parentTask.id;
        returnPT.pse__Milestone__c = parentTask.pse__Milestone__c;
        returnPT.pse__Start_Date_Time__c = parentTask.pse__Start_Date_Time__c;
        returnPT.pse__End_Date_Time__c = parentTask.pse__End_Date_Time__c;
        returnPT.Service_Line__c = parentTask.Service_Line__c;
        returnPT.pse__Status__c = 'Planned';
        returnPT.Type__c = 'Deliverable Task';
        returnPT.Role__c = pricingTask.Role__c;

        return returnPT;
    }

    private static pse__Project_Task__c cloneTemplateTask(pse__Project_Task__c origTask, pse__Project_Task__c templateTask) {
        pse__Project_Task__c newTask = new pse__Project_Task__c();

        newTask.name = templateTask.name;
        newTask.pse__Project__c = origTask.pse__Project__c;
        newTask.pse__Parent_Task__c = origTask.id;
        newTask.Service_Line__c = origTask.Service_Line__c;
        newTask.pse__Milestone__c = origTask.pse__Milestone__c;
        newTask.RecordTypeId = Schema.SObjectType.pse__Project_Task__c.getRecordTypeInfosByDeveloperName().get('RDS_Deliverable_Task').getRecordTypeId();
        newTask.pse__Start_Date_Time__c = origTask.pse__Start_Date_Time__c;
        newTask.pse__End_Date_Time__c = origTask.pse__End_Date_Time__c;
        newTask.Role__c = templateTask.Role__c;
        newTask.Type__c = 'Deliverable Task';
        newTask.Template_Task_ID__c = templateTask.id;
        newTask.pse__Status__c = 'Planned';

        return newTask;
    }

    private static Set<String>  getDeliverableTargetKeys(pse__Project_Task__c origTask) {
        Set<String> returnList = new Set<String>();
        string programDrug = UTL_PSA.getString(origTask.Program__c) + UTL_PSA.getString(origTask.Drug__c);
        string tradeName = origTask.Trade_Name__c != null ? UTL_PSA.getString(origTask.Trade_Name__c) : '*';
        string formulation = origTask.Formulation__c != null ? UTL_PSA.getString(origTask.Formulation__c) : '*';

        //add wildcards (eg: only progrma and drug populated)
        returnList.add(programDrug + '***'); 
        returnList.add(programDrug + tradeName + '**');
        returnList.add(programDrug + tradeName + formulation + '*');
        returnList.add(programDrug + '*' + formulation + '*');

        
        //add countries...
        List<String> countryString = new List<String>();
        if(origTask.Countries__c != null){
            countryString = origTask.Countries__c.split(';');
        }

        for(String country : countryString){
            returnList.add(programDrug + '**' + country); 
            returnList.add(programDrug + tradeName + '*' + country);
            returnList.add(programDrug + tradeName + formulation + country);
            returnList.add(programDrug + '*' + formulation + country);
        }
        return returnList;
    }
    
    /**
    * This method is used set and perform field updates
    */
    public static void setRDSProjTaskCheck(List<pse__Project_Task__c> newList, Map<Id, pse__Project_Task__c> oldMap, Map<String, Set<String>> methodToRecordTypeMap){
        List<pse__Project_Task__c> inScopeRDSProjTaskList = new List<pse__Project_Task__c>();
        Set<Id> syncSrvcLineLeadProjIdSet = new Set<Id>();

        for(pse__Project_Task__c pt : newList){
			string recordtypeName = Schema.SObjectType.pse__Project_Task__c.getRecordTypeInfosById().get(pt.RecordTypeId).getDeveloperName();
            
            if(recordtypeName == 'RDS_Project_Task'){
                inScopeRDSProjTaskList.add(pt);
                syncSrvcLineLeadProjIdSet.add(pt.pse__Project__c);
            }
            if(trigger.isUpdate && (recordTypeName == 'RDS_Project_Task') && oldMap != null){
                if(oldMap.get(pt.Id)!=null){
                    pse__Project_Task__c oldTask = oldMap.get(pt.Id);
                    if(oldTask.Trigger_Email_Notification__c == True && pt.Trigger_Email_Notification__c == False){
                        if(pt.pse__End_Date_Time__c != null){
                            Date plannedEndDate = pt.pse__End_Date_Time__c.date();
                            if((Date.today()).addDays(5) >=  plannedEndDate){
                                pt.addError('You cannot set this field as false because \'Planned End Date\' is not meeting the criteria to schedule another email. If you want to schedule another email please make sure \'Planned End Date\' is set at least 5 days after current date.');
                            }
                        }
                    }
                }
            }
        }
        if(inScopeRDSProjTaskList.size() > 0){
            Map<Id, pse__Proj__c> projMap = new Map<Id, pse__Proj__c>([select id, Name, Service_Line_Lead__c,pse__Account__r.Name, Service_Line__c from pse__Proj__c WHERE Id in: syncSrvcLineLeadProjIdSet]);
            for(pse__Project_Task__c pt : inScopeRDSProjTaskList){
                if(projMap.get(pt.pse__Project__c) != null){
                    pt.Service_Line_Lead__c = projMap.get(pt.pse__Project__c).Service_Line_Lead__c;
                    pt.Account_Name__c = projMap.get(pt.pse__Project__c).pse__Account__r.Name;
                    pt.Service_Line__c = projMap.get(pt.pse__Project__c).Service_Line__c;
                }
            }
        }
    }
    public static void updateResource(List<pse__Project_Task__c> newList, Map<Id, pse__Project_Task__c> oldMap){
        String previousStatus = '';
        Id RDS_Deliverable_Task_Id = Schema.SObjectType.pse__Project_Task__c.getRecordTypeInfosByDeveloperName().get('RDS_Deliverable_Task').getRecordTypeId();
        for(pse__Project_Task__c pt : newList){
            if(oldMap != null 
               && pt.pse__Actual_End_Date_Time__c == null
               && pt.RecordTypeId == RDS_Deliverable_Task_Id
               && ( pt.Resource__c != null && pt.Resource__c != oldMap.get( pt.Id ).Resource__c ) 
               && ( pt.pse__Status__c == CON_PSA.PROJ_TASK_STATUS_IN_PROGRESS || pt.pse__Status__c == CON_PSA.PROJ_TASK_STATUS_PLANNED ) 
               && ( pt.CreatedDate.Date().daysBetween( pt.pse__End_Date__c ) > 7  || pt.CreatedDate.Date().daysBetween( pt.pse__End_Date__c ) > 3)){
                  previousStatus = pt.pse__Status__c;
                  pt.pse__Status__c = CON_PSA.PROJ_TASK_STATUS_COMPLETE;
                  pt.pse__Status__c = previousStatus;
            }
        }
    }    
    
    /*
     * This method is used to update Project Task's checkbox Activate_Workflow_Rule_Conditionally__c for workflow updation
     * based on certain Project Task's, Parent Project's and Project's field
	*/
    public static void updateConditionForWorkFlow(List<pse__Project_Task__c> newList, Map<Id, pse__Project_Task__c> oldMap) {
        if(!(projectTaskIdsForUpdatingWorkflowCondition.size()>0)){
            Id rdsProjTaskRecordTypeId = Schema.SObjectType.pse__Project_Task__c.getRecordTypeInfosByDeveloperName().get(CON_PSA.RECORD_TYPE_RDS_PROJECT_TASK).getRecordTypeId();
            List<pse__Project_Task__c> projectTaskForWorkflowActivation = new List<pse__Project_Task__c>();
            Set<Id> projectTaskIdsForParentCheck = new Set<Id>();
            Set<Id> projectTaskIdsForWorkflowActivation = new Set<Id>();
            Set<Id> projectIdsForStageCheck = new Set<Id>();
            Map<Id, pse__Proj__c> projectDataMap = new Map<Id, pse__Proj__c>();
            
            if(trigger.isInsert){
                for(pse__Project_Task__c pt : newList){
                    if(pt.Parent_Project__c != null && pt.pse__Project__c != null){
                        if(pt.RecordTypeId == rdsProjTaskRecordTypeId && pt.Trigger_Email_Notification__c == TRUE && pt.pse__End_Date_Time__c > Date.today() && pt.pse__Actual_End_Date__c == null && pt.pse__Status__c != CON_PSA.PROJ_TASK_STATUS_CANCELLED &&  pt.pse__Status__c != CON_PSA.PROJ_TASK_STATUS_COMPLETE && pt.pse__Status__c != CON_PSA.PROJ_TASK_STATUS_NOT_APPLICABLE){
                            projectIdsForStageCheck.add(pt.Parent_Project__c);
                            projectIdsForStageCheck.add(pt.pse__Project__c);
                        }
                    }
                }
                
                //get parent project and project data and then update project tasks
                if(projectIdsForStageCheck.size()>0){
                    projectDataMap = new SLT_Project().getProjectByIdAndCondition(projectIdsForStageCheck, new Set<String>{'Id', 'pse__Stage__c'}, 'pse__Stage__c NOT IN (\'' +CON_PSA.PROJ_STAGE_CANCELED+ '\', \'' +CON_PSA.PROJ_STAGE_COMPLETED+ '\', \'' +CON_PSA.PROJ_STAGE_ON_HOLD+ '\')');
                    for(pse__Project_Task__c pt : newList){
                        if(projectDataMap.get(pt.Parent_Project__c) != null && projectDataMap.get(pt.pse__Project__c) != null){
                            pt.Activate_Workflow_Rule_Conditionally__c = TRUE;
                        }
                    }
                }
            }
            
            if(trigger.isUpdate){
                for(pse__Project_Task__c pt : newList){
                    if(pt.pse__End_Date_Time__c != oldMap.get(pt.Id).pse__End_Date_Time__c || pt.Trigger_Email_Notification__c != oldMap.get(pt.Id).Trigger_Email_Notification__c || pt.pse__Actual_End_Date__c != oldMap.get(pt.Id).pse__Actual_End_Date__c || pt.pse__Status__c != oldMap.get(pt.Id).pse__Status__c){
                        projectTaskIdsForUpdatingWorkflowCondition.add( pt.Id );
                        if(pt.RecordTypeId == rdsProjTaskRecordTypeId && pt.Trigger_Email_Notification__c == TRUE && pt.pse__End_Date_Time__c > Date.today() && pt.pse__Actual_End_Date__c == null && pt.pse__Status__c != CON_PSA.PROJ_TASK_STATUS_CANCELLED &&  pt.pse__Status__c != CON_PSA.PROJ_TASK_STATUS_COMPLETE && pt.pse__Status__c != CON_PSA.PROJ_TASK_STATUS_NOT_APPLICABLE){
                            projectTaskIdsForParentCheck.add(pt.Id);
                        }
                    }
                }
                //to check parent project, project lookup conditions for activating workflow checkbox Activate_Workflow_Rule_Conditionally__c as true
                if(projectTaskIdsForParentCheck.size()>0){
                    projectTaskForWorkflowActivation = new SLT_Project_Task().getProjectTaskByIdAndCondition(projectTaskIdsForParentCheck, new Set<String>{'Id', 'pse__Actual_End_Date_Time__c', 'RecordTypeId', 'pse__End_Date__c', 'Trigger_Email_Notification__c',
                        'Parent_Project__r.RecordTypeId', 'pse__Project__r.RecordTypeId', 'Parent_Project__r.pse__Stage__c',
                        'pse__Status__c', 'pse__End_Date_Time__c', 'pse__Actual_End_Date__c', 'pse__Project__r.pse__Stage__c','Activate_Workflow_Rule_Conditionally__c'}, 'Parent_Project__r.RecordTypeId = :RDS_Project_Id AND pse__Project__r.RecordTypeId = :RDS_Service_Line_Id AND Parent_Project__r.pse__Stage__c NOT IN (:PROJ_STAGE_CANCELED, :PROJ_STAGE_COMPLETED, :PROJ_STAGE_ON_HOLD) AND pse__Project__r.pse__Stage__c NOT IN (:PROJ_STAGE_CANCELED, :PROJ_STAGE_COMPLETED, :PROJ_STAGE_ON_HOLD)');
                    for(pse__Project_Task__c pt : projectTaskForWorkflowActivation){
                        projectTaskIdsForWorkflowActivation.add(pt.Id);
                    }
                }
                //update project task records
                if(projectTaskIdsForUpdatingWorkflowCondition.size()>0){
                    for(pse__Project_Task__c pt : newList){
                        if(projectTaskIdsForWorkflowActivation.contains(pt.Id)){
                            pt.Activate_Workflow_Rule_Conditionally__c = TRUE;
                        }else{
                            pt.Activate_Workflow_Rule_Conditionally__c = FALSE;
                        }
                    }
                }
            }
        }
    }
    public static void updateTriggerPastDueWorkflowField(List<pse__Project_Task__c> newList, Map<Id, pse__Project_Task__c> oldMap){
        for(pse__Project_Task__c pt : newList){
            if((trigger.isInsert || (trigger.isUpdate && (oldMap.get(pt.Id).End_Date_Planned__c != pt.End_Date_Planned__c) 
                                     || (oldMap.get(pt.Id).pse__End_Date__c != pt.pse__End_Date__c) 
                                     || (oldMap.get(pt.Id).Resource__c != pt.Resource__c) 
                                     || (oldMap.get(pt.Id).pse__Status__c != pt.pse__Status__c)))
               && pt.Resource__c != null
               && !pt.Trigger_Past_Due_Workflow__c 
               && pt.pse__Status__c != CON_PSA.PROJ_TASK_STATUS_COMPLETE 
               &&(((pt.recordTypeId == CON_PSA.RDS_DELIVERABLE_TASK_RECORD_TYPE_ID || pt.recordTypeId == CON_PSA.RDS_PROJECT_TASK_RECOR_TYPE_ID)
                   && pt.pse__End_Date__c <= System.today())
                  ||(pt.recordTypeId == CON_PSA.RDS_DELIVERABLE_RECORD_TYPE_ID 
                     && pt.End_Date_Planned__c <= System.today()))
              ){
                  pt.Trigger_Past_Due_Workflow__c = TRUE;
              }
        }
    }
    public class GeneralException extends Exception {}
    
}
