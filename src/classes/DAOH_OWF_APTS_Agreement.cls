/**
* This is APTS_Agreement trigger handler class.
* version : 1.0
*/
public class DAOH_OWF_APTS_Agreement {
    
    public static void dummy()
    {
        
    }
    
    /**
* This method is used to set Number of Requested Services based on selected Requested Services.
* @params  newList List<Apttus__APTS_Agreement__c>
* @params  oldMap Map<Id, Apttus__APTS_Agreement__c>
* @return  void
*/
   /* public static void setNoOfRequestedServicesBasedOnRequestedServices(List<Apttus__APTS_Agreement__c> newList, Map<Id, Apttus__APTS_Agreement__c> oldMap) {
        system.debug('***setNoOfRequestedServicesBasedOnRequestedServices->getCpuTime()***'+Limits.getCpuTime());
        for(Apttus__APTS_Agreement__c agreement : newList) {
            if(oldMap == null || (oldMap != null && agreement.Requested_Services__c != oldMap.get(agreement.Id).Requested_Services__c)) {
                if(String.IsNotBlank(agreement.Requested_Services__c)) {
                    agreement.Number_of_Requested_Services__c = agreement.Requested_Services__c.split(CON_OWF.SEMI_COLON).size();
                }else {
                    agreement.Number_of_Requested_Services__c = 0;
                }
            }
        }
        system.debug('***getCpuTime()***'+Limits.getCpuTime());
    }
    */
    /**
* This method is used to set Bid# based on Agreement Record Type.
* @params  newList List<Apttus__APTS_Agreement__c>
* @return  void
*/
   /* public static void setBidNoBasedOnRecordType(List<Apttus__APTS_Agreement__c> newList) {
        system.debug('***setBidNoBasedOnRecordType->getCpuTime()***'+Limits.getCpuTime());
        //Get Agreement_Type_Bid_Mapping custom metadata to get Bid# intialization for Agreement Type
        Set<String> agreementTypeBidMappFieldSet = new Set<String>{'DeveloperName', 'MasterLabel', 'Bid_No__c', 'Is_Incremental__c'};
            Map<String, Agreement_Type_Bid_Mapping__mdt> agreementTypeBidMappingByNameMap = new Map<String, Agreement_Type_Bid_Mapping__mdt>();
        Set<String> incrementalTypeAgreementTypeSet = new Set<String>();
        for(Agreement_Type_Bid_Mapping__mdt agrTypeBidMapping : new SLT_Agreement_Type_Bid_Mapping(false, false).getAgreementTypeBidMappings(agreementTypeBidMappFieldSet)) {
            agreementTypeBidMappingByNameMap.put(agrTypeBidMapping.DeveloperName, agrTypeBidMapping);
            if(agrTypeBidMapping.Is_Incremental__c) {
                incrementalTypeAgreementTypeSet.add(agrTypeBidMapping.DeveloperName);
            }
        }
        //Get a map of Record types for APTS_Agreement object
        Map<Id, RecordType> agreementRecordTypeIdToRecordTypeMap = new Map<Id, RecordType>(new SLT_ProcessInstanceWorkitem().getRecordTypesBySObjectType(CON_OWF.SOBJECT_TYPE_APTS_AGREEMENT));
        Map<Id, List<Apttus__APTS_Agreement__c>> agreementRecordTypeToAgreementsMap = new Map<Id, List<Apttus__APTS_Agreement__c>>();
        Set<Id> oppIdswithAgreementsSet = new Set<Id>();
        for(Apttus__APTS_Agreement__c agreement : newList) {
            if(!agreementRecordTypeToAgreementsMap.containsKey(agreement.RecordTypeId)) {
                agreementRecordTypeToAgreementsMap.put(agreement.RecordTypeId, new List<Apttus__APTS_Agreement__c>());    
            }
            agreementRecordTypeToAgreementsMap.get(agreement.RecordTypeId).add(agreement);
            
            if(agreementRecordTypeIdToRecordTypeMap.containsKey(agreement.RecordTypeId) 
               && incrementalTypeAgreementTypeSet.contains(agreementRecordTypeIdToRecordTypeMap.get(agreement.RecordTypeId).DeveloperName)) {
                   oppIdswithAgreementsSet.add(agreement.Apttus__Related_Opportunity__c);
               }
        }
        
        Map<Id, Map<String, decimal>> oppIdToAgrRecordTypeWithRecentAgrBidNumberMap = new Map<Id, Map<String, decimal>>();
        if(!oppIdswithAgreementsSet.isEmpty()) {
            Set<String> oppfieldSet = new Set<String>{'Id'};
                Set<String> agreementFieldSet = new Set<String>{'Id', 'Bid_Number__c', 'RecordType.DeveloperName'};
                    Map<Id, Opportunity> oppIdToOppWithAgreementsMap = new SLT_Opportunity(false, false).selectByIdWithOpportuntiyAgreement(oppIdswithAgreementsSet, oppfieldSet, agreementFieldSet);
            for(Id oppId : oppIdToOppWithAgreementsMap.keySet()) {
                if(oppIdToOppWithAgreementsMap.get(oppId).Apttus__R00N50000001Xl0FEAS__r.size() > 0) {
                    if(!oppIdToAgrRecordTypeWithRecentAgrBidNumberMap.containsKey(oppId)) {
                        oppIdToAgrRecordTypeWithRecentAgrBidNumberMap.put(oppId, new Map<String, decimal>());
                    }
                    for(Apttus__APTS_Agreement__c agreement : oppIdToOppWithAgreementsMap.get(oppId).Apttus__R00N50000001Xl0FEAS__r) {
                        if(incrementalTypeAgreementTypeSet.contains(agreement.RecordType.DeveloperName)) {
                            if(!oppIdToAgrRecordTypeWithRecentAgrBidNumberMap.get(oppId).containsKey(agreement.RecordType.DeveloperName)) {
                                oppIdToAgrRecordTypeWithRecentAgrBidNumberMap.get(oppId).put(agreement.RecordType.DeveloperName, agreement.Bid_Number__c);
                            }else if(oppIdToAgrRecordTypeWithRecentAgrBidNumberMap.get(oppId).get(agreement.RecordType.DeveloperName) < agreement.Bid_Number__c){
                                oppIdToAgrRecordTypeWithRecentAgrBidNumberMap.get(oppId).put(agreement.RecordType.DeveloperName, agreement.Bid_Number__c);
                            }
                        }
                    }
                }
            }
        }
        for(Id agrRecTypeId : agreementRecordTypeToAgreementsMap.keySet()) {
            if(agreementRecordTypeIdToRecordTypeMap.containsKey(agrRecTypeId) 
               && agreementTypeBidMappingByNameMap.containsKey(agreementRecordTypeIdToRecordTypeMap.get(agrRecTypeId).DeveloperName)) {
                   if(!incrementalTypeAgreementTypeSet.contains(agreementRecordTypeIdToRecordTypeMap.get(agrRecTypeId).DeveloperName)) {
                       for(Apttus__APTS_Agreement__c agreement : agreementRecordTypeToAgreementsMap.get(agrRecTypeId)) {
                           agreement.Bid_Number__c = agreementTypeBidMappingByNameMap.get(agreementRecordTypeIdToRecordTypeMap.get(agrRecTypeId).DeveloperName).Bid_No__c;
                       }
                   }else {
                       Id oppId = agreementRecordTypeToAgreementsMap.get(agrRecTypeId).get(0).Apttus__Related_Opportunity__c;
                       Decimal agreementBidNo = agreementTypeBidMappingByNameMap.get(agreementRecordTypeIdToRecordTypeMap.get(agrRecTypeId).DeveloperName).Bid_No__c;
                       if(oppIdToAgrRecordTypeWithRecentAgrBidNumberMap.containsKey(oppId)) {
                           if(oppIdToAgrRecordTypeWithRecentAgrBidNumberMap.get(oppId).containsKey(agreementRecordTypeIdToRecordTypeMap.get(agrRecTypeId).DeveloperName)) {
                               agreementBidNo = oppIdToAgrRecordTypeWithRecentAgrBidNumberMap.get(oppId).get(agreementRecordTypeIdToRecordTypeMap.get(agrRecTypeId).DeveloperName) + 1;
                           }
                       }
                       for(Apttus__APTS_Agreement__c agreement : agreementRecordTypeToAgreementsMap.get(agrRecTypeId)) {
                           agreement.Bid_Number__c = agreementBidNo;
                           agreementBidNo++;
                       }
                   }
               }
        }
        system.debug('***getCpuTime()***'+Limits.getCpuTime());
    }
    */
    /**
* This method is used to set Number of Requested Services based on selected Requested Services.
* @params  newList List<Apttus__APTS_Agreement__c>
* @params  oldMap Map<Id, Apttus__APTS_Agreement__c>
* @return  void
*/
   /* public static void setEndDateAndStatusOnProjectResReqsAndAssignments(List<Apttus__APTS_Agreement__c> newList, Map<Id, Apttus__APTS_Agreement__c> oldMap) {
        system.debug('***setEndDateAndStatusOnProjectResReqsAndAssignments->getCpuTime()***'+Limits.getCpuTime());
        Map<Id, Apttus__APTS_Agreement__c> agreementIdToAgreementMap = new Map<Id, Apttus__APTS_Agreement__c>();
         CON_OWF.BYPASS_VALIDATION_RULE_RR = true;
        for(Apttus__APTS_Agreement__c agreement : newList) {
            if(agreement.Bid_Due_Date__c != oldMap.get(agreement.Id).Bid_Due_Date__c && agreement.Bid_Due_Date__c != NULL) {
                agreementIdToAgreementMap.put(agreement.Id, agreement);
            }
        }
        
        if(!agreementIdToAgreementMap.isEmpty()) {
            Set<String> agreementFieldSet = new Set<String>{'Id', 'Apttus__Status__c'};
                Set<String> projectFieldSet = new Set<String>{'Id', 'pse__End_Date__c', 'pse__Project_Status__c'};
                    Set<String> resRequestFieldSet = new Set<String>{'Id', 'pse__End_Date__c','is_Bid_Defense__c', 'pse__Status__c','pse__Assignment__c','pse__Staffer_Resource__r.pse__Is_Resource_Active__c','pse__Staffer_Resource__r.pse__Is_Resource__c'}; 
                        Set<String> assignmentFieldSet = new Set<String>{'Id', 'pse__End_Date__c', 'pse__Status__c', 'pse__Schedule__c','pse__Resource_Request__r.is_Bid_Defense__c','pse__Resource__r.pse__Is_Resource_Active__c','pse__Resource__r.pse__Is_Resource__c'};
                            Map<Id, Apttus__APTS_Agreement__c> agrIdToAgrWithRelatedRecords = new SLT_APTS_Agreement(false,false).selectByIdWithAgreementAndProjsResReqsAssignments(agreementIdToAgreementMap.keySet(), agreementFieldSet, projectFieldSet, resRequestFieldSet, assignmentFieldSet);
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
                    if(agrIdToAgrWithRelatedRecords.get(agrId).Projects__r.size() > 0) {
                        for(pse__Proj__c project : agrIdToAgrWithRelatedRecords.get(agrId).Projects__r) {
                            project.pse__End_Date__c = agrBidDueDate;
                            projectsUpdateList.add(project);
                        }
                    }
                    //Validating if Resource_Requests exist under Agreements then iterate over Projects and update End Date & Status
                    if(agrIdToAgrWithRelatedRecords.get(agrId).Resource_Requests__r.size() > 0) {
                        for(pse__Resource_Request__c resRquest : agrIdToAgrWithRelatedRecords.get(agrId).Resource_Requests__r) {
                            if(!resRquest.is_Bid_Defense__c && (resRquest.pse__Status__c != 'Cancelled' && resRquest.pse__Status__c != 'Closed') && resRquest.pse__Staffer_Resource__r.pse__Is_Resource_Active__c == true && resRquest.pse__Staffer_Resource__r.pse__Is_Resource__c == true){
                                resRquest.pse__End_Date__c = agrBidDueDate;
                                if(agrBidDueDate == system.today() && resRquest.pse__Status__c == CON_OWF.OWF_STATUS_ASSIGNED && resRquest.pse__Assignment__c !=null) {
                                    resRquest.pse__Status__c = CON_OWF.OWF_STATUS_COMPLETED;
                                }else if(agrBidDueDate > system.today() && resRquest.pse__Status__c == CON_OWF.OWF_STATUS_COMPLETED && resRquest.pse__Assignment__c !=null) {
                                    resRquest.pse__Status__c = CON_OWF.OWF_STATUS_ASSIGNED;
                                }
                                resourceRequestsUpdateList.add(resRquest);
                            }
                        }
                    }
                    //Validating if Assignments exist under Agreements then iterate over Projects and update End Date & Status
                    if(agrIdToAgrWithRelatedRecords.get(agrId).Assignments__r.size() > 0) {
                        for(pse__Assignment__c assignment : agrIdToAgrWithRelatedRecords.get(agrId).Assignments__r) {
                            if(!assignment.pse__Resource_Request__r.is_Bid_Defense__c && (assignment.pse__Status__c == 'Accepted' || assignment.pse__Status__c == 'Pending' || assignment.pse__Status__c == 'Completed')
                               && assignment.pse__Resource__r.pse__Is_Resource_Active__c == true && assignment.pse__Resource__r.pse__Is_Resource__c == true)
                            {
                                //Validating if Assignment have Schedule populated then updating End_Date based on Argument's Bid_Due_Date
                                if(assignment.pse__Schedule__c != NULL) {
                                    assignmentScheduleUpdateList.add(new pse__Schedule__c(Id = assignment.pse__Schedule__c, pse__End_Date__c = agrBidDueDate));
                                }
                                if(agrBidDueDate == system.today() && assignment.pse__Status__c == CON_OWF.OWF_STATUS_ACCEPTED) {
                                    assignment.pse__Status__c = CON_OWF.OWF_STATUS_COMPLETED;
                                }else if(agrBidDueDate > system.today() && assignment.pse__Status__c == CON_OWF.OWF_STATUS_COMPLETED) {
                                    assignment.pse__Status__c = CON_OWF.OWF_STATUS_ACCEPTED;
                                }
                                assignmentsUpdateList.add(assignment);
                            }
                        }
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
        system.debug('***getCpuTime()***'+Limits.getCpuTime());
    }*/
    
