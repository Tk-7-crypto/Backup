public class DAOH_OWF_Resource_Request {
    
    /**
* This method is used to set Resource Request Name.
* @params  newList List<pse__Resource_Request__c>
* @return  void
*/
    public static void setResourceRequestName(List<pse__Resource_Request__c> newList, Map<Id, pse__Resource_Request__c> oldMap) {
        for(pse__Resource_Request__c resRequest : newList) {
            if(resRequest.recordTypeId == CON_OWF.OWF_RR_RECORD_TYPE_ID &&
               resRequest.SubGroup__c != NULL && resRequest.Resource_Request_Type__c != NULL && resRequest.Bid_History__c != NULL
               && (oldMap == NULL || (oldMap != NULL && (resRequest.Resource_Request_Type__c != oldMap.get(resRequest.Id).Resource_Request_Type__c 
                                                         || resRequest.SubGroup__c != oldMap.get(resRequest.Id).SubGroup__c || resRequest.Is_Bid_Defense__c  != oldMap.get(resRequest.Id).Is_Bid_Defense__c )))) {
                                                             resRequest.pse__Resource_Request_Name__c = resRequest.Resource_Request_Type__c + '/' + resRequest.SubGroup__c;
                                                             if(resRequest.Is_Bid_Defense__c) {
                                                                 resRequest.pse__Resource_Request_Name__c += '/' + CON_OWF.RES_REQ_TYPE_BID_DEFENCE;
                                                             }
                                                         }
        }
    }
    
    //IQVIAPSA-1852 update
    public static void createAssignmentsForClosedBDRR(List<pse__Resource_Request__c> newList)
    {
        if(CON_OWF.isUpdatedViaPresentationDate)
        {
            Map<id,pse__Schedule__c> scheduleToBeInsertedMap = new Map<id,pse__Schedule__c>();
            Map<id,pse__Assignment__c> assignmentToBeInsertedMap = new Map<id,pse__Assignment__c>();
            
            for(pse__Resource_Request__c resReqRecord : newList)
            {
                if(resReqRecord.pse__Resource__c!= null && (resReqRecord.SubGroup__c != 'TSL' && resReqRecord.SubGroup__c != 'Medical-MSL' && resReqRecord.SubGroup__c != CON_OWF.RES_REQ_TYPE_DESIGN_ANALYTICS))
                {
                    pse__Assignment__c objAssignment= new pse__Assignment__c(); 
                    objAssignment.pse__Project__c = resReqRecord.pse__Project__c;
                    objAssignment.Bid_History__c = resReqRecord.Bid_History__c;
                    objAssignment.pse__Resource__c = resReqRecord.pse__Resource__c;
                    objAssignment.pse__Resource_Request__c = resReqRecord.id;
                    objAssignment.pse__Is_Billable__c = false;
                    objAssignment.pse__Bill_Rate__c = 0;
                    objAssignment.pse__Status__c = 'Pending'; 
                    objAssignment.CurrencyIsoCode = resReqRecord.CurrencyIsoCode;
                    objAssignment.RecordTypeId = CON_OWF.OWF_ASSIGNMENT_RECORD_TYPE_ID;
                    objAssignment.Trigger_Email_Notification__c = true;
                    scheduleToBeInsertedMap.put(resReqRecord.Id,createdSchedule(resReqRecord.pse__Start_Date__c, resReqRecord.pse__End_Date__c));
                    assignmentToBeInsertedMap.put(resReqRecord.Id,objAssignment);
                    
                    //Updating Resource Request record
                    /* resReqRecord.pse__Assignment__c = objAssignment.Id;
rrToBeUpdatedList.add(resReqRecord);*/
                }
            }
            if(scheduleToBeInsertedMap.values().size() > 0){
                insert scheduleToBeInsertedMap.values();
            }				
            for(Id i : scheduleToBeInsertedMap.keySet())
            {
                assignmentToBeInsertedMap.get(i).pse__Schedule__c = scheduleToBeInsertedMap.get(i).id;
            }
            
            if(assignmentToBeInsertedMap.values().size() > 0){
                insert assignmentToBeInsertedMap.values();
            }	
        }
    }
    
    
    
    /**
* This method is used to cancel related assignments on resource request cancellation.
* @params List<pse__Resource_Request__c> newList
* @params Map<Id, pse__Resource_Request__c> oldMap
* @return void
*/
    public static void cancelRelatedAssignments(List<pse__Resource_Request__c> newList, Map<Id, pse__Resource_Request__c> oldMap){
        Set<Id> resourceRequestIdSet = new Set<Id>();
        Map<Id, pse__Assignment__c> assignmentIdToAssignmentMap = new Map<Id, pse__Assignment__c>();
        
        for(pse__Resource_Request__c resRequest : newList) {
            if(resRequest.recordTypeId == CON_OWF.OWF_RR_RECORD_TYPE_ID && resRequest.pse__Status__c != NULL && resRequest.pse__Status__c != oldMap.get(resRequest.Id).pse__Status__c 
               && (resRequest.pse__Status__c == CON_OWF.OWF_STATUS_CANCELLED || resRequest.pse__Status__c == CON_OWF.OWF_STATUS_CLOSED)) {
                   resourceRequestIdSet.add(resRequest.Id);
               }
        }
        
        if(resourceRequestIdSet.size() > 0){
                        Set<String> assignmentFieldSet = new Set<String>{'Id', 'pse__Status__c','pse__Resource_Request__r.pse__Status__c'};
                assignmentIdToAssignmentMap = new SLT_Assignment(false,false).selectAssignmentsByIdSet(resourceRequestIdSet, 'pse__Resource_Request__c in :sObjectIdset', assignmentFieldSet);
        }
        
        if(assignmentIdToAssignmentMap.values().size() > 0) {
            for(pse__Assignment__c assignment : assignmentIdToAssignmentMap.values()){
                if(assignment.pse__Resource_Request__r.pse__Status__c == CON_OWF.OWF_STATUS_CLOSED){
                    assignment.pse__Status__c = CON_OWF.OWF_STATUS_CLOSED;
                    CON_OWF.isUpdatedFromContact = true;
                }
                else{
                    assignment.pse__Status__c = CON_OWF.OWF_STATUS_CANCELLED;
                    UTL_OWF.isAssignmentStatusUpdateAsCancelledBySystem = true;
                } 
            } 
            update assignmentIdToAssignmentMap.values();
        }
    }
    
    /**
* This method is used to create Resource Skill Request records on RR creation.
* @params List<pse__Resource_Request__c> newList
* @return void
*/
    public static void createResourceSkillRequest(List<pse__Resource_Request__c> newList){
        List<pse__Resource_Skill_Request__c> createResourceSkillRequestList = new List<pse__Resource_Skill_Request__c>();
        createResourceSkillRequestList = returnRSRForResourceRequest(newList);
        if(createResourceSkillRequestList.size() > 0){
            try {
                insert createResourceSkillRequestList;
            }
            catch(Exception ex) {
                System.Debug(ex);
            }
            List<Suggested_Resources__c> suggestedResourceList = createSuggestedResourceForTSSU(createResourceSkillRequestList);
            if(suggestedResourceList.size()>0){
                insert suggestedResourceList;
            }
        }
    }
    
    /**
* This method is used to create Resource Skill Request records on RR creation.
* @params List<pse__Resource_Request__c> newList
* @return List<pse__Resource_Skill_Request__c>
*/
    public static List<pse__Resource_Skill_Request__c> returnRSRForResourceRequest(List<pse__Resource_Request__c> newList){
        List<pse__Resource_Skill_Request__c> createRsrRecordsList = new List<pse__Resource_Skill_Request__c>();
        
        Map<String, Map<String, pse__Skill__c>> skillTypeToSkillNameToSkillMap = new Map<String, Map<String, pse__Skill__c>>();
        Set<Id> bidHistoryIdSet = new Set<Id>();
        Map<Id, Bid_History__c> bidHistoryIdToBidHistoryMap = new Map<Id,Bid_History__c>();
        Map<Id, Opportunity> opportunityIdToOpportunityMap = new Map<Id, Opportunity>();
        Map<Id, pse__Resource_Request__c> RRMap = new Map<Id, pse__Resource_Request__c>();
        List<String> potentialRegionList = new List<String>();
        String opportunityType = '';									
        String therapyArea = '';
        String potentialRegions = '';
        String lineOfBusiness = '';
        String indication = '';
        String FSP ='';			   
        String isThisIQVIABiotech ='';
        String globalProjectUnit = '';
        
        Set<String> skillFieldSet = new Set<String>{'Id', 'Name', 'pse__Type__c'};
        List<pse__Skill__c> skillsList = new SLT_Skill(false, false).getAllSkillRecords(skillFieldSet).values();
        OWF_Config__c owfDefaultConfig = OWF_Config__c.getInstance();
        
        for(pse__Skill__c skill : skillsList){
            if(!skillTypeToSkillNameToSkillMap.containsKey(skill.pse__Type__c)){
                skillTypeToSkillNameToSkillMap.put(skill.pse__Type__c, new Map<String, pse__Skill__c>());
            }
            if(!skillTypeToSkillNameToSkillMap.get(skill.pse__Type__c).containsKey(skill.Name)){
                skillTypeToSkillNameToSkillMap.get(skill.pse__Type__c).put(skill.Name, skill);
            }
        }
        
        for(pse__Resource_Request__c resRequest : newList){
            if(resRequest.recordTypeId == CON_OWF.OWF_RR_RECORD_TYPE_ID && resRequest.SubGroup__c == CON_OWF.RES_REQ_TYPE_GLOBAL_ANALYTICS) {
                RRMap.put(resRequest.Id,resRequest);
            }
            else if(resRequest.recordTypeId == CON_OWF.OWF_RR_RECORD_TYPE_ID) {
                bidHistoryIdSet.add(resRequest.Bid_History__c);
           }
        }
        pse__Resource_Skill_Request__c rsrRecord;
        for(Id resRequestID : RRMap.keyset()){            
            rsrRecord = new pse__Resource_Skill_Request__c();
            rsrRecord.pse__Resource_Request__c = resRequestID;
            if(RRMap.get(resRequestID).Regional_Analytics_Country__c == 'Japan'){
                rsrRecord.pse__Skill_Certification__c = skillTypeToSkillNameToSkillMap.get(CON_OWF.SKILL_TYPE_GLOBAL_ANALYTICS_COUNTRY).get(CON_OWF.SKILL_JAPAN_REGIONAL_ANALYTICS).Id;
            }else{               
                rsrRecord.pse__Skill_Certification__c = skillTypeToSkillNameToSkillMap.get(CON_OWF.SKILL_TYPE_GLOBAL_ANALYTICS_COUNTRY).get(RRMap.get(resRequestID).Regional_Analytics_Country__c).Id;
            }
            rsrRecord.pse__Is_Primary__c = false;
            rsrRecord.pse__Minimum_Rating__c ='1 - Limited Exposure';
            createRsrRecordsList.add(rsrRecord);
        }
        Set<String> bidHistoryFieldSet = new Set<String>{'Id','Opportunity_Type__c',
            'Bid_History_Related_Opportunity__r.Id', 'Bid_History_Related_Opportunity__r.TherapyArea__c', 'Bid_History_Related_Opportunity__r.Potential_Regions__c', 'Bid_History_Related_Opportunity__r.Line_of_Business__c', 'Bid_History_Related_Opportunity__r.Indication_List__c','Bid_History_Related_Opportunity__r.Indication_List__r.Name', 'Bid_History_Related_Opportunity__r.FSP__c', 'Bid_History_Related_Opportunity__r.Is_this_IQVIA_Biotech__c','Bid_History_Related_Opportunity__r.Global_Project_Unit__c'};
                if(bidHistoryIdSet.size() > 0) {
                    bidHistoryIdToBidHistoryMap = new SLT_Bid_History(false, false).getBidHistoriesById(bidHistoryIdSet, bidHistoryFieldSet);
                }
        Set<String> potentialRegToBDLeadMappingFieldSet = new Set<String>{'Id','Potential_Region__c','BD_Lead_Sub_Region__c'};
            Map<String,String> bdLeadToPRMap = new Map<String,String>();
        for(Potential_Region_To_BD_Lead_Mapping__mdt mapping : 
            new SLT_Potential_Region_To_BD_Lead_Mapping(false,false).getPotentialRegionToBDLeadMappings(potentialRegToBDLeadMappingFieldSet)) {
                // Start - IQVIAPSA-1837
                if(mapping.BD_Lead_Sub_Region__c == 'Australia & New Zealand'){
                    bdLeadToPRMap.put('Australia & NZ',mapping.Potential_Region__c);
                }else{
                    bdLeadToPRMap.put(mapping.BD_Lead_Sub_Region__c,mapping.Potential_Region__c); 
                }
                // end - IQVIAPSA-1837
            }
        for(pse__Resource_Request__c resRequest : newList){
            if(bidHistoryIdToBidHistoryMap.containsKey(resRequest.Bid_History__c) && bidHistoryIdToBidHistoryMap.get(resRequest.Bid_History__c).Bid_History_Related_Opportunity__c != null){
                therapyArea = bidHistoryIdToBidHistoryMap.get(resRequest.Bid_History__c).Bid_History_Related_Opportunity__r.TherapyArea__c;
                potentialRegions = bidHistoryIdToBidHistoryMap.get(resRequest.Bid_History__c).Bid_History_Related_Opportunity__r.Potential_Regions__c;
                lineOfBusiness = bidHistoryIdToBidHistoryMap.get(resRequest.Bid_History__c).Bid_History_Related_Opportunity__r.Line_of_Business__c;
                indication = bidHistoryIdToBidHistoryMap.get(resRequest.Bid_History__c).Bid_History_Related_Opportunity__r.Indication_List__r.Name;
                FSP = bidHistoryIdToBidHistoryMap.get(resRequest.Bid_History__c).Bid_History_Related_Opportunity__r.FSP__c;																																
                isThisIQVIABiotech = bidHistoryIdToBidHistoryMap.get(resRequest.Bid_History__c).Bid_History_Related_Opportunity__r.Is_this_IQVIA_Biotech__c;
                globalProjectUnit = bidHistoryIdToBidHistoryMap.get(resRequest.Bid_History__c).Bid_History_Related_Opportunity__r.Global_Project_Unit__c;
                if(potentialRegions != null && potentialRegions != ''){
                    potentialRegionList = potentialRegions.split(';');
                }
            }
            if(bidHistoryIdToBidHistoryMap.containsKey(resRequest.Bid_History__c)){
                opportunityType = bidHistoryIdToBidHistoryMap.get(resRequest.Bid_History__c).Opportunity_Type__c;
            }
            
            if(skillTypeToSkillNameToSkillMap.containsKey(CON_OWF.SKILL_TYPE_LINE_OF_BUSINESS) 
            && lineOfBusiness != null  && lineOfBusiness != '' 
            && skillTypeToSkillNameToSkillMap.get(CON_OWF.SKILL_TYPE_LINE_OF_BUSINESS).containsKey(lineOfBusiness) ){
                   rsrRecord = new pse__Resource_Skill_Request__c();
                   rsrRecord.pse__Resource_Request__c = resRequest.Id;
                   rsrRecord.pse__Skill_Certification__c = skillTypeToSkillNameToSkillMap.get(CON_OWF.SKILL_TYPE_LINE_OF_BUSINESS).get(lineOfBusiness).Id;
                   rsrRecord.pse__Is_Primary__c = false;
                   createRsrRecordsList.add(rsrRecord);
               }
            
            if(skillTypeToSkillNameToSkillMap.containsKey(CON_OWF.SKILL_TYPE_OPPORTUNITY_TYPE) 
               && opportunityType != null  && opportunityType != '' 
               && skillTypeToSkillNameToSkillMap.get(CON_OWF.SKILL_TYPE_OPPORTUNITY_TYPE).containsKey(opportunityType) ){
                   rsrRecord = new pse__Resource_Skill_Request__c();
                   rsrRecord.pse__Resource_Request__c = resRequest.Id;
                   rsrRecord.pse__Skill_Certification__c = skillTypeToSkillNameToSkillMap.get(CON_OWF.SKILL_TYPE_OPPORTUNITY_TYPE).get(opportunityType).Id;
                   rsrRecord.pse__Is_Primary__c = false;
                   createRsrRecordsList.add(rsrRecord);
               } 
            if(skillTypeToSkillNameToSkillMap.containsKey(CON_OWF.SKILL_TYPE_GLOBAL_PROJECT_UNIT) 
               && globalProjectUnit != null  && globalProjectUnit != '' && (lineOfBusiness == CON_OWF.LINE_OF_BUSINESS_CLINICAL || lineOfBusiness == CON_OWF.LINE_OF_BUSINESS_EARLY_CLINICAL_DEVELOPMENT || lineOfBusiness == CON_OWF.LINE_OF_BUSINESS_OUTCOME)
               && skillTypeToSkillNameToSkillMap.get(CON_OWF.SKILL_TYPE_GLOBAL_PROJECT_UNIT).containsKey(globalProjectUnit)
               && resRequest.SubGroup__c == CON_OWF.RES_REQ_TYPE_IG_LEAD){
                   rsrRecord = new pse__Resource_Skill_Request__c();
                   rsrRecord.pse__Resource_Request__c = resRequest.Id;
                   rsrRecord.pse__Skill_Certification__c = skillTypeToSkillNameToSkillMap.get(CON_OWF.SKILL_TYPE_GLOBAL_PROJECT_UNIT).get(globalProjectUnit).Id;
                   rsrRecord.pse__Is_Primary__c = false;
                   createRsrRecordsList.add(rsrRecord);
               }
            
            if(skillTypeToSkillNameToSkillMap.containsKey(CON_OWF.SKILL_TYPE_INDICATION) 
               && indication != null && indication != '' 
               && indication != 'Not applicable'
               && skillTypeToSkillNameToSkillMap.get(CON_OWF.SKILL_TYPE_INDICATION).containsKey(indication) ){
                   rsrRecord = new pse__Resource_Skill_Request__c();
                   rsrRecord.pse__Resource_Request__c = resRequest.Id;
                   rsrRecord.pse__Skill_Certification__c = skillTypeToSkillNameToSkillMap.get(CON_OWF.SKILL_TYPE_INDICATION).get(indication).Id;
                   rsrRecord.pse__Is_Primary__c = false;
                   createRsrRecordsList.add(rsrRecord);
               }
            if(skillTypeToSkillNameToSkillMap.containsKey(CON_OWF.SKILL_TYPE_OPPORTUNITY_LEVEL) 
               && lineOfBusiness != null  && lineOfBusiness != '' && (lineOfBusiness == 'Clinical' || lineOfBusiness == CON_OWF.LINE_OF_BUSINESS_EARLY_CLINICAL_DEVELOPMENT || lineOfBusiness == CON_OWF.LINE_OF_BUSINESS_OUTCOME)
               && FSP != null  && FSP != '' && FSP == 'Yes'
               && skillTypeToSkillNameToSkillMap.get(CON_OWF.SKILL_TYPE_OPPORTUNITY_LEVEL).containsKey('FSP') ){
                   rsrRecord = new pse__Resource_Skill_Request__c();
                   rsrRecord.pse__Resource_Request__c = resRequest.Id;
                   rsrRecord.pse__Skill_Certification__c = skillTypeToSkillNameToSkillMap.get(CON_OWF.SKILL_TYPE_OPPORTUNITY_LEVEL).get('FSP').Id;
                   rsrRecord.pse__Is_Primary__c = false;
                   createRsrRecordsList.add(rsrRecord);
               }
            if(skillTypeToSkillNameToSkillMap.containsKey(CON_OWF.SKILL_TYPE_OPPORTUNITY_LEVEL) 
               && lineOfBusiness != null  && lineOfBusiness != '' && (lineOfBusiness == 'Clinical' || lineOfBusiness == CON_OWF.LINE_OF_BUSINESS_EARLY_CLINICAL_DEVELOPMENT || lineOfBusiness == CON_OWF.LINE_OF_BUSINESS_OUTCOME)
               && isThisIQVIABiotech != null  && isThisIQVIABiotech != '' && isThisIQVIABiotech == 'Yes'
               && skillTypeToSkillNameToSkillMap.get(CON_OWF.SKILL_TYPE_OPPORTUNITY_LEVEL).containsKey('IQVIA Biotech') ){
                   rsrRecord = new pse__Resource_Skill_Request__c();
                   rsrRecord.pse__Resource_Request__c = resRequest.Id;
                   rsrRecord.pse__Skill_Certification__c = skillTypeToSkillNameToSkillMap.get(CON_OWF.SKILL_TYPE_OPPORTUNITY_LEVEL).get('IQVIA Biotech').Id;
                   rsrRecord.pse__Is_Primary__c = false;
                   createRsrRecordsList.add(rsrRecord);
               }
            if(skillTypeToSkillNameToSkillMap.containsKey(CON_OWF.SKILL_TYPE_OPPORTUNITY_LEVEL) 
               && lineOfBusiness != null  && lineOfBusiness != '' && lineOfBusiness == CON_OWF.LINE_OF_BUSINESS_CLINICAL
               && isThisIQVIABiotech != null  && isThisIQVIABiotech != '' && isThisIQVIABiotech == CON_OWF.OWF_NO
               && skillTypeToSkillNameToSkillMap.get(CON_OWF.SKILL_TYPE_OPPORTUNITY_LEVEL).containsKey(CON_OWF.CORE_SKILL) ){
                   rsrRecord = new pse__Resource_Skill_Request__c();
                   rsrRecord.pse__Resource_Request__c = resRequest.Id;
                   rsrRecord.pse__Skill_Certification__c = skillTypeToSkillNameToSkillMap.get(CON_OWF.SKILL_TYPE_OPPORTUNITY_LEVEL).get(CON_OWF.CORE_SKILL).Id;
                   rsrRecord.pse__Is_Primary__c = false;
                   createRsrRecordsList.add(rsrRecord);
               }
            if(skillTypeToSkillNameToSkillMap.containsKey(CON_OWF.SKILL_TYPE_THERAPY_AREA) 
             && therapyArea !=null  && therapyArea != '' ){
                   rsrRecord = new pse__Resource_Skill_Request__c();
                   rsrRecord.pse__Resource_Request__c = resRequest.Id;

                   if(skillTypeToSkillNameToSkillMap.get(CON_OWF.SKILL_TYPE_THERAPY_AREA).containsKey(therapyArea)){
                       rsrRecord.pse__Skill_Certification__c = skillTypeToSkillNameToSkillMap.get(CON_OWF.SKILL_TYPE_THERAPY_AREA).get(therapyArea).Id;
                    }else if(!skillTypeToSkillNameToSkillMap.get(CON_OWF.SKILL_TYPE_THERAPY_AREA).containsKey(therapyArea) &&
                      therapyArea.equals('Allergy') && owfDefaultConfig.Out_of_Sync_Skill_Name__c!='' && skillTypeToSkillNameToSkillMap.get(CON_OWF.SKILL_TYPE_THERAPY_AREA).containsKey(owfDefaultConfig.Out_of_Sync_Skill_Name__c)){
                       rsrRecord.pse__Skill_Certification__c = skillTypeToSkillNameToSkillMap.get(CON_OWF.SKILL_TYPE_THERAPY_AREA).get(owfDefaultConfig.Out_of_Sync_Skill_Name__c).Id;
                    }
                   rsrRecord.pse__Is_Primary__c = false;
                   createRsrRecordsList.add(rsrRecord);
               }
            
            for(String tempPotentialRegion : potentialRegionList){
                if(tempPotentialRegion == 'Global') {
                    if(!bdLeadToPRMap.isEmpty() && bdLeadToPRMap.containsKey(resRequest.BD_Lead_Sub_Region__c)
                       && skillTypeToSkillNameToSkillMap.containsKey(CON_OWF.SKILL_TYPE_POTENTIAL_REGION)
                       && skillTypeToSkillNameToSkillMap.get(CON_OWF.SKILL_TYPE_POTENTIAL_REGION).containsKey(bdLeadToPRMap.get(resRequest.BD_Lead_Sub_Region__c))) {
                           
                           
                           rsrRecord = new pse__Resource_Skill_Request__c();
                           rsrRecord.pse__Resource_Request__c = resRequest.Id;
                           rsrRecord.pse__Skill_Certification__c = skillTypeToSkillNameToSkillMap.get(CON_OWF.SKILL_TYPE_POTENTIAL_REGION).get(bdLeadToPRMap.get(resRequest.BD_Lead_Sub_Region__c)).Id;
                           rsrRecord.pse__Is_Primary__c = false;
                           createRsrRecordsList.add(rsrRecord);
                       }                
                }
                else if(skillTypeToSkillNameToSkillMap.containsKey(CON_OWF.SKILL_TYPE_POTENTIAL_REGION) 
                        && tempPotentialRegion !=null && tempPotentialRegion != ''
                        && skillTypeToSkillNameToSkillMap.get(CON_OWF.SKILL_TYPE_POTENTIAL_REGION).containsKey(tempPotentialRegion) ){
                            rsrRecord = new pse__Resource_Skill_Request__c();
                            rsrRecord.pse__Resource_Request__c = resRequest.Id;
                            rsrRecord.pse__Skill_Certification__c = skillTypeToSkillNameToSkillMap.get(CON_OWF.SKILL_TYPE_POTENTIAL_REGION).get(tempPotentialRegion).Id;
                            rsrRecord.pse__Is_Primary__c = false;
                            createRsrRecordsList.add(rsrRecord);
                        }
            }
        }
        return createRsrRecordsList;
    }
    
    /**
* This method is used to delete Assignment record based on Resource.
* @params  newList List<pse__Assignment__c>
* @return  
*/
    public static void deleteAssignmentBasedOnResourceRequest(List<pse__Resource_Request__c> newList) {
        List<pse__Assignment__c> assignmentToBeDeletedList = new List<pse__Assignment__c>();
        assignmentToBeDeletedList = returnAssignmentBasedOnResourceRequest(newList);
        if(assignmentToBeDeletedList.size() > 0) {
            QBL_OWF_DeletionLogic.QueueAssignmentDeletion  queuableObject = new QBL_OWF_DeletionLogic.QueueAssignmentDeletion(assignmentToBeDeletedList);
            System.enqueueJob(queuableObject);
        }
    }
    
    private static List<pse__Assignment__c> returnAssignmentBasedOnResourceRequest(List<pse__Resource_Request__c> newList) {
        List<pse__Assignment__c> assignmentToBeReturnedList = new List<pse__Assignment__c>();
        Set<String> assignmentFieldSet = new Set<String>{'Id'};
            Map<Id, pse__Resource_Request__c> resourceRequestIdResourceRequestMap= new Map<Id, pse__Resource_Request__c>();
        for(pse__Resource_Request__c resourceRequest : newList)
        {
            if(resourceRequest.recordTypeId == CON_OWF.OWF_RR_RECORD_TYPE_ID) {
                resourceRequestIdResourceRequestMap.put(resourceRequest.ID, resourceRequest );
            }              
        }
        if(resourceRequestIdResourceRequestMap.size() > 0) {
            Map<Id, pse__Assignment__c> assignmentIdToAssignmentMap = new SLT_Assignment(false,false).getAssignmentResourceRequest(resourceRequestIdResourceRequestMap.keySet(),assignmentFieldSet );
            assignmentToBeReturnedList  = assignmentIdToAssignmentMap.values();
        }
        return assignmentToBeReturnedList;
    } 
    
    /**
* This method is used to rollup the Assignments fields on the Resource based on the value of Suggested FTE.
* @params  newResourceRequestList List<pse__Resource_Request__c>
* @params  oldResourceRequestMap Map<Id,pse__Resource_Request__c>
* @return  void
*/
    public static void populateRollupAssignmentFieldsOnContact(List<pse__Resource_Request__c> newResourceRequestList, Map<Id,pse__Resource_Request__c> oldResourceRequestMap){
        Set<Id> resourceRequestIdSet = new Set<Id>();
        for(pse__Resource_Request__c resourceRequest : newResourceRequestList){
            if(resourceRequest.recordTypeId == CON_OWF.OWF_RR_RECORD_TYPE_ID && resourceRequest.Suggested_FTE__c != oldResourceRequestMap.get(resourceRequest.Id).Suggested_FTE__c){
                resourceRequestIdSet.add(resourceRequest.Id);
            }
        }
        if(resourceRequestIdSet.size() > 0){
            String assignmentCondition = ' pse__Resource_Request__c IN :sObjectIdSet ';
            Set<String> assignmentFieldSet = new Set<String>{'Id', 'pse__Resource__c', 'pse__Status__c', 'Suggested_FTE__c', 'pse__Resource_Request__c','Estimation_Effort__c'};
                List<pse__Assignment__c> assignmentList = new SLT_Assignment(false,false).getAssignmentByResource(resourceRequestIdSet, assignmentCondition, assignmentFieldSet);
            
            if(!assignmentList.isEmpty()){
                Set<Id> resourceIdSet = new Set<Id>();
                for(pse__Assignment__c assignment : assignmentList){
                    resourceIdSet.add(assignment.pse__Resource__c);
                }
                assignmentCondition = ' pse__Resource__c IN :sObjectIdSet ';
                assignmentFieldSet.clear();
                assignmentFieldSet = new Set<String>{'Id', 'pse__Resource__c', 'pse__Status__c', 'Suggested_FTE__c','pse__Start_Date__c','Estimation_Effort__c'};
                    assignmentList.clear();
                assignmentList = new SLT_Assignment(false,false).getAssignmentByResource(resourceIdSet, assignmentCondition, assignmentFieldSet);
                
                if(!assignmentList.isEmpty()){
                    DAOH_OWF_Assignment.updateRollupAssignmentFieldsOnContact(assignmentList,null);
                }
            }
            
        }
    }
    
    /**
* This method is used to update Complexity Score Total on Resource Request based on the values from
* related Agreement, Opportunity and OWF Resource Setting.
* @params  newList List<pse__Resource_Request__c>
* @return  void
*/
    
    /**
* This method is used to update Complexity Score Total on Resource Request based on the values from
* related Agreement, Opportunity and OWF Resource Setting.
* @params  newList List<pse__Resource_Request__c>
* @return  void
*/
    public static void updateComplexityScoreTotal(List<pse__Resource_Request__c> newList,Map<Id, pse__Resource_Request__c> oldMap) {
        Set<Id> rrAgreementIdSet = new Set<Id>();
        Map<Id, Bid_History__c> agrIdToAgreementMap = new Map<Id, Bid_History__c>();
        Map<String,OWF_Resource_Setting__mdt> resSettingIdToResSettingMap = new Map<String,OWF_Resource_Setting__mdt>();        
        List<pse__Resource_Request__c> rrList = new List<pse__Resource_Request__c>();
        Set<String> orsFieldSet = new Set<String>{'Id','Sub_Group__c', 'Estimated_Fees__c','Is_there_a_Client_Bid_Grid__c','Number_of_Sites__c',
            'Potential_Regions__c','Project_Ex_Number_of_Unique_Tables__c','Re_Bid_Complexity__c',
            'Requested_Services__c','RFP_Ranking__c','Staffing_Number_of_Unique_Tables__c','Country__c'};
                
                for(OWF_Resource_Setting__mdt rsCMT : new SLT_OWF_Resource_Setting(false, false).getOWFResourceSettingRecords(orsFieldSet)) {
                    resSettingIdToResSettingMap.put(rsCMT.Sub_Group__c,rsCMT);                                          
                }
        if(resSettingIdToResSettingMap.size() > 0) {
            for(pse__Resource_Request__c rr : newList) {
                if(rr.recordTypeId == CON_OWF.OWF_RR_RECORD_TYPE_ID && (rr.SubGroup__c != '' && rr.SubGroup__c != null) && resSettingIdToResSettingMap.containsKey(rr.SubGroup__c) 
                   && rr.Bid_History__c != NULL && (Trigger.isInsert || (Trigger.isUpdate && oldMap.get(rr.id).SubGroup__c != rr.SubGroup__c))) {
                       rrAgreementIdSet.add(rr.Bid_History__c);
                       rrList.add(rr);
                   }
            }    
            if(rrAgreementIdSet.size() > 0) {
                //IQVIAPSA-2165 (start) 
                Set<String> agrFieldSet = new Set<String>{'Id', 'Name','RFP_Ranking__c','Number_of_Sites__c','Re_Bid_Complexity__c',
                    'Estimated_Fees__c','Is_there_a_Client_Bid_Grid__c','Number_of_Requested_Services__c',
                    'Staffing_Number_of_Unique_Tables__c','Triage_Level__c','Project_Ex_Number_of_Unique_Tables__c',
                    'Bid_History_Related_Opportunity__r.Number_of_Potential_Regions__c','Bid_History_Related_Opportunity__r.Potential_Regions__c',
                    'Bid_History_Related_Opportunity__c','Bid_Due_Date__c','Bid_History_Related_Opportunity__r.Bid_Defense_Date__c','CreatedDate','Triage_Level__c','Grid_Ranking_Level__c'};
                        //IQVIAPSA-2165 (stop) 
                agrIdToAgreementMap = new SLT_Bid_History(false,false).getBidHistoriesById(rrAgreementIdSet, agrFieldSet);
                UTL_OWF.calculateComplexityScoreTotal(agrIdToAgreementMap,resSettingIdToResSettingMap,rrList);
                UTL_OWF.calculateWRandSuggestedFTE(agrIdToAgreementMap,rrList);
                //system.assert(false,'Show debug');
                
            }
            
        }
    }
    
    
    
    /**
* This method is used to do calculation on RR based using OWF Assignment Setting CMT
* @params  newList List<pse__Resource_Request__c>

*/
    public static void updateDataBasedOnOASetting(List<pse__Resource_Request__c> newList,Map<Id, pse__Resource_Request__c> oldMap) {
        Set<Id> rrAgreementIdSet = new Set<Id>();
        Map<Id, Bid_History__c> agrIdToAgreementMap = new Map<Id, Bid_History__c>();
        List<pse__Resource_Request__c> rrList = new List<pse__Resource_Request__c>();
        for(pse__Resource_Request__c rr : newList) {
            
            if(rr.recordTypeId == CON_OWF.OWF_RR_RECORD_TYPE_ID && Trigger.isUpdate && oldMap.get(rr.id).Is_Bid_Defense__c  != rr.Is_Bid_Defense__c) {
                rrAgreementIdSet.add(rr.Bid_History__c);
                rrList.add(rr);
            }
        }    
        if(rrAgreementIdSet.size() > 0) {
            //IQVIAPSA-2165 (start) 
            Set<String> agrFieldSet = new Set<String>{'Id', 'Name','RFP_Ranking__c','Number_of_Sites__c','Re_Bid_Complexity__c',
                'Estimated_Fees__c','Is_there_a_Client_Bid_Grid__c','Number_of_Requested_Services__c',
                'Staffing_Number_of_Unique_Tables__c','Project_Ex_Number_of_Unique_Tables__c',
                'Bid_History_Related_Opportunity__r.Number_of_Potential_Regions__c','Bid_History_Related_Opportunity__r.Potential_Regions__c',
                'Bid_History_Related_Opportunity__c','Bid_Due_Date__c','Bid_History_Related_Opportunity__r.Bid_Defense_Date__c','CreatedDate','Triage_Level__c','Grid_Ranking_Level__c'};
                    //IQVIAPSA-2165 (stop) 
                    agrIdToAgreementMap = new SLT_Bid_History(false,false).getBidHistoriesById(rrAgreementIdSet, agrFieldSet);
            UTL_OWF.calculateWRandSuggestedFTE(agrIdToAgreementMap,rrList);
        }
    }
    
    
    public static void updateAssignmentStartAndEndDate(List<pse__Resource_Request__c> rrList,Map<Id, pse__Resource_Request__c> oldMap) {
        Set<Id> resourceRequestIdSet = new Set<Id>();
        Map<Id, pse__Assignment__c> schdToAssignmnetMap = new Map<Id, pse__Assignment__c>();
        Set<Id> scheduleIdSet = new Set<Id>();
        Map<Id, pse__Schedule__c> schIdSchMap = new Map<Id, pse__Schedule__c>();
        List<pse__Schedule__c> schUpdateList = new List<pse__Schedule__c>();
        
        for(pse__Resource_Request__c rr: rrList){
            if(rr.recordTypeId == CON_OWF.OWF_RR_RECORD_TYPE_ID && rr.pse__End_Date__c != oldMap.get(rr.Id).pse__End_Date__c){
                resourceRequestIdSet.add(rr.Id);
            }
        }
        if(resourceRequestIdSet.size() > 0){
            String assignmentCondition = ' pse__Resource_Request__c IN :sObjectIdSet ';
            Set<String> assignmentFieldSet = new Set<String>{'Id', 'pse__Schedule__c','pse__Resource_Request__r.pse__End_Date__c','pse__Resource_Request__r.pse__Start_Date__c','pse__Resource_Request__r.Is_Bid_Defense__c','pse__Resource_Request__r.pse__Assignment__r.CreatedDate'};
                Set<String> scheduleFieldSet = new Set<String>{'Id','pse__Start_Date__c','pse__End_Date__c'};
                    for(pse__Assignment__c assign : new SLT_Assignment(false,false).getAssignmentByResource(resourceRequestIdSet, assignmentCondition, assignmentFieldSet)) {
                        scheduleIdSet.add(assign.pse__Schedule__c);
                        schdToAssignmnetMap.put(assign.pse__Schedule__c,assign);
                    }
            if(scheduleIdSet.size() > 0) {
                schIdSchMap = new SLT_Schedule(false).selectScheduleById(scheduleIdSet,scheduleFieldSet ); 
                for(pse__Schedule__c sch : schIdSchMap.values()) {
                    if(schdToAssignmnetMap.get(sch.id).pse__Resource_Request__r.Is_Bid_Defense__c)
                    {
                        sch.pse__Start_Date__c = (schdToAssignmnetMap.get(sch.id).pse__Resource_Request__r.pse__End_Date__c < Date.Today() || schdToAssignmnetMap.get(sch.id).pse__Resource_Request__r.pse__Start_Date__c > Date.Today()) ? schdToAssignmnetMap.get(sch.id).pse__Resource_Request__r.pse__Start_Date__c : (schdToAssignmnetMap.get(sch.id).pse__Resource_Request__r.pse__Assignment__r.CreatedDate).date();
                    }
                    sch.pse__End_Date__c = schdToAssignmnetMap.get(sch.id).pse__Resource_Request__r.pse__End_Date__c;
                    schUpdateList.add(sch);
                }
            }
        }  
        if(schUpdateList.size() > 0) {
            update schUpdateList;
        }
    }
    
    
    public static void validateManualResourceRequestCreator(List<pse__Resource_Request__c> rrList)
    {
        Mulesoft_Integration_Control__c mulesoftSetting = Mulesoft_Integration_Control__c.getInstance();
        if(!mulesoftSetting.Ignore_Validation_Rules__c)
        {
            boolean resourceCheck = UTL_OWF.validateResourceGroup(UserInfo.getUserId());
            for(pse__Resource_Request__c rr: rrList)
            {
                if(rr.RecordTypeId == CON_OWF.OWF_RR_RECORD_TYPE_ID && !rr.Is_Created_Automatically__c 
                    && rr.SubGroup__c != 'LCS Product Specialist' && rr.SubGroup__c != 'LCS Bid Defense' 
                    && !resourceCheck){
                        rr.addError('\n Only OWF Compatible Group Users can create manual Resource Request');
                }
                if(rr.SubGroup__c == CON_OWF.RES_REQ_TYPE_GLOBAL_ANALYTICS && String.isBlank(rr.Regional_Analytics_Country__c)){
                        rr.addError('\n Countries are required for '+CON_OWF.RES_REQ_TYPE_GLOBAL_ANALYTICS);
                }
                        
            }
        }
    }
    
    /**
* This method is used to create Assignments on RR creation.
* @params List<pse__Resource_Request__c> newList
* @return void
*/
    public static void createAssignments(List<pse__Resource_Request__c> newList) {
        Set<Id> rrAgreementIdSet = new Set<Id>();
        Map<Id, Bid_History__c> agrIdToAgreementMap = new Map<Id, Bid_History__c>();
        Map<Id,pse__Resource_Request__c> clinicalRrToOpptyMap = new Map<Id,pse__Resource_Request__c>();
        Map<Id,pse__Resource_Request__c> clinicalBidDefenceRrToOpptyMap = new Map<Id,pse__Resource_Request__c>();
        Map<Id,pse__Resource_Request__c> skillRatingRRToOpptyMap = new Map<Id,pse__Resource_Request__c>();
        Map<Id,pse__Resource_Request__c> backupUserRrIdToRrMap = new Map<Id,pse__Resource_Request__c>();
        Map<Id, Opportunity> oppIdToOppMap = new Map<Id, Opportunity>(); 
        List<pse__Assignment__c> assignmentList = new list<pse__Assignment__c>();
        Map<Id,pse__Schedule__c> rrIdToScheduleMap = new Map<Id,pse__Schedule__c>();
        Map<Id,List<pse__Assignment__c>> oppIdToAssignMap = new Map<Id,List<pse__Assignment__c>>();
        Map<Id,Map<String,List<pse__Assignment__c>>> oppIdtoSubgroupNameToAssignmentMap = new Map<Id,Map<String,List<pse__Assignment__c>>>();
        Map<Id,Set<Id>> rrIdToContactsMap = new Map<Id,Set<Id>>();
        Map<Id,Set<Id>> rrIdToResourceMap = new Map<Id,Set<Id>>();
        Map<Id,List<Id>> rrIdToBackupContactsMap = new Map<Id,List<Id>>();
        Map<Id,pse__Assignment__c> rrIdToAssignmentMap = new Map<Id,pse__Assignment__c>();
        Set<Id> preferredResourceAssignmentIdSet = new Set<Id>();
        List<String> lineOfBusinessValues = new List<String>();
        Map<Id,pse__Assignment__c> autoAssignmentIdToAssignmentMap = new Map<Id,pse__Assignment__c>(); 
        List<Id> CTS_Lead_AutoAssignResourceOptions = new List<Id>();
        Map<Id, Contact> CTS_Lead_AutoAssignResources = new Map<Id, Contact>();
        Map<Id, pse__Resource_Request__c> contractPostAwardRRIdToResourceRequestMap = new Map<Id, pse__Resource_Request__c>();
        List<Id> CTS_Lead_RRIds = new List<Id>();
        
        Map<Id,Id> rrIdToContactIdMap = new Map<Id,Id>();
        Map<id,pse__Assignment__c> rRToAssignmentMap = new Map<id,pse__Assignment__c>();
        Map<id,pse__Schedule__c> rRToScheduleMap = new Map<id,pse__Schedule__c>();
        Map<id,pse__Assignment__c> rRTOAssignmtMap = new Map<id,pse__Assignment__c>();
        pse__Assignment__c objAssignment;
        pse__Schedule__c objSchedule;
        Map<String,OWF_Resources_Needed_to_SubGroup_Map__c> resourceToSubGroupMap = OWF_Resources_Needed_to_SubGroup_Map__c.getAll();
        Map<Id,pse__Resource_Request__c> rrIdToRrToUpdateMap = new Map<Id,pse__Resource_Request__c>();
        Set<Id> contactIdOFEESet = new Set<Id>();
        Set<String> rrOfEarlyEnagegementBidFieldSet = new Set<String>{'LeadSupportFlag__c', 'Resource_Request_Type__c', 'RecordTypeId', 'RecordType.Name', 'pse__Assignment__c', 'pse__Assignment__r.pse__Resource__c', 'pse__Opportunity__c', 'SubGroup__c'};
        Set<Id> oppIdToCloneRROriginalAssigneeSet = new Set<Id>();
        for(pse__Resource_Request__c rr : newList){
            oppIdToCloneRROriginalAssigneeSet.add(rr.pse__Opportunity__c);
        }
        String rrCondition ='and LeadSupportFlag__c = \'Lead\' and Resource_Request_Type__c =\'Early Engagement\' and pse__Assignment__c != null';
        Map<String,pse__Resource_Request__c> subgroupToRRMap = new Map<String,pse__Resource_Request__c>();
        List<pse__Resource_Request__c> rrOfEarlyEnagegementBid = new List<pse__Resource_Request__c>();
        if(oppIdToCloneRROriginalAssigneeSet.size() > 0){
             rrOfEarlyEnagegementBid = new SLT_Resource_Request(false,false).getResourceRequestListFromOpportunityOBCreatedDate(oppIdToCloneRROriginalAssigneeSet, rrOfEarlyEnagegementBidFieldSet, rrCondition);
        }
        for(pse__Resource_Request__c rr: rrOfEarlyEnagegementBid){
            contactIdOFEESet.add(rr.pse__Assignment__r.pse__Resource__c);
            if(!subgroupToRRMap.containsKey(rr.SubGroup__c)){
                subgroupToRRMap.put(rr.SubGroup__c,rr);
            }
        }
        for(pse__Resource_Request__c rr : newList){
            if((rr.Resource_Request_Type__c == CON_OWF.RES_REQ_TYPE_CLINICAL || rr.Resource_Request_Type__c == CON_OWF.RES_REQ_TYPE_CLINICAL_BALLPARK) && !rr.Is_Bid_Defense__c && subgroupToRRMap.containsKey(rr.SubGroup__c)){
                    pse__Resource_Request__c sameRR = new pse__Resource_Request__c();
                    sameRR.id = rr.Id;
                    sameRR.Original_Assignee__c = subgroupToRRMap.get(rr.SubGroup__c).pse__Assignment__r.pse__Resource__c;
                    rrIdToRrToUpdateMap.put(sameRR.id, sameRR);
            }
        }
        if(rrIdToRrToUpdateMap.size() > 0) {
            
            UTL_ExecutionControl.stopTriggerExecution_OWF = true;
            update rrIdToRrToUpdateMap.values();
            UTL_ExecutionControl.stopTriggerExecution_OWF = false;
        }
        Set<String> contactFieldOFEEBidSet = new Set<String>{'Id', 'Available_for_Triage_Flag__c', 'pse__Work_Calendar__c', 'Available_FTE__c', 'pse__Group__c', 'Sub_Group__c', 'pse__Is_Resource__c', 'pse__Is_Resource_Active__c', 'pse__Salesforce_User__r.IsActive'};
        Map<Id,Contact> contactIdToContactMap = new Map<Id,Contact>();
        if(contactIdOFEESet.size() > 0){
            contactIdToContactMap = new SLT_Contact().selectByContactId(contactIdOFEESet, contactFieldOFEEBidSet);
        }	
           
        
        for(pse__Resource_Request__c rr : newList) { 
            
            if(rr.recordTypeId == CON_OWF.OWF_RR_RECORD_TYPE_ID && rr.Bid_History__c != null && rr.Is_Created_Automatically__c ) {
                /*OWF_Config__c owfDefaultConfig = OWF_Config__c.getInstance();
                
                String lcsResourceId = owfDefaultConfig.LCS_Bid_Defence_Resource__c;*/
                if(rr.SubGroup__c == 'LCS Bid Defense' || rr.SubGroup__c == 'STS-Lead'|| rr.SubGroup__c == 'CTS-Lead')
                {
                    if(resourceToSubGroupMap.get(rr.SubGroup__c)!=null)
                    {
                        objAssignment= new pse__Assignment__c(); 
                        objAssignment.pse__Project__c = rr.pse__Project__c;
                        objAssignment.Bid_History__c = rr.Bid_History__c;
                        if (resourceToSubGroupMap.get(rr.SubGroup__c).Sub_Group__c == 'CTS-Lead') {
                            CTS_Lead_RRIds.add(rr.Id);
                            CTS_Lead_AutoAssignResourceOptions = resourceToSubGroupMap.get(rr.SubGroup__c).Auto_Assign_Resource__c.split(';');
                            objAssignment.pse__Resource__c = Id.valueOf(CTS_Lead_AutoAssignResourceOptions[0]);
                        }else {
                            objAssignment.pse__Resource__c = Id.valueOf(resourceToSubGroupMap.get(rr.SubGroup__c).Auto_Assign_Resource__c);
                        }
                        objAssignment.pse__Resource_Request__c = rr.Id;
                        objAssignment.pse__Is_Billable__c = false;
                        objAssignment.pse__Bill_Rate__c = 0;
                        objAssignment.pse__Status__c = 'Pending'; 
                        objAssignment.CurrencyIsoCode = rr.CurrencyIsoCode;
                        objAssignment.RecordTypeId = CON_OWF.OWF_ASSIGNMENT_RECORD_TYPE_ID;
                        objAssignment.Trigger_Email_Notification__c = true;
                        if(rr.SubGroup__c == 'LCS Bid Defense')
                        {                            
                            rRToScheduleMap.put(rr.Id,createdSchedule(rr.pse__Start_Date__c, rr.pse__End_Date__c));
                            rRTOAssignmtMap.put(rr.Id,objAssignment); 
                        }
                        else if(rr.SubGroup__c == 'STS-Lead'|| rr.SubGroup__c == 'CTS-Lead')
                        {
                            rrIdToScheduleMap.put(rr.Id,createdSchedule(rr.pse__Start_Date__c, rr.pse__End_Date__c));
                            autoAssignmentIdToAssignmentMap.put(rr.Id,objAssignment);
                        }
                    }
                }
                rrAgreementIdSet.add(rr.Bid_History__c);
            }
        }
        if(rrAgreementIdSet.size() > 0) {
            Set<String> agrFieldSet = new Set<String>{'Id', 'Name','RFP_Ranking__c','Number_of_Sites__c','Re_Bid_Complexity__c',
                'Estimated_Fees__c','Is_there_a_Client_Bid_Grid__c','Number_of_Requested_Services__c',
                'Staffing_Number_of_Unique_Tables__c','Project_Ex_Number_of_Unique_Tables__c',
                'Bid_History_Related_Opportunity__r.Number_of_Potential_Regions__c','Bid_History_Related_Opportunity__r.Potential_Regions__c',
                'Bid_History_Related_Opportunity__c','Bid_Due_Date__c','Bid_History_Related_Opportunity__r.Bid_Defense_Date__c'};
                    agrIdToAgreementMap = new SLT_Bid_History(false,false).getBidHistoriesById(rrAgreementIdSet, agrFieldSet);
        }
        
        Map<String, List<OWF_Assignment_Setting__mdt>> oasIdToOasMap = new Map<String, List<OWF_Assignment_Setting__mdt>>();
        Set<String> oasFieldSet = new Set<String>{'Id','Complexity_Score__c','Resource_Request_Type__c','Suggested_FTE__c','Workload_Ranking__c','Field_Start_Date__c','Field_End_Date__c','Sub_Group__c',
            'Value_Adjusted_Start_Days__c','Value_Adjusted_End_Days__c','RFP_Ranking__c',
            'Automation_initial_bid_flag__c','Disable_availability_flag__c','Line_of_Business__c'};
                if(agrIdToAgreementMap.size() > 0) {
                    for(OWF_Assignment_Setting__mdt oasCMT : new SLT_OWF_Assignment_Setting(false, false).getOWFAssignmentSettingRecords(oasFieldSet)) {
                        if(!oasIdToOasMap.containsKey(oasCMT.Resource_Request_Type__c)) {
                            oasIdToOasMap.put(oasCMT.Resource_Request_Type__c,new List<OWF_Assignment_Setting__mdt>()); 
                            oasIdToOasMap.get(oasCMT.Resource_Request_Type__c).add(oasCMT); 
                        } 
                        else{
                            oasIdToOasMap.get(oasCMT.Resource_Request_Type__c).add(oasCMT); 
                        }                                                    
                    }
                }
        if(oasIdToOasMap.size() > 0 ){            
            for(pse__Resource_Request__c rr : newList) {
                if(oasIdToOasMap.containsKey(rr.Resource_Request_Type__c) ) {
                    for(OWF_Assignment_Setting__mdt oas : oasIdToOasMap.get(rr.Resource_Request_Type__c)) {
                        if(rr.Complexity_Score_Total__c >= oas.Complexity_Score__c && rr.SubGroup__c == oas.Sub_Group__c
                           && (agrIdToAgreementMap.get(rr.Bid_History__c).RFP_Ranking__c == '' ||
                               (oas.RFP_Ranking__c != '*' && agrIdToAgreementMap.get(rr.Bid_History__c).RFP_Ranking__c == oas.RFP_Ranking__c) 
                               || oas.RFP_Ranking__c == '*') ) {
                                   //#3 
                                   if(rr.Resource_Request_Type__c == 'Re-Clinical' && oas.Automation_initial_bid_flag__c) {
                                       clinicalRrToOpptyMap.put(rr.Id,rr);
                                   }
                                   else if(rr.Resource_Request_Type__c == 'Post Award' && rr.SubGroup__c == 'TSL') {
                                       clinicalRrToOpptyMap.put(rr.Id,rr);
                                   }
                                   else if(rr.Resource_Request_Type__c == 'Contract Post Award' && CON_OWF.DSB_POST_SUBGROUP_OF_CONTRACT_POST_AWARD_BID.contains(rr.SubGroup__c) ){
                                       contractPostAwardRRIdToResourceRequestMap.put(rr.Id,rr);
                                   }
                                   else if(rr.Resource_Request_Type__c == 'Bid Defense' && rr.Is_Bid_Defense__c == True)
                                   {
                                       clinicalBidDefenceRrToOpptyMap.put(rr.id,rr);
                                   }
                                   else if(!oas.Disable_availability_flag__c) {
                                       if(oas.Line_of_Business__c!=null){
                                           lineOfBusinessValues=oas.Line_of_Business__c.split(',');
                                           if(!lineOfBusinessValues.contains(rr.Line_of_Business__c)){
                                               skillRatingRRToOpptyMap.put(rr.id,rr);
                                           }
                                       } else {
                                           skillRatingRRToOpptyMap.put(rr.id,rr);
                                       }
                                   }                                       
                               }  
                    }
                }
            }
        }
        //#-----------------------------------------
        if(clinicalBidDefenceRrToOpptyMap.size() > 0){
            
            Set<Id> aggrIdSet = new Set<Id>();
            Map<Id,pse__Resource_Request__c> rrIdToRrMap = new Map<Id,pse__Resource_Request__c>();
            for(pse__Resource_Request__c rr : clinicalBidDefenceRrToOpptyMap.values()){
                if(!aggrIdSet.contains(rr.Bid_History__c))
                {
                    aggrIdSet.add(rr.Bid_History__c);
                }
            }
            SLT_Resource_Request sltrr = new SLT_Resource_Request(false,false);
            SLT_Assignment sltAssignment = new SLT_Assignment(false,false);
            Set<String> rrFieldSet = new Set<String>{'id','Name','SubGroup__c','Bid_History__c','pse__Assignment__c', 'Suggested_FTE__c'};
                Set<String> assignmentFieldSet = new Set<String>{'id','Bid_History__c','pse__Schedule__c','pse__Resource_Request__c','pse__Is_Billable__c',
                    'pse__Bill_Rate__c','RecordTypeId','pse__Project__c','CurrencyIsoCode','Is_Triaged_Automatically__c',
                    'pse__Resource__r.pse__Is_Resource__c','pse__Resource__r.pse__Is_Resource_Active__c',
                    'pse__Resource__r.Sub_Group__c','pse__Resource__r.Available_for_Triage_Flag__c',
                    'pse__Resource__r.pse__Salesforce_User__r.IsActive', 'Estimation_Effort__c', 'Subgroup_Name__c','pse__Resource__r.pse__Work_Calendar__r.Standard_Number_of_Working_Days__c',
                    'pse__Resource__r.pse__Work_Calendar__r.pse__Week_Total_Hours__c','pse__Resource_Request__r.LeadSupportFlag__c'};
                        String getRRCondition = 'and SubGroup__c in (\'TSL\' ,\'Medical-MSL\',\'Biosimilar-COE\',\'CMSVC\',\'ECD-COE\',\'IQB Strategy Lead\',\'CAGT-COE\',\'PRD-COE\') and Is_Bid_Defense__c = false';
            List<pse__Resource_Request__c> rrList = sltrr.getResRequestListFromBidHistory(aggrIdSet,rrFieldSet,getRRCondition);
            Set<Id> sObjectIdset = new Set<Id>();
            for(pse__Resource_Request__c rr : rrList)
            {
                sObjectIdset.add(rr.id);
            }
            List<pse__Assignment__c> assignmentfromRRList = sltAssignment.getAssignmentByResource(sObjectIdset,'pse__Resource_Request__c in :sObjectIdset',assignmentFieldSet);
            
            Map<id,Map<String,List<pse__Resource_Request__c>>> agreementToRRMap = new Map<id,Map<String,List<pse__Resource_Request__c>>>();    
            
            for(pse__Assignment__c ass : assignmentfromRRList)
            {
                if(!rRToAssignmentMap.containsKey(ass.pse__Resource_Request__c))
                {
                    rRToAssignmentMap.put(ass.pse__Resource_Request__c, ass);
                }
            }
            for(pse__Resource_Request__c rr : rrList)
            {
                if(!agreementToRRMap.containsKey(rr.Bid_History__c)){
                    agreementToRRMap.put(rr.Bid_History__c,new Map<String,List<pse__Resource_Request__c>>());
                    agreementToRRMap.get(rr.Bid_History__c).put(rr.SubGroup__c,new List<pse__Resource_Request__c>{rr});
                }
                else{
                    if(agreementToRRMap.get(rr.Bid_History__c).containsKey(rr.SubGroup__c)){
                        if(CON_OWF.RES_REQ_TYPE_TSL == rr.SubGroup__c || CON_OWF.RES_REQ_TYPE_MEDICAL== rr.SubGroup__c ){
                            agreementToRRMap.get(rr.Bid_History__c).get(rr.SubGroup__c).add(rr);
                        }	 
                    }
                    else{
                        agreementToRRMap.get(rr.Bid_History__c).put(rr.SubGroup__c,new List<pse__Resource_Request__c>{rr});
                    }
                }
            }
            pse__Resource_Request__c sameRR;
            pse__Assignment__c newassign;
            pse__Assignment__c assign;
            Integer listSize;
            for(pse__Resource_Request__c rr : clinicalBidDefenceRrToOpptyMap.values()){
            if(agreementToRRMap.containsKey(rr.Bid_History__c) && agreementToRRMap.get(rr.Bid_History__c).containsKey(rr.SubGroup__c)){																		
                listSize = agreementToRRMap.get(rr.Bid_History__c).get(rr.SubGroup__c).size();
                if(agreementToRRMap.containsKey(rr.Bid_History__c) && agreementToRRMap.get(rr.Bid_History__c).containsKey(rr.SubGroup__c) && !agreementToRRMap.get(rr.Bid_History__c).get(rr.SubGroup__c).isEmpty() && rRToAssignmentMap.containsKey(agreementToRRMap.get(rr.Bid_History__c).get(rr.SubGroup__c)[listSize-1].id)){
                    assign = rRToAssignmentMap.get(agreementToRRMap.get(rr.Bid_History__c).get(rr.SubGroup__c)[listSize-1].id);
                    agreementToRRMap.get(rr.Bid_History__c).get(rr.SubGroup__c).remove(listSize-1);
                    if(assign.pse__Resource__r.pse__Is_Resource__c && assign.pse__Resource__r.pse__Is_Resource_Active__c && assign.pse__Resource__r.Sub_Group__c == rr.SubGroup__c && assign.pse__Resource__r.Available_for_Triage_Flag__c  && assign.pse__Resource__r.pse__Salesforce_User__r.IsActive){
                        newassign = assign.clone(false);
                        newassign.pse__Resource_Request__c = rr.id;
                        objSchedule= new pse__Schedule__c();
                        objSchedule.pse__Start_Date__c = (rr.pse__End_Date__c < Date.today() || rr.pse__Start_Date__c > Date.today()) ? rr.pse__Start_Date__c : Date.today();
                        objSchedule.pse__End_Date__c=rr.pse__End_Date__c;
                        objSchedule.pse__Monday_Hours__c=0;
                        objSchedule.pse__Tuesday_Hours__c=0;
                        objSchedule.pse__Wednesday_Hours__c=0;
                        objSchedule.pse__Thursday_Hours__c=0;
                        objSchedule.pse__Friday_Hours__c=0;
                        objSchedule.pse__Saturday_Hours__c=0;
                        objSchedule.pse__Sunday_Hours__c=0;
                        objSchedule.pse__Scheduled_Hours__c=0;
                        rrIdToScheduleMap.put(rr.id,objSchedule);
                        rRTOAssignmtMap.put(rr.id,newassign);
                        if(rr.SubGroup__c == CON_OWF.RES_REQ_TYPE_TSL || rr.SubGroup__c == CON_OWF.RES_REQ_TYPE_MEDICAL){
                        	sameRR = new pse__Resource_Request__c();
                        	sameRR.id = rr.id;
                        	sameRR.LeadSupportFlag__c = assign.pse__Resource_Request__r.LeadSupportFlag__c;
                        	rrIdToRrMap.put(sameRR.id,sameRR);
                        }
                    }
                    else if (!assign.pse__Resource__r.pse__Is_Resource__c || !assign.pse__Resource__r.pse__Is_Resource_Active__c ) {
                        sameRR = new pse__Resource_Request__c();
                        sameRR.id = rr.id;
                        sameRR.Original_Assignee__c = assign.pse__Resource__c;
                        sameRR.Auto_Assignment_Notes__c = 'Auto Assignment could not be created because the original assignee was inactive.';
                        if(rr.SubGroup__c == CON_OWF.RES_REQ_TYPE_TSL || rr.SubGroup__c == CON_OWF.RES_REQ_TYPE_MEDICAL){
                        	sameRR.LeadSupportFlag__c = assign.pse__Resource_Request__r.LeadSupportFlag__c;
                        }
                        rrIdToRrMap.put(sameRR.id,sameRR);
                    }
                    else if(assign.pse__Resource__r.Sub_Group__c != rr.SubGroup__c) {
                        sameRR = new pse__Resource_Request__c();
                        sameRR.id = rr.id;
                        sameRR.Original_Assignee__c = assign.pse__Resource__c;
                        sameRR.Auto_Assignment_Notes__c = 'Auto Assignment could not be created because the sub group of original assignee did not match the Sub Group of Resource Request.';
                        if(rr.SubGroup__c == CON_OWF.RES_REQ_TYPE_TSL || rr.SubGroup__c == CON_OWF.RES_REQ_TYPE_MEDICAL){
                        	sameRR.LeadSupportFlag__c = assign.pse__Resource_Request__r.LeadSupportFlag__c;
                        }
                        rrIdToRrMap.put(sameRR.id,sameRR);
                    } 
                    else if(!assign.pse__Resource__r.Available_for_Triage_Flag__c) {
                        sameRR = new pse__Resource_Request__c();
                        sameRR.id = rr.id;
                        sameRR.Original_Assignee__c = assign.pse__Resource__c;
                        sameRR.Auto_Assignment_Notes__c = 'Auto Assignment could not be created because the original assignee was not available for triage.';
                        if(rr.SubGroup__c == CON_OWF.RES_REQ_TYPE_TSL || rr.SubGroup__c == CON_OWF.RES_REQ_TYPE_MEDICAL){
                        	sameRR.LeadSupportFlag__c = assign.pse__Resource_Request__r.LeadSupportFlag__c;
                        }
                        rrIdToRrMap.put(sameRR.id,sameRR);
                    }
                    else if(!assign.pse__Resource__r.pse__Salesforce_User__r.IsActive) {
                        sameRR = new pse__Resource_Request__c();
                        sameRR.id = rr.id;
                        sameRR.Original_Assignee__c = assign.pse__Resource__c;
                        sameRR.Auto_Assignment_Notes__c = 'Auto Assignment could not be created because the related salesforce user of resource is inactive.';
                        if(rr.SubGroup__c == CON_OWF.RES_REQ_TYPE_TSL || rr.SubGroup__c == CON_OWF.RES_REQ_TYPE_MEDICAL){
                        	sameRR.LeadSupportFlag__c = assign.pse__Resource_Request__r.LeadSupportFlag__c;
                        }
                        rrIdToRrMap.put(sameRR.id,sameRR);
                    }
                }}
			}
            /*if(rrIdToScheduleMap.size() > 0)
            {
                insert rrIdToScheduleMap.values();
            }
            for(Id i : rrIdToScheduleMap.keySet())
            {
                
                rRTOAssignmtMap.get(i).pse__Schedule__c = rrIdToScheduleMap.get(i).id;
            }
            if(rRTOAssignmtMap.size() > 0)
            {
                insert rRTOAssignmtMap.values();
            }*/
            if(rrIdToRrMap.size() > 0) {
                
                UTL_ExecutionControl.stopTriggerExecution_OWF = true;
                update rrIdToRrMap.values();
                UTL_ExecutionControl.stopTriggerExecution_OWF = false;
            }
            
        }
        //#3 --------------------------------------
        if(clinicalRrToOpptyMap.size() > 0){
            Set<Id> oppIdSet = new Set<Id>();
            for(pse__Resource_Request__c rr : clinicalRrToOpptyMap.values()) {
                oppIdSet.add(rr.pse__Opportunity__c);
            }
            Set<String> oppFieldSet = new Set<String>{'Id','BD_Lead_Sub_Region__c'};
                Set<String> agrFieldSet = new Set<String>{'Id','Bid_Number__c','RecordType'};
                    Set<Id> agrIdSet = new Set<Id>();    
            Map<Id,pse__Resource_Request__c> rrIdToRRMap = new Map<Id,pse__Resource_Request__c>();
            //Retrieving Clinical Agreements with Bid Number = 1.
            String agrCondtion = 'Bid_Number__c = 1 and recordTypeId = \''+CON_OWF.OWF_CLINICAL_BID_BID_HISTORY_RECORD_TYPE_ID+'\'';
            
            oppIdToOppMap = new SLT_Opportunity(false,false).selectByIdWithBidHistoryCondtion(oppIdSet,oppFieldSet,agrFieldSet,agrCondtion);
            
            if(oppIdToOppMap.values().size() > 0) {                    
                for(Opportunity opp : oppIdToOppMap.values()) {
                    for(Bid_History__c agr : opp.Bid_Histories_Opportunity__r) {
                        agrIdSet.add(agr.id); 
                    }
                }
                if(agrIdSet.size() > 0) {
                    String assignCondition = 'and Resource_Request_Type__c In (\'Clinical\',\'Clinical - Ballpark\')';
                    Set<String> assignFieldSet = new Set<String>{'Id','pse__Resource__c','pse__Resource__r.pse__Salesforce_User__r.Name','pse__Resource__r.pse__Salesforce_User__r.IsActive','pse__Schedule__c','pse__Resource_Request__r.SubGroup__c','pse__Resource_Request__r.pse__Opportunity__c','pse__Resource_Request__c',
                        'pse__Resource__r.pse__Is_Resource__c','pse__Resource__r.pse__Is_Resource_Active__c',
                        'pse__Resource__r.Sub_Group__c','pse__Resource__r.Available_For_Triage_Flag__c','pse__Resource_Request__r.Preferred_Resource__c',
                        'pse__Resource_Request__r.Preferred_Resource__r.pse__Is_Resource__c','pse__Resource_Request__r.Preferred_Resource__r.pse__Is_Resource_Active__c',
                        'pse__Resource_Request__r.Preferred_Resource__r.Sub_Group__c','pse__Resource_Request__r.Preferred_Resource__r.Available_for_Triage_Flag__c', 'Estimation_Effort__c', 'Subgroup_Name__c',
                        'pse__Resource__r.pse__Work_Calendar__r.Standard_Number_of_Working_Days__c', 'pse__Start_Date__c', 'pse__End_Date__c', 'pse__Resource__r.pse__Work_Calendar__r.pse__Week_Total_Hours__c',
                        'pse__Resource_Request__r.Resource_Request_Type__c', 'pse__Resource_Request__r.Is_Created_Automatically__c', 'pse__Resource_Request__r.LeadSupportFlag__c','pse__Resource_Request__r.Sub_Group__c',
                        'Subgroup_Name__c','pse__Resource_Request__r.Is_Bid_Defense__c'};
                            
                            for(pse__Assignment__c assign : new SLT_Assignment(false,false).getAssignmentByBhrAndCondition(agrIdSet,assignCondition,assignFieldSet) ) {
                                if(!oppIdToAssignMap.containsKey(assign.pse__Resource_Request__r.pse__Opportunity__c)) {
                                    oppIdToAssignMap.put(assign.pse__Resource_Request__r.pse__Opportunity__c,new List<pse__Assignment__c>());
                                    oppIdToAssignMap.get(assign.pse__Resource_Request__r.pse__Opportunity__c).add(assign);
                                }
                                else {
                                    oppIdToAssignMap.get(assign.pse__Resource_Request__r.pse__Opportunity__c).add(assign);
                                }
                            }
                    
                    List<pse__Assignment__c> newAssignment = new List<pse__Assignment__c>();
                    for(Id rrId : clinicalRrToOpptyMap.keySet()) {
                        if (clinicalRrToOpptyMap.get(rrId).Resource_Request_Type__c == 'Post Award'){
                          if(oppIdToAssignMap.containsKey(clinicalRrToOpptyMap.get(rrId).pse__Opportunity__c)){
                            for(pse__Assignment__c assign : oppIdToAssignMap.get(clinicalRrToOpptyMap.get(rrId).pse__Opportunity__c)) {
                                if( assign.pse__Resource_Request__r.Resource_Request_Type__c == 'Clinical'){
                                    If(assign.pse__Resource_Request__r.LeadSupportFlag__c == 'Lead' || assign.pse__Resource_Request__r.Is_Created_Automatically__c == True){
                                        if(assign.Subgroup_Name__c == 'TSL' && assign.pse__Resource_Request__r.Is_Bid_Defense__c == False){
                                            newAssignment.add(assign);
                                            oppIdToAssignMap.clear();
                                            oppIdToAssignMap.put(assign.pse__Resource_Request__r.pse__Opportunity__c, newAssignment);
                                        }
                                    }
                                }
                            }
                          }
                        }
                    }
                    //Creating pse__Schedule__c records  
                    pse__Resource_Request__c sameRR;
                    Set<Id> assignmentIdSet = new Set<Id>();
                    Set<Id> rrIdSet = new Set<Id>();
                    
                    
                    for(Id rrId : clinicalRrToOpptyMap.keySet()) {
                        if(!oppIdToAssignMap.isEmpty() && oppIdToAssignMap.containsKey(clinicalRrToOpptyMap.get(rrId).pse__Opportunity__c)) {
                            for(pse__Assignment__c assign : oppIdToAssignMap.get(clinicalRrToOpptyMap.get(rrId).pse__Opportunity__c)) {
                                if(assign.pse__Resource_Request__r.SubGroup__c == clinicalRrToOpptyMap.get(rrId).SubGroup__c
                                   && (assign.pse__Resource__c == clinicalRrToOpptyMap.get(rrId).Original_Assignee__c )) { //|| clinicalRrToOpptyMap.get(rrId).SubGroup__c=='Strategic Pricing Lead'
                                       //Resource's Sub Group should match sub group of RR
                                       //Resource should be available for triage.
                                       if(!assignmentIdSet.contains(assign.id) && assign.pse__Resource_Request__r.Preferred_Resource__c != null
                                          && assign.pse__Resource_Request__r.Preferred_Resource__r.pse__Is_Resource__c && assign.pse__Resource_Request__r.Preferred_Resource__r.pse__Is_Resource_Active__c 
                                          && assign.pse__Resource_Request__r.Preferred_Resource__r.Sub_Group__c == clinicalRrToOpptyMap.get(rrId).SubGroup__c                                        
                                          && assign.pse__Resource_Request__r.Preferred_Resource__r.Available_for_Triage_Flag__c && !rrIdToAssignmentMap.containsKey(rrId) ) {
                                              
                                              rrIdToAssignmentMap.put(rrId,assign);
                                              assignmentIdSet.add(assign.id);
                                              rrIdSet.add(rrId);
                                              preferredResourceAssignmentIdSet.add(assign.id);
                                              rrIdToContactIdMap.put(rrId,assign.pse__Resource_Request__r.Preferred_Resource__c);
                                              
                                          } 
                                       else if( !assignmentIdSet.contains(assign.id) && assign.pse__Resource__r.pse__Is_Resource__c && assign.pse__Resource__r.pse__Is_Resource_Active__c
                                               //IQVIAPSA-2325 add (&& assign.pse__Resource__r.pse__Salesforce_User__r.IsActive )   Hot Fix story start
                                               && assign.pse__Resource__r.Sub_Group__c == clinicalRrToOpptyMap.get(rrId).SubGroup__c  && assign.pse__Resource__r.pse__Salesforce_User__r.IsActive                                      
                                               //IQVIAPSA-2325 add (&& assign.pse__Resource__r.pse__Salesforce_User__r.IsActive )   Hot Fix story end 
                                               && assign.pse__Resource__r.Available_for_Triage_Flag__c && !rrIdToAssignmentMap.containsKey(rrId)) {
                                                   rrIdToAssignmentMap.put(rrId,assign);
                                                   assignmentIdSet.add(assign.id);
                                                   rrIdSet.add(rrId);
                                                   rrIdToContactIdMap.put(rrId,assign.pse__Resource__c);
                                               }
                                       else if (!rrIdSet.contains(rrId) && (!assign.pse__Resource__r.pse__Is_Resource__c || !assign.pse__Resource__r.pse__Is_Resource_Active__c) ) {
                                           sameRR = new pse__Resource_Request__c();
                                           sameRR.id = rrId;
                                           sameRR.Original_Assignee__c = assign.pse__Resource__c;
                                           sameRR.Auto_Assignment_Notes__c = 'Auto Assignment could not be created because the original assignee was inactive.';
                                           rrIdToRRMap.put(sameRR.id,sameRR);
                                           rrIdSet.add(rrId);
                                       }
                                       else if(!rrIdSet.contains(rrId) && assign.pse__Resource__r.Sub_Group__c != clinicalRrToOpptyMap.get(rrId).SubGroup__c) {
                                           sameRR = new pse__Resource_Request__c();
                                           sameRR.id = rrId;
                                           sameRR.Original_Assignee__c = assign.pse__Resource__c;
                                           sameRR.Auto_Assignment_Notes__c = 'Auto Assignment could not be created because the sub group of original assignee did not match the Sub Group of Resource Request.';
                                           rrIdToRRMap.put(sameRR.id,sameRR);
                                           rrIdSet.add(rrId);
                                       } 
                                       else if(!rrIdSet.contains(rrId) && !assign.pse__Resource__r.Available_for_Triage_Flag__c) {
                                           sameRR = new pse__Resource_Request__c();
                                           sameRR.id = rrId;
                                           sameRR.Original_Assignee__c = assign.pse__Resource__c;
                                           sameRR.Auto_Assignment_Notes__c = 'Auto Assignment could not be created because the original assignee was not available for triage.';
                                           rrIdToRRMap.put(sameRR.id,sameRR);
                                           rrIdSet.add(rrId);
                                       }
                                       else if(!rrIdSet.contains(rrId) && !assign.pse__Resource__r.pse__Salesforce_User__r.IsActive) {
                                           
                                           sameRR = new pse__Resource_Request__c();
                                           sameRR.id = rrId;
                                           sameRR.Original_Assignee__c = assign.pse__Resource__c;
                                           sameRR.Auto_Assignment_Notes__c = 'Auto Assignment could not be created because the related salesforce user of resource is inactive.';
                                           rrIdToRRMap.put(sameRR.id,sameRR);
                                           rrIdSet.add(rrId);
                                       }
                                       
                                   }                              
                            }
                        } 
                    }
                    
                    //Process Days Off for Rebid
                    Map<Id,boolean> rrIdToDaysOffStatusMap = UTL_OWF.calculateDaysOffForRebid(rrIdToContactIdMap);
                    pse__Resource_Request__c sameRRDaysOff;
                    for(Id rrIdToProcess: rrIdToDaysOffStatusMap.keySet())
                    {
                        if(!rrIdToDaysOffStatusMap.get(rrIdToProcess))
                        {
                            if(preferredResourceAssignmentIdSet.contains(rrIdToAssignmentMap.get(rrIdToProcess).Id))
                            {
                                preferredResourceAssignmentIdSet.remove(rrIdToAssignmentMap.get(rrIdToProcess).Id);  
                            } 
                            
                            sameRRDaysOff = new pse__Resource_Request__c();
                            sameRRDaysOff.id = rrIdToProcess;
                            sameRRDaysOff.Original_Assignee__c = rrIdToAssignmentMap.get(rrIdToProcess).pse__Resource__c;
                            sameRRDaysOff.Auto_Assignment_Notes__c = 'Auto Assignment could not be created because the Related Resource has Non working Time more than 20%  for this RR';
                            
                            
                            assignmentIdSet.remove(rrIdToAssignmentMap.get(rrIdToProcess).Id);
                            rrIdToRRMap.put(sameRRDaysOff.id,sameRRDaysOff);
                            rrIdSet.add(rrIdToProcess);
                            rrIdToAssignmentMap.remove(rrIdToProcess);
                            
                        }
                    }
                    
                    
                    
                    
                    
                    for(Id rrId : clinicalRrToOpptyMap.keySet()) {
                        if( !rrIdToAssignmentMap.isEmpty() && rrIdToAssignmentMap.containsKey(rrId) ) {
                            objSchedule= new pse__Schedule__c();
                            objSchedule.pse__Start_Date__c = (clinicalRrToOpptyMap.get(rrId).pse__End_Date__c < Date.today() || clinicalRrToOpptyMap.get(rrId).pse__Start_Date__c > Date.today()) ? clinicalRrToOpptyMap.get(rrId).pse__Start_Date__c : Date.today();
                            objSchedule.pse__End_Date__c=clinicalRrToOpptyMap.get(rrId).pse__End_Date__c;
                            objSchedule.pse__Monday_Hours__c=0;
                            objSchedule.pse__Tuesday_Hours__c=0;
                            objSchedule.pse__Wednesday_Hours__c=0;
                            objSchedule.pse__Thursday_Hours__c=0;
                            objSchedule.pse__Friday_Hours__c=0;
                            objSchedule.pse__Saturday_Hours__c=0;
                            objSchedule.pse__Sunday_Hours__c=0;
                            objSchedule.pse__Scheduled_Hours__c=0;
                            rrIdToScheduleMap.put(rrId,objSchedule);  
                        }
                    } 
                }
            }
            if(rrIdToRRMap.size() > 0) {
                UTL_ExecutionControl.stopTriggerExecution_OWF = true;
                update rrIdToRRMap.values();
                UTL_ExecutionControl.stopTriggerExecution_OWF = false;  
            }
        }
        if(contractPostAwardRRIdToResourceRequestMap.size()>0){
            Set<Id> oppIdSet = new Set<Id>();
            Map<Id,pse__Resource_Request__c> rrIdToRRMap = new Map<Id,pse__Resource_Request__c>();
            for(pse__Resource_Request__c rr : contractPostAwardRRIdToResourceRequestMap.values()) {
                oppIdSet.add(rr.pse__Opportunity__c);
                }
            if(oppIdSet.size() > 0) {
                String assignCondition = 'and pse__Resource_Request__r.SubGroup__c like \'DSB%\' and Resource_Request_Type__c In (\'Clinical\',\'Clinical - Ballpark\',\'Re-Clinical\') and Bid_History__r.Is_Study_Awarded__c = \'' + CON_OWF.IS_STUDY_AWARDED_YES +'\' and Bid_History__r.recordTypeId = \''+CON_OWF.OWF_CLINICAL_BID_BID_HISTORY_RECORD_TYPE_ID+'\'';
                Set<String> assignFieldSet = new Set<String>{'Id','pse__Resource__c','pse__Resource__r.pse__Salesforce_User__r.Name','pse__Resource__r.pse__Salesforce_User__r.IsActive','pse__Schedule__c',
                    'pse__Resource_Request__r.SubGroup__c','pse__Resource_Request__r.pse__Opportunity__c','pse__Resource_Request__c',
                    'pse__Resource__r.pse__Is_Resource__c','pse__Resource__r.pse__Is_Resource_Active__c',
                    'pse__Resource__r.Sub_Group__c','pse__Resource__r.Available_For_Triage_Flag__c','pse__Resource_Request__r.Preferred_Resource__c',
                    'pse__Resource_Request__r.Preferred_Resource__r.pse__Is_Resource__c','pse__Resource_Request__r.Preferred_Resource__r.pse__Is_Resource_Active__c',
                    'pse__Resource_Request__r.Preferred_Resource__r.Sub_Group__c','pse__Resource_Request__r.Preferred_Resource__r.Available_for_Triage_Flag__c', 'Estimation_Effort__c', 'Subgroup_Name__c',
                    'pse__Resource__r.pse__Work_Calendar__r.Standard_Number_of_Working_Days__c', 'pse__Start_Date__c', 'pse__End_Date__c', 'pse__Resource__r.pse__Work_Calendar__r.pse__Week_Total_Hours__c',
                    'pse__Resource_Request__r.Resource_Request_Type__c', 'pse__Resource_Request__r.Is_Created_Automatically__c', 'pse__Resource_Request__r.LeadSupportFlag__c',
                    'Subgroup_Name__c','pse__Resource_Request__r.Is_Bid_Defense__c'};
                for(pse__Assignment__c assign : new SLT_Assignment(false,false).getAssignmentByBhrAndConditionOrderByRRCreatedDate(oppIdSet,assignCondition,assignFieldSet)) {
                    if(!oppIdtoSubgroupNameToAssignmentMap.containsKey(assign.pse__Resource_Request__r.pse__Opportunity__c)) {
                        oppIdtoSubgroupNameToAssignmentMap.put(assign.pse__Resource_Request__r.pse__Opportunity__c,new Map<String,List<pse__Assignment__c>>());
                        oppIdtoSubgroupNameToAssignmentMap.get(assign.pse__Resource_Request__r.pse__Opportunity__c).put(assign.pse__Resource_Request__r.SubGroup__c, new List<pse__Assignment__c>{assign});
                    }
                    else{
                        if(!oppIdtoSubgroupNameToAssignmentMap.get(assign.pse__Resource_Request__r.pse__Opportunity__c).containsKey(assign.pse__Resource_Request__r.SubGroup__c)){
                            oppIdtoSubgroupNameToAssignmentMap.get(assign.pse__Resource_Request__r.pse__Opportunity__c).put(assign.pse__Resource_Request__r.SubGroup__c, new List<pse__Assignment__c>{assign});                        
                        }
                        else{
                            oppIdtoSubgroupNameToAssignmentMap.get(assign.pse__Resource_Request__r.pse__Opportunity__c).get(assign.pse__Resource_Request__r.SubGroup__c).add(assign);                        
                        }
                    }
                }
                pse__Resource_Request__c sameRR;
                Set<Id> assignmentIdSet = new Set<Id>();
                Set<Id> rrIdSet = new Set<Id>();
                    
                for(Id rrId : contractPostAwardRRIdToResourceRequestMap.keySet()) {
                    if(!oppIdtoSubgroupNameToAssignmentMap.isEmpty() && oppIdtoSubgroupNameToAssignmentMap.containsKey(contractPostAwardRRIdToResourceRequestMap.get(rrId).pse__Opportunity__c)) {
                        if(oppIdtoSubgroupNameToAssignmentMap.get(contractPostAwardRRIdToResourceRequestMap.get(rrId).pse__Opportunity__c).containsKey(contractPostAwardRRIdToResourceRequestMap.get(rrId).SubGroup__c.substringBefore(' Post'))){
                            for(pse__Assignment__c assign : oppIdtoSubgroupNameToAssignmentMap.get(contractPostAwardRRIdToResourceRequestMap.get(rrId).pse__Opportunity__c).get(contractPostAwardRRIdToResourceRequestMap.get(rrId).SubGroup__c.substringBefore(' Post'))) {//|| clinicalRrToOpptyMap.get(rrId).SubGroup__c=='Strategic Pricing Lead'
                                if(!assignmentIdSet.contains(assign.id) && assign.pse__Resource__r.pse__Is_Resource__c && assign.pse__Resource__r.pse__Is_Resource_Active__c
                                    && assign.pse__Resource__r.pse__Salesforce_User__r.IsActive
                                    && assign.pse__Resource__r.Available_for_Triage_Flag__c && !rrIdToAssignmentMap.containsKey(rrId)) {
                                        rrIdToAssignmentMap.put(rrId,assign);
                                        assignmentIdSet.add(assign.id);
                                        rrIdSet.add(rrId);
                                        rrIdToContactIdMap.put(rrId,assign.pse__Resource__c);
                                }
                                else if(!rrIdSet.contains(rrId) && (!assign.pse__Resource__r.pse__Is_Resource__c || !assign.pse__Resource__r.pse__Is_Resource_Active__c) ){
                                    sameRR = new pse__Resource_Request__c();
                                    sameRR.id = rrId;
                                    sameRR.Original_Assignee__c = assign.pse__Resource__c;
                                    sameRR.Auto_Assignment_Notes__c = 'Auto Assignment could not be created because the original assignee was inactive.';
                                    rrIdToRRMap.put(sameRR.id,sameRR);
                                    rrIdSet.add(rrId);
                                }
                                else if(!rrIdSet.contains(rrId) && !assign.pse__Resource__r.Available_for_Triage_Flag__c) {
                                    sameRR = new pse__Resource_Request__c();
                                    sameRR.id = rrId;
                                    sameRR.Original_Assignee__c = assign.pse__Resource__c;
                                    sameRR.Auto_Assignment_Notes__c = 'Auto Assignment could not be created because the original assignee was not available for triage.';
                                    rrIdToRRMap.put(sameRR.id,sameRR);
                                    rrIdSet.add(rrId);
                                }
                                else if(!rrIdSet.contains(rrId) && !assign.pse__Resource__r.pse__Salesforce_User__r.IsActive) {
                                    sameRR = new pse__Resource_Request__c();
                                    sameRR.id = rrId;
                                    sameRR.Original_Assignee__c = assign.pse__Resource__c;
                                    sameRR.Auto_Assignment_Notes__c = 'Auto Assignment could not be created because the related salesforce user of resource is inactive.';
                                    rrIdToRRMap.put(sameRR.id,sameRR);
                                    rrIdSet.add(rrId);
                                }
                            }                              
                        }
                    } 
                }
                Map<Id,boolean> rrIdToDaysOffStatusMap = UTL_OWF.calculateDaysOffForRebid(rrIdToContactIdMap);
                pse__Resource_Request__c sameRRDaysOff;
                for(Id rrIdToProcess: rrIdToDaysOffStatusMap.keySet()){
                    if(!rrIdToDaysOffStatusMap.get(rrIdToProcess)){
                        if(preferredResourceAssignmentIdSet.contains(rrIdToAssignmentMap.get(rrIdToProcess).Id)){
                            preferredResourceAssignmentIdSet.remove(rrIdToAssignmentMap.get(rrIdToProcess).Id);  
                        } 
                        sameRRDaysOff = new pse__Resource_Request__c();
                        sameRRDaysOff.id = rrIdToProcess;
                        sameRRDaysOff.Original_Assignee__c = rrIdToAssignmentMap.get(rrIdToProcess).pse__Resource__c;
                        sameRRDaysOff.Auto_Assignment_Notes__c = 'Auto Assignment could not be created because the Related Resource has Non working Time more than 20%  for this RR';
                        assignmentIdSet.remove(rrIdToAssignmentMap.get(rrIdToProcess).Id);
                        rrIdToRRMap.put(sameRRDaysOff.id, sameRRDaysOff);
                        rrIdSet.add(rrIdToProcess);
                        rrIdToAssignmentMap.remove(rrIdToProcess);
                    }
                }
                    
                for(Id rrId : contractPostAwardRRIdToResourceRequestMap.keySet()){
                    if(!rrIdToAssignmentMap.isEmpty() && rrIdToAssignmentMap.containsKey(rrId)){
                        rrIdToScheduleMap.put(rrId,UTL_OWF.createScheduleFromResourceRequest(contractPostAwardRRIdToResourceRequestMap.get(rrId)));  
                    } 
                }
            }
            if(rrIdToRRMap.size() > 0) {
                UTL_ExecutionControl.stopTriggerExecution_OWF = true;
                update rrIdToRRMap.values();
                UTL_ExecutionControl.stopTriggerExecution_OWF = false;  
            }  
        }
        
        //#5-----------------------------------------------------------
        if(skillRatingRRToOpptyMap.size() > 0) {
            Contact cont= new Contact();
            for(Id rrId: skillRatingRRToOpptyMap.keySet()){
                if(subgroupToRRMap != null && subgroupToRRMap.containsKey(skillRatingRRToOpptyMap.get(rrId).SubGroup__c)){
                    if(contactIdToContactMap != null && contactIdToContactMap.size() > 0 && subgroupToRRMap.get(skillRatingRRToOpptyMap.get(rrId).SubGroup__c)!= null){                  
                        cont= contactIdToContactMap.get(subgroupToRRMap.get(skillRatingRRToOpptyMap.get(rrId).SubGroup__c).pse__Assignment__r.pse__Resource__c);
                    	if(cont!= null && cont.Available_FTE__c >= 0.20 && cont.Available_for_Triage_Flag__c && cont.pse__Is_Resource__c && cont.pse__Is_Resource_Active__c && cont.pse__Salesforce_User__r.IsActive && cont.Sub_Group__c == skillRatingRRToOpptyMap.get(rrId).SubGroup__c && !rrIdToContactsMap.containsKey(rrId) ){
                            if(!rrIdToResourceMap.containsKey(rrId)){
                                rrIdToResourceMap.put(rrId,new Set<Id>{cont.Id});
                            }
                            else{
                                rrIdToResourceMap.get(rrId).add(cont.Id);
                            }
                        }
                    }
                }
            }
            Map<Id,Set<Id>> rrIdToAssociatedContactsMap = new Map<Id,Set<Id>>();
            if(rrIdToResourceMap.size()>0){
                rrIdToAssociatedContactsMap = UTL_OWF.calculateDaysOffForClinicalBidRR(rrIdToResourceMap);
                for(Id rrId : rrIdToAssociatedContactsMap.keySet()){
                    rrIdToContactsMap.put(rrId,rrIdToAssociatedContactsMap.get(rrId));
                }
            }

            Set<String> rsrFieldSet = new Set<String>{'Id','pse__Resource_Request__c','pse__Skill_Certification__c',
                'pse__Resource_Request__r.pse__Opportunity__r.BD_Lead_Sub_Region__c',
                'pse__Resource_Request__r.Potential_Regions__c',
                'pse__Resource_Request__r.pse__Opportunity__r.Potential_Regions__c','pse__Resource_Request__r.pse__Opportunity__r.FSP__c',
                'pse__Resource_Request__r.SubGroup__c','pse__Resource_Request__r.Bid_History__r.Requested_Services__c','pse__Resource_Request__r.pse__Opportunity__r.Account.Id'}; 
                    Set<Id> skillIdSet = new Set<Id>();
            Map<Id,String> rrIdToPrMap = new Map<Id,String>();
            List<pse__Resource_Skill_Request__c> rsrList = new SLT_Resource_Skill_Request(false,false).getResourceSkillRequestByRrID(skillRatingRRToOpptyMap.keySet(),
                                                                                                                                     rsrFieldSet).values();

            for(pse__Resource_Skill_Request__c rsr : rsrList) {
                rrIdToPrMap.put(rsr.pse__Resource_Request__c,rsr.pse__Resource_Request__r.pse__Opportunity__r.Potential_Regions__c);
            }
            Map<String,DAOH_OWF_Resource_Skill_Request.ResourceCandidateMatchScore> combinedKeyToMatchScoreMap = new Map<String,DAOH_OWF_Resource_Skill_Request.ResourceCandidateMatchScore>();
            List<DAOH_OWF_Resource_Skill_Request.ResourceCandidateMatchScore> resMatchScoreWrapperList =
                new List<DAOH_OWF_Resource_Skill_Request.ResourceCandidateMatchScore>();
            List<DAOH_OWF_Resource_Skill_Request.ResourceCandidateMatchScore> 
                resourceCandidateMatchScoreList = DAOH_OWF_Resource_Skill_Request.createResourceCandidateMatchScore(rsrList);
            //system.debug('resourceCandidateMatchScoreList→ ' + resourceCandidateMatchScoreList.size());
            //filterMatchScoreForSPLResources(resourceCandidateMatchScoreList);
            
            //-------------------------------------
            resMatchScoreWrapperList = UTL_OWF.calculateNWTimePercentage(resourceCandidateMatchScoreList);
            resMatchScoreWrapperList.sort();
            String combinedkey;					  
            for(DAOH_OWF_Resource_Skill_Request.ResourceCandidateMatchScore resWithMaxMatchScore : resMatchScoreWrapperList) {
                combinedkey = resWithMaxMatchScore.resourceRequestId + '-' + resWithMaxMatchScore.contactId;
                combinedKeyToMatchScoreMap.put(combinedkey,resWithMaxMatchScore);
                /*system.debug('Id→'+resWithMaxMatchScore.contactId);
system.debug('Sub→'+resWithMaxMatchScore.resourceSubGroup);
system.debug('FTE→'+resWithMaxMatchScore.availableFTECount);
system.debug('Match→'+resWithMaxMatchScore.matchScore);
system.debug('Name→'+resWithMaxMatchScore.resourceName);*/
            }
            Set<String> skillFieldSet = new Set<String>{'Id','pse__Type__c','name'};
                Map<Id, pse__Skill__c> idToSkillMap = new Map<Id, pse__Skill__c>();
            idToSkillMap = new SLT_Skill(false,false).getAllSkillRecords(skillFieldSet);
            Set<Id> contactIdSet = new Set<Id>();
            Map<Id,Id> contactToBackupResourceIdMap = new Map<Id,Id>();
            Set<String> contactFieldSet = new Set<String>{'Id','Backup_OWF_User__c', 'Available_FTE__c', 'Pending_FTE__c'};
                
                //Get map of BD Lead Sub Region to Potential Region
                Set<String> potentialRegToBDLeadMappingFieldSet = new Set<String>{'Id','Potential_Region__c','BD_Lead_Sub_Region__c'};
                    Map<String,String> bdLeadToPRMap = new Map<String,String>();
            for(Potential_Region_To_BD_Lead_Mapping__mdt mapping : 
                new SLT_Potential_Region_To_BD_Lead_Mapping(false,false).getPotentialRegionToBDLeadMappings(potentialRegToBDLeadMappingFieldSet)) {
                    
                    bdLeadToPRMap.put(mapping.BD_Lead_Sub_Region__c,mapping.Potential_Region__c);
                }
            
            //Get set of Backup resources.
            for(DAOH_OWF_Resource_Skill_Request.ResourceCandidateMatchScore rcm : resMatchScoreWrapperList ) {
                contactIdSet.add(rcm.contactId);
            }
            if (contactIdSet.size() > 0 || CTS_Lead_AutoAssignResourceOptions.size() > 0) {
                Set<Id> contactsToQuerySet = new Set<Id>();
                contactsToQuerySet.addAll(contactIdSet);
                contactsToQuerySet.addAll(CTS_Lead_AutoAssignResourceOptions);
                for(Contact con : new SLT_Contact().selectByContactIdList(contactsToQuerySet, contactFieldSet)) {
                    if(contactIdSet.contains(con.Id) && con.Backup_OWF_User__c != null) {
                        contactToBackupResourceIdMap.put(con.id,con.Backup_OWF_User__c);
                    }
                    if (CTS_Lead_AutoAssignResourceOptions.contains(con.Id)) {
                        CTS_Lead_AutoAssignResources.put(con.Id, con);
                    }
                }
            }           
            Boolean hasPotentialRegionSkill;
            String skillName;
            //List<String> fspResourceList;
            for(DAOH_OWF_Resource_Skill_Request.ResourceCandidateMatchScore rcm : resMatchScoreWrapperList ) {
                //Check if match score of resource is greater than related threshold
                //system.debug('rcm.hasMatchingPR→' + rcm.hasMatchingPR);
                //system.debug('rcm.matchScore→' + rcm.matchScore);
                //system.debug('rcm.Threshold→' + rcm.assignmentSettingRecord.Matching_Point_Threshold__c);
                if(rcm.hasMatchingPR && rcm.matchScore > rcm.assignmentSettingRecord.Matching_Point_Threshold__c) {
                    hasPotentialRegionSkill = false;
                    skillName = Null;
                    //Assign resource in case Potential Region on RR is Global
                    if(rcm.skillIdSet != null && rrIdToPrMap.get(rcm.resourceRequestId) == 'Global') {
                        for(Id skillId : rcm.skillIdSet ) {
                            if(idToSkillMap.get(skillId).pse__Type__c == 'User Regional Geographic Working Scope') {
                                hasPotentialRegionSkill = true;
                                skillName = idToSkillMap.get(skillId).name;
                            }
                        }
                    }
                    //IQVIAPSA-4743
                    /*if(rcm.resReqObject.SubGroup__c == 'Strategic Pricing Lead' && rcm.resReqObject.pse__Opportunity__r.FSP__c == 'Yes'
                       && resourceToSubGroupMap.get('Strategic Pricing Lead').Auto_Assign_Resource__c!='')
                    {
                        fspResourceList = resourceToSubGroupMap.get('Strategic Pricing Lead').Auto_Assign_Resource__c.split(';');
                        if(fspResourceList.contains(rcm.contactId))
                        {
                            if((rcm.resReqObject.Bid_History__r.Requested_Services__c.contains('Clinical Monitoring') 
                                || ((rcm.resReqObject.Bid_History__r.Requested_Services__c.contains('Biostatistical')
                                     &&rcm.resReqObject.Bid_History__r.Requested_Services__c.contains('Pharmacovigilance LifeCycle Safety')
                                     &&rcm.resReqObject.Bid_History__r.Requested_Services__c.contains('Global Regulatory Affairs')
                                     &&rcm.resReqObject.Bid_History__r.Requested_Services__c.contains('Medical Writing'))
                                    || rcm.resReqObject.Bid_History__r.Requested_Services__c.contains('Data Management')))
                               &&rcm.contactId == Id.valueOf(fspResourceList[0]))
                            {
                                if(!rrIdToContactsMap.containsKey(rcm.resourceRequestId)) {
                                    rrIdToContactsMap.put(rcm.resourceRequestId,new Set<Id>());
                                    rrIdToContactsMap.get(rcm.resourceRequestId).add(rcm.contactId); 
                                }
                            }
                        }
                    }
                    else*/ if(hasPotentialRegionSkill 
          && (!bdLeadToPRMap.isEmpty() 
              && bdLeadToPRMap.containsKey(skillRatingRRToOpptyMap.get(rcm.resourceRequestId).BD_Lead_Sub_Region__c))
          && skillName == bdLeadToPRMap.get(skillRatingRRToOpptyMap.get(rcm.resourceRequestId).BD_Lead_Sub_Region__c)
          && rcm.availableFTE && rcm.nwtPercentage < 20 && rcm.resourceSubGroup != CON_OWF.RES_REQ_TYPE_TSL && rcm.resourceSubGroup != CON_OWF.RES_REQ_TYPE_IG_LEAD) {
              if(!rrIdToContactsMap.containsKey(rcm.resourceRequestId)) {
                  rrIdToContactsMap.put(rcm.resourceRequestId,new Set<Id>());
                  rrIdToContactsMap.get(rcm.resourceRequestId).add(rcm.contactId);
              }                        
          }
                    //Assign back up resource if current resource is not eligible
                    else if((!rcm.availableFTE || rcm.nwtPercentage >= 20) &&                          
                        (contactToBackupResourceIdMap.containskey(rcm.contactId) && 
                           combinedKeyToMatchScoreMap.containsKey(rcm.resourceRequestId+'-'+contactToBackupResourceIdMap.get(rcm.contactId))
                           && (combinedKeyToMatchScoreMap.get(rcm.resourceRequestId+'-'+contactToBackupResourceIdMap.get(rcm.contactId)).availableFTE || rcm.resourceSubGroup == CON_OWF.RES_REQ_TYPE_IG_LEAD)
                           && combinedKeyToMatchScoreMap.get(rcm.resourceRequestId+'-'+contactToBackupResourceIdMap.get(rcm.contactId)).nwtPercentage < 20
                           && !combinedKeyToMatchScoreMap.get(rcm.resourceRequestId+'-'+contactToBackupResourceIdMap.get(rcm.contactId)).assignmentSettingRecord.Disable_availability_flag__c
                           && combinedKeyToMatchScoreMap.get(rcm.resourceRequestId+'-'+contactToBackupResourceIdMap.get(rcm.contactId)).assignmentSettingRecord.Automation_backup_flag__c
                           && ((rcm.hasMatchingTherapyAreaCertificate && rcm.hasMatchingLineOfBusinessCertificate
                                && rcm.resourceSubGroup == CON_OWF.RES_REQ_TYPE_TSL &&
                                (rcm.isIqviaBiotech == '' || rcm.isIqviaBiotech == null
                                || rcm.lineOfBusiness != CON_OWF.LINE_OF_BUSINESS_CLINICAL || rcm.hasMatchingOpportunityLevelSkill))
                                || (rcm.resourceSubGroup == CON_OWF.RES_REQ_TYPE_IG_LEAD && rcm.hasMatchingLineOfBusinessCertificate && rcm.hasMatchingOpportunityLevelSkill && rcm.hasMatchingopportunityTypeCertificate && rcm.hasGlobalProjectUnitSkill && rcm.availableFTEPoint > 0)
                                || (rcm.resourceSubGroup != CON_OWF.RES_REQ_TYPE_TSL && rcm.resourceSubGroup != CON_OWF.RES_REQ_TYPE_IG_LEAD)))) {
                                    if(!rrIdToContactsMap.containsKey(rcm.resourceRequestId)) {
                                       rrIdToContactsMap.put(rcm.resourceRequestId,new Set<Id>());
                                       rrIdToContactsMap.get(rcm.resourceRequestId).add(contactToBackupResourceIdMap.get(rcm.contactId));
                                   }
                             
                    }
                    //Assign to the next available candidate.
                    else if((rcm.availableFTE || rcm.resourceSubGroup == CON_OWF.RES_REQ_TYPE_IG_LEAD) && rcm.nwtPercentage < 20 && (
                        (rcm.resourceSubGroup != CON_OWF.RES_REQ_TYPE_TSL && rcm.resourceSubGroup != CON_OWF.RES_REQ_TYPE_IG_LEAD)
                        || (rcm.resourceSubGroup == CON_OWF.RES_REQ_TYPE_IG_LEAD && rcm.hasMatchingLineOfBusinessCertificate && rcm.hasMatchingOpportunityLevelSkill && rcm.hasMatchingopportunityTypeCertificate && rcm.hasGlobalProjectUnitSkill && rcm.availableFTEPoint > 0)
                       	|| (rcm.resourceSubGroup == CON_OWF.RES_REQ_TYPE_TSL && rcm.hasMatchingLineOfBusinessCertificate && rcm.hasMatchingTherapyAreaCertificate &&
                            (rcm.isIqviaBiotech == '' || rcm.isIqviaBiotech == null || 
                             rcm.lineOfBusiness != CON_OWF.LINE_OF_BUSINESS_CLINICAL || rcm.hasMatchingOpportunityLevelSkill)))) {
                                if(!rrIdToContactsMap.containsKey(rcm.resourceRequestId)) {
                                    rrIdToContactsMap.put(rcm.resourceRequestId,new Set<Id>());
                                    rrIdToContactsMap.get(rcm.resourceRequestId).add(rcm.contactId);
                                }                      
                        }
                }
            }
            if(rrIdToContactsMap.size() > 0) {
                for(Id rr : rrIdToContactsMap.keySet()) {
                    for(Id resourceId : rrIdToContactsMap.get(rr)) {
                        objSchedule= new pse__Schedule__c();
                        objSchedule.pse__Start_Date__c = (skillRatingRRToOpptyMap.get(rr).pse__End_Date__c < Date.today()  || skillRatingRRToOpptyMap.get(rr).pse__Start_Date__c > Date.today()) ? skillRatingRRToOpptyMap.get(rr).pse__Start_Date__c : Date.today();
                        objSchedule.pse__End_Date__c=skillRatingRRToOpptyMap.get(rr).pse__End_Date__c;
                        objSchedule.pse__Monday_Hours__c=0;
                        objSchedule.pse__Tuesday_Hours__c=0;
                        objSchedule.pse__Wednesday_Hours__c=0;
                        objSchedule.pse__Thursday_Hours__c=0;
                        objSchedule.pse__Friday_Hours__c=0;
                        objSchedule.pse__Saturday_Hours__c=0;
                        objSchedule.pse__Sunday_Hours__c=0;
                        objSchedule.pse__Scheduled_Hours__c=0;
                        rrIdToScheduleMap.put(rr,objSchedule); 
                    }
                }
            }
        } else {
            if (CTS_Lead_RRIds.size() > 0) {
                Set<String> contactFieldSet = new Set<String>{'Available_FTE__c','Pending_FTE__c'};
                    Set<Id> contactsToQuerySet = new Set<Id>();
                for (Id contactId : CTS_Lead_AutoAssignResourceOptions) {
                    contactsToQuerySet.add(contactId);
                }
                if(contactsToQuerySet.size() > 0) {
                    CTS_Lead_AutoAssignResources = new SLT_Contact().selectByContactId(contactsToQuerySet,contactFieldSet);
                }
            }
        }
        if (CTS_Lead_RRIds.size() > 0 && CTS_Lead_AutoAssignResources.size() > 0) {
            Decimal maxAvailMinusPendingFTE = -100; // just a random value which is very less than possible (available FTE - pending FTE)
            Id selectedResourceId;
            Contact selectedResource;
            Decimal availMinusPendingFTE;
            for (Id resourceToSelectId : CTS_Lead_AutoAssignResourceOptions) {
                if (CTS_Lead_AutoAssignResources.containsKey(resourceToSelectId)) {
                    selectedResource = CTS_Lead_AutoAssignResources.get(resourceToSelectId);
                    availMinusPendingFTE = selectedResource.Available_FTE__c - selectedResource.Pending_FTE__c;
                    if (availMinusPendingFTE > maxAvailMinusPendingFTE) {
                        maxAvailMinusPendingFTE = availMinusPendingFTE;
                        selectedResourceId = selectedResource.Id;
                    }
                }
            }
            if (selectedResourceId != null && selectedResourceId != CTS_Lead_AutoAssignResourceOptions[0]) {
                for (Id CTS_Lead_RR_Id : CTS_Lead_RRIds) {
                    if (autoAssignmentIdToAssignmentMap.containsKey(CTS_Lead_RR_Id)) {
                        autoAssignmentIdToAssignmentMap.get(CTS_Lead_RR_Id).pse__Resource__c = selectedResourceId;
                    }
                }
            }
        }
        if(rrIdToScheduleMap.size() > 0 ){
            insert rrIdToScheduleMap.values();
        }
		//Creating pse__Assignment__c for Bid Defense RR
		for(Id rrId : clinicalBidDefenceRrToOpptyMap.keySet()) {
            if( !rRTOAssignmtMap.isEmpty() && rRTOAssignmtMap.containsKey(rrId) ) {
				rRTOAssignmtMap.get(rrId).pse__Schedule__c = rrIdToScheduleMap.get(rrId).id;
			}
		}
		if(rRTOAssignmtMap.size() > 0){
			assignmentList.addAll(rRTOAssignmtMap.values());
		}
		
        //Creating pse__Assignment__c records - #3
        for(Id rrId : clinicalRrToOpptyMap.keySet()) {
            if( !rrIdToAssignmentMap.isEmpty() && rrIdToAssignmentMap.containsKey(rrId) ) {
                objAssignment= new pse__Assignment__c(); 
                objAssignment.pse__Project__c=clinicalRrToOpptyMap.get(rrId).pse__Project__c;
                objAssignment.Bid_History__c = clinicalRrToOpptyMap.get(rrId).Bid_History__c;
                if(preferredResourceAssignmentIdSet.contains(rrIdToAssignmentMap.get(rrId).Id)) {
                    objAssignment.pse__Resource__c=rrIdToAssignmentMap.get(rrId).pse__Resource_Request__r.Preferred_Resource__c;
                }
                else {
                    objAssignment.pse__Resource__c=rrIdToAssignmentMap.get(rrId).pse__Resource__c;
                }                    
                objAssignment.pse__Resource_Request__c = clinicalRrToOpptyMap.get(rrId).id;
                objAssignment.pse__Is_Billable__c=false;
                objAssignment.pse__Bill_Rate__c=0;
                objAssignment.RecordTypeId = CON_OWF.OWF_ASSIGNMENT_RECORD_TYPE_ID;
                objAssignment.CurrencyIsoCode = clinicalRrToOpptyMap.get(rrId).CurrencyIsoCode;
                objAssignment.Is_Triaged_Automatically__c = true;
                objAssignment.Trigger_Email_Notification__c = true;
                if(rrIdToScheduleMap.size() >0){
                    objAssignment.pse__Schedule__c = rrIdToScheduleMap.get(rrId).id;  
                }      
                assignmentList.add(objAssignment);
            }
        }

        for(Id rrId : contractPostAwardRRIdToResourceRequestMap.keySet()) {
            if( !rrIdToAssignmentMap.isEmpty() && rrIdToAssignmentMap.containsKey(rrId) ) {
                objAssignment= new pse__Assignment__c(); 
                objAssignment.pse__Project__c = contractPostAwardRRIdToResourceRequestMap.get(rrId).pse__Project__c;
                objAssignment.Bid_History__c = contractPostAwardRRIdToResourceRequestMap.get(rrId).Bid_History__c;
                if(preferredResourceAssignmentIdSet.contains(rrIdToAssignmentMap.get(rrId).Id)) {
                    objAssignment.pse__Resource__c = rrIdToAssignmentMap.get(rrId).pse__Resource_Request__r.Preferred_Resource__c;
                }
                else {
                    objAssignment.pse__Resource__c = rrIdToAssignmentMap.get(rrId).pse__Resource__c;
                }                    
                objAssignment.pse__Resource_Request__c = contractPostAwardRRIdToResourceRequestMap.get(rrId).id;
                objAssignment.pse__Is_Billable__c=false;
                objAssignment.pse__Bill_Rate__c=0;
                objAssignment.RecordTypeId = CON_OWF.OWF_ASSIGNMENT_RECORD_TYPE_ID;
                objAssignment.CurrencyIsoCode = contractPostAwardRRIdToResourceRequestMap.get(rrId).CurrencyIsoCode;
                objAssignment.Is_Triaged_Automatically__c = true;
                objAssignment.Trigger_Email_Notification__c = true;
                if(rrIdToScheduleMap.size() >0){
                    objAssignment.pse__Schedule__c = rrIdToScheduleMap.get(rrId).id;  
                }      
                assignmentList.add(objAssignment);
            }
        }
        
        //Creating pse__Assignment__c records - #5
        for(Id rr : rrIdToContactsMap.keySet()) {
            for(Id resourceId : rrIdToContactsMap.get(rr)) {
                objAssignment= new pse__Assignment__c(); 
                objAssignment.pse__Project__c=skillRatingRRToOpptyMap.get(rr).pse__Project__c;
                objAssignment.Bid_History__c = skillRatingRRToOpptyMap.get(rr).Bid_History__c;
                objAssignment.pse__Resource__c = resourceId;
                objAssignment.pse__Resource_Request__c = skillRatingRRToOpptyMap.get(rr).id;
                objAssignment.pse__Is_Billable__c=false;
                objAssignment.pse__Bill_Rate__c=0;
                objAssignment.RecordTypeId = CON_OWF.OWF_ASSIGNMENT_RECORD_TYPE_ID;
                objAssignment.CurrencyIsoCode = skillRatingRRToOpptyMap.get(rr).CurrencyIsoCode;
                objAssignment.Is_Triaged_Automatically__c = true;
                objAssignment.Trigger_Email_Notification__c = true;
                if(rrIdToScheduleMap.size() >0){
                    objAssignment.pse__Schedule__c = rrIdToScheduleMap.get(rr).id;  
                }      
                assignmentList.add(objAssignment);
            }
        }
        //Creating pse__Assignment__c records - #6
        for(Id rr : rrIdToBackupContactsMap.keySet()) {
            for(Id resourceId : rrIdToBackupContactsMap.get(rr)) {
                objAssignment= new pse__Assignment__c(); 
                objAssignment.pse__Project__c=backupUserRrIdToRrMap.get(rr).pse__Project__c;
                objAssignment.Bid_History__c = backupUserRrIdToRrMap.get(rr).Bid_History__c;
                objAssignment.pse__Resource__c = resourceId;
                objAssignment.pse__Resource_Request__c = backupUserRrIdToRrMap.get(rr).id;
                objAssignment.pse__Is_Billable__c=false;
                objAssignment.pse__Bill_Rate__c=0;
                objAssignment.RecordTypeId = CON_OWF.OWF_ASSIGNMENT_RECORD_TYPE_ID;
                objAssignment.CurrencyIsoCode = backupUserRrIdToRrMap.get(rr).CurrencyIsoCode;
                objAssignment.Is_Triaged_Automatically__c = true;
                objAssignment.Trigger_Email_Notification__c = true;
                if(rrIdToScheduleMap.size() >0){
                    objAssignment.pse__Schedule__c = rrIdToScheduleMap.get(rr).id;  
                }      
                assignmentList.add(objAssignment);
            }
        }
        if(!autoAssignmentIdToAssignmentMap.isEmpty())
        {
            pse__Assignment__c assignmentInstance;											
            for(Id rrId: autoAssignmentIdToAssignmentMap.keySet())
            {
                assignmentInstance = autoAssignmentIdToAssignmentMap.get(rrId);
                assignmentInstance.pse__Schedule__c = rrIdToScheduleMap.get(rrId).id;
                assignmentList.add(assignmentInstance);
            }   
        }
        if(assignmentList.size() > 0 ){
            insert assignmentList;
            
        }                                        
    }
    
    /**
* This method is used to populate Project on RR of OWF Agreements if it doesn't exist.
* @params List<pse__Resource_Request__c> newList
* @return void
*/
    public static void populateProjectOnRR(List<pse__Resource_Request__c> newList) { 
        Set<Id> agreementIdSet = new Set<Id>();
        
        Map<Id,List<pse__Resource_Request__c>> agrToRRListMap = new Map<Id,List<pse__Resource_Request__c>>();
        Map<Id,pse__Proj__c> agreementToProjectMap = new Map<Id,pse__Proj__c>();
        Set<String> projFieldSet = new Set<String>{'Id','Bid_History__c'};
            for(pse__Resource_Request__c rr : newList) {
                if(rr.recordTypeId == CON_OWF.OWF_RR_RECORD_TYPE_ID && rr.pse__Project__c == null && rr.Bid_History__c != null) {
                    
                    agreementIdSet.add(rr.Bid_History__c);
                    if(!agrToRRListMap.containsKey(rr.Bid_History__c)) {
                        agrToRRListMap.put(rr.Bid_History__c,new List<pse__Resource_Request__c>());
                        agrToRRListMap.get(rr.Bid_History__c).add(rr);
                    }
                    else {
                        agrToRRListMap.get(rr.Bid_History__c).add(rr);
                    }
                    
                }
            }
        if(agreementIdSet.size() > 0 ) {
            Map<Id, pse__Proj__c> projIdToProjMap = new Map<Id, pse__Proj__c>();
            projIdToProjMap = new SLT_Project(false,false).getProjectByBidHistoryID(agreementIdSet, projFieldSet);
            
            for(Id projId : projIdToProjMap.keySet()) {
                agreementToProjectMap.put(projIdToProjMap.get(projId).Bid_History__c,projIdToProjMap.get(projId));
            }
            
            for(pse__Resource_Request__c rr : newList) {
                if(agreementIdSet.contains(rr.Bid_History__c) && agreementToProjectMap.containsKey(rr.Bid_History__c)){
                    rr.pse__Project__c = agreementToProjectMap.get(rr.Bid_History__c).id;
                }else {
                    rr.addError('There is no Project associated with this Agreement. Please contact the Triage Manager.');
                }                
            }
        }
    }
    
    public static void populateRRFieldsFromAgreement(List<pse__Resource_Request__c> newList){
        Set<Id> agreementIdSet = new Set<Id>();
        Set<Id> userIdSet = new Set<Id>();
        Boolean hasAccess = false;
        for(pse__Resource_Request__c rr : newList){
            if(rr.Bid_History__c != null ){
                agreementIdSet.add(rr.Bid_History__c);
            }
        }
        userIdSet.add(UserInfo.getUserId());
        if(agreementIdSet.size() > 0){
            List<pse__Proj__c> projectList = [Select id, recordTypeId, pse__Opportunity__c, Bid_History__c, Bid_History__r.Bid_History_Account__c,
                                              Bid_History__r.Bid_Due_Date__c, Bid_History__r.RecordType.Name,Bid_History__r.Bid_Number__c,Bid_History__r.currencyIsoCode, pse__Group__c, Bid_History__r.Name,
                                              pse__Start_Date__c,Bid_History__r.Bid_History_Related_Opportunity__r.Line_of_Business__c , Bid_History__r.Bid_History_Related_Opportunity__r.Potential_Regions__c
                                              FROM pse__Proj__c where Bid_History__c IN: agreementIdSet];
            Map<Id,pse__Proj__c> agreementIdToProjectMap = new Map<Id,pse__Proj__c>();    
            List<UserPackageLicense> uplList = [SELECT Id, PackageLicenseId, PackageLicense.NamespacePrefix,  UserId 
                                                FROM UserPackageLicense 
                                                where PackageLicense.NamespacePrefix = 'pse' AND UserId IN: userIdSet];
            Map<Id,UserPackageLicense> userIdToUPLMap = new Map<Id,UserPackageLicense>();
            //if(!uplList.isEmpty() || Test.isRunningTest() || !(currentORGURL.contains(prodClassicURL) || currentORGURL.contains(prodLightningURL))){
            for(UserPackageLicense upl : uplList){
                userIdToUPLMap.put(upl.UserId,upl);
            }
            //system.debug('projectList ' + projectList);
            //Check if running user has Triage Permission Set or not.
            List<PermissionSetAssignment> triageManagerPermissionList = [SELECT AssigneeId FROM PermissionSetAssignment WHERE PermissionSet.Name = 'OWF_Triage_Manager' and AssigneeId = :userInfo.getUserId() limit 1];
            if(triageManagerPermissionList != null && triageManagerPermissionList.size() > 0) {
                hasAccess  = true;  
            }
            else {
                hasAccess = false;
            }
            
            if(projectList.size() > 0){
                for(pse__Proj__c proj : projectList){
                    agreementIdToProjectMap.put(proj.Bid_History__c,proj);
                    
                }
                for(pse__Resource_Request__c rr : newList){
                    if(rr.Bid_History__c != null && agreementIdToProjectMap.containsKey(rr.Bid_History__c)){
                        if(agreementIdToProjectMap.get(rr.Bid_History__c).Bid_History__r.RecordType.Name == 'Clinical Bid' || agreementIdToProjectMap.get(rr.Bid_History__c).Bid_History__r.RecordType.Name == 'CSMS Bid')
                        {
                            if(agreementIdToProjectMap.get(rr.Bid_History__c).Bid_History__r.Bid_Number__c == 1)
                            {
                                rr.Bid_Category__c = 'Initial';
                            }
                            
                            else
                            {
                                rr.Bid_Category__c = 'Re-Bid';
                            }   
                        } else{
                            rr.Bid_Category__c = agreementIdToProjectMap.get(rr.Bid_History__c).Bid_History__r.RecordType.Name;
                        }
                        // adding for hotfix 2145
                        if(agreementIdToProjectMap.get(rr.Bid_History__c).recordTypeId == CON_PSA.PROJ_REC_TYPE_ID_RDS_PROJECT || 
                           agreementIdToProjectMap.get(rr.Bid_History__c).recordTypeId == CON_PSA.PROJ_REC_TYPE_ID_RDS_SERVICELINE || 
                           agreementIdToProjectMap.get(rr.Bid_History__c).recordTypeId == CON_PSA.PROJ_REC_TYPE_ID_RDS_INTERNAL){
                               rr.recordTypeId = CON_PSA.RESOURCE_REQUEST_REC_TYPE_ID_RDS_REQUEST;
                           }
                        else{
                            rr.recordTypeId = CON_OWF.OWF_RR_RECORD_TYPE_ID;
                        }
                        rr.currencyIsoCode = agreementIdToProjectMap.get(rr.Bid_History__c).Bid_History__r.currencyIsoCode;
                        rr.pse__Project__c = agreementIdToProjectMap.get(rr.Bid_History__c).id;
                        rr.pse__Opportunity__c = agreementIdToProjectMap.get(rr.Bid_History__c).pse__Opportunity__c;
                        rr.pse__Group__c = agreementIdToProjectMap.get(rr.Bid_History__c).pse__Group__c;
                        rr.Account__c = agreementIdToProjectMap.get(rr.Bid_History__c).Bid_History__r.Bid_History_Account__c;
                        //rr.Bid_Category__c = agreementIdToProjectMap.get(rr.Bid_History__c).Bid_History__r.Bid_Category__c;
                        //Start Date of RR should be Project's Start Date.
                        if(rr.pse__Start_Date__c == null){
                            rr.pse__Start_Date__c = agreementIdToProjectMap.get(rr.Bid_History__c).pse__Start_Date__c;
				  }
                        if(rr.pse__End_Date__c == null){
                            if(rr.SubGroup__c == CON_OWF.RES_REQ_TYPE_IG_LEAD) {
                                rr.pse__End_Date__c =  UTL_OWF.subtractBusinessDays(agreementIdToProjectMap.get(rr.Bid_History__c).Bid_History__r.Bid_Due_Date__c, 2);
                            }
                            else {
                                rr.pse__End_Date__c = agreementIdToProjectMap.get(rr.Bid_History__c).Bid_History__r.Bid_Due_Date__c;
                            }
                        }
                        rr.pse__SOW_Hours__c = 0.01;
                        if(rr.pse__End_Date__c < Date.Today() && !rr.Is_Bid_Defense__c && !hasAccess ){
                            rr.addError('Bid Due Date on Agreement: ' + agreementIdToProjectMap.get(rr.Bid_History__c).Bid_History__r.Name + ' should be in Future');
                        }
                        //added potential regions - iqviapsa-589
                        rr.Potential_Regions__c = agreementIdToProjectMap.get(rr.Bid_History__c).Bid_History__r.Bid_History_Related_Opportunity__r.Potential_Regions__c;
                    }
                    
                }
            } 
            /*}else{
for(pse__Resource_Request__c rr : newList){
rr.addError('You don\'t have sufficient permission to create this record. Please contact your Admin');
}
}*/                                                   
            
        }
        
    }
    
    
    public static void populateBidCategoryOnRR(List<pse__Resource_Request__c> newList) {
        Set<Id> agreementIdSet = new Set<Id>();
        Map<Id,Bid_History__c> agrIdToAgreementMap = new Map<Id,Bid_History__c>();
        Set<String> agrFieldSet = new Set<String>{'Id', 'Bid_Number__c', 'RecordType.Name','RecordTypeId'};
            
            for(pse__Resource_Request__c rr : newList ) {
                if(rr.recordTypeId == CON_OWF.OWF_RR_RECORD_TYPE_ID && rr.Bid_History__c != null) {
                    agreementIdSet.add(rr.Bid_History__c);
                }
            }
        if(agreementIdSet.size() > 0 ) {
            agrIdToAgreementMap = new SLT_Bid_History(false,false).getBidHistoriesById(agreementIdSet, agrFieldSet);
            for(pse__Resource_Request__c rr : newList ) {
                if(rr.Bid_History__c != null && agrIdToAgreementMap.containsKey(rr.Bid_History__c)) {
                    if(agrIdToAgreementMap.get(rr.Bid_History__c).RecordType.Name == 'Clinical Bid' || agrIdToAgreementMap.get(rr.Bid_History__c).RecordType.Name == 'CSMS Bid') {
                        if(agrIdToAgreementMap.get(rr.Bid_History__c).Bid_Number__c == 1) {
                            rr.Bid_Category__c = 'Initial';
                        }
                        
                        else {
                            rr.Bid_Category__c = 'Re-Bid';
                        }   
                    } else {
                        rr.Bid_Category__c = agrIdToAgreementMap.get(rr.Bid_History__c).RecordType.Name;
                    }                    
                }
            }     
        } 
    }
    
    
    public static void createResourceSkillRequestForGBO(List<pse__Resource_Request__c> newList){
        List<pse__Resource_Skill_Request__c> createResourceSkillRequestList = new List<pse__Resource_Skill_Request__c>();
        Set<Id> gboResourceRequestIdSet= new Set<Id>();
        for(pse__Resource_Request__c resourceRequest : newList) {
            if(resourceRequest.recordTypeId == CON_OWF.OWF_RR_RECORD_TYPE_ID && (resourceRequest.SubGroup__c.contains(CON_OWF.RES_REQ_TYPE_IG_LEAD) || resourceRequest.SubGroup__c.contains(CON_OWF.RES_REQ_TYPE_GBO_LEAD_PD) || resourceRequest.SubGroup__c.contains(CON_OWF.RFI_SUBGROUP) || resourceRequest.SubGroup__c.contains(CON_OWF.RES_REQ_TYPE_GBO_SUPPORT_PD) || resourceRequest.SubGroup__c.contains(CON_OWF.RES_REQ_TYPE_GBO_STRATEGIC_WRITER))){
                //system.assert(false,'1252');
                gboResourceRequestIdSet.add(resourceRequest.Id);
            }
            
        }
        if(gboResourceRequestIdSet.size()>0) {
            createResourceSkillRequestList = returnRSRForGBOResourceRequest(gboResourceRequestIdSet);
        }
        
        if(createResourceSkillRequestList.size() > 0){
            insert createResourceSkillRequestList;
        }
        List<Suggested_Resources__c> suggestedResourceList = createSuggestedResourceForGBO(createResourceSkillRequestList);
        if(suggestedResourceList.size() > 0){
            insert suggestedResourceList;
        }
    }
    public static List<Suggested_Resources__c> createSuggestedResourceForGBO(List<pse__Resource_Skill_Request__c> rsrList ){
        List<Suggested_Resources__c> suggestedResourceList = new List<Suggested_Resources__c>();
        List<DAOH_OWF_Resource_Skill_Request.ResourceCandidateMatchScore> resourceCandidateMatchScoreList = new List<DAOH_OWF_Resource_Skill_Request.ResourceCandidateMatchScore>();
        List<DAOH_OWF_Resource_Skill_Request.ResourceCandidateMatchScore> resMatchScoreWrapperList = new List<DAOH_OWF_Resource_Skill_Request.ResourceCandidateMatchScore>();
        
        resourceCandidateMatchScoreList = DAOH_OWF_Resource_Skill_Request.createResourceCandidateMatchScoreForGBO(rsrList);
        resMatchScoreWrapperList = UTL_OWF.calculateNWTimePercentage(resourceCandidateMatchScoreList);
        resMatchScoreWrapperList.sort();
        OWF_Assignment_Setting__mdt assignmentSettingRecord;
        if(resMatchScoreWrapperList.size()>0){
            for(DAOH_OWF_Resource_Skill_Request.ResourceCandidateMatchScore rcm : resMatchScoreWrapperList) {
                Id resourceId= rcm.contactId;
                Id resourceRequestId = rcm.resourceRequestId;
                assignmentSettingRecord = rcm.assignmentSettingRecord;
                //System.debug( '*** rcm.availableFTE, rcm.nwtPercentage, rcm.gradeLevelScore, rcm.hasMatchingPR, rcm.hasRequiredRFPBidComplexity  ' + rcm.availableFTE + ' ' + rcm.nwtPercentage + ' ' + rcm.gradeLevelScore + ' ' + rcm.hasMatchingPR + ' ' + rcm.hasRequiredRFPBidComplexity);
                if((rcm.resourceSubGroup == CON_OWF.RES_REQ_TYPE_IG_LEAD || rcm.availableFTE) && rcm.nwtPercentage < 20 && rcm.hasMatchingPR && ((rcm.hasRequiredRFPBidComplexity && rcm.gradeLevelScore>0 && rcm.resourceSubGroup != CON_OWF.RES_REQ_TYPE_GBO_LEAD_PD && rcm.resourceSubGroup != CON_OWF.RES_REQ_TYPE_IG_LEAD) 
                                                                                       || ((rcm.resourceSubGroup == CON_OWF.RES_REQ_TYPE_GBO_LEAD_PD || (rcm.resourceSubGroup == CON_OWF.RES_REQ_TYPE_IG_LEAD && rcm.availableFTEPoint > 0 && rcm.hasGlobalProjectUnitSkill)) && rcm.hasMatchingLineOfBusinessCertificate && rcm.hasMatchingopportunityTypeCertificate && rcm.hasMatchingOpportunityLevelSkill))){
                                                                                           Suggested_Resources__c suggestedResource= new Suggested_Resources__c();
                                                                                           suggestedResource.Name = rcm.resourceName;
                                                                                           suggestedResource.Resource__c =resourceId;
                                                                                           suggestedResource.Resource_Request__c =resourceRequestId;
                                                                                           suggestedResource.Match_Percentage__c = rcm.gradeLevelScore;
                                                                                           suggestedResource.Skill_Name__c = rcm.skillName;
                                                                                           if(rcm.matchScore>0){
                                                                                               Decimal maximumMatchScore = assignmentSettingRecord.Matching_Point_Indication__c*100
                                                                                                   +assignmentSettingRecord.Matching_Point_Line_of_Business__c*100
                                                                                                   +assignmentSettingRecord.Matching_Point_Therapeutic_Area__c*100
                                                                                                   +assignmentSettingRecord.Matching_Point_Potential_Regions__c*100;
                                                                                               suggestedResource.Remaining_Match_percentage__c= (rcm.matchScore*100)/maximumMatchScore;
                                                                                           }
                                                                                           suggestedResourceList.add(suggestedResource);
                                                                                       }								 
            }
        }
        return suggestedResourceList;
    }
    
    public static List<pse__Resource_Skill_Request__c> returnRSRForGBOResourceRequest(Set<Id> gboResourceRequestIdSet){
        List<pse__Resource_Skill_Request__c> createRsrRecordsList = new List<pse__Resource_Skill_Request__c>();
        Map<String, pse__Skill__c> skillNameToSkillMap = new Map<String, pse__Skill__c>();
        List<pse__Resource_Request__c> resourceRequestList = new List<pse__Resource_Request__c>();
        Set<String> resourceRequestFieldSet = new Set<String>{'Id','Bid_History__r.Triage_Level__c', 'Bid_History__r.RFP_Ranking__c','SubGroup__c','Name', 'Bid_History__r.Bid_Complexity__c'};
            if(gboResourceRequestIdSet.size() > 0) {
                resourceRequestList = new SLT_Resource_Request(false, false).selectResReqsById(gboResourceRequestIdSet, resourceRequestFieldSet).values();
            }        
        
        Set<String> skillFieldSet = new Set<String>{'Id', 'Name', 'pse__Type__c'};
            String skillCondition = 'pse__Type__c in (\'Grade Level\',\'Triage Level\')';
        List<pse__Skill__c> skillsList = new SLT_Skill(false, false).getSkillsByCondition(new Set<Id>(),skillFieldSet,skillCondition).values();
        for(pse__Skill__c skill : skillsList){
            skillNameToSkillMap.put(skill.Name, skill);
        }
        for(pse__Resource_Request__c resRequest : resourceRequestList){
            //system.assert(false,resRequest.SubGroup__c + ':' +skillNameToSkillMap.containsKey('RFI Triage Level'));
            if(skillNameToSkillMap.containsKey('RFP Ranking') && resRequest.SubGroup__c !='GBO-RFI'){
                pse__Resource_Skill_Request__c rsrRecord = new pse__Resource_Skill_Request__c();
                rsrRecord.pse__Resource_Request__c = resRequest.Id;
                rsrRecord.pse__Skill_Certification__c = skillNameToSkillMap.get('RFP Ranking').Id;
                rsrRecord.pse__Is_Primary__c = false;
                rsrRecord.pse__Minimum_Rating__c ='1 - Limited Exposure';
                createRsrRecordsList.add(rsrRecord);
            }
            if(skillNameToSkillMap.containsKey(resRequest.Bid_History__r.Triage_Level__c) && resRequest.SubGroup__c =='GBO-RFI')
            {
                pse__Resource_Skill_Request__c rsrRecord = new pse__Resource_Skill_Request__c();
                rsrRecord.pse__Resource_Request__c = resRequest.Id;
                rsrRecord.pse__Skill_Certification__c = skillNameToSkillMap.get(resRequest.Bid_History__r.Triage_Level__c).Id;
                rsrRecord.pse__Is_Primary__c = false;
                rsrRecord.pse__Minimum_Rating__c ='1 - Limited Exposure';
                createRsrRecordsList.add(rsrRecord);
            }
            //System.debug(LoggingLevel.INFO, '****** resRequest.Bid_History__r.Bid_Complexity__c: ' + resRequest.Bid_History__r.Bid_Complexity__c);
            if(resRequest.Bid_History__r.Bid_Complexity__c != '' && resRequest.Bid_History__r.Bid_Complexity__c != null){
                pse__Resource_Skill_Request__c rsrRecord = new pse__Resource_Skill_Request__c();
                rsrRecord.pse__Resource_Request__c = resRequest.Id;
                rsrRecord.pse__Is_Primary__c = false;
                // set min rating based on bid complexity
                //System.debug(LoggingLevel.INFO, '****** resRequest.Bid_History__r.Bid_Complexity__c: ' + resRequest.Bid_History__r.Bid_Complexity__c);
                if(resRequest.Bid_History__r.Bid_Complexity__c == 'Low'){
                    rsrRecord.pse__Minimum_Rating__c ='1 - Limited Exposure';
                }
                else if(resRequest.Bid_History__r.Bid_Complexity__c == 'Med'){
                    rsrRecord.pse__Minimum_Rating__c ='3 - Comfortable';
                }
                else if(resRequest.Bid_History__r.Bid_Complexity__c == 'High'){
                    rsrRecord.pse__Minimum_Rating__c ='5 - Expert';
                }
                // set skill based on rfp ranking
                // rfp ranking = 1
                if(resRequest.Bid_History__r.RFP_Ranking__c == '1'){
                    rsrRecord.pse__Skill_Certification__c = skillNameToSkillMap.get('RFP Ranking 1').Id;
                }
                // rfp ranking = 2
                else if(resRequest.Bid_History__r.RFP_Ranking__c == '2'){
                    rsrRecord.pse__Skill_Certification__c = skillNameToSkillMap.get('RFP Ranking 2').Id;
                }
                // rfp ranking = 3
                else if(resRequest.Bid_History__r.RFP_Ranking__c == '3'){
                    rsrRecord.pse__Skill_Certification__c = skillNameToSkillMap.get('RFP Ranking 3').Id;
                }
                // rfp ranking = 4
                else if(resRequest.Bid_History__r.RFP_Ranking__c == '4'){
                    rsrRecord.pse__Skill_Certification__c = skillNameToSkillMap.get('RFP Ranking 4').Id;
                }
                // rfp ranking = 5
                else if(resRequest.Bid_History__r.RFP_Ranking__c == '5'){
                    rsrRecord.pse__Skill_Certification__c = skillNameToSkillMap.get('RFP Ranking 5').Id;
                }
                
                createRsrRecordsList.add(rsrRecord);
            }
        }
        return createRsrRecordsList;
    }
    
    
    public static void populateOriginalAssigneeForPostAwards(List<pse__Resource_Request__c> newList)
    {
        Set<Id> oppIdSet = new Set<Id>();
        Map<String, Map<String,pse__Resource_Request__c>>  subgroupToleadSupportFlagToresourceRequestMap = new Map<String, Map<String,pse__Resource_Request__c>>();
        
        for(pse__Resource_Request__c rr: newList){
            if(rr.RecordTypeId == CON_OWF.OWF_RR_RECORD_TYPE_ID && rr.pse__Opportunity__c != Null 
               && rr.Resource_Request_Type__c != Null && rr.Resource_Request_Type__c.equals('Post Award')) {
                   oppIdSet.add(rr.pse__Opportunity__c);
               }
        }
        
        if(!oppIdSet.isEmpty())
        {
            Set<String> rrFieldSet = new  Set<String>{'id','Name','SubGroup__c','Bid_History__c','Bid_History__r.RecordType.DeveloperName','pse__Opportunity__c',
                'pse__Staffer_Resource__c','Opportunity_Number__c','pse__Staffer_Resource__r.Id', 'Resource_Request_Type__c','Is_Bid_Defense__c', 'Is_Created_Automatically__c','LeadSupportFlag__c'};
                    String getRRCondition = ' and Bid_History__r.RecordType.DeveloperName =\'Clinical_Bid\' and Is_Bid_Defense__c = False and LeadSupportFlag__c != null and (SubGroup__c = \'TSL\' or SubGroup__c = \'Medical-MSL\') and pse__Assignment__r.pse__Status__c in (\'Accepted\' ,\'Completed\') and pse__Assignment__r.Bid_Number__c=1';
            List<pse__Resource_Request__c> sltResourceRequestwithOpportunity = new SLT_Resource_Request(false,false).getResourceRequestListFromOpportunityforPostAward(oppIdSet,rrFieldSet,getRRCondition);
            
            for(pse__Resource_Request__c rr: sltResourceRequestwithOpportunity){
                if(!subgroupToleadSupportFlagToresourceRequestMap.containsKey(rr.SubGroup__c)){
                    subgroupToleadSupportFlagToresourceRequestMap.put(rr.SubGroup__c,new Map<String,pse__Resource_Request__c>()); 
                }
                if(subgroupToleadSupportFlagToresourceRequestMap.containsKey(rr.SubGroup__c) && !subgroupToleadSupportFlagToresourceRequestMap.get(rr.SubGroup__c).containsKey(rr.LeadSupportFlag__c)){
                     subgroupToleadSupportFlagToresourceRequestMap.get(rr.SubGroup__c).put(rr.LeadSupportFlag__c,rr);
                 }
            }
            for(pse__Resource_Request__c rr: newList)
               {
                    if(rr.RecordTypeId == CON_OWF.OWF_RR_RECORD_TYPE_ID && rr.Resource_Request_Type__c.equals('Post Award') && !subgroupToleadSupportFlagToresourceRequestMap.isEmpty() && subgroupToleadSupportFlagToresourceRequestMap.containsKey(rr.SubGroup__c) && subgroupToleadSupportFlagToresourceRequestMap.get(rr.SubGroup__c)!= null && subgroupToleadSupportFlagToresourceRequestMap.get(rr.SubGroup__c).containsKey(rr.LeadSupportFlag__c)){
                              rr.Original_Assignee__c = subgroupToleadSupportFlagToresourceRequestMap.get(rr.SubGroup__c).get(rr.LeadSupportFlag__c).pse__Staffer_Resource__r.Id;
                    }
               }
          }
    }
    
    public static List<Suggested_Resources__c> createSuggestedResourceForTSSU(List<pse__Resource_Skill_Request__c> rsrList )
    {
        List<Suggested_Resources__c> suggestedResourceList = new List<Suggested_Resources__c>();
        List<DAOH_OWF_Resource_Skill_Request.ResourceCandidateMatchScore> resourceCandidateMatchScoreList = new List<DAOH_OWF_Resource_Skill_Request.ResourceCandidateMatchScore>();
        List<DAOH_OWF_Resource_Skill_Request.ResourceCandidateMatchScore> resMatchScoreWrapperList = new List<DAOH_OWF_Resource_Skill_Request.ResourceCandidateMatchScore>();
        
        
       /*resMatchScoreWrapperList = DAOH_OWF_Resource_Skill_Request.createResourceCandidateMatchForRegionalAnaylytics(rsrList);  
        if(resMatchScoreWrapperList.size()>0){
            for(DAOH_OWF_Resource_Skill_Request.ResourceCandidateMatchScore rcm : resMatchScoreWrapperList) {
                if(rcm.resReqObject.SubGroup__c == CON_OWF.RES_REQ_TYPE_Global_Analytics ){
                    Suggested_Resources__c suggestedResource= new Suggested_Resources__c();
                    suggestedResource.Name = rcm.resourceName;
                    suggestedResource.Resource__c =rcm.contactId;
                    suggestedResource.Resource_Request__c =rcm.resourceRequestId;
                    suggestedResource.Match_Percentage__c = rcm.gradeLevelScore;
                    suggestedResource.Skill_Name__c = rcm.skillName;
                    suggestedResourceList.add(suggestedResource);
                }
            }
            if(suggestedResourceList.size()>0){
                insert suggestedResourceList;
                return;
            }
        }*/
        
        resourceCandidateMatchScoreList = DAOH_OWF_Resource_Skill_Request.createResourceCandidateMatchScoreForTSSU(rsrList); 
        resMatchScoreWrapperList = UTL_OWF.calculateNWTimePercentage(resourceCandidateMatchScoreList);
        resMatchScoreWrapperList.sort();
        
        OWF_Assignment_Setting__mdt assignmentSettingRecord;
        if(resMatchScoreWrapperList.size()>0){
            Id resourceId;
            Id resourceRequestId;
            Suggested_Resources__c suggestedResource;
            Decimal maximumMatchScore;				 
            for(DAOH_OWF_Resource_Skill_Request.ResourceCandidateMatchScore rcm : resMatchScoreWrapperList) {
                resourceId= rcm.contactId;
                resourceRequestId = rcm.resourceRequestId;
                assignmentSettingRecord = rcm.assignmentSettingRecord;
                if(rcm.availableFTE && rcm.nwtPercentage < 20 && rcm.hasMatchingPR &&((rcm.resourceSubGroup == CON_OWF.RES_REQ_TYPE_TSL
                && ((rcm.hasMatchingTherapyAreaCertificate && rcm.hasMatchingLineOfBusinessCertificate
                && (rcm.isIqviaBiotech == '' || rcm.isIqviaBiotech == null || rcm.lineOfBusiness != CON_OWF.LINE_OF_BUSINESS_CLINICAL || rcm.hasMatchingOpportunityLevelSkill)
                && (rcm.resourceRequestType == 'Clinical' || rcm.resourceRequestType == 'Clinical - Ballpark'))
                || (rcm.resourceRequestType != 'Clinical' && rcm.resourceRequestType != 'Clinical - Ballpark')))
                || rcm.resourceSubGroup != CON_OWF.RES_REQ_TYPE_TSL)){
                    suggestedResource= new Suggested_Resources__c();
                    suggestedResource.Name = rcm.resourceName;
                    suggestedResource.Resource__c =resourceId;
                    suggestedResource.Resource_Request__c =resourceRequestId;
                    suggestedResource.Match_Percentage__c = rcm.gradeLevelScore;
                    suggestedResource.Skill_Name__c = rcm.skillName;
                    if(rcm.matchScore>0 && rcm.resourceSubGroup == CON_OWF.RES_REQ_TYPE_Global_Analytics)
                    {
                        suggestedResource.Remaining_Match_percentage__c = rcm.matchScore*10;
                    }
                    else if(rcm.matchScore>0 && rcm.resourceSubGroup != CON_OWF.RES_REQ_TYPE_Global_Analytics){
                        rcm.matchScore = rcm.matchScore*10;
                        maximumMatchScore = assignmentSettingRecord.Matching_Point_Indication__c*100
                        +assignmentSettingRecord.Matching_Point_Line_of_Business__c*100
                        +assignmentSettingRecord.Matching_Point_Therapeutic_Area__c*100
                        +assignmentSettingRecord.Matching_Point_Potential_Regions__c*100;
                        if(rcm.resourceSubGroup == CON_OWF.RES_REQ_TYPE_TSL && (rcm.resourceRequestType == 'Clinical' || rcm.resourceRequestType == 'Clinical - Ballpark')){
                            maximumMatchScore = maximumMatchScore + assignmentSettingRecord.Matching_Point_BD_Lead_Sub_Region__c*100 +assignmentSettingRecord.Matching_Point_Customer__c*100;
                        }
                        suggestedResource.Remaining_Match_percentage__c= (rcm.matchScore*100)/maximumMatchScore;
                    }
                    suggestedResourceList.add(suggestedResource);
                }
            }
  
        }
        return suggestedResourceList;
    }
    /**
* This method is used to create Schedule
* @params  Date startDate
* @params  Date endDate
* @return  pse__Schedule__c scheduleRecord
*/
    private static pse__Schedule__c createdSchedule(Date startDate, Date endDate) {
        pse__Schedule__c scheduleRecord = new pse__Schedule__c();
        if(endDate < Date.today()  || startDate > Date.today()){
        	scheduleRecord.pse__Start_Date__c = startDate;
        }
        else{
            scheduleRecord.pse__Start_Date__c = date.today();
        }
        scheduleRecord.pse__End_Date__c = endDate;
        return scheduleRecord;
    }
    //IQVIAPSA-2318
    public static void validateStartEndDateforTriageManager(List<pse__Resource_Request__c> newList, Map<Id, pse__Resource_Request__c> oldMap){
        List<Bid_History__c> agmntIdList = new List<Bid_History__c>();
        Map<Id,Bid_History__c> agmntIdMap = new Map<Id,Bid_History__c>();
        Mulesoft_Integration_Control__c mulesoftSetting = Mulesoft_Integration_Control__c.getInstance();
        Boolean isTssuUser = false;
        Map<String,OWF_TSSU_Subgroup__c> owfTssuSubgroupCS_Map = new Map<String,OWF_TSSU_Subgroup__c>();
        owfTssuSubgroupCS_Map = OWF_TSSU_Subgroup__c.getAll();
        Set<String> contactFieldSet = new Set<String>{'Id', 'Sub_Group__c'};
            Set<ID> userIdSet = new Set<ID>{userInfo.getUserId()};    
                List<contact> contList=new SLT_Contact(false,false).selectBySalesforceUserIdList(userIdSet,contactFieldSet);
        if(contList!=null && !contList.isEmpty() && owfTssuSubgroupCS_Map.containsKey(contList[0].Sub_Group__c)){
            isTssuUser = true;
        }
        If(!mulesoftSetting.Ignore_Validation_Rules__c )
        {        
            if(!CON_OWF.BYPASS_VALIDATION_RULE_RR && !isTssuUser){
                Set<Id> rrIdSet = new Set<Id>();
                Set<Id> argmtIdSet = new Set<Id>();
                for(pse__Resource_Request__c rr: newList){
                    If( rr.RecordTypeId == CON_OWF.OWF_RR_RECORD_TYPE_ID && rr.SubGroup__c != Null && (oldMap != NULL && (rr.pse__End_Date__c != oldMap.get(rr.Id).pse__End_Date__c ) || (rr.pse__Start_Date__c != oldMap.get(rr.Id).pse__Start_Date__c ))){
                        rrIdSet.add(rr.Id);
                        argmtIdSet.add(rr.Bid_History__c);
                    }
                }
                
                If(!argmtIdSet.isEmpty()){   
                    Set<String> agrmntFieldSet = new Set<String>{'Id', 'Bid_Due_Date__c'};
                        agmntIdList = new SLT_Bid_History(false,false).getBidHistoryFieldsById(argmtIdSet,agrmntFieldSet);                    
                }
                
                for(Bid_History__c agrmnt : agmntIdList )
                {
                    agmntIdMap.put(agrmnt.Id,agrmnt);
                }
                
                If(!rrIdSet.isEmpty()){           
                    List<PermissionSetAssignment> triageManagerPermissionList = [SELECT AssigneeId FROM PermissionSetAssignment WHERE PermissionSet.Name = 'OWF_Triage_Manager' and AssigneeId = :userInfo.getUserId() limit 1];
                    
                    for(pse__Resource_Request__c rrUpdate: newList){              
                        
                        If(triageManagerPermissionList.size() == 0 ){
                            rrUpdate.addError('You don\'t have permission to change Start Date or End Date');
                        }
                        else if(rrUpdate.pse__Assignment__c != null){
                            rrUpdate.addError('You can not change Start Date or End Date when Resource Request have Assignment');
                        }
                        else if(!agmntIdMap.isEmpty() && agmntIdMap.get(rrUpdate.Bid_History__c).Bid_Due_Date__c != null && agmntIdMap.get(rrUpdate.Bid_History__c).Bid_Due_Date__c < Date.Today()){
                            rrUpdate.addError('You can not change Start or End Date if the Agreement\'s Bid due Date is in past');
                        }
                    }
                }
       		 }
        }
    }
    
    public static void setLeadSupportFlagOnResourceRequest(List<pse__Resource_Request__c> newList){
        Set<Id> bidHistoryIdSet = new Set<Id>();
        Map<Id,Map<String,List<String>>> bidIDtoResourceRequestSubgroupListMap = new Map<Id,Map<String,List<String>>>();
        Set<String> resourceRequestFieldSet = new Set<String>{'Bid_History__c','Resource_Request_Type__c','SubGroup__c'};
            
        for(pse__Resource_Request__c resRequest: newList){
            if(CON_OWF.RR_TYPE_FOR_LEAD_SUPPORT_FLAG.contains(resRequest.Resource_Request_Type__c)){
                bidHistoryIdSet.add(resRequest.Bid_History__c);
            }   
        }
        
        if(!bidHistoryIdSet.isEmpty()){
        	List<pse__Resource_Request__c> resourceRequestList = new SLT_Resource_Request().getResourceRequestListFromBidHistory(bidHistoryIdSet, resourceRequestFieldSet,'');
            for(pse__Resource_Request__c resRequest: resourceRequestList){
                if(!bidIDtoResourceRequestSubgroupListMap.containsKey(resRequest.Bid_History__c)){
                    bidIDtoResourceRequestSubgroupListMap.put(resRequest.Bid_History__c,new Map<String,List<String>>());
                    bidIDtoResourceRequestSubgroupListMap.get(resRequest.Bid_History__c).put(resRequest.Resource_Request_Type__c,new List<String>{resRequest.SubGroup__c});
                }
                else{
                    if(bidIDtoResourceRequestSubgroupListMap.get(resRequest.Bid_History__c).containsKey(resRequest.Resource_Request_Type__c)){
                        bidIDtoResourceRequestSubgroupListMap.get(resRequest.Bid_History__c).get(resRequest.Resource_Request_Type__c).add(resRequest.SubGroup__c);
                    }
                    else{
                        bidIDtoResourceRequestSubgroupListMap.get(resRequest.Bid_History__c).put(resRequest.Resource_Request_Type__c,new List<String>{resRequest.SubGroup__c});
                    }
                }
        	}
        }

        for(pse__Resource_Request__c resRequest: newList){
            if(!resRequest.Is_Created_Automatically__c && !bidIDtoResourceRequestSubgroupListMap.isEmpty() && bidIDtoResourceRequestSubgroupListMap.get(resRequest.Bid_History__c).containsKey(resRequest.Resource_Request_Type__c) && bidIDtoResourceRequestSubgroupListMap.get(resRequest.Bid_History__c).get(resRequest.Resource_Request_Type__c).contains(resRequest.SubGroup__c)){
                	resRequest.LeadSupportFlag__c = CON_OWF.SUPPORT_FLAG;
            }
        }     
    }
    
    public static void populateGroupOnResourceRequest(List<pse__Resource_Request__c> newList){
        Map<String,String> resSettingSubgroupToGroupMap = new Map<String,String>();
        Set<String> orsFieldSet = new Set<String>{'Id','Sub_Group__c', 'Group__c'};
        for(OWF_Resource_Setting__mdt rs : new SLT_OWF_Resource_Setting(false, false).getOWFResourceSettingRecords(orsFieldSet)){
                    resSettingSubgroupToGroupMap.put(rs.Sub_Group__c,rs.Group__c);                                          
        }
        for(pse__Resource_Request__c rr : newList){
            if(rr.recordTypeId == CON_OWF.OWF_RR_RECORD_TYPE_ID && resSettingSubgroupToGroupMap.containsKey(rr.SubGroup__c)){
                rr.Parent_Group__c = resSettingSubgroupToGroupMap.get(rr.SubGroup__c);
            }
        }      
    }	
}
