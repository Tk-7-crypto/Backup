/**
* This is Resource_Skill_Request trigger handler class.
* version : 1.0
*/
public without sharing class DAOH_OWF_Resource_Skill_Request {
    /**
    * This method is used to create ResourceCandidateMatchScore records on insertion of Resource_Skill_Request
    * @params  newList List<pse__Resource_Skill_Request__c>
    * @return  List<ResourceCandidateMatchScore>
    */
    public static List<ResourceCandidateMatchScore> createResourceCandidateMatchScore(List<pse__Resource_Skill_Request__c> resourceSkillRequestList) {
        List<ResourceCandidateMatchScore> resourceCandidateMatchScoreList = new List<ResourceCandidateMatchScore>();
        Set<Id> resourceRequestIdsSet = new Set<Id>();
        
        for(pse__Resource_Skill_Request__c rsr : resourceSkillRequestList) {
            if(rsr.pse__Resource_Request__c != null) {
                resourceRequestIdsSet.add(rsr.pse__Resource_Request__c);
            }
        }
        
        if(resourceRequestIdsSet.size() > 0) {
            resourceCandidateMatchScoreList = validateAndCreateCandidateMatchScores(resourceRequestIdsSet);
        }
        return resourceCandidateMatchScoreList;
         
    }
    
    /**
    * This method is used to validate skill certifications and create ResourceCandidateMatchScore records
    * @params  resourceRequestIdsSet Set<Id>
    * @return  List<ResourceCandidateMatchScore>
    */
    private static List<ResourceCandidateMatchScore> validateAndCreateCandidateMatchScores(Set<Id> resourceRequestIdsSet) {
        List<ResourceCandidateMatchScore> resourceCandidateMatchScoreList = new List<ResourceCandidateMatchScore>();
        Map<Id, pse__Resource_Request__c> resourceRequestsMap = new Map<Id, pse__Resource_Request__c>();
        Map<Id, List<pse__Resource_Skill_Request__c>> skillToRSRsMap = new Map<Id, List<pse__Resource_Skill_Request__c>>();
        Set<Id> contactAlignedwithAccount=new Set<Id>();
        Map<Id, List<pse__Skill_Certification_Rating__c>> skillIdToSkillCertiRatingsMap = new Map<Id, List<pse__Skill_Certification_Rating__c>>();
        Map<String,ResourceCandidateMatchScore> combinedKeyToMatchScoreMap = new Map<String,ResourceCandidateMatchScore>();
        ResourceCandidateMatchScore resCandidateMatchScoreRec;

        //Fetching Resource_Requests with all ResourceSkillRequests and preparing a map b/w resource_request and list of resource_skill_requests
        String resReqCondition = 'Id IN :sObjectIdSet And RecordType.DeveloperName = \'' + CON_OWF.OWF_RESOURCE_REQUEST_RECORD_TYPE_NAME + '\'';
        Set<String> resRequestFieldSet = new Set<String>{'Id', 'pse__Resource__c', 'Resource_Request_Type__c', 'SubGroup__c', 'Complexity_Score_Total__c', 'Bid_History__r.RFP_Ranking__c','Bid_History__r.BD_Lead_Sub_Region__c','Potential_Regions__c','BD_Lead_Sub_Region__c','pse__Opportunity__r.FSP__c','pse__Opportunity__r.Is_this_IQVIA_Biotech__c','pse__Opportunity__r.Line_of_Business__c','Bid_History__r.Requested_Services__c','Account__c','pse__Project__r.pse__Start_Date__c','Bid_History__r.Bid_History_Related_Opportunity__r.Global_project_unit__c','Bid_History__r.Opportunity_Type__c'};
            Set<String> resSkillRequestFieldSet = new Set<String>{'Id', 'pse__Resource_Request__c', 'pse__Skill_Certification__c', 'pse__Skill_Certification__r.pse__Type__c','pse__Resource_Request__r.SubGroup__c','pse__Resource_Request__r.pse__Opportunity__r.Line_of_Business__c','pse__Resource_Request__r.pse__Opportunity__r.TherapyArea__c'};
                String resSkillReqCondition =  'pse__Resource_Request__c IN : sObjectIdSet';
        resourceRequestsMap = new SLT_Resource_Request(false,false).selectByIdWithResReqsAndRSRs(resourceRequestIdsSet, resReqCondition, resRequestFieldSet, resSkillRequestFieldSet, resSkillReqCondition);
        Set<String> subGroupSet = new Set<String>();
        //Get map of BD Lead Sub Region to Potential Region
        Set<String> potentialRegToBDLeadMappingFieldSet = new Set<String>{'Id','Potential_Region__c','BD_Lead_Sub_Region__c'};
        Map<String,String> bdLeadToPRMap = new Map<String,String>();
        for(Potential_Region_To_BD_Lead_Mapping__mdt mapping : 
            new SLT_Potential_Region_To_BD_Lead_Mapping(false,false).getPotentialRegionToBDLeadMappings(potentialRegToBDLeadMappingFieldSet)) {
                    
            bdLeadToPRMap.put(mapping.BD_Lead_Sub_Region__c,mapping.Potential_Region__c);
        }
        Id accountId;
        //Fetching all Skill_Certification_Ratings and preparing a map b/w resource and list of Skill_Certification_Ratings
        if(!resourceRequestsMap.IsEmpty()) {
            for(pse__Resource_Request__c resourceRequest : resourceRequestsMap.values()) {
                subGroupSet.add(resourceRequest.SubGroup__c);
                if(resourceRequest.SubGroup__c == CON_OWF.RES_REQ_TYPE_TSL){
                    accountId = resourceRequest.Account__c;
                }
                if(resourceRequest.pse__Resource_Skill_Requests__r.size() > 0) {
                    for(pse__Resource_Skill_Request__c rsr: resourceRequest.pse__Resource_Skill_Requests__r) {
                        if(rsr.pse__Skill_Certification__c != NULL) {
                            if(!skillToRSRsMap.containsKey(rsr.pse__Skill_Certification__c)) {
                                skillToRSRsMap.put(rsr.pse__Skill_Certification__c, new List<pse__Resource_Skill_Request__c>());
                            }
                            skillToRSRsMap.get(rsr.pse__Skill_Certification__c).add(rsr);
                        }
                    }
                }
            }
            if(accountId != null){
                Set<String> caRelationFieldSet = new Set<String>{'Id','Contact.Name','ContactId','Function__c','contact.Available_FTE__c','Contact.Sub_Group__c'};
                    List<AccountContactRelation> activeRelations = new SLT_AccountContactRelation().getAccountContactRelationsforOWFUsingSubGroupAndFunction(caRelationFieldSet, accountId, CON_OWF.CONTACT_TYPE, True, CON_OWF.FUNCTION_SET_FOR_TSL_RR, CON_OWF.TSL_RR_SET);
                for(AccountContactRelation acr:activeRelations){
                    ContactAlignedwithAccount.add(acr.ContactId);
                }                                                                                                                                             
            }
            String skillCertRatingCondition = ' pse__Skill_Certification__c IN :sObjectIdSet AND is_duplicate__c = false AND isPSEActiveResource__c = True AND Active__c = True AND pse__Resource__c != NULL '
                + ' AND pse__Resource__r.pse__Group__c != null '
                + ' AND pse__Resource__r.pse__Salesforce_User__r.IsActive = true '
                + ' AND (pse__Skill_Certification__r.pse__Type__c = \'' + CON_OWF.SKILL_TYPE_INDICATION + '\''
                + ' OR pse__Skill_Certification__r.pse__Type__c = \''  + CON_OWF.SKILL_TYPE_THERAPY_AREA + '\''
                + ' OR pse__Skill_Certification__r.pse__Type__c = \''  + CON_OWF.SKILL_TYPE_LINE_OF_BUSINESS + '\''
                + ' OR pse__Skill_Certification__r.pse__Type__c = \''  + CON_OWF.SKILL_TYPE_POTENTIAL_REGION + '\''
                + ' OR pse__Skill_Certification__r.pse__Type__c = \''  + CON_OWF.SKILL_TYPE_OPPORTUNITY_TYPE + '\''
                + ' OR pse__Skill_Certification__r.pse__Type__c = \''  + CON_OWF.SKILL_TYPE_GLOBAL_PROJECT_UNIT + '\''
                + ' OR pse__Skill_Certification__r.pse__Type__c = \''  + CON_OWF.SKILL_TYPE_OPPORTUNITY_LEVEL + '\')'
                + ' AND pse__Resource__r.Sub_Group__c IN: subGroupSet ';
            Set<String> skillCertRatingFieldSet = new Set<String>{'Id', 'pse__Resource__c',  'pse__Skill_Certification__c', 'pse__Rating__c', 'pse__Skill_Certification__r.pse__Type__c','pse__Skill_Certification__r.Name','pse__Resource__r.Sub_Group__c','pse__Resource__r.Region__c',
                'pse__Resource__r.Available_For_Triage_Flag__c','pse__Resource__r.pse__Is_Resource__c','pse__Resource__r.pse__Is_Resource_Active__c','pse__Skill_Certification__r.name','pse__Resource__r.Available_FTE__c', 'Active__c','pse__Resource__r.Top_Speed__c','pse__Resource__r.COUNT_Assignemnts_Accepted__c','pse__Resource__r.COUNT_Assignemnts_Pending__c'};
                    for(pse__Skill_Certification_Rating__c scr : new SLT_Skill_Certification_Rating(false,false).getSkillCertificationRatingsBySkills(skillToRSRsMap.keySet(), skillCertRatingCondition, skillCertRatingFieldSet,subGroupSet).values()) {
                        if(!skillIdToSkillCertiRatingsMap.containsKey(scr.pse__Skill_Certification__c)) {
                            skillIdToSkillCertiRatingsMap.put(scr.pse__Skill_Certification__c, new List<pse__Skill_Certification_Rating__c>());
                        }
                        skillIdToSkillCertiRatingsMap.get(scr.pse__Skill_Certification__c).add(scr);
                    }
            if(!skillToRSRsMap.IsEmpty() && !skillIdToSkillCertiRatingsMap.IsEmpty()) {
                Map<String, List<OWF_Assignment_Setting__mdt>> oasIdToOasMap = new Map<String, List<OWF_Assignment_Setting__mdt>>();
                Map<String, List<OWF_Assignment_Setting__mdt>> oasIdToOasMapForGBO = new Map<String, List<OWF_Assignment_Setting__mdt>>();
                
                Set<String> oasFieldSet = new Set<String>{'Id','Complexity_Score__c','Resource_Request_Type__c','Sub_Group__c', 'RFP_Ranking__c',
                    'Matching_Point_Indication__c', 'Matching_Point_Therapeutic_Area__c', 'Matching_Point_Line_of_Business__c', 'Matching_Point_Potential_Regions__c',
                    'Ignore_FTE_Threshold__c','Matching_Point_Threshold__c','Automation_backup_flag__c','Disable_availability_flag__c','Matching_Point_BD_Lead_Sub_Region__c','Matching_Point_Customer__c'};
                        String mapKey = '';
                        for(OWF_Assignment_Setting__mdt oasCMT : new SLT_OWF_Assignment_Setting(false, false).getOWFAssignmentSettingRecords(oasFieldSet)) {
                            /*String assSettingKey = oasCMT.Resource_Request_Type__c + + '~' + oasCMT.Sub_Group__c 
+ ((String.IsBlank(oasCMT.RFP_Ranking__c) || oasCMT.RFP_Ranking__c.trim() == '*') ? 'Null' : oasCMT.RFP_Ranking__c);*/
                             if(oasCMT.Sub_Group__c.contains(CON_OWF.RES_REQ_TYPE_IG_LEAD)){
                                    mapKey = oasCMT.Resource_Request_Type__c+'-'+oasCMT.RFP_Ranking__c;
                                    if(!oasIdToOasMapForGBO.containsKey(mapKey)) {
                                        oasIdToOasMapForGBO.put(mapKey,new List<OWF_Assignment_Setting__mdt>()); 
                                        oasIdToOasMapForGBO.get(mapKey).add(oasCMT); 
                                    } else{
                                        oasIdToOasMapForGBO.get(mapKey).add(oasCMT); 
                                    }
                             }
                            else{
                                if(!oasIdToOasMap.containsKey(oasCMT.Resource_Request_Type__c)) {
                                    oasIdToOasMap.put(oasCMT.Resource_Request_Type__c,new List<OWF_Assignment_Setting__mdt>()); 
                                    oasIdToOasMap.get(oasCMT.Resource_Request_Type__c).add(oasCMT); 
                                } 
                                else{
                                    oasIdToOasMap.get(oasCMT.Resource_Request_Type__c).add(oasCMT); 
                                } 
                            }
                        }
                
                pse__Resource_Request__c rr;
                String rrPotentialRegion;
                String selectedSkillCertificationRatingVal;
                String rcmKey;
                List<String> resourceRegion;
                for(Id skillId : skillToRSRsMap.keySet()) {
                    for(pse__Resource_Skill_Request__c rsr : skillToRSRsMap.get(skillId)) {
                        if(skillIdToSkillCertiRatingsMap.containsKey(skillId)) {
                            rr = resourceRequestsMap.get(rsr.pse__Resource_Request__c);
                            rrPotentialRegion = rr.Potential_Regions__c;
                            //OWF_Assignment_Setting__mdt matchedAssignmentSetting;
                            /*String assSettingKey = '';
if(rr.SubGroup__c != NULL && rr.Resource_Request_Type__c != NULL) {
assSettingKey = rr.Resource_Request_Type__c + '~' +  rr.SubGroup__c 
+(String.IsBlank(rr.Bid_History__r.RFP_Ranking__c) ? 'Null' : rr.Bid_History__r.RFP_Ranking__c);
}*/
                            /*if(String.IsNotBlank(assSettingKey) && oasIdToOasMap.containsKey(assSettingKey)) {
for(OWF_Assignment_Setting__mdt assSetting : oasIdToOasMap.get(assSettingKey)) {
if(rr.Complexity_Score_Total__c >=  assSetting.Complexity_Score__c) {
matchedAssignmentSetting = assSetting;
break;
}
}
}*/
                            List<OWF_Assignment_Setting__mdt> assignmentSettingmetadta = new List<OWF_Assignment_Setting__mdt>();
                           
                            if(rr.SubGroup__c == CON_OWF.RES_REQ_TYPE_IG_LEAD){
                                assignmentSettingmetadta = new List<OWF_Assignment_Setting__mdt>{getMatchingAssignmentSetting(rr,oasIdToOasMapForGBO)};
                            }
                            else{
                                assignmentSettingmetadta = oasIdToOasMap.get(rr.Resource_Request_Type__c);
                            }
                            for(OWF_Assignment_Setting__mdt oas : assignmentSettingmetadta) {
                                
                                if(rr.Complexity_Score_Total__c >= oas.Complexity_Score__c && rr.SubGroup__c == oas.Sub_Group__c
                                   && (rr.Bid_History__r.RFP_Ranking__c == '' ||
                                       (oas.RFP_Ranking__c != '*' && rr.Bid_History__r.RFP_Ranking__c == oas.RFP_Ranking__c) 
                                       || oas.RFP_Ranking__c == '*') ) {
                                           
                                           for(pse__Skill_Certification_Rating__c scr : skillIdToSkillCertiRatingsMap.get(skillId)) {
                                               selectedSkillCertificationRatingVal = scr.pse__Rating__c;
                                               //system.debug('ResourceId->' + scr.pse__Resource__c);
                                              // system.debug(rsr.pse__Resource_Request__r.SubGroup__c + '::'+scr.pse__Resource__r.Sub_Group__c
                                                       //     +'::'+scr.pse__Resource__r.Available_For_Triage_Flag__c+'::'+
                                                        //    scr.pse__Resource__r.pse__Is_Resource__c+'::'+scr.pse__Resource__r.pse__Is_Resource_Active__c);
                                               if(rsr.pse__Resource_Request__r.SubGroup__c == scr.pse__Resource__r.Sub_Group__c
                                                  && scr.pse__Resource__r.Available_For_Triage_Flag__c
                                                  && scr.pse__Resource__r.pse__Is_Resource__c && scr.pse__Resource__r.pse__Is_Resource_Active__c) {
                                                      
                                                      rcmKey = rsr.pse__Resource_Request__c+'-'+scr.pse__Resource__c;
                                                      
                                                      if(combinedKeyToMatchScoreMap.containsKey(rcmKey)) {
                                                          resCandidateMatchScoreRec = combinedKeyToMatchScoreMap.get(rcmKey);
                                                          resCandidateMatchScoreRec.skillIdSet.add(skillId);
                                                      }
                                                      else{
                                                          resCandidateMatchScoreRec = new ResourceCandidateMatchScore(rsr.pse__Resource_Request__c, scr.pse__Resource__c);
                                                          resCandidateMatchScoreRec.skillIdSet = new Set<Id>();
                                                          resCandidateMatchScoreRec.skillIdSet.add(skillId);
                                                          resCandidateMatchScoreRec.resourceSubGroup = scr.pse__Resource__r.Sub_Group__c;
                                                          resCandidateMatchScoreRec.resourceRequestType = rr.Resource_Request_Type__c;
                                                          resCandidateMatchScoreRec.availableFTECount = scr.pse__Resource__r.Available_FTE__c;
                                                          resCandidateMatchScoreRec.resReqObject = rr;
                                                          resCandidateMatchScoreRec.isIqviaBiotech = rr.pse__Opportunity__r.Is_this_IQVIA_Biotech__c;
                                                          resCandidateMatchScoreRec.lineOfBusiness = rr.pse__Opportunity__r.Line_of_Business__c;
                                                          resCandidateMatchScoreRec.projectStartDate = rr.pse__Project__r.pse__Start_Date__c;
                                                         // system.debug('scr.pse__Resource__r.Sub_Group__c?' + scr.pse__Resource__r.Sub_Group__c);
                                                          combinedKeyToMatchScoreMap.put(rcmKey,resCandidateMatchScoreRec);
                                                      }
                                                      
                                                      if(oas != null) {
                                                          resCandidateMatchScoreRec.assignmentSettingRecordId = oas.Id;
                                                          resCandidateMatchScoreRec.assignmentSettingRecord = oas;
                                                          if(rr.SubGroup__c == CON_OWF.RES_REQ_TYPE_TSL){
                                                             if(scr.pse__Skill_Certification__r.pse__Type__c == CON_OWF.SKILL_TYPE_OPPORTUNITY_LEVEL
                                                             &&(scr.pse__Skill_Certification__r.Name == CON_OWF.Core_SKILL || scr.pse__Skill_Certification__r.Name == CON_OWF.IQVIA_BIOTECH_SKILL)){
                                                                  resCandidateMatchScoreRec.hasMatchingOpportunityLevelSkill = true;
                                                              }
                                                              resCandidateMatchScoreRec.availableFTEpoint = scr.pse__Resource__r.Available_FTE__c * 100;
                                                              if(!contactAlignedwithAccount.isEmpty()){
                                                                  resCandidateMatchScoreRec.accountMatchScore = oas.Matching_Point_Customer__c * CON_OWF.AlignedWithAccount.get(contactAlignedwithAccount.contains(scr.pse__Resource__c));
				                                              }
                                                              if(rr.Bid_History__r.BD_Lead_Sub_Region__c != null && scr.pse__Resource__r.Region__c != null && rr.Bid_History__r.BD_Lead_Sub_Region__c != 'Japan'){
                                                                  resourceRegion = CON_OWF.regionMap.get(rr.Bid_History__r.BD_Lead_Sub_Region__c);
                                                                  if(resourceRegion[0]!=null && resourceRegion[0].contains(scr.pse__Resource__r.Region__c)){
                                                                      resCandidateMatchScoreRec.tslRegionPoint = oas.Matching_Point_BD_Lead_Sub_Region__c * 2;
                                                                      resCandidateMatchScoreRec.hasMatchingPR = true;
                                                                  }
                                                                  else if(resourceRegion[1]!=null && resourceRegion[1].contains(scr.pse__Resource__r.Region__c)){
                                                                      resCandidateMatchScoreRec.tslRegionPoint = oas.Matching_Point_BD_Lead_Sub_Region__c * 1;
                                                                      resCandidateMatchScoreRec.hasMatchingPR = true;
                                                                  }
                                                              }
                                                          }
                                                          if(rr.SubGroup__c == CON_OWF.RES_REQ_TYPE_IG_LEAD){
                                                              //resCandidateMatchScoreRec.availableFTEpoint = scr.pse__Resource__r.Available_FTE__c * 100;
                                                              if(rr.pse__Opportunity__r.FSP__c != CON_OWF.OWF_YES && rr.pse__Opportunity__r.Is_this_IQVIA_Biotech__c != CON_OWF.OWF_YES){
                                                                  resCandidateMatchScoreRec.hasMatchingOpportunityLevelSkill = true; 
                                                              }
                                                              if(rr.Bid_History__r.BD_Lead_Sub_Region__c != null && scr.pse__Resource__r.Region__c != null){
                                                                  resourceRegion = CON_OWF.GBO_BD_LEAD_REGION_TO_RESOURCE_REGION_MAP.get(rr.Bid_History__r.BD_Lead_Sub_Region__c);
                                                                  if(resourceRegion[0] != null && resourceRegion[0].contains(scr.pse__Resource__r.Region__c)){
                                                                      resCandidateMatchScoreRec.tslRegionPoint = 100;
                                                                      resCandidateMatchScoreRec.hasMatchingPR = true;
                                                                  }
                                                                  else if(resourceRegion[1] != null && resourceRegion[1].contains(scr.pse__Resource__r.Region__c)){
                                                                      resCandidateMatchScoreRec.tslRegionPoint = 50;
                                                                      resCandidateMatchScoreRec.hasMatchingPR = true;
                                                                  }
                                                                  else if(resourceRegion[2] != null && resourceRegion[2].contains(scr.pse__Resource__r.Region__c)){
                                                                      resCandidateMatchScoreRec.tslRegionPoint = 25;
                                                                      resCandidateMatchScoreRec.hasMatchingPR = true;
                                                                  }
                                                              }
                                                              
                                                              if(scr.pse__Resource__r.Top_Speed__c != null){
                                                                  resCandidateMatchScoreRec.availableFTEpoint = scr.pse__Resource__r.Top_Speed__c;
                                                                  if(scr.pse__Resource__r.COUNT_Assignemnts_Accepted__c != null){
                                                                      resCandidateMatchScoreRec.availableFTEpoint -= scr.pse__Resource__r.COUNT_Assignemnts_Accepted__c;
                                                                  }
                                                                  if(scr.pse__Resource__r.COUNT_Assignemnts_Pending__c != null){
                                                                      resCandidateMatchScoreRec.availableFTEpoint -= scr.pse__Resource__r.COUNT_Assignemnts_Pending__c;
                                                                  }
                                                                  
                                                              }
                                                              if(scr.pse__Skill_Certification__r.pse__Type__c == CON_OWF.SKILL_TYPE_OPPORTUNITY_LEVEL && ((rr.pse__Opportunity__r.FSP__c == CON_OWF.OWF_YES && CON_OWF.FSP == scr.pse__Skill_Certification__r.name) || (rr.pse__Opportunity__r.Is_this_IQVIA_Biotech__c == CON_OWF.OWF_YES && CON_OWF.IQVIA_BIOTECH_SKILL == scr.pse__Skill_Certification__r.name))){
                                                                  resCandidateMatchScoreRec.hasMatchingOpportunityLevelSkill = true;
                                                                  resCandidateMatchScoreRec.opportunityLevelScore = CON_OWF.skillRatingValueMap.get(selectedSkillCertificationRatingVal.trim());
                                                              }
                                                              if(rr.Bid_History__r.Bid_History_Related_Opportunity__r.Global_project_unit__c != CON_OWF.GPU_MEDTECH_CLINICAL_SOULTIONS){
                                                                  resCandidateMatchScoreRec.hasGlobalProjectUnitSkill = true;
                                                          	  }
                                                              else if (scr.pse__Skill_Certification__r.pse__Type__c == CON_OWF.SKILL_TYPE_GLOBAL_PROJECT_UNIT && rr.Bid_History__r.Bid_History_Related_Opportunity__r.Global_project_unit__c == scr.pse__Skill_Certification__r.name){
                                                                  resCandidateMatchScoreRec.hasGlobalProjectUnitSkill = true;
                                                                  resCandidateMatchScoreRec.globalProjectUnitScore = CON_OWF.skillRatingValueMap.get(selectedSkillCertificationRatingVal.trim());
                                                              }
                                                              if(scr.pse__Skill_Certification__r.pse__Type__c == CON_OWF.SKILL_TYPE_OPPORTUNITY_TYPE && rr.Bid_History__r.Opportunity_Type__c == scr.pse__Skill_Certification__r.name){
                                                                  resCandidateMatchScoreRec.hasMatchingopportunityTypeCertificate = true;
                                                                  resCandidateMatchScoreRec.opportunityTypeScore = CON_OWF.skillRatingValueMap.get(selectedSkillCertificationRatingVal.trim());
                                                              }
                                                              if(scr.pse__Skill_Certification__r.pse__Type__c == CON_OWF.SKILL_TYPE_LINE_OF_BUSINESS && scr.pse__Skill_Certification__r.Name == rsr.pse__Resource_Request__r.pse__Opportunity__r.Line_of_Business__c){
                                                                      resCandidateMatchScoreRec.hasMatchingLineOfBusinessCertificate = true;
                                                                  resCandidateMatchScoreRec.lineOfBusinessScore = CON_OWF.skillRatingValueMap.get(selectedSkillCertificationRatingVal.trim());
                                                              }
                                                          }
                                                          
                                                          if(String.IsNotBlank(selectedSkillCertificationRatingVal) && CON_OWF.skillRatingValueMap.containsKey(selectedSkillCertificationRatingVal.trim())) {
                                                              if(scr.pse__Skill_Certification__r.pse__Type__c == CON_OWF.SKILL_TYPE_INDICATION){                                                                 
                                                                  resCandidateMatchScoreRec.indicationScore = oas.Matching_Point_Indication__c * CON_OWF.skillRatingValueMap.get(selectedSkillCertificationRatingVal.trim());
                                                              }
                                                              else if(scr.pse__Skill_Certification__r.pse__Type__c == CON_OWF.SKILL_TYPE_THERAPY_AREA){
                                                                  if( rsr.pse__Resource_Request__r.SubGroup__c==CON_OWF.RES_REQ_TYPE_TSL && scr.pse__Skill_Certification__r.Name == rsr.pse__Resource_Request__r.pse__Opportunity__r.TherapyArea__c){
                                                                      resCandidateMatchScoreRec.hasMatchingTherapyAreaCertificate = true;
                                                                  }
                                                                  resCandidateMatchScoreRec.therapyAreaScore = oas.Matching_Point_Therapeutic_Area__c * CON_OWF.skillRatingValueMap.get(selectedSkillCertificationRatingVal.trim());
                                                              }
                                                              else if(scr.pse__Skill_Certification__r.pse__Type__c == CON_OWF.SKILL_TYPE_LINE_OF_BUSINESS && rr.SubGroup__c != CON_OWF.RES_REQ_TYPE_IG_LEAD){
                                                                  if( rsr.pse__Resource_Request__r.SubGroup__c==CON_OWF.RES_REQ_TYPE_TSL && scr.pse__Skill_Certification__r.Name == rsr.pse__Resource_Request__r.pse__Opportunity__r.Line_of_Business__c){
                                                                      resCandidateMatchScoreRec.hasMatchingLineOfBusinessCertificate = true;
                                                                  }
                                                                  resCandidateMatchScoreRec.lineOfBusinessScore = oas.Matching_Point_Line_of_Business__c * CON_OWF.skillRatingValueMap.get(selectedSkillCertificationRatingVal.trim());
                                                              }
                                                              else if(scr.pse__Skill_Certification__r.pse__Type__c == CON_OWF.SKILL_TYPE_POTENTIAL_REGION && rr.SubGroup__c != CON_OWF.RES_REQ_TYPE_IG_LEAD) {
                                                                  resCandidateMatchScoreRec.potentialRegionScore = oas.Matching_Point_Potential_Regions__c * CON_OWF.skillRatingValueMap.get(selectedSkillCertificationRatingVal.trim());
                                                                  // added in 2163
                                                                  //System.debug(LoggingLevel.INFO, '***** printing RSR line 174 values ***** ' + 'rrPotentialRegion ' + rrPotentialRegion + 'scr.pse__Skill_Certification__r.name ' + scr.pse__Skill_Certification__r.name + 'bdLeadToPRMap ' 
                                                                   //            + bdLeadToPRMap + 'rr.BD_Lead_Sub_Region__c ' + rr.BD_Lead_Sub_Region__c);
                                                                  if(rrPotentialRegion.contains(scr.pse__Skill_Certification__r.name)
                                                                     || (rrPotentialRegion == 'Global' && bdLeadToPRMap.get(rr.BD_Lead_Sub_Region__c) == scr.pse__Skill_Certification__r.name)) {
                                                                         
                                                                          if(rsr.pse__Resource_Request__r.SubGroup__c != CON_OWF.RES_REQ_TYPE_TSL){
                                                                         		resCandidateMatchScoreRec.hasMatchingPR = true;
                                                                             }
                                                                         resCandidateMatchScoreRec.hasRequiredRFPBidComplexity = true;
                                                                         
                                                                     }
                                                              }
                                                              
                                                          }
                                                          
                                                          resCandidateMatchScoreRec.matchScore = resCandidateMatchScoreRec.therapyAreaScore + 
                                                              resCandidateMatchScoreRec.indicationScore + 
                                                              resCandidateMatchScoreRec.potentialRegionScore + 
                                                              resCandidateMatchScoreRec.lineOfBusinessScore+ 
                                                              resCandidateMatchScoreRec.accountMatchScore+
                                                              resCandidateMatchScoreRec.tslRegionPoint+
                                                              resCandidateMatchScoreRec.availableFTEpoint;
                                                       //   system.debug('Contact?' + resCandidateMatchScoreRec.contactId);
                                                        //  system.debug('MachScore?' + resCandidateMatchScoreRec.matchScore);
                                                         // system.debug('resCandidateMatchScoreRec' + resCandidateMatchScoreRec.therapyAreaScore + '::'+ resCandidateMatchScoreRec.indicationScore + '::' + 
                                                           //            resCandidateMatchScoreRec.potentialRegionScore + '::' + resCandidateMatchScoreRec.lineOfBusinessScore + '::::' + resCandidateMatchScoreRec.matchScore);
                                                      }
													      if(rr.SubGroup__c == CON_OWF.RES_REQ_TYPE_IG_LEAD){
                                                              resCandidateMatchScoreRec.matchScore = resCandidateMatchScoreRec.matchScore + resCandidateMatchScoreRec.opportunityTypeScore +  resCandidateMatchScoreRec.opportunityLevelScore +  resCandidateMatchScoreRec.globalProjectUnitScore;
                                                          }

                                                      resourceCandidateMatchScoreList.add(resCandidateMatchScoreRec);
                                                  }
                                           }
                                       }
                            }                              
                        }
                    }
                }
            }
        }
        return resourceCandidateMatchScoreList;
    }
    
    public static  List<ResourceCandidateMatchScore> createResourceCandidateMatchScoreForGBO(List<pse__Resource_Skill_Request__c> resourceSkillRequestList) {
        List<ResourceCandidateMatchScore> resourceCandidateMatchScoreList = new List<ResourceCandidateMatchScore>();
        Set<Id> resourceRequestIdsSet = new Set<Id>();
        
        for(pse__Resource_Skill_Request__c rsr : resourceSkillRequestList) {
            if(rsr.pse__Resource_Request__c != null) {
                resourceRequestIdsSet.add(rsr.pse__Resource_Request__c);
            }
        }
        if(resourceRequestIdsSet.size() > 0) {
            resourceCandidateMatchScoreList = validateAndCreateCandidateMatchScoresForGBO(resourceRequestIdsSet);
        }
        return resourceCandidateMatchScoreList;
    }
    /*public static List<ResourceCandidateMatchScore> createResourceCandidateMatchForRegionalAnaylytics(List<pse__Resource_Skill_Request__c> resourceSkillRequestList)
{
List<ResourceCandidateMatchScore> resourceCandidateMatchScoreList = new List<ResourceCandidateMatchScore>();
Set<Id> resourceRequestIdsSet = new Set<Id>();

for(pse__Resource_Skill_Request__c rsr : resourceSkillRequestList) {
if(rsr.pse__Resource_Request__c != null ) {
resourceRequestIdsSet.add(rsr.pse__Resource_Request__c);
}
}
if(resourceRequestIdsSet.size() > 0) {
resourceCandidateMatchScoreList = validateAndCreateCandidateMatchScoresRegionalAnalyticsSubgroup(resourceRequestIdsSet);
}
return resourceCandidateMatchScoreList;
}
*/
    
    public static List<ResourceCandidateMatchScore> createResourceCandidateMatchScoreForTSSU(List<pse__Resource_Skill_Request__c> resourceSkillRequestList)
    {
        List<ResourceCandidateMatchScore> resourceCandidateMatchScoreList = new List<ResourceCandidateMatchScore>();
        Set<Id> resourceRequestIdsSet = new Set<Id>();
        
        for(pse__Resource_Skill_Request__c rsr : resourceSkillRequestList) {
            if(rsr.pse__Resource_Request__c != null ) {
                resourceRequestIdsSet.add(rsr.pse__Resource_Request__c);
            }
        }
        if(resourceRequestIdsSet.size() > 0) {
            resourceCandidateMatchScoreList = validateAndCreateCandidateMatchScoresForTSSU(resourceRequestIdsSet);      
            
        }
        return resourceCandidateMatchScoreList;
    }
    /*   private static List<ResourceCandidateMatchScore> validateAndCreateCandidateMatchScoresRegionalAnalyticsSubgroup(Set<Id> resourceRequestIdsSet){
List<ResourceCandidateMatchScore> resourceCandidateMatchScoreList = new List<ResourceCandidateMatchScore>();
Map<Id, pse__Resource_Request__c> resourceRequestsMap = new Map<Id, pse__Resource_Request__c>();
Set<Id> skillIdSet = new Set<Id>();
Map<Id, List<pse__Skill_Certification_Rating__c>> skillIdToSkillCertiRatingsMap = new Map<Id, List<pse__Skill_Certification_Rating__c>>();
Map<String,ResourceCandidateMatchScore> combinedKeyToMatchScoreMap = new Map<String,ResourceCandidateMatchScore>();
ResourceCandidateMatchScore resCandidateMatchScoreRec;
Id SkillId;

//Fetching Resource_Requests with all ResourceSkillRequests and preparing a map b/w resource_request and list of resource_skill_requests
String resReqCondition = 'Id IN :sObjectIdSet And RecordType.DeveloperName = \'' + CON_OWF.OWF_RESOURCE_REQUEST_RECORD_TYPE_NAME + '\' And SubGroup__c in ('+ 
'\'' + CON_OWF.RES_REQ_TYPE_Global_Analytics +'\'' +')';        

Set<String> resRequestFieldSet = new Set<String>{'Id','Regional_Analytics_Country__c','Workload_Ranking__c', 'pse__Resource__c', 'Resource_Request_Type__c', 'SubGroup__c', 'Complexity_Score_Total__c', 'Bid_History__r.RFP_Ranking__c','Potential_Regions__c','Name','Bid_History__r.Bid_History_Related_Opportunity__r.Potential_Regions__c','BD_Lead_Sub_Region__c'};
Set<String> resSkillRequestFieldSet = new Set<String>{'Id', 'pse__Resource_Request__c', 'pse__Skill_Certification__c', 'pse__Skill_Certification__r.pse__Type__c','pse__Resource_Request__r.SubGroup__c'};
String resSkillReqCondition =  'pse__Resource_Request__c IN : sObjectIdSet';
resourceRequestsMap = new SLT_Resource_Request(false,false).selectByIdWithResReqsAndRSRs(resourceRequestIdsSet, resReqCondition, resRequestFieldSet, resSkillRequestFieldSet, resSkillReqCondition);
//Fetching all Skill_Certification_Ratings and preparing a map b/w resource and list of Skill_Certification_Ratings
if(!resourceRequestsMap.IsEmpty()) {
for(pse__Resource_Request__c resourceRequest : resourceRequestsMap.values()) {
if(resourceRequest.pse__Resource_Skill_Requests__r.size() > 0) {
for(pse__Resource_Skill_Request__c rsr: resourceRequest.pse__Resource_Skill_Requests__r) {
if(rsr.pse__Skill_Certification__c != NULL) {
if(!skillIdSet.contains(rsr.pse__Skill_Certification__c)) {
skillIdSet.add(rsr.pse__Skill_Certification__c);
}
}
}
}
}

String skillCertRatingCondition = ' pse__Skill_Certification__c IN :sObjectIdSet AND is_duplicate__c = false AND isPSEActiveResource__c = True AND pse__Resource__c != NULL '
+ ' AND pse__Resource__r.pse__Group__c != null '
+ ' AND pse__Resource__r.pse__Salesforce_User__r.IsActive = true '
+ ' AND (pse__Skill_Certification__r.pse__Type__c = \'' + CON_OWF.SKILL_TYPE_GLOBAL_ANALYTICS_COUNTRY + '\')';

System.debug('###skillid '+ skillIdSet);
System.debug('###skillCond '+skillCertRatingCondition);        
Set<String> skillCertRatingFieldSet = new Set<String>{'Id', 'pse__Resource__c',  'pse__Skill_Certification__c', 'pse__Rating__c', 'pse__Skill_Certification__r.pse__Type__c','pse__Resource__r.Sub_Group__c','pse__Resource__r.Available_For_Triage_Flag__c','pse__Resource__r.pse__Is_Resource__c','pse__Resource__r.pse__Is_Resource_Active__c','pse__Resource__r.Name','pse__Skill_Certification__r.name','RFP_Ranking__c'};
for(pse__Skill_Certification_Rating__c scr : new SLT_Skill_Certification_Rating(false,false).getSkillCertificationRatingsBySkills(skillIdSet, skillCertRatingCondition, skillCertRatingFieldSet).values()) {
if(!skillIdToSkillCertiRatingsMap.containsKey(scr.pse__Skill_Certification__c)) {
skillIdToSkillCertiRatingsMap.put(scr.pse__Skill_Certification__c, new List<pse__Skill_Certification_Rating__c>());
}
skillIdToSkillCertiRatingsMap.get(scr.pse__Skill_Certification__c).add(scr);
}

for(pse__Resource_Request__c resourceRequest : resourceRequestsMap.values()) {
if(resourceRequest.pse__Resource_Skill_Requests__r.size() > 0 ) {
for(pse__Resource_Skill_Request__c rsr: resourceRequest.pse__Resource_Skill_Requests__r)  {
skillId = rsr.pse__Skill_Certification__c;
if(skillIdToSkillCertiRatingsMap.get(skillId) != null){
for(pse__Skill_Certification_Rating__c scr : skillIdToSkillCertiRatingsMap.get(skillId)) {
if(rsr.pse__Resource_Request__r.SubGroup__c == scr.pse__Resource__r.Sub_Group__c
&& scr.pse__Resource__r.Available_For_Triage_Flag__c
&& scr.pse__Resource__r.pse__Is_Resource__c && scr.pse__Resource__r.pse__Is_Resource_Active__c) {
String rcmKey = rsr.pse__Resource_Request__c+'-'+scr.pse__Resource__c;
if(combinedKeyToMatchScoreMap.containsKey(rcmKey)) {
resCandidateMatchScoreRec = combinedKeyToMatchScoreMap.get(rcmKey);
resCandidateMatchScoreRec.skillIdSet.add(skillId);
} else{
resCandidateMatchScoreRec = new ResourceCandidateMatchScore(rsr.pse__Resource_Request__c, scr.pse__Resource__c);
resCandidateMatchScoreRec.skillIdSet = new Set<Id>();
resCandidateMatchScoreRec.skillIdSet.add(skillId);
resCandidateMatchScoreRec.resourceName = scr.pse__Resource__r.Name;
resCandidateMatchScoreRec.resReqObject = resourceRequest;
combinedKeyToMatchScoreMap.put(rcmKey,resCandidateMatchScoreRec);
}
}
}
}
}
}
}
}
return combinedKeyToMatchScoreMap.values();
}
*/
    
    private static List<ResourceCandidateMatchScore> validateAndCreateCandidateMatchScoresForTSSU(Set<Id> resourceRequestIdsSet)
    {
        List<ResourceCandidateMatchScore> resourceCandidateMatchScoreList = new List<ResourceCandidateMatchScore>();
        Map<Id, pse__Resource_Request__c> resourceRequestsMap = new Map<Id, pse__Resource_Request__c>();
        Set<Id> skillIdSet = new Set<Id>();
        Set<Id> contactAlignedwithAccount=new Set<Id>();
        Map<Id, List<pse__Skill_Certification_Rating__c>> skillIdToSkillCertiRatingsMap = new Map<Id, List<pse__Skill_Certification_Rating__c>>();
        Map<String,ResourceCandidateMatchScore> combinedKeyToMatchScoreMap = new Map<String,ResourceCandidateMatchScore>();
        ResourceCandidateMatchScore resCandidateMatchScoreRec;
        Id SkillId;
        Set<String> subGroupSet = new Set<String>();
        
        //Fetching Resource_Requests with all ResourceSkillRequests and preparing a map b/w resource_request and list of resource_skill_requests
        String resReqCondition = 'Id IN :sObjectIdSet And RecordType.DeveloperName = \'' + CON_OWF.OWF_RESOURCE_REQUEST_RECORD_TYPE_NAME + '\' And SubGroup__c in ('+ 
            '\'' + CON_OWF.RES_REQ_TYPE_TSL +'\',' +
            '\'' + CON_OWF.RES_REQ_TYPE_MEDICAL +'\',' +
            '\'' + CON_OWF.RES_REQ_TYPE_THERAPEUTIC_ANALYTICS_LEAD  +'\',' +
            '\'' + CON_OWF.RES_REQ_TYPE_Site_Analytics +'\',' +
            '\'' + CON_OWF.RES_REQ_TYPE_Feasibility_Analytics +'\',' +
            '\'' + CON_OWF.RES_REQ_TYPE_GLOBAL_ANALYTICS +'\',' +
            '\'' + CON_OWF.RES_REQ_TYPE_CMSVC +'\',' +
            '\'' + CON_OWF.RES_REQ_TYPE_DSB_DCT +'\',' +
            '\'' + CON_OWF.RES_REQ_TYPE_RW_AIM +'\',' +
            '\'' + CON_OWF.RES_REQ_TYPE_SNP_PRODUCT_SPECIALIST +'\'' +
            ')';
        Set<String> resRequestFieldSet = new Set<String>{'Id','Workload_Ranking__c', 'pse__Resource__c', 'Resource_Request_Type__c', 'SubGroup__c', 'Complexity_Score_Total__c', 'Bid_History__r.RFP_Ranking__c','Potential_Regions__c','Name','Account__c','Bid_History__r.BD_Lead_Sub_Region__c'
            ,'Bid_History__r.Bid_History_Related_Opportunity__r.Potential_Regions__c','pse__Opportunity__r.Line_of_Business__c','pse__Opportunity__r.Is_this_IQVIA_Biotech__c'
            ,'BD_Lead_Sub_Region__c','Regional_Analytics_Country__c','pse__Project__r.pse__Start_Date__c'};
                Set<String> resSkillRequestFieldSet = new Set<String>{'Id', 'pse__Resource_Request__c', 'pse__Skill_Certification__c', 'pse__Skill_Certification__r.pse__Type__c','pse__Resource_Request__r.SubGroup__c','pse__Resource_Request__r.pse__Opportunity__r.Line_of_Business__c','pse__Resource_Request__r.pse__Opportunity__r.TherapyArea__c'};
                    String resSkillReqCondition =  'pse__Resource_Request__c IN : sObjectIdSet';
        resourceRequestsMap = new SLT_Resource_Request(false,false).selectByIdWithResReqsAndRSRs(resourceRequestIdsSet, resReqCondition, resRequestFieldSet, resSkillRequestFieldSet, resSkillReqCondition);
        
        //Get map of BD Lead Sub Region to Potential Region
        Set<String> potentialRegToBDLeadMappingFieldSet = new Set<String>{'Id','Potential_Region__c','BD_Lead_Sub_Region__c'};
            Map<String,String> bdLeadToPRMap = new Map<String,String>();
        for(Potential_Region_To_BD_Lead_Mapping__mdt mapping : 
            new SLT_Potential_Region_To_BD_Lead_Mapping(false,false).getPotentialRegionToBDLeadMappings(potentialRegToBDLeadMappingFieldSet)) {
                bdLeadToPRMap.put(mapping.BD_Lead_Sub_Region__c,mapping.Potential_Region__c);
            }
        Id accountId;
        //Fetching all Skill_Certification_Ratings and preparing a map b/w resource and list of Skill_Certification_Ratings
        if(!resourceRequestsMap.IsEmpty()) {
            for(pse__Resource_Request__c resourceRequest : resourceRequestsMap.values()) {
                subGroupSet.add(resourceRequest.SubGroup__c);
                if(resourceRequest.SubGroup__c == CON_OWF.RES_REQ_TYPE_TSL){
                    accountId = resourceRequest.Account__c;
                }
                if(resourceRequest.pse__Resource_Skill_Requests__r.size() > 0) {
                    for(pse__Resource_Skill_Request__c rsr: resourceRequest.pse__Resource_Skill_Requests__r) {
                        if(rsr.pse__Skill_Certification__c != NULL) {
                            if(!skillIdSet.contains(rsr.pse__Skill_Certification__c)) {
                                skillIdSet.add(rsr.pse__Skill_Certification__c);
                            }
                        }
                    }
                }
            }
            if(accountId != null){
                Set<String> caRelationFieldSet = new Set<String>{'Id','Contact.Name','ContactId','Function__c','contact.Available_FTE__c','Contact.Sub_Group__c'};
                    List<AccountContactRelation> activeRelations = new SLT_AccountContactRelation().getAccountContactRelationsforOWFUsingSubGroupAndFunction(caRelationFieldSet, accountId, CON_OWF.CONTACT_TYPE, True, CON_OWF.FUNCTION_SET_FOR_TSL_RR, CON_OWF.TSL_RR_SET);
                for(AccountContactRelation acr:activeRelations){
                    ContactAlignedwithAccount.add(acr.ContactId);
                }                                                                                                                                             
            }
            String skillCertRatingCondition = ' pse__Skill_Certification__c IN :sObjectIdSet AND is_duplicate__c = false AND isPSEActiveResource__c = True AND Active__c = True AND pse__Resource__c != NULL '
                + ' AND pse__Resource__r.pse__Group__c != null '
                + ' AND pse__Resource__r.pse__Salesforce_User__r.IsActive = true '
                + ' AND (pse__Skill_Certification__r.pse__Type__c = \'' + CON_OWF.SKILL_TYPE_INDICATION + '\''
                + ' OR pse__Skill_Certification__r.pse__Type__c = \''  + CON_OWF.SKILL_TYPE_THERAPY_AREA + '\''
                + ' OR pse__Skill_Certification__r.pse__Type__c = \''  + CON_OWF.SKILL_TYPE_LINE_OF_BUSINESS + '\''
                + ' OR pse__Skill_Certification__r.pse__Type__c = \''  + CON_OWF.SKILL_TYPE_GLOBAL_ANALYTICS_COUNTRY + '\''
                + ' OR pse__Skill_Certification__r.pse__Type__c = \''  + CON_OWF.SKILL_TYPE_POTENTIAL_REGION + '\''
                + ' OR pse__Skill_Certification__r.pse__Type__c = \''  + CON_OWF.SKILL_TYPE_OPPORTUNITY_LEVEL + '\')'
                + ' AND pse__Resource__r.Sub_Group__c IN: subGroupSet';
            
            Set<String> skillCertRatingFieldSet = new Set<String>{'Id', 'pse__Resource__c',  'pse__Skill_Certification__c', 'pse__Rating__c', 'pse__Skill_Certification__r.pse__Type__c','pse__Resource__r.Sub_Group__c','pse__Resource__r.Available_For_Triage_Flag__c','pse__Resource__r.pse__Is_Resource__c','pse__Resource__r.pse__Is_Resource_Active__c','pse__Resource__r.Name','pse__Skill_Certification__r.name','RFP_Ranking__c','pse__Resource__r.Available_FTE__c','pse__Skill_Certification__r.Name','pse__Resource__r.Region__c', 'Active__c'};
                for(pse__Skill_Certification_Rating__c scr : new SLT_Skill_Certification_Rating(false,false).getSkillCertificationRatingsBySkills(skillIdSet, skillCertRatingCondition, skillCertRatingFieldSet,subGroupSet).values()) {
                    if(!skillIdToSkillCertiRatingsMap.containsKey(scr.pse__Skill_Certification__c)) {
                        skillIdToSkillCertiRatingsMap.put(scr.pse__Skill_Certification__c, new List<pse__Skill_Certification_Rating__c>());
                    }
                    skillIdToSkillCertiRatingsMap.get(scr.pse__Skill_Certification__c).add(scr);
                }
            
            
            if(!skillIdSet.IsEmpty() && !skillIdToSkillCertiRatingsMap.IsEmpty()) {
                Map<String, List<OWF_Assignment_Setting__mdt>> oasIdToOasMap = new Map<String, List<OWF_Assignment_Setting__mdt>>();
                Set<String> oasFieldSet = new Set<String>{'Id','Workload_Ranking__c','Complexity_Score__c','Resource_Request_Type__c','Sub_Group__c', 'RFP_Ranking__c','Matching_Point_Customer__c','Matching_Point_BD_Lead_Sub_Region__c',
                    'Matching_Point_Indication__c', 'Matching_Point_Therapeutic_Area__c', 'Matching_Point_Line_of_Business__c', 'Matching_Point_Potential_Regions__c','Ignore_FTE_Threshold__c','Matching_Point_Threshold__c'
                    ,'Automation_backup_flag__c','Disable_availability_flag__c','Matching_Point_Grade_Level__c','Suggested_FTE__c'};
                String mapKey;        
                        for(OWF_Assignment_Setting__mdt oasCMT : new SLT_OWF_Assignment_Setting(false, false).getOWFAssignmentSettingRecords(oasFieldSet)) {
                            if(CON_OWF.TSSU_Subgroup.contains(oasCMT.Sub_Group__c)){
                                mapKey = oasCMT.Resource_Request_Type__c+'-'+oasCMT.Sub_Group__c + oasCMT.Workload_Ranking__c;
                                if(!oasIdToOasMap.containsKey(mapKey)) {
                                    oasIdToOasMap.put(mapKey,new List<OWF_Assignment_Setting__mdt>()); 
                                    oasIdToOasMap.get(mapKey).add(oasCMT); 
                                } else{
                                    oasIdToOasMap.get(mapKey).add(oasCMT); 
                                }
                                
                            }
                        }
                OWF_Assignment_Setting__mdt matchedAssignmentSetting;
                String rrPotentialRegion;
                String selectedSkillCertificationRatingVal;
                String rcmKey;
                List<String> resourceRegion;
                for(pse__Resource_Request__c resourceRequest : resourceRequestsMap.values()) {
                    if(resourceRequest.pse__Resource_Skill_Requests__r.size() > 0 ) {
                        matchedAssignmentSetting = getMatchingAssignmentSettingForTSSU(resourceRequest,oasIdToOasMap);
                        if(matchedAssignmentSetting != null) {
                            for(pse__Resource_Skill_Request__c rsr: resourceRequest.pse__Resource_Skill_Requests__r)  {
                                skillId = rsr.pse__Skill_Certification__c;
                                if(skillIdToSkillCertiRatingsMap.containsKey(skillId)) {
                                    rrPotentialRegion = resourceRequest.Bid_History__r.Bid_History_Related_Opportunity__r.Potential_Regions__c;                            
                                    if(resourceRequest.Complexity_Score_Total__c >= matchedAssignmentSetting.Complexity_Score__c && resourceRequest.SubGroup__c == matchedAssignmentSetting.Sub_Group__c 
                                      ) {
                                          for(pse__Skill_Certification_Rating__c scr : skillIdToSkillCertiRatingsMap.get(skillId)) {
                                              selectedSkillCertificationRatingVal = scr.pse__Rating__c;
                                              if(rsr.pse__Resource_Request__r.SubGroup__c == scr.pse__Resource__r.Sub_Group__c
                                                 && scr.pse__Resource__r.Available_For_Triage_Flag__c
                                                 && scr.pse__Resource__r.pse__Is_Resource__c && scr.pse__Resource__r.pse__Is_Resource_Active__c) {
                                                     rcmKey = rsr.pse__Resource_Request__c+'-'+scr.pse__Resource__c;
                                                     if(combinedKeyToMatchScoreMap.containsKey(rcmKey)) {
                                                         resCandidateMatchScoreRec = combinedKeyToMatchScoreMap.get(rcmKey);
                                                         resCandidateMatchScoreRec.skillIdSet.add(skillId);
                                                     } else{
                                                         resCandidateMatchScoreRec = new ResourceCandidateMatchScore(rsr.pse__Resource_Request__c, scr.pse__Resource__c);
                                                         resCandidateMatchScoreRec.skillIdSet = new Set<Id>();
                                                         resCandidateMatchScoreRec.skillIdSet.add(skillId);
                                                         resCandidateMatchScoreRec.resourceName = scr.pse__Resource__r.Name;
                                                         resCandidateMatchScoreRec.resourceRequestType = resourceRequest.Resource_Request_Type__c;
                                                         resCandidateMatchScoreRec.projectStartDate = resourceRequest.pse__Project__r.pse__Start_Date__c;
                                                         resCandidateMatchScoreRec.resourceSubGroup = scr.pse__Resource__r.Sub_Group__c;
                                                         resCandidateMatchScoreRec.lineOfBusiness = resourceRequest.pse__Opportunity__r.Line_of_Business__c;
                                                         resCandidateMatchScoreRec.isIqviaBiotech = resourceRequest.pse__Opportunity__r.Is_this_IQVIA_Biotech__c;
                                                         combinedKeyToMatchScoreMap.put(rcmKey,resCandidateMatchScoreRec);
                                                     }
                                                     resCandidateMatchScoreRec.assignmentSettingRecordId = matchedAssignmentSetting.Id;
                                                     resCandidateMatchScoreRec.assignmentSettingRecord = matchedAssignmentSetting;
                                                     if(scr.pse__Skill_Certification__r.pse__Type__c == CON_OWF.SKILL_TYPE_OPPORTUNITY_LEVEL
                                                     &&(scr.pse__Skill_Certification__r.Name == CON_OWF.Core_SKILL || scr.pse__Skill_Certification__r.Name == CON_OWF.IQVIA_BIOTECH_SKILL)){
                                                         resCandidateMatchScoreRec.hasMatchingOpportunityLevelSkill = true;
                                                     }
                                                     if( resourceRequest.SubGroup__c == CON_OWF.RES_REQ_TYPE_TSL && (resourceRequest.Resource_Request_Type__c == 'Clinical' || resourceRequest.Resource_Request_Type__c == 'Clinical - Ballpark')){
                                                         resCandidateMatchScoreRec.availableFTEpoint = scr.pse__Resource__r.Available_FTE__c * 100;
                                                         if(!contactAlignedwithAccount.isEmpty()){
                                                             resCandidateMatchScoreRec.accountMatchScore = matchedAssignmentSetting.Matching_Point_Customer__c * CON_OWF.AlignedWithAccount.get(contactAlignedwithAccount.contains(scr.pse__Resource__c));
                                                         }
                                                         if(resourceRequest.Bid_History__r.BD_Lead_Sub_Region__c != null && scr.pse__Resource__r.Region__c != null && resourceRequest.Bid_History__r.BD_Lead_Sub_Region__c != 'Japan'){
                                                             resourceRegion = CON_OWF.regionMap.get(resourceRequest.Bid_History__r.BD_Lead_Sub_Region__c);
                                                             if(resourceRegion[0]!=null && resourceRegion[0]!=null && resourceRegion[0].contains(scr.pse__Resource__r.Region__c)){
                                                                 resCandidateMatchScoreRec.tslRegionPoint = matchedAssignmentSetting.Matching_Point_BD_Lead_Sub_Region__c * 2;
                                                                 resCandidateMatchScoreRec.hasMatchingPR = true;
                                                             }
                                                             else if(resourceRegion[1]!=null && resourceRegion[1]!=null && resourceRegion[1].contains(scr.pse__Resource__r.Region__c)){
                                                                 resCandidateMatchScoreRec.tslRegionPoint = matchedAssignmentSetting.Matching_Point_BD_Lead_Sub_Region__c * 1;
                                                                 resCandidateMatchScoreRec.hasMatchingPR = true;
                                                             }
                                                         }
                                                     }
                                                     
                                                     if(String.IsNotBlank(selectedSkillCertificationRatingVal) && CON_OWF.skillRatingValueMap.containsKey(selectedSkillCertificationRatingVal.trim())) {
                                                         if(scr.pse__Skill_Certification__r.pse__Type__c == CON_OWF.SKILL_TYPE_INDICATION)
                                                             resCandidateMatchScoreRec.indicationScore = matchedAssignmentSetting.Matching_Point_Indication__c * CON_OWF.skillRatingValueMap.get(selectedSkillCertificationRatingVal.trim());
                                                         else if(scr.pse__Skill_Certification__r.pse__Type__c == CON_OWF.SKILL_TYPE_THERAPY_AREA){
                                                             if( resourceRequest.SubGroup__c==CON_OWF.RES_REQ_TYPE_TSL && scr.pse__Skill_Certification__r.Name == rsr.pse__Resource_Request__r.pse__Opportunity__r.TherapyArea__c){
                                                                 resCandidateMatchScoreRec.hasMatchingTherapyAreaCertificate = true;
                                                             }
                                                             resCandidateMatchScoreRec.therapyAreaScore = matchedAssignmentSetting.Matching_Point_Therapeutic_Area__c * CON_OWF.skillRatingValueMap.get(selectedSkillCertificationRatingVal.trim());
                                                         }
                                                         else if(scr.pse__Skill_Certification__r.pse__Type__c == CON_OWF.SKILL_TYPE_LINE_OF_BUSINESS){
                                                             if( resourceRequest.SubGroup__c==CON_OWF.RES_REQ_TYPE_TSL && scr.pse__Skill_Certification__r.Name == rsr.pse__Resource_Request__r.pse__Opportunity__r.Line_Of_Business__c){
                                                                 resCandidateMatchScoreRec.hasMatchingLineOfBusinessCertificate = true;
                                                             }
                                                             
                                                             resCandidateMatchScoreRec.lineOfBusinessScore = matchedAssignmentSetting.Matching_Point_Line_of_Business__c * CON_OWF.skillRatingValueMap.get(selectedSkillCertificationRatingVal.trim());
                                                         }
                                                         else if(scr.pse__Skill_Certification__r.pse__Type__c == CON_OWF.SKILL_TYPE_POTENTIAL_REGION) {
                                                             resCandidateMatchScoreRec.potentialRegionScore = matchedAssignmentSetting.Matching_Point_Potential_Regions__c * CON_OWF.skillRatingValueMap.get(selectedSkillCertificationRatingVal.trim());
                                                             if(rrPotentialRegion!=null && rrPotentialRegion.contains(scr.pse__Skill_Certification__r.name)
                                                                || (rrPotentialRegion == 'Global' && bdLeadToPRMap.get(resourceRequest.BD_Lead_Sub_Region__c) == scr.pse__Skill_Certification__r.name)) {
                                                                    if((resourceRequest.SubGroup__c == CON_OWF.RES_REQ_TYPE_TSL &&
                                                                        !(resourceRequest.Resource_Request_Type__c == 'Clinical' ||
                                                                          resourceRequest.Resource_Request_Type__c == 'Clinical - Ballpark'))
                                                                       || resourceRequest.SubGroup__c != CON_OWF.RES_REQ_TYPE_TSL){
                                                                           resCandidateMatchScoreRec.hasMatchingPR = true;
                                                                       }
                                                                    resCandidateMatchScoreRec.hasRequiredRFPBidComplexity = true;
                                                                   // system.debug('rrPotentialRegion');
                                                                }
                                                         }
                                                         else if(scr.pse__Skill_Certification__r.pse__Type__c == CON_OWF.SKILL_TYPE_GLOBAL_ANALYTICS_COUNTRY) {
                                                             // system.assert(false,scr.pse__Skill_Certification__r.Name);
                                                             resCandidateMatchScoreRec.hasMatchingPR = true;
                                                             resCandidateMatchScoreRec.hasRequiredRFPBidComplexity = true;
                                                             resCandidateMatchScoreRec.rgCountryToScoreMap.put(resourceRequest.Regional_Analytics_Country__c,CON_OWF.skillRatingValueMap.get(selectedSkillCertificationRatingVal.trim()));
                                                         }
                                                     }
                                                     
                                                     if(resCandidateMatchScoreRec.resourceSubGroup == CON_OWF.RES_REQ_TYPE_GLOBAL_ANALYTICS)
                                                     {
                                                         resCandidateMatchScoreRec.matchScore = resCandidateMatchScoreRec.rgCountryToScoreMap.get(resourceRequest.Regional_Analytics_Country__c);
                                                     }
                                                     else
                                                     {
                                                         resCandidateMatchScoreRec.matchScore = resCandidateMatchScoreRec.therapyAreaScore + 
                                                             resCandidateMatchScoreRec.indicationScore + 
                                                             resCandidateMatchScoreRec.potentialRegionScore + 
                                                             resCandidateMatchScoreRec.lineOfBusinessScore+ 
                                                             resCandidateMatchScoreRec.accountMatchScore+
                                                             resCandidateMatchScoreRec.tslRegionPoint+
                                                             resCandidateMatchScoreRec.availableFTEpoint;  
                                                     }
                                                     
                                                 }
                                              resourceCandidateMatchScoreList.add(resCandidateMatchScoreRec);
                                          }
                                      }
                                }
                            }
                        }
                    }
                }
            }
        }
        return combinedKeyToMatchScoreMap.values();
    }
    
    private static List<ResourceCandidateMatchScore> validateAndCreateCandidateMatchScoresForGBO(Set<Id> resourceRequestIdsSet) {
        List<ResourceCandidateMatchScore> resourceCandidateMatchScoreList = new List<ResourceCandidateMatchScore>();
        Map<Id, pse__Resource_Request__c> resourceRequestsMap = new Map<Id, pse__Resource_Request__c>();
        Set<Id> skillIdSet = new Set<Id>();
        Map<Id, List<pse__Skill_Certification_Rating__c>> skillIdToSkillCertiRatingsMap = new Map<Id, List<pse__Skill_Certification_Rating__c>>();
        Set<Id> contactAlignedwithAccountSet = new Set<Id>();
        Map<String,ResourceCandidateMatchScore> combinedKeyToMatchScoreMap = new Map<String,ResourceCandidateMatchScore>();
        ResourceCandidateMatchScore resCandidateMatchScoreRec;
        Id SkillId;
        Id accountId;
        Set<String> subGroupSet = new Set<String>();
        
        //Fetching Resource_Requests with all ResourceSkillRequests and preparing a map b/w resource_request and list of resource_skill_requests
        String resReqCondition = 'Id IN :sObjectIdSet And RecordType.DeveloperName = \'' + CON_OWF.OWF_RESOURCE_REQUEST_RECORD_TYPE_NAME + '\'';
        Set<String> resRequestFieldSet = new Set<String>{'Id','Suggested_FTE__c', 'pse__Resource__c', 'Resource_Request_Type__c', 'SubGroup__c', 'Complexity_Score_Total__c','Bid_History__r.Triage_Level__c', 'Bid_History__r.RFP_Ranking__c', 'Potential_Regions__c', 'Name', 'Bid_History__r.Bid_History_Related_Opportunity__r.Potential_Regions__c', 'BD_Lead_Sub_Region__c', 'Bid_History__r.Numerical_Bid_Complexity__c', 'pse__Project__r.pse__Start_Date__c', 'Bid_History__r.BD_Lead_Sub_Region__c', 'Account__c', 'Bid_History__r.Opportunity_Type__c', 'pse__Opportunity__r.FSP__c', 'pse__Opportunity__r.Is_this_IQVIA_Biotech__c', 'pse__Opportunity__r.Line_of_Business__c','Bid_History__r.Bid_History_Related_Opportunity__r.Global_project_unit__c'};
        Set<String> resSkillRequestFieldSet = new Set<String>{'Id', 'pse__Resource_Request__c', 'pse__Skill_Certification__c', 'pse__Skill_Certification__r.pse__Type__c','pse__Resource_Request__r.SubGroup__c', 'pse__Skill_Certification__r.Name', 'pse__Resource_Request__r.pse__Opportunity__r.Line_of_Business__c'};
        String resSkillReqCondition =  'pse__Resource_Request__c IN : sObjectIdSet';
        resourceRequestsMap = new SLT_Resource_Request(false,false).selectByIdWithResReqsAndRSRs(resourceRequestIdsSet, resReqCondition, resRequestFieldSet, resSkillRequestFieldSet, resSkillReqCondition);
        
        //Get map of BD Lead Sub Region to Potential Region
        Set<String> potentialRegToBDLeadMappingFieldSet = new Set<String>{'Id','Potential_Region__c','BD_Lead_Sub_Region__c'};
            Map<String,String> bdLeadToPRMap = new Map<String,String>();
        for(Potential_Region_To_BD_Lead_Mapping__mdt mapping : 
            new SLT_Potential_Region_To_BD_Lead_Mapping(false,false).getPotentialRegionToBDLeadMappings(potentialRegToBDLeadMappingFieldSet)) {
                bdLeadToPRMap.put(mapping.BD_Lead_Sub_Region__c,mapping.Potential_Region__c);
            }
        
        Set<String> rrGradeLevelSettingFieldSet =new Set<String>{'RFP_Ranking__c','Grade_Level_Contribution__c'};
            Map<String,Map<String,Decimal>> rfpRankingWithRatingMap = new Map<String,Map<String,Decimal>>();
			Map<String,Decimal> skillRatingWithPercentageMap;										
        for(OWF_RR_Grade_Level_Setting__mdt rrGradeLevelSetting : new 
            SLT_OWF_RR_Grade_Level_Setting(false,false).getOWFResourceRequestGradeLevelSettingRecords(rrGradeLevelSettingFieldSet)){
                skillRatingWithPercentageMap = new Map<String,Decimal>();
                for(String gradeLevelContribution :rrGradeLevelSetting.Grade_Level_Contribution__c.split(',')){
                    skillRatingWithPercentageMap.put(gradeLevelContribution.substringBefore('~'),Decimal.valueOf(gradeLevelContribution.substringAfter('~')));
                }
                rfpRankingWithRatingMap.put(rrGradeLevelSetting.RFP_Ranking__c,skillRatingWithPercentageMap);
            }
        
        //Fetching all Skill_Certification_Ratings and preparing a map b/w resource and list of Skill_Certification_Ratings
        if(!resourceRequestsMap.IsEmpty()) {
            for(pse__Resource_Request__c resourceRequest : resourceRequestsMap.values()) {
                subGroupSet.add(resourceRequest.SubGroup__c);
                if(resourceRequest.SubGroup__c == CON_OWF.RES_REQ_TYPE_GBO_LEAD_PD){
                    accountId = resourceRequest.Account__c;
                }
                if(resourceRequest.pse__Resource_Skill_Requests__r.size() > 0) {
                    for(pse__Resource_Skill_Request__c rsr: resourceRequest.pse__Resource_Skill_Requests__r) {
                        if(rsr.pse__Skill_Certification__c != NULL) {
                            if(!skillIdSet.contains(rsr.pse__Skill_Certification__c)) {
                                skillIdSet.add(rsr.pse__Skill_Certification__c);
                            }
                        }
                    }
                }
            }
            if(accountId != null){
                Set<String> caRelationFieldSet = new Set<String>{'Id','Contact.Name','ContactId','Function__c','contact.Available_FTE__c','Contact.Sub_Group__c'};
                List<AccountContactRelation> activeRelations = new SLT_AccountContactRelation().getAccountContactRelationsforOWFUsingSubGroupAndFunction(caRelationFieldSet, accountId, CON_OWF.CONTACT_TYPE, True, CON_OWF.FUNCTION_SET_FOR_TSL_RR, new Set<String>{CON_OWF.RES_REQ_TYPE_GBO_LEAD_PD});
                for( AccountContactRelation acr : activeRelations){
                    contactAlignedwithAccountSet.add(acr.ContactId);
                }                                                                                                                                             
            }
            String skillCertRatingCondition = ' pse__Skill_Certification__c IN :sObjectIdSet AND is_duplicate__c = false AND isPSEActiveResource__c = True AND Active__c = True AND pse__Resource__c != NULL '
                + ' AND pse__Resource__r.pse__Group__c != null '
                + ' AND pse__Resource__r.pse__Salesforce_User__r.IsActive = true '
                + ' AND (pse__Skill_Certification__r.pse__Type__c = \'' + CON_OWF.SKILL_TYPE_INDICATION + '\''
                + ' OR pse__Skill_Certification__r.pse__Type__c = \''  + CON_OWF.SKILL_TYPE_THERAPY_AREA + '\''
                + ' OR pse__Skill_Certification__r.pse__Type__c = \''  + CON_OWF.SKILL_TYPE_LINE_OF_BUSINESS + '\''
                + ' OR pse__Skill_Certification__r.pse__Type__c = \''  + CON_OWF.SKILL_TYPE_POTENTIAL_REGION + '\''
                + ' OR pse__Skill_Certification__r.pse__Type__c = \''  + CON_OWF.SKILL_TYPE_TRIAGE_LEVEL + '\''
                + ' OR pse__Skill_Certification__r.pse__Type__c = \''  + CON_OWF.SKILL_TYPE_OPPORTUNITY_LEVEL + '\''
                + ' OR pse__Skill_Certification__r.pse__Type__c = \''  + CON_OWF.SKILL_TYPE_OPPORTUNITY_TYPE + '\''
                + ' OR pse__Skill_Certification__r.pse__Type__c = \''  + CON_OWF.SKILL_TYPE_GLOBAL_PROJECT_UNIT + '\''
                + ' OR pse__Skill_Certification__r.pse__Type__c = \''  + CON_OWF.SKILL_TYPE_GRADE_LEVEL + '\')'
                + ' AND pse__Resource__r.Sub_Group__c IN : subGroupSet';
            Set<String> skillCertRatingFieldSet = new Set<String>{'Id','Triage_Level__c', 'pse__Resource__c',  'pse__Skill_Certification__c', 'pse__Rating__c', 'pse__Skill_Certification__r.pse__Type__c', 'pse__Resource__r.Sub_Group__c', 'pse__Resource__r.Available_For_Triage_Flag__c', 'pse__Resource__r.pse__Is_Resource__c', 'pse__Resource__r.pse__Is_Resource_Active__c', 'pse__Resource__r.Name', 'pse__Skill_Certification__r.name', 'RFP_Ranking__c', 'pse__Numerical_Rating__c', 'pse__Skill_Certification__r.Name', 'pse__Resource__r.Region__c', 'pse__Resource__r.Available_FTE__c', 'Active__c','pse__Resource__r.Top_Speed__c','pse__Resource__r.COUNT_Assignemnts_Accepted__c','pse__Resource__r.COUNT_Assignemnts_Pending__c'};
                for(pse__Skill_Certification_Rating__c scr : new SLT_Skill_Certification_Rating(false,false).getSkillCertificationRatingsBySkills(skillIdSet, skillCertRatingCondition, skillCertRatingFieldSet,subGroupSet).values()) {
                    if(!skillIdToSkillCertiRatingsMap.containsKey(scr.pse__Skill_Certification__c)) {
                        skillIdToSkillCertiRatingsMap.put(scr.pse__Skill_Certification__c, new List<pse__Skill_Certification_Rating__c>());
                    }
                    skillIdToSkillCertiRatingsMap.get(scr.pse__Skill_Certification__c).add(scr);
                }
            if(!skillIdSet.IsEmpty() && !skillIdToSkillCertiRatingsMap.IsEmpty()) {
                Map<String, List<OWF_Assignment_Setting__mdt>> oasIdToOasMap = new Map<String, List<OWF_Assignment_Setting__mdt>>();
                Set<String> oasFieldSet = new Set<String>{'Id','Complexity_Score__c','Resource_Request_Type__c','Sub_Group__c', 'RFP_Ranking__c',
                    'Matching_Point_Indication__c','Triage_Level__c', 'Matching_Point_Therapeutic_Area__c', 'Matching_Point_Line_of_Business__c', 'Matching_Point_Potential_Regions__c','Ignore_FTE_Threshold__c','Matching_Point_Threshold__c','Automation_backup_flag__c','Disable_availability_flag__c','Matching_Point_Grade_Level__c','Suggested_FTE__c', 'Matching_Point_BD_Lead_Sub_Region__c', 'Matching_Point_Customer__c'};
				String mapKey;					  
                        for(OWF_Assignment_Setting__mdt oasCMT : new SLT_OWF_Assignment_Setting(false, false).getOWFAssignmentSettingRecords(oasFieldSet)) {
                            if(oasCMT.Sub_Group__c.contains(CON_OWF.RES_REQ_TYPE_GBO_LEAD_PD) || oasCMT.Sub_Group__c.contains(CON_OWF.RES_REQ_TYPE_GBO_SUPPORT_PD) || oasCMT.Sub_Group__c.contains(CON_OWF.RES_REQ_TYPE_GBO_STRATEGIC_WRITER) || oasCMT.Sub_Group__c.contains(CON_OWF.RES_REQ_TYPE_IG_LEAD)){
                                mapKey = oasCMT.Resource_Request_Type__c+'-'+oasCMT.RFP_Ranking__c;
                                if(!oasIdToOasMap.containsKey(mapKey)) {
                                    oasIdToOasMap.put(mapKey,new List<OWF_Assignment_Setting__mdt>()); 
                                    oasIdToOasMap.get(mapKey).add(oasCMT); 
                                } else{
                                    oasIdToOasMap.get(mapKey).add(oasCMT); 
                                }
                            }
                            else if(oasCMT.Sub_Group__c == CON_OWF.RFI_SUBGROUP && oasCMT.Resource_Request_Type__c == 'RFI')
                            {
                                mapKey = oasCMT.Resource_Request_Type__c+'-'+oasCMT.Triage_Level__c ;
                                if(!oasIdToOasMap.containsKey(mapKey)) {
                                    oasIdToOasMap.put(mapKey,new List<OWF_Assignment_Setting__mdt>()); 
                                    oasIdToOasMap.get(mapKey).add(oasCMT); 
                                } else{
                                    oasIdToOasMap.get(mapKey).add(oasCMT); 
                                }
                            }
                        }
				OWF_Assignment_Setting__mdt matchedAssignmentSetting;
				String rrPotentialRegion;
				String selectedSkillCertificationRatingVal;
				String rcmKey;
                List<String> resourceRegionList;
                for(pse__Resource_Request__c resourceRequest : resourceRequestsMap.values()) {
                    if(resourceRequest.pse__Resource_Skill_Requests__r.size() > 0) {
                        matchedAssignmentSetting = getMatchingAssignmentSetting(resourceRequest,oasIdToOasMap);
                        skillRatingWithPercentageMap = new Map<String,Decimal>();
                        
                        if(resourceRequest.Bid_History__r.RFP_Ranking__c!=null && (resourceRequest.SubGroup__c == CON_OWF.RES_REQ_TYPE_GBO_LEAD_PD || resourceRequest.SubGroup__c == CON_OWF.RES_REQ_TYPE_GBO_SUPPORT_PD || resourceRequest.SubGroup__c == CON_OWF.RES_REQ_TYPE_GBO_STRATEGIC_WRITER))
                            skillRatingWithPercentageMap = rfpRankingWithRatingMap.get(resourceRequest.Bid_History__r.RFP_Ranking__c);
                        else if(resourceRequest.SubGroup__c == 'GBO-RFI' && resourceRequest.Bid_History__r.Triage_Level__c!=null)
                            skillRatingWithPercentageMap = rfpRankingWithRatingMap.get(resourceRequest.Bid_History__r.Triage_Level__c);
                        // System.debug(LoggingLevel.INFO, '****** matchedAssignmentSetting: ' + matchedAssignmentSetting);
                        if(matchedAssignmentSetting != null) {
                            for(pse__Resource_Skill_Request__c rsr: resourceRequest.pse__Resource_Skill_Requests__r)  {
                                skillId = rsr.pse__Skill_Certification__c;
                                if(skillIdToSkillCertiRatingsMap.containsKey(skillId)) {
                                   // System.debug(LoggingLevel.INFO, '****** skillId: ' + skillId);
                                   rrPotentialRegion = resourceRequest.Bid_History__r.Bid_History_Related_Opportunity__r.Potential_Regions__c; 
                                   //System.debug(LoggingLevel.INFO, '****** resourceRequest.Complexity_Score_Total__c, matchedAssignmentSetting.Complexity_Score__c: ' + resourceRequest.Complexity_Score_Total__c + ' ' + matchedAssignmentSetting.Complexity_Score__c);                           
                                    if((((resourceRequest.SubGroup__c==CON_OWF.RES_REQ_TYPE_GBO_LEAD_PD || resourceRequest.SubGroup__c == CON_OWF.RES_REQ_TYPE_GBO_SUPPORT_PD || resourceRequest.SubGroup__c == CON_OWF.RES_REQ_TYPE_GBO_STRATEGIC_WRITER || resourceRequest.SubGroup__c == CON_OWF.RES_REQ_TYPE_IG_LEAD ) && resourceRequest.Complexity_Score_Total__c >= matchedAssignmentSetting.Complexity_Score__c && (resourceRequest.Bid_History__r.RFP_Ranking__c == '' || (matchedAssignmentSetting.RFP_Ranking__c != '*' && resourceRequest.Bid_History__r.RFP_Ranking__c == matchedAssignmentSetting.RFP_Ranking__c) || matchedAssignmentSetting.RFP_Ranking__c == '*'))                                   
                                        ||(resourceRequest.SubGroup__c == CON_OWF.RFI_SUBGROUP && resourceRequest.Suggested_FTE__c >= matchedAssignmentSetting.Suggested_FTE__c))
                                       && resourceRequest.SubGroup__c == matchedAssignmentSetting.Sub_Group__c) {
                                           for(pse__Skill_Certification_Rating__c scr : skillIdToSkillCertiRatingsMap.get(skillId)) {
                                               selectedSkillCertificationRatingVal = scr.pse__Rating__c;
                                               if(rsr.pse__Resource_Request__r.SubGroup__c == scr.pse__Resource__r.Sub_Group__c
                                                  && scr.pse__Resource__r.Available_For_Triage_Flag__c
                                                  && scr.pse__Resource__r.pse__Is_Resource__c && scr.pse__Resource__r.pse__Is_Resource_Active__c) {
                                                      rcmKey = rsr.pse__Resource_Request__c+'-'+scr.pse__Resource__c;
                                                      
                                                      if(combinedKeyToMatchScoreMap.containsKey(rcmKey)) {
                                                          resCandidateMatchScoreRec = combinedKeyToMatchScoreMap.get(rcmKey);
                                                          resCandidateMatchScoreRec.skillIdSet.add(skillId);
                                                      } else{
                                                          resCandidateMatchScoreRec = new ResourceCandidateMatchScore(rsr.pse__Resource_Request__c, scr.pse__Resource__c);
                                                          resCandidateMatchScoreRec.skillIdSet = new Set<Id>();
                                                          resCandidateMatchScoreRec.skillIdSet.add(skillId);
                                                          resCandidateMatchScoreRec.resourceName = scr.pse__Resource__r.Name;
                                                          resCandidateMatchScoreRec.projectStartDate = resourceRequest.pse__Project__r.pse__Start_Date__c;
                                                          resCandidateMatchScoreRec.resourceSubGroup = scr.pse__Resource__r.Sub_Group__c;
                                                          combinedKeyToMatchScoreMap.put(rcmKey,resCandidateMatchScoreRec);
                                                      }
                                                      resCandidateMatchScoreRec.assignmentSettingRecordId = matchedAssignmentSetting.Id;
                                                      resCandidateMatchScoreRec.assignmentSettingRecord = matchedAssignmentSetting;
                                                      if(String.IsNotBlank(selectedSkillCertificationRatingVal) && CON_OWF.skillRatingValueMap.containsKey(selectedSkillCertificationRatingVal.trim())) {
                                                        //  System.debug(LoggingLevel.INFO, '*** scr.pse__Resource__r.Name ' + scr.pse__Resource__r.Name);
                                                         // System.debug(LoggingLevel.INFO, '****** scr.pse__Skill_Certification__r.Name ' + scr.pse__Skill_Certification__r.Name);
                                                         // System.debug(LoggingLevel.INFO, '****** skillId ' + skillId);
                                                         // System.debug(LoggingLevel.INFO, '****** scr.pse__Numerical_Rating__c ' + scr.pse__Numerical_Rating__c);
                                                         // System.debug(LoggingLevel.INFO, '****** resourceRequest.Bid_History__r.Numerical_Bid_Complexity__c ' + resourceRequest.Bid_History__r.Numerical_Bid_Complexity__c);
                                                          if(resourceRequest.SubGroup__c == CON_OWF.RES_REQ_TYPE_GBO_LEAD_PD || resourceRequest.SubGroup__c == CON_OWF.RES_REQ_TYPE_IG_LEAD){
                                                              //resCandidateMatchScoreRec.availableFTEpoint = scr.pse__Resource__r.Available_FTE__c * 100;
                                                              if(resourceRequest.pse__Opportunity__r.FSP__c != CON_OWF.OWF_YES && resourceRequest.pse__Opportunity__r.Is_this_IQVIA_Biotech__c != CON_OWF.OWF_YES){
                                                                  resCandidateMatchScoreRec.hasMatchingOpportunityLevelSkill = true; 
                                                              }
                                                              if(!contactAlignedwithAccountSet.isEmpty()){
                                                                  resCandidateMatchScoreRec.accountMatchScore = 25 * CON_OWF.AlignedWithAccount.get(contactAlignedwithAccountSet.contains(scr.pse__Resource__c));
				                                              }
                                                              if(resourceRequest.Bid_History__r.BD_Lead_Sub_Region__c != null && scr.pse__Resource__r.Region__c != null){
                                                                  resourceRegionList = CON_OWF.GBO_BD_LEAD_REGION_TO_RESOURCE_REGION_MAP.get(resourceRequest.Bid_History__r.BD_Lead_Sub_Region__c);
                                                                  if(resourceRegionList[0] != null && resourceRegionList[0].contains(scr.pse__Resource__r.Region__c)){
                                                                      resCandidateMatchScoreRec.tslRegionPoint = 100;
                                                                      resCandidateMatchScoreRec.hasMatchingPR = true;
                                                                  }
                                                                  else if(resourceRegionList[1] != null && resourceRegionList[1].contains(scr.pse__Resource__r.Region__c)){
                                                                      resCandidateMatchScoreRec.tslRegionPoint = 50;
                                                                      resCandidateMatchScoreRec.hasMatchingPR = true;
                                                                  }
                                                                  else if(resourceRegionList[2] != null && resourceRegionList[2].contains(scr.pse__Resource__r.Region__c)){
                                                                      resCandidateMatchScoreRec.tslRegionPoint = 25;
                                                                      resCandidateMatchScoreRec.hasMatchingPR = true;
                                                                  }
                                                              }
                                                              if(resourceRequest.SubGroup__c == CON_OWF.RES_REQ_TYPE_IG_LEAD){
                                                                  if(scr.pse__Resource__r.Top_Speed__c != null){
                                                                      resCandidateMatchScoreRec.availableFTEpoint = scr.pse__Resource__r.Top_Speed__c;
                                                                      if(scr.pse__Resource__r.COUNT_Assignemnts_Accepted__c != null){
                                                                          resCandidateMatchScoreRec.availableFTEpoint -= scr.pse__Resource__r.COUNT_Assignemnts_Accepted__c;
                                                                      }
                                                                      if(scr.pse__Resource__r.COUNT_Assignemnts_Pending__c != null){
                                                                          resCandidateMatchScoreRec.availableFTEpoint -= scr.pse__Resource__r.COUNT_Assignemnts_Pending__c;
                                                                      }
                                                                  }
                                                              }
                                                              if(scr.pse__Skill_Certification__r.pse__Type__c == CON_OWF.SKILL_TYPE_OPPORTUNITY_LEVEL && ((resourceRequest.pse__Opportunity__r.FSP__c == CON_OWF.OWF_YES && CON_OWF.FSP == scr.pse__Skill_Certification__r.name) || (resourceRequest.pse__Opportunity__r.Is_this_IQVIA_Biotech__c == CON_OWF.OWF_YES && CON_OWF.IQVIA_BIOTECH_SKILL == scr.pse__Skill_Certification__r.name))){
                                                                  resCandidateMatchScoreRec.hasMatchingOpportunityLevelSkill = true;
                                                                  resCandidateMatchScoreRec.opportunityLevelScore = CON_OWF.skillRatingValueMap.get(selectedSkillCertificationRatingVal.trim());
                                                              }
                                                              if(resourceRequest.Bid_History__r.Bid_History_Related_Opportunity__r.Global_project_unit__c != CON_OWF.GPU_MEDTECH_CLINICAL_SOULTIONS){
                                                                  resCandidateMatchScoreRec.hasGlobalProjectUnitSkill = true;
                                                          	  }
                                                              else if (scr.pse__Skill_Certification__r.pse__Type__c == CON_OWF.SKILL_TYPE_GLOBAL_PROJECT_UNIT && resourceRequest.Bid_History__r.Bid_History_Related_Opportunity__r.Global_project_unit__c == scr.pse__Skill_Certification__r.name){
                                                                  resCandidateMatchScoreRec.hasGlobalProjectUnitSkill = true;
                                                                  resCandidateMatchScoreRec.globalProjectUnitScore = CON_OWF.skillRatingValueMap.get(selectedSkillCertificationRatingVal.trim());
                                                              }
                                                              
                                                              if(scr.pse__Skill_Certification__r.pse__Type__c == CON_OWF.SKILL_TYPE_OPPORTUNITY_TYPE && resourceRequest.Bid_History__r.Opportunity_Type__c == scr.pse__Skill_Certification__r.name){
                                                                  resCandidateMatchScoreRec.hasMatchingopportunityTypeCertificate = true;
                                                                  resCandidateMatchScoreRec.opportunityTypeScore = CON_OWF.skillRatingValueMap.get(selectedSkillCertificationRatingVal.trim());
                                                              }
                                                          }
                                                          if(scr.pse__Skill_Certification__r.pse__Type__c == CON_OWF.SKILL_TYPE_LINE_OF_BUSINESS){
                                                             if((resourceRequest.SubGroup__c == CON_OWF.RES_REQ_TYPE_GBO_LEAD_PD && resourceRequest.pse__Opportunity__r.Line_of_Business__c == scr.pse__Skill_Certification__r.name && CON_OWF.GBO_LEAD_OPPORTUNITY_SET.contains(resourceRequest.pse__Opportunity__r.Line_of_Business__c)) || resourceRequest.SubGroup__c == CON_OWF.RES_REQ_TYPE_IG_LEAD){
                                                                  resCandidateMatchScoreRec.lineOfBusinessScore = CON_OWF.skillRatingValueMap.get(selectedSkillCertificationRatingVal.trim());
                                                                  resCandidateMatchScoreRec.hasMatchingLineOfBusinessCertificate = true;
                                                              }
                                                              else{
                                                                  resCandidateMatchScoreRec.lineOfBusinessScore = matchedAssignmentSetting.Matching_Point_Line_of_Business__c * CON_OWF.skillRatingValueMap.get(selectedSkillCertificationRatingVal.trim());
                                                              }
                                                          }
                                                              else if(scr.pse__Skill_Certification__r.pse__Type__c == CON_OWF.SKILL_TYPE_INDICATION){
                                                                  resCandidateMatchScoreRec.indicationScore = matchedAssignmentSetting.Matching_Point_Indication__c * CON_OWF.skillRatingValueMap.get(selectedSkillCertificationRatingVal.trim());
                                                              }
                                                              else if(scr.pse__Skill_Certification__r.pse__Type__c == CON_OWF.SKILL_TYPE_THERAPY_AREA){
                                                                  resCandidateMatchScoreRec.therapyAreaScore = matchedAssignmentSetting.Matching_Point_Therapeutic_Area__c * CON_OWF.skillRatingValueMap.get(selectedSkillCertificationRatingVal.trim());
				                                              }
                                                              else if(scr.pse__Skill_Certification__r.pse__Type__c == CON_OWF.SKILL_TYPE_POTENTIAL_REGION && resourceRequest.SubGroup__c != CON_OWF.RES_REQ_TYPE_GBO_LEAD_PD) {
                                                                  resCandidateMatchScoreRec.potentialRegionScore = matchedAssignmentSetting.Matching_Point_Potential_Regions__c * CON_OWF.skillRatingValueMap.get(selectedSkillCertificationRatingVal.trim());                                                                  
                                                                  if(rrPotentialRegion!=null && rrPotentialRegion.contains(scr.pse__Skill_Certification__r.name)
                                                                     || (rrPotentialRegion == 'Global' && bdLeadToPRMap.get(resourceRequest.BD_Lead_Sub_Region__c) == scr.pse__Skill_Certification__r.name)) {
                                                                         resCandidateMatchScoreRec.hasMatchingPR = true;
                                                                     }
                                                              }
                                                              else if(scr.pse__Skill_Certification__r.pse__Type__c == CON_OWF.SKILL_TYPE_GRADE_LEVEL
                                                                        && (resourceRequest.SubGroup__c == CON_OWF.RES_REQ_TYPE_GBO_LEAD_PD || resourceRequest.SubGroup__c == CON_OWF.RES_REQ_TYPE_GBO_SUPPORT_PD || resourceRequest.SubGroup__c == CON_OWF.RES_REQ_TYPE_GBO_STRATEGIC_WRITER)){
                                                                            resCandidateMatchScoreRec.gradeLevelScore = skillRatingWithPercentageMap.get(scr.pse__Rating__c);
                                                                            resCandidateMatchScoreRec.skillName =  scr.RFP_Ranking__c;
                                                                            // if resource does not have required skill to handle bid complexity for this RFP ranking, will not add to suggested resource list
                                                                            if((scr.pse__Skill_Certification__r.Name == rsr.pse__Skill_Certification__r.Name && rsr.pse__Skill_Certification__r.Name.contains('RFP Ranking ') && scr.pse__Numerical_Rating__c >= resourceRequest.Bid_History__r.Numerical_Bid_Complexity__c) || resourceRequest.Bid_History__r.Numerical_Bid_Complexity__c == 0){
                                                                                //   System.debug(LoggingLevel.INFO, '****** adding resource to have required rfp bid complexity: ' + scr.pse__Resource__r.Name);
                                                                                
                                                                                resCandidateMatchScoreRec.hasRequiredRFPBidComplexity = true;
                                                                            }
                                                              }
                                                                    
                                                          else if(scr.pse__Skill_Certification__r.Name == resourceRequest.Bid_History__r.Triage_Level__c &&
                                                                  scr.pse__Skill_Certification__r.pse__Type__c == 'Triage Level'
                                                                  && resourceRequest.SubGroup__c==CON_OWF.RFI_SUBGROUP){
                                                                      resCandidateMatchScoreRec.gradeLevelScore = skillRatingWithPercentageMap.get(scr.pse__Rating__c);
                                                                      resCandidateMatchScoreRec.skillName =  scr.pse__Skill_Certification__r.Name;
                                                                      resCandidateMatchScoreRec.hasRequiredRFPBidComplexity = true;   
                                                                      
                                                                  }
                                                          
                                                          resCandidateMatchScoreRec.matchScore = resCandidateMatchScoreRec.therapyAreaScore + 
                                                              resCandidateMatchScoreRec.indicationScore + 
                                                              resCandidateMatchScoreRec.potentialRegionScore + 
                                                              resCandidateMatchScoreRec.lineOfBusinessScore;
                                                          if(resourceRequest.SubGroup__c == CON_OWF.RES_REQ_TYPE_GBO_LEAD_PD){
                                                              resCandidateMatchScoreRec.matchScore = resCandidateMatchScoreRec.matchScore + resCandidateMatchScoreRec.tslRegionPoint
                                                                  + resCandidateMatchScoreRec.opportunityTypeScore +  resCandidateMatchScoreRec.opportunityLevelScore 
                                                                  + resCandidateMatchScoreRec.accountMatchScore;
                                                          }
                                                          else if(resourceRequest.SubGroup__c == CON_OWF.RES_REQ_TYPE_IG_LEAD){
                                                              resCandidateMatchScoreRec.matchScore = resCandidateMatchScoreRec.matchScore + resCandidateMatchScoreRec.tslRegionPoint + resCandidateMatchScoreRec.availableFTEpoint
                                                                  + resCandidateMatchScoreRec.opportunityTypeScore +  resCandidateMatchScoreRec.opportunityLevelScore +  resCandidateMatchScoreRec.globalProjectUnitScore;
                                                          }
                                                      }
                                                      resourceCandidateMatchScoreList.add(resCandidateMatchScoreRec);
                                                      
                                                  }
                                           }
                                       }
                                }
                            }
                        }
                    }
                }
            }
        }
        return combinedKeyToMatchScoreMap.values();//combinedKeyToMatchScoreMap.values();
    }
    
    
    private static OWF_Assignment_Setting__mdt getMatchingAssignmentSettingForTSSU(pse__Resource_Request__c resourceRequest,Map<String,List<OWF_Assignment_Setting__mdt>> oasIdToOasMap){
        OWF_Assignment_Setting__mdt selectedAssignmentSetting;
        String matchingKey ='';
        Decimal matchScoreDifference = 0;
        matchingKey = resourceRequest.Resource_Request_Type__c+'-'+resourceRequest.SubGroup__c + resourceRequest.Workload_Ranking__c;
        if(resourceRequest.SubGroup__c == CON_OWF.RES_REQ_TYPE_GLOBAL_ANALYTICS)
            return oasIdToOasMap.get(matchingKey)[0];
        if(oasIdToOasMap.containsKey(matchingKey)){
        for(OWF_Assignment_Setting__mdt assignmentSetting : oasIdToOasMap.get(matchingKey)){
            matchScoreDifference = resourceRequest.Complexity_Score_Total__c-assignmentSetting.Complexity_Score__c;
            if(matchScoreDifference>0){
                if(selectedAssignmentSetting==null){
                    selectedAssignmentSetting = assignmentSetting;
                }
                if(selectedAssignmentSetting.Complexity_Score__c <= assignmentSetting.Complexity_Score__c){
                    selectedAssignmentSetting = assignmentSetting;
                }
            }
          }
        }
        return selectedAssignmentSetting;
    }
    
   
    private static OWF_Assignment_Setting__mdt getMatchingAssignmentSetting(pse__Resource_Request__c resourceRequest,Map<String,List<OWF_Assignment_Setting__mdt>> oasIdToOasMap){
        OWF_Assignment_Setting__mdt selectedAssignmentSetting;
        String matchingKey ='';
        Decimal matchScoreDifference = 0;
        if(resourceRequest.SubGroup__c == CON_OWF.RES_REQ_TYPE_GBO_LEAD_PD || resourceRequest.SubGroup__c == CON_OWF.RES_REQ_TYPE_IG_LEAD || resourceRequest.SubGroup__c == CON_OWF.RES_REQ_TYPE_GBO_SUPPORT_PD || resourceRequest.SubGroup__c == CON_OWF.RES_REQ_TYPE_GBO_STRATEGIC_WRITER)
        {
            if(String.isBlank(resourceRequest.Bid_History__r.RFP_Ranking__c)) {
                matchingKey =resourceRequest.Resource_Request_Type__c+'-*';
            } else {
                matchingKey = resourceRequest.Resource_Request_Type__c+'-'+resourceRequest.Bid_History__r.RFP_Ranking__c;
            }
        }
        else if(resourceRequest.SubGroup__c == CON_OWF.RFI_SUBGROUP && resourceRequest.Resource_Request_Type__c == 'RFI' )
        {
            matchingKey = resourceRequest.Resource_Request_Type__c + '-' + resourceRequest.Bid_History__r.Triage_Level__c;
        }
        if(resourceRequest.SubGroup__c ==CON_OWF.RFI_SUBGROUP)
        {
            return oasIdToOasMap.get(matchingKey)[0];
        }

        for(OWF_Assignment_Setting__mdt assignmentSetting : oasIdToOasMap.get(matchingKey)){
            matchScoreDifference = resourceRequest.Complexity_Score_Total__c-assignmentSetting.Complexity_Score__c;
            if(matchScoreDifference>0 && resourceRequest.SubGroup__c == assignmentSetting.Sub_Group__c){
                if(selectedAssignmentSetting==null){
                    selectedAssignmentSetting = assignmentSetting;
                }
                if(selectedAssignmentSetting.Complexity_Score__c <= assignmentSetting.Complexity_Score__c){
                    selectedAssignmentSetting = assignmentSetting;
                }
            }
        }
        return selectedAssignmentSetting;
    }
    
    
    /**
* Wrapper class to hold resource_request_Id, resourceId, assignment_Setting and matching scores
*/
    public class ResourceCandidateMatchScore implements Comparable  {
        public Id resourceRequestId;
        public Id contactId;
        public Id assignmentSettingRecordId;
        public String resourceSubGroup;
        public date projectStartDate;
        public String resourceRequestType;
        public decimal therapyAreaScore;
        public decimal indicationScore;
        public decimal potentialRegionScore;
        public decimal lineOfBusinessScore;
        public decimal accountMatchScore;
        public decimal RegionalAnalyticsScore;
        public decimal tslRegionPoint;
        public decimal nwtPercentage;
        public Boolean availableFTE;
        public Boolean hasMatchingLineOfBusinessCertificate;
        public Boolean hasMatchingTherapyAreaCertificate;
        public Boolean hasMatchingopportunityTypeCertificate;
        public Boolean hasMatchingOpportunityLevelSkill;
        public Boolean hasGlobalProjectUnitSkill;
        public decimal availableFTECount;
        public OWF_Assignment_Setting__mdt assignmentSettingRecord;
        public decimal matchScore;
        public Boolean hasMatchingPR;
        public Set<Id> skillIdSet;
        public String resourceName;
        public decimal gradeLevelScore;
        public decimal availableFTEpoint;
        public decimal opportunityLevelScore;
        public decimal opportunityTypeScore;
        public decimal globalProjectUnitScore;
        public String skillName;
        public Boolean hasRequiredRFPBidComplexity;
        public pse__Resource_Request__c resReqObject;
        public Map<String,Decimal> rgCountryToScoreMap;
        public String isIqviaBiotech;
        public String lineOfBusiness;
        public decimal getMatchScore() {
            decimal totalMatchScore = this.therapyAreaScore + this.indicationScore + this.potentialRegionScore + this.lineOfBusinessScore;
            return totalMatchScore;
        }
        
        public ResourceCandidateMatchScore(Id resourceRequestId, Id contactId) {
            this.resourceRequestId = resourceRequestId;
            this.contactId = contactId;
            this.resourceSubGroup = '';
            this.resourceRequestType= '';
            this.therapyAreaScore = 0;
            this.indicationScore = 0;
            this.projectStartDate = null;
            this.hasMatchingTherapyAreaCertificate = false;
            this.hasMatchingLineOfBusinessCertificate = false;
            this.hasMatchingopportunityTypeCertificate = false;
            this.hasMatchingOpportunityLevelSkill = false;
            this.hasGlobalProjectUnitSkill = false;
            this.potentialRegionScore = 0;
            this.lineOfBusinessScore = 0;
            this.RegionalAnalyticsScore=0;
            this.nwtPercentage = 0;
            this.availableFTE = false;
            this.availableFTECount = 0.0;
            this.hasMatchingPR = false;
            this.resourceName ='';
            this.gradeLevelScore= 0;
            this.accountMatchScore=0;
            this.skillName ='';
            this.tslRegionPoint = 0;
            this.availableFTEpoint = 0;
            this.opportunityLevelScore = 0;
            this.opportunityTypeScore = 0;
            this.globalProjectUnitScore = 0;
            this.hasRequiredRFPBidComplexity = false;
            this.resReqObject = new pse__Resource_Request__c();
            this.isIqviaBiotech = '';
            this.lineOfBusiness ='';
            this.rgCountryToScoreMap = new Map<String,Decimal>();
        }
        
        public Integer compareTo(Object compareTo) {
            ResourceCandidateMatchScore rcMatchScore = (ResourceCandidateMatchScore) compareTo;
            if (matchScore == rcMatchScore.matchScore ) return 0;
            if (matchScore > rcMatchScore.matchScore ) return -1;
            return 1;       
        }
    }
}