    /**
* This method is used to create project (pse__proj__c) record on insert of an Agreement.
* @params  newList List<Apttus__APTS_Agreement__c>
* @params  oldMap Map<Id, Apttus__APTS_Agreement__c>
* @return  
*/
   /* public static void createProjectBasedOnAgreement(List<Apttus__APTS_Agreement__c> newList) {
        system.debug('***createProjectBasedOnAgreement->getCpuTime()***'+Limits.getCpuTime());
        List<pse__proj__c> projectsToBeInsertedList = new List<pse__proj__c>();
        projectsToBeInsertedList = returnProjectBasedOnAgreement(newList);
        if(projectsToBeInsertedList.size() > 0) {
            insert projectsToBeInsertedList;
        }
        system.debug('***getCpuTime()***'+Limits.getCpuTime());
    }*/
    /**
* This method is used to create project (pse__proj__c) record on insert of an Agreement.
* @params  newList List<Apttus__APTS_Agreement__c>
* @params  oldMap Map<Id, Apttus__APTS_Agreement__c>
* @return  projectsToBeReturnedList List<pse__proj__c>
*/
   /* private static List<pse__Proj__c> returnProjectBasedOnAgreement(List<Apttus__APTS_Agreement__c> newList) {
        List<pse__proj__c> projectsToBeReturnedList = new List<pse__proj__c>();
        OWF_Config__c owfConfig = OWF_Config__c.getOrgDefaults();
        String owfStdGroupId = '';
        if(owfConfig != null) {
            owfStdGroupId = owfConfig.OWF_Standard_Group__c;
        }
        for(Apttus__APTS_Agreement__c agr : newList) {
            if(CON_OWF.OWF_AGREEMENT_RECORD_TYPE_IDS_SET.contains(agr.recordTypeId)) {
                pse__proj__c project = new pse__proj__c(
                    recordTypeId = CON_OWF.OWF_BID_PROJECT_RECORD_TYPE_ID,
                    name = agr.name,
                    currencyIsoCode = agr.currencyIsoCode,
                    pse__Start_Date__c = Date.today(),
                    pse__End_Date__c = agr.Bid_Due_Date__c,
                    Agreement__c = agr.id,
                    pse__Opportunity__c = agr.Apttus__Related_Opportunity__c,
                    pse__Account__c = agr.Apttus__Account__c,
                    pse__Group__c = owfStdGroupId
                );
                projectsToBeReturnedList.add(project); 
            }
        }
        return projectsToBeReturnedList;
    }    
    */
    /**
* This method is used to delete project (pse__proj__c) record based on Agreement.
* @params  newList List<Apttus__APTS_Agreement__c>
* @return  
*/
   /* public static void deleteProjectBasedOnAgreement(List<Apttus__APTS_Agreement__c> newList) {
        system.debug('***deleteProjectBasedOnAgreement->getCpuTime()***'+Limits.getCpuTime());
        List<pse__proj__c> projectsToBeDeletedList = new List<pse__proj__c>();
        projectsToBeDeletedList = returnProjectBasedOnAgr(newList);
        if(projectsToBeDeletedList.size() > 0) {
            QBL_OWF_DeletionLogic.QueueProjectDeletion   queuableObject = new QBL_OWF_DeletionLogic.QueueProjectDeletion  (projectsToBeDeletedList);
            System.enqueueJob(queuableObject);
        }
        system.debug('***getCpuTime()***'+Limits.getCpuTime());
    }*/
    
