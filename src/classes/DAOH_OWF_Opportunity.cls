/**
* This is Opportunity trigger handler class.
* version : 1.0
*/
public without sharing class DAOH_OWF_Opportunity {
    /**
* This method is used to set Number of Potential regions based on selected Potential Regions.
* @params  newList List<Opportunity>
* @params  oldMap Map<Id, Opportunity>
* @return  void
*/
    private static final Map<String , String> chnageOppFieldMap = new Map<String,String>{'Q2_Budget_Tool__c'=>'Q2_Budget_Tools__c','Advanced_Plan__c'=>'Advance_Plan__c','Protocol_Number__c'=>'Protocol_Number__c' , 'Expected_Project_End_Date__c' => 'Expected_Project_End_Date__c'};
    public static void setNoOfPotentialRegionsBasedOnPotentialRegions(List<Opportunity> newList, Map<Id, Opportunity> oldMap) {
        for(Opportunity opp : newList) {
            if(oldMap == NULL || (oldMap != NULL && opp.Potential_Regions__c != oldMap.get(opp.Id).Potential_Regions__c)) {
                if(String.IsNotBlank(opp.Potential_Regions__c)) {
                    opp.Number_of_Potential_Regions__c = opp.Potential_Regions__c.split(CON_OWF.SEMI_COLON).size();
                }else {
                    opp.Number_of_Potential_Regions__c = 0;
                }
            }
        }
    }
     /**
    * This method is used to add BDLeadSubRegion validation.
    * @params  newList List<Opportunity>
    * @params  oldMap Map<Id, Opportunity>
    * @return  void
    */
    public static void BDLeadSubRegionRequired(List<Opportunity> newList) {
        Mulesoft_Integration_Control__c mulesoftSetting = Mulesoft_Integration_Control__c.getInstance();
        if(!mulesoftSetting.Ignore_Validation_Rules__c){
            
            //Refactor code IQVIAPSA-2236 Start
            Set<Id> oppIdExistAgrmtSet=new Set<Id>();
            oppIdExistAgrmtSet = UTL_OWF.isOPPhasOWFAgreementReturnSet((new Map<Id,Opportunity>(newList)).keySet().clone());
            //Refactor code IQVIAPSA-2236 End
            
            for(Opportunity opp : newList) {
                //Refactor code IQVIAPSA-2236 (Add "oppIdExistAgrmt.contains(opp.id)" Remove  "UTL_OWF.isOPPhasOWFAgreement(new Set<ID>{opp.id})" )
                if( oppIdExistAgrmtSet.contains(opp.id) && opp.Potential_Regions__c =='Global' && opp.BD_Sub_Region_2__c == null)
                {
                    // Start - IQVIAPSA-1837
                    opp.adderror('Global Opportunities must include a WD SUBREGION. WD SUBREGION is found on the User.');
                    // end - IQVIAPSA-1837
                }
            }
        }
    }    
    /**
    * This method is used to delete Agreement (Bid_History__c) record based on Opportunity.
    * @params  newList List<Opportunity>
    * @return  
    */
    public static void deleteAgreementBasedOnOpportunity(List<Opportunity> newList) {
        List<Bid_History__c> agreementToBeDeletedList = new List<Bid_History__c>();
        agreementToBeDeletedList = returnAgreementBasedOnOpportunity(newList);
        if(agreementToBeDeletedList.size() > 0) {
            QBL_OWF_DeletionLogic.QueueAgreementDeletion  queuableObject = new QBL_OWF_DeletionLogic.QueueAgreementDeletion (agreementToBeDeletedList);
            System.enqueueJob(queuableObject);
        }
    }
    
    
    
    /**
    * This method is used to create resource request based on agreement udpate
    * @params    newList List<Opportunity>
    * @params    oldMap Map<Id, Opportunity>
    * @return  
    */
    public static void createClinicalBidResRequestsOnOppUpdate(List<Opportunity> newList, Map<Id, Opportunity> oldMap) {
        Set<Id> agreementOppIdsSet = new set<Id>();
        for(Opportunity opp : newList) {
            if(opp.Line_of_Business__c != oldMap.get(opp.Id).Line_of_Business__c || opp.Potential_Regions__c != oldMap.get(opp.Id).Potential_Regions__c
                || opp.InterventionType__c != oldMap.get(opp.Id).InterventionType__c || opp.QI_Invited_to_Present__c != oldMap.get(opp.Id).QI_Invited_to_Present__c
                || opp.Bid_Defense_Date__c != oldMap.get(opp.Id).Bid_Defense_Date__c || opp.Is_this_IQVIA_Biotech__c!=oldMap.get(opp.Id).Is_this_IQVIA_Biotech__c
                || opp.Identified_Business__c != oldMap.get(opp.Id).Identified_Business__c || opp.Population_Age_Group__c != oldMap.get(opp.Id).Population_Age_Group__c
                || opp.Phase_P__c != oldMap.get(opp.Id).Phase_P__c || opp.Parent_Opportunity__c != oldMap.get(opp.Id).Parent_Opportunity__c || opp.Is_this_a_Virtual_Trials_Study__c != oldMap.get(opp.Id).Is_this_a_Virtual_Trials_Study__c) {
                agreementOppIdsSet.add(opp.Id);
            }
        }
        
        if(agreementOppIdsSet.size() > 0) {
            if(UTL_OWF.isLoginUserhasPermissionControl())
            {
                String agrCondition = 'Bid_History_Related_Opportunity__c != NULL And Bid_History_Related_Opportunity__c IN :sObjectIdSet ' +
                                    ' And RecordTypeId = \'' + CON_OWF.OWF_CLINICAL_BID_BID_HISTORY_RECORD_TYPE_ID + '\'';
                CON_OWF.isUpdatedViaPresentationDate = true; //IQVIAPSA-1852
                List<pse__Resource_Request__c> reqRequestsInsertList = new List<pse__Resource_Request__c>();
                List<pse__Resource_Request__c> reqRequestsRebidInsertList = new List<pse__Resource_Request__c>();
                reqRequestsInsertList = UTL_OWF.processResRequestForInitialBids(agreementOppIdsSet, agrCondition, null, null);

                reqRequestsInsertList.addAll(UTL_OWF.processResRequestForClinicalReBids(agreementOppIdsSet, agrCondition,reqRequestsInsertList));
                if(reqRequestsInsertList.size() > 0) {                    
                    try
                    {
                     insert reqRequestsInsertList;
                    }
                    Catch(Exception E){
                        newList[0].addError('An Error occurred: ' + e.getMessage().substringAfter('FIELD_CUSTOM_VALIDATION_EXCEPTION,').substringBefore(': []'));
                    }
               }
            }
            else
            {
                for(Opportunity opp : newList) {
                    opp.adderror('You do not have the staffing permissions.');
                }
            }    
        }
    }
    
    private static List<Bid_History__c> returnAgreementBasedOnOpportunity(List<Opportunity> newList) {
        List<Bid_History__c> agreementsToBeReturnedList = new List<Bid_History__c>();
         Set<String> agreementFieldSet = new Set<String>{'Id'};
        Map<Id, Opportunity> opportunitytIdToOpportunityMap= new Map<Id, Opportunity>();
        for(Opportunity opportunity : newList)
        {
             opportunitytIdToOpportunityMap.put(opportunity.ID, opportunity );
        }
        if(!opportunitytIdToOpportunityMap.keySet().isEmpty())
        {
            Map<Id, Bid_History__c> agrIdToAgreementMap = new SLT_Bid_History(false,false).getBidHistoriesByOppID(opportunitytIdToOpportunityMap.keySet(),agreementFieldSet );
            agreementsToBeReturnedList  = agrIdToAgreementMap.values();
        }
        return agreementsToBeReturnedList;
    }   
    
    /**
    * This method is used to update Complexity Score Total on RR.
    * @params  newList List<Opportunity>
    * @params  oldMap Map<Id, Opportunity>
    * @return  void
    */
    public static void updateComplexityScoreTotalOnRR(List<Opportunity> newList, Map<Id, Opportunity> oldMap) {
        Set<Id> rrAgreementIdSet = new Set<Id>();
        Set<Id> oppIdSet = new Set<Id>();
        Map<Id, Bid_History__c> agrIdToAgreementMap = new Map<Id, Bid_History__c>();
        Map<String,OWF_Resource_Setting__mdt> resSettingIdToResSettingMap = new Map<String,OWF_Resource_Setting__mdt>();        
        CON_OWF.BYPASS_VALIDATION_RULE_RR = true;
        Set<String> orsFieldSet = new Set<String>{'Id','Sub_Group__c', 'Estimated_Fees__c','Is_there_a_Client_Bid_Grid__c','Number_of_Sites__c',
                                                   'Potential_Regions__c','Project_Ex_Number_of_Unique_Tables__c','Re_Bid_Complexity__c',
                                                    'Requested_Services__c','RFP_Ranking__c','Staffing_Number_of_Unique_Tables__c','Country__c'};
        for(Opportunity opp : newList) {
             if(opp.Number_of_Potential_Regions__c != oldMap.get(opp.Id).Number_of_Potential_Regions__c
               || (opp.Potential_Regions__c != oldMap.get(opp.Id).Potential_Regions__c 
                   && opp.Potential_Regions__c == 'Global') || ((opp.Bid_Defense_Date__c != oldMap.get(opp.Id).Bid_Defense_Date__c)))  {
                   
                      oppIdSet.add(opp.Id); 
             }                                        
        } 
        
        if(oppIdSet.size() > 0) {
            for(OWF_Resource_Setting__mdt rsCMT : new SLT_OWF_Resource_Setting(false,false).getOWFResourceSettingRecords(orsFieldSet)) {
                resSettingIdToResSettingMap.put(rsCMT.Sub_Group__c,rsCMT);                                          
            }
        
            Set<String> agrFieldSet = new Set<String>{'Id', 'Bid_History_Related_Opportunity__c','Bid_History_Related_Opportunity__r.Presentation_Date__c','Bid_History_Related_Opportunity__r.Number_of_Potential_Regions__c',
                                                        'Bid_History_Related_Opportunity__r.Potential_Regions__c', 'Name','RFP_Ranking__c','Number_of_Sites__c','Re_Bid_Complexity__c',
                                                        'Staffing_Number_of_Unique_Tables__c','Project_Ex_Number_of_Unique_Tables__c','Triage_Level__c',
                                                      'Estimated_Fees__c','Is_there_a_Client_Bid_Grid__c','Number_of_Requested_Services__c', 'Bid_Due_Date__c','Bid_History_Related_Opportunity__r.Bid_Defense_Date__c','CreatedDate','Grid_Ranking_Level__c'};
            Set<String> resReqFieldSet = new Set<String>{'Id','pse__Resource_Request_Name__c', 'pse__Opportunity__c', 'Bid_History__c', 'Resource_Request_Type__c', 'Complexity_Score_Total__c', 'SubGroup__c',
                                                        'CreatedDate','Workload_Ranking__c','Suggested_FTE__c','pse__Start_Date__c',
                                                        'pse__Start_Date__c','pse__End_Date__c', 'Is_Bid_Defense__c','pse__Status__c','Regional_Analytics_Country__c','pse__Assignment__r.pse__Status__c','SubGroup__c','Regional_Analytics_Country__c','pse__Assignment__c'}; 
                                                        
            String agrCondition = 'Bid_History_Related_Opportunity__c != NULL And Bid_History_Related_Opportunity__c IN :sObjectIdSet ';
            String resReqCondition = 'pse__Opportunity__c != NULL And Bid_History__c != NULL';                                            
            agrIdToAgreementMap = new SLT_Bid_History(false,false).getAgreementAndResReqsByOppId(oppIdSet, agrFieldSet, resReqFieldSet, agrCondition, resReqCondition);
            List<pse__Resource_Request__c> rrList = new List<pse__Resource_Request__c>();
            List<pse__Resource_Request__c> toBeUpdatedRRList = new List<pse__Resource_Request__c>();
            for(Bid_History__c agr : agrIdToAgreementMap.values()) {  
                for(pse__Resource_Request__c rr: agr.Bid_History_Resource_Requests__r){
                    rrList.add(rr);
                }
            }
            toBeUpdatedRRList = UTL_OWF.calculateWRandSuggestedFTE(agrIdToAgreementMap,rrList);
            if(toBeUpdatedRRList.size() > 0) {
                Set<Id> rrIdsSet = new Set<Id>();
                List<pse__Resource_Request__c> resRequestUpdateList = new List<pse__Resource_Request__c>();
                for(pse__Resource_Request__c rr : toBeUpdatedRRList) {
                    if(!rrIdsSet.contains(rr.Id)) {
                        resRequestUpdateList.add(rr);
                    }
                }
                try{
                    
                   update resRequestUpdateList;
                }
                Catch(Exception E)
                {
                    newList[0].addError('An Error occurred: ' + e.getMessage().substringAfter('FIELD_CUSTOM_VALIDATION_EXCEPTION,').substringBefore(': []'));
                }
            }
        }
    }

    /*public static void updatebiotech(List<Opportunity> newList, Map<Id, Opportunity> oldMap) 
    {		
       	Set<Id> opportunityList = new Set<Id>();
        
        for(Opportunity newOpportunity: newList) {
            if(newOpportunity.Is_this_IQVIA_Biotech__c != Null && newOpportunity.Is_this_IQVIA_Biotech__c != oldMap.get(newOpportunity.Id).Is_this_IQVIA_Biotech__c ) {
                opportunityList.add(newOpportunity.Id);
            }
        }
        
        if(!opportunityList.isEmpty()){
            Set<String> agreementFieldSet = new Set<String>{'Id','IQVIA_biotech__c','Bid_History_Related_Opportunity__c','RecordTypeId','Bid_History_Related_Opportunity__r.Is_this_IQVIA_Biotech__c','Bid_Due_Date__c'};
            List<Bid_History__c> agreementList = new SLT_Bid_History(false, false).getBidHistoryByOpportunitesAll(opportunityList, agreementFieldSet);
            
            if(!agreementList.isEmpty()){                                
                for(Bid_History__c agreementNewList: agreementList)
                {
                    if(agreementNewList.Bid_History_Related_Opportunity__r.Is_this_IQVIA_Biotech__c != Null && agreementNewList.RecordTypeId == CON_OWF.OWF_CLINICAL_BID_BID_HISTORY_RECORD_TYPE_ID){
                        agreementNewList.IQVIA_biotech__c = agreementNewList.Bid_History_Related_Opportunity__r.Is_this_IQVIA_Biotech__c; 
                    }
                }
            }
            update  agreementList;
        }
    }*/

    /*
    public static void createClinicalBidResourceRequestsOnPhaseUpdate(List<Opportunity> newList, Map<Id, Opportunity> oldMap) {
        Set<Id> opportunityIdsSet = new set<Id>();
        for(Opportunity newOpportunity : newList) {
            if(newOpportunity.Phase_P__c != NULL && newOpportunity.Phase_P__c != oldMap.get(newOpportunity.Id).Phase_P__c && 
			   newOpportunity.Phase_P__c != CON_OWF.OPPORTUNITY_PHASE_4) {
					opportunityIdsSet.add(newOpportunity.Id);
            }
        }
        
        if(opportunityIdsSet.size() > 0) {
            String agrCondition = 'Apttus__Related_Opportunity__c != NULL  ' +
                                    ' And RecordTypeId = \'' + CON_OWF.OWF_CLINICAL_BID_AGREEMENT_RECORD_TYPE_ID + '\'';
            
            List<pse__Resource_Request__c> reqRequestsInsertList = new List<pse__Resource_Request__c>();
            reqRequestsInsertList = UTL_OWF.processResRequestForInitialBids(opportunityIdsSet, agrCondition, null, null);
            if(reqRequestsInsertList.size() > 0) {
                insert reqRequestsInsertList;
            }    
        }
    }
    */
    public static void UpdateOCTRFxBid(List<Opportunity> newList, Map<Id, Opportunity> oldMap){
            Map<Id,Opportunity> opportunityNewMap = new Map<Id,Opportunity>();
        Set<Id> biotechUpdatedOpportunitySet = new Set<Id>();
        for(Opportunity newOpportunity: newList) {
            if((newOpportunity.StageName == CON_CRM.DELIVERING_PROP_STAGE && oldMap.get(newOpportunity.Id).StageName == CON_CRM.DEVELOPING_PROP_STAGE) ||(newOpportunity.Indication_List__c != Null && newOpportunity.Indication_List__c != oldMap.get(newOpportunity.Id).Indication_List__c ) 
               ||(newOpportunity.Global_project_unit__c != oldMap.get(newOpportunity.Id).Global_project_unit__c) || (newOpportunity.Is_this_IQVIA_Biotech__c != oldMap.get(newOpportunity.Id).Is_this_IQVIA_Biotech__c)) {
                   opportunityNewMap.put(newOpportunity.Id,newOpportunity); 
                   if(newOpportunity.Is_this_IQVIA_Biotech__c != oldMap.get(newOpportunity.Id).Is_this_IQVIA_Biotech__c){
                        biotechUpdatedOpportunitySet.add(newOpportunity.Id);
                   }          
               }
            if(newOpportunity.Line_of_Business__c == 'Q2 Solutions' && checkOppFieldChange(newOpportunity,oldMap.get(newOpportunity.Id),chnageOppFieldMap.keyset())){
                opportunityNewMap.put(newOpportunity.Id,newOpportunity);        
            }
        }
        if(!opportunityNewMap.keySet().isEmpty()){
            Set<String> agreementFieldSet = new Set<String>{'Id','Q2_Business_Area__c' ,'Opportunity_Owner__c','Opportunity_Number__c','Protocol_Number__c','Bid_Number__c','Advance_Plan__c','Q2_Budget_Tools__c','Bid_Sent_Date__c' ,'Expected_Project_End_Date__c', 'RecordTypeId', 'OWF_Indication__c','Bid_History_Related_Opportunity__c','Bid_History_Related_Opportunity__r.Indication_List__c','OWF_Therapy_Area__c','Bid_History_Related_Opportunity__r.TherapyArea__c','Bid_History_Related_Opportunity__r.Global_project_unit__c','Bid_History_Related_Opportunity__r.Is_this_IQVIA_Biotech__c', 'Bid_History_Related_Opportunity__r.Expected_Project_End_Date__c', 'IQVIA_biotech__c','Global_Project_Unit__c','Bid_History_Related_Opportunity__r.Owner.Name','Bid_History_Related_Opportunity__r.Protocol_Number__c','Bid_History_Related_Opportunity__r.Advanced_Plan__c','Bid_History_Related_Opportunity__r.Q2_Budget_Tool__c'}; 
                //String Condition = 'Bid_History_Related_Opportunity__c in :sObjectIdSet and RecordTypeId = \'' + CON_OWF.OWF_OCT_RFX_BID_HISTORY_RECORD_TYPE_ID+'\'';
                String condition = 'Bid_History_Related_Opportunity__c in :sObjectIdSet and (RecordTypeId = \'' + CON_OWF.OWF_OCT_RFX_BID_HISTORY_RECORD_TYPE_ID+'\' OR RecordTypeId = \'' + CON_OWF.OWF_CLINICAL_BID_BID_HISTORY_RECORD_TYPE_ID +'\' OR (RecordTypeId = \'' + CON_OWF.OWF_Q2_Solutions_BID_HISTORY_RECORD_TYPE_ID+'\' AND Q2_Business_Area__c IN (\'' + CON_OWF.Q2_BUSINESS_AREA_BIOSCIENCE + '\',\'' + CON_OWF.Q2_BUSINESS_AREA_VACCINES + '\')) OR RecordTypeId = \'' + CON_OWF.OWF_EARLY_ENGAGEMENT_BID_HISTORY_RECORD_TYPE_ID+'\' OR RecordTypeId = \'' + CON_OWF.OWF_CONTRACT_POST_AWARD_BID_HISTORY_RECORD_TYPE_ID +'\' OR RecordTypeId = \'' + CON_OWF.OWF_NON_RFP_BID_AGREEMENT_RECORD_TYPE_ID+'\')';
            List<Bid_History__c> agreementList = new SLT_Bid_History(false, false).getBidHistoriesByCondition(agreementFieldSet, condition, opportunityNewMap.keySet());
            
            if(!agreementList.isEmpty()){
                for(Bid_History__c agreement:agreementList){
                    if(agreement.RecordTypeId == CON_OWF.OWF_EARLY_ENGAGEMENT_BID_HISTORY_RECORD_TYPE_ID)
                    {
                        agreement.OWF_Indication__c = agreement.Bid_History_Related_Opportunity__r.Indication_List__c;
                        agreement.OWF_Therapy_Area__c = agreement.Bid_History_Related_Opportunity__r.TherapyArea__c;
                    }
                    else if(agreement.RecordTypeId == CON_OWF.OWF_OCT_RFX_BID_HISTORY_RECORD_TYPE_ID){
                        agreement.Bid_Sent_Date__c = Date.today();
                    }
                    else if(agreement.RecordTypeId == CON_OWF.OWF_NON_RFP_BID_AGREEMENT_RECORD_TYPE_ID){
                        agreement.OWF_Indication__c = agreement.Bid_History_Related_Opportunity__r.Indication_List__c;
                    }
                    else if(!biotechUpdatedOpportunitySet.isEmpty() && biotechUpdatedOpportunitySet.contains(agreement.Bid_History_Related_Opportunity__c) && agreement.Bid_History_Related_Opportunity__r.Is_this_IQVIA_Biotech__c != Null && agreement.RecordTypeId == CON_OWF.OWF_CLINICAL_BID_BID_HISTORY_RECORD_TYPE_ID){
                        agreement.IQVIA_biotech__c = agreement.Bid_History_Related_Opportunity__r.Is_this_IQVIA_Biotech__c; 
                    }
                    else if(agreement.RecordTypeId == CON_OWF.OWF_CONTRACT_POST_AWARD_BID_HISTORY_RECORD_TYPE_ID){
                        if(opportunityNewMap.get(agreement.Bid_History_Related_Opportunity__c).Global_project_unit__c != oldMap.get(agreement.Bid_History_Related_Opportunity__c).Global_project_unit__c){
                            agreement.Global_Project_Unit__c = agreement.Bid_History_Related_Opportunity__r.Global_project_unit__c;
                        }
                        if(opportunityNewMap.get(agreement.Bid_History_Related_Opportunity__c).Is_this_IQVIA_Biotech__c != oldMap.get(agreement.Bid_History_Related_Opportunity__c).Is_this_IQVIA_Biotech__c){
                            agreement.IQVIA_biotech__c = agreement.Bid_History_Related_Opportunity__r.Is_this_IQVIA_Biotech__c;
                        } 
                    }
                    else if(agreement.RecordTypeId == CON_OWF.OWF_Q2_Solutions_BID_HISTORY_RECORD_TYPE_ID && CON_OWF.Q2_BUSINESS_AREA_LIST.contains(agreement.Q2_Business_Area__c)){
                        updateBioScienceBidHistory(opportunityNewMap.get(agreement.Bid_History_Related_Opportunity__c),oldMap.get(agreement.Bid_History_Related_Opportunity__c),agreement);
                    }
                }
                update agreementList;
            }
        }
    }
    public static Bid_History__c updateBioScienceBidHistory(Opportunity newOpp, Opportunity oldOpp , Bid_History__c agreement){
        Opportunity opp = agreement.Bid_History_Related_Opportunity__r;
        if(newOpp.OwnerID != oldOpp.OwnerID){
            agreement.Opportunity_Owner__c = opp.Owner.Name;
        }
        for(String fieldName : chnageOppFieldMap.keyset()) {
            if(newOpp.get(fieldName) != oldOpp.get(fieldName)){
                 agreement.put(chnageOppFieldMap.get(fieldName), opp.get(fieldName));
            }
        }
        return  agreement;
    } 
    
    private static boolean checkOppFieldChange(Opportunity newOpp, Opportunity oldOpp, Set<String> fieldSet){
        for(String fieldName : fieldSet ){
            if(newOpp.get(fieldName)!=oldOpp.get(fieldName) || newOpp.OwnerID != oldOpp.OwnerID ){
                return true;
            }
        }
        return false;
    }
    
}
