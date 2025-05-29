/**
* This is Assignment trigger handler class.
* version : 1.0
*/
public without sharing class DAOH_OWF_Assignment {
    private static boolean run = true;
    
    public static void createClinicalBidResRequestsOnAssignmentUpdate(List<pse__Assignment__c> newList, Map<Id, pse__Assignment__c> oldMap) {
        Set<Id> agreementIdsSet = new Set<Id>();
        Set<String> agreementFieldSet = new Set<String>{'Bid_History_Related_Opportunity__r.id'};
        Set<Id> OppIdSet = new Set<Id>();
        SLT_Bid_History sltAgreement = new SLT_Bid_History(false,false);
        for(pse__Assignment__c newAssignment : newList)
        {
            if(newAssignment.recordTypeId == CON_OWF.OWF_ASSIGNMENT_RECORD_TYPE_ID && newAssignment.pse__Status__c != oldMap.get(newAssignment.id).pse__Status__c 
               && newAssignment.pse__Status__c == 'Accepted')
            {
                agreementIdsSet.add(newAssignment.Bid_History__c);
            }           
        }
        List<Bid_History__c> agrList = new List<Bid_History__c>();
        if(agreementIdsSet.size() > 0){
            agrList = sltAgreement.getBidHistoryFieldsById(agreementIdsSet,agreementFieldSet);
        }
        if(agrList.size() > 0)
        {
            for(Bid_History__c agg : agrList)
            {
                OppIdSet.add(agg.Bid_History_Related_Opportunity__c);
            }
            if(UTL_OWF.isLoginUserhasPermissionControl())
            {
                String agrCondition = 'Bid_History_Related_Opportunity__c != NULL And Bid_History_Related_Opportunity__c IN :sObjectIdSet ' +
                                        ' And RecordTypeId = \'' + CON_OWF.OWF_CLINICAL_BID_BID_HISTORY_RECORD_TYPE_ID + '\'';
                
                List<pse__Resource_Request__c> reqRequestsInsertList = new List<pse__Resource_Request__c>();
                reqRequestsInsertList = UTL_OWF.processResRequestForInitialBids(OppIdSet, agrCondition, null, null);
                if(reqRequestsInsertList.size() > 0) {
                    insert reqRequestsInsertList;
                }
            }
            else
            {
                for(pse__Assignment__c assignmt : newList) {
                    assignmt.adderror('The system is trying to staff Bid Defense Resource Requests, but you do not have the required staffing permissions.');
                } 
            }  
        }
    }

/**
* This method is used to set opportunity Name
* @params  newList List<pse__Assignment__c>
* @return  void
*/ 
    public static void insertOpportunityNameInAssignment(List<pse__Assignment__c> newList)
    {
        Set<Id> agreementIdsSet = new Set<Id>();
        
        for(pse__Assignment__c newAssignment : newList){
            if(newAssignment.Bid_History__c != NULL && newAssignment.recordTypeId == CON_OWF.OWF_ASSIGNMENT_RECORD_TYPE_ID) {
                agreementIdsSet.add(newAssignment.Bid_History__c);
            }
        }
        
        if(!agreementIdsSet.isEmpty()){
            Set<String> agreementFieldSet = new Set<String>{'Id', 'Bid_History_Related_Opportunity__c','Bid_History_Related_Opportunity__r.Id'};
            Map<Id, Bid_History__c>  agrIdAgreementMap = new SLT_Bid_History(false,false).getBidHistoriesById(agreementIdsSet, agreementFieldSet);       
            
            for (pse__Assignment__c assignmentValue: newList){
                if(!agrIdAgreementMap.isEmpty() && agrIdAgreementMap.containsKey(assignmentValue.Bid_History__c)){
                    assignmentValue.Lookup_Opportunity_Name__c = agrIdAgreementMap.get(assignmentValue.Bid_History__c).Bid_History_Related_Opportunity__r.Id;
                }
            }
        }
    }
    
    
    /**
* This method is used to set Estimated Effort.
* @params  newList List<pse__Assignment__c>
* @return  void
*/ 
    
    public static void updateEffortEstimation(List<pse__Assignment__c> newList)
    {
        Set<Id> resourceIdsSet = new Set<Id>();
        
        for(pse__Assignment__c newAssignment : newList){
            if(newAssignment.pse__Resource_Request__c != NULL && newAssignment.recordTypeId == CON_OWF.OWF_ASSIGNMENT_RECORD_TYPE_ID) {
                resourceIdsSet.add(newAssignment.pse__Resource_Request__c);
            }
        }
        
        if(!resourceIdsSet.isEmpty()){
            Set<String> resourceRequestFieldSet = new Set<String>{'Id', 'Suggested_FTE__c'};
            Map<Id, pse__Resource_Request__c>  rrIdResourceRequestMap = new SLT_Resource_Request(false,false).selectResReqsById(resourceIdsSet, resourceRequestFieldSet);       
            
            for (pse__Assignment__c assignmentValue: newList){
                if(!rrIdResourceRequestMap.isEmpty() && rrIdResourceRequestMap.containsKey(assignmentValue.pse__Resource_Request__c)){
                    assignmentValue.Estimation_Effort__c = rrIdResourceRequestMap.get(assignmentValue.pse__Resource_Request__c).Suggested_FTE__c;
                }
            }
        }
    }
    
    
    
/**
* This method is used to validate Estimated Effort.
* @params  newList List<pse__Assignment__c>
* @return  void
*/
   /* public static void validateEffortEstimation(List<pse__Assignment__c> newList, Map<Id, pse__Assignment__c> oldMap){
        Mulesoft_Integration_Control__c mulesoftSetting = Mulesoft_Integration_Control__c.getInstance();
        
        Set<String> contactFieldSet = new Set<String>{'Id', 'pse__Salesforce_User__c','Sub_Group__c'};
        List<Contact> contactList = new SLT_Contact().selectByPseSalesforceUserIdList(new Set<Id>{UserInfo.getUserId()}, contactFieldSet);
        
        List<PermissionSetAssignment> triageManagerPermissionList = new List<PermissionSetAssignment>();
        triageManagerPermissionList = [SELECT  PermissionSet.Name, AssigneeId, Assignee.Name 
                                       FROM PermissionSetAssignment 
                                       WHERE PermissionSet.Name = 'OWF_Triage_Manager' and AssigneeId = :userInfo.getUserId() limit 1];
        
        boolean allowToEdit = true;
        for(Contact newContact: contactList){
            if(triageManagerPermissionList.size() == 0 && newContact.Sub_Group__c != null && (newContact.Sub_Group__c.contains('GBO') || newContact.Sub_Group__c.contains('DSB'))){
               allowToEdit = false;
            }
        }
        
        for(pse__Assignment__c assignment : newList)
        {
            pse__Assignment__c oldAssignment = oldMap.get(assignment.id);
            if(!mulesoftSetting.Ignore_Validation_Rules__c) {
                if(oldAssignment.Estimation_Effort__c != assignment.Estimation_Effort__c && allowToEdit == false && assignment.recordTypeId == CON_OWF.OWF_ASSIGNMENT_RECORD_TYPE_ID ){
                    assignment.Estimation_Effort__c.addError('You cannot edit this field');
                }
            }
        }
    }*/
    
/**
* This method is used to set Number of Requested Services based on selected Requested Services.
* @params  newList List<Bid_History__c>
* @params  oldMap Map<Id, Bid_History__c>
* @return  void
*/
    public static void createSkillCertRatingsOnAssignCompleted(List<pse__Assignment__c> newList, Map<Id, pse__Assignment__c> oldMap) {
        Set<Id> assignmentResRequestIdsSet = new Set<Id>();
        Set<Id> assignmentResourceIdsSet = new Set<Id>();
        Map<Id,pse__Assignment__c> assignmentMap = new Map<Id,pse__Assignment__c>();
        Set<Id> assignmentIdsSet = new Set<Id>();
        String assignmentCondition = 'Id IN :sObjectIdSet';
        Set<String> AssignmentFieldSet = new Set<String>{'Id','pse__Resource__r.Secondary_Sub_Group__c','pse__Resource__r.Sub_Group__c','pse__Resource__c','pse__Resource_Request__c'};
            for(pse__Assignment__c assignment : newList) {
                if(assignment.recordTypeId == CON_OWF.OWF_ASSIGNMENT_RECORD_TYPE_ID && assignment.pse__Status__c != oldMap.get(assignment.Id).pse__Status__c && assignment.pse__Status__c == CON_OWF.OWF_STATUS_COMPLETED) {
                    assignmentIdsSet.add(assignment.id);
                }
            }
        if(!assignmentIdsSet.isEmpty()){
            assignmentMap = new SLT_Assignment().selectAssignmentsByIdSet(assignmentIdsSet,assignmentCondition,AssignmentFieldSet);
            
        }     
        for(pse__Assignment__c assignment : assignmentMap.values())
        {
            if(assignment.pse__Resource__c != null && assignment.pse__Resource_Request__c != null
               && (assignment.pse__Resource__r.Sub_Group__c == null || !assignment.pse__Resource__r.Sub_Group__c.contains('GBO'))
               && (assignment.pse__Resource__r.Secondary_Sub_Group__c == null || !assignment.pse__Resource__r.Secondary_Sub_Group__c.contains('GBO'))){
                   assignmentResRequestIdsSet.add(assignment.pse__Resource_Request__c);
                   assignmentResourceIdsSet.add(assignment.pse__Resource__c);
               }
        }
        if(!assignmentResRequestIdsSet.isEmpty()){
            List<pse__Skill_Certification_Rating__c> skillCertRatingInsertList = validateAndCreateSkillCertRatingsToRelatedResource(newList, oldMap, assignmentResRequestIdsSet, assignmentResourceIdsSet);
            if(skillCertRatingInsertList.size() > 0) {
                insert skillCertRatingInsertList;
            }
        }
    }
    
    /**
    * This method is used to set Number of Requested Services based on selected Requested Services.
    * @params  newList List<Bid_History__c>
    * @params  oldMap Map<Id, Bid_History__c>
    * @params  Set<Id> assignmentResRequestIdsSet
    * @params  Set<Id> assignmentResourceIdsSet
    * @return  List<pse__Skill_Certification_Rating__c> 
    */
    private static List<pse__Skill_Certification_Rating__c> validateAndCreateSkillCertRatingsToRelatedResource(List<pse__Assignment__c> newList, Map<Id, pse__Assignment__c> oldMap, Set<Id> assignmentResRequestIdsSet, Set<Id> assignmentResourceIdsSet) {
        List<pse__Skill_Certification_Rating__c> skillCertRatingInsertList = new List<pse__Skill_Certification_Rating__c>();
        Map<Id, pse__Resource_Request__c> rrIdToRresourceRequestWithSkillMap = new Map<Id, pse__Resource_Request__c>();
        Map<Id, pse__Skill_Certification_Rating__c> scrIdToSkillCertiRatingMap = new Map<Id, pse__Skill_Certification_Rating__c>();
        Map<Id, Map<Id, pse__Skill_Certification_Rating__c>> scrIdToSkillCertRatingWithContactMap = new Map<Id, Map<Id, pse__Skill_Certification_Rating__c>>();
        
        if(assignmentResRequestIdsSet.size() > 0) {
            String resReqCondition = 'Id IN :sObjectIdSet And RecordType.DeveloperName = \'' + CON_OWF.OWF_RESOURCE_REQUEST_RECORD_TYPE_NAME + '\'';
            Set<String> resRequestFieldSet = new Set<String>{'Id', 'pse__Assignment__c', 'Therapy_Area__c', 'Indication__c'};
                Set<String> resSkillRequestFieldSet = new Set<String>{'Id', 'pse__Is_Primary__c', 'pse__Resource_Request__c', 'pse__Skill_Certification__c', 'pse__Skill_or_Certification__c', 'pse__Skill_Record_Type__c'};
                    String resSkillReqCondition = '(pse__Skill_Certification__r.pse__Type__c = \'' + CON_OWF.SKILL_TYPE_INDICATION + '\')';
                    //Automatic creation of skill rating of type Line of Business and Potential Region is not needed.
                    /*+ '\' OR pse__Skill_Certification__r.pse__Type__c = \''  + CON_OWF.SKILL_TYPE_LINE_OF_BUSINESS 
                    + '\' OR pse__Skill_Certification__r.pse__Type__c = \''  + CON_OWF.SKILL_TYPE_POTENTIAL_REGION + '\')';*/
            rrIdToRresourceRequestWithSkillMap = new SLT_Resource_Request(false,false).selectByIdWithResReqsAndRSRs(assignmentResRequestIdsSet, resReqCondition, resRequestFieldSet, resSkillRequestFieldSet, resSkillReqCondition);
        }
        
        if(assignmentResourceIdsSet.size() > 0) {
            String skillCertRatingCondition = ' pse__Resource__c IN :sObjectIdSet AND Active__c = True';
            Set<String> skillCertRatingFieldSet = new Set<String>{'Id', 'pse__Resource__c',  'pse__Skill_Certification__c', 'pse__Rating__c', 'Active__c'};
            scrIdToSkillCertiRatingMap = new SLT_Skill_Certification_Rating(false,false).getSkillCertificationRatingsByContactIds(assignmentResourceIdsSet, skillCertRatingCondition, skillCertRatingFieldSet);
            
            if(!scrIdToSkillCertiRatingMap.IsEmpty()) {
                for(pse__Skill_Certification_Rating__c skillCertRating : scrIdToSkillCertiRatingMap.values()) {
                    if(!scrIdToSkillCertRatingWithContactMap.containsKey(skillCertRating.pse__Resource__c)) {
                        scrIdToSkillCertRatingWithContactMap.put(skillCertRating.pse__Resource__c, new Map<Id, pse__Skill_Certification_Rating__c>());
                    }
                    scrIdToSkillCertRatingWithContactMap.get(skillCertRating.pse__Resource__c).put(skillCertRating.pse__Skill_Certification__c, skillCertRating);
                }
            }
        }
        
        if(!rrIdToRresourceRequestWithSkillMap.IsEmpty()) {
            for(pse__Assignment__c assignment : newList) {
                if(assignment.pse__Status__c != oldMap.get(assignment.Id).pse__Status__c && assignment.pse__Status__c == CON_OWF.OWF_STATUS_COMPLETED && rrIdToRresourceRequestWithSkillMap.containsKey(assignment.pse__Resource_Request__c) && rrIdToRresourceRequestWithSkillMap.get(assignment.pse__Resource_Request__c).pse__Resource_Skill_Requests__r.size() > 0) {
                    for(pse__Resource_Skill_Request__c resSkillReq : rrIdToRresourceRequestWithSkillMap.get(assignment.pse__Resource_Request__c).pse__Resource_Skill_Requests__r) {
                        if(scrIdToSkillCertRatingWithContactMap.containsKey(assignment.pse__Resource__c) && !scrIdToSkillCertRatingWithContactMap.get(assignment.pse__Resource__c).containsKey(resSkillReq.pse__Skill_Certification__c)) {
                            pse__Skill_Certification_Rating__c resSkillCertRatingRec = createResourceSkillCertificationRating(assignment.pse__Resource__c, resSkillReq.pse__Skill_Certification__c);
                            skillCertRatingInsertList.add(resSkillCertRatingRec);
                            scrIdToSkillCertRatingWithContactMap.get(assignment.pse__Resource__c).put(resSkillReq.pse__Skill_Certification__c, resSkillCertRatingRec);
                        }else if(!scrIdToSkillCertRatingWithContactMap.containsKey(assignment.pse__Resource__c)) {
                            pse__Skill_Certification_Rating__c resSkillCertRatingRec = createResourceSkillCertificationRating(assignment.pse__Resource__c, resSkillReq.pse__Skill_Certification__c);
                            skillCertRatingInsertList.add(resSkillCertRatingRec); 
                            scrIdToSkillCertRatingWithContactMap.put(assignment.pse__Resource__c, new Map<Id, pse__Skill_Certification_Rating__c>());   
                            scrIdToSkillCertRatingWithContactMap.get(assignment.pse__Resource__c).put(resSkillReq.pse__Skill_Certification__c, resSkillCertRatingRec);
                        }
                    }
                }
            }
        }
        return skillCertRatingInsertList;
    }
    
    /**
    * This method is used to create Skill/Certification Rating record
    * @params  Id resourceId
    * @params  Id skillCertificaitonId
    * @return  pse__Skill_Certification_Rating__c
    */
    private static pse__Skill_Certification_Rating__c createResourceSkillCertificationRating(Id resourceId, Id skillCertificaitonId) {
        pse__Skill_Certification_Rating__c skillCertificationRatingRec = new pse__Skill_Certification_Rating__c();
        skillCertificationRatingRec.pse__Resource__c = resourceId;
        skillCertificationRatingRec.pse__Skill_Certification__c = skillCertificaitonId;
        skillCertificationRatingRec.pse__Rating__c = '1 - Limited Exposure';
        skillCertificationRatingRec.Active__c = True;
        return skillCertificationRatingRec;
    }
    
    
    /**
    * This method is used to rollup the Assignments fields on the Resource.
    * @params  newAssignmentList List<pse__Assignment__c>
    * @params  oldAssignmentMap Map<Id,pse__Assignment__c>
    * @return  void
    */
    public static void populateRollupAssignmentFieldsOnContact(List<pse__Assignment__c> newAssignmentList, Map<Id,pse__Assignment__c> oldAssignmentMap){
        Set<Id> resourceIdSet = new Set<Id>();
        
        for(pse__Assignment__c assignment : newAssignmentList){
            if(assignment.recordTypeId == CON_OWF.OWF_ASSIGNMENT_RECORD_TYPE_ID) {
                if(oldAssignmentMap != null && (assignment.pse__Status__c != oldAssignmentMap.get(assignment.Id).pse__Status__c ||
                                                                             assignment.Suggested_FTE__c != oldAssignmentMap.get(assignment.Id).Suggested_FTE__c ||
                                                                             assignment.Estimation_Effort__c != oldAssignmentMap.get(assignment.Id).Estimation_Effort__c ||
                                                                             assignment.pse__Resource__c != oldAssignmentMap.get(assignment.Id).pse__Resource__c)){
                                                                                 
                                                                                 if(assignment.pse__Resource__c != oldAssignmentMap.get(assignment.Id).pse__Resource__c && oldAssignmentMap.get(assignment.Id).pse__Resource__c != null){
                                                                                     resourceIdSet.add(assignment.pse__Resource__c);
                                                                                 }
                                                                                 if(assignment.pse__Resource__c != null){
                                                                                     resourceIdSet.add(assignment.pse__Resource__c);
                                                                                 } 
                                                                             }else if(assignment.pse__Resource__c != null && oldAssignmentMap == null){
                                                                                 resourceIdSet.add(assignment.pse__Resource__c);
                                                                             }
            }
        }
        if(!resourceIdSet.isEmpty()){
            String assignmentCondition = ' pse__Resource__c IN :sObjectIdSet AND pse__Status__c in (\'Accepted\' ,\'Pending\')';
            Set<String> assignmentFieldSet = new Set<String>{'Id', 'pse__Resource__c','pse__Start_Date__c', 'pse__Status__c', 'Suggested_FTE__c','Estimation_Effort__c'};
            List<pse__Assignment__c> assignmentList = new SLT_Assignment(false,false).getAssignmentByResource(resourceIdSet, assignmentCondition, assignmentFieldSet);
            updateRollupAssignmentFieldsOnContact(assignmentList,resourceIdSet);
            
        }
        
    }
    
    /**
    * This method is used to update the Assignments fields on the Resource.
    * @params  assignmentList List<pse__Assignment__c>
    * @return  void
    */
    public static void updateRollupAssignmentFieldsOnContact(List<pse__Assignment__c> assignmentList,Set<Id> resourceIdSet){
        Map<Id,List<pse__Assignment__c>> resourceIdToRelatedAssignmentListMap = new Map<Id,List<pse__Assignment__c>>();
        try{
            if(!assignmentList.isEmpty()){
                for(pse__Assignment__c assignment : assignmentList){
                    if(!resourceIdToRelatedAssignmentListMap.containsKey(assignment.pse__Resource__c)){
                        resourceIdToRelatedAssignmentListMap.put(assignment.pse__Resource__c, new List<pse__Assignment__c>());
                    }
                    resourceIdToRelatedAssignmentListMap.get(assignment.pse__Resource__c).add(assignment);
                }   
            }else{
                for(Id i : resourceIdSet){
                    resourceIdToRelatedAssignmentListMap.put(i,new List<pse__Assignment__c>());
                }
            }
            
            List<Contact> updatedResourceList = new List<Contact>();
            Decimal pendingRecordsCount;
            Decimal pendingFTECount;
            Decimal acceptedRecordsCount;
            Decimal currentFTECount;
            Contact contactRecord;
            for(Id resourceId : resourceIdToRelatedAssignmentListMap.keySet()){
                pendingRecordsCount = 0;
                pendingFTECount = 0;
                acceptedRecordsCount = 0;
                currentFTECount = 0;
                
                if(resourceIdToRelatedAssignmentListMap.get(resourceId).size() > 0){
                    for(pse__Assignment__c assignment : resourceIdToRelatedAssignmentListMap.get(resourceId)){
                        if(assignment.pse__Status__c == 'Pending'){
                            if(assignment.Estimation_Effort__c != NULL){
                                pendingRecordsCount++; 
                                pendingFTECount += assignment.Estimation_Effort__c;
                            }else{
                                pendingRecordsCount++; 
                                pendingFTECount += assignment.Suggested_FTE__c;
                            }
                        }else if(assignment.pse__Status__c == 'Accepted'){
                            acceptedRecordsCount++;
                            if(assignment.pse__Start_Date__c <= Date.today() && assignment.Estimation_Effort__c != NULL){
                                currentFTECount += assignment.Estimation_Effort__c;
                            }else if(assignment.pse__Start_Date__c <= Date.today()){
                                currentFTECount += assignment.Suggested_FTE__c;
                            }                          
                        }
                    }
                }
                contactRecord = new Contact(Id = resourceId);
                contactRecord.Pending_FTE_Sum__c = pendingFTECount;
                contactRecord.Current_FTE_Sum__c = currentFTECount ;
                contactRecord.COUNT_Assignemnts_Pending__c = pendingRecordsCount;
                contactRecord.COUNT_Assignemnts_Accepted__c = acceptedRecordsCount;
                
                updatedResourceList.add(contactRecord);
            }
            
            if(!updatedResourceList.isEmpty()){
                update updatedResourceList;
            }    
        }catch(Exception e){
            system.debug('Error: ' + e.getMessage() + ' at Line number: ' + e.getLineNumber());
        }
    }
    
     /**
    * This method is used to reassign/Update the owner of the Assignment.
    * @params  newList List<Bid_History__c>
    * @params  oldMap Map<Id, Bid_History__c>
    * @return  void
    */
    public static void updateAssignmentOwner(List<pse__Assignment__c> newList, Map<Id, pse__Assignment__c> oldMap) {
        Map<id,Id> resourceIdToUserIdMap = new Map<id,Id>();
        set<id> resourceIdSet = new set<id>();
        List<Contact> contactList= new List<Contact>();
        pse__Assignment__c assignmnetOld = new pse__Assignment__c();
        
        for (pse__Assignment__c assignmnetNew : newList) {
            if(assignmnetNew.recordTypeId == CON_OWF.OWF_ASSIGNMENT_RECORD_TYPE_ID) {
                resourceIdSet.add(assignmnetNew.pse__Resource__c);
            }
        }
       
        if(!resourceIdSet.isEmpty()){
            Set<String> resourceFieldSet = new Set<String>{'Id', 'Salesforce_User__c', 'pse__Salesforce_User__c'};
                contactList = new SLT_Contact().selectByContactIdList(resourceIdSet, resourceFieldSet);       
        }
        
        for (Contact resource : contactList) {
            if(resource.pse__Salesforce_User__c != null){
                resourceIdToUserIdMap.put(resource.id,resource.pse__Salesforce_User__c);
            }
        }   
         
        for (pse__Assignment__c assignmnetNew : newList) { 
            
            if(oldMap != null && oldMap.containskey(assignmnetNew.Id)){
                assignmnetOld = oldMap.get(assignmnetNew.Id);
            }
            if(resourceIdToUserIdMap != null && resourceIdToUserIdMap.containsKey(assignmnetNew.pse__Resource__c) && resourceIdToUserIdMap.get(assignmnetNew.pse__Resource__c) != null && ((Trigger.isInsert && assignmnetNew.pse__Resource__c != null) || ( Trigger.isUpdate && (assignmnetNew.pse__Resource__c != assignmnetOld.pse__Resource__c || assignmnetNew.OwnerId != resourceIdToUserIdMap.get(assignmnetNew.pse__Resource__c))))){
                assignmnetNew.OwnerId = resourceIdToUserIdMap.get(assignmnetNew.pse__Resource__c);
            }
        }
    } 
    
         /**
    * This method is used to to set the owner of the Agreement, based on the Assignment.
    * @params  newList List<Bid_History__c>
    * @params  oldMap Map<Id, Bid_History__c>
    * @return  void
    */
    public static void updateAgreementOwnerByAssignment(List<pse__Assignment__c> newList, Map<Id, pse__Assignment__c> oldMap) {
        pse__Assignment__c assignmnetOld = new pse__Assignment__c();
        pse__Assignment__c newAssignment;
        Map<Id,Bid_History__c> agreementMapTobeUpdated = new Map<Id,Bid_History__c>();
        Map<Id,List<Investigator_Grant__c>> bidHistoryIdtoIGMap = new Map<Id,List<Investigator_Grant__c>>();
        set<id> bidHistoryIdSet = new set<id>();
        List<Investigator_Grant__c> iGToBeUpdatedList = new List<Investigator_Grant__c>();
        Set<Id> AssignmentIdSets = new Set<Id>();
        List<Bid_History__c> updatedAgreementList = new List<Bid_History__c>();
        Map<Id,pse__Assignment__c> assignmentIdToAssignmentMap = new Map<Id,pse__Assignment__c>();
        
        
        for (pse__Assignment__c assignmnetNew : newList) {
            if(assignmnetNew.recordTypeId == CON_OWF.OWF_ASSIGNMENT_RECORD_TYPE_ID) {
                AssignmentIdSets.add(assignmnetNew.Id);
                if(assignmnetNew.Subgroup_Name__c == CON_OWF.RES_REQ_TYPE_IG_LEAD){
                    bidHistoryIdSet.add(assignmnetNew.Bid_History__c);
                }
            }
        } 
        if(!AssignmentIdSets.isEmpty()){
            Set<String> assignmentFieldSet = new Set<String>{'pse__Resource_Request__r.Id', 'pse__Resource_Request__r.SubGroup__c','pse__Resource_Request__r.Is_Created_Automatically__c','pse__Resource_Request__r.Bid_History__r.RecordTypeId','pse__Resource_Request__r.pse__End_Date__c',
                'pse__Resource__r.Id', 'pse__Resource__r.Salesforce_User__c', 'pse__Resource__r.pse__Salesforce_User__c',
                'Bid_History__r.Id', 'Bid_History__r.OwnerId','Bid_History__r.User__c'};
				String assignCondition = 'Id in: sObjectIdset';
                    assignmentIdToAssignmentMap = new SLT_Assignment().selectAssignmentsByIdSet(AssignmentIdSets,assignCondition,assignmentFieldSet);
            
        }
        if(!bidHistoryIdSet.isEmpty()){
            Set<String> investigatorGrantFieldSet = new Set<String>{'Id', 'Assigned_Investigator_Grants_Developer__c','Bid_History__c'};
            String condition = 'Bid_History__c in: sObjectIdset';
            for(Investigator_Grant__c ig : new SLT_InvestigatorGrant(false,false).getInvestigatorGrantByBidHistoryId(bidHistoryIdSet,condition,investigatorGrantFieldSet)){
                if(!bidHistoryIdtoIGMap.containsKey(ig.Bid_History__c)){
                    bidHistoryIdtoIGMap.put(ig.Bid_History__c, new List<Investigator_Grant__c>{ig});
                }
                else{
                    bidHistoryIdtoIGMap.get(ig.Bid_History__c).add(ig);
                }
            }
        }
        for (pse__Assignment__c assignmnetNew : newList) { 
            
            if(oldMap != null && oldMap.containskey(assignmnetNew.Id)){
                assignmnetOld = oldMap.get(assignmnetNew.Id);
            }

            if(!assignmentIdToAssignmentMap.isEmpty() && assignmentIdToAssignmentMap.containsKey(assignmnetNew.id)){
                newAssignment = assignmentIdToAssignmentMap.get(assignmnetNew.id);
                
                if((newAssignment.pse__Resource__c != null && assignmnetNew.pse__Status__c == 'Accepted' && 
                    newAssignment.pse__Resource_Request__r.SubGroup__c != null && 
                    newAssignment.pse__Resource_Request__r.Is_Created_Automatically__c && 
                    newAssignment.pse__Resource_Request__r.SubGroup__c == CON_OWF.RES_REQ_TYPE_IG_LEAD)){
                        if(bidHistoryIdtoIGMap.get(newAssignment.Bid_History__c) != null){
                            for(Investigator_Grant__c ig : bidHistoryIdtoIGMap.get(newAssignment.Bid_History__c)){
                                iGToBeUpdatedList.add(new Investigator_Grant__c(id = ig.id,Assigned_Investigator_Grants_Developer__c = newAssignment.pse__Resource__r.pse__Salesforce_User__c,Investigator_Grants_Assigned_Date__c = Date.newInstance(assignmnetNew.createdDate.year(), assignmnetNew.createdDate.month(), assignmnetNew.createdDate.day()) ,Investigator_Grants_Due_Date_to_PD__c = newAssignment.pse__Resource_Request__r.pse__End_Date__c));
                            }   
                        }
                    }
                
                if(newAssignment.pse__Resource__c != null && assignmnetNew.pse__Status__c == 'Accepted' && 
                newAssignment.pse__Resource_Request__r.SubGroup__c != null && 
                newAssignment.pse__Resource_Request__r.Is_Created_Automatically__c &&
                (
                    (Trigger.isInsert && assignmnetNew.pse__Resource__c != null ) || 
                    ( Trigger.isUpdate  && 
                        (assignmnetNew.pse__Resource__c != assignmnetOld.pse__Resource__c || 
                        (newAssignment.Bid_History__c != null 
                        && newAssignment.Bid_History__r.OwnerId != newAssignment.pse__Resource__r.pse__Salesforce_User__c
                        )
                        )
                    )
                )
                ){
                    if(newAssignment.pse__Resource_Request__r.SubGroup__c == CON_OWF.RES_REQ_TYPE_GBO_LEAD_PD 
                        || (newAssignment.pse__Resource_Request__r.SubGroup__c == CON_OWF.RES_REQ_TYPE_GBO_LEAD_CONTRACTS_ANALYST 
                            &&  newAssignment.pse__Resource_Request__r.Bid_History__r.RecordTypeId == CON_OWF.OWF_CONTRACT_POST_AWARD_BID_HISTORY_RECORD_TYPE_ID)
                        || (newAssignment.pse__Resource_Request__r.SubGroup__c == CON_OWF.RES_REQ_TYPE_CONNECTED_DEVICES_PD 
                            &&  newAssignment.pse__Resource_Request__r.Bid_History__r.RecordTypeId == CON_OWF.OWF_CSS_BID_BID_HISTORY_RECORD_TYPE_ID)){
                                Bid_History__c agreement = new Bid_History__c(id = newAssignment.Bid_History__c);
                                agreement.OwnerId = newAssignment.pse__Resource__r.pse__Salesforce_User__c;
                                updatedAgreementList.add(agreement);     
                            }else if(newAssignment.pse__Resource_Request__r.SubGroup__c == CON_OWF.RES_REQ_TYPE_JAPAN){
                                Bid_History__c agreement = new Bid_History__c(id = newAssignment.Bid_History__c);
                                agreement.User__c = newAssignment.pse__Resource__r.pse__Salesforce_User__c;
                                agreementMapTobeUpdated.put(agreement.Id,agreement);
                                
                            }else if(newAssignment.pse__Resource_Request__r.SubGroup__c == CON_OWF.RES_REQ_TYPE_TSL && newAssignment.Bid_History__r.User__c == Null){
                                
                                Bid_History__c agreement = new Bid_History__c(id = newAssignment.Bid_History__c);
                                agreement.User__c = newAssignment.pse__Resource__r.pse__Salesforce_User__c;
                                agreementMapTobeUpdated.put(agreement.Id,agreement);
                                
                            }
                }
              }
        }
        for(Bid_History__c agr : updatedAgreementList){
            if(agreementMapTobeUpdated.containsKey(agr.Id)){
                agreementMapTobeUpdated.get(agr.Id).OwnerId = agr.OwnerId;
            }
            else{
                agreementMapTobeUpdated.put(agr.Id,agr);                
            }                
        }
        try{     
            if(!agreementMapTobeUpdated.values().isEmpty()){
                update agreementMapTobeUpdated.values();
            }
            if(!iGToBeUpdatedList.isEmpty()){
                update iGToBeUpdatedList;
            }
        }catch(Exception e){
            system.debug('Error: ' + e.getMessage() + ' at Line number: ' + e.getLineNumber());
        }
    }
    
    /**
    * This method is used to update the accepted date based on status
    * @params  newList List<Bid_History__c>
    * @params  oldMap Map<Id, Bid_History__c>
    * @return  void
    */
    /*public static void updateAcceptedDateWhenStatusIsAccepted(List<pse__Assignment__c> newList, Map<Id, pse__Assignment__c> oldMap) {
        Id owfAssignmentRecordTypeId = Schema.SObjectType.pse__Assignment__c.getRecordTypeInfosByName().get('OWF Assignment').getRecordTypeId();
        for(pse__Assignment__c assignment : newList){
            if(assignment.pse__Status__c == 'Accepted' && assignment.recordTypeId == owfAssignmentRecordTypeId){
                if(oldMap == null || ( oldMap != null && assignment.pse__Status__c != oldMap.get(assignment.Id).pse__Status__c)){
                    assignment.Accepted_Date__c = System.today();
                }
            }
        }
    }*/
    
    /**
    * This method is used to update the accepted date, rejected date, match date fields based on status change and status based on Resource change.
    * @params  newList List<Bid_History__c>
    * @params  oldMap Map<Id, Bid_History__c>
    * @return  void
    */
    public static void updateFieldsWhenStatusAndResourceChanged(List<pse__Assignment__c> newList, Map<Id, pse__Assignment__c> oldMap) {
        Id owfAssignmentRecordTypeId = Schema.SObjectType.pse__Assignment__c.getRecordTypeInfosByName().get('OWF Assignment').getRecordTypeId();
        Set<Id> assignmentIdSet = new Set<Id>();
        for(pse__Assignment__c assignment : newList){
            if(assignment.recordTypeId == owfAssignmentRecordTypeId) {
                
                if((oldMap != null && assignment.pse__Status__c != oldMap.get(assignment.Id).pse__Status__c) && assignment.Assignment_Type__c == 'Days Off' && !CON_OWF.allowDaysOffStatusUpdate){
                    assignment.addError('Cannot Change Days off Assignment Status from Assignment View');
                }
                if(oldMap == null || (oldMap != null && assignment.pse__Status__c != oldMap.get(assignment.Id).pse__Status__c)){
                    if(assignment.pse__Status__c == CON_OWF.OWF_STATUS_ACCEPTED){
                        assignment.Accepted_Date__c = System.now();
                    }
                    else if(assignment.pse__Status__c == CON_OWF.OWF_STATUS_REJECTED){
                        assignment.Rejected_Date__c = System.today();
                    }
                }
                if(assignment.pse__Resource__c != null && (oldMap == null || (oldMap != null && assignment.pse__Resource__c != oldMap.get(assignment.Id).pse__Resource__c))) {
                    assignment.Match_Date__c = System.today();
                    if(assignment.Assignment_Type__c != 'Days Off') {
                        assignment.pse__Status__c = CON_OWF.OWF_STATUS_PENDING;
                    }
                }
                //Update Agreement Id on Assignment
                if(assignment.pse__Resource_Request__c != null && assignment.Bid_History__c == null ) {
                    assignmentIdSet.add(assignment.id);
                }
            }
        }
            if(assignmentIdSet.size() > 0) {
			Set<String> assignmentFieldSet = new Set<String>{'Id','pse__Resource_Request__r.Bid_History__c','pse__Resource_Request__c'};
			String assignCondition = 'Id in: sObjectIdset';
			Map<Id, pse__Assignment__c> assignmentMap = new SLT_Assignment(false,false).selectAssignmentsByIdSet(assignmentIdSet,assignCondition,assignmentFieldSet);
			for(pse__Assignment__c assignment : newList){
				if(assignment.recordTypeId == owfAssignmentRecordTypeId && assignmentMap.containsKey(assignment.id)) {
					assignment.Bid_History__c = assignmentMap.get(assignment.id).pse__Resource_Request__r.Bid_History__c;
				}
			}           
		
		}
        for(pse__Assignment__c assignment : newList){
            if(assignment.recordTypeId == owfAssignmentRecordTypeId && (oldMap == null || (oldMap != null && assignment.pse__Status__c != oldMap.get(assignment.Id).pse__Status__c))){
                if(assignment.pse__Status__c == CON_OWF.OWF_STATUS_REJECTED )
                {   
                    assignment.Original_Resource_Request__c = assignment.pse__Resource_Request__c;
                    assignment.Former_Resource_Request__c = assignment.pse__Resource_Request__c;
                    assignment.pse__Resource_Request__c = null;
                }
                else if(assignment.pse__Status__c == CON_OWF.OWF_STATUS_CANCELLED ) {
                    assignment.Former_Resource_Request__c = assignment.pse__Resource_Request__c;
                    assignment.pse__Resource_Request__c = null;
                }
            }
        }
    }
    
     /**
    * This method is used to update status of Resource Request on creation of Assignment.
    * @params  newList List<Bid_History__c>
    * @params  oldMap Map<Id, Bid_History__c>
    * @return  void
    */
    public static void updateRrStatus(List<pse__Assignment__c> newList, Map<Id, pse__Assignment__c> oldMap) {
        Map<Id,pse__Assignment__c> rrIdToAssignmentMap = new Map<Id,pse__Assignment__c>();
        Set<String> rrFieldSet = new Set<String>{'Id', 'pse__Status__c','pse__Assignment__c','pse__resource__c','pse__Staffer_Resource__c'};
        List<pse__Resource_Request__c> rrList = new List<pse__Resource_Request__c>();
        for(pse__Assignment__c assignment : newList){
            if(assignment.RecordTypeId == CON_OWF.OWF_ASSIGNMENT_RECORD_TYPE_ID) {
                rrIdToAssignmentMap.put(assignment.pse__Resource_Request__c,assignment);
            }            
        }
        if(!rrIdToAssignmentMap.isEmpty()) {
            for(pse__Resource_Request__c rrToBeUpdated: new SLT_Resource_Request(false,false).selectResReqsById(rrIdToAssignmentMap.keySet(),rrFieldSet).values()) {
                rrToBeUpdated.pse__Status__c = CON_OWF.OWF_STATUS_ASSIGNED;
                rrToBeUpdated.pse__Resource__c = rrIdToAssignmentMap.get(rrToBeUpdated.Id).pse__resource__c;
                rrToBeUpdated.pse__Staffer_Resource__c = rrIdToAssignmentMap.get(rrToBeUpdated.Id).pse__resource__c;
                rrToBeUpdated.pse__Assignment__c = rrIdToAssignmentMap.get(rrToBeUpdated.Id).Id;
                rrList.add(rrToBeUpdated);                                                                    
            }    
        }
        if(rrList.size() > 0) {
            update rrList;
        } 
    }
    
    /**
    * This method is used to update hours of schedule on creation of Assignment.
    * @params  newList List<pse__Assignment__c>
    * @params  oldMap Map<Id, pse__Assignment__c>
    * @return  void
    */
    public static void updateScheduleHours(List<pse__Assignment__c> newList, Map<Id, pse__Assignment__c> oldMap) {
        List<pse__Schedule__c> scheduleList = new List<pse__Schedule__c>();
        Set<String> scheduleFieldSet = new Set<String>{'Id','pse__Monday_Hours__c','pse__Tuesday_Hours__c','pse__Wednesday_Hours__c',
            'pse__Thursday_Hours__c','pse__Friday_Hours__c','pse__Saturday_Hours__c','pse__Sunday_Hours__c'};
        List<pse__Assignment__c> assignList = [SELECT id,Bid_History__c, recordTypeId, pse__Start_Date__c, pse__End_Date__c, pse__Resource__r.pse__Work_Calendar__r.Standard_Number_of_Working_Days__c, 
                                            pse__Resource__r.pse__Work_Calendar__r.pse__Week_Total_Hours__c, pse__Resource__c, Estimation_Effort__c, pse__Schedule__c, pse__Resource__r.pse__Work_Calendar__r.pse__Monday_Hours__c, 
                                            pse__Resource__r.pse__Work_Calendar__r.pse__Tuesday_Hours__c, pse__Resource__r.pse__Work_Calendar__r.pse__Wednesday_Hours__c, pse__Resource__r.pse__Work_Calendar__r.pse__Thursday_Hours__c,
                                            pse__Resource__r.pse__Work_Calendar__r.pse__Friday_Hours__c, pse__Resource__r.pse__Work_Calendar__r.pse__Saturday_Hours__c, pse__Resource__r.pse__Work_Calendar__r.pse__Sunday_Hours__c 
                                            FROM pse__Assignment__c WHERE id IN :newList];
        List<pse__Schedule_Exception__c> schedExceptionsDelete;
        Map<Id, pse__Assignment__c> scheduleIdToAssignmentMap = new Map<Id,pse__Assignment__c>();
        List<pse__Schedule_Exception__c> schedExceptionsUpdate = new List<pse__Schedule_Exception__c>();
        List<pse__HolidayObj__c> holidayList = [SELECT Id, pse__Date__c, pse__Work_Calendar__c, pse__Work_Hours__c FROM pse__HolidayObj__c where pse__Work_Hours__c =: 0];
        Integer numOfHolidays = 0;
        List<pse__Schedule_Exception__c> scheduleExceptionsToAdd = new List<pse__Schedule_Exception__c>();
        //List<Days_Off__c> daysOff = new List<Days_Off__c>();
        //List<Id> contacts = new List<Id>();

        // schedule id to assignment map
        for(pse__Assignment__c assignment : assignList)
        {
            if(assignment.recordTypeId == CON_OWF.OWF_ASSIGNMENT_RECORD_TYPE_ID) {
                scheduleIdToAssignmentMap.put(assignment.pse__Schedule__c,assignment);
                //contacts.add(assignment.pse__Resource__c);
            }
        }
        
        //daysOff = [SELECT id from Days_Off__c WHERE Employee__r.Id in :contacts];

        // existing schedule exceptions to be  deleted
        schedExceptionsDelete = [SELECT id FROM pse__Schedule_Exception__c WHERE pse__Schedule__c IN :scheduleIdToAssignmentMap.keySet()];
        
        if(!scheduleIdToAssignmentMap.isEmpty())
        {
            // Delete existing schedule exceptions
            if(!schedExceptionsDelete.isEmpty()){
                delete schedExceptionsDelete;
            }
            List<pse__HolidayObj__c> applicableHolidays;
            pse__Assignment__c assign;
            Integer totalBizDays;
            Decimal totalHours;
            Decimal hoursPerDay;
            pse__Schedule_Exception__c scheduleExc;
            for(pse__Schedule__c scheduleToUpdate : new SLT_Schedule(false).selectScheduleById(scheduleIdToAssignmentMap.keySet(),scheduleFieldSet).values())
            {
                applicableHolidays = new List<pse__HolidayObj__c>();
                assign = scheduleIdToAssignmentMap.get(scheduleToUpdate.id);
                totalBizDays = 0;

                // calculate num of holidays in assignment date range
                for(pse__HolidayObj__c holiday : holidayList){
                    if(assign.pse__Resource__r.pse__Work_Calendar__c == holiday.pse__Work_Calendar__c && assign.pse__Start_Date__c <= holiday.pse__Date__c && assign.pse__End_Date__c >= holiday.pse__Date__c && holiday.pse__Work_Hours__c == 0){
                        applicableHolidays.add(holiday);                        
                        numOfHolidays++;
                    }
                }

                if(assign.pse__Start_Date__c != null && assign.pse__End_Date__c != null ){
                    // Calculate total hours based on total business days & estimated effort
                    totalBizDays = UTL_OWF.findNoOfDays_exclude_weekend(assign.pse__Start_Date__c, assign.pse__End_Date__c, numOfHOlidays);
                }

                if(assign.pse__Start_Date__c != null && assign.pse__End_Date__c != null && assign.pse__Resource__r.pse__Work_Calendar__r.Standard_Number_of_Working_Days__c != null && 
                    assign.pse__Resource__r.pse__Work_Calendar__r.pse__Week_Total_Hours__c != null && assign.Estimation_Effort__c != null && assign.pse__Resource__c != null && 
                    assign.pse__Resource__r.pse__Work_Calendar__r.Standard_Number_of_Working_Days__c != 0 && totalBizDays != 0 && 
                    assign.pse__Resource__r.pse__Work_Calendar__r.pse__Week_Total_Hours__c != 0 && assign.Estimation_Effort__c != 0){

                    

                        // calculate total num of business hours, then multiply by estimated effort
                        totalHours = ((totalBizDays / assign.pse__Resource__r.pse__Work_Calendar__r.Standard_Number_of_Working_Days__c) * assign.pse__Resource__r.pse__Work_Calendar__r.pse__Week_Total_Hours__c) * assign.Estimation_Effort__c;
                        
                        // calculate working hours per day for contact's work cal
                        hoursPerDay = totalHours / totalBizDays;
                            
                        // manually create schedule
                        scheduleToUpdate.pse__Start_Date__c = assign.pse__Start_Date__c;
                        scheduleToUpdate.pse__End_Date__c = assign.pse__End_Date__c;
                        if(assign.pse__Resource__r.pse__Work_Calendar__r.pse__Monday_Hours__c != 0){
                                scheduleToUpdate.pse__Monday_Hours__c = hoursPerDay;
                        }
                        if(assign.pse__Resource__r.pse__Work_Calendar__r.pse__Tuesday_Hours__c != 0){
                                scheduleToUpdate.pse__Tuesday_Hours__c = hoursPerDay;
                        }
                        if(assign.pse__Resource__r.pse__Work_Calendar__r.pse__Wednesday_Hours__c != 0){
                                scheduleToUpdate.pse__Wednesday_Hours__c = hoursPerDay;
                        }
                        if(assign.pse__Resource__r.pse__Work_Calendar__r.pse__Thursday_Hours__c != 0){
                                scheduleToUpdate.pse__Thursday_Hours__c = hoursPerDay;
                        }
                        if(assign.pse__Resource__r.pse__Work_Calendar__r.pse__Friday_Hours__c != 0){
                                scheduleToUpdate.pse__Friday_Hours__c = hoursPerDay;
                        }
                        if(assign.pse__Resource__r.pse__Work_Calendar__r.pse__Saturday_Hours__c != 0){
                                scheduleToUpdate.pse__Saturday_Hours__c = hoursPerDay;
                        }
                        if(assign.pse__Resource__r.pse__Work_Calendar__r.pse__Sunday_Hours__c != 0){
                                scheduleToUpdate.pse__Sunday_Hours__c = hoursPerDay;
                        }
                        scheduleToUpdate.pse__Scheduled_Hours__c = totalHours;
                        scheduleToUpdate.pse__Scheduled_Days__c = totalBizDays;
                        scheduleList.add(scheduleToUpdate); 
                        
                        // create schedule exceptions
                        for(pse__HolidayObj__c holiday : applicableHolidays){
                            scheduleExc = new pse__Schedule_Exception__c();
                            scheduleExc.pse__Date__c = holiday.pse__Date__c;
                            //scheduleExc.pse__End_Date__c = pattern.endDate;
                            scheduleExc.pse__Sunday_Hours__c = 0;
                            scheduleExc.pse__Monday_Hours__c = 0;
                            scheduleExc.pse__Tuesday_Hours__c = 0;
                            scheduleExc.pse__Wednesday_Hours__c = 0;
                            scheduleExc.pse__Thursday_Hours__c = 0;
                            scheduleExc.pse__Friday_Hours__c = 0;
                            scheduleExc.pse__Saturday_Hours__c = 0;
                            scheduleExc.pse__Schedule__c = scheduleToUpdate.id;
                            scheduleExceptionsToAdd.add(scheduleExc);
                    	}
                        
                        // add functionality to account for user's time off?
                       

                }
                // if any values needed for totalHours calculation are null or 0, assign all hours to be 0
                else{
                    scheduleToUpdate.pse__Monday_Hours__c = 0;
                    scheduleToUpdate.pse__Tuesday_Hours__c = 0;
                    scheduleToUpdate.pse__Wednesday_Hours__c = 0;
                    scheduleToUpdate.pse__Thursday_Hours__c = 0;
                    scheduleToUpdate.pse__Friday_Hours__c = 0;
                    scheduleToUpdate.pse__Saturday_Hours__c = 0;
                    scheduleToUpdate.pse__Sunday_Hours__c = 0;
                    scheduleList.add(scheduleToUpdate);
                } 
            }
        }
        update scheduleList;
        insert schedExceptionsUpdate;
        insert scheduleExceptionsToAdd; 

    }
    
    
    
     /**
    * This method is used to update Resource on Resource Request when Assignment is Rejected.
    * @params  newList List<Bid_History__c>
    * @params  oldMap Map<Id, Bid_History__c>
    * @return  void
    */
    public static void updateRelatedFieldsOnRejected(List<pse__Assignment__c> newList, Map<Id, pse__Assignment__c> oldMap) {
        Map<Id,pse__Assignment__c> assignmentIdToAssignmentMap = new Map<Id,pse__Assignment__c>();
        Set<String> rrFieldSet = new Set<String>{'Id','Name','pse__Opportunity__r.Bid_Defense_Date__c','pse__Resource__r.Sub_Group__c','pse__Resource__r.pse__Salesforce_User__r.IsActive','pse__Project__c','pse__Group__c','Bid_History__c','pse__Opportunity__c','SubGroup__c','pse__Opportunity__r.QI_Invited_to_Present__c', 'pse__Status__c','pse__Assignment__c','pse__Resource__c','pse__Staffer_Resource__c','pse__Start_Date__c','pse__End_Date__c','Closure_Reason__c','Cancellation_Reason__c','Cancellation_Comments__c','Is_Bid_Defense__c'};
        List<pse__Resource_Request__c> rrList = new List<pse__Resource_Request__c>();
        List<pse__Schedule__c> scheduleList = new List<pse__Schedule__c>();
		List<pse__Resource_Request__c> rrToBeCreatedList = new List<pse__Resource_Request__c>();

        
        for(pse__Assignment__c assignment : newList){
            if(assignment.RecordTypeId == CON_OWF.OWF_ASSIGNMENT_RECORD_TYPE_ID) {
                assignmentIdToAssignmentMap.put(assignment.Id,assignment);
            }            
        }
        if(!assignmentIdToAssignmentMap.isEmpty()) {
            for(pse__Resource_Request__c rrToBeUpdated: new SLT_Resource_Request(false,false).getResourceRequestByAssignmentID(assignmentIdToAssignmentMap.keySet(),rrFieldSet).values()) {
                
                pse__Assignment__c assignment = assignmentIdToAssignmentMap.get(rrToBeUpdated.pse__Assignment__c);
                if(assignment.pse__Status__c != oldMap.get(assignment.Id).pse__Status__c && (assignment.pse__Status__c == CON_OWF.OWF_STATUS_REJECTED || (assignment.pse__Status__c == CON_OWF.OWF_STATUS_CANCELLED && !rrToBeUpdated.Is_Bid_Defense__c && !CON_OWF.isUpdatedFromContact) 
                   || (assignment.pse__Status__c == CON_OWF.OWF_STATUS_CLOSED && !rrToBeUpdated.Is_Bid_Defense__c && !CON_OWF.isUpdatedFromContact)))
                {
                    
                    rrToBeUpdated.pse__Status__c = CON_OWF.OWF_STATUS_READYTOSTAFF;
                    rrToBeUpdated.pse__Resource__c = null;
                    rrToBeUpdated.pse__Assignment__c = null;
                    rrToBeUpdated.pse__Staffer_Resource__c = null;
                    rrList.add(rrToBeUpdated);
                }
                /* else if (assignment.pse__Status__c == CON_OWF.OWF_STATUS_CANCELLED &&
                assignment.pse__Resource_Request__r.Is_Bid_Defense__c && 
                assignment.Lookup_Opportunity_Name__r.QI_Invited_to_Present__c == 'Yes'
                && !CON_OWF.isUpdatedFromContact)
                {
                rrToBeUpdated.pse__Status__c = CON_OWF.OWF_STATUS_READYTOSTAFF;
                rrToBeUpdated.pse__Resource__c = null;
                rrToBeUpdated.pse__Assignment__c = null;
                rrToBeUpdated.pse__Staffer_Resource__c = null;
                rrList.add(rrToBeUpdated);
                }*/
                //IQVIAPSA-1852
                else if (assignment.pse__Status__c != oldMap.get(assignment.Id).pse__Status__c && (assignment.pse__Status__c == CON_OWF.OWF_STATUS_CLOSED &&
                         rrToBeUpdated.Is_Bid_Defense__c && 
                         (rrToBeUpdated.pse__Opportunity__r.QI_Invited_to_Present__c == 'Yes'
                          ||(rrToBeUpdated.pse__Opportunity__r.QI_Invited_to_Present__c == 'Not sure'
                             &&rrToBeUpdated.pse__Opportunity__r.Bid_Defense_Date__c != null))
                         && !CON_OWF.isUpdatedFromContact))
                {
                    //system.debug('Creating New RR for Closed One');
                    pse__Resource_Request__c rrToBecreated = new pse__Resource_Request__c();
                    //rrToBecreated = rrToBeUpdated.clone(false, true, false, false);   
                    rrToBecreated.recordTypeId = CON_OWF.OWF_RR_RECORD_TYPE_ID;
                    rrToBecreated.pse__Opportunity__c = rrToBeUpdated.pse__Opportunity__c;
                    rrToBecreated.Bid_History__c = rrToBeUpdated.Bid_History__c;
                    rrToBecreated.SubGroup__c = rrToBeUpdated.SubGroup__c;
                    rrToBecreated.pse__Project__c  = rrToBeUpdated.pse__Project__c;
                    rrToBecreated.pse__Group__c = rrToBeUpdated.pse__Group__c;
                    rrToBecreated.Is_Bid_Defense__c = true;
                    rrToBecreated.Is_Created_Automatically__c = true;
                    rrToBecreated.Auto_Assignment_Notes__c = 'This Resource Request was created in replacement of a Closed Resource Request:' +rrToBeUpdated.Name;
                    rrToBecreated.pse__SOW_Hours__c = 0.01;
                    rrToBecreated.CurrencyIsoCode = rrToBeUpdated.CurrencyIsoCode;  
                    rrToBecreated.pse__Assignment__c = null;
                    if(rrToBeUpdated.SubGroup__c!=rrToBeUpdated.pse__Resource__r.Sub_Group__c
                       || !rrToBeUpdated.pse__Resource__r.pse__Salesforce_User__r.IsActive)
                    {
                        rrToBecreated.Auto_Assignment_Notes__c = 'Auto assignment can not be created as former Resource is Invalid.\n Original Resource Request:'+ rrToBeUpdated.Name;    
                    }
                    else{
                        rrToBecreated.pse__Resource__c =  assignment.pse__Resource__c;
                    }
                    rrToBeCreatedList.add(rrToBecreated);
                    
                    rrToBeUpdated.pse__Status__c = CON_OWF.OWF_STATUS_CLOSED;
                    rrToBeUpdated.Closure_Reason__c = 'This resource is Closed because Presentation date on related Opportunity has been changed.';
                    rrToBeUpdated.pse__End_Date__c = Date.Today();
                    rrList.add(rrToBeUpdated);
                }
                else if(assignment.pse__Status__c != oldMap.get(assignment.Id).pse__Status__c && (assignment.pse__Status__c == CON_OWF.OWF_STATUS_CANCELLED && !CON_OWF.isUpdatedFromContact))
                {
                    rrToBeUpdated.pse__Status__c = CON_OWF.OWF_STATUS_CANCELLED;
                    rrToBeUpdated.Cancellation_Reason__c = 'Other';
                    rrToBeUpdated.Cancellation_Comments__c = 'This resource is cancelled because related Opportunity did not meet the criteria';
                    rrList.add(rrToBeUpdated);
                }
                else if(assignment.pse__Status__c != oldMap.get(assignment.Id).pse__Status__c && assignment.pse__Status__c == CON_OWF.OWF_STATUS_CLOSED)
                {
                    rrToBeUpdated.pse__Status__c = CON_OWF.OWF_STATUS_CLOSED;
                    rrToBeUpdated.Closure_Reason__c = 'This resource is Closed because related Opportunity did not meet the criteria';
                    rrToBeUpdated.pse__End_Date__c = Date.Today();
                    rrList.add(rrToBeUpdated);
                }
                else if(assignment.pse__Status__c != oldMap.get(assignment.Id).pse__Status__c && (rrToBeUpdated.pse__Resource__c == null || rrToBeUpdated.pse__Staffer_Resource__c == null))
                {
                        rrToBeUpdated.pse__Resource__c = assignment.pse__Resource__c; 
                        rrToBeUpdated.pse__Staffer_Resource__c = assignment.pse__Resource__c;
                        rrList.add(rrToBeUpdated);
                }
                if(assignment.pse__End_Date__c != rrToBeUpdated.pse__End_Date__c)
                {
                    pse__Schedule__c scheduleToUpdate = new pse__schedule__c(Id = assignment.pse__Schedule__c,
                                                                            pse__Start_Date__c = rrToBeUpdated.pse__Start_Date__c,
                                                                            pse__End_Date__c = rrToBeUpdated.pse__End_Date__c 
                                                                           );
                    scheduleList.add(scheduleToUpdate);
                }
            }  
 
        }
        if(rrList.size() > 0) {
            update rrList;
        }
        if(scheduleList.size() > 0)
        {
            update scheduleList;
        }
        if(rrToBeCreatedList.size() >0)
        { 
           insert rrToBeCreatedList; 
           //system.debug('rrToBeCreatedList' + rrToBeCreatedList); 
        } 
    }
    
    /*
    This Method is use to Populate the 
    DateLeadPDAssigned and 
    DueDateatAssignment field 
    on related agreement
    */
    public static void populateDueDateatAssignmentAndDateLeadPDAssigned(List<pse__Assignment__c> newList, Map<Id, pse__Assignment__c> oldMap)
    {
        Map<Id,Bid_History__c> agreementToUpdateMap = new Map<Id,Bid_History__c>();
        Bid_History__c agreementToBeUpdated;
		for(pse__Assignment__c assignment : newList){
            if(assignment.RecordTypeId == CON_OWF.OWF_ASSIGNMENT_RECORD_TYPE_ID && assignment.pse__Resource__c != null && assignment.Bid_History__c != null) {
				agreementToBeUpdated = new Bid_History__c();
                agreementToBeUpdated.Id = assignment.Bid_History__c;
                if(assignment.Resource_Sub_Group__c == 'GBO-Lead PD' && !agreementToUpdateMap.containsKey(agreementToBeUpdated.Id))
                {
                    agreementToBeUpdated.DateLeadPDAssigned__c = Date.Today();
                    agreementToBeUpdated.DueDateAtAssignment__c = assignment.pse__End_Date__c;
                    agreementToUpdateMap.put(agreementToBeUpdated.Id,agreementToBeUpdated);
				}

            }            
        }
        if(agreementToUpdateMap.values().size()>0){
            update agreementToUpdateMap.values();
        }
        
    }	

    /**
    * This method is used to update the record type of Assignment.
    * @params  newList List<pse__Assignment__c>
    * @params  oldMap Map<Id, pse__Assignment__c>
    * @return  void
    */
    public static void updateRecordTypeId(List<pse__Assignment__c> newList, Map<Id, pse__Assignment__c> oldMap) {
        Set<Id> resourceRequestIdSet = new Set<Id>();
        Set<Id> projIdSet = new Set<Id>();
        Map<Id, pse__Resource_Request__c> rrIdToRrMap = new Map<Id, pse__Resource_Request__c>();
        // add map id to Proj
        Map<Id, pse__Proj__c> projIdToProjMap = new Map<Id, pse__Proj__c>();
        Set<String> rrFieldSet = new Set<String>{'Id','recordTypeId'};
        Set<String> projFieldSet = new Set<String>{'Id','recordTypeId'};
        for(pse__Assignment__c assignment : newList){
            if(assignment.pse__Resource_Request__c != null) {
                resourceRequestIdSet.add(assignment.pse__Resource_Request__c);
            }
            // if assign proj not null, add to id to proj map
            if(assignment.pse__Project__c != null){
                projIdSet.add(assignment.pse__Project__c);
            }
        }
        if(resourceRequestIdSet.size() > 0 ){
            rrIdToRrMap = new SLT_Resource_Request(false,false).selectResReqsById(resourceRequestIdSet,rrFieldSet);
            for(pse__Assignment__c assignment : newList){
                if(rrIdToRrMap.containsKey(assignment.pse__Resource_Request__c) 
                    && rrIdToRrMap.get(assignment.pse__Resource_Request__c).recordTypeId == CON_OWF.OWF_RR_RECORD_TYPE_ID) {
                    assignment.recordTypeId = CON_OWF.OWF_ASSIGNMENT_RECORD_TYPE_ID;
                }
            }
        }
        
        // if proj map > 0, query project by id, go through each assignment and if proj map contains the assign proj & proj record type is rds proj/rds internal/rds service line, make assign record type id 
        if(projIdSet.size() > 0 ){
            projIdToProjMap = new SLT_Project(false,false).getProjectById(projIdSet,projFieldSet);
            for(pse__Assignment__c assignment : newList){
                if(projIdToProjMap.containsKey(assignment.pse__Project__c) 
                    && (projIdToProjMap.get(assignment.pse__Project__c).recordTypeId == CON_PSA.PROJ_REC_TYPE_ID_RDS_PROJECT || 
                    projIdToProjMap.get(assignment.pse__Project__c).recordTypeId == CON_PSA.PROJ_REC_TYPE_ID_RDS_SERVICELINE || 
                    projIdToProjMap.get(assignment.pse__Project__c).recordTypeId == CON_PSA.PROJ_REC_TYPE_ID_RDS_INTERNAL )) {
                    assignment.recordTypeId =CON_PSA.ASSIGNMENT_REC_TYPE_ID_RDS;
                }
            }
        }
    }
	
	 /**
* This method is used to make the Assignment Trigger ready created from FF Package.
* @params  newList List<Bid_History__c>
* @params  oldMap Map<Id, Bid_History__c>
* @return  void
*/
    public static void makeAssignmentTriggerReady(List<pse__Assignment__c> newList, Map<Id, pse__Assignment__c> oldMap)
    {
        Id owfAssignmentRecordTypeId = Schema.SObjectType.pse__Assignment__c.getRecordTypeInfosByName().get('OWF Assignment').getRecordTypeId();
        for(pse__Assignment__c assignment : newList){
            if(assignment.recordTypeId == owfAssignmentRecordTypeId && !assignment.Trigger_Email_Notification__c ) {
                assignment.Trigger_Email_Notification__c = true;
            }
        }
    }
	
    public static void validateAssignmentForSubGroup(List<pse__Assignment__c> newList){
        Set<Id> resourceRequestIdSet = new Set<Id>();
        Set<Id> resourceIdSet = new Set<Id>();
        Map<Id, pse__Resource_Request__c> rrIdToRrMap = new Map<Id, pse__Resource_Request__c>();
        Set<String> rrFieldSet = new Set<String>{'Id','SubGroup__c'};
        Map<Id, Contact> resourceIdToResourceMap = new Map<Id, Contact>();
        Set<String> resourceFieldSet = new Set<String>{'Id','Secondary_Sub_Group__c','Sub_Group__c'};
        Mulesoft_Integration_Control__c mulesoft = Mulesoft_Integration_Control__c.getInstance();
        for(pse__Assignment__c assignment : newList){
            if(CON_OWF.OWF_ASSIGNMENT_RECORD_TYPE_ID == assignment.RecordTypeId) {
            	resourceRequestIdSet.add(assignment.pse__Resource_Request__c);
            	resourceIdSet.add(assignment.pse__Resource__c);
            }
        }
    	if(resourceRequestIdSet.size()>0 && resourceIdSet.size()>0){
            rrIdToRrMap = new SLT_Resource_Request(false,false).selectResReqsById(resourceRequestIdSet,rrFieldSet);
            resourceIdToResourceMap = new SLT_Contact(false,false).selectByContactId(resourceIdSet,resourceFieldSet);
            for(pse__Assignment__c assignment : newList){
                if((!mulesoft.Ignore_Validation_Rules__c) && assignment.RecordTypeId == CON_OWF.OWF_ASSIGNMENT_RECORD_TYPE_ID && !assignment.assignment_type__c.equals('Days Off')){
                    if((rrIdToRrMap.get(assignment.pse__Resource_Request__c).SubGroup__c != resourceIdToResourceMap.get(assignment.pse__Resource__c).Sub_Group__c) 
                       && !( resourceIdToResourceMap.get(assignment.pse__Resource__c).Secondary_Sub_Group__c!=null &&
                            resourceIdToResourceMap.get(assignment.pse__Resource__c).Secondary_Sub_Group__c.contains(rrIdToRrMap.get(assignment.pse__Resource_Request__c).SubGroup__c))){
                        assignment.addError('This Assignment cannot be created because the sub group/additional Sub-Group of resource does not match the sub group of Resource Request.');
                    }
                }
            }
        }
    }
    // Method to created Suggeted Resources whenever assignment is Rejected.
    public static void createSuggestedResourcesWhenAssignmentIsRejected(List<pse__Assignment__c> newList, Map<Id, pse__Assignment__c> oldMap){
        Set<Id> resourceRequestIdSet = new Set<Id>();
        List<Suggested_Resources__c> suggestedResourcesToBeDeleted = new List<Suggested_Resources__c>();
        List<Suggested_Resources__c> suggestedResourceList = new List<Suggested_Resources__c>();
        Map<Id, pse__Resource_Skill_Request__c> resourceSkillRequestMap = new Map<Id, pse__Resource_Skill_Request__c>();
         for(pse__Assignment__c assignment : newList){
            if(CON_OWF.OWF_ASSIGNMENT_RECORD_TYPE_ID == assignment.RecordTypeId && assignment.pse__Status__c != oldMap.get(assignment.Id).pse__Status__c && assignment.pse__Status__c == CON_OWF.OWF_STATUS_REJECTED) {
            	resourceRequestIdSet.add(oldMap.get(assignment.id).pse__Resource_Request__c);
            }
        }
        Set<String> suggestedResourceFieldSet = new Set<String>{'Id','Resource_Request__c'};
        if(!resourceRequestIdSet.isEmpty()){
            suggestedResourcesToBeDeleted = new SLT_Suggested_Resources().getSuggestedResourcesByResourceRequestID(resourceRequestIdSet,suggestedResourceFieldSet);
            if(!suggestedResourcesToBeDeleted.isEmpty()){
                delete suggestedResourcesToBeDeleted;
            }
            Set<String> rsrFieldSet = new Set<String>{ 'pse__Minimum_Rating__c','pse__Resource_Request__c','pse__Skill_Certification__c','pse__Skill_Certification__r.name','pse__Resource_Request__r.SubGroup__c' };
            resourceSkillRequestMap = new SLT_Resource_Skill_Request().getResourceSkillRequestByRrID(resourceRequestIdSet, rsrFieldSet);
            List<pse__Resource_Skill_Request__c> rsrForGBOList = new List<pse__Resource_Skill_Request__c>();
            List<pse__Resource_Skill_Request__c> rsrForTSSUList = new List<pse__Resource_Skill_Request__c>();
            for(Id rsrId : resourceSkillRequestMap.keySet()){
                if(CON_OWF.RES_REQ_GBO_SET.contains(resourceSkillRequestMap.get(rsrId).pse__Resource_Request__r.SubGroup__c)){
                    rsrForGBOList.add(resourceSkillRequestMap.get(rsrId));
                }
                else{
                    rsrForTSSUList.add(resourceSkillRequestMap.get(rsrId));
                }
            }
            suggestedResourceList.addall(DAOH_OWF_Resource_Request.createSuggestedResourceForGBO(rsrForGBOList));
            suggestedResourceList.addall(DAOH_OWF_Resource_Request.createSuggestedResourceForTSSU(rsrForTSSUList));
            if(!suggestedResourceList.isEmpty()){
                insert suggestedResourceList;
            }
        }
    }

    // Prevents recursion on update
    public static boolean runOnce(){
        if(run){
         run=false;
         return true;
        }else{
            return run;
        }
    }
    
    
    public static void updateBudgetAnalystAssignedByAssignment(List<pse__Assignment__c> newList, Map<Id, pse__Assignment__c> oldMap) 
    {
        Set<Id> assignmentIdSet = new Set<Id>();
        Map<Id, Bid_History__c> bidHistoriesToBeupdated= new Map<Id, Bid_History__c>();
        Map<Id,pse__Assignment__c> assignmentIdToAssignmentMap = new Map<Id,pse__Assignment__c>();
        pse__Assignment__c assignmnetOld = new pse__Assignment__c();
        for (pse__Assignment__c assignmnetNew : newList) 
        {
            if(assignmnetNew.recordTypeId == CON_OWF.OWF_ASSIGNMENT_RECORD_TYPE_ID) 
            {
                assignmentIdSet.add(assignmnetNew.id);
                
            }
        } 
        
        if(!assignmentIdSet.isEmpty())		
        {
            Set<String> assignmentFieldSet = new Set<String>{'pse__Resource__r.Id', 'pse__Resource__r.Salesforce_User__c', 'pse__Resource__r.pse__Salesforce_User__c',
                'Bid_History__r.Id','Bid_History__r.Budget_Analyst_Assigned__c','pse__Status__c','pse__Resource__c','pse__Resource_Request__c','Bid_History__c',
                'pse__Resource_Request__r.Id', 'pse__Resource_Request__r.SubGroup__c','pse__Resource_Request__r.Is_Created_Automatically__c'};
			String assignCondition = 'Id in: sObjectIdset';
            assignmentIdToAssignmentMap = new SLT_Assignment().selectAssignmentsByIdSet(assignmentIdSet,assignCondition,assignmentFieldSet);
            
        }        
        for (pse__Assignment__c assignmnetNew : assignmentIdToAssignmentMap.values()) 
        { 
            if(oldMap != null && oldMap.containskey(assignmnetNew.Id)){
                assignmnetOld = oldMap.get(assignmnetNew.Id); 
            }
            
            if(assignmnetNew.pse__Status__c == 'Accepted'
               && assignmnetNew.pse__Resource__c != null
               && assignmnetNew.pse__Resource_Request__c != null
               && assignmnetNew.pse__Resource_Request__r.SubGroup__c != null
               && assignmnetNew.pse__Resource_Request__r.Is_Created_Automatically__c
               && (
                   (Trigger.isInsert && assignmnetNew.pse__Resource__c != null ) 
                   || 
                   (Trigger.isUpdate  
                    && 
                    (assignmnetNew.pse__Resource__c != assignmnetOld.pse__Resource__c || 
                     assignmnetNew.Bid_History__c != null)
                   )
               )
              )
            {
                if(assignmnetNew.pse__Resource_Request__r.SubGroup__c == CON_OWF.RES_REQ_TYPE_GBO_BID_GRID)
                {
                    if(assignmnetNew.Bid_History__r.Budget_Analyst_Assigned__c == null || assignmnetNew.Bid_History__r.Budget_Analyst_Assigned__c != assignmnetNew.pse__Resource__r.pse__Salesforce_User__c){
                        if(!bidHistoriesToBeupdated.containsKey(assignmnetNew.Bid_History__c)){
                            bidHistoriesToBeupdated.put(assignmnetNew.Bid_History__c,new Bid_History__c(id = assignmnetNew.Bid_History__c,Budget_Analyst_Assigned__c = assignmnetNew.pse__Resource__r.pse__Salesforce_User__c));
                        }
                        else{
                            bidHistoriesToBeupdated.get(assignmnetNew.Bid_History__c).Budget_Analyst_Assigned__c = assignmnetNew.pse__Resource__r.pse__Salesforce_User__c;
                        }
                    }
                }
            }
        }
        
        try{     
            if(!bidHistoriesToBeupdated.values().isEmpty()){
                update bidHistoriesToBeupdated.values();
            }    
        }catch(Exception e){
            system.debug('Budget Analyst Assigned Error: ' + e.getMessage() + ' at Line number: ' + e.getLineNumber());
        }
    }
    
    /*
     * This method is used to restrict OWF user without having "OWF Triage Manager" permission set
     * to manually update assignment status as "Cancelled", to bypass this validation if system updates
     * assignment status to 'Cancelled' we can mark 'isAssignmentStatusUpdateAsCancelledBySystem' variable of UTL_OWF as true.
	*/
    public static void restrictOWFUserForAssignmentStatusToCancelled(List<pse__Assignment__c> newList, Map<Id, pse__Assignment__c> oldMap){
        Boolean isUserHavingOWFTriageManagerPermission = FeatureManagement.checkPermission('OWF_Triage_Manager');
        for(pse__Assignment__c assignment : newList){
            if(trigger.isUpdate && assignment.recordTypeId == CON_OWF.OWF_ASSIGNMENT_RECORD_TYPE_ID && assignment.pse__Status__c != null && assignment.pse__Status__c != oldMap.get(assignment.Id).pse__Status__c
               && assignment.pse__Status__c == CON_OWF.OWF_ASSIGNMENT_STATUS_CANCELLED && !isUserHavingOWFTriageManagerPermission && !UTL_OWF.isAssignmentStatusUpdateAsCancelledBySystem){
                assignment.addError('Please use the Rejected option and provide a rejected reason.');
            }
        }
    }
    
    public static void sendEmailbyWorkflowEmailRecord(List<pse__Assignment__c> newList, Map<id, pse__Assignment__c> oldMap){
        Set<Id> assignmentIdSet = new Set<Id>();
        List<pse__Assignment__c> assignmentRecordsList = new List<pse__Assignment__c>();
        List<UTL_OWF.workflowEmailRecordWrapper> workflowEmailRecordWrapperMessageList = new List<UTL_OWF.workflowEmailRecordWrapper>();
        String whereclause = 'Id IN :sObjectIdSet AND pse__Resource_Request__r.SubGroup__c IN (\'' + CON_OWF.RES_REQ_TYPE_GBO_LEAD_CONTRACTS_ANALYST + '\' , \'' + CON_OWF.RES_REQ_TYPE_GBO_SUPPORT_CA + '\')';
        Set<String> assignmentFieldSet = (new Set<String> {'Id', 'Bid_History__r.Agreement_Pathway__c', 'pse__Resource__r.Name', 'pse__Resource__r.Email','pse__Resource__r.Line_Manager__c',
            'pse__Resource__r.Line_Manager__r.Email', 'Bid_History__r.Contract_Project_Manager__c', 'Bid_History__r.Contract_Project_Manager__r.Email',
            'Bid_History__r.Contract_IQVIA_Business_Account_Manager__c', 'Bid_History__r.Contract_IQVIA_Business_Account_Manager__r.Email', 'Bid_History__c',
            'Bid_History__r.Bid_History_Related_Opportunity__c', 'Bid_History__r.Bid_History_Related_Opportunity__r.Legacy_Quintiles_Opportunity_Number__c',
            'Bid_History__r.Bid_History_Related_Opportunity__r.Name', 'Bid_History__r.Requested_Agreement_Type__c', 'Bid_History__r.Name',
            'Bid_History__r.Bid_History_Related_Opportunity__r.Account', 'Bid_History__r.Bid_History_Related_Opportunity__r.Account.Id',
            'Bid_History__r.Bid_History_Related_Opportunity__r.Account.Name', 'Bid_History__r.Date_Tracking_Started__c',
            'Bid_History__r.CreatedById', 'Bid_History__r.CreatedBy.IsActive', 'Bid_History__r.CreatedBy.Email', 'pse__Start_Date__c',
            'pse__Resource_Request__c', 'pse__Resource_Request__r.SubGroup__c', 'Subgroup_Name__c'});
        List<pse__Assignment__c> assignmentsForBidHistoryPathwayEmailList = new List<pse__Assignment__c>();
        
        for(pse__Assignment__c assignmentRecord : newList){
            if(assignmentRecord.RecordTypeId == CON_OWF.OWF_ASSIGNMENT_RECORD_TYPE_ID){
                assignmentIdSet.add(assignmentRecord.Id);
            }
        }
        
        if(!assignmentIdSet.isEmpty()){
            assignmentRecordsList = new SLT_Assignment(false, false).getAssignmentByResource(assignmentIdSet, whereClause, assignmentFieldSet);
            
            for(pse__Assignment__c assignmentRecord : assignmentRecordsList){
                if(assignmentRecord.Bid_History__c != null && CON_OWF.CONTRACT_POST_AWARD_AGREEMENT_PATHWAY_Set.contains(assignmentRecord.Bid_History__r.Agreement_Pathway__c)){
                    assignmentsForBidHistoryPathwayEmailList.add(assignmentRecord);
                }
            }
            
            workflowEmailRecordWrapperMessageList.addAll(prepareEmailForContractPostAwardBidPathway(assignmentsForBidHistoryPathwayEmailList));
            
            if(!workflowEmailRecordWrapperMessageList.isEmpty()){
                UTL_OWF.sendEmailByWorkflowEmailRecord(workflowEmailRecordWrapperMessageList);
            }
        }
    }
    
    public static List<UTL_OWF.workflowEmailRecordWrapper> prepareEmailForContractPostAwardBidPathway(List<pse__Assignment__c> assignmentsList){
        List<UTL_OWF.workflowEmailRecordWrapper> workflowEmailRecordWrapperMessageList = new List<UTL_OWF.workflowEmailRecordWrapper>();
        List<String> toEmailList;
        String tdStyle = 'style = "border: 1px solid #cdcdcd; padding: 8px;"';
        String emailOverallBodyContent;
        UTL_OWF.workflowEmailRecordWrapper workflowEmailRecordWrapperMessage;
        
        for(pse__Assignment__c assignmentRecord : assignmentsList){
            toEmailList = new List<String>();
            
            if(assignmentRecord.Bid_History__c != null && assignmentRecord.Bid_History__r.CreatedById != null
               && assignmentRecord.Bid_History__r.CreatedBy.IsActive && assignmentRecord.Bid_History__r.CreatedBy.Email != null){
                toEmailList.add(assignmentRecord.Bid_History__r.CreatedBy.Email);
            }
            if(assignmentRecord.pse__Resource__r.Email != null){
                toEmailList.add(assignmentRecord.pse__Resource__r.Email);
            }
            if(assignmentRecord.pse__Resource__r.Line_Manager__c != null && assignmentRecord.pse__Resource__r.Line_Manager__r.Email != null){
                toEmailList.add(assignmentRecord.pse__Resource__r.Line_Manager__r.Email);
            }
            if(assignmentRecord.Bid_History__c != null &&  assignmentRecord.Bid_History__r.Contract_Project_Manager__c != null
               && assignmentRecord.Bid_History__r.Contract_Project_Manager__r.Email != null){
                   toEmailList.add(assignmentRecord.Bid_History__r.Contract_Project_Manager__r.Email);
               }
            if(assignmentRecord.Bid_History__c != null && assignmentRecord.Bid_History__r.Contract_IQVIA_Business_Account_Manager__c != null
               && assignmentRecord.Bid_History__r.Contract_IQVIA_Business_Account_Manager__r.Email != null){
                   toEmailList.add(assignmentRecord.Bid_History__r.Contract_IQVIA_Business_Account_Manager__r.Email);
               }
            
            if(!toEmailList.isEmpty()){
                emailOverallBodyContent = '';
                workflowEmailRecordWrapperMessage = new UTL_OWF.workflowEmailRecordWrapper();
                workflowEmailRecordWrapperMessage.subject = ((assignmentRecord.Bid_History__c != null
                                                              && assignmentRecord.Bid_History__r.Bid_History_Related_Opportunity__c != null
                                                              && assignmentRecord.Bid_History__r.Bid_History_Related_Opportunity__r.Legacy_Quintiles_Opportunity_Number__c != null)
                                                             ? assignmentRecord.Bid_History__r.Bid_History_Related_Opportunity__r.Legacy_Quintiles_Opportunity_Number__c : ('')) + ' - '
                    + ((assignmentRecord.Bid_History__c != null && assignmentRecord.Bid_History__r.Requested_Agreement_Type__c != null)
                       ? assignmentRecord.Bid_History__r.Requested_Agreement_Type__c : ('')) + ' - Successfully Assigned';
                emailOverallBodyContent = '<div>Dear Requester,<br>';
                emailOverallBodyContent += '<br>Your request has successfully been assigned<br>';
                emailOverallBodyContent += '<br><table style = "font-family: arial, sans-serif; border-collapse: collapse;">';
                emailOverallBodyContent += '<tr><td ' + tdStyle +'>Type of Agreement </td><td ' + tdStyle +'>' + ((assignmentRecord.Bid_History__c != null && assignmentRecord.Bid_History__r.Requested_Agreement_Type__c != null) ? assignmentRecord.Bid_History__r.Requested_Agreement_Type__c : ('')) + '</td></tr>';
                emailOverallBodyContent += '<tr><td ' + tdStyle +'>Agreement Name</td><td ' + tdStyle +'>' + ((assignmentRecord.Bid_History__c != null && assignmentRecord.Bid_History__r.Name != null) ? assignmentRecord.Bid_History__r.Name : ('')) + '</td></tr>';
                emailOverallBodyContent += '<tr><td ' + tdStyle +'>Account Link</td><td ' + tdStyle + '>' + ((assignmentRecord.Bid_History__c != null && assignmentRecord.Bid_History__r.Bid_History_Related_Opportunity__c != null && assignmentRecord.Bid_History__r.Bid_History_Related_Opportunity__r.Account != null)
                                                                                                             ? ('<a href = \'' + URL.getOrgDomainURL().toExternalForm() + '/' + assignmentRecord.Bid_History__r.Bid_History_Related_Opportunity__r.Account.Id + '\'>' + assignmentRecord.Bid_History__r.Bid_History_Related_Opportunity__r.Account.Name + '</a>')
                                                                                                             : ('')) +'</td></tr>';
                
                emailOverallBodyContent += '<tr><td ' + tdStyle +'>Opportunity Link</td><td ' + tdStyle + '>' + ((assignmentRecord.Bid_History__c != null && assignmentRecord.Bid_History__r.Bid_History_Related_Opportunity__c != null)
                                                                                                                 ? ('<a href = \'' + URL.getOrgDomainURL().toExternalForm() + '/' + assignmentRecord.Bid_History__r.Bid_History_Related_Opportunity__c + '\'>' + assignmentRecord.Bid_History__r.Bid_History_Related_Opportunity__r.Name + '</a>')
                                                                                                                 : ('')) +'</td></tr>';
                emailOverallBodyContent += '<tr><td ' + tdStyle +'>Start Date</td><td ' + tdStyle +'>' + ((assignmentRecord.Bid_History__c != null && assignmentRecord.pse__Start_Date__c != null) ? (((Datetime)assignmentRecord.pse__Start_Date__c).formatGMT('MMMM d, yyyy')) : ('')) + '</td></tr>';
                emailOverallBodyContent += '<tr><td ' + tdStyle +'>Resource Assigned </td><td ' + tdStyle +'>' + ((assignmentRecord.pse__Resource__r.Name != null) ? assignmentRecord.pse__Resource__r.Name : ('')) + '</td></tr></table>';
                if(assignmentRecord.Bid_History__c != null){
                       emailOverallBodyContent += '<br>Step by Step guidance:<br>';
                       emailOverallBodyContent += '<br>' + '<a href = \'https://quintiles.sharepoint.com/sites/busops/unit-pricing-tool-apttus/CRM%20UPT%20SF%20Connector%20Tool%20Training/Forms/AllItems.aspx?id=%2Fsites%2Fbusops%2Funit%2Dpricing%2Dtool%2Dapttus%2FCRM%20UPT%20SF%20Connector%20Tool%20Training%2FContracts%2FStep%20by%20Step%20Guidelines&viewid=01827e5e%2Dcc23%2D4327%2D9108%2Ddc1630b7af2f\'>' + 'SF Connect</a><br>';
                       emailOverallBodyContent += '<br>' + '<a href = \'https://quintiles.sharepoint.com/sites/busops/unit-pricing-tool-apttus/Non%20SF%20Quote_CLM%20Training/Forms/AllItems.aspx\'>' + 'Non SF Connect</a><br>';
                }
                emailOverallBodyContent += '<br><b><span style = "color: #FF0000">*ATTENTION REQUESTOR/PROJECT LEADER:</span> The “Start Date” referred to in this communication is the actual start date the GBO resource (CA/PD/BA) will begin working on this request. Please do not reach out to the resource until said date. The resource will reach out to you when they are ready to discuss realistic timelines and expectations. </b><br>';
                emailOverallBodyContent += '<br><b>IMPORTANT :</b> Please create an execution plan under this contract to begin tracking of contract lifecycle and available allocation.';
                workflowEmailRecordWrapperMessage.whatId = assignmentRecord.Id;
                workflowEmailRecordWrapperMessage.toEmails = toEmailList;
                workflowEmailRecordWrapperMessage.emailAction = CON_OWF.CONTRACT_POST_AWARD_BID_PATHWAY_EMAIL_ACTION;
                workflowEmailRecordWrapperMessage.staticContent = emailOverallBodyContent;
                workflowEmailRecordWrapperMessageList.add(workflowEmailRecordWrapperMessage);
            }
        }
        return workflowEmailRecordWrapperMessageList;
    }
}