    /**
* This method is used to create Resource Request for Clinical Bids
* @params  newList List<Apttus__APTS_Agreement__c>
* @params  oldMap Map<Id, Apttus__APTS_Agreement__c>
*/
  /*  public static void createClinicalBidResRequestsOnAgreementUpdate(List<Apttus__APTS_Agreement__c> newList, Map<Id, Apttus__APTS_Agreement__c> oldMap) {
        system.debug('***createClinicalBidResRequestsOnAgreementUpdate->getCpuTime()***'+Limits.getCpuTime());
        Set<Id> agreementOppIdsSet = new set<Id>();
        Set<Id> rebidAgreementOppIdsSet = new Set<Id>();
        for(Apttus__APTS_Agreement__c agrmt : newList) {
            if(agrmt.Bid_Due_Date__c != oldMap.get(agrmt.Id).Bid_Due_Date__c || agrmt.Requested_Services__c != oldMap.get(agrmt.Id).Requested_Services__c
               || agrmt.Targeted_Countries__c != oldMap.get(agrmt.Id).Targeted_Countries__c || agrmt.Budget_Deliverable__c != oldMap.get(agrmt.Id).Budget_Deliverable__c
               || agrmt.Grid_Ranking_Level__c !=  oldMap.get(agrmt.Id).Grid_Ranking_Level__c || agrmt.Is_there_a_Client_Bid_Grid__c !=  oldMap.get(agrmt.Id).Is_there_a_Client_Bid_Grid__c
               || agrmt.Estimated_Fees__c !=  oldMap.get(agrmt.Id).Estimated_Fees__c || agrmt.Additional_Services_Requested__c !=  oldMap.get(agrmt.Id).Additional_Services_Requested__c 
               || agrmt.RFP_Ranking__c !=  oldMap.get(agrmt.Id).RFP_Ranking__c)
            {
                if(agrmt.Bid_Number__c == 1)
                    agreementOppIdsSet.add(agrmt.Apttus__Related_Opportunity__c);
                else if(agrmt.Bid_Number__c > 1)
                    rebidAgreementOppIdsSet.add(agrmt.Apttus__Related_Opportunity__c);	
            }
          
        }
        List<pse__Resource_Request__c> reqRequestsInsertList = new List<pse__Resource_Request__c>();
        List<pse__Resource_Request__c> reqRequestsInsertListRebid = new List<pse__Resource_Request__c>();
        if(agreementOppIdsSet.size() > 0) {
            String agrCondition = 'Apttus__Related_Opportunity__c != NULL And Apttus__Related_Opportunity__c IN :sObjectIdSet ' +
                ' And RecordTypeId = \'' + CON_OWF.OWF_CLINICAL_BID_AGREEMENT_RECORD_TYPE_ID + '\'';
            reqRequestsInsertList = UTL_OWF.processResRequestForInitialBids(agreementOppIdsSet, agrCondition, null, null);
            
        }
		if(rebidAgreementOppIdsSet.size() >0)
        {
            String agrCondition = 'Apttus__Related_Opportunity__c != NULL And Apttus__Related_Opportunity__c IN :sObjectIdSet ' +
                ' And RecordTypeId = \'' + CON_OWF.OWF_CLINICAL_BID_AGREEMENT_RECORD_TYPE_ID + '\'';
        	reqRequestsInsertListRebid = UTL_OWF.processResRequestForClinicalReBids(rebidAgreementOppIdsSet, agrCondition,reqRequestsInsertList);
        }
        reqRequestsInsertList.addAll(reqRequestsInsertListRebid);    

		if(reqRequestsInsertList.size()>0)
        {
            insert reqRequestsInsertList;
        }
        
        system.debug('***getCpuTime()***'+Limits.getCpuTime());
    }
    
    private static List<pse__Proj__c> returnProjectBasedOnAgr(List<Apttus__APTS_Agreement__c> newList) {
        List<pse__proj__c> projectsToBeReturnedList = new List<pse__proj__c>();
        Set<String> projectFieldSet = new Set<String>{'Id'};
        Map<Id, Apttus__APTS_Agreement__c> agreementIdToAgreementMap= new Map<Id, Apttus__APTS_Agreement__c>();
        for(Apttus__APTS_Agreement__c agreement : newList)
        {
            agreementIdToAgreementMap.put(agreement.ID, agreement );
        }
        
        Map<Id, pse__proj__c> prjIdToProjectMap = new SLT_Project(false,false).getProjectByAgreementID(agreementIdToAgreementMap.keySet(),projectFieldSet );
        projectsToBeReturnedList  = prjIdToProjectMap .values();
        return projectsToBeReturnedList;
    } 
    
    /**
* This method is used to update Complexity Score Total on RR.
* @params  newList List<Apttus__APTS_Agreement__c>
* @params  oldMap Map<Id, Apttus__APTS_Agreement__c>
* @return  void
*/
  /*  public static void updateComplexityScoreTotalOnRR(List<Apttus__APTS_Agreement__c> newList, Map<Id, Apttus__APTS_Agreement__c> oldMap) {     
         CON_OWF.BYPASS_VALIDATION_RULE_RR = true;
        system.debug('***updateComplexityScoreTotalOnRR->getCpuTime()***'+Limits.getCpuTime());
        Set<Id> rrAgreementIdSet = new Set<Id>();
        Set<Id> oppIdSet = new Set<Id>();
        Map<Id, Apttus__APTS_Agreement__c> agrIdToAgreementMap = new Map<Id, Apttus__APTS_Agreement__c>();
        Map<String,OWF_Resource_Setting__mdt> resSettingIdToResSettingMap = new Map<String,OWF_Resource_Setting__mdt>(); 
        List<pse__Resource_Request__c> rrList = new List<pse__Resource_Request__c>();
        List<pse__Resource_Request__c> rrWithCSTList = new List<pse__Resource_Request__c>();
        List<pse__Resource_Request__c> toBeUpdatedRRList = new List<pse__Resource_Request__c>();
        Set<String> orsFieldSet = new Set<String>{'Id','Sub_Group__c', 'Estimated_Fees__c','Is_there_a_Client_Bid_Grid__c','Number_of_Sites__c',
            'Potential_Regions__c','Project_Ex_Number_of_Unique_Tables__c','Re_Bid_Complexity__c',
            'Requested_Services__c','RFP_Ranking__c','Staffing_Number_of_Unique_Tables__c','Country__c'};
                for(Apttus__APTS_Agreement__c agr : newList) {
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
                           oppIdSet.add(agr.Apttus__Related_Opportunity__c);
                       }                                        
                }   
        
        if(rrAgreementIdSet.size() > 0 && oppIdSet.size() > 0) {
            //IQVIAPSA-2165 == start
            Set<String> agrFieldSet = new Set<String>{'Id', 'Name','RFP_Ranking__c','Number_of_Sites__c','Re_Bid_Complexity__c',
                'Estimated_Fees__c','Is_there_a_Client_Bid_Grid__c','Number_of_Requested_Services__c',
                'Staffing_Number_of_Unique_Tables__c','Triage_Level__c','Project_Ex_Number_of_Unique_Tables__c',
                'Apttus__Related_Opportunity__r.Number_of_Potential_Regions__c','Apttus__Related_Opportunity__r.Potential_Regions__c',
                'Apttus__Related_Opportunity__c','Bid_Due_Date__c','Apttus__Related_Opportunity__r.Bid_Defense_Date__c',
                'CreatedDate','Grid_Ranking_Level__c'};
             //IQVIAPSA-2165 == stop
                    Set<String> resReqFieldSet = new Set<String>{'Id', 'pse__Opportunity__c', 'Agreement__c', 'Resource_Request_Type__c', 'Complexity_Score_Total__c', 'SubGroup__c',
                        'CreatedDate','Workload_Ranking__c','Suggested_FTE__c','pse__Start_Date__c',
                        'pse__Start_Date__c','pse__End_Date__c', 'Is_Bid_Defense__c','pse__Status__c','Regional_Analytics_Country__c'};
                            
                            String agrCondition = 'Apttus__Related_Opportunity__c != NULL And Apttus__Related_Opportunity__c IN :sObjectIdSet ';
            String resReqCondition = 'pse__Opportunity__c != NULL And Agreement__c != NULL';
            agrIdToAgreementMap = new SLT_APTS_Agreement(false,false).getAgreementAndResReqsByOppId(oppIdSet, agrFieldSet, resReqFieldSet, agrCondition, resReqCondition);                            
            
            for(Apttus__APTS_Agreement__c agr : agrIdToAgreementMap.values()) {
                
                for(pse__Resource_Request__c rr: agr.Resource_Requests__r){
                    rrList.add(rr);
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
        system.debug('***getCpuTime()***'+Limits.getCpuTime());                                                
    }
    */
    /**
* This method is used to do calculation on RR based using OWF Assignment Setting CMT and Resource_Request_Name on RR based on modified Resource_Rquest_Type field
* @params  List<Apttus__APTS_Agreement__c> newList
* @params  Map<Id, Apttus__APTS_Agreement__c> oldMap
* @return  void
*/
  /*  public static void updateDataBasedOnOasSetting(List<Apttus__APTS_Agreement__c> newList, Map<Id, Apttus__APTS_Agreement__c> oldMap) {
        system.debug('***updateDataBasedOnOasSetting->getCpuTime()***'+Limits.getCpuTime());
        Set<Id> rrAgreementIdSet = new Set<Id>();
        Map<Id, Apttus__APTS_Agreement__c> agrIdToAgreementMap = new Map<Id, Apttus__APTS_Agreement__c>();
        Map<Id,pse__Resource_Request__c> rrIdToRRMap = new Map<Id,pse__Resource_Request__c>();
        List<pse__Resource_Request__c> toBeUpdatedRRList = new List<pse__Resource_Request__c>();
        Set<String> resReqFieldSet = new Set<String>{'Id', 'pse__Opportunity__c', 'Agreement__c', 'Resource_Request_Type__c', 'Complexity_Score_Total__c', 'SubGroup__c',
            'CreatedDate','Workload_Ranking__c','Suggested_FTE__c','pse__Start_Date__c',
            'pse__Start_Date__c','pse__End_Date__c', 'Is_Bid_Defense__c','pse__Status__c'}; 
                for(Apttus__APTS_Agreement__c agr : newList) {
                    if(agr.RecordType != oldMap.get(agr.id).RecordType 
                       ||agr.Budget_Deliverable__c != oldMap.get(agr.id).Budget_Deliverable__c ||
                       agr.RFP_Ranking__c != oldMap.get(agr.id).RFP_Ranking__c) {
                           rrAgreementIdSet.add(agr.id);
                           agrIdToAgreementMap.put(agr.id,agr);
                       }                                        
                } 
        if(rrAgreementIdSet.size() > 0 ){
            rrIdToRRMap = new SLT_Resource_Request(false,false).getResourceRequestByAgrID(rrAgreementIdSet,resReqFieldSet);
            if(rrIdToRRMap.size() > 0 ) {
                toBeUpdatedRRList = UTL_OWF.calculateWRandSuggestedFTE(agrIdToAgreementMap,rrIdToRRMap.values());
                update toBeUpdatedRRList;
            }
        }
        system.debug('***getCpuTime()***'+Limits.getCpuTime());
    }*/
    
