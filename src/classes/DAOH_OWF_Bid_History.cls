public class DAOH_OWF_Bid_History {

public static Integer toEmailCounter = 1;
        
public static void setNoOfRequestedServicesBasedOnRequestedServices(List<Bid_History__c> newList, Map<Id, Bid_History__c> oldMap) {
        for(Bid_History__c agreement : newList) {
            if(oldMap == null || (oldMap != null && agreement.Requested_Services__c != oldMap.get(agreement.Id).Requested_Services__c)) {
                if(String.IsNotBlank(agreement.Requested_Services__c)) {
                    agreement.Number_of_Requested_Services__c = agreement.Requested_Services__c.split(CON_OWF.SEMI_COLON).size();
                }else {
                    agreement.Number_of_Requested_Services__c = 0;
                }
            }
            // IQVIAPSA-5060 RFP Ranking Mapping to Opportunity Type
            if((oldMap == null || (oldMap != null && agreement.Opportunity_Type__c != oldMap.get(agreement.Id).Opportunity_Type__c)) && agreement.RecordTypeId == CON_OWF.OWF_CLINICAL_BID_BID_HISTORY_RECORD_TYPE_ID){
                if(agreement.Opportunity_Type__c=='Price per Pt'){
                    agreement.RFP_Ranking__c = '1';
                }else if (agreement.Opportunity_Type__c=='BTS Ballpark'){
                    agreement.RFP_Ranking__c = '2';
                }else if (agreement.Opportunity_Type__c=='Ballpark requiring IQVIA-defined C/S/P strategy' || agreement.Opportunity_Type__c=='Limited service RFP (non-Clinical, non-FSP)'){
                    agreement.RFP_Ranking__c = '3';
                }else if (agreement.Opportunity_Type__c=='Full service RFP' || agreement.Opportunity_Type__c=='FSP_Skill'){
                    agreement.RFP_Ranking__c = '4';
                }else if (agreement.Opportunity_Type__c=='Program or Strategic Partnership'){
                    agreement.RFP_Ranking__c = '5';
                }
            }
        }
    }
    
    /**
* This method is used to set Bid# based on Agreement Record Type.
* @params  newList List<Bid_History__c>
* @return  void
*/
    public static void setBidNoBasedOnRecordType(List<Bid_History__c> newList) {
        //Get Agreement_Type_Bid_Mapping custom metadata to get Bid# intialization for Agreement Type
        Set<String> agreementTypeBidMappFieldSet = new Set<String>{'DeveloperName', 'MasterLabel', 'Bid_No__c', 'Is_Incremental__c'};
            Map<String, Agreement_Type_Bid_Mapping__mdt> agreementTypeBidMappingByNameMap = new Map<String, Agreement_Type_Bid_Mapping__mdt>();
        Set<String> incrementalTypeAgreementTypeSet = new Set<String>();
        for(Agreement_Type_Bid_Mapping__mdt agrTypeBidMapping : new SLT_Agreement_Type_Bid_Mapping(false, false).getAgreementTypeBidMappings(agreementTypeBidMappFieldSet)) 
        {
            
            agreementTypeBidMappingByNameMap.put(agrTypeBidMapping.DeveloperName, agrTypeBidMapping);
            if(agrTypeBidMapping.Is_Incremental__c) {
                incrementalTypeAgreementTypeSet.add(agrTypeBidMapping.DeveloperName);
            }
        }
        
        //Get a map of Record types for APTS_Agreement object
        Map<Id, RecordType> agreementRecordTypeIdToRecordTypeMap = new Map<Id, RecordType>(new SLT_ProcessInstanceWorkitem().getRecordTypesBySObjectType(CON_OWF.SOBJECT_TYPE_Bid_History));
        Map<Id, List<Bid_History__c>> agreementRecordTypeToAgreementsMap = new Map<Id, List<Bid_History__c>>();
        Set<Id> oppIdswithAgreementsSet = new Set<Id>();
        for(Bid_History__c agreement : newList) {
            
            if(!agreementRecordTypeToAgreementsMap.containsKey(agreement.RecordTypeId)) {
                agreementRecordTypeToAgreementsMap.put(agreement.RecordTypeId, new List<Bid_History__c>());    
            }
            agreementRecordTypeToAgreementsMap.get(agreement.RecordTypeId).add(agreement);
            if(agreementRecordTypeIdToRecordTypeMap.containsKey(agreement.RecordTypeId) 
               && incrementalTypeAgreementTypeSet.contains(agreementRecordTypeIdToRecordTypeMap.get(agreement.RecordTypeId).DeveloperName)) {
                   oppIdswithAgreementsSet.add(agreement.Bid_History_Related_Opportunity__c);
               }
        }
        
        Map<Id, Map<String, decimal>> oppIdToAgrRecordTypeWithRecentAgrBidNumberMap = new Map<Id, Map<String, decimal>>();
        if(!oppIdswithAgreementsSet.isEmpty()) {
            Set<String> oppfieldSet = new Set<String>{'Id'};
            Set<String> agreementFieldSet = new Set<String>{'Id', 'Bid_Number__c', 'RecordType.DeveloperName'};
            Map<Id, Opportunity> oppIdToOppWithAgreementsMap = new SLT_Opportunity(false, false).selectByIdWithOpportuntiyBidHistory(oppIdswithAgreementsSet, oppfieldSet, agreementFieldSet);
            for(Id oppId : oppIdToOppWithAgreementsMap.keySet()) {
                if(oppIdToOppWithAgreementsMap.get(oppId).Bid_Histories_Opportunity__r.size() > 0) {
                    if(!oppIdToAgrRecordTypeWithRecentAgrBidNumberMap.containsKey(oppId)) {
                        oppIdToAgrRecordTypeWithRecentAgrBidNumberMap.put(oppId, new Map<String, decimal>());
                    }
                    for(Bid_History__c agreement : oppIdToOppWithAgreementsMap.get(oppId).Bid_Histories_Opportunity__r) {
                        if(incrementalTypeAgreementTypeSet.contains(agreement.RecordType.DeveloperName) && !oppIdToAgrRecordTypeWithRecentAgrBidNumberMap.get(oppId).containsKey(agreement.RecordType.DeveloperName)) {
                            oppIdToAgrRecordTypeWithRecentAgrBidNumberMap.get(oppId).put(agreement.RecordType.DeveloperName, agreement.Bid_Number__c);
                        }else if(incrementalTypeAgreementTypeSet.contains(agreement.RecordType.DeveloperName) && oppIdToAgrRecordTypeWithRecentAgrBidNumberMap.get(oppId).get(agreement.RecordType.DeveloperName) < agreement.Bid_Number__c){
                            oppIdToAgrRecordTypeWithRecentAgrBidNumberMap.get(oppId).put(agreement.RecordType.DeveloperName, agreement.Bid_Number__c);
                        }
                    }
                }
            }
        }
        
        for(Id agrRecTypeId : agreementRecordTypeToAgreementsMap.keySet()) {
            if(agreementRecordTypeIdToRecordTypeMap.containsKey(agrRecTypeId) 
               && agreementTypeBidMappingByNameMap.containsKey(agreementRecordTypeIdToRecordTypeMap.get(agrRecTypeId).DeveloperName)) {
                   
                   if(!incrementalTypeAgreementTypeSet.contains(agreementRecordTypeIdToRecordTypeMap.get(agrRecTypeId).DeveloperName)) {
                       for(Bid_History__c agreement : agreementRecordTypeToAgreementsMap.get(agrRecTypeId)) {
                           agreement.Bid_Number__c = agreementTypeBidMappingByNameMap.get(agreementRecordTypeIdToRecordTypeMap.get(agrRecTypeId).DeveloperName).Bid_No__c;
                       }
                   }else {
                       Id oppId = agreementRecordTypeToAgreementsMap.get(agrRecTypeId).get(0).Bid_History_Related_Opportunity__c;
                       Decimal agreementBidNo = agreementTypeBidMappingByNameMap.get(agreementRecordTypeIdToRecordTypeMap.get(agrRecTypeId).DeveloperName).Bid_No__c;
                       if(oppIdToAgrRecordTypeWithRecentAgrBidNumberMap.containsKey(oppId)) {
                           if(oppIdToAgrRecordTypeWithRecentAgrBidNumberMap.get(oppId).containsKey(agreementRecordTypeIdToRecordTypeMap.get(agrRecTypeId).DeveloperName)) {
                               agreementBidNo = oppIdToAgrRecordTypeWithRecentAgrBidNumberMap.get(oppId).get(agreementRecordTypeIdToRecordTypeMap.get(agrRecTypeId).DeveloperName) + 1;
                           }
                       }
                       for(Bid_History__c agreement : agreementRecordTypeToAgreementsMap.get(agrRecTypeId)) {
                           agreement.Bid_Number__c = agreementBidNo;
                           agreementBidNo++;
                       }
                   }
               }
        }

    }
    public static void setQueueAsOwneronQ2RecordType(List<Bid_History__c> newList, Map<Id, Bid_History__c> oldMap){
        Set<Id> bidIds = new Set<Id>();
        for(Bid_history__c bid: newList){
            if(bid.RecordTypeId == CON_OWF.OWF_Q2_Solutions_BID_HISTORY_RECORD_TYPE_ID){
                bidIds.add(bid.id);
            }
        }
        if(!bidIds.isEmpty()){
        List<Group> Q2UsersQueue = new SLT_Groups(false,false).getGroupByDevelopernameSet(new Set<String>{'Id'},new Set<String>{'Q2_Unassigned'});
        for(Bid_History__c bid:newList){
            if(!Q2UsersQueue.isEmpty() && bid.RecordTypeId == CON_OWF.OWF_Q2_Solutions_BID_HISTORY_RECORD_TYPE_ID && (Trigger.isInsert || (Trigger.isUpdate && bid.Submit_to_Proposals__c != oldMap.get(bid.id).Submit_to_Proposals__c)) && bid.Submit_to_Proposals__c == CON_OWF.OWF_BID_HISTORY_SUBMIT_TO_PROPOSALS_TRUE  && bid.Q2_Business_Area__c == CON_OWF.Q2_BUSINESS_AREA){
                bid.OwnerId = Q2UsersQueue[0].Id;
            }
            else if(!q2UsersQueue.isEmpty() && bid.RecordTypeId == CON_OWF.OWF_Q2_Solutions_BID_HISTORY_RECORD_TYPE_ID 
                    && Trigger.isInsert 
                    && CON_OWF.Q2_BUSINESS_AREA_LIST.contains(bid.Q2_Business_Area__c))
            {
                bid.OwnerId = q2UsersQueue[0].Id; 
                
            }
        }
        }
        
    }																												   									   
    
    /**
* This method is used to set Number of Requested Services based on selected Requested Services.
* @params  newList List<Bid_History__c>
* @params  oldMap Map<Id, Bid_History__c>
* @return  void
*/
    public static void setEndDateAndStatusOnProjectResReqsAndAssignments(List<Bid_History__c> newList, Map<Id, Bid_History__c> oldMap) {
        Map<Id, Bid_History__c> agreementIdToAgreementMap = new Map<Id, Bid_History__c>();
         CON_OWF.BYPASS_VALIDATION_RULE_RR = true;
        for(Bid_History__c agreement : newList) {
            if(agreement.Bid_Due_Date__c != oldMap.get(agreement.Id).Bid_Due_Date__c && agreement.Bid_Due_Date__c != NULL) {
                agreementIdToAgreementMap.put(agreement.Id, agreement);
            }
        }
        Map<Id, Bid_History__c> agrIdToAgrWithRelatedRecords = new Map<Id, Bid_History__c>();
        if(!agreementIdToAgreementMap.isEmpty()) {
            Set<String> agreementFieldSet = new Set<String>{'Id'};
                Set<String> projectFieldSet = new Set<String>{'Id', 'pse__End_Date__c', 'pse__Project_Status__c'};
                    Set<String> resRequestFieldSet = new Set<String>{'Id', 'pse__End_Date__c','is_Bid_Defense__c', 'pse__Status__c','pse__Assignment__c','pse__Staffer_Resource__r.pse__Is_Resource_Active__c','pse__Staffer_Resource__r.pse__Is_Resource__c','pse__Assignment__r.pse__Status__c','SubGroup__c','Regional_Analytics_Country__c','pse__Assignment__c'}; 
                        Set<String> assignmentFieldSet = new Set<String>{'Id', 'pse__End_Date__c', 'pse__Status__c', 'pse__Schedule__c','pse__Resource_Request__r.is_Bid_Defense__c','pse__Resource__r.pse__Is_Resource_Active__c','pse__Resource__r.pse__Is_Resource__c','pse__Resource_Request__r.Regional_Analytics_Country__c','Subgroup_Name__c','pse__Resource_Request__c.SubGroup__c'};
                            agrIdToAgrWithRelatedRecords = new SLT_Bid_History(false,false).selectByIdWithAgreementAndProjsResReqsAssignments(agreementIdToAgreementMap.keySet(), agreementFieldSet, projectFieldSet, resRequestFieldSet, assignmentFieldSet);
        }
        //Initialize list of objects to update records
        List<pse__Proj__c> projectsUpdateList = new List<pse__Proj__c>();
        List<pse__Resource_Request__c> resourceRequestsUpdateList = new List<pse__Resource_Request__c>();
        List<pse__Assignment__c> assignmentsUpdateList = new List<pse__Assignment__c>();
        List<pse__Schedule__c> assignmentScheduleUpdateList = new List<pse__Schedule__c>();
        
        //Iterating loop over Agreement Ids set and updating End_Date and Status on related records based on Agreement's Bid_Due_Date and Status respectively
        for(Id agrId : agreementIdToAgreementMap.keySet()) {
            if(agrIdToAgrWithRelatedRecords.containsKey(agrId)) {
                Date agrBidDueDate = agreementIdToAgreementMap.get(agrId).Bid_Due_Date__c;
                //Validating if Projects exist under Agreements then iterate over Projects and update End Date
                if(agrIdToAgrWithRelatedRecords.get(agrId).Bid_History__r.size() > 0) {
                    for(pse__Proj__c project : agrIdToAgrWithRelatedRecords.get(agrId).Bid_History__r) {
                        project.pse__End_Date__c = agrBidDueDate;
                        projectsUpdateList.add(project);
                    }
                }
                //Validating if Resource_Requests exist under Agreements then iterate over Projects and update End Date & Status
                for(pse__Resource_Request__c resRquest : agrIdToAgrWithRelatedRecords.get(agrId).Bid_History_Resource_Requests__r) {
                    if(!resRquest.is_Bid_Defense__c && (((resRquest.SubGroup__c == CON_OWF.RES_REQ_TYPE_GBO_LEAD_PD || resRquest.SubGroup__c == CON_OWF.RES_REQ_TYPE_GBO_LEAD_CONTRACTS_ANALYST) && UTL_OWF.bidUpdatedFromAgreement) || !UTL_OWF.bidUpdatedFromAgreement) && (resRquest.pse__Status__c != 'Cancelled' && resRquest.pse__Status__c != 'Closed') && resRquest.pse__Staffer_Resource__r.pse__Is_Resource_Active__c == true && resRquest.pse__Staffer_Resource__r.pse__Is_Resource__c == true
                        && ((resRquest.SubGroup__c != CON_OWF.RES_REQ_TYPE_Clinical_Coding && resRquest.SubGroup__c != CON_OWF.RES_REQ_TYPE_GBO_BID_GRID && (resRquest.SubGroup__c != CON_OWF.RES_REQ_TYPE_GLOBAL_ANALYTICS 
                             || resRquest.Regional_Analytics_Country__c == CON_OWF.RA_COUNTRY_TYPE_STRATEGIC_ANALYTICS)) || (resRquest.pse__Assignment__c == null || (resRquest.pse__Assignment__c != null
                             && resRquest.pse__Assignment__r.pse__Status__c != CON_OWF.OWF_ASSIGNMENT_STATUS_ACCEPTED && resRquest.pse__Assignment__r.pse__Status__c != CON_OWF.OWF_ASSIGNMENT_STATUS_COMPLETED)))){
                          if(resRquest.SubGroup__c == CON_OWF.RES_REQ_TYPE_IG_LEAD) {
                              resRquest.pse__End_Date__c = UTL_OWF.subtractBusinessDays(agrBidDueDate, 2);
                          }
                          else {
                              resRquest.pse__End_Date__c = agrBidDueDate;
                          }
                        if(agrBidDueDate == system.today() && resRquest.pse__Status__c == CON_OWF.OWF_STATUS_ASSIGNED && resRquest.pse__Assignment__c !=null) {
                            resRquest.pse__Status__c = CON_OWF.OWF_STATUS_COMPLETED;
                        }else if(agrBidDueDate > system.today() && resRquest.pse__Status__c == CON_OWF.OWF_STATUS_COMPLETED && resRquest.pse__Assignment__c !=null) {
                            resRquest.pse__Status__c = CON_OWF.OWF_STATUS_ASSIGNED;
                        }
                        resourceRequestsUpdateList.add(resRquest);
                    }
                }
                //Validating if Assignments exist under Agreements then iterate over Projects and update End Date & Status
                for(pse__Assignment__c assignment : agrIdToAgrWithRelatedRecords.get(agrId).Bid_History_Assignments__r) {
                    //Validating if Assignment have Schedule populated then updating End_Date based on Argument's Bid_Due_Date
                    if((!assignment.pse__Resource_Request__r.is_Bid_Defense__c && (assignment.pse__Status__c == 'Accepted' || assignment.pse__Status__c == 'Pending' || assignment.pse__Status__c == 'Completed')
                        && assignment.pse__Resource__r.pse__Is_Resource_Active__c == true && assignment.pse__Resource__r.pse__Is_Resource__c == true) && assignment.pse__Schedule__c != NULL && (((assignment.Subgroup_Name__c == CON_OWF.RES_REQ_TYPE_GBO_LEAD_PD || assignment.Subgroup_Name__c == CON_OWF.RES_REQ_TYPE_GBO_LEAD_CONTRACTS_ANALYST) && UTL_OWF.bidUpdatedFromAgreement) || !UTL_OWF.bidUpdatedFromAgreement) &&
                        ((assignment.Subgroup_Name__c != CON_OWF.RES_REQ_TYPE_Clinical_Coding && assignment.Subgroup_Name__c != CON_OWF.RES_REQ_TYPE_GBO_BID_GRID && (assignment.Subgroup_Name__c != CON_OWF.RES_REQ_TYPE_GLOBAL_ANALYTICS ||
                            assignment.pse__Resource_Request__r.Regional_Analytics_Country__c == CON_OWF.RA_COUNTRY_TYPE_STRATEGIC_ANALYTICS)) || 
                           	(assignment.pse__Status__c != CON_OWF.OWF_ASSIGNMENT_STATUS_ACCEPTED && assignment.pse__Status__c != CON_OWF.OWF_ASSIGNMENT_STATUS_COMPLETED))) {
                            assignmentScheduleUpdateList.add(new pse__Schedule__c(Id = assignment.pse__Schedule__c, pse__End_Date__c = agrBidDueDate));
                        }
                    if((!assignment.pse__Resource_Request__r.is_Bid_Defense__c && (assignment.pse__Status__c == 'Accepted' || assignment.pse__Status__c == 'Pending' || assignment.pse__Status__c == 'Completed')
                        && assignment.pse__Resource__r.pse__Is_Resource_Active__c == true && assignment.pse__Resource__r.pse__Is_Resource__c == true) && agrBidDueDate == system.today() && assignment.pse__Status__c == CON_OWF.OWF_STATUS_ACCEPTED) {
                            assignment.pse__Status__c = CON_OWF.OWF_STATUS_COMPLETED;
                        }
                    else if((!assignment.pse__Resource_Request__r.is_Bid_Defense__c && (assignment.pse__Status__c == 'Accepted' || assignment.pse__Status__c == 'Pending' || assignment.pse__Status__c == 'Completed')
                             && assignment.pse__Resource__r.pse__Is_Resource_Active__c == true && assignment.pse__Resource__r.pse__Is_Resource__c == true) && agrBidDueDate > system.today() && assignment.pse__Status__c == CON_OWF.OWF_STATUS_COMPLETED) {
                                 assignment.pse__Status__c = CON_OWF.OWF_STATUS_ACCEPTED;
                             }
                    assignmentsUpdateList.add(assignment);
                }
            }
        }
        
        if(projectsUpdateList.size() > 0) {
            update projectsUpdateList;
        }
        
        if(resourceRequestsUpdateList.size() > 0) {
            update resourceRequestsUpdateList;
        }
        
        if(assignmentScheduleUpdateList.size() > 0) {
            update assignmentScheduleUpdateList;
        }
        
        if(assignmentsUpdateList.size() > 0) {
            update assignmentsUpdateList;
        }
    }
    
    /**
* This method is used to create project (pse__proj__c) record on insert of an Agreement.
* @params  newList List<Bid_History__c>
* @params  oldMap Map<Id, Bid_History__c>
* @return  
*/
    public static void createProjectBasedOnAgreement(List<Bid_History__c> newList) {
        List<pse__proj__c> projectsToBeInsertedList = new List<pse__proj__c>();
        projectsToBeInsertedList = returnProjectBasedOnAgreement(newList);
        if(projectsToBeInsertedList.size() > 0) {
            insert projectsToBeInsertedList;
        }
    }
    /**
* This method is used to create project (pse__proj__c) record on insert of an Agreement.
* @params  newList List<Bid_History__c>
* @params  oldMap Map<Id, Bid_History__c>
* @return  projectsToBeReturnedList List<pse__proj__c>
*/
    private static List<pse__Proj__c> returnProjectBasedOnAgreement(List<Bid_History__c> newList) {
        List<pse__proj__c> projectsToBeReturnedList = new List<pse__proj__c>();
        OWF_Config__c owfConfig = OWF_Config__c.getOrgDefaults();
        String owfStdGroupId = '';
        if(owfConfig != null) {
            owfStdGroupId = owfConfig.OWF_Standard_Group__c;
        }
        for(Bid_History__c agr : newList) {
            if(CON_OWF.OWF_AGREEMENT_RECORD_TYPE_BID_HISTORY.contains(agr.recordTypeId)) {
                pse__proj__c project = new pse__proj__c(
                    recordTypeId = CON_OWF.OWF_BID_PROJECT_RECORD_TYPE_ID,
                    name = agr.name,
                    currencyIsoCode = agr.currencyIsoCode,
                    pse__Start_Date__c = Date.today(),
                    pse__End_Date__c = agr.Bid_Due_Date__c,
                    Bid_History__c = agr.id,
                    pse__Opportunity__c = agr.Bid_History_Related_Opportunity__c,
                    pse__Account__c = agr.Bid_History_Account__c,
                    pse__Group__c = owfStdGroupId
                );
                projectsToBeReturnedList.add(project); 
            }
        }
        return projectsToBeReturnedList;
    }    
    
    /**
* This method is used to delete project (pse__proj__c) record based on Agreement.
* @params  newList List<Bid_History__c>
* @return  
*/
    public static void deleteProjectBasedOnAgreement(List<Bid_History__c> newList) {
        List<pse__proj__c> projectsToBeDeletedList = new List<pse__proj__c>();
        projectsToBeDeletedList = returnProjectBasedOnAgr(newList);
        if(projectsToBeDeletedList.size() > 0) {
            QBL_OWF_DeletionLogic.QueueProjectDeletion   queuableObject = new QBL_OWF_DeletionLogic.QueueProjectDeletion  (projectsToBeDeletedList);
            System.enqueueJob(queuableObject);
        }
    }
    
    /**
* This method is used to create Resource Request for Clinical Bids
* @params  newList List<Bid_History__c>
* @params  oldMap Map<Id, Bid_History__c>
*/
    public static void createClinicalBidResRequestsOnAgreementUpdate(List<Bid_History__c> newList, Map<Id, Bid_History__c> oldMap) {
        Set<Id> agreementOppIdsSet = new set<Id>();
        Set<Id> rebidAgreementOppIdsSet = new Set<Id>();
        List<Id> InitialBidIdSet = new List<Id>();
        List<Id> rebidIdSet = new List<Id>();
        for(Bid_History__c agrmt : newList) {
            if((agrmt.Bid_Due_Date__c != oldMap.get(agrmt.Id).Bid_Due_Date__c || agrmt.Requested_Services__c != oldMap.get(agrmt.Id).Requested_Services__c
               || agrmt.Targeted_Countries__c != oldMap.get(agrmt.Id).Targeted_Countries__c || agrmt.Budget_Deliverable__c != oldMap.get(agrmt.Id).Budget_Deliverable__c
               || agrmt.Grid_Ranking_Level__c !=  oldMap.get(agrmt.Id).Grid_Ranking_Level__c || agrmt.Is_there_a_Client_Bid_Grid__c !=  oldMap.get(agrmt.Id).Is_there_a_Client_Bid_Grid__c
               || agrmt.Estimated_Fees__c !=  oldMap.get(agrmt.Id).Estimated_Fees__c || agrmt.Additional_Services_Requested__c !=  oldMap.get(agrmt.Id).Additional_Services_Requested__c 
               || agrmt.RFP_Ranking__c !=  oldMap.get(agrmt.Id).RFP_Ranking__c) && agrmt.RecordTypeId ==  CON_OWF.OWF_CLINICAL_BID_BID_HISTORY_RECORD_TYPE_ID)
            {
              if(agrmt.Bid_Due_Date__c >= Date.today() && (agrmt.Bid_Stopped__c == null || agrmt.Bid_Stopped__c == 'No')){																											
                if(agrmt.Bid_Number__c == 1){
                    agreementOppIdsSet.add(agrmt.Bid_History_Related_Opportunity__c);
                    InitialBidIdSet.add(agrmt.Id);													  
                }else if(agrmt.Bid_Number__c > 1){
                    rebidAgreementOppIdsSet.add(agrmt.Bid_History_Related_Opportunity__c);
                    rebidIdSet.add(agrmt.Id);												 
                }
              }
            }
          
        }
        List<pse__Resource_Request__c> reqRequestsInsertList = new List<pse__Resource_Request__c>();
        List<pse__Resource_Request__c> reqRequestsInsertListRebid = new List<pse__Resource_Request__c>();
        if(agreementOppIdsSet.size() > 0) {
            String bidIds = String.join(InitialBidIdSet, '\',\'') +'\'';
            String agrCondition = 'Bid_History_Related_Opportunity__c != NULL And Bid_History_Related_Opportunity__c IN :sObjectIdSet and Id in ( \'' + bidIds +
                ') And RecordTypeId = \'' + CON_OWF.OWF_CLINICAL_BID_BID_HISTORY_RECORD_TYPE_ID + '\'';
            reqRequestsInsertList = UTL_OWF.processResRequestForInitialBids(agreementOppIdsSet, agrCondition, null, null);

        }
		if(rebidAgreementOppIdsSet.size() >0)
        {
            String bidIds = String.join(rebidIdSet, '\',\'') +'\'';
            String agrCondition = 'Bid_History_Related_Opportunity__c != NULL And Bid_History_Related_Opportunity__c IN :sObjectIdSet and Id in ( \'' + bidIds +
             ') And RecordTypeId = \'' + CON_OWF.OWF_CLINICAL_BID_BID_HISTORY_RECORD_TYPE_ID + '\'';
            reqRequestsInsertListRebid = UTL_OWF.processResRequestForClinicalReBids(rebidAgreementOppIdsSet, agrCondition,reqRequestsInsertList);
        }
        reqRequestsInsertList.addAll(reqRequestsInsertListRebid);    

		if(reqRequestsInsertList.size()>0)
        {
            insert reqRequestsInsertList;
        }
        
    }
    
    private static List<pse__Proj__c> returnProjectBasedOnAgr(List<Bid_History__c> newList) {
        List<pse__proj__c> projectsToBeReturnedList = new List<pse__proj__c>();
        Set<String> projectFieldSet = new Set<String>{'Id'};
        Map<Id, Bid_History__c> agreementIdToAgreementMap= new Map<Id, Bid_History__c>();
        for(Bid_History__c agreement : newList)
        {
            agreementIdToAgreementMap.put(agreement.ID, agreement );
        }
        
        Map<Id, pse__proj__c> prjIdToProjectMap = new SLT_Project(false,false).getProjectByBidHistoryID(agreementIdToAgreementMap.keySet(),projectFieldSet );
        projectsToBeReturnedList  = prjIdToProjectMap .values();
        return projectsToBeReturnedList;
    } 

    
    /**
* This method is used to update Complexity Score Total on RR.
* @params  newList List<Bid_History__c>
* @params  oldMap Map<Id, Bid_History__c>
* @return  void
*/
    public static void updateComplexityScoreTotalOnRR(List<Bid_History__c> newList, Map<Id, Bid_History__c> oldMap) {     
         CON_OWF.BYPASS_VALIDATION_RULE_RR = true;
        Set<Id> rrAgreementIdSet = new Set<Id>();
        Set<Id> oppIdSet = new Set<Id>();
        Map<Id, Bid_History__c> agrIdToAgreementMap = new Map<Id, Bid_History__c>();
        Map<String,OWF_Resource_Setting__mdt> resSettingIdToResSettingMap = new Map<String,OWF_Resource_Setting__mdt>(); 
        List<pse__Resource_Request__c> rrList = new List<pse__Resource_Request__c>();
        List<pse__Resource_Request__c> rrWithCSTList = new List<pse__Resource_Request__c>();
        List<pse__Resource_Request__c> toBeUpdatedRRList = new List<pse__Resource_Request__c>();
        Set<String> orsFieldSet = new Set<String>{'Id','Sub_Group__c', 'Estimated_Fees__c','Is_there_a_Client_Bid_Grid__c','Number_of_Sites__c',
            'Potential_Regions__c','Project_Ex_Number_of_Unique_Tables__c','Re_Bid_Complexity__c',
            'Requested_Services__c','RFP_Ranking__c','Staffing_Number_of_Unique_Tables__c','Country__c'};
                for(Bid_History__c agr : newList) {
                    if(agr.RFP_Ranking__c != oldMap.get(agr.id).RFP_Ranking__c 
                       ||agr.Number_of_Sites__c != oldMap.get(agr.id).Number_of_Sites__c
                       ||agr.Estimated_Fees__c != oldMap.get(agr.id).Estimated_Fees__c
                       ||agr.Re_bid_Complexity__c != oldMap.get(agr.id).Re_bid_Complexity__c
                       ||agr.Is_there_a_Client_Bid_Grid__c != oldMap.get(agr.id).Is_there_a_Client_Bid_Grid__c
                       ||agr.Number_of_Requested_Services__c != oldMap.get(agr.id).Number_of_Requested_Services__c
                       ||agr.Staffing_Number_of_Unique_Tables__c != oldMap.get(agr.id).Staffing_Number_of_Unique_Tables__c
                       ||agr.Project_Ex_Number_of_Unique_Tables__c != oldMap.get(agr.id).Project_Ex_Number_of_Unique_Tables__c
                       || agr.Grid_Ranking_Level__c != oldMap.get(agr.id).Grid_Ranking_Level__c ) {
                           
                           rrAgreementIdSet.add(agr.id);
                           oppIdSet.add(agr.Bid_History_Related_Opportunity__c);
                       }                                        
                }   
        
        if(rrAgreementIdSet.size() > 0 && oppIdSet.size() > 0) {
            //IQVIAPSA-2165 == start
            Set<String> agrFieldSet = new Set<String>{'Id', 'Name','RFP_Ranking__c','Number_of_Sites__c','Re_Bid_Complexity__c',
                'Estimated_Fees__c','Is_there_a_Client_Bid_Grid__c','Number_of_Requested_Services__c',
                'Staffing_Number_of_Unique_Tables__c','Triage_Level__c','Project_Ex_Number_of_Unique_Tables__c',
                'Bid_History_Related_Opportunity__r.Number_of_Potential_Regions__c','Bid_History_Related_Opportunity__r.Potential_Regions__c',
                'Bid_History_Related_Opportunity__c','Bid_Due_Date__c','Bid_History_Related_Opportunity__r.Bid_Defense_Date__c',
                'CreatedDate','Grid_Ranking_Level__c'};
             //IQVIAPSA-2165 == stop
                    Set<String> resReqFieldSet = new Set<String>{'Id', 'pse__Opportunity__c','Bid_History__c', 'Resource_Request_Type__c', 'Complexity_Score_Total__c', 'SubGroup__c',
                        'CreatedDate','Workload_Ranking__c','Suggested_FTE__c','pse__Start_Date__c',
                        'pse__Start_Date__c','pse__End_Date__c', 'Is_Bid_Defense__c','pse__Status__c','Regional_Analytics_Country__c','pse__Assignment__c'};
                            
                            String agrCondition = 'Bid_History_Related_Opportunity__c != NULL And Bid_History_Related_Opportunity__c IN :sObjectIdSet ';
            String resReqCondition = 'pse__Opportunity__c != NULL And Bid_History__c != NULL';
            agrIdToAgreementMap = new SLT_Bid_History(false,false).getAgreementAndResReqsByOppId(oppIdSet, agrFieldSet, resReqFieldSet, agrCondition, resReqCondition);                            
            
            for(Bid_History__c agr : agrIdToAgreementMap.values()) {
              if(rrAgreementIdSet.contains(agr.Id) && agr.Bid_Due_Date__c >= Date.today()){
                for(pse__Resource_Request__c rr: agr.Bid_History_Resource_Requests__r){
                    rrList.add(rr);
                }					
              }
            }
            
            for(OWF_Resource_Setting__mdt rsCMT : new SLT_OWF_Resource_Setting(false, false).getOWFResourceSettingRecords(orsFieldSet)) {
                resSettingIdToResSettingMap.put(rsCMT.Sub_Group__c,rsCMT); 
            }
            if(resSettingIdToResSettingMap.size() > 0) {
                rrWithCSTList = UTL_OWF.calculateComplexityScoreTotal(agrIdToAgreementMap,resSettingIdToResSettingMap,rrList);
                toBeUpdatedRRList = UTL_OWF.calculateWRandSuggestedFTE(agrIdToAgreementMap,rrWithCSTList);
                if(toBeUpdatedRRList.size() > 0) {
                    try
                    {
                        update toBeUpdatedRRList;   
                    }
                    Catch(Exception E){
                        newList[0].addError('An Error occurred: ' + e.getMessage().substringAfter('FIELD_CUSTOM_VALIDATION_EXCEPTION,').substringBefore(': []'));
                    }
                }
            }
        }
    }    
    
    /**
* This method is used to do calculation on RR based using OWF Assignment Setting CMT and Resource_Request_Name on RR based on modified Resource_Rquest_Type field
* @params  List<Bid_History__c> newList
* @params  Map<Id, Bid_History__c> oldMap
* @return  void
*/
    public static void updateDataBasedOnOasSetting(List<Bid_History__c> newList, Map<Id, Bid_History__c> oldMap) {
        Set<Id> rrAgreementIdSet = new Set<Id>();
        Map<Id, Bid_History__c> agrIdToAgreementMap = new Map<Id, Bid_History__c>();
        Map<Id,pse__Resource_Request__c> rrIdToRRMap = new Map<Id,pse__Resource_Request__c>();
        List<pse__Resource_Request__c> toBeUpdatedRRList = new List<pse__Resource_Request__c>();
        Set<String> resReqFieldSet = new Set<String>{'Id', 'pse__Opportunity__c', 'Bid_History__c', 'Resource_Request_Type__c', 'Complexity_Score_Total__c', 'SubGroup__c',
            'CreatedDate','Workload_Ranking__c','Suggested_FTE__c','pse__Start_Date__c',
            'pse__Start_Date__c','pse__End_Date__c', 'Is_Bid_Defense__c','pse__Status__c','Regional_Analytics_Country__c','pse__Assignment__c'}; 
                for(Bid_History__c agr : newList) {
                    if(agr.RecordType != oldMap.get(agr.id).RecordType 
                       ||agr.Budget_Deliverable__c != oldMap.get(agr.id).Budget_Deliverable__c ||
                       agr.RFP_Ranking__c != oldMap.get(agr.id).RFP_Ranking__c) {
                           rrAgreementIdSet.add(agr.id);
                           agrIdToAgreementMap.put(agr.id,agr);
                       }                                        
                } 
        if(rrAgreementIdSet.size() > 0 ){
            rrIdToRRMap = new SLT_Resource_Request(false,false).getResourceRequestByBhrID(rrAgreementIdSet,resReqFieldSet);
            if(rrIdToRRMap.size() > 0 ) {
                toBeUpdatedRRList = UTL_OWF.calculateWRandSuggestedFTE(agrIdToAgreementMap,rrIdToRRMap.values());
                update toBeUpdatedRRList;
            }
        }
    }
    
    /**
* This method is used to set related Opportunity Name in the name field of Agreement.
* @params  newList List<Bid_History__c>
* @return  void
*/
    public static void populateAgrNameWithOppName(List<Bid_History__c> newList) {
        Set<Id> oppIdSet = new Set<Id>();
        Set<String> oppFieldSet = new Set<String>{'Id','Name','Owner.Email','Indication_List__c','TherapyArea__c','Is_this_IQVIA_Biotech__c','Potential_Regions__c','Global_project_unit__c','AccountId'};
            Map<Id, Opportunity> idToOppMap = new Map<Id, Opportunity>();
        
        for(Bid_History__c agr : newList) {
            //if(CON_OWF.OWF_AGREEMENT_RECORD_TYPE_IDS_SET.contains(agr.recordTypeId) && agr.recordTypeId != CON_OWF.OWF_NON_RFP_BID_AGREEMENT_RECORD_TYPE_ID || CON_CRM.CRM_AGREEMENT_RECORD_TYPE_SET.contains(agr.recordTypeId)) {
            if(CON_OWF.OWF_AGREEMENT_RECORD_TYPE_BID_HISTORY.contains(agr.recordTypeId)) {
                oppIdSet.add(agr.Bid_History_Related_Opportunity__c);

            }
            if(agr.recordTypeId == CON_OWF.OWF_Q2_Solutions_BID_HISTORY_RECORD_TYPE_ID && agr.Bid_Due_Date__c != Null){
                agr.Original_Due_Date__c = agr.Bid_Due_Date__c;
            }
            
            //IQVIAPSA-7093
            if(trigger.isInsert && agr.RecordTypeId == CON_OWF.OWF_TECH_SOLUTIONS_SUPPORT_REQUEST_BID_HISTORY_RECORD_TYPE_ID && agr.Bid_Due_Date__c == null
               && (!agr.Do_You_Need_Global_RFP_Team_Support__c && agr.Do_You_Need_Global_SE_Support__c)){
                   agr.Bid_Due_Date__c = Date.Today().addDays(30);
               }
        }
        if(oppIdSet.size() > 0 ){
            idToOppMap = new SLT_Opportunity(false,false).getOpportunityById(oppIdSet,oppFieldSet);
        }
        for(Bid_History__c agr : newList) {
            if(idToOppMap.containsKey(agr.Bid_History_Related_Opportunity__c)) {
                agr.name = idToOppMap.get(agr.Bid_History_Related_Opportunity__c).name.left(80);
                agr.Original_Due_Date__c = agr.Bid_Due_Date__c;
                agr.Opportunity_Owner_Email_Address__c = idToOppMap.get(agr.Bid_History_Related_Opportunity__c).Owner.Email;
                
                if(agr.RecordTypeId == CON_OWF.OWF_CLINICAL_BID_BID_HISTORY_RECORD_TYPE_ID && idToOppMap.get(agr.Bid_History_Related_Opportunity__c).Is_this_IQVIA_Biotech__c != Null){
                    agr.IQVIA_biotech__c = idToOppMap.get(agr.Bid_History_Related_Opportunity__c).Is_this_IQVIA_Biotech__c;
                }
                if(agr.RecordTypeId == CON_OWF.OWF_OCT_RFX_BID_HISTORY_RECORD_TYPE_ID && idToOppMap.get(agr.Bid_History_Related_Opportunity__c).Is_this_IQVIA_Biotech__c != Null){
                    agr.IQVIA_biotech__c = idToOppMap.get(agr.Bid_History_Related_Opportunity__c).Is_this_IQVIA_Biotech__c;
                }
                if(agr.RecordTypeId == CON_OWF.OWF_EARLY_ENGAGEMENT_BID_HISTORY_RECORD_TYPE_ID && idToOppMap.get(agr.Bid_History_Related_Opportunity__c).Indication_List__c != Null)
                {
                    agr.OWF_Indication__c = idToOppMap.get(agr.Bid_History_Related_Opportunity__c).Indication_List__c;
                    agr.OWF_Therapy_Area__c = idToOppMap.get(agr.Bid_History_Related_Opportunity__c).TherapyArea__c;
                }
                if(agr.RecordTypeId == CON_OWF.OWF_EARLY_ENGAGEMENT_BID_HISTORY_RECORD_TYPE_ID )
                {
                    agr.OWF_Potential_Regions__c = idToOppMap.get(agr.Bid_History_Related_Opportunity__c).Potential_Regions__c;
                }
                if(agr.RecordTypeId == CON_OWF.OWF_NON_RFP_BID_AGREEMENT_RECORD_TYPE_ID && idToOppMap.get(agr.Bid_History_Related_Opportunity__c).Indication_List__c != Null)
                {
                    agr.OWF_Indication__c = idToOppMap.get(agr.Bid_History_Related_Opportunity__c).Indication_List__c;
                }
                
                if(agr.RecordTypeId == CON_OWF.OWF_CONTRACT_POST_AWARD_BID_HISTORY_RECORD_TYPE_ID){
                    if(agr.Created_by_FormAssembly__c){
                        agr.Global_Project_Unit__c = idToOppMap.get(agr.Bid_History_Related_Opportunity__c).Global_project_unit__c;
                        agr.Bid_Due_Date__c = System.Today().addDays(90);
                        agr.IQVIA_biotech__c = idToOppMap.get(agr.Bid_History_Related_Opportunity__c).Is_this_IQVIA_Biotech__c;
                        agr.Bid_History_Account__c = idToOppMap.get(agr.Bid_History_Related_Opportunity__c).AccountId;
                            
                        if(agr.Line_of_Business__c== CON_OWF.LINE_OF_BUSINESS_OUTCOME || agr.Line_of_Business__c== CON_OWF.LINE_OF_BUSINESS_RWLP){
                            // Set Lead Business Group and Division Business Unit
                            agr.Lead_Business_Group__c = CON_OWF.LEAD_BUSINESS_GROUP_INTEGRATED_HEALTH_SERVICES;
                            agr.Division_Business_Unit__c = agr.Line_of_Business__c == CON_OWF.LINE_OF_BUSINESS_OUTCOME ? CON_OWF.DIVISION_BUSINESS_UNIT_OUTCOME : CON_OWF.DIVISION_BUSINESS_UNIT_RWLP;
                            agr.Deliver_Unit__c = CON_OWF.DELIVER_UNIT_RWE;
                        } 
                        if(CON_OWF.rankingValueMap.containsKey(agr.Ranking__c)){
                            agr.Contract_Ranking__c = CON_OWF.rankingValueMap.get(agr.Ranking__c);
                        }                 
                        // Set Agreement Pathway based on conditions
                        if(agr.Requested_Agreement_Type__c == CON_OWF.REQUESTED_AGREEMENT_TYPE_LRA || agr.Requested_Agreement_Type__c == CON_OWF.REQUESTED_AGREEMENT_TYPE_LRA_AMENDMENT){
                            agr.Agreement_Pathway__c = CON_OWF.AGREEMENT_PATHWAY_OSA;
                        }
                        else if(agr.Line_of_Business__c == CON_OWF.LINE_OF_BUSINESS_OUTCOME || agr.Line_of_Business__c == CON_OWF.LINE_OF_BUSINESS_RWLP){
                            agr.Agreement_Pathway__c = CON_OWF.AGREEMENT_PATHWAY_LATEPHASE;
                        }
                        else{
                            agr.Agreement_Pathway__c = CON_OWF.AGREEMENT_PATHWAY_CLINICAL;
                        }                    
                    }
                    if(!agr.Created_by_FormAssembly__c && CON_OWF.contractRankingValueMap.containsKey(agr.Contracts_Component__c)){
                        agr.Contract_Ranking__c = CON_OWF.contractRankingValueMap.get(agr.Contracts_Component__c);
                    }
                    if(CON_OWF.requestedAgreementMapToBidDueDateMap != null && CON_OWF.requestedAgreementMapToBidDueDateMap.containsKey(agr.Requested_Agreement_Type__c)){
                        agr.Bid_Due_Date__c = UTL_OWF.addBusinessDays(System.Today(),CON_OWF.requestedAgreementMapToBidDueDateMap.get(agr.Requested_Agreement_Type__c));
                    }
                    else{
                        agr.Bid_Due_Date__c = UTL_OWF.addBusinessDays(System.Today(),60);
                    } 
                }               
                
            }
            
        }
        
    }
    
    public static void createOutboundMessageDeletionQueue(List<Bid_History__c> deleteList) {
        fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(
            new Schema.SObjectType[] {
                Outbound_Message_Deletion_queue__c.SobjectType
                    }
        );
        Outbound_Message_Deletion_queue__c outBound;
        Boolean toCommit = false;
        for(Bid_History__c agr : deleteList) {
            outBound = new Outbound_Message_Deletion_queue__c();
            outBound.Operation__c = CON_CRM.DELETE_LABEL;
            
            if(agr.LQ_Bid_Histroy_Id__c != null) {
                outBound.LQ_Id__c = agr.LQ_Bid_Histroy_Id__c;
            }
            outBound.SObjectType__c = 'ApttusAPTS_Agreement_c' ;
            outBound.RecordID__c = agr.Id;
            uow.registerNew(outBound);
            toCommit = true;
        }
        
        if(toCommit) {
            uow.commitWork();
        }
    }
    public static void setMulesoftSyncfields(List<Bid_History__c> newList,Map<Id, Bid_History__c> oldMap) {
        // FEATURE-3828
        for(Bid_History__c agreement : newList) {      
            if((Trigger.isInsert || agreement.LQ_Mulesoft_Sync_Status__c == oldMap.get(agreement.Id).LQ_Mulesoft_Sync_Status__c || (agreement.LQ_Mulesoft_Sync_Status__c != oldMap.get(agreement.Id).LQ_Mulesoft_Sync_Status__c 
                                                                                                                                    && (agreement.LQ_Mulesoft_Sync_Status__c != CON_CRM.MULESOFT_SYNC_STATUS_COMPLETED &&  agreement.LQ_Mulesoft_Sync_Status__c != CON_CRM.MULESOFT_SYNC_STATUS_FAILED))) && CON_OWF.OWF_AGREEMENT_RECORD_TYPE_BID_HISTORY.contains(agreement.recordTypeId)) {
                                                                                                                                        agreement.LQ_Mulesoft_Sync_Status__c = CON_CRM.MULESOFT_SYNC_STATUS_PENDING;
                                                                                                                                    }                        
        }
    }
    /**
* This method is used to set related Opportunity Name in the name field of Agreement.
* @params  newList List<Bid_History__c>
* @return  void
*/
    /*public static void checkAgreementRecordTypeMapping(List<Bid_History__c> newList)
{
Set<String> oppStageToBidTypeMapFieldSet = new Set<String>{ 'Opp_Stage__c', 'Agreement_Record_Type__c' };
Boolean isExist = false;
Map<String,Set<String>> oppStageToBidTypeMap = new Map<String,Set<String>>();
for(Opp_Stage_to_Bid_Type_Mapping__mdt oppStageToBidType :
new SLT_OppStageToBidTypeMapping(true, false).getOppStageToBidTypeMappings(oppStageToBidTypeMapFieldSet)) {
if(!oppStageToBidTypeMap.containsKey(oppStageToBidType.Opp_Stage__c)) {
oppStageToBidTypeMap.put(oppStageToBidType.Opp_Stage__c,new Set<String>());
oppStageToBidTypeMap.get(oppStageToBidType.Opp_Stage__c).add(oppStageToBidType.Agreement_Record_Type__c);
}
else {
oppStageToBidTypeMap.get(oppStageToBidType.Opp_Stage__c).add(oppStageToBidType.Agreement_Record_Type__c);
}
}
for(Bid_History__c app : newList)
{
if(oppStageToBidTypeMap.containsKey(App.Opportunity_Stage__c.substring(0,1)) && oppStageToBidTypeMap.get(App.Opportunity_Stage__c.substring(0,1)).contains(Schema.getGlobalDescribe().get('Bid_History__c').getDescribe().getRecordTypeInfosById().get(app.RecordTypeId).getName()))
{
isExist = true;
}
else if(oppStageToBidTypeMap.containsKey(App.Opportunity_Stage__c.substring(0,2)) && oppStageToBidTypeMap.get(App.Opportunity_Stage__c.substring(0,2)).contains(Schema.getGlobalDescribe().get('Bid_History__c').getDescribe().getRecordTypeInfosById().get(app.RecordTypeId).getName()))
{
isExist = true;
}  
if(!isExist)
{
App.addError('Bid can be created on Valid Stage.');
}
}

}*/
    
    /**
* This method is used to create set bidtype initial/rebid Agreement on Opportunity
* @params  newAgreementList List<Bid_History__c>
* @return  void
*/
    /*
public static void populateReBidFields(List<Bid_History__c> newAgreementList) {
Map<String, List<OWF_ReBidFieldMapping__mdt>>  agrRecordTypeNameToreBidFieldMap = new Map<String, List<OWF_ReBidFieldMapping__mdt>>();
List<OWF_ReBidFieldMapping__mdt> rebidFieldMappingList = new SLT_OWF_ReBidFieldMapping().getReBidFieldMapping();
Set<String> opportunityFieldSet = new Set<String>{'Id'};
Set<String> agreementFieldSet = new Set<String>{'Id', 'Bid_History_Related_Opportunity__c', 'Apttus__Account__c', 'recordTypeId'};
Set<String> accountFieldSet = new Set<String>{'Id'};
Set<String> userFieldSet = new Set<String>{'Id'};
if(rebidFieldMappingList.size() > 0) {
for(OWF_ReBidFieldMapping__mdt rebidMapping : rebidFieldMappingList) {
if(agrRecordTypeNameToreBidFieldMap.containsKey(rebidMapping.RecordType__c)) {
agrRecordTypeNameToreBidFieldMap.get(rebidMapping.RecordType__c).add(rebidMapping);
} else {
agrRecordTypeNameToreBidFieldMap.put(rebidMapping.RecordType__c, new List<OWF_ReBidFieldMapping__mdt>{rebidMapping});
}
if(rebidMapping.SourceType__c == 'Field') {
if(rebidMapping.SourceObject__c == 'Agreement') {
agreementFieldSet.add(rebidMapping.SourceValue__c);
} else if(rebidMapping.SourceObject__c == 'Opportunity') {
opportunityFieldSet.add(rebidMapping.SourceValue__c);
} else if(rebidMapping.SourceObject__c == 'Account') {
accountFieldSet.add(rebidMapping.SourceValue__c);
} else if(rebidMapping.SourceObject__c == 'User') {
userFieldSet.add(rebidMapping.SourceValue__c);
}
}
}
Map<Id, Schema.RecordTypeInfo> recordTypeInfoIdMap = Schema.SObjectType.Bid_History__c.getRecordTypeInfosById();
Map<String, Id> recordTypeDevNameToIdMap = new Map<String, Id>();
for(Id recordTypeId : recordTypeInfoIdMap.keySet()) {
recordTypeDevNameToIdMap.put(recordTypeInfoIdMap.get(recordTypeId).getDeveloperName(), recordTypeId);
}
Set<Id> oppIdSet = new Set<Id>();
Set<Id> accountIdSet = new Set<Id>();
for(Bid_History__c agreement : newAgreementList) {
if(agreement.Bid_History_Related_Opportunity__c != null)
oppIdSet.add(agreement.Bid_History_Related_Opportunity__c);
if(agreement.Apttus__Account__c != null)
accountIdSet.add(agreement.Apttus__Account__c);
}
Map<Id, Opportunity> opportunityMap = new SLT_Opportunity(false,false).selectAgreementByOpportunities(oppIdSet, opportunityFieldSet, agreementFieldSet);
Map<Id, Map<String, Bid_History__c>> oppIdToAgrRecordTypeNameToAgrRecordMap = new Map<Id, Map<String, Bid_History__c>>();
for(Opportunity oppRecord : opportunityMap.values()) {
Map<String, Bid_History__c> agreementMap = new Map<String, Bid_History__c>();
for(Bid_History__c agreement : oppRecord.Apttus__R00N50000001Xl0FEAS__r) {
String recordTypeName = recordTypeInfoIdMap.get(agreement.recordTypeId).getDeveloperName();
agreementMap.put(recordTypeName, agreement);
}
oppIdToAgrRecordTypeNameToAgrRecordMap.put(oppRecord.Id, agreementMap);
}
Map<Id, Account> accountMap = new SLT_Account().selectByAccountId(accountIdSet, accountFieldSet);
Map<Id, Account> agreementIdToAccountMap = new Map<Id, Account>();
for(Bid_History__c agreement : newAgreementList) {
if(agreement.Apttus__Account__c != null)
agreementIdToAccountMap.put(agreement.Id, accountMap.get(agreement.Apttus__Account__c));
}
Map<Id, User> userMap = new SLT_User().selectByUserId(new Set<Id>{UserInfo.getUserId()}, userFieldSet);
User runningUser = userMap.values()[0];
String bidType;
String recordTypeName;
Map<String, String> fieldDataTypeToFieldAPINameMap = new UTL_Sobject('Bid_History__c').getFieldDataTypeByFieldAPIName();
for(Bid_History__c agreement : newAgreementList) {
recordTypeName = recordTypeInfoIdMap.get(agreement.RecordTypeId).getDeveloperName();
if(recordTypeName == 'Clinical_Short_Form') {
agreement.RecordTypeId = recordTypeDevNameToIdMap.get('Clinical_Bid');
recordTypeName = 'Clinical_Bid';
} else if(recordTypeName == 'RFI_Short_Form') {
agreement.RecordTypeId = recordTypeDevNameToIdMap.get('RFI_Request');
recordTypeName = 'RFI_Request';
} else if(recordTypeName == 'CSS_Short_Form') {
agreement.RecordTypeId = recordTypeDevNameToIdMap.get('CSS_Bid');
recordTypeName = 'CSS_Bid';
}
if(oppIdToAgrRecordTypeNameToAgrRecordMap.containsKey(agreement.Bid_History_Related_Opportunity__c) && (!oppIdToAgrRecordTypeNameToAgrRecordMap.get(agreement.Bid_History_Related_Opportunity__c).containsKey(recordTypeName))) {
bidType = 'Initial';
} else {
bidType = 'Rebid';
}
if(agrRecordTypeNameToreBidFieldMap.containsKey(recordTypeName)) {
for(OWF_ReBidFieldMapping__mdt rebidFieldMapping : agrRecordTypeNameToreBidFieldMap.get(recordTypeName)) {
String fieldValue = null;
if(rebidFieldMapping.BidType__c != 'None' && rebidFieldMapping.BidType__c != bidType)
continue;
if(rebidFieldMapping.SourceType__c == 'Value') {
if(rebidFieldMapping.SourceValue__c == 'Today') {
fieldValue = Date.today().format();
} else {
fieldValue = rebidFieldMapping.SourceValue__c;
}
} else {
if(rebidFieldMapping.SourceObject__c == 'Opportunity') {
if(opportunityMap.containsKey(agreement.Bid_History_Related_Opportunity__c)) {
if(rebidFieldMapping.SourceValue__c.contains('.')) {
List<String> fieldNames = rebidFieldMapping.SourceValue__c.split('\\.');
fieldValue = (String)opportunityMap.get(agreement.Bid_History_Related_Opportunity__c).getSobject(fieldNames[0]).get(fieldNames[1]);
} else {
fieldValue = (String)opportunityMap.get(agreement.Bid_History_Related_Opportunity__c).get(rebidFieldMapping.SourceValue__c);       
}
}
} else if(rebidFieldMapping.SourceObject__c == 'Agreement') {
if(oppIdToAgrRecordTypeNameToAgrRecordMap.containsKey(agreement.Bid_History_Related_Opportunity__c)) {  
fieldValue = String.valueOf(oppIdToAgrRecordTypeNameToAgrRecordMap.get(agreement.Bid_History_Related_Opportunity__c).get(recordTypeName).get(rebidFieldMapping.SourceValue__c) );
}

} else if(rebidFieldMapping.SourceObject__c == 'Account') {
if(agreementIdToAccountMap.containsKey(agreement.Id)) {
fieldValue = (String)agreementIdToAccountMap.get(agreement.Id).get(rebidFieldMapping.SourceValue__c);
}
} else if(rebidFieldMapping.SourceObject__c == 'User') {
fieldValue = (String)runningUser.get(rebidFieldMapping.SourceValue__c);
}
}
String field = rebidFieldMapping.TargetField__c;
String fieldType = fieldDataTypeToFieldAPINameMap.get(field.trim().toLowerCase());
if(fieldValue == null) {
agreement.put(rebidFieldMapping.TargetField__c, fieldValue);
} else if(fieldType == 'currency' || fieldType == 'double' || fieldType == 'percent' || fieldType == 'decimal') {
agreement.put(rebidFieldMapping.TargetField__c, Decimal.valueOf(fieldValue));
} else if(fieldType == 'boolean') {
agreement.put(rebidFieldMapping.TargetField__c, Boolean.valueOf(fieldValue));
} else if(fieldType == 'date') {
if(rebidFieldMapping.SourceType__c == 'Value') {
agreement.put(rebidFieldMapping.TargetField__c, Date.parse(fieldValue));
} else {
agreement.put(rebidFieldMapping.TargetField__c, Date.valueOf(fieldValue));
}
} else {
agreement.put(rebidFieldMapping.TargetField__c, fieldValue);
}
}
}
}  
}
}
*/
    /**
* This method is used to create set bidtype initial/rebid Agreement on Opportunity
* @params  newAgreementList List<Bid_History__c>
* @return  void
*/
    public static void changeRecordType(List<Bid_History__c> newAgreementList) {
        Map<Id, Schema.RecordTypeInfo> recordTypeInfoIdMap = Schema.SObjectType.Bid_History__c.getRecordTypeInfosById();
        Map<String, Id> recordTypeDevNameToIdMap = new Map<String, Id>();
        for(Id recordTypeId : recordTypeInfoIdMap.keySet()) {
            recordTypeDevNameToIdMap.put(recordTypeInfoIdMap.get(recordTypeId).getDeveloperName(), recordTypeId);
        }
        String recordTypeName;
        for(Bid_History__c agreement : newAgreementList) {
            recordTypeName = recordTypeInfoIdMap.get(agreement.RecordTypeId).getDeveloperName();
            if(recordTypeName == 'Clinical_Short_Form') {
                agreement.RecordTypeId = recordTypeDevNameToIdMap.get('Clinical_Bid');
                recordTypeName = 'Clinical_Bid';
            } 
            else if(recordTypeName == 'CSMS_Short_Form') {
                agreement.RecordTypeId = recordTypeDevNameToIdMap.get('CSMS_Bid');
                recordTypeName = 'CSMS_Bid';
            }
            else if(recordTypeName == 'RFI_Short_Form') {
                agreement.RecordTypeId = recordTypeDevNameToIdMap.get('RFI_Request');
                recordTypeName = 'RFI_Request';
            } else if(recordTypeName == 'CSS_Short_Form') {
                agreement.RecordTypeId = recordTypeDevNameToIdMap.get('CSS_Bid');
                recordTypeName = 'CSS_Bid';
            }//IQVIAPSA-4213 -- Begin
            else if(recordTypeName == 'OCT_RFx_Short_Form') {
                agreement.RecordTypeId = recordTypeDevNameToIdMap.get('OCT_RFx_Bid');
                recordTypeName = 'OCT_RFx_Bid';
            } //IQVIAPSA-4213 -- End
            else if(recordTypeName == 'GCC_Short_Form') {
                agreement.RecordTypeId = recordTypeDevNameToIdMap.get('GCC');
                recordTypeName = 'GCC';
            }
            else if(recordTypeName == 'Tech_Solutions_Support_Request_Short_Form') {
                agreement.RecordTypeId = recordTypeDevNameToIdMap.get('Tech_Solutions_Support_Request');
                recordTypeName = 'Tech_Solutions_Support_Request';
            }
        }
    }
    
    public static void updateBiotech(List<Bid_History__c> newList)
    {
        Set<Id> opportunityIdsSet = new Set<Id>();
        for(Bid_History__c newAgreement : newList){
            if(newAgreement.Bid_History_Related_Opportunity__c != NULL && newAgreement.RecordTypeId == CON_OWF.OWF_CLINICAL_BID_BID_HISTORY_RECORD_TYPE_ID){
                opportunityIdsSet.add(newAgreement.Bid_History_Related_Opportunity__c);
            }
        }
        
        if(!opportunityIdsSet.isEmpty()){
            Set<String> opportunityFieldSet = new Set<String>{'Id','Is_this_IQVIA_Biotech__c'};
                Map<Id, Opportunity>  oppIdToOppMap = new SLT_Opportunity(false, false).getOpportunityById(opportunityIdsSet, opportunityFieldSet);       
            
            for (Bid_History__c agreementValue: newList){
                if(!oppIdToOppMap.isEmpty()){
                    if(oppIdToOppMap.containsKey(agreementValue.Bid_History_Related_Opportunity__c) && oppIdToOppMap.get(agreementValue.Bid_History_Related_Opportunity__c).Is_this_IQVIA_Biotech__c != Null && agreementValue.RecordTypeId == CON_OWF.OWF_CLINICAL_BID_BID_HISTORY_RECORD_TYPE_ID){
                        agreementValue.IQVIA_biotech__c = oppIdToOppMap.get(agreementValue.Bid_History_Related_Opportunity__c).Is_this_IQVIA_Biotech__c;
                    }
                }
            }
        }
    }
    
    /*Validate Early Enagagement Bid For RW NmBRE*/
    public static void validateEarlyEngagementBid(List<Bid_History__c> newList)
    {
        Mulesoft_Integration_Control__c mulesoftSetting = Mulesoft_Integration_Control__c.getInstance();
        for (Bid_History__c agreement: newList)
        {
            if(agreement.RecordTypeId == Schema.SObjectType.Bid_History__c.getRecordTypeInfosByDeveloperName().get('Early_Engagement_Bid').getRecordTypeId() &&
               agreement.Resources_Needed__c!=null && agreement.Type_of_Engagement_Activity__c!=null)
            {
                List<String> resourcesNeededList = new List<String>();
                resourcesNeededList = agreement.Resources_Needed__c.split(';');
                List<String> typeOfEngagementActivityList = new List<String>();
                typeOfEngagementActivityList = agreement.Type_of_Engagement_Activity__c.split(';');
                if(!typeOfEngagementActivityList.contains('RW NmBRE') && resourcesNeededList.contains('No Resource Request')){
                    agreement.addError('No Resource Request can only be selected for RW NmBRE Engagement Activity type');
                }
                if(typeOfEngagementActivityList.contains('RW NmBRE') && !mulesoftSetting.Ignore_Validation_Rules__c )
                {
                    if(typeOfEngagementActivityList.size()>1){
                        agreement.addError('No other value can be selected in Type of Engagement Activity if RW NmBRE already Present');
                    }
                    if(agreement.OWF_Phase__c !=null
                       || agreement.OWF_Lead_Sub_Region__c != null || agreement.Is_there_a_Client_Bid_Grid__c != null
                       || agreement.Bid_Number__c > 0){
                        agreement.addError('Following Sections cannot be modified If RW NmBRE is present in Type of Engagement Activity: TSSU/GBO Resourcing, Opportunity Detail, Bid Detail.'); 
                    }
                    if(resourcesNeededList.size() > 1 && resourcesNeededList.contains('No Resource Request')){
                        agreement.addError('You cannot select additional resources when No Resources is selected');
                    }
                }
                if(!typeOfEngagementActivityList.contains('RW NmBRE') && resourcesNeededList != null)
                {
                    for(String resource : CON_OWF.LP_RESOURCES_SET ){
                        if(resourcesNeededList.contains(resource)){
                            agreement.addError('LP Resources can only be selected for RW NmBRE Engagement Activity type');
                            break;
                        }
                    }
                } 
            }
        }
    }
    
    public static void validateBidUpdate(List<Bid_History__c> newList,Map<Id, Bid_History__c>oldMap){
        Mulesoft_Integration_Control__c mulesoftSetting = Mulesoft_Integration_Control__c.getInstance();
        List<Bid_History__c> bidHistoryList = new List<Bid_History__c>();
        if(!mulesoftSetting.Ignore_Validation_Rules__c){
            for(Bid_History__c bid: newList){
                if(bid.recordtypeId == CON_OWF.OWF_CLINICAL_BID_BID_HISTORY_RECORD_TYPE_ID 
                   && bid.Bid_Due_Date__c != oldMap.get(bid.id).Bid_Due_Date__c && oldMap.get(bid.id).Bid_Due_Date__c < System.today()){
                       bidHistoryList.add(bid);
                   }
            }
            if(!bidHistoryList.isEmpty()){
                List<PermissionSetAssignment> permissionSetList = [SELECT Id FROM PermissionSetAssignment WHERE AssigneeId = :Userinfo.getUserId() AND PermissionSet.Name = 'OWF_Admin_User'];
                if(permissionSetList.isEmpty()){
                    for(Bid_History__c bid: bidHistoryList){
                        bid.addError('The deliverable date has been met.Further activity will require a new bid to be created.');
                    }
                }
            }
        }
    }
    
    
    
    /*  ===============================================================================
        Created:        Frankie Spano
        Date:           05/22/2020
        Description:    add Bid Complexity calculation
        @param newMap   List Of Agreements
        @return none
        ===============================================================================
    */
    public static void updateBidComplexity(List<Bid_History__c> newList){
        for(Bid_History__c agreement: newList){
	      if(agreement.RecordTypeId != CON_OWF.OWF_Q2_Solutions_BID_HISTORY_RECORD_TYPE_ID){
            Integer requestedDays;
            if(agreement.CreatedDate != null && agreement.Original_Due_Date__c != null){
                requestedDays = UTL_OWF.findNoOfDays_exclude_weekend(agreement.CreatedDate.date(),agreement.Original_Due_Date__c, 0);
            }
            else if(agreement.Original_Due_Date__c != null){
                requestedDays = UTL_OWF.findNoOfDays_exclude_weekend(Date.today(),agreement.Original_Due_Date__c, 0);
            }
            else{
                agreement.Bid_Complexity__c = '';
                continue;
            }
            if(agreement.Bid_Number__c > 1){
                if(requestedDays < 3 && ((agreement.RFP_Ranking__c == '1' && agreement.Budget_Deliverable__c == 'Price per Patient Range' && (agreement.Proposal_Deliverable__c == 'Summary of key study assumptions, experience and budget' || agreement.Proposal_Deliverable__c == 'N/A'))
                    || (agreement.RFP_Ranking__c == '2' && agreement.Budget_Deliverable__c == 'Rounded Ballpark' && (agreement.Proposal_Deliverable__c == 'Summary of key study assumptions, experience and budget' || agreement.Proposal_Deliverable__c == 'N/A') && agreement.Number_of_Requested_Services__c < 5 && agreement.Estimated_Fees__c == 'Less than $10M')
                    || (agreement.RFP_Ranking__c == '3' && agreement.Budget_Deliverable__c == 'Full Budget' && (agreement.Proposal_Deliverable__c == 'Summary of key study assumptions, experience and budget' || agreement.Proposal_Deliverable__c == 'N/A') && (agreement.Number_of_Requested_Services__c == 1 || agreement.Number_of_Requested_Services__c == 2) && agreement.Estimated_Fees__c == 'Less than $10M' && agreement.Is_there_a_Client_Bid_Grid__c == 'No' && agreement.Is_this_part_of_a_Program__c == 'Not part of a program')
                    || (agreement.RFP_Ranking__c == '4' && agreement.Budget_Deliverable__c == 'Full Budget' && (agreement.Proposal_Deliverable__c == 'Full proposal' || agreement.Proposal_Deliverable__c == 'Summary of key study assumptions, brief rationale for strategy, experience and budget' ) && (agreement.Number_of_Requested_Services__c < 5) && agreement.Estimated_Fees__c == 'Greater than $10M'))){
                    agreement.Bid_Complexity__c = 'Low';
                    //System.debug(LoggingLevel.INFO, '**** bid complexity updated - low (rebid)');
                    }
                else if(((requestedDays >= 3 && requestedDays <= 5) 
                && ((agreement.RFP_Ranking__c == '2' && agreement.Budget_Deliverable__c == 'Rounded Ballpark' && agreement.Proposal_Deliverable__c == 'Experience tables and budget range' && agreement.Number_of_Requested_Services__c >= 5 && agreement.Estimated_Fees__c == 'Greater than $10M')
                || (agreement.RFP_Ranking__c == '3' && agreement.Budget_Deliverable__c == 'Full Budget' && (agreement.Proposal_Deliverable__c == 'Experience tables and budget range' || agreement.Proposal_Deliverable__c == 'Full proposal') && (agreement.Number_of_Requested_Services__c >= 3 || agreement.Number_of_Requested_Services__c <= 5) && agreement.Requested_Services__c.contains('Clinical Monitoring') && agreement.Estimated_Fees__c == 'Less than $10M' && agreement.Is_there_a_Client_Bid_Grid__c == 'Yes' && (agreement.Is_this_part_of_a_Program__c == 'Yes - lead opportunity' || agreement.Is_this_part_of_a_Program__c == 'Yes - not the lead'))
                || (agreement.RFP_Ranking__c == '4' && agreement.Budget_Deliverable__c == 'Full Budget' && (agreement.Proposal_Deliverable__c == 'Full proposal' || agreement.Proposal_Deliverable__c == 'Summary of key study assumptions, brief rationale for strategy, experience and budget') && agreement.Number_of_Requested_Services__c >= 5 && agreement.Estimated_Fees__c == 'Greater than $10M'))
                || (agreement.RFP_Ranking__c == '5' && agreement.Budget_Deliverable__c == 'Full Budget' && (agreement.Proposal_Deliverable__c == 'Full proposal' || agreement.Proposal_Deliverable__c == 'Summary of key study assumptions, brief rationale for strategy, experience and budget' ) && agreement.Estimated_Fees__c == 'Greater than $20M' && requestedDays < 3))){
                    agreement.Bid_Complexity__c = 'Med';
                    //System.debug(LoggingLevel.INFO, '**** bid complexity updated - med (rebid)');
                }
                else if((requestedDays >= 3 && agreement.RFP_Ranking__c == '1' && agreement.Budget_Deliverable__c == 'Price per Patient Range' && (agreement.Proposal_Deliverable__c == 'Full proposal' || agreement.Proposal_Deliverable__c == 'Summary of key study assumptions, brief rationale for strategy, experience and budget' || agreement.Proposal_Deliverable__c == 'Experience tables and budget range')) ||
                (requestedDays >= 3 && agreement.RFP_Ranking__c == '5' && agreement.Budget_Deliverable__c == 'Full Budget' && (agreement.Proposal_Deliverable__c == 'Full proposal' || agreement.Proposal_Deliverable__c == 'Summary of key study assumptions, brief rationale for strategy, experience and budget' ) && agreement.Estimated_Fees__c == 'Greater than $50M') || 
                ((requestedDays >= 5
                && ((agreement.RFP_Ranking__c == '2' && agreement.Budget_Deliverable__c == 'Rounded Ballpark' && (agreement.Proposal_Deliverable__c == 'Full proposal' || agreement.Proposal_Deliverable__c == 'Summary of key study assumptions, brief rationale for strategy, experience and budget') && agreement.Number_of_Requested_Services__c > 5 && (agreement.Estimated_Fees__c == 'Greater than $20M' || agreement.Estimated_Fees__c == 'Greater than $25M - GFR' || agreement.Estimated_Fees__c == 'Greater than $50M'))
                || (agreement.RFP_Ranking__c == '3' && agreement.Budget_Deliverable__c == 'Full Budget' && (agreement.Proposal_Deliverable__c == 'Full proposal' || agreement.Proposal_Deliverable__c == 'Summary of key study assumptions, brief rationale for strategy, experience and budget' ) && agreement.Number_of_Requested_Services__c >= 5 && agreement.Estimated_Fees__c == 'Greater than $10M' && agreement.Is_there_a_Client_Bid_Grid__c == 'Yes' && (agreement.Is_this_part_of_a_Program__c == 'Yes - lead opportunity' || agreement.Is_this_part_of_a_Program__c == 'Yes - not the lead'))
                || (agreement.RFP_Ranking__c == '4' && agreement.Budget_Deliverable__c == 'Full Budget' && (agreement.Proposal_Deliverable__c == 'Full proposal' || agreement.Proposal_Deliverable__c == 'Summary of key study assumptions, brief rationale for strategy, experience and budget') && agreement.Number_of_Requested_Services__c > 5 && agreement.Estimated_Fees__c == 'Greater than $20M'))))){
                    agreement.Bid_Complexity__c = 'High';
                   // System.debug(LoggingLevel.INFO, '**** bid complexity updated - high (rebid)');
                }
                else{
                    //System.debug(LoggingLevel.INFO, '**** bid complexity updated - empty (rebid)');
                    agreement.Bid_Complexity__c = '';
                }
                
            }
            else{ 
                if((agreement.RFP_Ranking__c == '1' && agreement.Budget_Deliverable__c == 'Price per Patient Range' && (agreement.Proposal_Deliverable__c == 'Summary of key study assumptions, experience and budget' || agreement.Proposal_Deliverable__c == 'N/A'))
                    || (agreement.RFP_Ranking__c == '2' && agreement.Budget_Deliverable__c == 'Rounded Ballpark' && (agreement.Proposal_Deliverable__c == 'Summary of key study assumptions, experience and budget' || agreement.Proposal_Deliverable__c == 'N/A') && agreement.Number_of_Requested_Services__c < 5 && agreement.Estimated_Fees__c == 'Less than $10M')
                    || (agreement.RFP_Ranking__c == '3' && agreement.Budget_Deliverable__c == 'Full Budget' && (agreement.Proposal_Deliverable__c == 'Summary of key study assumptions, experience and budget' || agreement.Proposal_Deliverable__c == 'N/A') && (agreement.Number_of_Requested_Services__c == 1 || agreement.Number_of_Requested_Services__c == 2) && agreement.Estimated_Fees__c == 'Less than $10M' && agreement.Is_there_a_Client_Bid_Grid__c == 'No' && agreement.Is_this_part_of_a_Program__c == 'Not part of a program')
                    || (agreement.RFP_Ranking__c == '4' && agreement.Budget_Deliverable__c == 'Full Budget' && (agreement.Proposal_Deliverable__c == 'Full proposal' || agreement.Proposal_Deliverable__c == ' Summary of key study assumptions, brief rationale for strategy, experience and budget' ) && (agreement.Number_of_Requested_Services__c < 5) && agreement.Estimated_Fees__c == 'Greater than $10M')){
                    agreement.Bid_Complexity__c = 'Low';
                    //System.debug(LoggingLevel.INFO, '**** bid complexity updated - low');
                }
                else if((agreement.RFP_Ranking__c == '2' && agreement.Budget_Deliverable__c == 'Rounded Ballpark' && agreement.Proposal_Deliverable__c == 'Experience tables and budget range' && agreement.Number_of_Requested_Services__c >= 5 && agreement.Estimated_Fees__c == 'Greater than $10M')
                || (agreement.RFP_Ranking__c == '3' && agreement.Budget_Deliverable__c == 'Full Budget' && (agreement.Proposal_Deliverable__c == 'Experience tables and budget range' || agreement.Proposal_Deliverable__c == 'Full proposal' ) && (agreement.Number_of_Requested_Services__c >= 3 || agreement.Number_of_Requested_Services__c <= 5) && agreement.Requested_Services__c.contains('Clinical Monitoring') && agreement.Estimated_Fees__c == 'Less than $10M' && agreement.Is_there_a_Client_Bid_Grid__c == 'Yes' && (agreement.Is_this_part_of_a_Program__c == 'Yes - lead opportunity' || agreement.Is_this_part_of_a_Program__c == 'Yes - not the lead'))
                || (agreement.RFP_Ranking__c == '4' && agreement.Budget_Deliverable__c == 'Full Budget' && (agreement.Proposal_Deliverable__c == 'Full proposal' || agreement.Proposal_Deliverable__c == ' Summary of key study assumptions, brief rationale for strategy, experience and budget') && agreement.Number_of_Requested_Services__c >= 5 && agreement.Estimated_Fees__c == 'Greater than $10M')
                || (agreement.RFP_Ranking__c == '5' && agreement.Budget_Deliverable__c == 'Full Budget' && (agreement.Proposal_Deliverable__c == 'Full proposal' || agreement.Proposal_Deliverable__c == ' Summary of key study assumptions, brief rationale for strategy, experience and budget') && agreement.Estimated_Fees__c == 'Greater than $20M')){
                    agreement.Bid_Complexity__c = 'Med';
                    //System.debug(LoggingLevel.INFO, '**** bid complexity updated - med ');
                }
                else if((agreement.RFP_Ranking__c == '1' && agreement.Budget_Deliverable__c == 'Price per Patient Range' && (agreement.Proposal_Deliverable__c == 'Full proposal' || agreement.Proposal_Deliverable__c == ' Summary of key study assumptions, brief rationale for strategy, experience and budget' || agreement.Proposal_Deliverable__c == 'Experience tables and budget range') && requestedDays >= 3)
                || (agreement.RFP_Ranking__c == '5' && agreement.Budget_Deliverable__c == 'Full Budget' && (agreement.Proposal_Deliverable__c == 'Full proposal' || agreement.Proposal_Deliverable__c == ' Summary of key study assumptions, brief rationale for strategy, experience and budget' ) && agreement.Estimated_Fees__c == 'Greater than $50M' && requestedDays >= 3)
                || (agreement.RFP_Ranking__c == '2' && agreement.Budget_Deliverable__c == 'Rounded Ballpark' && (agreement.Proposal_Deliverable__c == 'Full proposal' || agreement.Proposal_Deliverable__c == ' Summary of key study assumptions, brief rationale for strategy, experience and budget') && agreement.Number_of_Requested_Services__c >= 5 && (agreement.Estimated_Fees__c == 'Greater than $20M' || agreement.Estimated_Fees__c == 'Greater than $25M - GFR' || agreement.Estimated_Fees__c == 'Greater than $50M'))
                || (agreement.RFP_Ranking__c == '3' && agreement.Budget_Deliverable__c == 'Full Budget' && (agreement.Proposal_Deliverable__c == 'Full proposal' || agreement.Proposal_Deliverable__c == ' Summary of key study assumptions, brief rationale for strategy, experience and budget' ) && agreement.Number_of_Requested_Services__c >= 5 && agreement.Estimated_Fees__c == 'Greater than $10M' && agreement.Is_there_a_Client_Bid_Grid__c == 'Yes' && (agreement.Is_this_part_of_a_Program__c == 'Yes - lead opportunity' || agreement.Is_this_part_of_a_Program__c == 'Yes - not the lead'))
                || (agreement.RFP_Ranking__c == '4' && agreement.Budget_Deliverable__c == 'Full Budget' && (agreement.Proposal_Deliverable__c == 'Full proposal' || agreement.Proposal_Deliverable__c == ' Summary of key study assumptions, brief rationale for strategy, experience and budget' ) && agreement.Number_of_Requested_Services__c >= 5 && agreement.Estimated_Fees__c == 'Greater than $20M')){
                    agreement.Bid_Complexity__c = 'High';
                    //System.debug(LoggingLevel.INFO, '**** bid complexity updated - high ');
                }
                else{
                    agreement.Bid_Complexity__c = '';
                    //System.debug(LoggingLevel.INFO, '**** bid complexity updated - empty ');
                }
            }
        }
	  }
    }

    public static void updateResourcesNeededFromAgreement(List<Bid_History__c> newList, Map<Id, Bid_History__c> oldMap) 
    {
        Map<Id, Bid_History__c> agrIdToAgreementMap = new Map<Id, Bid_History__c>();
        Set<Id> rrAgreementIdSet = new Set<Id>();        
        Map<Id,pse__Resource_Request__c> oldRRfromAgreement = new Map<Id,pse__Resource_Request__c>();        
        Set<String> resReqFieldSet = new Set<String>{'Id', 'pse__Opportunity__c', 'Bid_History__c',
        'Resource_Request_Type__c', 'Complexity_Score_Total__c', 'SubGroup__c',
        'CreatedDate','Workload_Ranking__c','Suggested_FTE__c','pse__Start_Date__c',
        'pse__Start_Date__c','pse__End_Date__c', 'Is_Bid_Defense__c','pse__Status__c','Regional_Analytics_Country__c'};
        Map<String, OWF_Resources_Needed_to_SubGroup_Map__c> resourcesNeededToSubGrpMap = new Map<String,OWF_Resources_Needed_to_SubGroup_Map__c>();
        resourcesNeededToSubGrpMap = OWF_Resources_Needed_to_SubGroup_Map__c.getAll();
        List<String> resourcesNeededList = new List<String>();
        List<pse__Resource_Request__c> rrList = new List<pse__Resource_Request__c>();
        Set<String> newRegionalAnalyticsCountries = new Set<String>();
        
        try{
            for(Bid_History__c agr : newList) 
            {     
               If(agr.recordTypeId == CON_OWF.OWF_NON_RFP_BID_BID_HISTORY_RECORD_TYPE_ID || agr.recordTypeId == CON_OWF.OWF_EARLY_ENGAGEMENT_BID_HISTORY_RECORD_TYPE_ID || agr.recordTypeId == CON_OWF.OWF_POST_AWARD_BID_HISTORY_RECORD_TYPE_ID){
                    If(agr.Resources_Needed__c !=  oldMap.get(agr.Id).Resources_Needed__c || (agr.Resources_Needed__c.contains(CON_OWF.RES_REQ_TYPE_GLOBAL_ANALYTICS) && agr.Regional_Analytics_Country__c != oldMap.get(agr.Id).Regional_Analytics_Country__c)){
                        rrAgreementIdSet.add(agr.id);
                        agrIdToAgreementMap.put(agr.id,agr);
                    }   
                }
            }
			
            if(agrIdToAgreementMap.size() > 0)
            {
                oldRRfromAgreement = new SLT_Resource_Request(false,false).getResourceRequestByBhrID(rrAgreementIdSet,resReqFieldSet);
                
                for(Bid_History__c agreement : agrIdToAgreementMap.values()) 
                {
                    if (agreement.Regional_Analytics_Country__c != null && String.isNotBlank(agreement.Regional_Analytics_Country__c)) {
                        newRegionalAnalyticsCountries = new Set<String>(agreement.Regional_Analytics_Country__c.split(';'));
                    }
                    if(agreement.Resources_Needed__c != Null && String.IsNotBlank(agreement.Resources_Needed__c)){
                        resourcesNeededList = agreement.Resources_Needed__c.split(';');
                    } 
                    if(resourcesNeededList.contains('No Resource Request')){
                        resourcesNeededList.remove(resourcesNeededList.indexOf('No Resource Request'));
                        Break;
                    }
                    
                    OWF_Config__c owfConfig = OWF_Config__c.getOrgDefaults();
                    String owfStdGroupId = '';
                    if(owfConfig != null) {
                        owfStdGroupId = owfConfig.OWF_Standard_Group__c;
                    }
                    
                    if(resourcesNeededList.size() > 0 && rrAgreementIdSet.size() > 0)
                    {
                        String subGroup;
                        for(Integer i = 0; i < resourcesNeededList.size(); i++)
                        {
                            for(pse__Resource_Request__c oldList : oldRRfromAgreement.values()) {
                                subGroup = resourcesNeededToSubGrpMap.get(resourcesNeededList.get(i)).Sub_Group__c;
                                if (subGroup == oldList.SubGroup__c && subGroup != CON_OWF.RES_REQ_TYPE_GLOBAL_ANALYTICS) {
                                    resourcesNeededList.remove(i);
                                    i--;
                                    break;
                                }else if(subGroup == oldList.SubGroup__c){
                                    newRegionalAnalyticsCountries.remove(oldList.Regional_Analytics_Country__c);
                                }
                            }
                        }
                    }
                    
                    for(String resourceNeeded : resourcesNeededList) 
                    {
                        if(resourceNeeded == CON_OWF.RES_REQ_TYPE_GLOBAL_ANALYTICS)
                        {
                            for( String country : newRegionalAnalyticsCountries)
                            {
                               pse__Resource_Request__c newRR = new pse__Resource_Request__c(
                               recordTypeId = CON_OWF.OWF_RR_RECORD_TYPE_ID,
                               currencyIsoCode = agreement.currencyIsoCode,
                               pse__Opportunity__c = agreement.Bid_History_Related_Opportunity__c,
                               pse__Group__c = owfStdGroupId,
                               Account__c = agreement.Bid_History_Account__c,
                               Bid_History__c = agreement.Id,
                               SubGroup__c = resourcesNeededToSubGrpMap.containsKey(resourceNeeded)? resourcesNeededToSubGrpMap.get(resourceNeeded).Sub_Group__c:'',
                               pse__Start_Date__c = Date.Today(),
                               pse__End_Date__c = agreement.Bid_Due_Date__c,
                               pse__SOW_Hours__c = 0.01,
                               Is_Created_Automatically_Initial_Bid__c = True,
                               Is_Created_Automatically__c = True,
                               Select_Analysis__c = agreement.Select_Analysis__c,																				 
                               Regional_Analytics_Country__c = country);
                               rrList.add(newRR); 
                            }
                        }
                        else
                        {
                           pse__Resource_Request__c newRR = new pse__Resource_Request__c(
                           recordTypeId = CON_OWF.OWF_RR_RECORD_TYPE_ID,
                           currencyIsoCode = agreement.currencyIsoCode,
                           pse__Opportunity__c = agreement.Bid_History_Related_Opportunity__c,
                           pse__Group__c = owfStdGroupId,
                           Account__c = agreement.Bid_History_Account__c,
                           Bid_History__c = agreement.Id,
                           SubGroup__c = resourcesNeededToSubGrpMap.containsKey(resourceNeeded)? resourcesNeededToSubGrpMap.get(resourceNeeded).Sub_Group__c:'',
                           pse__Start_Date__c = Date.Today(),
                           pse__End_Date__c = agreement.Bid_Due_Date__c,
                           pse__SOW_Hours__c = 0.01,
                           Is_Created_Automatically_Initial_Bid__c = True,
                           Is_Created_Automatically__c = True);
                           if(!CON_OWF.LP_RESOURCES_SET.contains(resourceNeeded)){
                                rrList.add(newRR);
                           }
                        }
                    }                      
                }
            }
            
            if(rrList.size() > 0){
                insert rrList;
            }
			 
        }catch(Exception e){
            system.debug('updateResourcesNeededFromAgreementError: ' + e.getMessage() + ' at Line number: ' + e.getLineNumber());
        }
    }
    
    
    public static void setAccountCountry(List<Bid_History__c> newAgreementList, Map<Id, Bid_History__c> oldMap) {
        Set<Id> accountIdSet = new Set<id>();
        List<Bid_History__c> updatedList = new List<Bid_History__c>();
        for(Bid_History__c bhsr :newAgreementList) {
            if((Trigger.isInsert || Trigger.isUpdate) && bhsr.Bid_History_Account__c != null) { 
                accountIdSet.add(bhsr.Bid_History_Account__c);
                updatedList.add(bhsr);
            } else if (Trigger.isUpdate && bhsr.Bid_History_Account__c == null) {
                bhsr.Account_Country__c = null;    
            }
        }
        if(accountIdSet.size() > 0) {
            Map<Id,Account> accountIdMap = new Map<Id,Account>([select Id, AccountCountry__c, RecordType.Id from Account where Id In :accountIdSet]);
            for (Bid_History__c bhsr : updatedList) {
                if (accountIdMap.containsKey(bhsr.Bid_History_Account__c) && accountIdMap.get(bhsr.Bid_History_Account__c).RecordType.Id != CON_CRM.GLOBAL_CUSTOMER_ACCOUNT_RECORD_TYPE_ID) {
                    bhsr.Account_Country__c = accountIdMap.get(bhsr.Bid_History_Account__c).AccountCountry__c;    
                } else {
                    bhsr.Account_Country__c = null;
                }
            }   
        }
    }
    
    
    public static void updateSuggestedDueDate(List<Bid_History__c> newList, Map<Id, Bid_History__c> oldMap) {
        Integer daysToAdd=0; 
        Integer daysToAdjust=0;
        Date bidDueDate;
        Set<Id> oppIds = new Set<Id>();
        for(Bid_History__c agreement : newList) {
            if((oldMap == null || (oldMap != null && agreement.Opportunity_Type__c != oldMap.get(agreement.Id).Opportunity_Type__c)) && agreement.RecordTypeId == CON_OWF.OWF_CLINICAL_BID_BID_HISTORY_RECORD_TYPE_ID){
                oppIds.add(agreement.Bid_History_Related_Opportunity__c);
            }
        }
        Map<Id, Opportunity> oppList = new Map<Id, Opportunity>();
        if(!oppIds.isEmpty()){
            Set<String> agrFieldSet = new Set<String>{'Id', 'Name','Is_this_a_Virtual_Trials_Study__c'};
            oppList=   new SLT_Opportunity().getOpportunityById(oppIds, agrFieldSet);
       
          for(Bid_History__c agreement : newList) {
                if(agreement.Opportunity_Type__c=='BTS Ballpark' && agreement.Is_there_a_Client_Bid_Grid__c == 'Yes')
                {
                    daysToAdjust=CON_OWF.daysForClientBidGrid ;
                }
                else if (agreement.Opportunity_Type__c=='Ballpark requiring IQVIA-defined C/S/P strategy' || agreement.Opportunity_Type__c=='Limited service RFP (non-Clinical, non-FSP)')
                {
                    if(agreement.Is_there_a_Client_Bid_Grid__c == 'Yes' && agreement.Opportunity_Type__c=='Limited service RFP (non-Clinical, non-FSP)' && ((agreement.Number_of_Scenarios__c!=null && agreement.Number_of_Scenarios__c >= 2) || (oppList != null && oppList.get(agreement.Bid_History_Related_Opportunity__c).Is_this_a_Virtual_Trials_Study__c=='Yes Fully Virtual'|| oppList.get(agreement.Bid_History_Related_Opportunity__c).Is_this_a_Virtual_Trials_Study__c=='Yes Hybrid' )) ){
                        daysToAdjust=CON_OWF.daysForClientBidGrid + CON_OWF.daysForDCT ;
                    }else if(agreement.Is_there_a_Client_Bid_Grid__c == 'No' && agreement.Opportunity_Type__c=='Limited service RFP (non-Clinical, non-FSP)' && ((agreement.Number_of_Scenarios__c!=null && agreement.Number_of_Scenarios__c >= 2) || (oppList != null && oppList.get(agreement.Bid_History_Related_Opportunity__c).Is_this_a_Virtual_Trials_Study__c=='Yes Fully Virtual'|| oppList.get(agreement.Bid_History_Related_Opportunity__c).Is_this_a_Virtual_Trials_Study__c=='Yes Hybrid' )) ){
                        daysToAdjust=CON_OWF.daysForDCT ;
                    }else if(agreement.Is_there_a_Client_Bid_Grid__c == 'Yes'){
                        daysToAdjust=CON_OWF.daysForClientBidGrid;
                    }
                }
                
                if(agreement.Opportunity_Type__c != NULL) {
                    daysToAdd=daysToAdjust + CON_OWF.oppTypeToTATMap.get(agreement.Opportunity_Type__c);
                    if(Trigger.isInsert){
                        bidDueDate = Date.today();
                    }
                    else if(Trigger.isUpdate){
                        bidDueDate = date.newinstance(agreement.CreatedDate.year(), agreement.CreatedDate.month(), agreement.CreatedDate.day());
                    }
                    agreement.Suggested_Due_Date__c= getAdjustedDateAccToWorkingDays(bidDueDate,daysToAdd);
                }
           }
        }
    }
    
    private static Date getAdjustedDateAccToWorkingDays(Date dateToAdjust, Integer valueAdjustedDays){
        Integer businessDaysAdded = 0;
        Date currentDate = dateToAdjust;
        while (businessDaysAdded <= valueAdjustedDays) {
            currentDate = currentDate.addDays(1);
            Datetime d = datetime.newInstance(currentDate.year(), currentDate.month(),currentDate.day());
            if (d.format('E') != 'Sat' && d.format('E') != 'Sun' && IsWeekendDay(currentDate)) {
                businessDaysAdded = businessDaysAdded + 1;
            }
        }
        return currentDate;
    }
    private static Boolean IsWeekendDay(Date currentDate){
        datetime predicatedDateTime = datetime.newInstance(currentDate.year(), currentDate.month(), currentDate.day());
        if(predicatedDateTime.format('E') == 'Sat' | predicatedDateTime.format('E') == 'Sun'){
            return false;
        }
        else{
            return true;
            } 
    }
    
    public static void sendEmailToRequestedProductsEmailsOnCSSBid(List<Bid_History__c> newList) {
        Set<Id> sObjectIdSet = new Set<Id>();
        Workflow_Email_Record__c workFlowRecord;
        List<Workflow_Email_Record__c> workflowEmailRecordsToInsertList = new List<Workflow_Email_Record__c>();
        String moduleName = CON_OWF.OWF_MODULE_NAME;
        String emailAction = CON_OWF.CSS_BID_REQUESTED_PRODUCTS_EMAIL_ACTION;
        String emailOverallBodyContent = '';
        Integer content1FieldLength = Schema.SObjectType.Workflow_Email_Record__c.fields.content_1__c.getLength();
        Integer content2FieldLength = Schema.SObjectType.Workflow_Email_Record__c.fields.content_2__c.getLength();
        Set<String> productList;
        String productChecked='';
        
        for(Bid_History__c agreement : newList){
            if(agreement.RecordTypeId == CON_OWF.OWF_CSS_BID_BID_HISTORY_RECORD_TYPE_ID){
                sObjectIdSet.add(agreement.Id);
            }
        }
        String whereclause = 'Id IN :sObjectIdSet';
        Map<String,OWF_Generic_Setting__c> resourceEmail = OWF_Generic_Setting__c.getAll();
        Set<String> bhrFieldSet = (new Set<String>{'Pertinent_Details_Specific_Rebid_Request__c', 'FPI_Date__c','LPI_Date__c','DBL_Date__c','LPO_Date__c',
            'Bid_Due_Date__c', 'Is_PPT_Format_Required__c','Connected_Devices__c','Complete_Consent__c','PCS__c', 'eCOA__c','IRT__c','Indication__c','Therapy_Area__c', 
            'Protocol_Number__c','Phase__c','Customer_discount_in_place_or_requested__c','Is_there_a_Client_Bid_Grid__c', 'Bid_History_Related_Opportunity__r.Amount', 
            'CurrencyIsoCode', 'Estimated_Fees__c','Rate_Card_MSA__c','Is_this_part_of_a_Program__c','Associated_CRM_Numbers__c', 'Bid_History_Related_Opportunity__r.Id', 
            'Bid_History_Related_Opportunity__r.Name','Bid_History_Account__r.Name','Opportunity_Owner__c','Opportunity_Number__c', 'Legacy_Quintiles_Opportunity_Number__c', 
            'Parent_Opportunity__c', 'Line_of_Business__c', 'Win_Probability__c', 'RecordTypeId', 'Bid_Category__c', 'Bid_Type__c', 'Bid_History_Related_Opportunity__r.Owner_Email__c', 
            'Grant_Plan__c','Study_Optimizer__c','Site_Portal__c','eTMF__c','Clinical_Trial_Payments__c','CDAS__c','Clinical_Technology_Opportunity_Type__c','Risk_Based_Monitoring__c','One_Home_for_Sites__c','DQS__c',
            'Name', 'Bid_History_Related_Opportunity__r.Parent_Opportunity__r.Name', 'Clinical_Technology_Opportunity_Type__c','Bid_History_Related_Opportunity__r.Parent_Opportunity__r.Legacy_Quintiles_Opportunity_Number__c','Pre_Work_Order__c',
            'Lost_products__c', 'Primary_Bid_Loss_Reason__c','Participant_Payments__c','Payments_Forecasting__c','Opportunity_Type__c','Client_Deliverable_What_is_the_client_s__c','RFI_Request_Type__c','Orchestration_to_be_considered__c','Efficiencies_to_be_considered__c','Bid_Number__c'});       
        
        List<Bid_History__c> bidHistoryRecordsList = new List<Bid_History__c>();
        if(!sObjectIdSet.isEmpty()){
            bidHistoryRecordsList = new SLT_Bid_History(false, false).getBidHistoriesByCondition(bhrFieldSet, whereClause, sObjectIdSet);
        }
        if(bidHistoryRecordsList.size() > 0 && resourceEmail != null){
            for(Bid_History__c agreement : bidHistoryRecordsList){
                productList = new Set<String>();
                workFlowRecord = new Workflow_Email_Record__c();
                if(agreement.Bid_History_Related_Opportunity__r.Owner_Email__c != null){
                    workFlowRecord.To_Email_1__c = agreement.Bid_History_Related_Opportunity__r.Owner_Email__c;
                    toEmailCounter += 1;
                }
                if(agreement.Complete_Consent__c){  
                    productList.add(CON_OWF.BHR_CSS_REQUESTED_PRODUCT_COMPLETE_CONSENT);
                }
                if(agreement.PCS__c){
                    productList.add(CON_OWF.BHR_CSS_REQUESTED_PRODUCT_PCS);
                }
                if(agreement.eCOA__c){
                    productList.add(CON_OWF.BHR_CSS_REQUESTED_PRODUCT_ECOA);
                }
                if(agreement.IRT__c){
                    productList.add(CON_OWF.BHR_CSS_REQUESTED_PRODUCT_CENDUILT_IRT);
                }
                if(agreement.Grant_Plan__c){
                    productList.add(CON_OWF.BHR_CSS_REQUESTED_PRODUCT_GRANT_PLAN);
                }
                if(agreement.Study_Optimizer__c){
                    productList.add(CON_OWF.BHR_CSS_REQUESTED_PRODUCT_STUDY_OPTIMIZER);
                }
                if(agreement.Site_Portal__c){
                    productList.add(CON_OWF.BHR_CSS_REQUESTED_PRODUCT_SITE_PORTAL);
                }
                if(agreement.eTMF__c){
                    productList.add(CON_OWF.BHR_CSS_REQUESTED_PRODUCT_ETMF);
                }
                if(agreement.Risk_Based_Monitoring__c){
                    productList.add(CON_OWF.BHR_CSS_REQUESTED_RISK_BASED_MONITORIING);
                }
                if(agreement.CDAS__c){
                    productList.add(CON_OWF.BHR_CSS_REQUESTED_CDAS);
                }
                if(agreement.DQS__c){
                    productList.add(CON_OWF.BHR_CSS_REQUESTED_DQS);
                }
                if(agreement.One_Home_for_Sites__c){
                    productList.add(CON_OWF.BHR_CSS_REQUESTED_ONE_HOME_FOR_SITES);
                }
                if(agreement.Participant_Payments__c){
                    productList.add(CON_OWF.BHR_CSS_REQUESTED_PARTICIPANT_PAYMENTS);
                }
                if(agreement.Payments_Forecasting__c){
                    productList.add(CON_OWF.BHR_CSS_REQUESTED_PAYMENTS_FORECASTING);
                }
                if(agreement.Connected_Devices__c && (agreement.IRT__c || agreement.eCOA__c || agreement.Complete_Consent__c || agreement.Grant_Plan__c || agreement.Participant_Payments__c || agreement.Payments_Forecasting__c || agreement.Site_Portal__c || agreement.DQS__c || agreement.Study_Optimizer__c || agreement.eTMF__c || agreement.One_Home_for_Sites__c || agreement.CDAS__c || agreement.Risk_Based_Monitoring__c)) {
                    productList.add(CON_OWF.BHR_CSS_REQUESTED_PRODUCT_CONNECTED_DEVICES);
                    if(agreement.Clinical_Technology_Opportunity_Type__c == CON_OWF.CLINICAL_TECHNOLOGY_OPP_TYPE_CROPT && resourceEmail.get('CROPT') != null && resourceEmail.get('CROPT').Value__c != null){
                        workFlowRecord = assignEmailToMultipleToEmailFields(workFlowRecord, (resourceEmail.get('CROPT').Value__c + ',' + resourceEmail.get(CON_OWF.BHR_CSS_REQUESTED_PRODUCT_CONNECTED_DEVICES).Value__c));  
                    }
                    if(agreement.Clinical_Technology_Opportunity_Type__c == CON_OWF.CLINICAL_TECHNOLOGY_OPP_TYPE_DIRECT && resourceEmail.get('DIRECT') != null && resourceEmail.get('DIRECT').Value__c != null){
                        workFlowRecord = assignEmailToMultipleToEmailFields(workFlowRecord, (resourceEmail.get('DIRECT').Value__c + ',' + resourceEmail.get(CON_OWF.BHR_CSS_REQUESTED_PRODUCT_CONNECTED_DEVICES).Value__c));
                    }
                    if(agreement.Clinical_Technology_Opportunity_Type__c == null && resourceEmail.get(CON_OWF.BHR_CSS_REQUESTED_PRODUCT_CONNECTED_DEVICES) != null && resourceEmail.get(CON_OWF.BHR_CSS_REQUESTED_PRODUCT_CONNECTED_DEVICES).Value__c != null) {
                        workFlowRecord = assignEmailToMultipleToEmailFields(workFlowRecord, resourceEmail.get(CON_OWF.BHR_CSS_REQUESTED_PRODUCT_CONNECTED_DEVICES).Value__c);
                    }
                }
                else if(agreement.Connected_Devices__c){
                    productList.add(CON_OWF.BHR_CSS_REQUESTED_PRODUCT_CONNECTED_DEVICES);
                    if(resourceEmail.get(CON_OWF.BHR_CSS_REQUESTED_PRODUCT_CONNECTED_DEVICES) != null && resourceEmail.get(CON_OWF.BHR_CSS_REQUESTED_PRODUCT_CONNECTED_DEVICES).Value__c != null){
                        workFlowRecord = assignEmailToMultipleToEmailFields(workFlowRecord, resourceEmail.get(CON_OWF.BHR_CSS_REQUESTED_PRODUCT_CONNECTED_DEVICES).Value__c);    
                    }
                }
                else{
                    if(agreement.Clinical_Technology_Opportunity_Type__c == CON_OWF.CLINICAL_TECHNOLOGY_OPP_TYPE_CROPT && resourceEmail.get('CROPT') != null && resourceEmail.get('CROPT').Value__c != null){
                        workFlowRecord = assignEmailToMultipleToEmailFields(workFlowRecord, resourceEmail.get('CROPT').Value__c);  
                    }
                    if(agreement.Clinical_Technology_Opportunity_Type__c == CON_OWF.CLINICAL_TECHNOLOGY_OPP_TYPE_DIRECT && resourceEmail.get('DIRECT') != null && resourceEmail.get('DIRECT').Value__c != null){
                        workFlowRecord = assignEmailToMultipleToEmailFields(workFlowRecord, resourceEmail.get('DIRECT').Value__c);
                    }
                }
                productChecked = String.join(new List<String>(productList), ', ');
                workFlowRecord.Email_Action__c = emailAction;
                workFlowRecord.Module_Name__c = moduleName;
                workFlowRecord.Email_Subject__c = (agreement.Bid_Type__c != null ? (agreement.Bid_Type__c == 'initial' ? agreement.Bid_Type__c : agreement.Bid_Type__c+' '+agreement.Bid_Number__c) : ('')) + '- ' + (agreement.Bid_Category__c != null ? agreement.Bid_Category__c : ('')) + '-' +
                (agreement.Bid_History_Account__r.Name != null ? agreement.Bid_History_Account__r.Name : ('')) + ' - ' + (agreement.Legacy_Quintiles_Opportunity_Number__c != null ? agreement.Legacy_Quintiles_Opportunity_Number__c : (''))+ ' -' +' Parent ID: '+
                (agreement.Bid_History_Related_Opportunity__r.Parent_Opportunity__r.Legacy_Quintiles_Opportunity_Number__c != null ? agreement.Bid_History_Related_Opportunity__r.Parent_Opportunity__r.Legacy_Quintiles_Opportunity_Number__c : ('')) + '- ' +(String.valueOf(agreement.Bid_Due_Date__c) != null ? String.valueOf(agreement.Bid_Due_Date__c) : (''));              
                if(agreement.Opportunity_Type__c == CON_OWF.OWF_BID_HISTORY_OPPORTUNITY_TYPE_RFP_ONLY) {
                    emailOverallBodyContent = '<div><b>Dear RFP Mailbox</b><br><br>';
                    emailOverallBodyContent += '<b>Pertinent details/specific rebid request: <b>' + '<span style = "font-weight: normal;">' + (agreement.Pertinent_Details_Specific_Rebid_Request__c != null ? agreement.Pertinent_Details_Specific_Rebid_Request__c : ('')) + '</span>' +'<br>';
                    emailOverallBodyContent += '<b>Clinical Technology Opportunity Type: <b>' + '<span style = "font-weight: normal;">' + (agreement.Clinical_Technology_Opportunity_Type__c != null ? agreement.Clinical_Technology_Opportunity_Type__c : ('')) + '</span>' +'<br><br>';
                    emailOverallBodyContent += '<b>Opportunity Type: <b>' + '<span style = "font-weight: normal;">' + (agreement.Opportunity_Type__c != null ? agreement.Opportunity_Type__c : ('')) + '</span>' +'<br><br>';
                    emailOverallBodyContent += '<b>Bid due date: </b><span style = "font-weight: normal;">' + (String.valueOf(agreement.Bid_Due_Date__c) != null ? String.valueOf(agreement.Bid_Due_Date__c) : ('')) + '</span><br>';
                    emailOverallBodyContent += '<b>Client Deliverable: </b><span style = "font-weight: normal;">' + (String.valueOf(agreement.Client_Deliverable_What_is_the_client_s__c) != null ? String.valueOf(agreement.Client_Deliverable_What_is_the_client_s__c) : ('')) + '</span><br><br>';
                    emailOverallBodyContent += '<b>RFI Request Type: </b><span style = "font-weight: normal;">' + (agreement.RFI_Request_Type__c != null ? agreement.RFI_Request_Type__c : ('')) + '</span><br><br>';
                    emailOverallBodyContent += '<b>Core Information</b><br>';
                    emailOverallBodyContent += '<b>Requested Products: </b><span style = "font-weight: normal;">' + productChecked + '</span><br>';
                    emailOverallBodyContent += '<b>Indication: </b><span style = "font-weight: normal;">' + (String.valueOf(agreement.Indication__c) != null ? String.valueOf(agreement.Indication__c) : ('')) + '</span><br><br>';
                    emailOverallBodyContent += '<b>Link to Bid History: </b><span style = "font-weight: normal;"><a href = \'' + URL.getOrgDomainUrl().toExternalForm() + '/' + (agreement.id != null ? agreement.id : ('')) + '\'>' + (agreement.Name != null ? agreement.Name : ('')) + '</a></span><br>';
                    emailOverallBodyContent += '<b>Link to Opportunity: </b><span style = "font-weight: normal;"><a href = \'' + URL.getOrgDomainUrl().toExternalForm() + '/' + (agreement.Bid_History_Related_Opportunity__r.Id != null ? agreement.Bid_History_Related_Opportunity__r.Id : ('')) + '\'>' + (agreement.Bid_History_Related_Opportunity__r.Name != null ? agreement.Bid_History_Related_Opportunity__r.Name : ('')) + '</a></span><br><br>';
                    emailOverallBodyContent += '<b>Opportunity Information</b><br>';
                    emailOverallBodyContent += '<b>Opportunity Name: </b><span style = "font-weight: normal;">' + (String.valueOf(agreement.Bid_History_Related_Opportunity__r.Name) != null ? String.valueOf(agreement.Bid_History_Related_Opportunity__r.Name) : ('')) + '</span><br>';
                    emailOverallBodyContent += '<b>Account Name: </b><span style = "font-weight: normal;">' + (String.valueOf(agreement.Bid_History_Account__r.Name) != null ? String.valueOf(agreement.Bid_History_Account__r.Name) : ('')) + '</span><br>';
                    emailOverallBodyContent += '<b>Opportunity Owner: </b><span style = "font-weight: normal;">' + (agreement.Opportunity_Owner__c != null ? agreement.Opportunity_Owner__c : ('')) + '</span><br>';
                    emailOverallBodyContent += '<b>Opportunity Number: </b><span style = "font-weight: normal;">' + (agreement.Opportunity_Number__c != null ? agreement.Opportunity_Number__c : ('')) + '</span><br>';
                }
                if(agreement.Opportunity_Type__c == CON_OWF.OWF_BID_HISTORY_OPPORTUNITY_TYPE_RFP || agreement.Opportunity_Type__c == CON_OWF.OWF_BID_HISTORY_OPPORTUNITY_TYPE_RFP_AND_RFI) {
                    emailOverallBodyContent = '<div><b>Dear RFP Mailbox</b><br><br>';
                    emailOverallBodyContent += '<b>Pertinent details/specific rebid request: <b>' + '<span style = "font-weight: normal;">' + (agreement.Pertinent_Details_Specific_Rebid_Request__c != null ? agreement.Pertinent_Details_Specific_Rebid_Request__c : ('')) + '</span>' +'<br><br>';
                    emailOverallBodyContent += '<b>Clinical Technology Opportunity Type: <b>' + '<span style = "font-weight: normal;">' + (agreement.Clinical_Technology_Opportunity_Type__c != null ? agreement.Clinical_Technology_Opportunity_Type__c : ('')) + '</span>' +'<br><br>';
                    emailOverallBodyContent += '<b>Opportunity Type: <b>' + '<span style = "font-weight: normal;">' + (agreement.Opportunity_Type__c != null ? agreement.Opportunity_Type__c : ('')) + '</span>' +'<br><br>';
                    emailOverallBodyContent += '<b>Opportunity Dates</b><br>';
                    emailOverallBodyContent += '<b>FPI: </b><span style = "font-weight: normal;">' + (String.valueOf(agreement.FPI_Date__c) != null ? (((Datetime)agreement.FPI_Date__c).formatGmt('dd-MM-YYYY')) : ('')) + '</span><br>';
                    emailOverallBodyContent += '<b>LPI: </b><span style = "font-weight: normal;">' + (String.valueOf(agreement.LPI_Date__c) != null ? (((Datetime)agreement.LPI_Date__c).formatGmt('dd-MM-YYYY')) : ('')) + '</span><br>';
                    emailOverallBodyContent += '<b>LPO: </b><span style = "font-weight: normal;">' + (String.valueOf(agreement.LPO_Date__c) != null ? (((Datetime)agreement.LPO_Date__c).formatGmt('dd-MM-YYYY')) : ('')) + '</span><br>';
                    emailOverallBodyContent += '<b>DBL: </b><span style = "font-weight: normal;">' + (String.valueOf(agreement.DBL_Date__c) != null ? (((Datetime)agreement.DBL_Date__c).formatGmt('dd-MM-YYYY')) : ('')) + '</span><br>';
                    emailOverallBodyContent += '<b>Bid due date: </b><span style = "font-weight: normal;">' + (String.valueOf(agreement.Bid_Due_Date__c) != null ? (((Datetime)agreement.Bid_Due_Date__c).formatGmt('dd-MM-YYYY')) : ('')) + '</span><br>';
                    emailOverallBodyContent += '<b>Proposal Format: </b><span style = "font-weight: normal;">' + (String.valueOf(agreement.Is_PPT_Format_Required__c) != null ? String.valueOf(agreement.Is_PPT_Format_Required__c) : ('')) + '</span><br>';
                    emailOverallBodyContent += '<b>Client Deliverable: </b><span style = "font-weight: normal;">' + (String.valueOf(agreement.Client_Deliverable_What_is_the_client_s__c) != null ? String.valueOf(agreement.Client_Deliverable_What_is_the_client_s__c) : ('')) + '</span><br><br>';
                    emailOverallBodyContent += '<b>Efficiencies: </b><span style = "font-weight: normal;">' + (agreement.Efficiencies_to_be_considered__c != null ? agreement.Efficiencies_to_be_considered__c : ('')) + '</span><br><br>';
                    emailOverallBodyContent += '<b>Orchestration to be considered?: </b><span style = "font-weight: normal;">' + (String.valueOf(agreement.Orchestration_to_be_considered__c) != null ? String.valueOf(agreement.Orchestration_to_be_considered__c) : ('')) + '</span><br><br>';
                    emailOverallBodyContent += '<b>Core Information</b><br>';
                    emailOverallBodyContent += '<b>Requested Products: </b><span style = "font-weight: normal;">' + productChecked + '</span><br><br>';
                    emailOverallBodyContent += '<b>Indication: </b><span style = "font-weight: normal;">' + (String.valueOf(agreement.Indication__c) != null ? String.valueOf(agreement.Indication__c) : ('')) + '</span><br>';
                    emailOverallBodyContent += '<b>Therapy Area: </b><span style = "font-weight: normal;">' + (String.valueOf(agreement.Therapy_Area__c) != null ? String.valueOf(agreement.Therapy_Area__c) : ('')) + '</span><br>';
                    emailOverallBodyContent += '<b>Protocol Name/Number: </b><span style = "font-weight: normal;">' + (agreement.Protocol_Number__c != null ? agreement.Protocol_Number__c : ('')) + '</span><br><br>';
                    emailOverallBodyContent += '<b>Phase: </b><span style = "font-weight: normal;">' + (String.valueOf(agreement.Phase__c) != null ? String.valueOf(agreement.Phase__c) : ('')) + '</span><br>';
                    emailOverallBodyContent += '<b>Customer Discount in place or Requested: </b><span style = "font-weight: normal;">' + (String.valueOf(agreement.Customer_discount_in_place_or_requested__c) != null ? String.valueOf(agreement.Customer_discount_in_place_or_requested__c) : ('')) + '</span><br>';
                    emailOverallBodyContent += '<b>Is there a Client Grid?: </b><span style = "font-weight: normal;">' + (String.valueOf(agreement.Is_there_a_Client_Bid_Grid__c) != null ? String.valueOf(agreement.Is_there_a_Client_Bid_Grid__c) : ('')) + '</span><br>';
                    emailOverallBodyContent += '<b>Amount: </b><span style = "font-weight: normal;">' + (String.valueOf(agreement.Bid_History_Related_Opportunity__r.Amount) != null ? String.valueOf(agreement.Bid_History_Related_Opportunity__r.Amount) : ('')) + '</span><br>';
                    emailOverallBodyContent += '<b>Currency: </b><span style = "font-weight: normal;">' + (String.valueOf(agreement.CurrencyIsoCode) != null ? String.valueOf(agreement.CurrencyIsoCode) : ('')) + '</span><br>';
                    emailOverallBodyContent += '<b>Rate Card/MSA?: </b><span style = "font-weight: normal;">' + (String.valueOf(agreement.Rate_Card_MSA__c) != null ? String.valueOf(agreement.Rate_Card_MSA__c) : ('')) + '</span><br>';
                    emailOverallBodyContent += '<b>Is this Part of a Program?: </b><span style = "font-weight: normal;">' + (String.valueOf(agreement.Is_this_part_of_a_Program__c) != null ? String.valueOf(agreement.Is_this_part_of_a_Program__c) : ('')) + '</span><br>';
                    emailOverallBodyContent += '<b>Associated CRM Opportunity Numbers: </b><span style = "font-weight: normal;">' + (agreement.Associated_CRM_Numbers__c != null ? agreement.Associated_CRM_Numbers__c : ('')) + '</span><br><br>';
                    emailOverallBodyContent += '<b>Link to Bid History: </b><span style = "font-weight: normal;"><a href = \'' + URL.getOrgDomainUrl().toExternalForm() + '/' + (agreement.id != null ? agreement.id : ('')) + '\'>' + (agreement.Name != null ? agreement.Name : ('')) + '</a></span><br><br>';
                    emailOverallBodyContent += '<b>Link to Opportunity: </b><span style = "font-weight: normal;"><a href = \'' + URL.getOrgDomainUrl().toExternalForm() + '/' + (agreement.Bid_History_Related_Opportunity__r.Id != null ? agreement.Bid_History_Related_Opportunity__r.Id : ('')) + '\'>' + (agreement.Bid_History_Related_Opportunity__r.Name != null ? agreement.Bid_History_Related_Opportunity__r.Name : ('')) + '</a></span><br><br><br>';
                    emailOverallBodyContent += '<b>Opportunity Information</b><br>';
                    emailOverallBodyContent += '<b>Opportunity Name: </b><span style = "font-weight: normal;">' + (String.valueOf(agreement.Bid_History_Related_Opportunity__r.Name) != null ? String.valueOf(agreement.Bid_History_Related_Opportunity__r.Name) : ('')) + '</span><br>';
                    emailOverallBodyContent += '<b>Account Name: </b><span style = "font-weight: normal;">' + (String.valueOf(agreement.Bid_History_Account__r.Name) != null ? String.valueOf(agreement.Bid_History_Account__r.Name) : ('')) + '</span><br>';
                    emailOverallBodyContent += '<b>Opportunity Owner: </b><span style = "font-weight: normal;">' + (agreement.Opportunity_Owner__c != null ? agreement.Opportunity_Owner__c : ('')) + '</span><br>';
                    emailOverallBodyContent += '<b>Opportunity Number: </b><span style = "font-weight: normal;">' + (agreement.Opportunity_Number__c != null ? agreement.Opportunity_Number__c : ('')) + '</span><br>';
                    emailOverallBodyContent += '<b>LQ Opportunity Number: </b><span style = "font-weight: normal;">' + (agreement.Legacy_Quintiles_Opportunity_Number__c != null ? agreement.Legacy_Quintiles_Opportunity_Number__c : ('')) + '</span><br>';
                    emailOverallBodyContent += '<b>Parent Opportunity Number: </b><span style = "font-weight: normal;">' + (String.valueOf(agreement.Bid_History_Related_Opportunity__r.Parent_Opportunity__r.Legacy_Quintiles_Opportunity_Number__c) != null ? String.valueOf(agreement.Bid_History_Related_Opportunity__r.Parent_Opportunity__r.Legacy_Quintiles_Opportunity_Number__c) : ('')) + '</span><br>';
                    emailOverallBodyContent += '<b>Line of Business: </b><span style = "font-weight: normal;">' + (agreement.Line_of_Business__c != null ? agreement.Line_of_Business__c : ('')) + '</span><br>';
                }
                emailOverallBodyContent += '</div>';
                if(emailOverallBodyContent.length() < content1FieldLength){
                    workFlowRecord.content_1__c = emailOverallBodyContent;
                }else{
                    workFlowRecord.content_1__c = emailOverallBodyContent.substring(0, content1FieldLength-1);
                    if(emailOverallBodyContent.length() < content1FieldLength+content2FieldLength-2 ) {
                        workFlowRecord.content_2__c = emailOverallBodyContent.substring(content1FieldLength-1, emailOverallBodyContent.length());
                    } else {
                        workFlowRecord.content_2__c = emailOverallBodyContent.substring(content1FieldLength-1, content1FieldLength+content2FieldLength-2);
                    }
                }
                if(productList.size() > 0 || agreement.Line_of_Business__c == CON_OWF.OPP_LINE_OF_BUSINESS_CONNECTED_DEVICES){
                    workflowEmailRecordsToInsertList.add(workFlowRecord);
                }
                emailOverallBodyContent = '';
            }
        }
        toEmailCounter = 1;
        if(workflowEmailRecordsToInsertList.size() > 0){
            Database.insert(workflowEmailRecordsToInsertList, false);
        }
    }
    
    //assign email to "To_Email_(n)__c" fields dynamically to Workflow_Email_Record__c record based on comma seperated input emailsString
    public static Workflow_Email_Record__c assignEmailToMultipleToEmailFields(Workflow_Email_Record__c objWorkFlowEmailRecord, String emailsString){
        List<String> emailsList = emailsString.split(',');
        if(emailsList != null){
            for(String email : emailsList){
                objWorkFlowEmailRecord.put('To_Email_' + toEmailCounter + '__c', email.trim());
                toEmailCounter += 1;
            }
        }
        return objWorkFlowEmailRecord;
    }
    
    public static List<UTL_OWF.workflowEmailRecordWrapper> sendEmailForQ2LabBidHistoryScientificReview(Map<id, Bid_History__c> q2LabBidHistoryScientificReviewMap){
        List<UTL_OWF.workflowEmailRecordWrapper> workflowEmailRecordWrapperMessageList = new List<UTL_OWF.workflowEmailRecordWrapper>();
        List<String> toCcEmailList = new List<String>();
        
        OWF_Generic_Setting__c additionalEmail = OWF_Generic_Setting__c.getValues(CON_OWF.BHR_OWF_Q2LAB_Bid_History_Scientific_Review);
        if(additionalEmail != null && additionalEmail.Value__c != null){
            toCcEmailList = (additionalEmail.Value__c).split(',');
        }
        if(toCcEmailList.size()>0){
            List<String> toEmailList = new List<String>();
            String subject = '';
            String emailOverallBodyContent = '';
            UTL_OWF.workflowEmailRecordWrapper workflowEmailRecordWrapperMessage = new UTL_OWF.workflowEmailRecordWrapper();
            for(Bid_History__c bidHistory : q2LabBidHistoryScientificReviewMap.values()){
                toEmailList = new List<String>();
                subject = '';
                emailOverallBodyContent = '';
                if(bidHistory.Bid_History_Related_Opportunity__r.Owner_Email__c != null){
                    toEmailList.add(bidHistory.Bid_History_Related_Opportunity__r.Owner_Email__c);
                }
                workflowEmailRecordWrapperMessage = new UTL_OWF.workflowEmailRecordWrapper();
                subject ='NEW Scientific Review Request for ' + (bidHistory.Opportunity_Account__c != null ? bidHistory.Opportunity_Account__c : ('')) + ' - ' + (bidHistory.Protocol_Number__c != null ? bidHistory.Protocol_Number__c :('')) + ' - ' + (bidHistory.Legacy_Quintiles_Opportunity_Number__c  != null ? bidHistory.Legacy_Quintiles_Opportunity_Number__c  :('')) + ' - ' + (String.valueOf(bidHistory.Science_Due_Date__c) != null ? String.valueOf(bidHistory.Science_Due_Date__c) :(''));
                emailOverallBodyContent = '<div>A new opportunity has been received for ' + (bidHistory.Opportunity_Account__c != null ? bidHistory.Opportunity_Account__c : ('')) + ' - ' + (bidHistory.Protocol_Number__c != null ? bidHistory.Protocol_Number__c :('')) + ' which requires a scientific review.<br><br>';
                emailOverallBodyContent += 'Please see below for a summary of the key study information and a link to the CRM Bid History record where full RFP information and documents can be obtained.<br><br>';
                emailOverallBodyContent += '<b>Bid History Link: </b><span style = "font-weight: normal;"><a href = \'' + URL.getOrgDomainUrl().toExternalForm() + '/' + (bidHistory.id != null ? bidHistory.id : ('')) + '\'>' + (bidHistory.Name != null ? bidHistory.Name : ('')) + '</a></span><br>';
                emailOverallBodyContent += '<b>Sponsor: </b><span style = "font-weight: normal;">' + (bidHistory.Opportunity_Account__c != null ? bidHistory.Opportunity_Account__c : ('')) + '</span><br>';
                emailOverallBodyContent += '<b>Opportunity Owner: </b><span style = "font-weight: normal;">' + (bidHistory.Bid_History_Related_Opportunity__r.Owner.Name != null ? bidHistory.Bid_History_Related_Opportunity__r.Owner.Name : ('')) + '</span><br>';
                emailOverallBodyContent += '<b>Bid Owner: </b><span style = "font-weight: normal;">' + (bidHistory.Owner.Name != null ? bidHistory.Owner.Name : ('')) + '</span><br>';
                emailOverallBodyContent += '<b>Budget Tool: </b><span style = "font-weight: normal;">' + (bidHistory.Q2_Budget_Tools__c != null ? bidHistory.Q2_Budget_Tools__c : ('')) + '</span><br>';
                emailOverallBodyContent += '<b>Budget Deliverables: </b><span style = "font-weight: normal;">' + (bidHistory.Budget_Deliverable__c != null ? bidHistory.Budget_Deliverable__c : ('')) + '</span><br>';
                emailOverallBodyContent += '<b>Protocol Number: </b><span style = "font-weight: normal;">' + (bidHistory.Protocol_Number__c != null ? bidHistory.Protocol_Number__c : ('')) + '</span><br>';
                emailOverallBodyContent += '<b>Opportunity Number: </b><span style = "font-weight: normal;">' + (bidHistory.Legacy_Quintiles_Opportunity_Number__c  != null ? bidHistory.Legacy_Quintiles_Opportunity_Number__c  : ('')) + '</span><br>';
                emailOverallBodyContent += '<b><span style="color:red;">Bid Type: </b><span style = "font-weight: normal;color:red;">' + (bidHistory.Bid_Type__c != null ? bidHistory.Bid_Type__c : ('')) + '</span></span><br>';
                emailOverallBodyContent += '<b>Bid Number: </b><span style = "font-weight: normal;">' + (String.valueOf(bidHistory.Bid_Number__c) != null ? String.valueOf(bidHistory.Bid_Number__c) : ('')) + '</span><br>';
                emailOverallBodyContent += '<b>Indication: </b><span style = "font-weight: normal;">' + (bidHistory.Indication__c != null ? bidHistory.Indication__c : ('')) + '</span><br>';
                emailOverallBodyContent += '<b>Study Phase: </b><span style = "font-weight: normal;">' + (bidHistory.Study_Phase__c != null ? bidHistory.Study_Phase__c : ('')) + '</span><br>';
                emailOverallBodyContent += '<b>Study Start Date: </b><span style = "font-weight: normal;">' + (String.valueOf(bidHistory.Expected_Project_Start_Date__c) != null ? String.valueOf(bidHistory.Expected_Project_Start_Date__c) : ('')) + '</span><br>';
                emailOverallBodyContent += '<b>Enrollment (Months): </b><span style = "font-weight: normal;">' + (String.valueOf(bidHistory.Enrollement_Months__c) != null ? String.valueOf(bidHistory.Enrollement_Months__c) : ('')) + '</span><br>';
                emailOverallBodyContent += '<b>Patient Duration (Months): </b><span style = "font-weight: normal;">' + (String.valueOf(bidHistory.Patient_Duration_Months__c) != null ? String.valueOf(bidHistory.Patient_Duration_Months__c) : ('')) + '</span><br>';
                emailOverallBodyContent += '<b>Region(s): </b><span style = "font-weight: normal;">' + (bidHistory.OWF_Potential_Regions__c != null ? bidHistory.OWF_Potential_Regions__c : ('')) + '</span><br>';
                emailOverallBodyContent += '<b>Requested Services: </b><span style = "font-weight: normal;">' + (bidHistory.Requested_Services__c != null ? bidHistory.Requested_Services__c : ('')) + '</span><br><br>';
                emailOverallBodyContent += '<b>Scientific Review Due Date: </b><span style = "font-weight: normal;">' + (String.valueOf(bidHistory.Science_Due_Date__c) != null ? String.valueOf(bidHistory.Science_Due_Date__c) : ('')) + '</span><br>';
                emailOverallBodyContent += '<b>Additional Study Comments/Information: </b><span style = "font-weight: normal;">' + (bidHistory.Pertinent_Details_Specific_Rebid_Request__c != null ? bidHistory.Pertinent_Details_Specific_Rebid_Request__c : ('')) + '</span><br>';
                emailOverallBodyContent += '</div>';
                
                workflowEmailRecordWrapperMessage.whatId = bidHistory.Id;
                workflowEmailRecordWrapperMessage.toEmails = toEmailList;
                workflowEmailRecordWrapperMessage.ccEmails = toCcEmailList;
                workflowEmailRecordWrapperMessage.emailAction = CON_OWF.Q2LAB_BID_HISTORY_SCIENTIFIC_REVIEW_EMAIL_ACTION;
                workflowEmailRecordWrapperMessage.subject = subject;
                workflowEmailRecordWrapperMessage.staticContent = emailOverallBodyContent;
                workflowEmailRecordWrapperMessageList.add(workflowEmailRecordWrapperMessage);
                
            }  
        }
        
        return workflowEmailRecordWrapperMessageList;
        
    }
    
    public static List<UTL_OWF.workflowEmailRecordWrapper> sendEmailForQ2SolutionsStrategicPricingLeadAssigned(Map<id, Bid_History__c> q2SolutionsStrategicPricingLeadAssigned){
        List<UTL_OWF.workflowEmailRecordWrapper> workflowEmailRecordWrapperMessageList = new List<UTL_OWF.workflowEmailRecordWrapper>();

            List<String> toEmailList = new List<String>();
            String subject = '';
            String emailOverallBodyContent = '';
            UTL_OWF.workflowEmailRecordWrapper workflowEmailRecordWrapperMessage = new UTL_OWF.workflowEmailRecordWrapper();
        
            for(Bid_History__c bidHistory : q2SolutionsStrategicPricingLeadAssigned.values()){
                toEmailList = new List<String>();
                subject = '';
                emailOverallBodyContent = '';
                if(bidHistory.Bid_History_Related_Opportunity__r.Owner_Email__c != null){
                    toEmailList.add(bidHistory.Bid_History_Related_Opportunity__r.Owner_Email__c);
                }
                if(bidHistory.Strategic_Pricing_Lead__r.Email != null){
                    toEmailList.add(bidHistory.Strategic_Pricing_Lead__r.Email);
                }
                /*if(bidHistory.Bid_Owner_Email__c != null){
                    toEmailList.add(bidHistory.Bid_Owner_Email__c);
                }*/
                workflowEmailRecordWrapperMessage = new UTL_OWF.workflowEmailRecordWrapper();
                subject =  'Strategic Pricing Lead Assigned' + ' - ' + (bidHistory.Opportunity_Account__c != null ? bidHistory.Opportunity_Account__c : ('')) + '-' + (bidHistory.Protocol_Number__c != null ? bidHistory.Protocol_Number__c : ('')) + '-' + (bidHistory.Legacy_Quintiles_Opportunity_Number__c  != null ? bidHistory.Legacy_Quintiles_Opportunity_Number__c  : ('')) + '-' + (String.valueOf(bidHistory.Bid_Due_Date__c) != null ? String.valueOf(bidHistory.Bid_Due_Date__c) : (''));
                emailOverallBodyContent = '<div>Hi ' + (bidHistory.Strategic_Pricing_Lead__r.Name != null ? bidHistory.Strategic_Pricing_Lead__r.Name : ('')) + '<br><br>';
                emailOverallBodyContent += 'Please see details below for a new opportunity from ' + (bidHistory.Bid_History_Related_Opportunity__r.Owner.Name != null ? bidHistory.Bid_History_Related_Opportunity__r.Owner.Name : ('')) + ' for ' + (bidHistory.Opportunity_Account__c != null ? bidHistory.Opportunity_Account__c : ('')) + ' requiring Strategic Pricing input and review.<br><br>';
                emailOverallBodyContent += 'Opportunity number: ' + (bidHistory.Legacy_Quintiles_Opportunity_Number__c  != null ? bidHistory.Legacy_Quintiles_Opportunity_Number__c  : ('')) + '<br><br>';
                emailOverallBodyContent += 'Opportunity account: ' + (bidHistory.Opportunity_Account__c != null ? bidHistory.Opportunity_Account__c : ('')) + '<br>';
                emailOverallBodyContent += 'Protocol number: ' + (bidHistory.Protocol_Number__c != null ? bidHistory.Protocol_Number__c : ('')) + '<br>';
                emailOverallBodyContent += 'Assigned PD: ' + (bidHistory.Owner.Name != null ? bidHistory.Owner.Name : ('')) + '<br><br>';
                emailOverallBodyContent += 'Bid due date: ' + (String.valueOf(bidHistory.Bid_Due_Date__c) != null ? String.valueOf(bidHistory.Bid_Due_Date__c) : ('')) + '<br>';
                emailOverallBodyContent += 'Date Requested: ' + (String.valueOf(bidHistory.Date_Review_Requested__c) != null ? String.valueOf(bidHistory.Date_Review_Requested__c) : ('')) + '<br><br>';
                emailOverallBodyContent += 'Additional Detail: ' + (bidHistory.Pertinent_Details_Specific_Rebid_Request__c != null ? bidHistory.Pertinent_Details_Specific_Rebid_Request__c : ('')) + '<br>';
                emailOverallBodyContent += 'Link to Bid History: <a href = \'' + URL.getOrgDomainUrl().toExternalForm() + '/' + (bidHistory.id != null ? bidHistory.id : ('')) + '\'>' + (bidHistory.Name != null ? bidHistory.Name : ('')) + '</a><br>';
                emailOverallBodyContent += '</div>';
                
                workflowEmailRecordWrapperMessage.whatId = bidHistory.Id;
                workflowEmailRecordWrapperMessage.toEmails = toEmailList;
                workflowEmailRecordWrapperMessage.ownerId = bidHistory.OwnerId;
                workflowEmailRecordWrapperMessage.emailAction = CON_OWF.Q2LAB_STRATEGIC_PRICING_LEAD_ASSIGNED_EMAIL_ACTION;
                workflowEmailRecordWrapperMessage.subject = subject;
                workflowEmailRecordWrapperMessage.staticContent = emailOverallBodyContent;
                workflowEmailRecordWrapperMessageList.add(workflowEmailRecordWrapperMessage);
                
            }  
        
        return workflowEmailRecordWrapperMessageList;
        
    }
    
    public static List<UTL_OWF.workflowEmailRecordWrapper> sendEmailForQ2SolutionsBidHistoryAdvionQuoteRequested(Map<id, Bid_History__c> q2SolutionsBidHistoryAdvionQuoteRequestedDataMap){
        List<UTL_OWF.workflowEmailRecordWrapper> workflowEmailRecordWrapperMessageList = new List<UTL_OWF.workflowEmailRecordWrapper>();
        List<String> toCcEmailList = new List<String>();
        
        OWF_Generic_Setting__c additionalEmail = OWF_Generic_Setting__c.getValues(CON_OWF.BHR_OWF_04_BIOANALYTICALBD);
        if(additionalEmail != null && additionalEmail.Value__c != null){
            toCcEmailList = (additionalEmail.Value__c).split(',');
        }
        if(toCcEmailList.size()>0){
            List<String> toEmailList = new List<String>();
            String subject = '';
            String emailOverallBodyContent = '';
            UTL_OWF.workflowEmailRecordWrapper workflowEmailRecordWrapperMessage = new UTL_OWF.workflowEmailRecordWrapper();
            for(Bid_History__c agreement : q2SolutionsBidHistoryAdvionQuoteRequestedDataMap.values()){
                toEmailList = new List<String>();
                subject = '';
                emailOverallBodyContent = '';
                if(agreement.CreatedBy.Email != null){
                    toEmailList.add(agreement.CreatedBy.Email);
                }
                workflowEmailRecordWrapperMessage = new UTL_OWF.workflowEmailRecordWrapper();
                subject = 'New Review Request for '+(agreement.Opportunity_Account__c != null ? agreement.Opportunity_Account__c : ('')) + '-' + (agreement.Protocol_Number__c != null ? agreement.Protocol_Number__c : (''));
                emailOverallBodyContent = '<div>A Q² Biosciences opportunity has been requested for :<br><br>';
                emailOverallBodyContent += '<b>Account Name : </b>' + '<span style = "font-weight: normal;">' + (agreement.Opportunity_Account__c != null ? agreement.Opportunity_Account__c : ('')) + '</span>' +'<br><br>';
                emailOverallBodyContent += '<b>Opportunity Name : </b>' + '<span style = "font-weight: normal;">' + (agreement.Opportunity_Name__c != null ? agreement.Opportunity_Name__c : ('')) + '</span>' +'<br><br>';
                emailOverallBodyContent += '<b>Opportunity Number : </b>' + '<span style = "font-weight: normal;">' + (agreement.Legacy_Quintiles_Opportunity_Number__c  != null ? agreement.Legacy_Quintiles_Opportunity_Number__c  : ('')) + '</span>' +'<br><br>';
                emailOverallBodyContent += '<b>Protocol Number : </b>' + '<span style = "font-weight: normal;">' + (agreement.Protocol_Number__c != null ? agreement.Protocol_Number__c : ('')) + '</span>' +'<br><br>';
                emailOverallBodyContent += 'Please use the link below to take you to the Q² Solutions opportunity record.Please create a child Bioanalytical services Opportunity.<br>';
                emailOverallBodyContent += 'To access the protocol and other study specific documents, please refer to the Q² Solutions Bid History record link below .The documents will be included in Box.com.<br>';
                emailOverallBodyContent += 'Please provide the final Quote to the Q² Solutions Proposal Developer for inclusion into the Full Service Proposal.<br><br>';
                emailOverallBodyContent += '<b>Link to Q² Solutions Opportunity Record : </b><span style = "font-weight: normal;"><a href = \'' + URL.getOrgDomainUrl().toExternalForm() + '/' + (agreement.Bid_History_Related_Opportunity__r.Id != null ? agreement.Bid_History_Related_Opportunity__r.Id : ('')) + '\'>' + (agreement.Bid_History_Related_Opportunity__r.Name != null ? agreement.Bid_History_Related_Opportunity__r.Name : ('')) + '</a></span><br><br>';
                emailOverallBodyContent += '<b>Link to Q² Solutions Bid History Record : </b><span style = "font-weight: normal;"><a href = \'' + URL.getOrgDomainUrl().toExternalForm() + '/' + (agreement.id != null ? agreement.id : ('')) + '\'>' + (agreement.Name != null ? agreement.Name : ('')) + '</a></span><br><br>';
                emailOverallBodyContent += '<b>Q² Solutions Sales Lead : </b>' + '<span style = "font-weight: normal;">' + (agreement.Bid_History_Related_Opportunity__r.Owner.Name != null ? agreement.Bid_History_Related_Opportunity__r.Owner.Name : ('')) + '</span>' +'<br><br>';
                emailOverallBodyContent += '<b>Bid Due Date : </b>' + '<span style = "font-weight: normal;">' + (String.valueOf(agreement.Bid_Due_Date__c) != null ? String.valueOf(agreement.Bid_Due_Date__c) : ('')) + '</span>' +'<br><br>';
                emailOverallBodyContent += '<b>Drug Name : </b>' + '<span style = "font-weight: normal;">' + (agreement.Drug_Name__c != null ? agreement.Drug_Name__c : ('')) + '</span>' +'<br><br>';
                emailOverallBodyContent += '<b>Indication : </b>' + '<span style = "font-weight: normal;">' + (agreement.Indication__c != null ? agreement.Indication__c : ('')) + '</span>' +'<br><br>';
                emailOverallBodyContent += '<b>Study Phase : </b>' + '<span style = "font-weight: normal;">' + (agreement.Study_Phase__c != null ? agreement.Study_Phase__c : ('')) + '</span>' +'<br><br>';
                emailOverallBodyContent += '<b>Study Start Date : </b>' + '<span style = "font-weight: normal;">' + (String.valueOf(agreement.Study_Start_Date__c) != null ? String.valueOf(agreement.Study_Start_Date__c) : ('')) + '</span>' +'<br><br>';
                emailOverallBodyContent += '<b>Is there an existing validated method? : </b>' + '<span style = "font-weight: normal;">' + (agreement.Is_there_an_existing_validated_method__c != null ? agreement.Is_there_an_existing_validated_method__c : ('')) + '</span>' +'<br><br>';
                emailOverallBodyContent += '<b>Will sponsor transfer method? : </b>' + '<span style = "font-weight: normal;">' + (agreement.Will_sponsor_transfer_method__c != null ? agreement.Will_sponsor_transfer_method__c : ('')) + '</span>' +'<br><br>';
                emailOverallBodyContent += '<b>Will sponsor request development? : </b>' + '<span style = "font-weight: normal;">' + (agreement.Will_sponsor_request_development__c != null ? agreement.Will_sponsor_request_development__c : ('')) + '</span>' +'<br><br>';
                emailOverallBodyContent += '<b>Q2 Solutions Sales Additional Comments to BioSciences : </b>' + '<span style = "font-weight: normal;">' + (agreement.Q2LAB_Sales_Comments_for_BioSciences__c != null ? agreement.Q2LAB_Sales_Comments_for_BioSciences__c : ('')) + '</span>' +'<br><br><br>';
                emailOverallBodyContent += 'Sincerely<br>';
                emailOverallBodyContent += 'Q² Solutions Sales and Proposals<br>';
                emailOverallBodyContent += '</div>';
                
                workflowEmailRecordWrapperMessage.whatId = agreement.Id;
                workflowEmailRecordWrapperMessage.toEmails = toEmailList;
                workflowEmailRecordWrapperMessage.ccEmails = toCcEmailList;
                workflowEmailRecordWrapperMessage.emailAction = CON_OWF.Q2_SOLUTIONS_BIDHISTORY_ADVION_QUOTE_REQUESTED_EMAIL_ACTION;
                workflowEmailRecordWrapperMessage.subject = subject;
                workflowEmailRecordWrapperMessage.staticContent = emailOverallBodyContent;
                workflowEmailRecordWrapperMessageList.add(workflowEmailRecordWrapperMessage);
                
            }  
        }
        
        return workflowEmailRecordWrapperMessageList;
        
    }
    
    public static List<UTL_OWF.workflowEmailRecordWrapper> sendEmailForQ2SolutionsStrategicPricingInvolved(Map<id, Bid_History__c> q2SolutionsStrategicPricingInvolvedMap){
        List<UTL_OWF.workflowEmailRecordWrapper> workflowEmailRecordWrapperMessageList = new List<UTL_OWF.workflowEmailRecordWrapper>();
        List<String> toCcEmailList = new List<String>();
        
        OWF_Generic_Setting__c additionalEmail = OWF_Generic_Setting__c.getValues(CON_OWF.BHR_OWF_05_STRATEGICPRICING);
        if(additionalEmail != null && additionalEmail.Value__c != null){
            toCcEmailList = (additionalEmail.Value__c).split(',');
        }
        if(toCcEmailList.size()>0){
            List<String> toEmailList = new List<String>();
            String subject = '';
            String emailOverallBodyContent = '';
            UTL_OWF.workflowEmailRecordWrapper workflowEmailRecordWrapperMessage = new UTL_OWF.workflowEmailRecordWrapper();
            for(Bid_History__c agreement : q2SolutionsStrategicPricingInvolvedMap.values()){
                toEmailList = new List<String>();
                subject = '';
                emailOverallBodyContent = '';
                if(agreement.Bid_History_Related_Opportunity__r.Owner_Email__c != null){
                    toEmailList.add(agreement.Bid_History_Related_Opportunity__r.Owner_Email__c);
                }
                workflowEmailRecordWrapperMessage = new UTL_OWF.workflowEmailRecordWrapper();
                subject = 'New Strategic Pricing Request  '+(agreement.Opportunity_Account__c != null ? agreement.Opportunity_Account__c : ('')) + '-' + (agreement.Protocol_Number__c != null ? agreement.Protocol_Number__c : ('')) + '-' + (agreement.Legacy_Quintiles_Opportunity_Number__c  != null ? agreement.Legacy_Quintiles_Opportunity_Number__c  : ('')) + '-' + (String.valueOf(agreement.Bid_Due_Date__c) != null ? String.valueOf(agreement.Bid_Due_Date__c) : (''));
                emailOverallBodyContent =  '<div>Hi Strategic Pricing team, A new opportunity for ' + '<span style = "font-weight: normal;">' + (agreement.Opportunity_Account__c != null ? agreement.Opportunity_Account__c : ('')) + '</span>' + ' has been created which requires Strategic Pricing input.<br>';
                emailOverallBodyContent += 'Please see the key summary information below and assign a Strategic Pricing team member to work on this opportunity.<br><br>';
                emailOverallBodyContent += '<b>Opportunity Number : </b>' + '<span style = "font-weight: normal;">' + (agreement.Legacy_Quintiles_Opportunity_Number__c  != null ? agreement.Legacy_Quintiles_Opportunity_Number__c  : ('')) + '</span>' +'<br><br>';
                emailOverallBodyContent += '<b>Opportunity account : </b>' + '<span style = "font-weight: normal;">' + (agreement.Opportunity_Account__c != null ? agreement.Opportunity_Account__c : ('')) + '</span>' +'<br><br>';
                emailOverallBodyContent += '<b>Protocol Number : </b>' + '<span style = "font-weight: normal;">' + (agreement.Protocol_Number__c != null ? agreement.Protocol_Number__c : ('')) + '</span>' +'<br><br>';
                emailOverallBodyContent += '<b>Bid Due Date : </b>' + '<span style = "font-weight: normal;">' + (String.valueOf(agreement.Bid_Due_Date__c) != null ? String.valueOf(agreement.Bid_Due_Date__c) : ('')) + '</span>' +'<br><br>';
                emailOverallBodyContent += '<b>Additional Detail : </b>' + '<span style = "font-weight: normal;">' + (agreement.Specific_budget_areas_requiring_review__c != null ? agreement.Specific_budget_areas_requiring_review__c : ('')) +'<br><br>';
                emailOverallBodyContent += '<b>Link to Bid History Record : </b><span style = "font-weight: normal;"><a href = \'' + URL.getOrgDomainUrl().toExternalForm() + '/' + (agreement.id != null ? agreement.id : ('')) + '\'>' + (agreement.Name != null ? agreement.Name : ('')) + '</a></span><br>';
                emailOverallBodyContent += '</div>';
                
                workflowEmailRecordWrapperMessage.whatId = agreement.Id;
                workflowEmailRecordWrapperMessage.toEmails = toEmailList;
                workflowEmailRecordWrapperMessage.ccEmails = toCcEmailList;
                workflowEmailRecordWrapperMessage.emailAction = CON_OWF.Q2_SOLUTIONS_STRATEGIC_PRICING_INVOLVED_EMAIL_ACTION;
                workflowEmailRecordWrapperMessage.subject = subject;
                workflowEmailRecordWrapperMessage.staticContent = emailOverallBodyContent;
                workflowEmailRecordWrapperMessageList.add(workflowEmailRecordWrapperMessage);
                
            }  
        }
        
        return workflowEmailRecordWrapperMessageList;
    }
    
    public static List<UTL_OWF.workflowEmailRecordWrapper> sendEmailForQ2SolutionsBidHistoryTriageNotificationExcludingMerckKGaA(Map<id, Bid_History__c> q2SolutionsBidHistoryTriageNotificationExcludingMerckKGaAMap){
        List<UTL_OWF.workflowEmailRecordWrapper> workflowEmailRecordWrapperMessageList = new List<UTL_OWF.workflowEmailRecordWrapper>();
        List<String> toCcEmailList = new List<String>();
        
        OWF_Generic_Setting__c additionalEmail = OWF_Generic_Setting__c.getValues(CON_OWF.BHR_OWF_07_Q2PROPOSALREQUEST);
        OWF_Generic_Setting__c additionalEmail2 = OWF_Generic_Setting__c.getValues(CON_OWF.BHR_OWF_07_Q2STRATEGIC_PROPOSAL_WRITER_TEXT);
        OWF_Generic_Setting__c additionalEmail3 = OWF_Generic_Setting__c.getValues(CON_OWF.BHR_OWF_07_Q2_BUDGET_TOOL);
        if(additionalEmail != null && additionalEmail.Value__c != null){
            toCcEmailList = (additionalEmail.Value__c).split(',');
        }
        if(toCcEmailList.size()>0){
            List<String> toEmailList = new List<String>();
            String subject = '';
            String emailOverallBodyContent = '';
            UTL_OWF.workflowEmailRecordWrapper workflowEmailRecordWrapperMessage = new UTL_OWF.workflowEmailRecordWrapper();
            for(Bid_History__c agreement : q2SolutionsBidHistoryTriageNotificationExcludingMerckKGaAMap.values()){
                toEmailList = new List<String>();
                subject = '';
                emailOverallBodyContent = '';
                if(agreement.Bid_History_Related_Opportunity__r.Owner_Email__c != null){
                    toEmailList.add(agreement.Bid_History_Related_Opportunity__r.Owner_Email__c);
                }
                if(agreement.Q2_Budget_Tools__c == CON_OWF.Q2_BUDGET_TOOLS_RNPS_NURSE){
                    toCcEmailList = (additionalEmail3.Value__c).split(',');
                }
                if(agreement.Proposal_Deliverable__c==CON_OWF.STRATEGIC_PROPOSAL_WRITER_TEXT){
                   toCcEmailList.addAll((additionalEmail2.Value__c).split(','));
                }
                workflowEmailRecordWrapperMessage = new UTL_OWF.workflowEmailRecordWrapper();
                subject = 'NEW ASSIGNMENT for '+ (agreement.Opportunity_Account__c != null ? agreement.Opportunity_Account__c : ('')) + '-' + (agreement.Protocol_Number__c != null ? agreement.Protocol_Number__c : ('')) + '-' + (agreement.Legacy_Quintiles_Opportunity_Number__c  != null ? agreement.Legacy_Quintiles_Opportunity_Number__c  : ('')) + '-' + (String.valueOf(agreement.Science_Due_Date__c) != null ? String.valueOf(agreement.Science_Due_Date__c) : (''));
                emailOverallBodyContent = '<div><b>Bid History Link : </b><span style = "font-weight: normal;"><a href = \'' + URL.getOrgDomainUrl().toExternalForm() + '/' + (agreement.id != null ? agreement.id : ('')) + '\'>' + (agreement.Name != null ? agreement.Name : ('')) + '</a></span><br>';
                emailOverallBodyContent += '<b>Protocol Number : </b>' + '<span style = "font-weight: normal;">' + (agreement.Protocol_Number__c != null ? agreement.Protocol_Number__c : ('')) + '</span>' +'<br>';
                emailOverallBodyContent += '<b>Sales Lead : </b>' + '<span style = "font-weight: normal;">' + (agreement.Bid_History_Related_Opportunity__r.Owner.Name != null ? agreement.Bid_History_Related_Opportunity__r.Owner.Name : ('')) + '</span>' +'<br>';
                emailOverallBodyContent += '<b>Bid Number : </b>' + '<span style = "font-weight: normal;">' + (String.valueOf(agreement.Bid_Number__c) != null ? String.valueOf(agreement.Bid_Number__c) : ('')) + '</span>' +'<br>';
                emailOverallBodyContent += '<b>Scientific Review Required : </b>' + '<span style = "font-weight: normal;">' + (agreement.Scientific_Review__c != null ? agreement.Scientific_Review__c : ('')) + '</span>' +'<br>';
                emailOverallBodyContent += '<b>Assigned Proposal Ranking : </b>' + '<span style = "font-weight: normal;">' + (agreement.Assign_Proposal_Ranking__c != null ? agreement.Assign_Proposal_Ranking__c : ('')) + '</span>' +'<br>';
                emailOverallBodyContent += '<b>Strategy Call Required : </b>' + '<span style = "font-weight: normal;">' + (agreement.Is_a_Strategy_Call_Required__c != null ? agreement.Is_a_Strategy_Call_Required__c : ('')) + '</span>' +'<br>';
                emailOverallBodyContent += '<b>Bioanalytical (Advion) Required : </b>' + '<span style = "font-weight: normal;">' + (agreement.Q2_BioSciences_Quote_Requested__c != null ? agreement.Q2_BioSciences_Quote_Requested__c : ('')) + '</span>' +'<br>';
                emailOverallBodyContent += '<b>Q² CTMS : </b>' + '<span style = "font-weight: normal;">' + (agreement.Bid_History_Related_Opportunity__r.Q2_CTMS_Picklist__c != null ? agreement.Bid_History_Related_Opportunity__r.Q2_CTMS_Picklist__c : ('')) + '</span>' +'<br>';
                emailOverallBodyContent += '</div>';
                
                workflowEmailRecordWrapperMessage.whatId = agreement.Id;
                workflowEmailRecordWrapperMessage.toEmails = toEmailList;
                workflowEmailRecordWrapperMessage.ccEmails = toCcEmailList;
                workflowEmailRecordWrapperMessage.emailAction = CON_OWF.Q2_SOLUTIONS_BIDHISTORY_TRIAGE_NOTIFICATION_EXCLUDING_MERCK_KGAA_EMAIL_ACTION;
                workflowEmailRecordWrapperMessage.subject = subject;
                workflowEmailRecordWrapperMessage.staticContent = emailOverallBodyContent;
                workflowEmailRecordWrapperMessageList.add(workflowEmailRecordWrapperMessage);
                
            }  
        }
        
        return workflowEmailRecordWrapperMessageList;
    }
    
    public static List<UTL_OWF.workflowEmailRecordWrapper> sendEmailForQ2SolutionsLevel1RankingAlert(Map<Id, Bid_History__c> q2SolutionsLevel1RankingAlertMap){
        List<UTL_OWF.workflowEmailRecordWrapper> workflowEmailRecordWrapperMessageList = new List<UTL_OWF.workflowEmailRecordWrapper>();
																				  
            List<String> toEmailList = new List<String>();
            String subject = '';
            String emailOverallBodyContent = '';
            UTL_OWF.workflowEmailRecordWrapper workflowEmailRecordWrapperMessage = new UTL_OWF.workflowEmailRecordWrapper();
        for(Bid_History__c agreement : q2SolutionsLevel1RankingAlertMap.values()){
                toEmailList = new List<String>();
                subject = '';
                emailOverallBodyContent = '';
            if(agreement.Bid_History_Related_Opportunity__r.Owner_Email__c != null){
                toEmailList.add(agreement.Bid_History_Related_Opportunity__r.Owner_Email__c);
            }
            if(agreement.Supporting_Bid_Owner__r.Email != null){
                toEmailList.add(agreement.Supporting_Bid_Owner__r.Email);
            }
            /*if(agreement.Owner.Email != null){
                toEmailList.add(agreement.Owner.Email);
            }*/
            
            workflowEmailRecordWrapperMessage = new UTL_OWF.workflowEmailRecordWrapper();
            subject = 'NEW ASSIGNMENT '+(agreement.Assign_Proposal_Ranking__c != null ? agreement.Assign_Proposal_Ranking__c : ('')) + ' Opportunity For ' + (agreement.Opportunity_Account__c != null ? agreement.Opportunity_Account__c : ('')) +'-'+(agreement.Protocol_Number__c != null ? agreement.Protocol_Number__c : ('')) + '-'+(agreement.Legacy_Quintiles_Opportunity_Number__c  != null ? agreement.Legacy_Quintiles_Opportunity_Number__c  : ('')) ;
            emailOverallBodyContent = '<div>A New '+ '<span style = "font-weight: normal;">' + (agreement.Assign_Proposal_Ranking__c != null ? agreement.Assign_Proposal_Ranking__c : ('')) + '</span>';
            emailOverallBodyContent += ' opportunity has been received from '+ '<span style = "font-weight: normal;">' + (agreement.Opportunity_Owner__c != null ? agreement.Opportunity_Owner__c : ('')) + '</span>';
            emailOverallBodyContent += ' ,for '+ '<span style = "font-weight: normal;">' + (agreement.Opportunity_Account__c != null ? agreement.Opportunity_Account__c : ('')) + '</span>'+'.<br>';
            emailOverallBodyContent += '<span style = "font-weight: normal;">' + (agreement.Owner.Name != null ? agreement.Owner.Name : ('')) + '</span>' +' has been assigned to work on this opportunity.<br><br>';
            emailOverallBodyContent += '<b>Bid History Link : </b><span style = "font-weight: normal;"><a href = \'' + URL.getOrgDomainUrl().toExternalForm() + '/' + (agreement.id != null ? agreement.id : ('')) + '\'>' + (agreement.Name != null ? agreement.Name : ('')) + '</a></span><br><br>';
            emailOverallBodyContent += '<b>Key Study Information </b><br>';
            emailOverallBodyContent += '<b>Opportunity Number : </b>' + '<span style = "font-weight: normal;">' + (agreement.Legacy_Quintiles_Opportunity_Number__c  != null ? agreement.Legacy_Quintiles_Opportunity_Number__c  : ('')) + '</span>' +'<br>';
            emailOverallBodyContent += '<b>Sponsor : </b> '+ '<span style = "font-weight: normal;">' + (agreement.Opportunity_Account__c != null ? agreement.Opportunity_Account__c : ('')) + '</span>'+'<br>';
            emailOverallBodyContent += '<b>Protocol Number : </b>' + '<span style = "font-weight: normal;">' + (agreement.Protocol_Number__c != null ? agreement.Protocol_Number__c : ('')) + '</span>' +'<br>';
            emailOverallBodyContent += '<b>Bid Due Date : </b>' + '<span style = "font-weight: normal;">' + (String.valueOf(agreement.Bid_Due_Date__c) != null ? String.valueOf(agreement.Bid_Due_Date__c) : ('')) + '</span>' +'<br>';
            emailOverallBodyContent += '<b>Requested Service : </b>' + '<span style = "font-weight: normal;">' + (agreement.Requested_Services__c != null ? agreement.Requested_Services__c : ('')) + '</span>' +'<br><br>';
            emailOverallBodyContent += '<b>Ranking : </b>' + '<span style = "font-weight: normal;">' + (agreement.Assign_Proposal_Ranking__c != null ? agreement.Assign_Proposal_Ranking__c : ('')) + '</span>' +'<br><br>';
            emailOverallBodyContent += '<b>Strategy Call Required : </b>' + '<span style = "font-weight: normal;">' + (agreement.Is_a_Strategy_Call_Required__c != null ? agreement.Is_a_Strategy_Call_Required__c : ('')) + '</span>' +'<br><br>';
            emailOverallBodyContent += '<b>Scientific Review Required : </b>' + '<span style = "font-weight: normal;">' + (agreement.Scientific_Review__c != null ? agreement.Scientific_Review__c : ('')) + '</span>' +'<br><br>';
            emailOverallBodyContent += '<b>Bid Number : </b>' + '<span style = "font-weight: normal;">' + (String.valueOf(agreement.Bid_Number__c) != null ? String.valueOf(agreement.Bid_Number__c) : ('')) + '</span>' +'<br>';
            emailOverallBodyContent += '<b>Lab Region : </b>' + '<span style = "font-weight: normal;">' + (agreement.OWF_Potential_Regions__c != null ? agreement.OWF_Potential_Regions__c : ('')) + '</span>' +'<br><br>';
            emailOverallBodyContent += '<b>Supporting Bid Owner : </b>' + '<span style = "font-weight: normal;">' + (String.valueOf(agreement.Supporting_Bid_Owner__r.Name) != null ? String.valueOf(agreement.Supporting_Bid_Owner__r.Name) : ('')) + '</span>' +'<br>';
            emailOverallBodyContent += '<b>Supporting Bid Owner Deliverable : </b>' + '<span style = "font-weight: normal;">' + (agreement.Supporting_Bid_Owner_Deliverable__c != null ? agreement.Supporting_Bid_Owner_Deliverable__c : ('')) + '</span>' +'<br><br>';
            emailOverallBodyContent += '</div>';
            
            workflowEmailRecordWrapperMessage.whatId = agreement.Id;
            workflowEmailRecordWrapperMessage.ownerId = agreement.OwnerId;
            workflowEmailRecordWrapperMessage.toEmails = toEmailList;
            workflowEmailRecordWrapperMessage.emailAction = CON_OWF.Q2_SOLUTIONS_LEVEL_1_RANKING_ALERT_EMAIL_ACTION;
            workflowEmailRecordWrapperMessage.subject = subject;
            workflowEmailRecordWrapperMessage.staticContent = emailOverallBodyContent;
            workflowEmailRecordWrapperMessageList.add(workflowEmailRecordWrapperMessage);
            
        }  
        return workflowEmailRecordWrapperMessageList;
    }
    
    public static List<UTL_OWF.workflowEmailRecordWrapper> sendEmailForQ2SolutionsLevel2RankingAlert(Map<Id, Bid_History__c> q2SolutionsLevel2RankingAlertMap){
        List<UTL_OWF.workflowEmailRecordWrapper> workflowEmailRecordWrapperMessageList = new List<UTL_OWF.workflowEmailRecordWrapper>();
																				  
            List<String> toEmailList = new List<String>();
            String subject = '';
            String emailOverallBodyContent = '';
            UTL_OWF.workflowEmailRecordWrapper workflowEmailRecordWrapperMessage = new UTL_OWF.workflowEmailRecordWrapper();
        for(Bid_History__c agreement : q2SolutionsLevel2RankingAlertMap.values()){
                toEmailList = new List<String>();
                subject = '';
                emailOverallBodyContent = '';
            if(agreement.Bid_History_Related_Opportunity__r.Owner_Email__c != null){
                toEmailList.add(agreement.Bid_History_Related_Opportunity__r.Owner_Email__c);
            }
            if(agreement.Supporting_Bid_Owner__r.Email != null){
                toEmailList.add(agreement.Supporting_Bid_Owner__r.Email);
            }
            /*if(agreement.Owner.Email != null){
                toEmailList.add(agreement.Owner.Email);
            }*/
            workflowEmailRecordWrapperMessage = new UTL_OWF.workflowEmailRecordWrapper();
            subject ='NEW ASSIGNMENT '+(agreement.Assign_Proposal_Ranking__c != null ? agreement.Assign_Proposal_Ranking__c : ('')) + ' Opportunity For ' + (agreement.Opportunity_Account__c != null ? agreement.Opportunity_Account__c : ('')) +'-'+(agreement.Protocol_Number__c != null ? agreement.Protocol_Number__c : ('')) + '-'+(agreement.Legacy_Quintiles_Opportunity_Number__c  != null ? agreement.Legacy_Quintiles_Opportunity_Number__c  : ('')) ;
            emailOverallBodyContent = '<div>A New '+ '<span style = "font-weight: normal;">' + (agreement.Assign_Proposal_Ranking__c != null ? agreement.Assign_Proposal_Ranking__c : ('')) + '</span>';
            emailOverallBodyContent += ' opportunity has been received from '+ '<span style = "font-weight: normal;">' + (agreement.Opportunity_Owner__c != null ? agreement.Opportunity_Owner__c : ('')) + '</span>';
            emailOverallBodyContent += ' ,for '+ '<span style = "font-weight: normal;">' + (agreement.Opportunity_Account__c != null ? agreement.Opportunity_Account__c : ('')) + '</span>'+'.<br><br>';
            emailOverallBodyContent += '<span style = "font-weight: normal;">' + (agreement.Owner.Name != null ? agreement.Owner.Name : ('')) + '</span>' +' has been assigned to work on this opportunity.<br><br>';
            emailOverallBodyContent += '<b>Bid History Link : </b><span style = "font-weight: normal;"><a href = \'' + URL.getOrgDomainUrl().toExternalForm() + '/' + (agreement.id != null ? agreement.id : ('')) + '\'>' + (agreement.Name != null ? agreement.Name : ('')) + '</a></span><br><br>';
            emailOverallBodyContent += '<b>Key Study Information </b><br>';
            emailOverallBodyContent += '<b>Opportunity Number : </b>' + '<span style = "font-weight: normal;">' + (agreement.Legacy_Quintiles_Opportunity_Number__c  != null ? agreement.Legacy_Quintiles_Opportunity_Number__c  : ('')) + '</span>' +'<br><br>';
            emailOverallBodyContent += '<b>Sponsor : </b> '+ '<span style = "font-weight: normal;">' + (agreement.Opportunity_Account__c != null ? agreement.Opportunity_Account__c : ('')) + '</span>'+'<br>';
            emailOverallBodyContent += '<b>Protocol Number : </b>' + '<span style = "font-weight: normal;">' + (agreement.Protocol_Number__c != null ? agreement.Protocol_Number__c : ('')) + '</span>' +'<br>';
            emailOverallBodyContent += '<b>Bid Due Date : </b>' + '<span style = "font-weight: normal;">' + (String.valueOf(agreement.Bid_Due_Date__c) != null ? String.valueOf(agreement.Bid_Due_Date__c) : ('')) + '</span>' +'<br>';
            emailOverallBodyContent += '<b>Requested Service : </b>' + '<span style = "font-weight: normal;">' + (agreement.Requested_Services__c != null ? agreement.Requested_Services__c : ('')) + '</span>' +'<br>';
            emailOverallBodyContent += '<b>Ranking : </b>' + '<span style = "font-weight: normal;">' + (agreement.Assign_Proposal_Ranking__c != null ? agreement.Assign_Proposal_Ranking__c : ('')) + '</span>' +'<br>';
            emailOverallBodyContent += '<b>Strategy Call Required : </b>' + '<span style = "font-weight: normal;">' + (agreement.Is_a_Strategy_Call_Required__c != null ? agreement.Is_a_Strategy_Call_Required__c : ('')) + '</span>' +'<br>';
            emailOverallBodyContent += '<b>Scientific Review Required : </b>' + '<span style = "font-weight: normal;">' + (agreement.Scientific_Review__c != null ? agreement.Scientific_Review__c : ('')) + '</span>' +'<br>';
            emailOverallBodyContent += '<b>Bid Number : </b>' + '<span style = "font-weight: normal;">' + (String.valueOf(agreement.Bid_Number__c) != null ? String.valueOf(agreement.Bid_Number__c) : ('')) + '</span>' +'<br>';
            emailOverallBodyContent += '<b>Lab Region : </b>' + '<span style = "font-weight: normal;">' + (agreement.OWF_Potential_Regions__c != null ? agreement.OWF_Potential_Regions__c : ('')) + '</span>' +'<br>';
            emailOverallBodyContent += '<b>Budget Deliverable : </b>' + '<span style = "font-weight: normal;">' + (agreement.Budget_Deliverable__c != null ? agreement.Budget_Deliverable__c : ('')) + '</span>' +'<br>';
            emailOverallBodyContent += '<b>Text Deliverable : </b>' + '<span style = "font-weight: normal;">' + (agreement.Proposal_Deliverable__c != null ? agreement.Proposal_Deliverable__c : ('')) + '</span>' +'<br><br>';
            emailOverallBodyContent += '<b>Supporting Bid Owner : </b>' + '<span style = "font-weight: normal;">' + (String.valueOf(agreement.Supporting_Bid_Owner__r.Name) != null ? String.valueOf(agreement.Supporting_Bid_Owner__r.Name) : ('')) + '</span>' +'<br>';
            emailOverallBodyContent += '<b>Supporting Bid Owner Deliverable : </b>' + '<span style = "font-weight: normal;">' + (agreement.Supporting_Bid_Owner_Deliverable__c != null ? agreement.Supporting_Bid_Owner_Deliverable__c : ('')) + '</span>' +'<br><br>';
            emailOverallBodyContent += '</div>';
            
            workflowEmailRecordWrapperMessage.whatId = agreement.Id;
            workflowEmailRecordWrapperMessage.toEmails = toEmailList;
            workflowEmailRecordWrapperMessage.ownerId = agreement.OwnerId;
            workflowEmailRecordWrapperMessage.emailAction = CON_OWF.Q2_SOLUTIONS_LEVEL_2_RANKING_ALERT_EMAIL_ACTION;
            workflowEmailRecordWrapperMessage.subject = subject;
            workflowEmailRecordWrapperMessage.staticContent = emailOverallBodyContent;
            workflowEmailRecordWrapperMessageList.add(workflowEmailRecordWrapperMessage);
            
        }  
        return workflowEmailRecordWrapperMessageList;
    }
    
    public static List<UTL_OWF.workflowEmailRecordWrapper> sendEmailForQ2SolutionsLevel3RankingAlert(Map<Id, Bid_History__c> q2SolutionsLevel3RankingAlertMap){
        List<UTL_OWF.workflowEmailRecordWrapper> workflowEmailRecordWrapperMessageList = new List<UTL_OWF.workflowEmailRecordWrapper>();
																				  
            List<String> toEmailList = new List<String>();
            String subject = '';
            String emailOverallBodyContent = '';
            UTL_OWF.workflowEmailRecordWrapper workflowEmailRecordWrapperMessage = new UTL_OWF.workflowEmailRecordWrapper();
        for(Bid_History__c agreement : q2SolutionsLevel3RankingAlertMap.values()){
                toEmailList = new List<String>();
                subject = '';
                emailOverallBodyContent = '';
            if(agreement.Bid_History_Related_Opportunity__r.Owner_Email__c != null){
                toEmailList.add(agreement.Bid_History_Related_Opportunity__r.Owner_Email__c);
            }
            if(agreement.Supporting_Bid_Owner__r.Email != null){
                toEmailList.add(agreement.Supporting_Bid_Owner__r.Email);
            }
            /*if(agreement.Owner.Email != null){
                toEmailList.add(agreement.Owner.Email);
            }*/
            workflowEmailRecordWrapperMessage = new UTL_OWF.workflowEmailRecordWrapper();
            subject = 'NEW ASSIGNMENT '+(agreement.Assign_Proposal_Ranking__c != null ? agreement.Assign_Proposal_Ranking__c : ('')) + ' Opportunity For ' + (agreement.Opportunity_Account__c != null ? agreement.Opportunity_Account__c : ('')) +'-'+(agreement.Protocol_Number__c != null ? agreement.Protocol_Number__c : ('')) + '-'+(agreement.Legacy_Quintiles_Opportunity_Number__c  != null ? agreement.Legacy_Quintiles_Opportunity_Number__c  : ('')) ;
            emailOverallBodyContent = '<div>A New '+ '<span style = "font-weight: normal;">' + (agreement.Assign_Proposal_Ranking__c != null ? agreement.Assign_Proposal_Ranking__c : ('')) + '</span>';
            emailOverallBodyContent += ' opportunity has been received from '+ '<span style = "font-weight: normal;">' + (agreement.Opportunity_Owner__c != null ? agreement.Opportunity_Owner__c : ('')) + '</span>';
            emailOverallBodyContent += ' , for '+ '<span style = "font-weight: normal;">' + (agreement.Opportunity_Account__c != null ? agreement.Opportunity_Account__c : ('')) + '</span>'+'.<br><br>';
            emailOverallBodyContent += '<span style = "font-weight: normal;">' + (agreement.Owner.Name != null ? agreement.Owner.Name : ('')) + '</span>' +' has been assigned to work on this opportunity.<br><br>';
            emailOverallBodyContent += 'Please use the link below to review the documents and information currently available, prior to the meeting.<br><br>';
            emailOverallBodyContent += '<b>Bid History Link : </b><span style = "font-weight: normal;"><a href = \'' + URL.getOrgDomainUrl().toExternalForm() + '/' + (agreement.id != null ? agreement.id : ('')) + '\'>' + (agreement.Name != null ? agreement.Name : ('')) + '</a></span><br><br>';
            emailOverallBodyContent += '<b>Key Study Information </b><br>';
            emailOverallBodyContent += '<b>Opportunity Number : </b>' + '<span style = "font-weight: normal;">' + (agreement.Legacy_Quintiles_Opportunity_Number__c  != null ? agreement.Legacy_Quintiles_Opportunity_Number__c  : ('')) + '</span>' +'<br>';
            emailOverallBodyContent += '<b>Sponsor : </b> '+ '<span style = "font-weight: normal;">' + (agreement.Opportunity_Account__c != null ? agreement.Opportunity_Account__c : ('')) + '</span>'+'<br>';
            emailOverallBodyContent += '<b>Protocol Number : </b>' + '<span style = "font-weight: normal;">' + (agreement.Protocol_Number__c != null ? agreement.Protocol_Number__c : ('')) + '</span>' +'<br>';
            emailOverallBodyContent += '<b>Bid Due Date : </b>' + '<span style = "font-weight: normal;">' + (String.valueOf(agreement.Bid_Due_Date__c) != null ? String.valueOf(agreement.Bid_Due_Date__c) : ('')) + '</span>' +'<br>';
            emailOverallBodyContent += '<b>Requested Service : </b>' + '<span style = "font-weight: normal;">' + (agreement.Requested_Services__c != null ? agreement.Requested_Services__c : ('')) + '</span>' +'<br>';
            emailOverallBodyContent += '<b>Ranking : </b>' + '<span style = "font-weight: normal;">' + (agreement.Assign_Proposal_Ranking__c != null ? agreement.Assign_Proposal_Ranking__c : ('')) + '</span>' +'<br>';
            emailOverallBodyContent += '<b>Strategy Call Required : </b>' + '<span style = "font-weight: normal;">' + (agreement.Is_a_Strategy_Call_Required__c != null ? agreement.Is_a_Strategy_Call_Required__c : ('')) + '</span>' +'<br>';
            emailOverallBodyContent += '<b>Scientific Review Required : </b>' + '<span style = "font-weight: normal;">' + (agreement.Scientific_Review__c != null ? agreement.Scientific_Review__c : ('')) + '</span>' +'<br>';
            emailOverallBodyContent += '<b>Bid Number : </b>' + '<span style = "font-weight: normal;">' + (String.valueOf(agreement.Bid_Number__c) != null ? String.valueOf(agreement.Bid_Number__c) : ('')) + '</span>' +'<br>';
            emailOverallBodyContent += '<b>Lab Region : </b>' + '<span style = "font-weight: normal;">' + (agreement.OWF_Potential_Regions__c != null ? agreement.OWF_Potential_Regions__c : ('')) + '</span>' +'<br>';
            emailOverallBodyContent += '<b>Budget Deliverable : </b>' + '<span style = "font-weight: normal;">' + (agreement.Budget_Deliverable__c != null ? agreement.Budget_Deliverable__c : ('')) + '</span>' +'<br>';
            emailOverallBodyContent += '<b>Text Deliverable : </b>' + '<span style = "font-weight: normal;">' + (agreement.Proposal_Deliverable__c != null ? agreement.Proposal_Deliverable__c : ('')) + '</span>' +'<br><br>';
            emailOverallBodyContent += '<b>Supporting Bid Owner : </b>' + '<span style = "font-weight: normal;">' + (String.valueOf(agreement.Supporting_Bid_Owner__r.Name) != null ? String.valueOf(agreement.Supporting_Bid_Owner__r.Name) : ('')) + '</span>' +'<br>';
            emailOverallBodyContent += '<b>Supporting Bid Owner Deliverable : </b>' + '<span style = "font-weight: normal;">' + (agreement.Supporting_Bid_Owner_Deliverable__c != null ? agreement.Supporting_Bid_Owner_Deliverable__c : ('')) + '</span>' +'<br><br>';
            emailOverallBodyContent += '</div>';
            
            workflowEmailRecordWrapperMessage.whatId = agreement.Id;
            workflowEmailRecordWrapperMessage.toEmails = toEmailList;
            workflowEmailRecordWrapperMessage.ownerId = agreement.OwnerId;
            workflowEmailRecordWrapperMessage.emailAction = CON_OWF.Q2_SOLUTIONS_LEVEL_3_RANKING_ALERT_EMAIL_ACTION;
            workflowEmailRecordWrapperMessage.subject = subject;
            workflowEmailRecordWrapperMessage.staticContent = emailOverallBodyContent;
            workflowEmailRecordWrapperMessageList.add(workflowEmailRecordWrapperMessage);
            
        }  
        return workflowEmailRecordWrapperMessageList;
    }
    
    public static List<UTL_OWF.workflowEmailRecordWrapper> sendEmailForQ2SolutionsLevel4RankingAlert(Map<Id, Bid_History__c> q2SolutionsLevel4RankingAlertMap){
        List<UTL_OWF.workflowEmailRecordWrapper> workflowEmailRecordWrapperMessageList = new List<UTL_OWF.workflowEmailRecordWrapper>();
        List<String> toCcEmailList = new List<String>();
        
        Map<String,OWF_Generic_Setting__c> additionalEmail = OWF_Generic_Setting__c.getAll();
        if(additionalEmail != null && additionalEmail.get(CON_OWF.BHR_OWF_Q2SOLUTIONSLEVEL4RANKINGEMAIL1).Value__c != null){
            toCcEmailList.addAll((additionalEmail.get(CON_OWF.BHR_OWF_Q2SOLUTIONSLEVEL4RANKINGEMAIL1).Value__c).split(','));
        }
        if(additionalEmail != null && additionalEmail.get(CON_OWF.BHR_OWF_Q2SOLUTIONSLEVEL4RANKINGEMAIL2).Value__c != null){
            toCcEmailList.addAll((additionalEmail.get(CON_OWF.BHR_OWF_Q2SOLUTIONSLEVEL4RANKINGEMAIL2).Value__c).split(','));
        }
        
        if(toCcEmailList.size()>0){
            List<String> toEmailList = new List<String>();
            String subject = '';
            String emailOverallBodyContent = '';
            UTL_OWF.workflowEmailRecordWrapper workflowEmailRecordWrapperMessage = new UTL_OWF.workflowEmailRecordWrapper();
            for(Bid_History__c agreement : q2SolutionsLevel4RankingAlertMap.values()){
                toEmailList = new List<String>();
                subject = '';
                emailOverallBodyContent = '';
                if(agreement.Bid_History_Related_Opportunity__r.Owner_Email__c != null){
                    toEmailList.add(agreement.Bid_History_Related_Opportunity__r.Owner_Email__c);
                }
                if(agreement.Supporting_Bid_Owner__r.Email != null){
                    toEmailList.add(agreement.Supporting_Bid_Owner__r.Email);
                }
                /*if(agreement.Owner.Email != null){
                    toEmailList.add(agreement.Owner.Email);
                }*/
                workflowEmailRecordWrapperMessage = new UTL_OWF.workflowEmailRecordWrapper();
                subject = 'NEW ASSIGNMENT '+(agreement.Assign_Proposal_Ranking__c != null ? agreement.Assign_Proposal_Ranking__c : ('')) + ' $5M+ Opportunity For ' + (agreement.Opportunity_Account__c != null ? agreement.Opportunity_Account__c : ('')) +'-'+(agreement.Protocol_Number__c != null ? agreement.Protocol_Number__c : ('')) + '-'+(agreement.Legacy_Quintiles_Opportunity_Number__c  != null ? agreement.Legacy_Quintiles_Opportunity_Number__c  : (''));
                emailOverallBodyContent = '<div>A New '+ '<span style = "font-weight: normal;">' + (agreement.Assign_Proposal_Ranking__c != null ? agreement.Assign_Proposal_Ranking__c : ('')) + '</span>';
                emailOverallBodyContent += ' opportunity has been received from '+ '<span style = "font-weight: normal;">' + (agreement.Opportunity_Owner__c != null ? agreement.Opportunity_Owner__c : ('')) + '</span>';
                emailOverallBodyContent += ' , for '+ '<span style = "font-weight: normal;">' + (agreement.Opportunity_Account__c != null ? agreement.Opportunity_Account__c : ('')) + '</span>'+'.<br><br>';
                emailOverallBodyContent += '<span style = "font-weight: normal;">' + (agreement.Owner.Name != null ? agreement.Owner.Name : ('')) + '</span>' +' has been assigned to work on this opportunity.<br><br>';
                emailOverallBodyContent += 'Please use the link below to review the documents and information currently available, prior to the meeting.<br><br>';
                emailOverallBodyContent += '<b>Bid History Link : </b><span style = "font-weight: normal;"><a href = \'' + URL.getOrgDomainUrl().toExternalForm() + '/' + (agreement.id != null ? agreement.id : ('')) + '\'>' + (agreement.Name != null ? agreement.Name : ('')) + '</a></span><br>';
                emailOverallBodyContent += '<b>Key Study Information </b><br>';
                emailOverallBodyContent += '<b>Opportunity Number : </b>' + '<span style = "font-weight: normal;">' + (agreement.Legacy_Quintiles_Opportunity_Number__c  != null ? agreement.Legacy_Quintiles_Opportunity_Number__c  : ('')) + '</span>' +'<br>';
                emailOverallBodyContent += '<b>Sponsor : </b> '+ '<span style = "font-weight: normal;">' + (agreement.Opportunity_Account__c != null ? agreement.Opportunity_Account__c : ('')) + '</span>'+'<br>';
                emailOverallBodyContent += '<b>Protocol Number : </b>' + '<span style = "font-weight: normal;">' + (agreement.Protocol_Number__c != null ? agreement.Protocol_Number__c : ('')) + '</span>' +'<br>';
                emailOverallBodyContent += '<b>Bid Due Date : </b>' + '<span style = "font-weight: normal;">' + (String.valueOf(agreement.Bid_Due_Date__c) != null ? String.valueOf(agreement.Bid_Due_Date__c) : ('')) + '</span>' +'<br>';
                emailOverallBodyContent += '<b>Requested Service : </b>' + '<span style = "font-weight: normal;">' + (agreement.Requested_Services__c != null ? agreement.Requested_Services__c : ('')) + '</span>' +'<br>';
                emailOverallBodyContent += '<b>Ranking : </b>' + '<span style = "font-weight: normal;">' + (agreement.Assign_Proposal_Ranking__c != null ? agreement.Assign_Proposal_Ranking__c : ('')) + '</span>' +'<br>';
                emailOverallBodyContent += '<b>Strategy Call Required : </b>' + '<span style = "font-weight: normal;">' + (agreement.Is_a_Strategy_Call_Required__c != null ? agreement.Is_a_Strategy_Call_Required__c : ('')) + '</span>' +'<br>';
                emailOverallBodyContent += '<b>Scientific Review Required : </b>' + '<span style = "font-weight: normal;">' + (agreement.Scientific_Review__c != null ? agreement.Scientific_Review__c : ('')) + '</span>' +'<br>';
                emailOverallBodyContent += '<b>Bid Number : </b>' + '<span style = "font-weight: normal;">' + (String.valueOf(agreement.Bid_Number__c) != null ? String.valueOf(agreement.Bid_Number__c) : ('')) + '</span>' +'<br>';
                emailOverallBodyContent += '<b>Lab Region : </b>' + '<span style = "font-weight: normal;">' + (agreement.OWF_Potential_Regions__c != null ? agreement.OWF_Potential_Regions__c : ('')) + '</span>' +'<br>';
                emailOverallBodyContent += '<b>Budget Deliverable : </b>' + '<span style = "font-weight: normal;">' + (agreement.Budget_Deliverable__c != null ? agreement.Budget_Deliverable__c : ('')) + '</span>' +'<br>';
                emailOverallBodyContent += '<b>Text Deliverable : </b>' + '<span style = "font-weight: normal;">' + (agreement.Proposal_Deliverable__c != null ? agreement.Proposal_Deliverable__c : ('')) + '</span>' +'<br><br>';
                emailOverallBodyContent += '<b>Supporting Bid Owner : </b>' + '<span style = "font-weight: normal;">' + (String.valueOf(agreement.Supporting_Bid_Owner__r.Name) != null ? String.valueOf(agreement.Supporting_Bid_Owner__r.Name) : ('')) + '</span>' +'<br>';
                emailOverallBodyContent += '<b>Supporting Bid Owner Deliverable : </b>' + '<span style = "font-weight: normal;">' + (agreement.Supporting_Bid_Owner_Deliverable__c != null ? agreement.Supporting_Bid_Owner_Deliverable__c : ('')) + '</span>' +'<br><br>';
                emailOverallBodyContent += '</div>';
                
                workflowEmailRecordWrapperMessage.whatId = agreement.Id;
                workflowEmailRecordWrapperMessage.toEmails = toEmailList;
                workflowEmailRecordWrapperMessage.ccEmails = toCcEmailList;
                workflowEmailRecordWrapperMessage.ownerId = agreement.OwnerId;
                workflowEmailRecordWrapperMessage.emailAction = CON_OWF.Q2_SOLUTIONS_LEVEL_4_RANKING_ALERT_EMAIL_ACTION;
                workflowEmailRecordWrapperMessage.subject = subject;
                workflowEmailRecordWrapperMessage.staticContent = emailOverallBodyContent;
                workflowEmailRecordWrapperMessageList.add(workflowEmailRecordWrapperMessage);
                
            }  
        }
        return workflowEmailRecordWrapperMessageList;
    }
    
    public static void q2LabBidHistoryAssignProposalRankingFieldUpdate(List<Bid_History__c> newList){
        for(Bid_History__c bidHistory : newList){
            if(bidHistory.RecordTypeId == CON_OWF.OWF_Q2_Solutions_BID_HISTORY_RECORD_TYPE_ID &&
               bidHistory.Q2_Business_Area__c == CON_OWF.Q2_BUSINESS_AREA){
                   if(bidHistory.Budget_Deliverable__c == CON_OWF.BUDGET_DELIVERABLE_BALLPARK && bidHistory.Requested_Services__c != null){
                       bidHistory.Assign_Proposal_Ranking__c = CON_OWF.ASSIGN_PROPOSAL_RANKING_LEVEL_1;
                   }
                   if(bidHistory.Budget_Deliverable__c != CON_OWF.BUDGET_DELIVERABLE_BALLPARK && bidHistory.Estimated_Fees__c == CON_OWF.ESTIMATED_FEE_LESS_THAN_5M 
                      && (bidHistory.Requested_Services__c.contains(CON_OWF.REQUESTED_INTERNAL_SERVICES_KIT_SUPPLY_ONLY) || bidHistory.Requested_Services__c.contains(CON_OWF.REQUESTED_INTERNAL_SERVICES_SPEC_MANAGEMENT_BASIC) 
                          || bidHistory.Requested_Services__c.contains(CON_OWF.REQUESTED_INTERNAL_SERVICES_STANDARD_SAFETY_TESTING))){
                              bidHistory.Assign_Proposal_Ranking__c = CON_OWF.ASSIGN_PROPOSAL_RANKING_LEVEL_2;
                          }
                   if((bidHistory.Budget_Deliverable__c == CON_OWF.BUDGET_DELIVERABLE_BUDGET || bidHistory.Budget_Deliverable__c == CON_OWF.BUDGET_DELIVERABLE_BUDGET_BID_GRID) 
                      && bidHistory.Estimated_Fees__c == CON_OWF.ESTIMATED_FEE_LESS_THAN_5M 
                      && (bidHistory.Requested_Services__c.contains(CON_OWF.REQUESTED_INTERNAL_SERVICES_ANATOMIC_PATHOLOGY_ANALYTICAL) 
                          || bidHistory.Requested_Services__c.contains(CON_OWF.REQUESTED_INTERNAL_SERVICES_ANATOMIC_PATHOLOGY_PROCESSING) 
                          || bidHistory.Requested_Services__c.contains(CON_OWF.REQUESTED_INTERNAL_SERVICES_COMPANION_DIAGNOSTICS) 
                          || bidHistory.Requested_Services__c.contains(CON_OWF.REQUESTED_INTERNAL_SERVICES_COMPLEX_3RD_PARTY_LOGISTICS)
                          || bidHistory.Requested_Services__c.contains(CON_OWF.REQUESTED_INTERNAL_SERVICES_COMPLEX_SAMPLE_STORAGE)
                          || bidHistory.Requested_Services__c.contains(CON_OWF.REQUESTED_INTERNAL_SERVICES_GENOMICS_EA)
                          || bidHistory.Requested_Services__c.contains(CON_OWF.REQUESTED_INTERNAL_SERVICES_LOCAL_LAB_DATA_ENTRY)
                          || bidHistory.Requested_Services__c.contains(CON_OWF.REQUESTED_INTERNAL_SERVICES_POTENTIAL_VALIDATION_TRANSLATIONAL)
                          || bidHistory.Requested_Services__c.contains(CON_OWF.REQUESTED_INTERNAL_SERVICES_NON_STANDARD_TESTING))){
                              bidHistory.Assign_Proposal_Ranking__c = CON_OWF.ASSIGN_PROPOSAL_RANKING_LEVEL_3;
                          }
                   if(bidHistory.Budget_Deliverable__c != CON_OWF.BUDGET_DELIVERABLE_BALLPARK && bidHistory.Estimated_Fees__c == CON_OWF.ESTIMATED_FEE_GREATER_THAN_5M){
                       bidHistory.Assign_Proposal_Ranking__c = CON_OWF.ASSIGN_PROPOSAL_RANKING_LEVEL_4;
                   }  
               }
        }   
    }
    
    // IQVIAPSA-6544 
    public static void q2BioFortisQuoteNeededFieldUpdate(List<Bid_History__c> newList,Map<id, Bid_History__c> oldMap){
        for(Bid_History__c bidHistory : newList){
            if(trigger.isInsert || (trigger.isUpdate && bidHistory.Requested_Services__c != oldMap.get(bidHistory.id).Requested_Services__c)){
                if(bidHistory.RecordTypeId == CON_OWF.OWF_Q2_Solutions_BID_HISTORY_RECORD_TYPE_ID && bidHistory.Requested_Services__c != null &&
                   bidHistory.Requested_Services__c.contains(CON_OWF.REQUESTED_INTERNAL_SERVICES_BIOFORTIS)){
                       bidHistory.Q2_BioFortis_Quote_Needed__c = TRUE;
                   }
            } 
        }
    }
    
    //IQVIAPSA-6186 rule no 06 Q2 strategic pricing lead alert
    public static List<UTL_OWF.workflowEmailRecordWrapper> sendEmailForQ2SolutionStrategicPricingAlert(Map<Id, Bid_History__c> q2SolutionStrategicPricingAlertMap){
        List<UTL_OWF.workflowEmailRecordWrapper> workflowEmailRecordWrapperMessageList = new List<UTL_OWF.workflowEmailRecordWrapper>();
            List<String> toEmailList = new List<String>();
            String subject = '';
            String emailOverallBodyContent = '';
            UTL_OWF.workflowEmailRecordWrapper workflowEmailRecordWrapperMessage = new UTL_OWF.workflowEmailRecordWrapper();
        
            for(Bid_History__c bidHistory : q2SolutionStrategicPricingAlertMap.values()){
                toEmailList = new List<String>();
                subject = '';
                emailOverallBodyContent = '';
                if(bidHistory.Bid_History_Related_Opportunity__r.Owner_Email__c != null){
                    toEmailList.add(bidHistory.Bid_History_Related_Opportunity__r.Owner_Email__c);
                }
                if(bidHistory.Strategic_Pricing_Lead__r.Email != null){
                    toEmailList.add(bidHistory.Strategic_Pricing_Lead__r.Email);
                }
                /*if(bidHistory.Bid_Owner_Email__c != null){
                    toEmailList.add(bidHistory.Bid_Owner_Email__c);
                }*/
                workflowEmailRecordWrapperMessage = new UTL_OWF.workflowEmailRecordWrapper();
                subject = 'SP Request ' + (bidHistory.Opportunity_Account__c != null ? bidHistory.Opportunity_Account__c : ('')) + '-' + (bidHistory.Legacy_Quintiles_Opportunity_Number__c  != null ? bidHistory.Legacy_Quintiles_Opportunity_Number__c  : ('')) + '-' + (String.valueOf(bidHistory.Bid_Due_Date__c) != null ? String.valueOf(bidHistory.Bid_Due_Date__c) : (''));
                emailOverallBodyContent = '<div>Hi ' + (bidHistory.Strategic_Pricing_Lead__r.Name != null ? bidHistory.Strategic_Pricing_Lead__r.Name : ('')) + '<br><br>';
                emailOverallBodyContent += 'Please see details below for an opportunity from ' + (bidHistory.Bid_History_Related_Opportunity__r.Owner.Name != null ? bidHistory.Bid_History_Related_Opportunity__r.Owner.Name : ('')) + ' for ' + (bidHistory.Opportunity_Account__c != null ? bidHistory.Opportunity_Account__c : ('')) + ' requiring Strategic Pricing input and review.<br><br>';
                emailOverallBodyContent += 'Opportunity Number: ' + (bidHistory.Legacy_Quintiles_Opportunity_Number__c  != null ? bidHistory.Legacy_Quintiles_Opportunity_Number__c  : ('')) + '<br>';
                emailOverallBodyContent += 'Opportunity Account: ' + (bidHistory.Opportunity_Account__c != null ? bidHistory.Opportunity_Account__c : ('')) + '<br>';
                emailOverallBodyContent += 'Protocol Number: ' + (bidHistory.Protocol_Number__c != null ? bidHistory.Protocol_Number__c : ('')) + '<br>';
                emailOverallBodyContent += 'Bid Due Date: ' + (String.valueOf(bidHistory.Bid_Due_Date__c) != null ? String.valueOf(bidHistory.Bid_Due_Date__c) : ('')) + '<br>';
                emailOverallBodyContent += 'Specific budget areas requiring review: ' + (bidHistory.Specific_budget_areas_requiring_review__c != null ? bidHistory.Specific_budget_areas_requiring_review__c : ('')) + '<br>';
                emailOverallBodyContent += 'Bid Number: ' + (String.valueOf(bidHistory.Bid_Number__c) != null ? String.valueOf(bidHistory.Bid_Number__c) : ('')) + '<br><br>';
                emailOverallBodyContent += 'Bid History Link: <a href = \'' + URL.getOrgDomainUrl().toExternalForm() + '/' + (bidHistory.id != null ? bidHistory.id : ('')) + '\'>' + (bidHistory.Name != null ? bidHistory.Name : ('')) + '</a><br><br>';
                emailOverallBodyContent += 'Submitted by: ' + (bidHistory.CreatedBy.Name != null ? bidHistory.CreatedBy.Name : ('')) + '<br><br>';
                emailOverallBodyContent += '</div>';
                
                workflowEmailRecordWrapperMessage.whatId = bidHistory.Id;
                workflowEmailRecordWrapperMessage.toEmails = toEmailList;
                workflowEmailRecordWrapperMessage.ownerId = bidHistory.OwnerId;
                workflowEmailRecordWrapperMessage.emailAction = CON_OWF.Q2_SOLUTIONS_STRATEGIC_PRICING_LEAD_ALERT_EMAIL_ACTION;
                workflowEmailRecordWrapperMessage.subject = subject;
                workflowEmailRecordWrapperMessage.staticContent = emailOverallBodyContent;
                workflowEmailRecordWrapperMessageList.add(workflowEmailRecordWrapperMessage);
                
            }  
        
        return workflowEmailRecordWrapperMessageList;
    }
    
    public static List<UTL_OWF.workflowEmailRecordWrapper> sendEmailForQ2SolutionSubmitToContracts(Map<Id, Bid_History__c> q2SolutionStrategicPricingAlertMap){
        List<UTL_OWF.workflowEmailRecordWrapper> workflowEmailRecordWrapperMessageList = new List<UTL_OWF.workflowEmailRecordWrapper>();
        List<String> toCcEmailList = new List<String>();
        
        OWF_Generic_Setting__c additionalEmail = OWF_Generic_Setting__c.getValues(CON_OWF.BHR_OWF_06_Q2CONTRACTREQUESTS);
        if(additionalEmail != null && additionalEmail.Value__c != null){
            toCcEmailList = (additionalEmail.Value__c).split(',');
        }
        if(toCcEmailList.size()>0){
            List<String> toEmailList = new List<String>();
            String subject = '';
            String emailOverallBodyContent = '';
            UTL_OWF.workflowEmailRecordWrapper workflowEmailRecordWrapperMessage = new UTL_OWF.workflowEmailRecordWrapper();
            for(Bid_History__c bidHistory : q2SolutionStrategicPricingAlertMap.values()){
                toEmailList = new List<String>();
                subject = '';
                emailOverallBodyContent = '';
                /*if(bidHistory.Bid_Owner_Email__c != null){
                    toEmailList.add(bidHistory.Bid_Owner_Email__c);
                }*/
                workflowEmailRecordWrapperMessage = new UTL_OWF.workflowEmailRecordWrapper();
                subject =  'Request for CA support: ' + (bidHistory.Legacy_Quintiles_Opportunity_Number__c  != null ? bidHistory.Legacy_Quintiles_Opportunity_Number__c  : (''));
                emailOverallBodyContent = '<div>Dear Contracts <br><br>';
                emailOverallBodyContent += 'Please assign a CA to assist with this new opportunity.<br><br>';
                emailOverallBodyContent += 'Link to Opportunity: <a href = \'' + URL.getOrgDomainUrl().toExternalForm() + '/' + (bidHistory.Bid_History_Related_Opportunity__c != null ? bidHistory.Bid_History_Related_Opportunity__c : ('')) + '\'>' + (bidHistory.Bid_History_Related_Opportunity__r.Name != null ? bidHistory.Bid_History_Related_Opportunity__r.Name : ('')) + '</a><br>';
                emailOverallBodyContent += '</div>';
                
                workflowEmailRecordWrapperMessage.whatId = bidHistory.Id;
                workflowEmailRecordWrapperMessage.toEmails = toEmailList;
                workflowEmailRecordWrapperMessage.ccEmails = toCcEmailList;
                workflowEmailRecordWrapperMessage.ownerId = bidHistory.OwnerId;
                workflowEmailRecordWrapperMessage.emailAction = CON_OWF.Q2_SUBMIT_TO_CONTRACTS_EMAIL_ACTION;
                workflowEmailRecordWrapperMessage.subject = subject;
                workflowEmailRecordWrapperMessage.staticContent = emailOverallBodyContent;
                workflowEmailRecordWrapperMessageList.add(workflowEmailRecordWrapperMessage);
                
            }  
        }
        return workflowEmailRecordWrapperMessageList;
    }
    
    /* This method is used to Send Email Through Email Workflow Alert Object
    * @params  List<Bid_History__c> newList,Map<id, Bid_History__c> oldMap
    * @return  void
    */									
    //IQVIAPSA-6544 1
    
    public static List<UTL_OWF.workflowEmailRecordWrapper> sendEmailForQ2BioFortisAlert(Map<Id, Bid_History__c> q2SolutionBioFortisAlertMap){
        List<UTL_OWF.workflowEmailRecordWrapper> workflowEmailRecordWrapperMessageList = new List<UTL_OWF.workflowEmailRecordWrapper>();
        List<String> toEmailList = new List<String>();
        
        OWF_Generic_Setting__c additionalEmail = OWF_Generic_Setting__c.getValues(CON_OWF.BHR_OWF_12_Q2BIOFORTISALERT);
        if(additionalEmail != null && additionalEmail.Value__c != null){
            toEmailList = (additionalEmail.Value__c).split(',');
        }
        if(toEmailList.size()>0){
            String subject = '';
            String emailOverallBodyContent = '';
            UTL_OWF.workflowEmailRecordWrapper workflowEmailRecordWrapperMessage = new UTL_OWF.workflowEmailRecordWrapper();
            for(Bid_History__c agreement : q2SolutionBioFortisAlertMap.values()){
                subject = '';
                emailOverallBodyContent = '';
                workflowEmailRecordWrapperMessage = new UTL_OWF.workflowEmailRecordWrapper();
                subject = (agreement.Opportunity_Name__c != null ? agreement.Opportunity_Name__c : (''))+'_'+(agreement.Bid_History_Related_Opportunity__r.Phase__c != null ? agreement.Bid_History_Related_Opportunity__r.Phase__c : (''))+'_'+(agreement.Bid_History_Related_Opportunity__r.TherapyArea__c != null ? agreement.Bid_History_Related_Opportunity__r.TherapyArea__c : (''))+'_'
                    +(agreement.Legacy_Quintiles_Opportunity_Number__c  != null ? agreement.Legacy_Quintiles_Opportunity_Number__c  : (''))+'_'+(String.valueOf(agreement.Bid_History_Related_Opportunity__r.Proposal_Due_Date__c) != null ? String.valueOf(agreement.Bid_History_Related_Opportunity__r.Proposal_Due_Date__c) : (''))+'_Indication:'+(agreement.Bid_History_Related_Opportunity__r.Indication__c != null ? agreement.Bid_History_Related_Opportunity__r.Indication__c : (''));
                emailOverallBodyContent = '<div>'+(agreement.Bid_History_Related_Opportunity__r.Owner.Name != null ? agreement.Bid_History_Related_Opportunity__r.Owner.Name : (''))+' has provided a new Central Laboratory opportunity from ';
                emailOverallBodyContent += (agreement.Opportunity_Account__c != null ? agreement.Opportunity_Account__c : ('')) + ' to include BioFortis.<br><br>';
                emailOverallBodyContent += (agreement.Owner.Name != null ? agreement.Owner.Name : (''))+' has been assigned as Proposal Developer. Please direct all further correspondence to the assigned PD and Central Lab BD.<br><br>';
                emailOverallBodyContent += '<b>Proposal Deliverable : </b>' + '<span style = "font-weight: normal;">' + (agreement.Proposal_Deliverable__c != null ? agreement.Proposal_Deliverable__c : ('')) + '</span>' +'<br>';
                emailOverallBodyContent += '<b>Budget Deliverable : </b>' + '<span style = "font-weight: normal;">' + (agreement.Budget_Deliverable__c != null ? agreement.Budget_Deliverable__c : ('')) + '</span>' +'<br>';
                emailOverallBodyContent += '<b>Proposal Due Date : </b>' + '<span style = "font-weight: normal;">' + (String.valueOf(agreement.Bid_Due_Date__c) != null ? String.valueOf(agreement.Bid_Due_Date__c) : ('')) + '</span>' +'<br>';
                emailOverallBodyContent += '<b>Link to Opportunity : </b><span style = "font-weight: normal;"><a href = \'' +  Url.getOrgDomainUrl().toExternalForm() + '/' + (agreement.Bid_History_Related_Opportunity__r.Id != null ? agreement.Bid_History_Related_Opportunity__r.Id : ('')) + '\'>' + (agreement.Bid_History_Related_Opportunity__r.Name != null ? agreement.Bid_History_Related_Opportunity__r.Name : ('')) + '</a></span><br><br>';
                emailOverallBodyContent += '<u><b>Opportunity Details</b></u><br><br>';
                emailOverallBodyContent += '<b>LQ Opportunity Number : </b>' + '<span style = "font-weight: normal;">' + (agreement.Legacy_Quintiles_Opportunity_Number__c != null ? agreement.Legacy_Quintiles_Opportunity_Number__c : ('')) + '</span>' +'<br><br>';
                emailOverallBodyContent += '<b>Phase : </b>' + '<span style = "font-weight: normal;">' + (agreement.Bid_History_Related_Opportunity__r.Phase__c != null ? agreement.Bid_History_Related_Opportunity__r.Phase__c : ('')) + '</span>' +'<br>';
                emailOverallBodyContent += '<b>Therapeutic Area : </b>' + '<span style = "font-weight: normal;">' + (agreement.Therapy_Area__c != null ? agreement.Therapy_Area__c : ('')) + '</span>' +'<br>';
                emailOverallBodyContent += '<b>Potential Regions : </b>' + '<span style = "font-weight: normal;">' + (agreement.Bid_History_Related_Opportunity__r.Potential_Regions__c != null ? agreement.Bid_History_Related_Opportunity__r.Potential_Regions__c : ('')) + '</span>' +'<br>';
                emailOverallBodyContent += '<b>Patients Enrolled : </b>' + '<span style = "font-weight: normal;">' + (String.valueOf(agreement.Patients_Enrolled__c) != null ? String.valueOf(agreement.Patients_Enrolled__c) : ('')) + '</span>' +'<br><br>';
                emailOverallBodyContent += '<b>Bid Defense Date : </b>' + '<span style = "font-weight: normal;">' + (String.valueOf(agreement.Bid_History_Related_Opportunity__r.Presentation_Date__c) != null ? String.valueOf(agreement.Bid_History_Related_Opportunity__r.Presentation_Date__c) : ('')) + '</span>' +'<br>';
                emailOverallBodyContent += '<b>FPI Date : </b>' + '<span style = "font-weight: normal;">' + (String.valueOf(agreement.Bid_History_Related_Opportunity__r.FPI_Date__c) != null ? String.valueOf(agreement.Bid_History_Related_Opportunity__r.FPI_Date__c) : ('')) + '</span>' +'<br>';
                emailOverallBodyContent += '</div>';
                
                workflowEmailRecordWrapperMessage.whatId = agreement.Id;
                workflowEmailRecordWrapperMessage.toEmails = toEmailList;
                workflowEmailRecordWrapperMessage.emailAction = CON_OWF.Q2_SOLUTIONS_BIO_FORTIS_ALERT_EMAIL_ACTION;
                workflowEmailRecordWrapperMessage.subject = subject;
                workflowEmailRecordWrapperMessage.staticContent = emailOverallBodyContent;
                workflowEmailRecordWrapperMessageList.add(workflowEmailRecordWrapperMessage);
            }  
        }
        return workflowEmailRecordWrapperMessageList;  
    }
    
    //IQVIAPSA-6544 2
    public static List<UTL_OWF.workflowEmailRecordWrapper> sendEmailForQ2ChinaLocalSolutionAlert(Map<Id, Bid_History__c> q2SolutionChinaLocalAlertMap){
        List<UTL_OWF.workflowEmailRecordWrapper> workflowEmailRecordWrapperMessageList = new List<UTL_OWF.workflowEmailRecordWrapper>();
        List<String> toEmailList = new List<String>();
        
        OWF_Generic_Setting__c additionalEmail = OWF_Generic_Setting__c.getValues(CON_OWF.BHR_OWF_13_Q2CHINALOCALSOLUTIONALERT);
        if(additionalEmail != null && additionalEmail.Value__c != null){
            toEmailList = (additionalEmail.Value__c).split(',');
        }
        if(toEmailList.size()>0){
            String subject = '';
            String emailOverallBodyContent = '';
            UTL_OWF.workflowEmailRecordWrapper workflowEmailRecordWrapperMessage = new UTL_OWF.workflowEmailRecordWrapper();
            for(Bid_History__c bidHistory : q2SolutionChinaLocalAlertMap.values()){
                subject = '';
                emailOverallBodyContent = '';
                workflowEmailRecordWrapperMessage = new UTL_OWF.workflowEmailRecordWrapper();
                subject ='NEW Scientific Review Request for ' + ' - ' + (bidHistory.Opportunity_Account__c != null ? bidHistory.Opportunity_Account__c : ('')) + ' - ' + (bidHistory.Protocol_Number__c != null ? bidHistory.Protocol_Number__c :('')) + ' - ' + (bidHistory.Legacy_Quintiles_Opportunity_Number__c  != null ? bidHistory.Legacy_Quintiles_Opportunity_Number__c  :('')) + ' - ' + (String.valueOf(bidHistory.Science_Due_Date__c) != null ? String.valueOf(bidHistory.Science_Due_Date__c) :(''));
                emailOverallBodyContent = '<div>A new opportunity has been received for ' + (bidHistory.Opportunity_Account__c != null ? bidHistory.Opportunity_Account__c : ('')) + ' - ' + (bidHistory.Protocol_Number__c != null ? bidHistory.Protocol_Number__c :('')) + ' which requires a scientific review.<br><br>';
                emailOverallBodyContent += 'Please see below for a summary of the key study information and a link to the CRM Bid History record where full RFP information and documents can be obtained.<br><br>';
                emailOverallBodyContent += '<b>Bid History Link: </b><span style = "font-weight: normal;"><a href = \'' +  Url.getOrgDomainUrl().toExternalForm() + '/' + (bidHistory.id != null ? bidHistory.id : ('')) + '\'>' + (bidHistory.Name != null ? bidHistory.Name : ('')) + '</a></span><br>';
                emailOverallBodyContent += '<b>Sponsor: </b><span style = "font-weight: normal;">' + (bidHistory.Opportunity_Account__c != null ? bidHistory.Opportunity_Account__c : ('')) + '</span><br>';
                emailOverallBodyContent += '<b>Opportunity Owner: </b><span style = "font-weight: normal;">' + (bidHistory.Bid_History_Related_Opportunity__r.Owner.Name != null ? bidHistory.Bid_History_Related_Opportunity__r.Owner.Name : ('')) + '</span><br>';
                emailOverallBodyContent += '<b>Bid Owner: </b><span style = "font-weight: normal;">' + (bidHistory.Owner.Name != null ? bidHistory.Owner.Name : ('')) + '</span><br>';
                emailOverallBodyContent += '<b>Budget Tool: </b><span style = "font-weight: normal;">' + (bidHistory.Q2_Budget_Tools__c != null ? bidHistory.Q2_Budget_Tools__c : ('')) + '</span><br>';
                emailOverallBodyContent += '<b>Budget Deliverables: </b><span style = "font-weight: normal;">' + (bidHistory.Budget_Deliverable__c != null ? bidHistory.Budget_Deliverable__c : ('')) + '</span><br>';
                emailOverallBodyContent += '<b>Protocol Number: </b><span style = "font-weight: normal;">' + (bidHistory.Protocol_Number__c != null ? bidHistory.Protocol_Number__c : ('')) + '</span><br>';
                emailOverallBodyContent += '<b>Opportunity Number: </b><span style = "font-weight: normal;">' + (bidHistory.Legacy_Quintiles_Opportunity_Number__c  != null ? bidHistory.Legacy_Quintiles_Opportunity_Number__c  : ('')) + '</span><br>';
                emailOverallBodyContent += '<b>Bid Type: </b><span style = "font-weight: normal;">' + (bidHistory.Bid_Type__c != null ? bidHistory.Bid_Type__c : ('')) + '</span></span><br>';
                emailOverallBodyContent += '<b>Bid Number: </b><span style = "font-weight: normal;">' + (String.valueOf(bidHistory.Bid_Number__c) != null ? String.valueOf(bidHistory.Bid_Number__c) : ('')) + '</span><br>';
                emailOverallBodyContent += '<b>Indication: </b><span style = "font-weight: normal;">' + (bidHistory.Indication__c != null ? bidHistory.Indication__c : ('')) + '</span><br>';
                emailOverallBodyContent += '<b>Study Phase: </b><span style = "font-weight: normal;">' + (bidHistory.Study_Phase__c != null ? bidHistory.Study_Phase__c : ('')) + '</span><br>';
                emailOverallBodyContent += '<b>Study Start Date: </b><span style = "font-weight: normal;">' + (String.valueOf(bidHistory.Study_Start_Date__c) != null ? String.valueOf(bidHistory.Study_Start_Date__c) : ('')) + '</span><br>';
                emailOverallBodyContent += '<b>Enrollment (Months): </b><span style = "font-weight: normal;">' + (String.valueOf(bidHistory.Enrollement_Months__c) != null ? String.valueOf(bidHistory.Enrollement_Months__c) : ('')) + '</span><br>';
                emailOverallBodyContent += '<b>Patient Duration (Months): </b><span style = "font-weight: normal;">' + (String.valueOf(bidHistory.Patient_Duration_Months__c) != null ? String.valueOf(bidHistory.Patient_Duration_Months__c) : ('')) + '</span><br>';
                emailOverallBodyContent += '<b>Region(s): </b><span style = "font-weight: normal;">' + (bidHistory.OWF_Potential_Regions__c != null ? bidHistory.OWF_Potential_Regions__c : ('')) + '</span><br>';
                emailOverallBodyContent += '<b>Requested Services: </b><span style = "font-weight: normal;">' + (bidHistory.Requested_Services__c != null ? bidHistory.Requested_Services__c : ('')) + '</span><br><br>';
                emailOverallBodyContent += '<b>Scientific Review Due Date: </b><span style = "font-weight: normal;">' + (String.valueOf(bidHistory.Science_Due_Date__c) != null ? String.valueOf(bidHistory.Science_Due_Date__c) : ('')) + '</span><br>';
                emailOverallBodyContent += '<b>Additional Study Comments/Information: </b><span style = "font-weight: normal;">' + (bidHistory.Testing_Comments__c != null ? bidHistory.Testing_Comments__c : ('')) + '</span><br>';
                emailOverallBodyContent += '</div>';
                
                workflowEmailRecordWrapperMessage.whatId = bidHistory.Id;
                workflowEmailRecordWrapperMessage.toEmails = toEmailList;
                workflowEmailRecordWrapperMessage.emailAction = CON_OWF.Q2_SOLUTIONS_CHINA_LOCAL_SOLUTIONS_ALERT_EMAIL_ACTION;
                workflowEmailRecordWrapperMessage.subject = subject;
                workflowEmailRecordWrapperMessage.staticContent = emailOverallBodyContent;
                workflowEmailRecordWrapperMessageList.add(workflowEmailRecordWrapperMessage);
                
            }  
        }        
        return workflowEmailRecordWrapperMessageList;  
    }
    
    //IQVIAPSA-6815
    public static List<UTL_OWF.workflowEmailRecordWrapper> sendEmailForQ2BidOwnerChange(Map<Id, Bid_History__c> q2BidOwnerChangeAlertMap){
        List<UTL_OWF.workflowEmailRecordWrapper> workflowEmailRecordWrapperMessageList = new List<UTL_OWF.workflowEmailRecordWrapper>();
        List<String> toEmailList = new List<String>();

            String subject = '';
            String emailOverallBodyContent = '';
            UTL_OWF.workflowEmailRecordWrapper workflowEmailRecordWrapperMessage = new UTL_OWF.workflowEmailRecordWrapper();
            for(Bid_History__c bidHistory : q2BidOwnerChangeAlertMap.values()){
                /*if(bidHistory.Owner.Email != null || bidHistory.Owner.Email != ''){
                    toEmailList.add(bidHistory.Owner.Email);
                }*/
                if(bidHistory.Supporting_Bid_Owner__r.Email != null || bidHistory.Supporting_Bid_Owner__r.Email != ''){
                    toEmailList.add(bidHistory.Supporting_Bid_Owner__r.Email);
                }
                if(bidHistory.Opportunity_Owner_Email__c != null || bidHistory.Opportunity_Owner_Email__c != ''){
                    toEmailList.add(bidHistory.Opportunity_Owner_Email__c);
                }
                subject = '';
                emailOverallBodyContent = '';
                workflowEmailRecordWrapperMessage = new UTL_OWF.workflowEmailRecordWrapper();
                subject ='Assigned-'+ (bidHistory.Bid_Pre_Post_Award__c != null ? bidHistory.Bid_Pre_Post_Award__c : ('')) + ' for ' + (bidHistory.Opportunity_Account__c != null ? bidHistory.Opportunity_Account__c : ('')) + ' - ' + (bidHistory.Protocol_Number__c != null ? bidHistory.Protocol_Number__c :('')) + ' - ' + (bidHistory.Legacy_Quintiles_Opportunity_Number__c != null ? bidHistory.Legacy_Quintiles_Opportunity_Number__c :(''));
                emailOverallBodyContent = '<div>This - '+ (bidHistory.Bid_Pre_Post_Award__c != null ? bidHistory.Bid_Pre_Post_Award__c : ('')) + ' for ' + (bidHistory.Opportunity_Account__c != null ? bidHistory.Opportunity_Account__c : ('')) + ' - ' + (bidHistory.Protocol_Number__c != null ? bidHistory.Protocol_Number__c :('')) +' has been assigned to ' + (bidHistory.Owner.Name != null ? bidHistory.Owner.Name : ('')) + '. <br><br>';
                emailOverallBodyContent += 'Please ensure that, moving forward, any communications, completed reviews and additional information are shared with '+ (bidHistory.Owner.Name != null ? bidHistory.Owner.Name : ('')) + '. <br/><br/><br/>';
                emailOverallBodyContent += '<b>Bid History Link: </b><span style = "font-weight: normal;"><a href = \'' +  Url.getOrgDomainUrl().toExternalForm() + '/' + (bidHistory.id != null ? bidHistory.id : ('')) + '\'>' + (bidHistory.Name != null ? bidHistory.Name : ('')) + '</a></span><br>';
                emailOverallBodyContent += '</div>';
                
                workflowEmailRecordWrapperMessage.whatId = bidHistory.Id;
                workflowEmailRecordWrapperMessage.toEmails = toEmailList;
                workflowEmailRecordWrapperMessage.ownerId = bidHistory.OwnerId;
                workflowEmailRecordWrapperMessage.emailAction = CON_OWF.Q2_SOLUTIONS_BID_OWNER_CHANGE_ALERT_EMAIL_ACTION;
                workflowEmailRecordWrapperMessage.subject = subject;
                workflowEmailRecordWrapperMessage.staticContent = emailOverallBodyContent;
                workflowEmailRecordWrapperMessageList.add(workflowEmailRecordWrapperMessage);
                
            }         
        return workflowEmailRecordWrapperMessageList;  
    }

    public static List<UTL_OWF.workflowEmailRecordWrapper> sendEmailForAwardedBidHistoryAlert(Map<Id, Bid_History__c> budgetToolsMap){
        List<UTL_OWF.workflowEmailRecordWrapper> workflowEmailRecordWrapperMessageList = new List<UTL_OWF.workflowEmailRecordWrapper>();
        List<String> toEmailList;
        String emailOverallBodyContent;
        UTL_OWF.workflowEmailRecordWrapper workflowEmailRecordWrapperMessage;
        
        for(Bid_History__c agreement : budgetToolsMap.values()){
            toEmailList = new List<String>();
            emailOverallBodyContent = '';
            if(agreement.Bid_History_Related_Opportunity__r.Owner_Email__c != null){
                toEmailList.add(agreement.Bid_History_Related_Opportunity__r.Owner_Email__c);
            }
            if(agreement.Owner.Email != null){
                toEmailList.add(agreement.Owner.Email);
            }
            workflowEmailRecordWrapperMessage = new UTL_OWF.workflowEmailRecordWrapper();
            workflowEmailRecordWrapperMessage.subject ='ACTION: Non Compliant Quote -'+(agreement.Legacy_Quintiles_Opportunity_Number__c != null ? agreement.Legacy_Quintiles_Opportunity_Number__c : ('')) ;
            emailOverallBodyContent = '<div>Dear ' + (agreement.Owner.Name != null ? agreement.Owner.Name : ('')) + '<br></br>';
            emailOverallBodyContent += ' The awarded opportunity '+ '<span style = "font-weight: normal;">' + (agreement.Legacy_Quintiles_Opportunity_Number__c != null ? agreement.Legacy_Quintiles_Opportunity_Number__c : ('')) + '</span>';
            emailOverallBodyContent += ' has an associated quote record with the awarded bid '+ '<span style = "font-weight: normal;">' + (agreement.Name != null ? agreement.Name : ('')) + '</span>'+ '<span style = "font-weight: normal;">' + (String.valueOf(agreement.Bid_Number__c) != null ? String.valueOf(agreement.Bid_Number__c) : ('')) + '</span>';
            emailOverallBodyContent += ' that does not meet the required criteria to automatically move the quote to \'Accepted\'<br></br>';
            emailOverallBodyContent += '<br>Please take immediate steps to ensure that the associated quote meets all the following criteria: <br>';
            emailOverallBodyContent += '<ul><li>A FINAL UPT on Notes & Attachments (CRM Finalisation required)</li><li>Complete all required fields in section ‘Required fields for Bid Owners</li><li>Quote is marked as Primary</li></ul>';            
            emailOverallBodyContent += '<br><b>Opportunity Details</b><br>';
            emailOverallBodyContent += 'Link to Opportunity: '+ '<span style = "font-weight: normal;"><a href = \'' + URL.getOrgDomainURL().toExternalForm() + '/' + (agreement.Bid_History_Related_Opportunity__r.Id != null ? agreement.Bid_History_Related_Opportunity__r.Id : ('')) + '\'>' + (agreement.Bid_History_Related_Opportunity__r.Name != null ? agreement.Bid_History_Related_Opportunity__r.Name : ('')) + '</a></span>'+'<br>';
            emailOverallBodyContent += 'Link to Awarded Bid: ' + '<span style = "font-weight: normal;"><a href = \'' + URL.getOrgDomainURL().toExternalForm() + '/' + (agreement.id != null ? agreement.id : ('')) + '\'>' + (agreement.Name != null ? agreement.Name : (''))+ '</a></span>' +  +'<br></br>';
            emailOverallBodyContent += 'Link to Associated Quote: ' + '<span style = "font-weight: normal;">' + (agreement.Link_to_Quote__c != null ? agreement.Link_to_Quote__c : ('')) + '</span>' +  +'<br></br>';
            emailOverallBodyContent += '<br>Please refer to the training materials located on the UPT SharePoint, or subsequently please contact CPQ/UPT Support.<br>';
            emailOverallBodyContent += 'Thank you.</div>';
            
            workflowEmailRecordWrapperMessage.whatId = agreement.Id;
            workflowEmailRecordWrapperMessage.toEmails = toEmailList;
            workflowEmailRecordWrapperMessage.emailAction = CON_OWF.BUDGET_TOOLS_ALERT_EMAIL_ACTION;
            workflowEmailRecordWrapperMessage.staticContent = emailOverallBodyContent;
            workflowEmailRecordWrapperMessageList.add(workflowEmailRecordWrapperMessage);
            
        }  
        return workflowEmailRecordWrapperMessageList;
    }
    
    public static List<UTL_OWF.workflowEmailRecordWrapper> sendEmailForReadyToAwardedBidHistoryAlert(List<Bid_History__c> bidHistoryList){
        List<UTL_OWF.workflowEmailRecordWrapper> workflowEmailRecordWrapperMessageList = new List<UTL_OWF.workflowEmailRecordWrapper>();
        List<String> toEmailList;
        String emailOverallBodyContent;
        OWF_Generic_Setting__c additionalEmail = OWF_Generic_Setting__c.getValues(CON_OWF.BHR_OWF_AwardBidWithStatusReadyToAward);
        UTL_OWF.workflowEmailRecordWrapper workflowEmailRecordWrapperMessage;
        for(Bid_History__c bidHistory : bidHistoryList){
            toEmailList = new List<String>();
            emailOverallBodyContent = '';
            if(additionalEmail != null && additionalEmail.Value__c != null){
                toEmailList = (additionalEmail.Value__c).split(',');
            }
            if(bidHistory.Owner.Email != null){
                toEmailList.add(bidHistory.Owner.Email);
            }
            workflowEmailRecordWrapperMessage = new UTL_OWF.workflowEmailRecordWrapper();
            workflowEmailRecordWrapperMessage.subject =(bidHistory.Name != null ? bidHistory.Name : ('')) + ' ' + (bidHistory.Opportunity_Number__c != null ? bidHistory.Opportunity_Number__c : ('')) + ' of ' + (bidHistory.Bid_History_Account__r.Name != null ? bidHistory.Bid_History_Account__r.Name : ('')) + ' has been Awarded with Bid # '+ (String.valueOf(bidHistory.Bid_Number__c) != null ? String.valueOf(bidHistory.Bid_Number__c) : (''));
            emailOverallBodyContent = '<div><b>Notification of Outcome of Bid</b><br>';
            emailOverallBodyContent += '<br>Comments: ' + (bidHistory.Comments__c != null ? bidHistory.Comments__c : ('')) + '<br>';
            emailOverallBodyContent += 'Opportunity Owner: '  + (bidHistory.Opportunity_Owner__c != null ? bidHistory.Opportunity_Owner__c : ('')) + '<br>';
            emailOverallBodyContent += 'Opportunity Number: ' + (bidHistory.Opportunity_Number__c != null ? bidHistory.Opportunity_Number__c : ('')) + '<br>';
            emailOverallBodyContent += 'Legacy Quintiles Opportunity Number: ' + (bidHistory.Legacy_Quintiles_Opportunity_Number__c != null ? bidHistory.Legacy_Quintiles_Opportunity_Number__c : ('')) + '<br></br>';
            emailOverallBodyContent += '<br>Bid No:  ' + (String.valueOf(bidHistory.Bid_Number__c) != null ? String.valueOf(bidHistory.Bid_Number__c) : ('')) + '<br>';
            emailOverallBodyContent += 'Account Name: ' + (bidHistory.Bid_History_Account__r.Name != null ? bidHistory.Bid_History_Account__r.Name : ('')) +'<br>';
            emailOverallBodyContent += 'Category: ' + (bidHistory.Bid_Category__c != null ? bidHistory.Bid_Category__c : ('')) + '<br>';
            emailOverallBodyContent += 'Is this IQVIA Biotech: ' + (bidHistory.Bid_History_Related_Opportunity__r.Is_this_IQVIA_Biotech__c != null ? bidHistory.Bid_History_Related_Opportunity__r.Is_this_IQVIA_Biotech__c : ('')) + '<br>';
            emailOverallBodyContent += 'Total Project Awarded Price: ' + (String.valueOf(bidHistory.Bid_History_Related_Opportunity__r.Total_Project_Awarded_Price__c) != null ? String.valueOf(bidHistory.Bid_History_Related_Opportunity__r.Total_Project_Awarded_Price__c) : ('')) + '<br>';
            emailOverallBodyContent += 'Opportunity Name: ' + (String.valueOf(bidHistory.Bid_History_Related_Opportunity__r.Name) != null ? String.valueOf(bidHistory.Bid_History_Related_Opportunity__r.Name) : ('')) + '<br>';
            emailOverallBodyContent += 'Opportunity Link: ' + '<a href = \'' + URL.getOrgDomainURL().toExternalForm() + '/' + (bidHistory.Bid_History_Related_Opportunity__r.Id != null ? bidHistory.Bid_History_Related_Opportunity__r.Id : ('')) + '\'>' + (bidHistory.Bid_History_Related_Opportunity__r.Name != null ? bidHistory.Bid_History_Related_Opportunity__r.Name : ('')) + '</a>'+'<br></br>';
            emailOverallBodyContent += '<br>Note: To use the above link please make sure you are already logged into IQVIA CRM<br></br>';
            emailOverallBodyContent += '<br><b>Opportunity Information</b><br>';
            emailOverallBodyContent += 'Indication: ' + (bidHistory.Indication__c != null ? bidHistory.Indication__c : ('')) +'<br>';
            emailOverallBodyContent += 'Therapy Area: ' + (bidHistory.Therapy_Area__c != null ? bidHistory.Therapy_Area__c : ('')) +'<br>';
            emailOverallBodyContent += 'Phase: ' + (bidHistory.Phase__c != null ? bidHistory.Phase__c : ('')) +'<br>';
            emailOverallBodyContent += 'Expected Project Start Date: ' + (String.valueOf(bidHistory.Expected_Project_Start_Date__c) != null ? String.valueOf(bidHistory.Expected_Project_Start_Date__c) : ('')) +'<br>';
            emailOverallBodyContent += 'Line of Business: ' + (bidHistory.Line_of_Business__c != null ? bidHistory.Line_of_Business__c : ('')) +'<br>';
            emailOverallBodyContent += 'Will be Contracted via CO?: ' + (bidHistory.Bid_History_Related_Opportunity__r.Will_be_Contracted_via_CO__c != null ? bidHistory.Bid_History_Related_Opportunity__r.Will_be_Contracted_via_CO__c : ('')) +'<br></br>';            
            emailOverallBodyContent += '<br>Primary Win Reason: ' + (bidHistory.Bid_History_Related_Opportunity__r.Primary_Win_Reason__c != null ? bidHistory.Bid_History_Related_Opportunity__r.Primary_Win_Reason__c : ('')) + '<br>';
            emailOverallBodyContent += 'Primary Win Reason Detail: ' + (bidHistory.Bid_History_Related_Opportunity__r.Primary_Win_Reason_Detail__c != null ? bidHistory.Bid_History_Related_Opportunity__r.Primary_Win_Reason_Detail__c : ('')) + '<br></br>';            
            emailOverallBodyContent += '<br>** This information has been sent to you via the IQVIA CRM System **<br></br>';
                        
            workflowEmailRecordWrapperMessage.whatId = bidHistory.Id;
            workflowEmailRecordWrapperMessage.toEmails = toEmailList;
            workflowEmailRecordWrapperMessage.emailAction = CON_OWF.BUDGET_TOOLS_BIDHISTORY_ALERT_EMAIL_ACTION;
            workflowEmailRecordWrapperMessage.staticContent = emailOverallBodyContent;
            workflowEmailRecordWrapperMessageList.add(workflowEmailRecordWrapperMessage);
            
        }  
        return workflowEmailRecordWrapperMessageList;
    }

    private static List<UTL_OWF.workflowEmailRecordWrapper> sendQ2solutionsEmailNotifications(Bid_History__c bidHistory , Map<id, Bid_History__c> oldMap){
        List<UTL_OWF.workflowEmailRecordWrapper> workflowEmailRecordWrapperMessageList = new List<UTL_OWF.workflowEmailRecordWrapper>(); 
        if(trigger.IsInsert){
            workflowEmailRecordWrapperMessageList.add(sendQ2SolutionsBidAlertToRFPMailbox(bidHistory));
            
            if(bidHistory.Bid_Sent__c ==  CON_OWF.BID_SENT){
                workflowEmailRecordWrapperMessageList.add(sendEmailForQ2solutionsBidSentDate(bidHistory));
            }
        }
        else if(trigger.IsUpdate){
            if(bidHistory.OwnerId != oldMap.get(bidHistory.id).OwnerId && String.ValueOf(bidHistory.OwnerId).startsWith('005')){
                workflowEmailRecordWrapperMessageList.add(sendEmailForQ2solutionsBidOwnerChange(bidHistory));
            }
            
            if(bidHistory.Stage__c != oldMap.get(bidHistory.id).Stage__c && (bidHistory.Stage__c == CON_OWF.BID_HISTORY_STAGE_SENT || bidHistory.Stage__c == CON_OWF.BID_HISTORY_STAGE_SIGNED_FINALIZED) ){
                workflowEmailRecordWrapperMessageList.add(sendQ2SolutionsEmailNotificationOnStageChange(bidHistory));
            }
            if(bidHistory.Bid_Sent__c != oldMap.get(bidHistory.id).Bid_Sent__c && bidHistory.Bid_Sent__c ==  CON_OWF.BID_SENT){
                workflowEmailRecordWrapperMessageList.add(sendEmailForQ2solutionsBidSentDate(bidHistory));
            }
        }
        return workflowEmailRecordWrapperMessageList;
    }
    
    public static UTL_OWF.workflowEmailRecordWrapper sendEmailForGCCforFieldUpdate(Bid_History__c bidHistory , Map<id, Bid_History__c> oldMap){
        List<String> toEmailList;
        String emailOverallBodyContent;
        OWF_Generic_Setting__c additionalEmail = OWF_Generic_Setting__c.getValues(CON_OWF.BHR_OWF_NotificationToGCCBidHistoryOnFieldUpdate);
        UTL_OWF.workflowEmailRecordWrapper workflowEmailRecordWrapperMessage;
        toEmailList = new List<String>();
        emailOverallBodyContent = '';
        if(additionalEmail != null && additionalEmail.Value__c != null){
            toEmailList = (additionalEmail.Value__c).split(',');
        }
        workflowEmailRecordWrapperMessage = new UTL_OWF.workflowEmailRecordWrapper();
        workflowEmailRecordWrapperMessage.subject ='Field update may effect proposal,please review';
        emailOverallBodyContent = '<div>Please be informed that below fields has been edited in the below bid:<br><br>';
        emailOverallBodyContent += '<b>Bid Link: </b><span style = "font-weight: normal;"><a href = \'' + URL.getOrgDomainUrl().toExternalForm() + '/' + (bidHistory.id != null ? bidHistory.id : ('')) + '\'>' + (bidHistory.Name != null ? bidHistory.Name : ('')) + '</a></span><br>';
        if(bidHistory.Calls_Emails_Contacts_Monthly_Inbound__c != oldMap.get(bidHistory.id).Calls_Emails_Contacts_Monthly_Inbound__c){
            emailOverallBodyContent += 'Calls/Emails/Contacts Monthly Inbound: <b> Old Value:</b>' + (oldMap.get(bidHistory.id).Calls_Emails_Contacts_Monthly_Inbound__c != null ? oldMap.get(bidHistory.id).Calls_Emails_Contacts_Monthly_Inbound__c : ('')) + 
                '<b> New Value:</b>' + (bidHistory.Calls_Emails_Contacts_Monthly_Inbound__c != null ? bidHistory.Calls_Emails_Contacts_Monthly_Inbound__c : ('')) + '<br>';
        } 
        if(bidHistory.Calls_Emails_Contacts_Monthly_Outbound__c != oldMap.get(bidHistory.id).Calls_Emails_Contacts_Monthly_Outbound__c){
            emailOverallBodyContent += 'Calls/Emails/Contacts Monthly Outbound: <b> Old Value:</b>' + (oldMap.get(bidHistory.id).Calls_Emails_Contacts_Monthly_Outbound__c != null ? oldMap.get(bidHistory.id).Calls_Emails_Contacts_Monthly_Outbound__c : ('')) + 
                '<b> New Value:</b>' + (bidHistory.Calls_Emails_Contacts_Monthly_Outbound__c != null ? bidHistory.Calls_Emails_Contacts_Monthly_Outbound__c : ('')) + '<br>';
        } 
        if(bidHistory.Project_Duration_Months__c != oldMap.get(bidHistory.id).Project_Duration_Months__c){
            emailOverallBodyContent += 'Project Duration (Months): <b> Old Value:</b>' + (oldMap.get(bidHistory.id).Project_Duration_Months__c != null ? oldMap.get(bidHistory.id).Project_Duration_Months__c : ('')) + 
                '<b> New Value:</b>' + (bidHistory.Project_Duration_Months__c != null ? bidHistory.Project_Duration_Months__c : ('')) + '<br>';
        }          
        workflowEmailRecordWrapperMessage.whatId = bidHistory.Id;
        workflowEmailRecordWrapperMessage.toEmails = toEmailList;
        workflowEmailRecordWrapperMessage.emailAction = CON_OWF.OWF_NotificationToGCCForFieldUpdate;
        workflowEmailRecordWrapperMessage.staticContent = emailOverallBodyContent;            
        return workflowEmailRecordWrapperMessage;
    }
   
    public static UTL_OWF.workflowEmailRecordWrapper sendEmailForGCCforBHRStatusUpdate(Bid_History__c bidHistory , Map<id, Bid_History__c> oldMap){
            UTL_OWF.workflowEmailRecordWrapper workflowEmailRecordWrapperMessage;
            workflowEmailRecordWrapperMessage = new UTL_OWF.workflowEmailRecordWrapper();
            List<String> toEmailList;
            String emailOverallBodyContent;
            OWF_Generic_Setting__c additionalEmail = OWF_Generic_Setting__c.getValues(CON_OWF.BHR_OWF_NotificationToGCCBidHistoryOnStatusUpdate);
            toEmailList = new List<String>();
            emailOverallBodyContent = '';
            if(additionalEmail != null && additionalEmail.Value__c != null){
                toEmailList = (additionalEmail.Value__c).split(',');
            }
            workflowEmailRecordWrapperMessage.subject =  bidHistory.Bid_History_Number__c+' – Status changed to \''+bidHistory.Bid_History_Status__c+'\'';
            emailOverallBodyContent  = '<b>Bid History Number: </b>'+ (bidHistory.Bid_History_Number__c!= null ? bidHistory.Bid_History_Number__c : (''))+'<br>';
            emailOverallBodyContent += '<b>Bid History Name: </b>'+ (bidHistory.Name!= null ? bidHistory.Name : (''))+'<br>';
            emailOverallBodyContent += '<b>Bid Owner: </b>'+ (bidHistory.Owner.Name!= null ? bidHistory.Owner.name : (''))+'<br>';
            emailOverallBodyContent += '<b>Link to Bid: </b><span style = "font-weight: normal;"><a href = \'' + URL.getOrgDomainUrl().toExternalForm() + '/' + (bidHistory.id != null ? bidHistory.id : ('')) + '\'>' + (bidHistory.Name != null ? bidHistory.Name : ('')) + '</a></span><br>';
            workflowEmailRecordWrapperMessage.whatId = bidHistory.Id;
            workflowEmailRecordWrapperMessage.toEmails = toEmailList;
            workflowEmailRecordWrapperMessage.emailAction = CON_OWF.OWF_NotificationToGCCForStatusUpdate;
            workflowEmailRecordWrapperMessage.staticContent = emailOverallBodyContent;            
                       
        return workflowEmailRecordWrapperMessage;
    }
    
    
    
    public static UTL_OWF.workflowEmailRecordWrapper sendEmailForTechSolSupportforCreateRecord(Bid_History__c bidHistory){
        List<String> toEmailList;
        String emailOverallBodyContent;
        OWF_Generic_Setting__c additionalEmail = OWF_Generic_Setting__c.getValues(CON_OWF.BHR_OWF_NotificationToTechSolutionOnCreate);
        UTL_OWF.workflowEmailRecordWrapper workflowEmailRecordWrapperMessage;
        toEmailList = new List<String>();
        List<String> toCcEmailList = new List<String>();
        emailOverallBodyContent = '';
        if(additionalEmail != null && additionalEmail.Value__c != null){
            toEmailList = (additionalEmail.Value__c).split(',');
        }
        if(bidHistory.Opportunity_Owner_Email__c != null || bidHistory.Opportunity_Owner_Email__c != ''){
            toCcEmailList.add(bidHistory.Opportunity_Owner_Email__c);
        }
        workflowEmailRecordWrapperMessage = new UTL_OWF.workflowEmailRecordWrapper();
        workflowEmailRecordWrapperMessage.subject =(bidHistory.Bid_History_Account__r.Name != null ? bidHistory.Bid_History_Account__r.Name + ' - ' : ('')) +(bidHistory.Legacy_Quintiles_Opportunity_Number__c != null ? bidHistory.Legacy_Quintiles_Opportunity_Number__c + ' - ' : (''))+'New Tech Solutions request'+(bidHistory.Bid_Due_Date__c != null ?' - '+ bidHistory.Bid_Due_Date__c.format() : (''));
        emailOverallBodyContent = '<div>'+ (bidHistory.Bid_History_Related_Opportunity__r.Owner.name != null ? bidHistory.Bid_History_Related_Opportunity__r.Owner.name : ('')) +' has raised a New Tech Solutions Request<br><br>';
        emailOverallBodyContent += 'Opportunity Number: ' + (bidHistory.Opportunity_Number__c != null ? bidHistory.Opportunity_Number__c : (''))+'<br>';
        emailOverallBodyContent += 'Request Created date '+(bidHistory.CreatedDate != null ? bidHistory.CreatedDate.date().format() : (''))+'<br>';
        emailOverallBodyContent += 'Client Name : '+(bidHistory.Bid_History_Account__r.Name != null ? bidHistory.Bid_History_Account__r.Name : ('')) +'<br>';
        emailOverallBodyContent += 'Request Type: '+(bidHistory.Request_Type_RFP__c != null ? bidHistory.Request_Type_RFP__c : ('')) +'<br>';
        emailOverallBodyContent += 'Request Type SE: '+(bidHistory.Request_Type_SE__c != null ? bidHistory.Request_Type_SE__c : ('')) +'<br><br>';
        emailOverallBodyContent += '<b>Link to Bid Request: </b><span style = "font-weight: normal;"><a href = \'' + URL.getOrgDomainUrl().toExternalForm() + '/' + (bidHistory.id != null ? bidHistory.id : ('')) + '\'>' + (bidHistory.Name != null ? bidHistory.Name : ('')) + '</a></span><br>'; 
        workflowEmailRecordWrapperMessage.whatId = bidHistory.Id;
        workflowEmailRecordWrapperMessage.toEmails = toEmailList;
        workflowEmailRecordWrapperMessage.ccEmails = toCcEmailList;
        workflowEmailRecordWrapperMessage.emailAction = CON_OWF.BHR_OWF_22_NotificationToTechSolutionOnCreate;
        workflowEmailRecordWrapperMessage.staticContent = emailOverallBodyContent;            
        return workflowEmailRecordWrapperMessage;
    }
    
    public static UTL_OWF.workflowEmailRecordWrapper sendEmailForTechSolSupportforCreateRecordForSafetyTechnologies(Bid_History__c bidHistory){
        List<String> toEmailList;
        String emailOverallBodyContent;
        OWF_Generic_Setting__c additionalEmail = OWF_Generic_Setting__c.getValues(CON_OWF.BHR_OWF_NotificationToTechSolutionOnCreateWithSafetyTechnologies);
        UTL_OWF.workflowEmailRecordWrapper workflowEmailRecordWrapperMessage;
        List<UTL_OWF.workflowEmailRecordWrapper> workflowEmailRecordWrapperMessageList = new List<UTL_OWF.workflowEmailRecordWrapper>();
        toEmailList = new List<String>();
        List<String> toCcEmailList = new List<String>();
        emailOverallBodyContent = '';
        if(additionalEmail != null && additionalEmail.Value__c != null){
            toEmailList = (additionalEmail.Value__c).split(',');
        }
        if(bidHistory.Opportunity_Owner_Email__c != null || bidHistory.Opportunity_Owner_Email__c != ''){
            toCcEmailList.add(bidHistory.Opportunity_Owner_Email__c);
        }
        workflowEmailRecordWrapperMessage = new UTL_OWF.workflowEmailRecordWrapper();
        workflowEmailRecordWrapperMessage.subject =(bidHistory.Bid_History_Account__r.Name != null ? bidHistory.Bid_History_Account__r.Name + ' - ' : ('')) +(bidHistory.Bid_History_Related_Opportunity__r.Opportunity_Number__c != null ? bidHistory.Bid_History_Related_Opportunity__r.Opportunity_Number__c + ' - ' : (''))+'New Tech Solutions request';
        emailOverallBodyContent = '<div>'+ (bidHistory.Bid_History_Related_Opportunity__r.Owner.name != null ? bidHistory.Bid_History_Related_Opportunity__r.Owner.name : ('')) +' has raised a New Tech Solutions Request<br><br>';
        emailOverallBodyContent += 'Opportunity Number: ' + (bidHistory.Bid_History_Related_Opportunity__r.Opportunity_Number__c != null ? bidHistory.Bid_History_Related_Opportunity__r.Opportunity_Number__c : (''))+'<br>';
        emailOverallBodyContent += 'Opportunity Name : '+(bidHistory.Bid_History_Related_Opportunity__r.Name != null ? bidHistory.Bid_History_Related_Opportunity__r.Name : ('')) +'<br>';
        emailOverallBodyContent += 'Request Created date '+(bidHistory.CreatedDate != null ? bidHistory.CreatedDate.date().format() : (''))+'<br>';
        emailOverallBodyContent += 'Client Name : '+(bidHistory.Bid_History_Account__r.Name != null ? bidHistory.Bid_History_Account__r.Name : ('')) +'<br>';
        emailOverallBodyContent += 'System Implementation Type: '+(bidHistory.System_Implementation_Type__c != null ? bidHistory.System_Implementation_Type__c : ('')) +'<br>';
        emailOverallBodyContent += '<b>Link to Opportunity: </b><span style = "font-weight: normal;"><a href = \'' + URL.getOrgDomainUrl().toExternalForm() + '/' + (bidHistory.Bid_History_Related_Opportunity__r.id != null ? bidHistory.Bid_History_Related_Opportunity__r.id : ('')) + '\'>' + (bidHistory.Bid_History_Related_Opportunity__r.Name != null ? bidHistory.Bid_History_Related_Opportunity__r.Name : ('')) + '</a></span><br>';
        emailOverallBodyContent += '<b>Link to Bid History: </b><span style = "font-weight: normal;"><a href = \'' + URL.getOrgDomainUrl().toExternalForm() + '/' + (bidHistory.id != null ? bidHistory.id : ('')) + '\'>' + (bidHistory.Name != null ? bidHistory.Name : ('')) + '</a></span><br>';
        workflowEmailRecordWrapperMessage.whatId = bidHistory.Id;
        workflowEmailRecordWrapperMessage.toEmails = toEmailList;
        workflowEmailRecordWrapperMessage.ccEmails = toCcEmailList;
        workflowEmailRecordWrapperMessage.emailAction = CON_OWF.OWF_NotificationToTechSolutionOnCreateWithSafetyTechnologies;
        workflowEmailRecordWrapperMessage.staticContent = emailOverallBodyContent;
        return workflowEmailRecordWrapperMessage;
    }
    //IQVIAPSA-7058
    private static UTL_OWF.workflowEmailRecordWrapper sendQ2SolutionsBidAlertToRFPMailbox(Bid_History__c bidHistory){
        Map<String, String> bussniessAreaToRFPMailBox = new  Map<String, String>{CON_OWF.Q2_BUSINESS_AREA_VACCINES => CON_OWF.BHR_OWF_Q2SOLUTIONS_VACCINES_RFP_MAILBOX,
            																	CON_OWF.Q2_BUSINESS_AREA_BIOSCIENCE => CON_OWF.BHR_OWF_Q2SOLUTIONS_BIOSCEINCES_RFP_MAILBOX ,
            																	CON_OWF.Q2_BUSINESS_AREA_DISCOVERY + '-'+ CON_OWF.BUDGET_TOOL_PROTEIN_SCIENCES => CON_OWF.BHR_OWF_Q2SOLUTIONS_DISCOVERY_PROTEIN_SCIENCES_RFP_MAILBOX,
                                                                                CON_OWF.Q2_BUSINESS_AREA_DISCOVERY +'-'+ CON_OWF.BUDGET_TOOL_SPECIFICA => CON_OWF.BHR_OWF_Q2SOLUTIONS_DISCOVERY_SPECIFICA_RFP_MAILBOX,
                                                                                CON_OWF.Q2_BUSINESS_AREA_DISCOVERY +'-'+ CON_OWF.BUDGET_TOOL_IMMUN_XPERTS => CON_OWF.BHR_OWF_Q2SOLUTIONS_DISCOVERY_IMMUN_XPERTS_RFP_MAILBOX };
        List<String> toEmailList;
        String emailOverallBodyContent;
        OWF_Generic_Setting__c emails;
        UTL_OWF.workflowEmailRecordWrapper workflowEmailRecordWrapperMessage =  new UTL_OWF.workflowEmailRecordWrapper();
        toEmailList = new List<String>();
        emailOverallBodyContent = '';
        String key = bidHistory.Q2_Business_Area__c;
        if(bidHistory.Q2_Business_Area__c == CON_OWF.Q2_BUSINESS_AREA_DISCOVERY) {
            key += '-' + bidHistory.Q2_Budget_Tools__c;
        }
        if(bussniessAreaToRfpMailBox.containsKey(key)) {
            emails = OWF_Generic_Setting__c.getValues(bussniessAreaToRfpMailBox.get(key));
        } 
        if(emails != null && emails.Value__c != null){
            toEmailList = (emails.Value__c).split(',');
        }
        toEmailList.add(bidHistory.Opportunity_Owner_Email__c);
        workflowEmailRecordWrapperMessage.subject = 'Bid Type: ' + bidHistory.Bid_Type__c + ' - ' +  bidHistory.Legacy_Quintiles_Opportunity_Number__c + ' - ' + bidHistory.Opportunity_Name__c;
        string templateBody = '';
        if (bidHistory.Bid_Type__c == CON_OWF.BID_TYPE_CHANGE_ORDER){
            templateBody = getChangeOrderBioscienceBidEmailTemplate(bidHistory);
        }
        else{
            templateBody = getInitialBioscienceBidEmailTemplate(bidHistory);
        }
        workflowEmailRecordWrapperMessage.whatId = bidHistory.Id;
        workflowEmailRecordWrapperMessage.toEmails = toEmailList;
        workflowEmailRecordWrapperMessage.emailAction = CON_OWF.Q2SOLUTIONS_BIOSCEINCES_RFP_MAILBOX_EMAIL_ACTION;
        workflowEmailRecordWrapperMessage.staticContent = templateBody;
        return workflowEmailRecordWrapperMessage;
    }
    private static UTL_OWF.workflowEmailRecordWrapper sendEmailForQ2solutionsBidOwnerChange(Bid_History__c bidHistory){
        List<String> toEmailList = new List<String>();
        String subject = 'Assigned: Bid Type - ' + bidHistory.Bid_Type__c + ' - ' +  bidHistory.Legacy_Quintiles_Opportunity_Number__c + ' - ' + bidHistory.Opportunity_Name__c;
        UTL_OWF.workflowEmailRecordWrapper workflowEmailRecordWrapperMessage = new UTL_OWF.workflowEmailRecordWrapper();
        if(bidHistory.Opportunity_Owner_Email__c != null && bidHistory.Opportunity_Owner_Email__c != ''){
            toEmailList.add(bidHistory.Opportunity_Owner_Email__c);
        }
        String template= getBidOwnerChangeTemplate(bidHistory);
        
        workflowEmailRecordWrapperMessage.whatId = bidHistory.Id;
        workflowEmailRecordWrapperMessage.toEmails = toEmailList;
        workflowEmailRecordWrapperMessage.emailAction = CON_OWF.Q2SOLUTIONS_BIOSCEINCES_RFP_MAILBOX_EMAIL_ACTION;
        workflowEmailRecordWrapperMessage.subject = subject;
        workflowEmailRecordWrapperMessage.staticContent = template;
        return workflowEmailRecordWrapperMessage;
    }  
    private static UTL_OWF.workflowEmailRecordWrapper sendQ2SolutionsEmailNotificationOnStageChange(Bid_History__c bidHistory){
        List<String> toEmailList = new List<String>();
        String subject = bidHistory.Stage__c + ' : Bid Type - ' + bidHistory.Bid_Type__c + ' - ' +  bidHistory.Legacy_Quintiles_Opportunity_Number__c + ' - ' + bidHistory.Opportunity_Name__c ;
        UTL_OWF.workflowEmailRecordWrapper workflowEmailRecordWrapperMessage = new UTL_OWF.workflowEmailRecordWrapper();
        if(bidHistory.Opportunity_Owner_Email__c != null && bidHistory.Opportunity_Owner_Email__c != ''){
            toEmailList.add(bidHistory.Opportunity_Owner_Email__c);
        }
        String template= getChangeOrderStageChangeTemplate(bidHistory);
        
        workflowEmailRecordWrapperMessage.whatId = bidHistory.Id;
        workflowEmailRecordWrapperMessage.toEmails = toEmailList;
        workflowEmailRecordWrapperMessage.ownerId = bidHistory.OwnerId;
        workflowEmailRecordWrapperMessage.emailAction = CON_OWF.Q2SOLUTIONS_BIOSCEINCES_RFP_MAILBOX_EMAIL_ACTION;
        workflowEmailRecordWrapperMessage.subject = subject;
        workflowEmailRecordWrapperMessage.staticContent = template;
        return workflowEmailRecordWrapperMessage;
    } 
    private static UTL_OWF.workflowEmailRecordWrapper sendEmailForQ2solutionsBidSentDate(Bid_History__c bidHistory){       
        List<String> toEmailList = new List<String>();
        UTL_OWF.workflowEmailRecordWrapper workflowEmailRecordWrapperMessage = new UTL_OWF.workflowEmailRecordWrapper();
        if(bidHistory.Opportunity_Owner_Email__c != null && bidHistory.Opportunity_Owner_Email__c != ''){
            toEmailList.add(bidHistory.Opportunity_Owner_Email__c);
        }
        String subject = 'Sent: Bid Type - ' + bidHistory.Bid_Type__c + ' - ' +  bidHistory.Legacy_Quintiles_Opportunity_Number__c + ' - ' + bidHistory.Opportunity_Name__c ;        
        String template= getBidSentDateTemplate(bidHistory);
        
        workflowEmailRecordWrapperMessage.whatId = bidHistory.Id;
        workflowEmailRecordWrapperMessage.toEmails = toEmailList;
        workflowEmailRecordWrapperMessage.emailAction = CON_OWF.Q2SOLUTIONS_BIOSCEINCES_RFP_MAILBOX_EMAIL_ACTION;
        workflowEmailRecordWrapperMessage.subject = subject;
        workflowEmailRecordWrapperMessage.staticContent = template;
        return workflowEmailRecordWrapperMessage;
    }

    private static string getBidOwnerChangeTemplate(Bid_History__c bidHistory) {
        String emailOverallBodyContent=''; 
        String bidLink =  URL.getSalesforceBaseUrl().toExternalForm() + '/' + bidHistory.Id;
        List<String> emailBodyValues = new List<String> {
            '<a href=\'' + bidLink + '\'>'  + bidHistory.Name + '</a>',
            String.valueOf(bidHistory.Owner.Name)
            };
                 
        emailOverallBodyContent = 'This request has been assigned to : {1}<br/><br/>'+
                                  'Please ensure that, moving forward, any communications, completed reviews and additional information are shared with {1}<br/><br/>'+
                                  '<b>Bid History Link : </b> {0}<br/>';
                               
        
        
        return  String.format(emailOverallBodyContent, emailBodyValues);
        
    }
    private static string getBidSentDateTemplate(Bid_History__c bidHistory) {
        String emailOverallBodyContent=''; 
        String bidLink =  URL.getSalesforceBaseUrl().toExternalForm() + '/' + bidHistory.Id;
        String oppLink =  URL.getSalesforceBaseUrl().toExternalForm() + '/' + bidHistory.Bid_History_Related_Opportunity__c;
        List<String> emailBodyValues = new List<String> {
            bidHistory.Bid_Type__c,
            bidHistory.Opportunity_Name__c, 
            bidHistory.Opportunity_Account__c,
            bidHistory.Legacy_Quintiles_Opportunity_Number__c, 
            '<a href=\'' + bidLink + '\'>'  + bidHistory.Name + '</a>',
            '<a href=\'' + oppLink + '\'>'  + bidHistory.Opportunity_Name__c + '</a>',
            bidHistory.Bid_History_Related_Opportunity__r.Owner.Name,
            bidHistory.Bid_Sent_Date__c !=null?String.valueOf(bidHistory.Bid_Sent_Date__c):('')
        };
            
            emailOverallBodyContent = 'Dear {6}<br/>'+
            'The proposal has been SENT to the sponsor on : {7}<br/>'+
            'Bid Type: {0}<br/>'+
            'Opportunity Name: {1}<br/>'+
            'Account Name: {2}<br/>'+
            'Opportunity Number: {3}<br/>'+
            'Link to Bid History:  {4}<br/>'+
            'Link to Opportunity: {5}<br/>';
        
        return  String.format(emailOverallBodyContent, emailBodyValues);
        
    }
    
    private static string getChangeOrderStageChangeTemplate(Bid_History__c bidHistory) {
        String emailOverallBodyContent=''; 
        String bidLink =  URL.getSalesforceBaseUrl().toExternalForm() + '/' + bidHistory.Id;
        String oppLink =  URL.getSalesforceBaseUrl().toExternalForm() + '/' + bidHistory.Bid_History_Related_Opportunity__c;
        List<String> emailBodyValues = new List<String> {
            bidHistory.Bid_Type__c,
            bidHistory.Opportunity_Name__c, 
            bidHistory.Opportunity_Account__c,
            bidHistory.Legacy_Quintiles_Opportunity_Number__c, 
            '<a href=\'' + bidLink + '\'>'  + bidHistory.Name + '</a>',
            '<a href=\'' + oppLink + '\'>'  + bidHistory.Opportunity_Name__c + '</a>',
            bidHistory.Bid_History_Related_Opportunity__r.Owner.Name,
            bidHistory.Change_Order_Awarded_Date__c!=null?String.valueOf(bidHistory.Change_Order_Awarded_Date__c):(''),
            bidHistory.Change_Order_Sent_to_Customer_Date__c!=null?String.valueOf(bidHistory.Change_Order_Sent_to_Customer_Date__c):('')
            };
            
            emailOverallBodyContent = 'Dear {6}<br/>';
            emailOverallBodyContent +=  'The Change Order has been ' + (bidHistory.Stage__c).toUpperCase()  +' on '+(bidHistory.Stage__c == CON_OWF.BID_HISTORY_STAGE_SIGNED_FINALIZED ? +'{7}<br/>' : +'{8}<br/>');
            emailOverallBodyContent += 'Bid Type: {0}<br/>'+
            'Opportunity Name: {1}<br/>'+
            'Account Name: {2}<br/>'+
            'Opportunity Number: {3}<br/>'+
            'Link to Bid History:  {4}<br/>'+
            'Link to Opportunity: {5}<br/>';
        
        return  String.format(emailOverallBodyContent, emailBodyValues);
    }
   
    private static string getChangeOrderBioscienceBidEmailTemplate(Bid_History__c bidHistory) {
         String emailOverallBodyContent ='';
         String bidLink =  URL.getOrgDomainUrl().toExternalForm() + '/' + bidHistory.Id;
         String oppLink =  URL.getOrgDomainUrl().toExternalForm() + '/' + bidHistory.Bid_History_Related_Opportunity__c;
         List<String> emailBodyValues = new List<String> {
             bidHistory.Description_of_Scope__c,
             bidHistory.Opportunity_Name__c, 
             bidHistory.Opportunity_Account__c,
             bidHistory.Legacy_Quintiles_Opportunity_Number__c, 
             '<a href=\'' + bidLink + '\'>'  + bidHistory.Name + '</a>',
             '<a href=\'' + oppLink + '\'>'  + bidHistory.Opportunity_Name__c + '</a>',
             bidHistory.Phase__c,
             bidHistory.Indication__c, 
             String.valueOf(bidHistory.Change_Order_Due_Date__c),
             String.valueOf(bidHistory.Bid_Priority__c),
             String.valueOf(bidHistory.Questions_Due_Date__c),
             String.valueOf(bidHistory.CRO_Selection_Date__c),
             String.valueOf(bidHistory.Win_Probability__c),
             String.valueOf(bidHistory.Estimated_Fees__c),
             String.valueOf(bidHistory.createdBy.Name),
             String.valueOf(bidHistory.createdBy.Email),
             bidHistory.Bid_Type__c
             };
                        
            emailOverallBodyContent = 'Dear RFP Mailbox <br/><br/>'+
             'Bid Type: {16}<br/>'+
             'CO request from {14} &lt;{15}&gt;<br/>'+
             'Description of Scope: {0}<br/>'+
             'Opportunity Name: {1}<br/>'+
             'Account Name: {2}<br/>'+
             'Opportunity Number: {3}<br/>'+
             'Link to Bid History:  {4}<br/>'+
             'Link to Opportunity: {5}<br/>'+
             'Phase: {6}<br/>'+
             'Indication: {7}<br/>'+
             'Change Order Due Date: {8}<br/>'+
             'Bid Priority: <b>{9}</b><br/>'+
             'Questions Due Date: {10}<br/>'+
             'CRO selection Date: {11}<br/>'+
             'Win Probability %: {12}<br/>'+
             'Estimated Fees: {13}<br/><br/>'+            
             'Associated RFP Documents have been added to <a href=\'https://www.box.com/\'>box.com</a>.';
        
        return String.format(emailOverallBodyContent, emailBodyValues);
    }
    
    private static string getInitialBioscienceBidEmailTemplate(Bid_History__c bidHistory) {
        String emailOverallBodyContent = '';
        String bidLink =  URL.getOrgDomainUrl().toExternalForm() + '/' + bidHistory.Id;
        String oppLink =  URL.getOrgDomainUrl().toExternalForm() + '/' + bidHistory.Bid_History_Related_Opportunity__c;
        List<String> emailBodyValues = new List<String> {
            bidHistory.Opportunity_Name__c, 
            bidHistory.Opportunity_Account__c,
            bidHistory.Legacy_Quintiles_Opportunity_Number__c, 
            '<a href=\'' + bidLink + '\'>'  + bidHistory.Name + '</a>',
            '<a href=\'' + oppLink + '\'>'  + bidHistory.Opportunity_Name__c + '</a>',
            bidHistory.Phase__c,
            bidHistory.Indication__c, 
            String.valueOf(bidHistory.Bid_Due_Date__c),
            String.valueOf(bidHistory.Bid_Priority__c),
            String.valueOf(bidHistory.Questions_Due_Date__c),
            String.valueOf(bidHistory.Win_Probability__c), 
            String.valueOf(bidHistory.Estimated_Fees__c),
            bidHistory.Bid_Type__c
             };
                        
          emailOverallBodyContent = 'Dear RFP Mailbox <br/><br/>' +
              'Bid Type: {12}<br/>'+
              'Opportunity Name: {0}<br/>'+
              'Account Name: {1}<br/>'+
              'Opportunity Number: {2}<br/>'+
              'Link to Bid History:  {3}<br/>'+
              'Link to Opportunity: {4}<br/>'+
              'Phase: {5}<br/>'+
              'Indication: {6}<br/>'+
              'Bid Due Date: {7}<br/>'+
              'Bid Priority: <b>{8}</b><br/>'+
              'Questions Due Date: {9}<br/>'+
              'Win Probability %: {10}<br/>'+
              'Estimated Fees: {11}<br/><br/>'+            
              'Associated RFP Documents have been added to <a href=\'https://www.box.com/\'>box.com</a>.';
        
        return String.format(emailOverallBodyContent, emailBodyValues);
    }
    
    public static List<UTL_OWF.workflowEmailRecordWrapper> sendContractPostAwardBidEmailAlertBasedOnAgreementType(List<Bid_History__c> bidHistoryList){
        List<UTL_OWF.workflowEmailRecordWrapper> workflowEmailRecordWrapperMessageList = new List<UTL_OWF.workflowEmailRecordWrapper>();
        List<String> toEmailList = new List<String>();
        String emailOverallBodyContent;
        String requesterName;
        UTL_OWF.workflowEmailRecordWrapper workflowEmailRecordWrapperMessage;
        for(Bid_History__c bidHistory : bidHistoryList){
            toEmailList = new List<String>();
            emailOverallBodyContent = '';
            if(!bidHistory.Created_by_FormAssembly__c){
                toEmailList.add(bidHistory.CreatedBy.Email);
                requesterName = bidHistory.Owner.Name;
            }else{
                if(bidHistory.Requester_email__c != null){
                    toEmailList.add(bidHistory.Requester_email__c);
                }
                if(bidHistory.Project_Manager_Email__c != null){
                    toEmailList.add(bidHistory.Project_Manager_Email__c);
                }
                requesterName = bidHistory.Requester_email__c;
            }
            if(!toEmailList.isEmpty()){
	            workflowEmailRecordWrapperMessage = new UTL_OWF.workflowEmailRecordWrapper();
	            workflowEmailRecordWrapperMessage.subject = 'Creation of Agreement Request - ' + (bidHistory.Requested_Agreement_Type__c != null ? bidHistory.Requested_Agreement_Type__c : ('')) + ' - ' + (bidHistory.Legacy_Quintiles_Opportunity_Number__c != null ? bidHistory.Legacy_Quintiles_Opportunity_Number__c : ('')) + ' has successfully been requested. ';
	            emailOverallBodyContent = '<div>This email is to inform you that the following <b>'+ (bidHistory.Requested_Agreement_Type__c != null ? bidHistory.Requested_Agreement_Type__c : ('')) + ' '+'</b> request has been created.<br>';
	            emailOverallBodyContent += '<br>Agreement Name: ' + (bidHistory.Name != null ? bidHistory.Name : ('')) + '<br>';
	            emailOverallBodyContent += 'Opportunity Number: '  + (bidHistory.Legacy_Quintiles_Opportunity_Number__c != null ? bidHistory.Legacy_Quintiles_Opportunity_Number__c : ('')) + '<br>';
	            emailOverallBodyContent += 'Account Name: ' + (bidHistory.Bid_History_Account__r.Name != null ? bidHistory.Bid_History_Account__r.Name : ('')) +'<br>';
	            emailOverallBodyContent += 'Requester: ' + requesterName + '<br><br>';
	            emailOverallBodyContent += 'This agreement will be assigned to an owner to manage your request. You will receive a notification once an owner has been assigned.' + '<br><br>';
	            emailOverallBodyContent += '<b>REMINDER:</b> Please do not commit to a deliverable due date with a customer before agreement with the assigned owner. Be assured that the assigned owner will work with you to meet customer expectations to ensure successful execution of the contract.' + '<br><br>';
	            emailOverallBodyContent += '<b>Please Note:</b> For certain contract type requests submitted within the two weeks prior to quarter end, the assignment of new requests may be delayed due to end of quarter priorities.' + '<br>';
	            
	            workflowEmailRecordWrapperMessage.whatId = bidHistory.Id;
	            workflowEmailRecordWrapperMessage.toEmails = toEmailList;
	            workflowEmailRecordWrapperMessage.emailAction = CON_OWF.CONTRACT_POST_AWARD_BID_CREATION_EMAIL_ACTION;
	            workflowEmailRecordWrapperMessage.staticContent = emailOverallBodyContent;
	            workflowEmailRecordWrapperMessageList.add(workflowEmailRecordWrapperMessage);
	       }
        }  
        return workflowEmailRecordWrapperMessageList;
    }
    
    public static void sendEmailbyWorkflowEmailRecord(List<Bid_History__c> newList,Map<id, Bid_History__c> oldMap){
        Set<Id> sObjectIdSet = new Set<Id>();
        List<Bid_History__c> bidHistoryRecordsList = new List<Bid_History__c>();
        Map<id, Bid_History__c> q2SolutionsBidHistoryAdvionQuoteRequestedMap = new Map<id, Bid_History__c>();
        Map<id, Bid_History__c> q2SolutionsStrategicPricingInvolvedMap = new Map<id, Bid_History__c>();
        Map<id, Bid_History__c> q2SolutionsBidHistoryTriageNotificationExcludingMerckKGaAMap = new Map<id, Bid_History__c>();
        Map<id, Bid_History__c> q2SolutionsLevel1RankingAlertMap = new Map<id, Bid_History__c>();
        Map<id, Bid_History__c> q2SolutionsLevel2RankingAlertMap = new Map<id, Bid_History__c>();
        Map<id, Bid_History__c> q2SolutionsLevel3RankingAlertMap = new Map<id, Bid_History__c>();
        Map<id, Bid_History__c> q2SolutionsLevel4RankingAlertMap = new Map<id, Bid_History__c>();
        Map<id, Bid_History__c> q2LabBidHistoryScientificReviewMap = new Map<id, Bid_History__c>();
        Map<id, Bid_History__c> q2SolutionsStrategicPricingLeadAssignedMap = new Map<id, Bid_History__c>();
        Map<id, Bid_History__c> q2SolutionStrategicPricingAlertMap = new Map<id, Bid_History__c>();
        Map<id, Bid_History__c> q2SolutionBioFortisAlertMap = new Map<id, Bid_History__c>();
        Map<id, Bid_History__c> q2SolutionChinaLocalAlertMap = new Map<id, Bid_History__c>();
        Map<id, Bid_History__c> q2BidOwnerChangeAlertMap = new Map<id, Bid_History__c>();
        Map<id, Bid_History__c> q2SolutionSubmitToContractsMap = new Map<id, Bid_History__c>();
        Map<id, Bid_History__c> awardedBidHistoryMap = new Map<id, Bid_History__c>();
        List<Bid_History__c> postAwardEmailNotificationBasedOnAgreenentTypeList = new List<Bid_History__c>();
        List<Bid_History__c> readyToAwardBidHistoryList = new List<Bid_History__c>();
        List<UTL_OWF.workflowEmailRecordWrapper> workflowEmailRecordWrapperMessageList = new List<UTL_OWF.workflowEmailRecordWrapper>();
        
        for(Bid_History__c bidHistory : newList){
            if(bidHistory.RecordTypeId == CON_OWF.OWF_Q2_Solutions_BID_HISTORY_RECORD_TYPE_ID){
                sObjectIdSet.add(bidHistory.Id);
            }else if(bidHistory.RecordTypeId == CON_OWF.OWF_CONTRACT_POST_AWARD_BID_HISTORY_RECORD_TYPE_ID){
                sObjectIdSet.add(bidHistory.Id);
            }else if(bidHistory.RecordTypeId == CON_OWF.OWF_CLINICAL_BID_BID_HISTORY_RECORD_TYPE_ID){
                if(trigger.isUpdate && (bidHistory.Is_Study_Awarded__c != oldMap.get(bidHistory.id).Is_Study_Awarded__c && bidHistory.Is_Study_Awarded__c == 'Yes' 
                                        && (bidHistory.Related_Quote_Status__c == CON_OWF.BHR_OWF_RELATED_QUOTE_STATUS_NOT_READY_TO_AWARD || bidHistory.Related_Quote_Status__c == CON_OWF.BHR_OWF_RELATED_QUOTE_STATUS_READY_TO_AWARD))){
                    sObjectIdSet.add(bidHistory.Id);
                }
            }
            else if(bidHistory.RecordTypeId == CON_OWF.OWF_GCC_BID_HISTORY_RECORD_TYPE_ID){
                if(trigger.isUpdate && (bidHistory.Calls_Emails_Contacts_Monthly_Inbound__c != oldMap.get(bidHistory.id).Calls_Emails_Contacts_Monthly_Inbound__c 
                                        || bidHistory.Calls_Emails_Contacts_Monthly_Outbound__c != oldMap.get(bidHistory.id).Calls_Emails_Contacts_Monthly_Outbound__c 
                                        || bidHistory.Project_Duration_Months__c != oldMap.get(bidHistory.id).Project_Duration_Months__c)){
                                            sObjectIdSet.add(bidHistory.Id);
                                        }
                if(Trigger.isUpdate && bidHistory.Bid_History_Status__c  != oldMap.get(bidHistory.id).Bid_History_Status__c 
                        && (bidHistory.Bid_History_Status__c == CON_OWF.OWF_BID_HISTORY_STATUS_IN_PROGRESS_TRIAGE || bidHistory.Bid_History_Status__c == CON_OWF.OWF_BID_HISTORY_STATUS_IN_PROGRESS_ASSIGNED ||bidHistory.Bid_History_Status__c == CON_OWF.OWF_BID_HISTORY_STATUS_AWAITING_CUSTOMER_FEEDBACK)){
                           
                            sObjectIdSet.add(bidHistory.Id);
                }
                
            } 
            else if(bidHistory.RecordTypeId == CON_OWF.OWF_TECH_SOLUTIONS_SUPPORT_REQUEST_BID_HISTORY_RECORD_TYPE_ID && trigger.isInsert) {
                sObjectIdSet.add(bidHistory.Id);
            }
            else if(bidHistory.RecordTypeId == CON_OWF.OWF_RFI_BID_HISTORY_RECORD_TYPE_ID) {
                if(trigger.isUpdate && (((bidHistory.RFI_Due_Date__c!= null &&  bidHistory.IQVIA_technologies__c!= null)
                                         && (oldMap.get(bidHistory.id).RFI_Due_Date__c == null
                                             || oldMap.get(bidHistory.id).IQVIA_technologies__c == null)))
                   || (bidHistory.IQVIA_LABS_SPW_Support__c == 'Yes')){
                       sObjectIdSet.add(bidHistory.Id);
                   }
            }
            // Add Any New Reocrd Types To Send Email through Email Workflow Email Record
        }
        String whereclause = 'Id IN :sObjectIdSet';
        //Add New Custom Field To put in the Email Content
        Set<String> bhrFieldSet = (new Set<String>{'Opportunity_Account__c', 'Protocol_Number__c','Opportunity_Name__c','Opportunity_Number__c',
            'Opportunity_Owner__c','Bid_Due_Date__c', 'Drug_Name__c','Indication__c','Study_Phase__c','Expected_Project_Start_Date__c',
            'Is_there_an_existing_validated_method__c','Will_sponsor_request_development__c','Will_sponsor_transfer_method__c',
            'Bid_History_Related_Opportunity__r.Id','Bid_History_Related_Opportunity__r.Name','Bid_History_Account__r.Name',
            'RecordTypeId','Name','Bid_History_Related_Opportunity__r.Opportunity_Number__c','Bid_History_Related_Opportunity__r.Owner.Name',
            'CreatedBy.Email','CreatedBy.Name','Opportunity_Owner_Email__c','Science_Due_Date__c','Request_Type_RFP__c','Request_Type_SE__c',
            'Bid_Number__c','Scientific_Review__c','Assign_Proposal_Ranking__c','Is_a_Strategy_Call_Required__c',
            'Q2_BioSciences_Quote_Requested__c','Bid_History_Related_Opportunity__r.Q2_CTMS_Picklist__c',
            'Bid_History_Related_Opportunity__r.Owner_Email__c','Submit_to_Proposals__c','Q2_Business_Area__c','Strategic_Pricing_Involvement_Needed__c',
            'Owner.Email','OwnerId','Specific_budget_areas_requiring_review__c',
            'id','Requested_Services__c','Strategy_Call_Requirement__c','Supporting_Bid_Owner__c','Supporting_Bid_Owner_Deliverable__c','Proposal_Deliverable__c','Budget_Deliverable__c','Supporting_Bid_Owner__r.Email',
            'Owner.Name','Parent_Opportunity__c','Line_of_Business__c',
            'Patient_Duration_Months__c','OWF_Potential_Regions__c','Enrollement_Months__c','Pertinent_Details_Specific_Rebid_Request__c','Q2_Budget_Tools__c','Bid_Type__c','Date_Review_Requested__c',
            'Strategic_Pricing_Lead__c','Strategic_Pricing_Lead__r.Email','Bid_Owner_Email__c','Strategic_Pricing_Lead__r.Name','Bid_History_Related_Opportunity__c',
            'Submit_to_Contracts__c','Is_a_Strategy_Call_Required__c','Bid_History_Related_Opportunity__r.Phase__c','Bid_History_Related_Opportunity__r.TherapyArea__c','Bid_History_Related_Opportunity__r.Proposal_Due_Date__c',
            'Bid_History_Related_Opportunity__r.Indication__c','Q2_BioFortis_Quote_Needed__c','Bid_History_Related_Opportunity__r.OwnerId','Therapy_Area__c','Bid_History_Related_Opportunity__r.Potential_Regions__c',
			'Patients_Enrolled__c','Bid_History_Related_Opportunity__r.Presentation_Date__c','Bid_History_Related_Opportunity__r.FPI_Date__c','Science_Due_Date__c','Enrollement_Months__c','Testing_Comments__c','Legacy_Quintiles_Opportunity_Number__c','CreatedDate',
            'Owner.Name','Supporting_Bid_Owner__r.Name','Q2LAB_Sales_Comments_for_BioSciences__c','Study_Start_Date__c','Study_End_Date__c', 'Bid_Pre_Post_Award__c', 'Is_Study_Awarded__c', 'Related_Quote_Status__c', 'Link_to_Quote__c', 
            'Bid_Category__c', 'Bid_History_Related_Opportunity__r.Total_Project_Awarded_Price__c', 'Bid_History_Related_Opportunity__r.Will_be_Contracted_via_CO__c', 'Bid_History_Related_Opportunity__r.Primary_Win_Reason__c', 'Bid_History_Related_Opportunity__r.Primary_Win_Reason_Detail__c',
            'Phase__c', 'Bid_History_Related_Opportunity__r.Is_this_IQVIA_Biotech__c', 'Comments__c', 'Questions_Due_Date__c','Win_Probability__c','Estimated_Fees__c','Requester_email__c','Requested_Agreement_Type__c','Agreement_Pathway__c','Created_by_FormAssembly__c','CRO_Selection_Date__c','Description_of_Scope__c', 'Project_Manager_Email__c','Change_Order_Awarded_Date__c','Change_Order_Signed_Date__c','Change_Order_Sent_to_Customer_Date__c','Stage__c','RFP_Assigned_Date__c','Bid_Priority__c','Change_Order_Due_Date__c','Bid_Sent_Date__c' , 'Bid_Sent__c',
            'Calls_Emails_Contacts_Monthly_Inbound__c','Calls_Emails_Contacts_Monthly_Outbound__c','Project_Duration_Months__c', 'Safety_Technologies__c', 'System_Implementation_Type__c', 'Engage__c', 'GFMS__c', 'ITR__c', 'OCE_Content__c', 'OCE_Digital__c', 'OCE_Optimizer__c', 'OCE_Personal__c', 'OneKey__c', 'Other__c', 'RIM_Smart__c', 'SmartSolve__c', 'Strategic_Meetings_Events__c', 'Safety_Technologies__c', 'IQVIA_technologies__c','RFI_Due_Date__c','RFI_Request_Type__c','Client_Deliverable_What_is_the_client_s__c','Bid_History_Status__c','Bid_History_Number__c', 'IQVIA_LABS_SPW_Support__c'});
        if(!sObjectIdSet.isEmpty()){
            bidHistoryRecordsList = new SLT_Bid_History(false, false).getBidHistoriesByCondition(bhrFieldSet, whereClause, sObjectIdSet);   
        }
        if(bidHistoryRecordsList != null && bidHistoryRecordsList.size() > 0){
            for(Bid_History__c bidHistory : bidHistoryRecordsList){
                // Add New Check For Any Custom Record Type 
                if(bidHistory.RecordTypeId == CON_OWF.OWF_Q2_Solutions_BID_HISTORY_RECORD_TYPE_ID && (trigger.IsInsert || (trigger.isUpdate && (bidHistory.Submit_to_Proposals__c != oldMap.get(bidHistory.id).Submit_to_Proposals__c || bidHistory.Q2_BioSciences_Quote_Requested__c != oldMap.get(bidHistory.id).Q2_BioSciences_Quote_Requested__c ))) && bidHistory.Submit_to_Proposals__c == CON_OWF.OWF_BID_HISTORY_SUBMIT_TO_PROPOSALS_TRUE && bidHistory.Q2_BioSciences_Quote_Requested__c == CON_OWF.OWF_YES){
                    q2SolutionsBidHistoryAdvionQuoteRequestedMap.put(bidHistory.id, bidHistory);
                }
                if(bidHistory.RecordTypeId == CON_OWF.OWF_Q2_Solutions_BID_HISTORY_RECORD_TYPE_ID && 
                   (trigger.IsInsert || (trigger.isUpdate && 
                                         (bidHistory.Submit_to_Proposals__c != oldMap.get(bidHistory.id).Submit_to_Proposals__c 
                                          || bidHistory.Q2_Business_Area__c != oldMap.get(bidHistory.id).Q2_Business_Area__c
                                          || (bidHistory.Q2_Budget_Tools__c != oldMap.get(bidHistory.id).Q2_Budget_Tools__c && bidHistory.Q2_Budget_Tools__c == CON_OWF.Q2_BUDGET_TOOLS_RNPS_NURSE)
                                          || (bidHistory.Proposal_Deliverable__c != oldMap.get(bidHistory.id).Proposal_Deliverable__c && bidHistory.Proposal_Deliverable__c == CON_OWF.STRATEGIC_PROPOSAL_WRITER_TEXT))))
                   && bidHistory.Submit_to_Proposals__c == CON_OWF.OWF_BID_HISTORY_SUBMIT_TO_PROPOSALS_TRUE 
                   && bidHistory.Q2_Business_Area__c == CON_OWF.Q2_BUSINESS_AREA){
                    q2SolutionsBidHistoryTriageNotificationExcludingMerckKGaAMap.put(bidHistory.id, bidHistory);
                } 
                if(bidHistory.RecordTypeId == CON_OWF.OWF_Q2_Solutions_BID_HISTORY_RECORD_TYPE_ID && (trigger.IsInsert || (trigger.isUpdate && bidHistory.Strategic_Pricing_Involvement_Needed__c != oldMap.get(bidHistory.id).Strategic_Pricing_Involvement_Needed__c )) && bidHistory.Strategic_Pricing_Involvement_Needed__c == CON_OWF.OWF_YES){
                    q2SolutionsStrategicPricingInvolvedMap.put(bidHistory.id, bidHistory);
                }
                if(bidHistory.RecordTypeId == CON_OWF.OWF_Q2_Solutions_BID_HISTORY_RECORD_TYPE_ID && bidHistory.Assign_Proposal_Ranking__c == CON_OWF.ASSIGN_PROPOSAL_RANKING_LEVEL_1 && bidHistory.Q2_Business_Area__c == CON_OWF.Q2_BUSINESS_AREA){
                    if(trigger.isUpdate && bidHistory.OwnerId != oldMap.get(bidHistory.id).OwnerId){
                        q2SolutionsLevel1RankingAlertMap.put(bidHistory.id, bidHistory);
                    }
                }
                if(bidHistory.RecordTypeId == CON_OWF.OWF_Q2_Solutions_BID_HISTORY_RECORD_TYPE_ID && bidHistory.Assign_Proposal_Ranking__c == CON_OWF.ASSIGN_PROPOSAL_RANKING_LEVEL_2 && bidHistory.Q2_Business_Area__c == CON_OWF.Q2_BUSINESS_AREA){
                    if(trigger.isUpdate && bidHistory.OwnerId != oldMap.get(bidHistory.id).OwnerId){
                        q2SolutionsLevel2RankingAlertMap.put(bidHistory.id, bidHistory);
                    }
                }
                if(bidHistory.RecordTypeId == CON_OWF.OWF_Q2_Solutions_BID_HISTORY_RECORD_TYPE_ID && bidHistory.Assign_Proposal_Ranking__c == CON_OWF.ASSIGN_PROPOSAL_RANKING_LEVEL_3 && bidHistory.Q2_Business_Area__c == CON_OWF.Q2_BUSINESS_AREA){
                    if(trigger.isUpdate && bidHistory.OwnerId != oldMap.get(bidHistory.id).OwnerId){
                        q2SolutionsLevel3RankingAlertMap.put(bidHistory.id, bidHistory);
                    }
                }
                if(bidHistory.RecordTypeId == CON_OWF.OWF_Q2_Solutions_BID_HISTORY_RECORD_TYPE_ID && bidHistory.Assign_Proposal_Ranking__c == CON_OWF.ASSIGN_PROPOSAL_RANKING_LEVEL_4 && bidHistory.Q2_Business_Area__c == CON_OWF.Q2_BUSINESS_AREA){
                    if(trigger.isUpdate && bidHistory.OwnerId != oldMap.get(bidHistory.id).OwnerId){
                        q2SolutionsLevel4RankingAlertMap.put(bidHistory.id, bidHistory);
                    }
                }                
                if(bidHistory.RecordTypeId == CON_OWF.OWF_Q2_Solutions_BID_HISTORY_RECORD_TYPE_ID && (trigger.IsInsert || (trigger.isUpdate && ( bidHistory.Q2_Business_Area__c != oldMap.get(bidHistory.id).Q2_Business_Area__c || bidHistory.Scientific_Review__c != oldMap.get(bidHistory.id).Scientific_Review__c || bidHistory.Submit_to_Proposals__c != oldMap.get(bidHistory.id).Submit_to_Proposals__c ))) && bidHistory.Q2_Business_Area__c == CON_OWF.Q2_BUSINESS_AREA && (bidHistory.Scientific_Review__c == CON_OWF.OWF_YES || bidHistory.Scientific_Review__c == CON_OWF.SCIENTIFIC_REVIEW_YES_POST_AWARD_REBID_WITH_SR) && bidHistory.Submit_to_Proposals__c == CON_OWF.OWF_BID_HISTORY_SUBMIT_TO_PROPOSALS_TRUE){
                    q2LabBidHistoryScientificReviewMap.put(bidHistory.id, bidHistory);															  
                }
                if(bidHistory.RecordTypeId == CON_OWF.OWF_Q2_Solutions_BID_HISTORY_RECORD_TYPE_ID && (trigger.IsInsert || (trigger.isUpdate && ( bidHistory.Q2_Business_Area__c != oldMap.get(bidHistory.id).Q2_Business_Area__c || bidHistory.Strategic_Pricing_Lead__c != oldMap.get(bidHistory.id).Strategic_Pricing_Lead__c ))) && bidHistory.Strategic_Pricing_Lead__c != null && bidHistory.Q2_Business_Area__c == CON_OWF.Q2_BUSINESS_AREA){
                    q2SolutionsStrategicPricingLeadAssignedMap.put(bidHistory.id, bidHistory);
                } 
                if(bidHistory.RecordTypeId == CON_OWF.OWF_Q2_Solutions_BID_HISTORY_RECORD_TYPE_ID && (trigger.IsInsert || (trigger.isUpdate && bidHistory.Strategic_Pricing_Lead__c != oldMap.get(bidHistory.id).Strategic_Pricing_Lead__c )) && bidHistory.Strategic_Pricing_Lead__c != null){
                    q2SolutionStrategicPricingAlertMap.put(bidHistory.id, bidHistory);
                } 
                if(bidHistory.RecordTypeId == CON_OWF.OWF_Q2_Solutions_BID_HISTORY_RECORD_TYPE_ID && (trigger.IsInsert || (trigger.isUpdate && bidHistory.Submit_to_Contracts__c != oldMap.get(bidHistory.id).Submit_to_Contracts__c )) && bidHistory.Submit_to_Contracts__c == true){
                    q2SolutionSubmitToContractsMap.put(bidHistory.id, bidHistory);
                }
                if(bidHistory.RecordTypeId == CON_OWF.OWF_Q2_Solutions_BID_HISTORY_RECORD_TYPE_ID && bidHistory.Q2_BioFortis_Quote_Needed__c == true && bidHistory.Submit_to_Proposals__c == CON_OWF.SUBMIT_TO_PROPOSALS_TRUE){
                    if(trigger.isUpdate && bidHistory.OwnerId != oldMap.get(bidHistory.id).OwnerId){
                        q2SolutionBioFortisAlertMap.put(bidHistory.id, bidHistory);
                    }
                }
                if(bidHistory.RecordTypeId == CON_OWF.OWF_Q2_Solutions_BID_HISTORY_RECORD_TYPE_ID && bidHistory.Scientific_Review__c == CON_OWF.SCIENTIFIC_REVIEW_CLS && bidHistory.Submit_to_Proposals__c == CON_OWF.SUBMIT_TO_PROPOSALS_TRUE){
                    if(trigger.isInsert || (trigger.isUpdate && (bidHistory.Scientific_Review__c != oldMap.get(bidHistory.id).Scientific_Review__c  || bidHistory.Submit_to_Proposals__c != oldMap.get(bidHistory.id).Submit_to_Proposals__c))){
                        q2SolutionChinaLocalAlertMap.put(bidHistory.id, bidHistory);
                    }
                }
                if(bidHistory.RecordTypeId == CON_OWF.OWF_Q2_Solutions_BID_HISTORY_RECORD_TYPE_ID && bidHistory.Submit_to_Proposals__c == CON_OWF.SUBMIT_TO_PROPOSALS_TRUE){
                    if(trigger.isUpdate && !CON_OWF.Q2_BUSINESS_AREA_LIST.contains(bidHistory.Q2_Business_Area__c) && (bidHistory.OwnerId != oldMap.get(bidHistory.id).OwnerId || bidHistory.Supporting_Bid_Owner__c != oldMap.get(bidHistory.Id).Supporting_Bid_Owner__c) && String.ValueOf(bidHistory.OwnerId).startsWith('005') ){
                        q2BidOwnerChangeAlertMap.put(bidHistory.id, bidHistory);
                    }
                }   
                if(bidHistory.RecordTypeId == CON_OWF.OWF_CLINICAL_BID_BID_HISTORY_RECORD_TYPE_ID){
                    if(trigger.isUpdate && (bidHistory.Is_Study_Awarded__c != oldMap.get(bidHistory.id).Is_Study_Awarded__c && bidHistory.Is_Study_Awarded__c == 'Yes' 
                                            && bidHistory.Related_Quote_Status__c == CON_OWF.BHR_OWF_RELATED_QUOTE_STATUS_NOT_READY_TO_AWARD)){
                                                awardedBidHistoryMap.put(bidHistory.id, bidHistory);
                    }
                }
                if(bidHistory.RecordTypeId == CON_OWF.OWF_CLINICAL_BID_BID_HISTORY_RECORD_TYPE_ID){
                    if(trigger.isUpdate && (bidHistory.Is_Study_Awarded__c != oldMap.get(bidHistory.id).Is_Study_Awarded__c && bidHistory.Is_Study_Awarded__c == 'Yes' 
                                            && bidHistory.Related_Quote_Status__c == CON_OWF.BHR_OWF_RELATED_QUOTE_STATUS_READY_TO_AWARD)){
                                                readyToAwardBidHistoryList.add(bidHistory);
                    }
                }
                if(bidHistory.RecordTypeId == CON_OWF.OWF_Q2_Solutions_BID_HISTORY_RECORD_TYPE_ID && CON_OWF.Q2_BUSINESS_AREA_LIST.contains(bidHistory.Q2_Business_Area__c)){
                    workflowEmailRecordWrapperMessageList.addAll(sendQ2solutionsEmailNotifications(bidHistory , oldMap));
                }
                if(bidHistory.RecordTypeId == CON_OWF.OWF_CONTRACT_POST_AWARD_BID_HISTORY_RECORD_TYPE_ID && trigger.IsInsert &&
                   (CON_OWF.CONTRACT_POST_AWARD_AGREEMENT_PATHWAY_Set.contains(bidHistory.Agreement_Pathway__c))){
                       postAwardEmailNotificationBasedOnAgreenentTypeList.add(bidHistory);
                }
                if(bidHistory.RecordTypeId == CON_OWF.OWF_GCC_BID_HISTORY_RECORD_TYPE_ID && (trigger.isUpdate && (bidHistory.Calls_Emails_Contacts_Monthly_Inbound__c != oldMap.get(bidHistory.id).Calls_Emails_Contacts_Monthly_Inbound__c 
                                                                                                                  || bidHistory.Calls_Emails_Contacts_Monthly_Outbound__c != oldMap.get(bidHistory.id).Calls_Emails_Contacts_Monthly_Outbound__c 
                                                                                                                  || bidHistory.Project_Duration_Months__c != oldMap.get(bidHistory.id).Project_Duration_Months__c))){
                                                                                                                      workflowEmailRecordWrapperMessageList.add(sendEmailForGCCforFieldUpdate(bidHistory , oldMap));
                                                                                                                  }                                                                                  
                if(bidHistory.RecordTypeId == CON_OWF.OWF_TECH_SOLUTIONS_SUPPORT_REQUEST_BID_HISTORY_RECORD_TYPE_ID && trigger.isInsert
                   && (bidHistory.Engage__c || bidHistory.GFMS__c || bidHistory.ITR__c || bidHistory.OCE_Content__c
                       || bidHistory.OCE_Digital__c || bidHistory.OCE_Optimizer__c || bidHistory.OCE_Personal__c
                       || bidHistory.OneKey__c || bidHistory.Other__c || bidHistory.RIM_Smart__c
                       || bidHistory.SmartSolve__c || bidHistory.Strategic_Meetings_Events__c)) {
                           workflowEmailRecordWrapperMessageList.add(sendEmailForTechSolSupportforCreateRecord(bidHistory));
                       }
                if(bidHistory.RecordTypeId == CON_OWF.OWF_TECH_SOLUTIONS_SUPPORT_REQUEST_BID_HISTORY_RECORD_TYPE_ID && trigger.isInsert && bidHistory.Safety_Technologies__c) {
                    workflowEmailRecordWrapperMessageList.add(sendEmailForTechSolSupportforCreateRecordForSafetyTechnologies(bidHistory));
                }
                if(bidHistory.RecordTypeId == CON_OWF.OWF_RFI_BID_HISTORY_RECORD_TYPE_ID
                   && ((bidHistory.RFI_Due_Date__c!= null && bidHistory.IQVIA_technologies__c!= null)
                       && (oldMap.get(bidHistory.id).RFI_Due_Date__c == null 
                           || oldMap.get(bidHistory.id).IQVIA_technologies__c == null))) {
                               workflowEmailRecordWrapperMessageList.add(sendEmailForRFIRequestToIQVIATeam(bidHistory));
                           }
                if(bidHistory.RecordTypeId == CON_OWF.OWF_RFI_BID_HISTORY_RECORD_TYPE_ID
                   && oldMap.get(bidHistory.id).IQVIA_LABS_SPW_Support__c != 'Yes' && bidHistory.IQVIA_LABS_SPW_Support__c == 'Yes') {
                               workflowEmailRecordWrapperMessageList.add(sendEmailForRFIRequestIQVIALABSSPWSupport(bidHistory));
                           }
                
                if(bidHistory.RecordTypeId == CON_OWF.OWF_GCC_BID_HISTORY_RECORD_TYPE_ID && Trigger.isUpdate && bidHistory.Bid_History_Status__c  != oldMap.get(bidHistory.id).Bid_History_Status__c 
                   && (bidHistory.Bid_History_Status__c == CON_OWF.OWF_BID_HISTORY_STATUS_IN_PROGRESS_TRIAGE || bidHistory.Bid_History_Status__c == CON_OWF.OWF_BID_HISTORY_STATUS_IN_PROGRESS_ASSIGNED ||bidHistory.Bid_History_Status__c == CON_OWF.OWF_BID_HISTORY_STATUS_AWAITING_CUSTOMER_FEEDBACK)){
                       
                       workflowEmailRecordWrapperMessageList.add(sendEmailForGCCforBHRStatusUpdate(bidHistory , oldMap));
                                                                                                                  }                                                                                  
            }
        }
        
        if(q2SolutionsBidHistoryAdvionQuoteRequestedMap != null && !q2SolutionsBidHistoryAdvionQuoteRequestedMap.isEmpty()){
            workflowEmailRecordWrapperMessageList.addAll(sendEmailForQ2SolutionsBidHistoryAdvionQuoteRequested(q2SolutionsBidHistoryAdvionQuoteRequestedMap));
        }
        if(q2SolutionsStrategicPricingInvolvedMap != null && !q2SolutionsStrategicPricingInvolvedMap.isEmpty()){
            workflowEmailRecordWrapperMessageList.addAll(sendEmailForQ2SolutionsStrategicPricingInvolved(q2SolutionsStrategicPricingInvolvedMap));
        }
        if(q2SolutionsBidHistoryTriageNotificationExcludingMerckKGaAMap != null && !q2SolutionsBidHistoryTriageNotificationExcludingMerckKGaAMap.isEmpty()){
            workflowEmailRecordWrapperMessageList.addAll(sendEmailForQ2SolutionsBidHistoryTriageNotificationExcludingMerckKGaA(q2SolutionsBidHistoryTriageNotificationExcludingMerckKGaAMap));
        }
        if(q2SolutionsLevel1RankingAlertMap != null && !q2SolutionsLevel1RankingAlertMap.isEmpty()){
            workflowEmailRecordWrapperMessageList.addAll(sendEmailForQ2SolutionsLevel1RankingAlert(q2SolutionsLevel1RankingAlertMap));
        }
        if(q2SolutionsLevel2RankingAlertMap != null && !q2SolutionsLevel2RankingAlertMap.isEmpty()){
            workflowEmailRecordWrapperMessageList.addAll(sendEmailForQ2SolutionsLevel2RankingAlert(q2SolutionsLevel2RankingAlertMap));
        }
        if(q2SolutionsLevel3RankingAlertMap != null && !q2SolutionsLevel3RankingAlertMap.isEmpty()){
            workflowEmailRecordWrapperMessageList.addAll(sendEmailForQ2SolutionsLevel3RankingAlert(q2SolutionsLevel3RankingAlertMap));
        }
        if(q2SolutionsLevel4RankingAlertMap != null && !q2SolutionsLevel4RankingAlertMap.isEmpty()){
            workflowEmailRecordWrapperMessageList.addAll(sendEmailForQ2SolutionsLevel4RankingAlert(q2SolutionsLevel4RankingAlertMap));
        }
        if(q2LabBidHistoryScientificReviewMap != null && !q2LabBidHistoryScientificReviewMap.isEmpty()){
            workflowEmailRecordWrapperMessageList.addAll(sendEmailForQ2LabBidHistoryScientificReview(q2LabBidHistoryScientificReviewMap));
        }
        if(q2SolutionsStrategicPricingLeadAssignedMap != null && !q2SolutionsStrategicPricingLeadAssignedMap.isEmpty()){
            workflowEmailRecordWrapperMessageList.addAll(sendEmailForQ2SolutionsStrategicPricingLeadAssigned(q2SolutionsStrategicPricingLeadAssignedMap));
        }
        if(q2SolutionStrategicPricingAlertMap != null && !q2SolutionStrategicPricingAlertMap.isEmpty()){
            workflowEmailRecordWrapperMessageList.addAll(sendEmailForQ2SolutionStrategicPricingAlert(q2SolutionStrategicPricingAlertMap));
        }
        if(q2SolutionSubmitToContractsMap != null && !q2SolutionSubmitToContractsMap.isEmpty()){
            workflowEmailRecordWrapperMessageList.addAll(sendEmailForQ2SolutionSubmitToContracts(q2SolutionSubmitToContractsMap));
        }
        if(q2SolutionBioFortisAlertMap != null && !q2SolutionBioFortisAlertMap.isEmpty()){
            workflowEmailRecordWrapperMessageList.addAll(sendEmailForQ2BioFortisAlert(q2SolutionBioFortisAlertMap));
        }
        if(q2SolutionChinaLocalAlertMap != null && !q2SolutionChinaLocalAlertMap.isEmpty()){
            workflowEmailRecordWrapperMessageList.addAll(sendEmailForQ2ChinaLocalSolutionAlert(q2SolutionChinaLocalAlertMap));
        }
        if(q2BidOwnerChangeAlertMap != null && !q2BidOwnerChangeAlertMap.isEmpty()){
            workflowEmailRecordWrapperMessageList.addAll(sendEmailForQ2BidOwnerChange(q2BidOwnerChangeAlertMap));
        }
        if(awardedBidHistoryMap != null && !awardedBidHistoryMap.isEmpty()){
            workflowEmailRecordWrapperMessageList.addAll(sendEmailForAwardedBidHistoryAlert(awardedBidHistoryMap));
        }
        if(readyToAwardBidHistoryList != null && !readyToAwardBidHistoryList.isEmpty()){
            workflowEmailRecordWrapperMessageList.addAll(sendEmailForReadyToAwardedBidHistoryAlert(readyToAwardBidHistoryList));
        }
        if(!postAwardEmailNotificationBasedOnAgreenentTypeList.isEmpty()){
            workflowEmailRecordWrapperMessageList.addAll(sendContractPostAwardBidEmailAlertBasedOnAgreementType(postAwardEmailNotificationBasedOnAgreenentTypeList));
       }
        
        if(workflowEmailRecordWrapperMessageList.size()>0){
            UTL_OWF.sendEmailByWorkflowEmailRecord(workflowEmailRecordWrapperMessageList);
        }
        
    }
    public static void populateRFPAssignedDate(List<Bid_History__c> newList, Map<id, Bid_History__c> oldMap){
        for(Bid_History__c bidHistory : newList){
            if(bidHistory.RecordTypeId == CON_OWF.OWF_CSS_BID_BID_HISTORY_RECORD_TYPE_ID && bidHistory.OwnerId != null
               && bidHistory.OwnerId != oldMap.get(bidHistory.id).OwnerId){
                   bidHistory.RFP_Assigned_Date__c = Datetime.now();
               }
        } 
    }
    
    public static void populateRelatedQuoteStatusForAwardeded(List<Bid_History__c> newList, Map<Id, Bid_History__c> oldMap){
        List<String> budgetToolsList = new List<String>();
        
        for(Bid_History__c bidHistoryRecord : newList){
            if(bidHistoryRecord.RecordTypeId == CON_OWF.OWF_CLINICAL_BID_BID_HISTORY_RECORD_TYPE_ID
               && (trigger.isInsert || (trigger.isUpdate && bidHistoryRecord.Budget_Tools__c != oldMap.get(bidHistoryRecord.Id).Budget_Tools__c))){
                   //updating Related_Quote_Status__c for only insert when Budget_Tools__c is blank
                   if(trigger.isInsert && String.isBlank(bidHistoryRecord.Budget_Tools__c)){
                       bidHistoryRecord.Related_Quote_Status__c = CON_OWF.BHR_OWF_RELATED_QUOTE_STATUS_NO_QUOTE_CREATED;
                   }else{
                       //updating Related_Quote_Status__c for both insert/update when Budget_Tools__c not blank
                       if(!String.isBlank(bidHistoryRecord.Budget_Tools__c)){
                           budgetToolsList = bidHistoryRecord.Budget_Tools__c.split(';');
                       }
                       if(budgetToolsList.size() == 1 && (budgetToolsList.contains(CON_OWF.BHR_OWF_BUDGET_TOOLS_UNIT_PRICING_TOOL) || budgetToolsList.contains(CON_OWF.BHR_OWF_BUDGET_TOOLS_LCS_UPT))){
                           bidHistoryRecord.Related_Quote_Status__c = CON_OWF.BHR_OWF_RELATED_QUOTE_STATUS_NO_QUOTE_CREATED;
                       }else{
                           bidHistoryRecord.Related_Quote_Status__c = CON_OWF.BHR_OWF_RELATED_QUOTE_STATUS_NO_QUOTE_REQUIRED;
                       }
                   }
               }
        }
    }

    /*public static void validateTotalEffectiveDiscount(List<Bid_History__c> newList, Map<Id, Bid_History__c> oldMap){
        String totalEffectiveDiscountString;
        List<String> totalEffectiveDiscountSplitList;
        Decimal convertToDecimal;
        if(Trigger.IsUpdate && Trigger.IsBefore){
            for(Bid_History__c bidHistory : newList){
                try {
                    if(bidHistory.Total_Effective_Discount__c != null && bidHistory.Total_Effective_Discount__c != oldMap.get(bidHistory.id).Total_Effective_Discount__c){
                        convertToDecimal = Double.valueOf(bidHistory.Total_Effective_Discount__c);
                        if(convertToDecimal >= -999.99 && convertToDecimal <= 999.99 && convertToDecimal.scale() <=2){
                               totalEffectiveDiscountString = String.ValueOf(bidHistory.Total_Effective_Discount__c);
                               if(totalEffectiveDiscountString.contains('-') || totalEffectiveDiscountString.contains('+')){
                                   totalEffectiveDiscountString = totalEffectiveDiscountString.replace('+','');
                                   totalEffectiveDiscountString = totalEffectiveDiscountString.replace('-','');
                               }
                               totalEffectiveDiscountSplitList = totalEffectiveDiscountString.split('\\.');
                               if(totalEffectiveDiscountSplitList != null && totalEffectiveDiscountSplitList.size() > 0 && totalEffectiveDiscountSplitList[0].length() >3){
                                   bidHistory.addError('Please enter only numeric values (in the format xxx.xx)');
                               }
                           }else{
                               bidHistory.addError('Please enter only numeric values (in the format xxx.xx)');
                           }
                    }   
                }catch(Exception ex) {
                    bidHistory.addError('Please enter only numeric values (in the format xxx.xx)');
                }
            }
        } 
    }*/

    public static void createResourceRequestsOnContractPostAwardBid(List<Bid_History__c> newList,Map<id, Bid_History__c> oldMap){
        Set<Id> bidHistoryIdSet = new Set<Id>();
        for(Bid_History__c bidHistory : newList){
            if(bidHistory.recordTypeId == CON_OWF.OWF_CONTRACT_POST_AWARD_BID_HISTORY_RECORD_TYPE_ID 
               && (bidHistory.Requested_Services__c != oldMap.get(bidHistory.Id).Requested_Services__c
                   || bidHistory.Requested_Agreement_Type__c != oldMap.get(bidHistory.Id).Requested_Agreement_Type__c)){
                       bidHistoryIdSet.add(bidHistory.Id);
            }
        }
        if(bidHistoryIdSet.size() > 0){
            Set<String> projFieldSet = new Set<String>{'Id','Bid_History__c','pse__Group__c'};
            Map<Id, pse__Proj__c> projectIdToProjectMap = new SLT_Project(false,false).getProjectByBidHistoryID(bidHistoryIdSet,projFieldSet);
            Map<Id, pse__Proj__c> bidHistoryIdToProjectMap = new Map<Id, pse__Proj__c>();
            for(Id projectId : projectIdToProjectMap.keySet()){
                bidHistoryIdToProjectMap.put(projectIdToProjectMap.get(projectId).Bid_History__c,projectIdToProjectMap.get(projectId));
            }
        	List<pse__Resource_Request__c> resReqs = UTL_OWF.createRRForContractPostAwardBid(bidHistoryIdSet,bidHistoryIdToProjectMap);
            insert resReqs;
        }
    }
    
    public static void populateFieldsForGCCBidHistory(List<Bid_History__c> newList, Map<Id, Bid_History__c> oldMap){
        Map<String, String> rfpDeliverableToRfpRankingMap = (new Map<String, String>{
            CON_OWF.OWF_BID_HISTORY_RFP_DELIVERABLES_HIGH_LEVEL_COST => CON_OWF.OWF_BID_HISTORY_RFP_RANKING_LEVEL1,
                CON_OWF.OWF_BID_HISTORY_RFP_DELIVERABLES_SUMM_OF_GCC_CAP => CON_OWF.OWF_BID_HISTORY_RFP_RANKING_LEVEL1,
                CON_OWF.OWF_BID_HISTORY_RFP_DELIVERABLES_ABBR_RFP_COST_BRK_AND_SUMM => CON_OWF.OWF_BID_HISTORY_RFP_RANKING_LEVEL2,
                CON_OWF.OWF_BID_HISTORY_RFP_DELIVERABLES_FULL_RFP_COMP_TXT_AND_COST_BRK => CON_OWF.OWF_BID_HISTORY_RFP_RANKING_LEVEL3
                });
        Map<String, String> rfpRankingToStandardGCCTurnaroundTImeBDMap = (new Map<String, String>{
            CON_OWF.OWF_BID_HISTORY_RFP_RANKING_LEVEL1 => CON_OWF.OWF_BID_HISTORY_STANDARD_TURNAROUND_TIME_BD_5_BUSINESS_DAYS,
                CON_OWF.OWF_BID_HISTORY_RFP_RANKING_LEVEL2 => CON_OWF.OWF_BID_HISTORY_STANDARD_TURNAROUND_TIME_BD_7_BUSINESS_DAYS,
                CON_OWF.OWF_BID_HISTORY_RFP_RANKING_LEVEL3 => CON_OWF.OWF_BID_HISTORY_STANDARD_TURNAROUND_TIME_BD_10_BUSINESS_DAYS
                });
        
        for(Bid_History__c agreement : newList) {
            if(agreement.RecordTypeId == CON_OWF.OWF_GCC_SHORT_FORM_BID_HISTORY_RECORD_TYPE_ID || agreement.RecordTypeId == CON_OWF.OWF_GCC_BID_HISTORY_RECORD_TYPE_ID){
                if((Trigger.isInsert || (Trigger.isUpdate && agreement.Bid_History_Status__c != oldMap.get(agreement.Id).Bid_History_Status__c))
                   && agreement.Bid_History_Status__c == CON_OWF.OWF_BID_HISTORY_STATUS_AWAITING_CUSTOMER_FEEDBACK){
                       agreement.Bid_Sent_Date__c = Date.Today();
                   }
                
                if((Trigger.isInsert || (Trigger.isUpdate && agreement.Bid_History_Status__c != oldMap.get(agreement.Id).Bid_History_Status__c))
                   && agreement.Bid_History_Status__c == CON_OWF.OWF_BID_HISTORY_STATUS_IN_PROGRESS_ASSIGNED){
                       agreement.RFP_Assigned_Date__c = Datetime.now();
                   }
                
                if(((Trigger.isInsert && agreement.RFP_Deliverables__c != null) || (Trigger.isUpdate && agreement.RFP_Deliverables__c != oldMap.get(agreement.Id).RFP_Deliverables__c))
                   && rfpDeliverableToRfpRankingMap.containsKey(agreement.RFP_Deliverables__c)){
                       agreement.RFP_Ranking__c = rfpDeliverableToRfpRankingMap.get(agreement.RFP_Deliverables__c);
                   }
                
                if(((Trigger.isInsert && agreement.RFP_Ranking__c != null) || (Trigger.isUpdate && agreement.RFP_Ranking__c != oldMap.get(agreement.Id).RFP_Ranking__c))
                   && rfpRankingToStandardGCCTurnaroundTImeBDMap.containsKey(agreement.RFP_Ranking__c)){
                       agreement.Standard_Turnaround_Time_BD__c = rfpRankingToStandardGCCTurnaroundTImeBDMap.get(agreement.RFP_Ranking__c);
                   }
                if(Trigger.isInsert && agreement.Standard_Turnaround_Time_BD__c != NULL && agreement.Bid_Requested_Date__c != NULL){
                        agreement.Standard_Submission_Date__c = getAdjustedDateAccToWorkingDays(agreement.Bid_Requested_Date__c,Integer.valueOf((agreement.Standard_Turnaround_Time_BD__c).split(' ')[0]));
                }
                if(((Trigger.isInsert && (agreement.One_Off_Fees_For_Service_Implementation__c != null|| agreement.One_Off_Fees_For_Phone_Line_Impl__c != null
                                          || agreement.Pass_Through_Cost_Translator_Service_Est__c != null || agreement.Running_Service_Fees_Exc_Translation__c != null))
                    || (Trigger.isUpdate && (agreement.One_Off_Fees_For_Service_Implementation__c != oldMap.get(agreement.Id).One_Off_Fees_For_Service_Implementation__c
                                             || agreement.One_Off_Fees_For_Phone_Line_Impl__c != oldMap.get(agreement.Id).One_Off_Fees_For_Phone_Line_Impl__c
                                             || agreement.Pass_Through_Cost_Translator_Service_Est__c != oldMap.get(agreement.Id).Pass_Through_Cost_Translator_Service_Est__c
                                             || agreement.Running_Service_Fees_Exc_Translation__c != oldMap.get(agreement.Id).Running_Service_Fees_Exc_Translation__c)))){
                                                 agreement.Total_Bid_Value_Labor_Direct_Discount__c = (agreement.One_Off_Fees_For_Service_Implementation__c != null ? agreement.One_Off_Fees_For_Service_Implementation__c : 0)
                                                     + (agreement.One_Off_Fees_For_Phone_Line_Impl__c != null ? agreement.One_Off_Fees_For_Phone_Line_Impl__c : 0)
                                                     + (agreement.Pass_Through_Cost_Translator_Service_Est__c != null ? agreement.Pass_Through_Cost_Translator_Service_Est__c : 0)
                                                     + (agreement.Running_Service_Fees_Exc_Translation__c != null ? agreement.Running_Service_Fees_Exc_Translation__c : 0);
                                             }
            }
        }
    }
    
    public static void populateFieldsForContractPostAwardBid(List<Bid_History__c> newList, Map<Id, Bid_History__c> oldMap){
        Set<Id> sObjectIdSet = new Set<Id>();
        Set<Id> oppIdSet = new Set<Id>();
        Map<Id, Bid_History__c> oppIdToBidHistoryMap = new Map<Id, Bid_History__c>();
        Set<String> bhrFieldSet = (new Set<String>{'Budget_Tools__c', 'Bid_History_Related_Opportunity__c', 'Bid_Number__c', 'Is_Study_Awarded__c'});
        for(Bid_History__c bidHistoryRecord : newList){
            if(bidHistoryRecord.RecordTypeId == CON_OWF.OWF_CONTRACT_POST_AWARD_BID_HISTORY_RECORD_TYPE_ID && bidHistoryRecord.Created_by_FormAssembly__c == true && bidHistoryRecord.Bid_Number__c > 1 ){
                sObjectIdSet.add(bidHistoryRecord.Bid_History_Related_Opportunity__c);
            }
            if(bidHistoryRecord.RecordTypeId == CON_OWF.OWF_CONTRACT_POST_AWARD_BID_HISTORY_RECORD_TYPE_ID) {
                oppIdSet.add(bidHistoryRecord.Bid_History_Related_Opportunity__c);
            }
        }
        if(!sObjectIdSet.isEmpty()){
            String whereclause = 'Bid_History_Related_Opportunity__c IN : sObjectIdSet AND RecordTypeId = \'' +CON_OWF.OWF_CONTRACT_POST_AWARD_BID_HISTORY_RECORD_TYPE_ID+ '\'';
            List<Bid_History__c> bidHistoryRecordsList = new SLT_Bid_History(false, false).getBidHistoryByOppOrderByField(sObjectIdSet,bhrFieldSet, whereClause,'CreatedDate');
            for(Bid_History__c bidHistoryRecord : bidHistoryRecordsList){
                if(!oppIdToBidHistoryMap.containsKey(bidHistoryRecord.Bid_History_Related_Opportunity__c)){
                    oppIdToBidHistoryMap.put(bidHistoryRecord.Bid_History_Related_Opportunity__c, bidHistoryRecord);
                }
            }
            for(Bid_History__c bidHistoryRecord : newList){
                if(oppIdToBidHistoryMap.containsKey(bidHistoryRecord.Bid_History_Related_Opportunity__c)){
                    bidHistoryRecord.Budget_Tools__c = oppIdToBidHistoryMap.get(bidHistoryRecord.Bid_History_Related_Opportunity__c).Budget_Tools__c;
                }            
            }    
        }
        if(!oppIdSet.isEmpty()) {
            String whereClause = 'Bid_History_Related_Opportunity__c IN : sObjectIdSet AND RecordTypeId = \'' +CON_OWF.OWF_CLINICAL_BID_BID_HISTORY_RECORD_TYPE_ID+ '\'';
            List<Bid_History__c> bidHistoryRecordsList = new SLT_Bid_History(false, false).getBidHistoryByOppOrderByField(oppIdSet,bhrFieldSet, whereClause,'Bid_Number__c');
            Map<Id,Bid_History__c> oppIdToBidMap = New Map<Id,Bid_History__c>();
            for(Bid_History__c bid : bidHistoryRecordsList) {
                if(!oppIdToBidMap.containsKey(bid.Bid_History_Related_Opportunity__c)) {
                    oppIdToBidMap.put(bid.Bid_History_Related_Opportunity__c,bid);
                }
                else{
                    if(bid.Is_Study_Awarded__c == CON_OWF.IS_STUDY_AWARDED_YES) {
                        oppIdToBidMap.put(bid.Bid_History_Related_Opportunity__c,bid);
                    }
                }
            }
            for(Bid_History__c bidHistoryRecord : newList){
                if(oppIdToBidMap.containsKey(bidHistoryRecord.Bid_History_Related_Opportunity__c)){
                    bidHistoryRecord.Latest_Awarded_Bid__c  = oppIdToBidMap.get(bidHistoryRecord.Bid_History_Related_Opportunity__c).Id;
                }
            }
        }
    }

    public static void processQ2SolutionsBid(List<Bid_History__c> newList, Map<Id, Bid_History__c> oldMap) {
        List<Bid_History__c> bidsToProcess = new List<Bid_History__c>();
        Set<Id> sObjectIdSet = new Set<Id>();
        for(Bid_History__c bid : newList) {
            if(bid.RecordTypeId == CON_OWF.OWF_Q2_Solutions_BID_HISTORY_RECORD_TYPE_ID && CON_OWF.Q2_BUSINESS_AREA_LIST.contains(bid.Q2_Business_Area__c)){
                bidsToProcess.add(bid);
                sObjectIdSet.add(bid.Bid_History_Related_Opportunity__c);
            }
        }
        if(!bidsToProcess.isEmpty()) {
            if(oldMap != null ){
                q2BioScienceBidTypeValidateOnUpdate(bidsToProcess, oldMap , sObjectIdSet);
            }
            else{
                q2BioSciencesBidTypeValidateOnInsert(bidsToProcess, sObjectIdSet);
                q2BioScienceOppCureencyFieldPopulateOnInsert(bidsToProcess, sObjectIdSet);

            }
            q2RequestedTurnAroundTimeFieldUpdate(bidsToProcess,oldMap);
        }
    }  
    
    private static void q2BioScienceBidTypeValidateOnUpdate(List<Bid_History__c> newList, Map<Id, Bid_History__c> oldMap,  Set<Id> sObjectIdSet){     
        
        List<Bid_History__c> bidsToBeValidated = new List<Bid_History__c>();
        for(Bid_History__c bidHistoryRecord : newList){
            if(bidHistoryRecord.Bid_Type__c != oldMap?.get(bidHistoryRecord.Id).Bid_Type__c){
                bidHistoryRecord.addError('You can not change the bid type.');                
            }
            if(bidHistoryRecord.Bid_Type__c == CON_OWF.BID_TYPE_CHANGE_ORDER && bidHistoryRecord.Study_Number__c != oldMap.get(bidHistoryRecord.Id).Study_Number__c){               
                bidsToBeValidated.add(bidHistoryRecord);
            }
        }
        
        if(!bidsToBeValidated.isEmpty()) {
            Map<Id, Map<String, Bid_History__c>> oppTobidHistoryMap = getLatestBidHistory(sObjectIdSet, oldMap);
            for(Bid_History__c bid : bidsToBeValidated) {
                Map<String, Bid_History__c> bidHistoryTypeMap = oppTobidHistoryMap?.get(bid.Bid_History_Related_Opportunity__c);
                if(!bidHistoryTypeMap.isEmpty()  &&  bid.Study_Number__c < bidHistoryTypeMap.values()[0]?.Study_Number__c){
                    bid.addError('The number of Quote Sections should be more than or equal to the previous bid');
                }
            }
        }
    }
    
    private static void q2BioSciencesBidTypeValidateOnInsert(List<Bid_History__c> newList, Set<Id> sObjectIdSet){  
        Set<String> changeOrderStageToBeValidate = new Set<String>{CON_OWF.BID_HISTORY_STAGE_SIGNED_FINALIZED, CON_OWF.BID_HISTORY_STAGE_TERMINATED};
        Map<Id, Map<String, Bid_History__c>> oppTobidHistoryMap = getLatestBidHistory(sObjectIdSet,null);
        Set<String> oppFieldSet = (new Set<String>{'Full_Service__c','StageName','Name'});
        Map<Id, Opportunity> oppMap = new SLT_Opportunity(false, false).getOpportunityById(oppTobidHistoryMap.keySet(),oppFieldSet); 
        
        for(Bid_History__c bidHistoryRecord : newList) {
            Opportunity oppty =  oppMap.get(bidHistoryRecord.Bid_History_Related_Opportunity__c);  
            Map<String, Bid_History__c> bidHistoryTypeMap = oppTobidHistoryMap?.get(oppty.Id);
            
            if(oppty!=null){
                String bidName = bidHistoryRecord.Bid_Type__c + ' - ' + oppty.Name;
                bidHistoryRecord.Name = bidName.left(80); 
            }
            Boolean isOpportuntiyAwarded = oppty?.StageName==CON_CRM.CLOSED_WON_STAGE
                ||(oppty?.StageName== CON_CRM.FINALIZING_DEAL_STAGE &&
                   oppty?.Full_Service__c=='Yes');                    
            if(isOpportuntiyAwarded) {
                if(bidHistoryRecord.Bid_Type__c != CON_OWF.BID_TYPE_CHANGE_ORDER) {
                    bidHistoryRecord.addError('You cannot create an initial or rebid if the opportunity is awarded');
                }
                else {
                    if(bidHistoryTypeMap.containsKey(CON_OWF.BID_TYPE_CHANGE_ORDER) && !changeOrderStageToBeValidate.contains(bidHistoryTypeMap?.get(CON_OWF.BID_TYPE_CHANGE_ORDER)?.Stage__c)){
                        bidHistoryRecord.addError('Existing Change order has not been Signed/Finalized/Terminated, please review existing change order stage');	
                    }
                    if(!bidHistoryTypeMap.isEmpty() && bidHistoryRecord.Study_Number__c < bidHistoryTypeMap.values()[0]?.Study_Number__c){
                        bidHistoryRecord.addError('The number of Quote Sections should be more than or equal to the previous bid');
                    }
                    
                }
            }
            else {
                
                if(bidHistoryRecord.Bid_Type__c == CON_OWF.BID_TYPE_RE_BID && !bidHistoryTypeMap?.containsKey(CON_OWF.BID_TYPE_INITIAL)){
                    bidHistoryRecord.addError('Rebid cant be created without initial bid. Please create initial bid first');	
                }
                if(bidHistoryRecord.Bid_Type__c == CON_OWF.BID_TYPE_INITIAL  && bidHistoryTypeMap?.containsKey(CON_OWF.BID_TYPE_INITIAL)){
                    bidHistoryRecord.addError('An existing bid is already available, create a rebid instead initial bid.');	
                }
                
                if(bidHistoryRecord.Bid_Type__c == CON_OWF.BID_TYPE_CHANGE_ORDER) {
                    bidHistoryRecord.addError('You cannot create a change order as the opportunity is not yet awarded');
                }
            }                
        }
    }
    private static void q2BioScienceOppCureencyFieldPopulateOnInsert(List<Bid_History__c> newList, Set<Id> sObjectIdSet){
        for(Bid_History__c bidHistoryRecord : newList){
            bidHistoryRecord.CurrencyIsoCode = bidHistoryRecord.Current_Opportunity_Currency__c ;
        }
    }

    public static void populateChangeOrderAmount(List<Bid_History__c> newList, Map<Id, Bid_History__c> oldMap){
        List<Bid_History__c> bidsToUpdate = new List<Bid_History__c>();
        Set<Id> sObjectIdSet = new Set<Id>();
        // Decimal convertedQuoteTotalNetAmount ;  
        for(Bid_History__c bid : newList) {
            if(bid.RecordTypeId == CON_OWF.OWF_Q2_Solutions_BID_HISTORY_RECORD_TYPE_ID &&
                CON_OWF.Q2_BUSINESS_AREA_LIST.contains(bid.Q2_Business_Area__c) &&
                bid.Bid_Type__c == CON_OWF.BID_TYPE_CHANGE_ORDER &&
                (oldMap == null ||(bid.Stage__c != oldMap.get(bid.Id).Stage__c &&
                                  (bid.Stage__c == CON_OWF.BID_HISTORY_STAGE_SIGNED_FINALIZED ||
                                   bid.Stage__c == CON_OWF.BID_HISTORY_STAGE_SENT))))
            {
                bidsToUpdate.add(bid);
                sObjectIdSet.add(bid.Bid_History_Related_Opportunity__c);
            }          
        }
        if(bidsToUpdate.size()>0){
            Map<String,Map<Id, Quote__c>> lastAcceptedAndFinalizeQuote = UTL_OWF.getLastAcceptedAndFinalizeQuote(sObjectIdSet);
            Map<Id,Quote__c> latestAcceptedQuote = new  Map<Id,Quote__c>();
            Decimal convertedQuoteTotalNetAmount ;          
            for(Bid_History__c bidHistoryRecord : bidsToUpdate) {
                if(bidHistoryRecord.Stage__c== CON_OWF.BID_HISTORY_STAGE_SENT){
                    latestAcceptedQuote =  lastAcceptedAndFinalizeQuote?.get(CON_CPQ.APPROVED);
                }
                else{
                    latestAcceptedQuote =  lastAcceptedAndFinalizeQuote?.get(CON_CPQ.ACCEPTED);
                }
                if(oldMap==null){
                    if(latestAcceptedQuote?.get(bidHistoryRecord.Bid_History_Related_Opportunity__c)?.TotalNetAmount__c!=null){
                        convertedQuoteTotalNetAmount = UTL_OWF.getConversionQuoteTotalNetAmount(bidHistoryRecord.Current_Opportunity_Currency__c,latestAcceptedQuote.get(bidHistoryRecord.Bid_History_Related_Opportunity__c));         
                        bidHistoryRecord.Previous_value_for_Contract__c = convertedQuoteTotalNetAmount;
                    }
                    else{
                        bidHistoryRecord.Previous_value_for_Contract__c = bidHistoryRecord.Opportunity_Value__c;
                    }
                }
                else{
                    if(latestAcceptedQuote?.get(bidHistoryRecord.Bid_History_Related_Opportunity__c)?.TotalNetAmount__c!=null){
                        convertedQuoteTotalNetAmount = UTL_OWF.getConversionQuoteTotalNetAmount(bidHistoryRecord.Current_Opportunity_Currency__c,latestAcceptedQuote.get(bidHistoryRecord.Bid_History_Related_Opportunity__c));         
                        bidHistoryRecord.Change_Order_Amount__c = convertedQuoteTotalNetAmount - bidHistoryRecord.Previous_value_for_Contract__c;
                    }
                    else{
                        bidHistoryRecord.Change_Order_Amount__c = 0;
                    }  
                    
                }
            }
        }
    }

    private static Map<Id, Map<String, Bid_History__c>> getLatestBidHistory(Set<Id> sObjectIdSet ,  Map<Id, Bid_History__c> oldMap){
        Set<String> bhrFieldSet = (new Set<String>{'Id','Stage__c','Study_Number__c','Bid_Type__c','Q2_Business_Area__c', 'Bid_History_Related_Opportunity__c', 'Bid_Number__c'});
        Map<Id, Map<String, Bid_History__c>> bidHistoryTypeMap = new Map<Id, Map<String, Bid_History__c>>();      
        if(!sObjectIdSet.isEmpty()){           
            String whereclause = 'Bid_History_Related_Opportunity__c IN : sObjectIdSet AND Q2_Business_Area__c IN ' + CON_OWF.Q2_BUSINESS_AREA_LIST_SOQL + ' AND RecordTypeId = \'' +CON_OWF.OWF_Q2_Solutions_BID_HISTORY_RECORD_TYPE_ID+ '\'';
            List<Bid_History__c> bidHistoryRecordsList = new SLT_Bid_History(false, false).getBidHistoryByOppOrderByField(sObjectIdSet,bhrFieldSet, whereClause,'CreatedDate');
            
            if(!bidHistoryRecordsList.isEmpty()){ 
                for(Bid_History__c bidHistoryRecord : bidHistoryRecordsList){
                    Id opportunityId = bidHistoryRecord.Bid_History_Related_Opportunity__c;
                    // Check if the outer map already contains the Opportunity ID
                    if (opportunityId != null && !bidHistoryTypeMap.containsKey(opportunityId)) {
                        bidHistoryTypeMap.put(opportunityId, new Map<String, Bid_History__c>());
                    }
                    if((oldMap == null || !oldMap.containsKey(bidHistoryRecord.Id)) && bidHistoryRecord.Bid_Type__c!=null && !bidHistoryTypeMap.get(opportunityId).containsKey(bidHistoryRecord.Bid_Type__c)) {
                           bidHistoryTypeMap.get(opportunityId).put(bidHistoryRecord.Bid_Type__c, bidHistoryRecord);                            
                       }
                    }
            }
            for(Id oppId : sobjectIdSet){
                if (!bidHistoryTypeMap.containsKey(oppId)) {
                    bidHistoryTypeMap.put(oppId, new Map<String, Bid_History__c>());
                }
            }
        }       
        return bidHistoryTypeMap ; 
    }
      
    public static void populateStandardSubmissionDate(List<Bid_History__c> newList, Map<Id, Bid_History__c> oldMap){
        for (Bid_History__c bid : newList) {
            if(bid.recordTypeId == CON_OWF.OWF_Q2_Solutions_BID_HISTORY_RECORD_TYPE_ID && bid.Q2_Business_Area__c == CON_OWF.Q2_BUSINESS_AREA){
                if(bid.Bid_Number__c!= null) {
                    Integer bidHistoryNumber = Integer.valueof(bid.Bid_Number__c);
                    if (bidHistoryNumber == 1) {
                        bid.Standard_Submission_Date__c = addBusinessDays(Date.today(), 10);
                    }
                    else if (bidHistoryNumber > 1 || bid.Bid_Pre_Post_Award__c == CON_OWF.BID_PRE_POST_AWARD) {
                        bid.Standard_Submission_Date__c = addBusinessDays(Date.today(), 5);
                    }
                    checkStandardSubmissionDate(bid);
                }
            }
        }
    }
    public static void checkStandardSubmissionDateOnAfterUpdate(List<Bid_History__c> newList) {
        for (Bid_History__c bid : newList) {
            if(bid.recordTypeId == CON_OWF.OWF_Q2_Solutions_BID_HISTORY_RECORD_TYPE_ID && bid.Q2_Business_Area__c == CON_OWF.Q2_BUSINESS_AREA){
                if(bid.Bid_Number__c!= null) {
                    checkStandardSubmissionDate(bid);
                }
            }
        }
    }
    public static void checkStandardSubmissionDate(Bid_History__c bid){
        if (bid.Bid_Due_Date__c < bid.Standard_Submission_Date__c) {
            if(bid.Reason_for_short_TAT__c == null){
                Date dt = (Date)bid.Standard_Submission_Date__c;
                bid.Reason_for_short_TAT__c.adderror('Please select reason for Short TAT as Bid Due Date is less than Standard Submission Date ('+dt.format()+')');
            }
            if(Bid.Notes__c == null){
                bid.Notes__c.adderror('Please enter additional info for Short TAT');
            }
        }
    }
    private static Date addBusinessDays(Date startDate, Integer businessDays) {
        DateTime currentDate = startDate; 
        while (businessDays >= 0) { 
            currentDate = currentDate.addDays(1); 
            if (currentDate.format('E') != 'Sat' && currentDate.format('E') != 'Sun') {
                businessDays--; 
            } 
        } 
        return currentDate.date(); 
    }
    public static void createResourceRequestsOnCSSBid(List<Bid_History__c> newList,Map<id, Bid_History__c> oldMap){
        Set<Id> bidHistoryIdSet = new Set<Id>();
        for(Bid_History__c bidHistory : newList){
            if(bidHistory.recordTypeId == CON_OWF.OWF_CSS_BID_BID_HISTORY_RECORD_TYPE_ID && (bidHistory.Connected_Devices__c != oldMap.get(bidHistory.Id).Connected_Devices__c && bidHistory.Connected_Devices__c)){
                       bidHistoryIdSet.add(bidHistory.Id);
                   }
        }
        if(bidHistoryIdSet.size() > 0){	
            Set<String> projFieldSet = new Set<String>{'Id','Bid_History__c','pse__Group__c'};
                Map<Id, pse__Proj__c> projectIdToProjectMap = new SLT_Project(false,false).getProjectByBidHistoryID(bidHistoryIdSet,projFieldSet);
            Map<Id, pse__Proj__c> bidHistoryIdToProjectMap = new Map<Id, pse__Proj__c>();
            for(Id projectId : projectIdToProjectMap.keySet()){
                bidHistoryIdToProjectMap.put(projectIdToProjectMap.get(projectId).Bid_History__c,projectIdToProjectMap.get(projectId));
            }
            List<pse__Resource_Request__c> resReqs = UTL_OWF.createRRForCSSBid(bidHistoryIdSet,bidHistoryIdToProjectMap);
            insert resReqs;
        }
    }
    public static UTL_OWF.workflowEmailRecordWrapper sendEmailForRFIRequestToIQVIATeam(Bid_History__c bidHistory) {
        List<String> toEmailList;
        String emailOverallBodyContent;
        OWF_Generic_Setting__c additionalEmail = OWF_Generic_Setting__c.getValues(CON_OWF.BHR_OWF_NotificationFromRFIToIQVIATeam);
        UTL_OWF.workflowEmailRecordWrapper workflowEmailRecordWrapperMessage;
        toEmailList = new List<String>();
        List<String> toCcEmailList = new List<String>();
        emailOverallBodyContent = '';
        if(additionalEmail != null && additionalEmail.Value__c != null){
            toEmailList = (additionalEmail.Value__c).split(',');
        } 
        workflowEmailRecordWrapperMessage = new UTL_OWF.workflowEmailRecordWrapper();
        workflowEmailRecordWrapperMessage.subject = 'IQVIA Technologies RFI Request'+ ' - ' +(bidHistory.Bid_History_Account__r.Name != null ? bidHistory.Bid_History_Account__r.Name + ' - ' : '') + (bidHistory.Legacy_Quintiles_Opportunity_Number__c != null ? bidHistory.Legacy_Quintiles_Opportunity_Number__c + '' : (''))+ ' ' + (bidHistory.RFI_Due_Date__c != null ? ' - ' + bidHistory.RFI_Due_Date__c.format() : ''); 
        emailOverallBodyContent = '<div> An RFI request has been created <br><br>';
        emailOverallBodyContent += '<b> Account Name </b>: '+(bidHistory.Bid_History_Account__r.Name != null ? bidHistory.Bid_History_Account__r.Name : ('')) +'<br>';
        emailOverallBodyContent += '<b> Opportunity Name: </b>'+(bidHistory.Bid_History_Related_Opportunity__r.Name != null ? bidHistory.Bid_History_Related_Opportunity__r.Name : ('')) +'<br>';
        emailOverallBodyContent += '<b> Opportunity Number: </b>' + (bidHistory.Legacy_Quintiles_Opportunity_Number__c != null ? bidHistory.Legacy_Quintiles_Opportunity_Number__c : ('') != null ? bidHistory.Legacy_Quintiles_Opportunity_Number__c : (''))+'<br><br>';
        emailOverallBodyContent += '<b> IQVIA Technologies Products: </b>' + (bidHistory.IQVIA_technologies__c != null ? bidHistory.IQVIA_technologies__c : (''))+'<br>';
        emailOverallBodyContent += '<b> RFI Request Type: </b>'+(bidHistory.RFI_Request_Type__c != null ? bidHistory.RFI_Request_Type__c : ('')) +'<br>';
        emailOverallBodyContent += '<b> RFI Due Date: </b>' + (bidHistory.RFI_Due_Date__c != null ? bidHistory.RFI_Due_Date__c.format() : '') + '<br>';
        emailOverallBodyContent += '<b> Client Deliverable: </b>'+(bidHistory.Client_Deliverable_What_is_the_client_s__c != null ? bidHistory.Client_Deliverable_What_is_the_client_s__c : ('')) +'<br><br>';
        emailOverallBodyContent += '<b> RFI Details:</b><br>';
        emailOverallBodyContent += '<b> Link to RFI Request: </b><span style = "font-weight: normal;"><a href = \'' + URL.getOrgDomainUrl().toExternalForm() + '/' + (bidHistory.id != null ? bidHistory.id : ('')) + '\'>' + (bidHistory.Name != null ? bidHistory.Name : ('')) + '</a></span><br>';
        emailOverallBodyContent += '<b> Link to Opportunity: </b><span style = "font-weight: normal;"><a href = \'' + URL.getOrgDomainUrl().toExternalForm() + '/' + (bidHistory.Bid_History_Related_Opportunity__r.id != null ? bidHistory.Bid_History_Related_Opportunity__r.id : ('')) + '\'>' + (bidHistory.Bid_History_Related_Opportunity__r.Name != null ? bidHistory.Bid_History_Related_Opportunity__r.Name : ('')) + '</a></span><br>';
        workflowEmailRecordWrapperMessage.whatId = bidHistory.Id;
        workflowEmailRecordWrapperMessage.toEmails = toEmailList;
        workflowEmailRecordWrapperMessage.emailAction = CON_OWF.BHR_OWF_24_NotificationFromRFIToIQVIATeam;
        workflowEmailRecordWrapperMessage.staticContent = emailOverallBodyContent;            
        return workflowEmailRecordWrapperMessage;   
    }
    
    public static UTL_OWF.workflowEmailRecordWrapper sendEmailForRFIRequestIQVIALABSSPWSupport(Bid_History__c bidHistory) {
        List<String> toEmailList;
        String emailOverallBodyContent;
        OWF_Generic_Setting__c additionalEmail = OWF_Generic_Setting__c.getValues(CON_OWF.BHR_OWF_NotificationFromRFIIQVIALABSSPWSupport);
        UTL_OWF.workflowEmailRecordWrapper workflowEmailRecordWrapperMessage;
        toEmailList = new List<String>();
        List<String> toCcEmailList = new List<String>();
        emailOverallBodyContent = '';
        if(additionalEmail != null && additionalEmail.Value__c != null){
            toEmailList = (additionalEmail.Value__c).split(',');
        } 
        workflowEmailRecordWrapperMessage = new UTL_OWF.workflowEmailRecordWrapper();
        workflowEmailRecordWrapperMessage.subject = 'New RFI Request requires IQVIA LABS SPW support - ' + (bidHistory.Bid_History_Account__r.Name != null ? bidHistory.Bid_History_Account__r.Name + ' - ' : '') + (bidHistory.Legacy_Quintiles_Opportunity_Number__c != null ? bidHistory.Legacy_Quintiles_Opportunity_Number__c + '' : (''))+ ' ' + (bidHistory.RFI_Due_Date__c != null ? ' - ' + bidHistory.RFI_Due_Date__c.format() : ''); 
        emailOverallBodyContent = '<div> Dear IQVIA Labs SPWs <br><br>';
        emailOverallBodyContent += 'An RFI Request has been created and requires IQVIA Labs SPW Support <br><br>';
        emailOverallBodyContent += 'Account Name: '+(bidHistory.Bid_History_Account__r.Name != null ? bidHistory.Bid_History_Account__r.Name : ('')) +'<br>';
        emailOverallBodyContent += 'Opportunity Name: '+(bidHistory.Bid_History_Related_Opportunity__r.Name != null ? bidHistory.Bid_History_Related_Opportunity__r.Name : ('')) +'<br>';
        emailOverallBodyContent += 'Opportunity Number: ' + (bidHistory.Legacy_Quintiles_Opportunity_Number__c != null ? bidHistory.Legacy_Quintiles_Opportunity_Number__c : (''))+'<br><br>';
        emailOverallBodyContent += 'Link to RFI Request: <span style = "font-weight: normal;"><a href = \'' + URL.getOrgDomainUrl().toExternalForm() + '/' + (bidHistory.id != null ? bidHistory.id : ('')) + '\'>' + (bidHistory.Name != null ? bidHistory.Name : ('')) + '</a></span><br>';
        emailOverallBodyContent += 'Link to Opportunity: <span style = "font-weight: normal;"><a href = \'' + URL.getOrgDomainUrl().toExternalForm() + '/' + (bidHistory.Bid_History_Related_Opportunity__r.id != null ? bidHistory.Bid_History_Related_Opportunity__r.id : ('')) + '\'>' + (bidHistory.Bid_History_Related_Opportunity__r.Name != null ? bidHistory.Bid_History_Related_Opportunity__r.Name : ('')) + '</a></span><br><br>';
        emailOverallBodyContent += 'Thank you <br><br>';
        emailOverallBodyContent += 'RFI Team <br><br></div>';
        workflowEmailRecordWrapperMessage.whatId = bidHistory.Id;
        workflowEmailRecordWrapperMessage.toEmails = toEmailList;
        workflowEmailRecordWrapperMessage.emailAction = CON_OWF.BHR_OWF_26_NotificationRFIIQVIALABSSPWSupport;
        workflowEmailRecordWrapperMessage.staticContent = emailOverallBodyContent;            
        return workflowEmailRecordWrapperMessage;   
    }
    
    public static void q2RequestedTurnAroundTimeFieldUpdate(List<Bid_History__c> bidHistoryList, Map<Id,Bid_History__c> oldbidHistoryMap) {
        for(Bid_History__c bid : bidHistoryList){
            Date startDate;
            Date endDate;
            Integer total = 0;
            if (oldbidHistoryMap == null){
                startDate =  Date.Today();
            }
            else if(bid.Bid_Due_Date__c != oldbidHistoryMap?.get(bid.Id).Bid_Due_Date__c || bid.Change_Order_Due_Date__c != oldbidHistoryMap?.get(bid.Id).Change_Order_Due_Date__c ){ 
                    startDate = bid.CreatedDate.date();
            }
            if (startDate != null){
                if (bid.Bid_Type__c == CON_OWF.BID_TYPE_INITIAL || bid.Bid_Type__c == CON_OWF.BID_TYPE_RE_BID && bid.Bid_Due_Date__c != null){
                    endDate = bid.Bid_Due_Date__c;
                }
                else if (bid.Bid_Type__c == CON_OWF.BID_TYPE_CHANGE_ORDER && bid.Change_Order_Due_Date__c != null){
                    endDate =  bid.Change_Order_Due_Date__c; 
                }
            }
            if(startDate != null && endDate != null){
                Integer daysRemaining = startDate.daysBetween(endDate);
                DateTime endDateTime =(DateTime)endDate;
                String dayOfWeekEndDate = endDateTime.format('EEEE');
                if (dayOfWeekEndDate != 'Saturday' && dayOfWeekEndDate != 'Sunday') {
                    daysRemaining+= 1;
                }
                for (Integer i = 0;  i < daysRemaining; i++){
                    Datetime targetDate =   startDate+i;
                    String dayOfWeek = targetDate.format('EEEE');
                    if (dayOfWeek != 'Saturday' && dayOfWeek != 'Sunday'){
                        total++ ;
                    }
                }
                bid.Requested_Turn_Around_Time__c = total;
            }
        }
    }
}