    /**
* This method is used to set related Opportunity Name in the name field of Agreement.
* @params  newList List<Apttus__APTS_Agreement__c>
* @return  void
*/
   /* public static void populateAgrNameWithOppName(List<Apttus__APTS_Agreement__c> newList) {
        system.debug('***populateAgrNameWithOppName->getCpuTime()***'+Limits.getCpuTime());
        Set<Id> oppIdSet = new Set<Id>();
        Set<String> oppFieldSet = new Set<String>{'Id','Name','Owner.Email','Is_this_IQVIA_Biotech__c','Indication_List__c','TherapyArea__c'};
            Map<Id, Opportunity> idToOppMap = new Map<Id, Opportunity>();
        for(Apttus__APTS_Agreement__c agr : newList) {
            //if(CON_OWF.OWF_AGREEMENT_RECORD_TYPE_IDS_SET.contains(agr.recordTypeId) && agr.recordTypeId != CON_OWF.OWF_NON_RFP_BID_AGREEMENT_RECORD_TYPE_ID || CON_CRM.CRM_AGREEMENT_RECORD_TYPE_SET.contains(agr.recordTypeId)) {
            if(CON_OWF.OWF_AGREEMENT_RECORD_TYPE_IDS_SET.contains(agr.recordTypeId) || CON_CRM.CRM_AGREEMENT_RECORD_TYPE_SET.contains(agr.recordTypeId)) {
                oppIdSet.add(agr.Apttus__Related_Opportunity__c);
            }
        }
        if(oppIdSet.size() > 0 ){
            idToOppMap = new SLT_Opportunity(false,false).getOpportunityById(oppIdSet,oppFieldSet);
            for(Apttus__APTS_Agreement__c agr : newList) {
                if(idToOppMap.containsKey(agr.Apttus__Related_Opportunity__c)) {
                    agr.name = idToOppMap.get(agr.Apttus__Related_Opportunity__c).name.left(80);
                    agr.Original_Due_Date__c = agr.Bid_Due_Date__c;
                    agr.Opportunity_Owner_Email_Address__c = idToOppMap.get(agr.Apttus__Related_Opportunity__c).Owner.Email;

                    if(agr.RecordTypeId == CON_OWF.OWF_CLINICAL_BID_AGREEMENT_RECORD_TYPE_ID && idToOppMap.get(agr.Apttus__Related_Opportunity__c).Is_this_IQVIA_Biotech__c != Null)
 						agr.IQVIA_biotech__c = idToOppMap.get(agr.Apttus__Related_Opportunity__c).Is_this_IQVIA_Biotech__c;
                    
                    if(agr.RecordTypeId == CON_OWF.OWF_EARLY_ENGAGEMENT_BID_RECORD_TYPE_ID && idToOppMap.get(agr.Apttus__Related_Opportunity__c).Indication_List__c != Null)
                    {
                        agr.OWF_Indication__c = idToOppMap.get(agr.Apttus__Related_Opportunity__c).Indication_List__c;
                        agr.OWF_Therapy_Area__c = idToOppMap.get(agr.Apttus__Related_Opportunity__c).TherapyArea__c;
                    }
                }
                
            }
        }
        system.debug('***getCpuTime()***'+Limits.getCpuTime());
    }
    
    public static void createOutboundMessageDeletionQueue(List<Apttus__APTS_Agreement__c> deleteList) {
        system.debug('***createOutboundMessageDeletionQueue->getCpuTime()***'+Limits.getCpuTime());
        fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(
            new Schema.SObjectType[] {
                Outbound_Message_Deletion_queue__c.SobjectType
                    }
        );
        Outbound_Message_Deletion_queue__c outBound;
        Boolean toCommit = false;
        for(Apttus__APTS_Agreement__c agr : deleteList) {
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
        system.debug('***getCpuTime()***'+Limits.getCpuTime());
    }
    public static void setMulesoftSyncfields(List<Apttus__APTS_Agreement__c> newList,Map<Id, Apttus__APTS_Agreement__c> oldMap) {
        system.debug('***setMulesoftSyncfields->getCpuTime()***'+Limits.getCpuTime());
        // FEATURE-3828
        for(Apttus__APTS_Agreement__c agreement : newList) {      
            if((Trigger.isInsert || agreement.LQ_Mulesoft_Sync_Status__c == oldMap.get(agreement.Id).LQ_Mulesoft_Sync_Status__c || (agreement.LQ_Mulesoft_Sync_Status__c != oldMap.get(agreement.Id).LQ_Mulesoft_Sync_Status__c 
                                                                                                                                    && (agreement.LQ_Mulesoft_Sync_Status__c != CON_CRM.MULESOFT_SYNC_STATUS_COMPLETED &&  agreement.LQ_Mulesoft_Sync_Status__c != CON_CRM.MULESOFT_SYNC_STATUS_FAILED))) && CON_OWF.OWF_AGREEMENT_RECORD_TYPE_BID_HISTORY.contains(agreement.recordTypeId)) {
                                                                                                                                        agreement.LQ_Mulesoft_Sync_Status__c = CON_CRM.MULESOFT_SYNC_STATUS_PENDING;
                                                                                                                                    }                        
        }
        system.debug('***getCpuTime()***'+Limits.getCpuTime());
    }
    /**
* This method is used to set related Opportunity Name in the name field of Agreement.
* @params  newList List<Apttus__APTS_Agreement__c>
* @return  void
*/
    /*public static void checkAgreementRecordTypeMapping(List<Apttus__APTS_Agreement__c> newList)
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
for(Apttus__APTS_Agreement__c app : newList)
{
if(oppStageToBidTypeMap.containsKey(App.Opportunity_Stage__c.substring(0,1)) && oppStageToBidTypeMap.get(App.Opportunity_Stage__c.substring(0,1)).contains(Schema.getGlobalDescribe().get('Apttus__APTS_Agreement__c').getDescribe().getRecordTypeInfosById().get(app.RecordTypeId).getName()))
{
isExist = true;
}
else if(oppStageToBidTypeMap.containsKey(App.Opportunity_Stage__c.substring(0,2)) && oppStageToBidTypeMap.get(App.Opportunity_Stage__c.substring(0,2)).contains(Schema.getGlobalDescribe().get('Apttus__APTS_Agreement__c').getDescribe().getRecordTypeInfosById().get(app.RecordTypeId).getName()))
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
* @params  newAgreementList List<Apttus__APTS_Agreement__c>
* @return  void
*/
    /*
public static void populateReBidFields(List<Apttus__APTS_Agreement__c> newAgreementList) {
Map<String, List<OWF_ReBidFieldMapping__mdt>>  agrRecordTypeNameToreBidFieldMap = new Map<String, List<OWF_ReBidFieldMapping__mdt>>();
List<OWF_ReBidFieldMapping__mdt> rebidFieldMappingList = new SLT_OWF_ReBidFieldMapping().getReBidFieldMapping();
Set<String> opportunityFieldSet = new Set<String>{'Id'};
Set<String> agreementFieldSet = new Set<String>{'Id', 'Apttus__Related_Opportunity__c', 'Apttus__Account__c', 'recordTypeId'};
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
Map<Id, Schema.RecordTypeInfo> recordTypeInfoIdMap = Schema.SObjectType.Apttus__APTS_Agreement__c.getRecordTypeInfosById();
Map<String, Id> recordTypeDevNameToIdMap = new Map<String, Id>();
for(Id recordTypeId : recordTypeInfoIdMap.keySet()) {
recordTypeDevNameToIdMap.put(recordTypeInfoIdMap.get(recordTypeId).getDeveloperName(), recordTypeId);
}
Set<Id> oppIdSet = new Set<Id>();
Set<Id> accountIdSet = new Set<Id>();
for(Apttus__APTS_Agreement__c agreement : newAgreementList) {
if(agreement.Apttus__Related_Opportunity__c != null)
oppIdSet.add(agreement.Apttus__Related_Opportunity__c);
if(agreement.Apttus__Account__c != null)
accountIdSet.add(agreement.Apttus__Account__c);
}
Map<Id, Opportunity> opportunityMap = new SLT_Opportunity(false,false).selectAgreementByOpportunities(oppIdSet, opportunityFieldSet, agreementFieldSet);
Map<Id, Map<String, Apttus__APTS_Agreement__c>> oppIdToAgrRecordTypeNameToAgrRecordMap = new Map<Id, Map<String, Apttus__APTS_Agreement__c>>();
for(Opportunity oppRecord : opportunityMap.values()) {
Map<String, Apttus__APTS_Agreement__c> agreementMap = new Map<String, Apttus__APTS_Agreement__c>();
for(Apttus__APTS_Agreement__c agreement : oppRecord.Apttus__R00N50000001Xl0FEAS__r) {
String recordTypeName = recordTypeInfoIdMap.get(agreement.recordTypeId).getDeveloperName();
agreementMap.put(recordTypeName, agreement);
}
oppIdToAgrRecordTypeNameToAgrRecordMap.put(oppRecord.Id, agreementMap);
}
Map<Id, Account> accountMap = new SLT_Account().selectByAccountId(accountIdSet, accountFieldSet);
Map<Id, Account> agreementIdToAccountMap = new Map<Id, Account>();
for(Apttus__APTS_Agreement__c agreement : newAgreementList) {
if(agreement.Apttus__Account__c != null)
agreementIdToAccountMap.put(agreement.Id, accountMap.get(agreement.Apttus__Account__c));
}
Map<Id, User> userMap = new SLT_User().selectByUserId(new Set<Id>{UserInfo.getUserId()}, userFieldSet);
User runningUser = userMap.values()[0];
String bidType;
String recordTypeName;
Map<String, String> fieldDataTypeToFieldAPINameMap = new UTL_Sobject('Apttus__APTS_Agreement__c').getFieldDataTypeByFieldAPIName();
for(Apttus__APTS_Agreement__c agreement : newAgreementList) {
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
if(oppIdToAgrRecordTypeNameToAgrRecordMap.containsKey(agreement.Apttus__Related_Opportunity__c) && (!oppIdToAgrRecordTypeNameToAgrRecordMap.get(agreement.Apttus__Related_Opportunity__c).containsKey(recordTypeName))) {
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
if(opportunityMap.containsKey(agreement.Apttus__Related_Opportunity__c)) {
if(rebidFieldMapping.SourceValue__c.contains('.')) {
List<String> fieldNames = rebidFieldMapping.SourceValue__c.split('\\.');
fieldValue = (String)opportunityMap.get(agreement.Apttus__Related_Opportunity__c).getSobject(fieldNames[0]).get(fieldNames[1]);
} else {
fieldValue = (String)opportunityMap.get(agreement.Apttus__Related_Opportunity__c).get(rebidFieldMapping.SourceValue__c);       
}
}
} else if(rebidFieldMapping.SourceObject__c == 'Agreement') {
if(oppIdToAgrRecordTypeNameToAgrRecordMap.containsKey(agreement.Apttus__Related_Opportunity__c)) {  
fieldValue = String.valueOf(oppIdToAgrRecordTypeNameToAgrRecordMap.get(agreement.Apttus__Related_Opportunity__c).get(recordTypeName).get(rebidFieldMapping.SourceValue__c) );
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
* @params  newAgreementList List<Apttus__APTS_Agreement__c>
* @return  void
*/
  /*  public static void changeRecordType(List<Apttus__APTS_Agreement__c> newAgreementList) {
        Map<Id, Schema.RecordTypeInfo> recordTypeInfoIdMap = Schema.SObjectType.Apttus__APTS_Agreement__c.getRecordTypeInfosById();
        Map<String, Id> recordTypeDevNameToIdMap = new Map<String, Id>();
        for(Id recordTypeId : recordTypeInfoIdMap.keySet()) {
            recordTypeDevNameToIdMap.put(recordTypeInfoIdMap.get(recordTypeId).getDeveloperName(), recordTypeId);
        }
        String recordTypeName;
        for(Apttus__APTS_Agreement__c agreement : newAgreementList) {
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
            }
        }
        
    }
    
    public static void updateBiotech(List<Apttus__APTS_Agreement__c> newList)
    {
        Set<Id> opportunityIdsSet = new Set<Id>();
        for(Apttus__APTS_Agreement__c newAgreement : newList){
            if(newAgreement.Apttus__Related_Opportunity__c != NULL){
                opportunityIdsSet.add(newAgreement.Apttus__Related_Opportunity__c);
            }
        }
        
        if(!opportunityIdsSet.isEmpty()){
            Set<String> opportunityFieldSet = new Set<String>{'Id','Is_this_IQVIA_Biotech__c'};
                Map<Id, Opportunity>  oppIdToOppMap = new SLT_Opportunity(false, false).getOpportunityById(opportunityIdsSet, opportunityFieldSet);       
            
            for (Apttus__APTS_Agreement__c agreementValue: newList){
                if(!oppIdToOppMap.isEmpty()){
                    if(oppIdToOppMap.containsKey(agreementValue.Apttus__Related_Opportunity__c) && oppIdToOppMap.get(agreementValue.Apttus__Related_Opportunity__c).Is_this_IQVIA_Biotech__c != Null && agreementValue.RecordTypeId == CON_OWF.OWF_CLINICAL_BID_RECORD_TYPE_ID){
                        agreementValue.IQVIA_biotech__c = oppIdToOppMap.get(agreementValue.Apttus__Related_Opportunity__c).Is_this_IQVIA_Biotech__c;
                    }
                }
            }
        }
    }
    
    /*Validate Early Enagagement Bid For RW NmBRE*/
 /*   public static void validateEarlyEngagementBid(List<Apttus__APTS_Agreement__c> newList)
    {
        Mulesoft_Integration_Control__c mulesoftSetting = Mulesoft_Integration_Control__c.getInstance();
        for (Apttus__APTS_Agreement__c agreement: newList)
        {
            if(agreement.RecordTypeId == Schema.SObjectType.Apttus__APTS_Agreement__c.getRecordTypeInfosByDeveloperName().get('Early_Engagement_Bid').getRecordTypeId() &&
               agreement.Resources_Needed__c!=null && agreement.Type_of_Engagement_Activity__c!=null)
            {
                List<String> resourcesNeededList = new List<String>();
                resourcesNeededList = agreement.Resources_Needed__c.split(';');
                List<String> typeOfEngagementActivityList = new List<String>();
                typeOfEngagementActivityList = agreement.Type_of_Engagement_Activity__c.split(';');
                if(!typeOfEngagementActivityList.contains('RW NmBRE') && resourcesNeededList.contains('No Resource Request'))
                    agreement.addError('No Resource Request can only be selected for RW NmBRE Engagement Activity type');
                
                if(typeOfEngagementActivityList.contains('RW NmBRE') && !mulesoftSetting.Ignore_Validation_Rules__c )
                {
                    if(typeOfEngagementActivityList.size()>1)
                        agreement.addError('No other value can be selected in Type of Engagement Activity if RW NmBRE already Present');
                    
                    if(agreement.OWF_Therapy_Area__c != null || agreement.OWF_Indication__c != null || agreement.OWF_Phase__c !=null
                       || agreement.OWF_Lead_Sub_Region__c != null || agreement.OWF_Potential_Regions__c != null || agreement.Is_there_a_Client_Bid_Grid__c != null
                       || agreement.Bid_Number__c > 0)
                        agreement.addError('Following Sections cannot be modified If RW NmBRE is present in Type of Engagement Activity: TSSU/GBO Resourcing, Opportunity Detail, Bid Detail.'); 
                    
                    if(resourcesNeededList.size() == 1)
                    {
                        if(!resourcesNeededList.contains('No Resource Request'))
                            agreement.addError('Select only No Resource Request in Resources Needed for RW NmBRE type of Enagagement Activity');
                    }
                    else
                    {
                        agreement.addError('Select only No Resource Request in Resources Needed for RW NmBRE type of Enagagement Activity');
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
    
  /*
   *   public static void updateBidComplexity(List<Apttus__APTS_Agreement__c> newList){
        for(Apttus__APTS_Agreement__c agreement: newList){
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
                if(requestedDays < 3 && ((agreement.RFP_Ranking__c == '1' && agreement.Budget_Deliverable__c == 'Price per patient' && (agreement.Proposal_Deliverable__c == 'Brief text' || agreement.Proposal_Deliverable__c == 'N/A'))
                    || (agreement.RFP_Ranking__c == '2' && agreement.Budget_Deliverable__c == 'Ballpark' && (agreement.Proposal_Deliverable__c == 'Brief text' || agreement.Proposal_Deliverable__c == 'N/A') && agreement.Number_of_Requested_Services__c < 5 && agreement.Estimated_Fees__c == 'Less than $10M')
                    || (agreement.RFP_Ranking__c == '3' && agreement.Budget_Deliverable__c == 'Awardable' && (agreement.Proposal_Deliverable__c == 'Brief text' || agreement.Proposal_Deliverable__c == 'N/A') && (agreement.Number_of_Requested_Services__c == 1 || agreement.Number_of_Requested_Services__c == 2) && agreement.Estimated_Fees__c == 'Less than $10M' && agreement.Is_there_a_Client_Bid_Grid__c == 'No' && agreement.Is_this_part_of_a_Program__c == 'Not part of a program')
                    || (agreement.RFP_Ranking__c == '4' && agreement.Budget_Deliverable__c == 'Awardable' && (agreement.Proposal_Deliverable__c == 'Full text' || agreement.Proposal_Deliverable__c == 'Strategic text' || agreement.Proposal_Deliverable__c == 'PPT') && (agreement.Number_of_Requested_Services__c < 5) && agreement.Estimated_Fees__c == 'Greater than $10M'))){
                    agreement.Bid_Complexity__c = 'Low';
                    System.debug(LoggingLevel.INFO, '**** bid complexity updated - low (rebid)');
                    }
                else if(((requestedDays >= 3 && requestedDays <= 5) 
                && ((agreement.RFP_Ranking__c == '2' && agreement.Budget_Deliverable__c == 'Ballpark' && agreement.Proposal_Deliverable__c == 'Abbreviated text' && agreement.Number_of_Requested_Services__c >= 5 && agreement.Estimated_Fees__c == 'Greater than $10M')
                || (agreement.RFP_Ranking__c == '3' && agreement.Budget_Deliverable__c == 'Awardable' && (agreement.Proposal_Deliverable__c == 'Abbreviated text' || agreement.Proposal_Deliverable__c == 'Full text' || agreement.Proposal_Deliverable__c == 'PPT') && (agreement.Number_of_Requested_Services__c >= 3 || agreement.Number_of_Requested_Services__c <= 5) && agreement.Requested_Services__c.contains('Clinical Monitoring') && agreement.Estimated_Fees__c == 'Less than $10M' && agreement.Is_there_a_Client_Bid_Grid__c == 'Yes' && (agreement.Is_this_part_of_a_Program__c == 'Yes - lead opportunity' || agreement.Is_this_part_of_a_Program__c == 'Yes - not the lead'))
                || (agreement.RFP_Ranking__c == '4' && agreement.Budget_Deliverable__c == 'Awardable' && (agreement.Proposal_Deliverable__c == 'Full text' || agreement.Proposal_Deliverable__c == 'Strategic text' || agreement.Proposal_Deliverable__c == 'PPT') && agreement.Number_of_Requested_Services__c >= 5 && agreement.Estimated_Fees__c == 'Greater than $10M'))
                || (agreement.RFP_Ranking__c == '5' && agreement.Budget_Deliverable__c == 'Awardable' && (agreement.Proposal_Deliverable__c == 'Full text' || agreement.Proposal_Deliverable__c == 'Strategic text' || agreement.Proposal_Deliverable__c == 'PPT') && agreement.Estimated_Fees__c == 'Greater than $20M' && requestedDays < 3))){
                    agreement.Bid_Complexity__c = 'Med';
                    System.debug(LoggingLevel.INFO, '**** bid complexity updated - med (rebid)');
                }
                else if((requestedDays >= 3 && agreement.RFP_Ranking__c == '1' && agreement.Budget_Deliverable__c == 'Price per patient' && (agreement.Proposal_Deliverable__c == 'Full text' || agreement.Proposal_Deliverable__c == 'PPT' || agreement.Proposal_Deliverable__c == 'Strategic text' || agreement.Proposal_Deliverable__c == 'Abbreviated text')) ||
                (requestedDays >= 3 && agreement.RFP_Ranking__c == '5' && agreement.Budget_Deliverable__c == 'Awardable' && (agreement.Proposal_Deliverable__c == 'Full text' || agreement.Proposal_Deliverable__c == 'Strategic text' || agreement.Proposal_Deliverable__c == 'PPT') && agreement.Estimated_Fees__c == 'Greater than $50M') || 
                ((requestedDays >= 5
                && ((agreement.RFP_Ranking__c == '2' && agreement.Budget_Deliverable__c == 'Ballpark' && (agreement.Proposal_Deliverable__c == 'Full text' || agreement.Proposal_Deliverable__c == 'Strategic text' ||agreement.Proposal_Deliverable__c == 'PPT') && agreement.Number_of_Requested_Services__c > 5 && (agreement.Estimated_Fees__c == 'Greater than $20M' || agreement.Estimated_Fees__c == 'Greater than $25M - GFR' || agreement.Estimated_Fees__c == 'Greater than $50M'))
                || (agreement.RFP_Ranking__c == '3' && agreement.Budget_Deliverable__c == 'Awardable' && (agreement.Proposal_Deliverable__c == 'Full text' || agreement.Proposal_Deliverable__c == 'Strategic text' || agreement.Proposal_Deliverable__c == 'PPT') && agreement.Number_of_Requested_Services__c >= 5 && agreement.Estimated_Fees__c == 'Greater than $10M' && agreement.Is_there_a_Client_Bid_Grid__c == 'Yes' && (agreement.Is_this_part_of_a_Program__c == 'Yes - lead opportunity' || agreement.Is_this_part_of_a_Program__c == 'Yes - not the lead'))
                || (agreement.RFP_Ranking__c == '4' && agreement.Budget_Deliverable__c == 'Awardable' && (agreement.Proposal_Deliverable__c == 'Full text' || agreement.Proposal_Deliverable__c == 'Strategic text' || agreement.Proposal_Deliverable__c == 'PPT') && agreement.Number_of_Requested_Services__c > 5 && agreement.Estimated_Fees__c == 'Greater than $20M'))))){
                    agreement.Bid_Complexity__c = 'High';
                    System.debug(LoggingLevel.INFO, '**** bid complexity updated - high (rebid)');
                }
                else{
                    System.debug(LoggingLevel.INFO, '**** bid complexity updated - empty (rebid)');
                    agreement.Bid_Complexity__c = '';
                }
                
            }
            else{ 
                if((agreement.RFP_Ranking__c == '1' && agreement.Budget_Deliverable__c == 'Price per patient' && (agreement.Proposal_Deliverable__c == 'Brief text' || agreement.Proposal_Deliverable__c == 'N/A'))
                    || (agreement.RFP_Ranking__c == '2' && agreement.Budget_Deliverable__c == 'Ballpark' && (agreement.Proposal_Deliverable__c == 'Brief text' || agreement.Proposal_Deliverable__c == 'N/A') && agreement.Number_of_Requested_Services__c < 5 && agreement.Estimated_Fees__c == 'Less than $10M')
                    || (agreement.RFP_Ranking__c == '3' && agreement.Budget_Deliverable__c == 'Awardable' && (agreement.Proposal_Deliverable__c == 'Brief text' || agreement.Proposal_Deliverable__c == 'N/A') && (agreement.Number_of_Requested_Services__c == 1 || agreement.Number_of_Requested_Services__c == 2) && agreement.Estimated_Fees__c == 'Less than $10M' && agreement.Is_there_a_Client_Bid_Grid__c == 'No' && agreement.Is_this_part_of_a_Program__c == 'Not part of a program')
                    || (agreement.RFP_Ranking__c == '4' && agreement.Budget_Deliverable__c == 'Awardable' && (agreement.Proposal_Deliverable__c == 'Full text' || agreement.Proposal_Deliverable__c == 'Strategic text' || agreement.Proposal_Deliverable__c == 'PPT') && (agreement.Number_of_Requested_Services__c < 5) && agreement.Estimated_Fees__c == 'Greater than $10M')){
                    agreement.Bid_Complexity__c = 'Low';
                    System.debug(LoggingLevel.INFO, '**** bid complexity updated - low');
                }
                else if((agreement.RFP_Ranking__c == '2' && agreement.Budget_Deliverable__c == 'Ballpark' && agreement.Proposal_Deliverable__c == 'Abbreviated text' && agreement.Number_of_Requested_Services__c >= 5 && agreement.Estimated_Fees__c == 'Greater than $10M')
                || (agreement.RFP_Ranking__c == '3' && agreement.Budget_Deliverable__c == 'Awardable' && (agreement.Proposal_Deliverable__c == 'Abbreviated text' || agreement.Proposal_Deliverable__c == 'Full text' || agreement.Proposal_Deliverable__c == 'PPT') && (agreement.Number_of_Requested_Services__c >= 3 || agreement.Number_of_Requested_Services__c <= 5) && agreement.Requested_Services__c.contains('Clinical Monitoring') && agreement.Estimated_Fees__c == 'Less than $10M' && agreement.Is_there_a_Client_Bid_Grid__c == 'Yes' && (agreement.Is_this_part_of_a_Program__c == 'Yes - lead opportunity' || agreement.Is_this_part_of_a_Program__c == 'Yes - not the lead'))
                || (agreement.RFP_Ranking__c == '4' && agreement.Budget_Deliverable__c == 'Awardable' && (agreement.Proposal_Deliverable__c == 'Full text' || agreement.Proposal_Deliverable__c == 'Strategic text' || agreement.Proposal_Deliverable__c == 'PPT') && agreement.Number_of_Requested_Services__c >= 5 && agreement.Estimated_Fees__c == 'Greater than $10M')
                || (agreement.RFP_Ranking__c == '5' && agreement.Budget_Deliverable__c == 'Awardable' && (agreement.Proposal_Deliverable__c == 'Full text' || agreement.Proposal_Deliverable__c == 'Strategic text' || agreement.Proposal_Deliverable__c == 'PPT') && agreement.Estimated_Fees__c == 'Greater than $20M')){
                    agreement.Bid_Complexity__c = 'Med';
                    System.debug(LoggingLevel.INFO, '**** bid complexity updated - med ');
                }
                else if((agreement.RFP_Ranking__c == '1' && agreement.Budget_Deliverable__c == 'Price per patient' && (agreement.Proposal_Deliverable__c == 'Full text' || agreement.Proposal_Deliverable__c == 'PPT' || agreement.Proposal_Deliverable__c == 'Strategic text' || agreement.Proposal_Deliverable__c == 'Abbreviated text') && requestedDays >= 3)
                || (agreement.RFP_Ranking__c == '5' && agreement.Budget_Deliverable__c == 'Awardable' && (agreement.Proposal_Deliverable__c == 'Full text' || agreement.Proposal_Deliverable__c == 'Strategic text' || agreement.Proposal_Deliverable__c == 'PPT') && agreement.Estimated_Fees__c == 'Greater than $50M' && requestedDays >= 3)
                || (agreement.RFP_Ranking__c == '2' && agreement.Budget_Deliverable__c == 'Ballpark' && (agreement.Proposal_Deliverable__c == 'Full text' || agreement.Proposal_Deliverable__c == 'Strategic text' ||agreement.Proposal_Deliverable__c == 'PPT') && agreement.Number_of_Requested_Services__c >= 5 && (agreement.Estimated_Fees__c == 'Greater than $20M' || agreement.Estimated_Fees__c == 'Greater than $25M - GFR' || agreement.Estimated_Fees__c == 'Greater than $50M'))
                || (agreement.RFP_Ranking__c == '3' && agreement.Budget_Deliverable__c == 'Awardable' && (agreement.Proposal_Deliverable__c == 'Full text' || agreement.Proposal_Deliverable__c == 'Strategic text' || agreement.Proposal_Deliverable__c == 'PPT') && agreement.Number_of_Requested_Services__c >= 5 && agreement.Estimated_Fees__c == 'Greater than $10M' && agreement.Is_there_a_Client_Bid_Grid__c == 'Yes' && (agreement.Is_this_part_of_a_Program__c == 'Yes - lead opportunity' || agreement.Is_this_part_of_a_Program__c == 'Yes - not the lead'))
                || (agreement.RFP_Ranking__c == '4' && agreement.Budget_Deliverable__c == 'Awardable' && (agreement.Proposal_Deliverable__c == 'Full text' || agreement.Proposal_Deliverable__c == 'Strategic text' || agreement.Proposal_Deliverable__c == 'PPT') && agreement.Number_of_Requested_Services__c >= 5 && agreement.Estimated_Fees__c == 'Greater than $20M')){
                    agreement.Bid_Complexity__c = 'High';
                    System.debug(LoggingLevel.INFO, '**** bid complexity updated - high ');
                }
                else{
                    agreement.Bid_Complexity__c = '';
                    System.debug(LoggingLevel.INFO, '**** bid complexity updated - empty ');
                }
            }
        }
    }
 
    public static void updateResourcesNeededFromAgreement(List<Apttus__APTS_Agreement__c> newList, Map<Id, Apttus__APTS_Agreement__c> oldMap) 
    {
        Map<Id, Apttus__APTS_Agreement__c> agrIdToAgreementMap = new Map<Id, Apttus__APTS_Agreement__c>();
        Set<Id> rrAgreementIdSet = new Set<Id>();        
        Map<Id,pse__Resource_Request__c> oldRRfromAgreement = new Map<Id,pse__Resource_Request__c>();        
        Set<String> resReqFieldSet = new Set<String>{'Id', 'pse__Opportunity__c', 'Agreement__c', 
        'Resource_Request_Type__c', 'Complexity_Score_Total__c', 'SubGroup__c',
        'CreatedDate','Workload_Ranking__c','Suggested_FTE__c','pse__Start_Date__c',
        'pse__Start_Date__c','pse__End_Date__c', 'Is_Bid_Defense__c','pse__Status__c','Regional_Analytics_Country__c'};
        Map<String, OWF_Resources_Needed_to_SubGroup_Map__c> resourcesNeededToSubGrpMap = new Map<String,OWF_Resources_Needed_to_SubGroup_Map__c>();
        resourcesNeededToSubGrpMap = OWF_Resources_Needed_to_SubGroup_Map__c.getAll();
        List<String> resourcesNeededList = new List<String>();
        List<pse__Resource_Request__c> rrList = new List<pse__Resource_Request__c>();
        
        try{
            for(Apttus__APTS_Agreement__c agr : newList) 
            {     
                if(agr.recordTypeId == CON_OWF.OWF_NON_RFP_BID_RECORD_TYPE_ID || agr.recordTypeId == CON_OWF.OWF_EARLY_ENGAGEMENT_BID_RECORD_TYPE_ID || agr.recordTypeId == CON_OWF.OWF_POST_AWARD_BID_RECORD_TYPE_ID){
                    if(agr.Resources_Needed__c !=  oldMap.get(agr.Id).Resources_Needed__c){
                        rrAgreementIdSet.add(agr.id);
                        agrIdToAgreementMap.put(agr.id,agr);
                    }   
                }
            }
			
            if(agrIdToAgreementMap.size() > 0)
            {
                oldRRfromAgreement = new SLT_Resource_Request(false,false).getResourceRequestByAgrID(rrAgreementIdSet,resReqFieldSet);
                
                for(Apttus__APTS_Agreement__c agreement : agrIdToAgreementMap.values()) 
                {   
                    if(agreement.Resources_Needed__c != Null && String.IsNotBlank(agreement.Resources_Needed__c))
                        resourcesNeededList = agreement.Resources_Needed__c.split(';');
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
                        for(Integer i = 0; i < resourcesNeededList.size(); i++)
                        {
                            for(pse__Resource_Request__c oldList : oldRRfromAgreement.values()){
                                if(resourcesNeededToSubGrpMap.get(resourcesNeededList.get(i)).Sub_Group__c == oldList.SubGroup__c){
                                    resourcesNeededList.remove(i);
                                    i--;
                                    break;
                                }
                            }
                        }
                    } 

                    for(String resourceNeeded : resourcesNeededList) {
                        pse__Resource_Request__c newRR = new pse__Resource_Request__c(
                           recordTypeId = CON_OWF.OWF_RR_RECORD_TYPE_ID,
                           currencyIsoCode = agreement.currencyIsoCode,
                           pse__Opportunity__c = agreement.Apttus__Related_Opportunity__c,
                           pse__Group__c = owfStdGroupId,
                           Account__c = agreement.Apttus__Account__c,
                           Agreement__c = agreement.Id,
                           SubGroup__c = resourcesNeededToSubGrpMap.containsKey(resourceNeeded)? resourcesNeededToSubGrpMap.get(resourceNeeded).Sub_Group__c:'',
                           pse__Start_Date__c = Date.Today(),
                           pse__End_Date__c = agreement.Bid_Due_Date__c,
                           pse__SOW_Hours__c = 0.01,
                           Is_Created_Automatically_Initial_Bid__c = True,
                           Is_Created_Automatically__c = True
                        );
                        rrList.add(newRR);   
                    }                      
                }
            }
            
            if(rrList.size() > 0)
                insert rrList;
        }catch(Exception e){
            system.debug('updateResourcesNeededFromAgreementError: ' + e.getMessage() + ' at Line number: ' + e.getLineNumber());
        }
    }*/
}