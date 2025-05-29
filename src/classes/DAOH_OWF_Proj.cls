/**
* This is Project(pse__Proj__c) trigger handler class.
* version : 1.0
*/
public class DAOH_OWF_Proj {
    
    /**
    * This method is used to create Resource Request (pse__Resource_Request__c) record on insert of a Bid type Project.
    * @params  newList List<pse__Proj__c>
    * @return  
    */
    public static void createRRBasedOnAgrAssociatedWithProj(List<pse__Proj__c> newList) {
        List<pse__Resource_Request__c> rrToBeInsertedList = new List<pse__Resource_Request__c>();
        rrToBeInsertedList = returnRRBasedOnAgrAssociatedWithProj(newList);
        if(rrToBeInsertedList.size() > 0) {
            insert rrToBeInsertedList;
        }
    }
    
    /**
    * This method is used to delete Resource Request record based on Project.
    * @params  newList List<pse__Proj__c>
    * @return  
    */
    public static void deleteResourceRequestBasedOnProject(List<pse__Proj__c> newList) {
        List<pse__Resource_Request__c> resourceRequesToBeDeletedList = new List<pse__Resource_Request__c>();
        resourceRequesToBeDeletedList = returnResourceRequestBasedOnProject(newList);
        if(resourceRequesToBeDeletedList.size() > 0) {
            QBL_OWF_DeletionLogic.QueueResourceRequestDeletion  queuableObject = new QBL_OWF_DeletionLogic.QueueResourceRequestDeletion (resourceRequesToBeDeletedList);
            System.enqueueJob(queuableObject);
        }
    }
    
    /**
    * This method is used to create Resource Request (pse__Resource_Request__c) record on insert of Project's Bid_Number.
    * @params  newList List<pse__Proj__c>
    * @return 
    */
    public static void createClinicalBidRRsBasedOnBidNoOfProjects(List<pse__Proj__c> newList) {
        List<pse__Resource_Request__c> rrToBeInsertedList = new List<pse__Resource_Request__c>();
        Set<Id> projectOppIdsSet = new Set<Id>();
        Map<Id, List<pse__Proj__c>> oppIdToReBidsProjectsMap = new Map<Id, List<pse__Proj__c>>();
        Map<Id, pse__Proj__c> initialAgrmtIdToProjectMap = new Map<Id, pse__Proj__c>();
        Set<Id> bidHistoryIds = new Set<Id>();
        Set<String> projectFieldSet =new Set<String>{'Id','Bid_History__r.RecordTypeId'};
        for(pse__Proj__c project : newList) {
            if(project.recordTypeId == CON_OWF.OWF_BID_PROJECT_RECORD_TYPE_ID && project.Bid_History__c != null){
                bidHistoryIds.add(project.Bid_History__c);
            }
        }
        Map<Id, pse__Proj__c> projectIdToProjectMap = new Map<Id, pse__Proj__c>();
        if(!bidHistoryIds.isEmpty()){
            projectIdToProjectMap = new SLT_Project().getProjectByBidHistoryID(bidHistoryIds,projectFieldSet);
        }
        for(pse__Proj__c project : newList) {
            if(project.recordTypeId == CON_OWF.OWF_BID_PROJECT_RECORD_TYPE_ID && 
                project.Bid_History__c != NULL && projectIdToProjectMap.containsKey(project.Id) && projectIdToProjectMap.get(project.Id).Bid_History__r.RecordTypeId == CON_OWF.OWF_CLINICAL_BID_BID_HISTORY_RECORD_TYPE_ID && project.pse__Opportunity__c != NULL && project.Bid_Number__c >= 1) {
                
                projectOppIdsSet.add(project.pse__Opportunity__c);
                //Prepar a map b/w OppId and list of projects
                if(project.Bid_Number__c > 1) {
                    if(!oppIdToReBidsProjectsMap.containsKey(project.pse__Opportunity__c)) {
                        oppIdToReBidsProjectsMap.put(project.pse__Opportunity__c, new List<pse__Proj__c>());
                    }
                    oppIdToReBidsProjectsMap.get(project.pse__Opportunity__c).add(project);
                }else {
                    initialAgrmtIdToProjectMap.put(project.Bid_History__c, project);
                }
            }
        }
        

        
        if(projectOppIdsSet.size() > 0) {

            String agrCondition = 'Bid_History_Related_Opportunity__c != NULL And Bid_History_Related_Opportunity__c IN :sObjectIdSet ' +
                                    ' And RecordTypeId = \'' + CON_OWF.OWF_CLINICAL_BID_BID_HISTORY_RECORD_TYPE_ID + '\'';
            rrToBeInsertedList = UTL_OWF.processResRequestForInitialBids(projectOppIdsSet, agrCondition, initialAgrmtIdToProjectMap, oppIdToReBidsProjectsMap);
            rrToBeInsertedList.addAll(UTL_OWF.processResRequestForClinicalReBids(projectOppIdsSet,agrCondition,rrToBeInsertedList));

            if(rrToBeInsertedList.size() > 0) {
                insert rrToBeInsertedList;
            }    
        }
    }
        
   /**
    * This method is used to set Number of Requested Services based on selected Requested Services.
    * @params  newList List<pse__Proj__c>
    * @return  rrList List<pse__Resource_Request__c>
    */
    private static List<pse__Resource_Request__c> returnRRBasedOnAgrAssociatedWithProj(List<pse__Proj__c> newList) {
        Set<Id> agreementIdSet = new Set<Id>();
        Map<pse__Proj__c,Id> projectToAgreementMap = new Map<pse__Proj__c,Id>();
        Map<Id, Bid_History__c> bhrIdBHRMap = new Map<Id, Bid_History__c>();
        Set<String> fieldSet = new Set<String>{'Id', 'Resources_Needed__c','RecordTypeId','Bid_History_Account__c','Bid_Due_Date__c','Bid_Number__c','Regional_Analytics_Country__c','Select_Analysis__c'};
            List<pse__Resource_Request__c> rrList = new List<pse__Resource_Request__c>();
        for(pse__Proj__c proj : newList) {           
            if(proj.recordTypeId == CON_OWF.OWF_BID_PROJECT_RECORD_TYPE_ID && proj.Bid_History__c != null) {
                projectToAgreementMap.put(proj,proj.Bid_History__c);
            }   
        }
        if(projectToAgreementMap.size() > 0) {
            agreementIdSet.addAll(projectToAgreementMap.values());       
            bhrIdBHRMap = new SLT_Bid_History(false,false).getBidHistoriesById(agreementIdSet, fieldSet);
            Map<String, OWF_Resources_Needed_to_SubGroup_Map__c> resourcesNeededToSubGrpMap = new Map<String,OWF_Resources_Needed_to_SubGroup_Map__c>();
            resourcesNeededToSubGrpMap = OWF_Resources_Needed_to_SubGroup_Map__c.getAll();
            if(bhrIdBHRMap.size() > 0) {
                for(pse__Proj__c proj : projectToAgreementMap.keySet()) {                    
                    if(bhrIdBHRMap.containsKey(proj.Bid_History__c) && 
                       CON_OWF.RESOURCES_NEEEDED_FIELD_BASED_RR_BID_HISTORY_RECORDTYPE_SET.contains(
                           bhrIdBHRMap.get(proj.Bid_History__c).RecordTypeId) &&
                       bhrIdBHRMap.get(proj.Bid_History__c).Resources_Needed__c != '' &&
                       bhrIdBHRMap.get(proj.Bid_History__c).Resources_Needed__c != null
                    ) {
                        boolean autoRRFlag = false;	                          
                        if(bhrIdBHRMap.get(proj.Bid_History__c).RecordTypeId == CON_OWF.OWF_NON_RFP_BID_BID_HISTORY_RECORD_TYPE_ID ||
                           bhrIdBHRMap.get(proj.Bid_History__c).RecordTypeId == CON_OWF.OWF_POST_AWARD_BID_HISTORY_RECORD_TYPE_ID||
                           bhrIdBHRMap.get(proj.Bid_History__c).RecordTypeId == CON_OWF.OWF_EARLY_ENGAGEMENT_BID_HISTORY_RECORD_TYPE_ID){
                            autoRRFlag = true; 
                           }
                        List<String> resourcesNeededList = new List<String>();
                        resourcesNeededList = bhrIdBHRMap.get(proj.Bid_History__c).Resources_Needed__c.split(';');
          	            if(resourcesNeededList.contains('No Resource Request')){
                            resourcesNeededList.remove(resourcesNeededList.indexOf('No Resource Request'));
                        }
                        //IQVIAPSA-3857
                        List<String> regionalAnalyticsCountry = new List<String>();
                        if(bhrIdBHRMap.get(proj.Bid_History__c).Regional_Analytics_Country__c != Null)
                        {
                            regionalAnalyticsCountry = bhrIdBHRMap.get(proj.Bid_History__c).Regional_Analytics_Country__c.split(';');
                        }
                        for(String resourceNeeded : resourcesNeededList) 
                        {
                            //IQVIAPSA-3857
                            if(resourceNeeded == 'Global Analytics')
                            {	
								for( String country : regionalAnalyticsCountry)
								{
									pse__Resource_Request__c newRR = new pse__Resource_Request__c(
									recordTypeId = CON_OWF.OWF_RR_RECORD_TYPE_ID,
									currencyIsoCode = bhrIdBHRMap.get(proj.Bid_History__c).currencyIsoCode,
									pse__Project__c = proj.id,
									Select_Analysis__c = bhrIdBHRMap.get(proj.Bid_History__c).Select_Analysis__c,
									pse__Opportunity__c = proj.pse__Opportunity__c,
									pse__Group__c = proj.pse__Group__c,
									Account__c = bhrIdBHRMap.get(proj.Bid_History__c).Bid_History_Account__c,
									Bid_History__c = proj.Bid_History__c,
									SubGroup__c = resourcesNeededToSubGrpMap.containsKey(resourceNeeded)?
									resourcesNeededToSubGrpMap.get(resourceNeeded).Sub_Group__c:'',
									pse__Start_Date__c = Date.Today(),
									pse__End_Date__c = bhrIdBHRMap.get(proj.Bid_History__c).Bid_Due_Date__c,
									pse__SOW_Hours__c = 0.01,
									Is_Created_Automatically_Initial_Bid__c = autoRRFlag,
									Is_Created_Automatically__c = autoRRFlag,
									Regional_Analytics_Country__c = country);
									rrList.add(newRR);  
								}
							
							}
							else
							{
									pse__Resource_Request__c newRR = new pse__Resource_Request__c(
                                    recordTypeId = CON_OWF.OWF_RR_RECORD_TYPE_ID,
                                    currencyIsoCode = bhrIdBHRMap.get(proj.Bid_History__c).currencyIsoCode,
                                    pse__Project__c = proj.id,
                                    pse__Opportunity__c = proj.pse__Opportunity__c,
                                    pse__Group__c = proj.pse__Group__c,
                                    Account__c = bhrIdBHRMap.get(proj.Bid_History__c).Bid_History_Account__c,
                                    Bid_History__c = proj.Bid_History__c,
                                    SubGroup__c = resourcesNeededToSubGrpMap.containsKey(resourceNeeded)?
                                                                        resourcesNeededToSubGrpMap.get(resourceNeeded).Sub_Group__c:'',
                                    pse__Start_Date__c = Date.Today(),
                                    pse__End_Date__c = bhrIdBHRMap.get(proj.Bid_History__c).Bid_Due_Date__c,
                                    pse__SOW_Hours__c = 0.01,
                                    Is_Created_Automatically_Initial_Bid__c = autoRRFlag,
                                    Is_Created_Automatically__c = autoRRFlag );
                                    if(!CON_OWF.LP_RESOURCES_SET.contains(resourceNeeded)){
                                        rrList.add(newRR);
                                    }
                                }  
                            } 
                    }
                    else if(bhrIdBHRMap.containsKey(proj.Bid_History__c) && 
                               bhrIdBHRMap.get(proj.Bid_History__c).RecordTypeId ==
                                CON_OWF.OWF_RFI_BID_HISTORY_RECORD_TYPE_ID 
                           ) {
                                  pse__Resource_Request__c newRR = new pse__Resource_Request__c(
                                                         recordTypeId = CON_OWF.OWF_RR_RECORD_TYPE_ID,
                                                         currencyIsoCode = bhrIdBHRMap.get(proj.Bid_History__c).currencyIsoCode,
                                                         pse__Project__c = proj.id,
                                                         pse__Opportunity__c = proj.pse__Opportunity__c,
                                                         pse__Group__c = proj.pse__Group__c,
                                                         Account__c = bhrIdBHRMap.get(proj.Bid_History__c).Bid_History_Account__c,
                                                         Bid_Category__c = CON_OWF.RFI_RR,
                                                         Bid_History__c = proj.Bid_History__c,
                                                         SubGroup__c = CON_OWF.RFI_SUBGROUP,
                                                         pse__Start_Date__c = Date.Today(),
                                                         pse__End_Date__c = bhrIdBHRMap.get(proj.Bid_History__c).Bid_Due_Date__c,
                                                         pse__SOW_Hours__c = 0.01,
                                                         Is_Created_Automatically_Initial_Bid__c = true,
                                                         Is_Created_Automatically__c = true
                                                         );  

                            rrList.add(newRR);     
                           }
                    
                    else if(bhrIdBHRMap.containsKey(proj.Bid_History__c) && 
                            bhrIdBHRMap.get(proj.Bid_History__c).RecordTypeId ==
                            CON_OWF.OWF_CSMS_Bid_RECORD_TYPE_ID)
                    {
                        pse__Resource_Request__c newRR = new pse__Resource_Request__c(
                            recordTypeId = CON_OWF.OWF_RR_RECORD_TYPE_ID,
                            currencyIsoCode = bhrIdBHRMap.get(proj.Bid_History__c).currencyIsoCode,
                            pse__Project__c = proj.id,
                            pse__Opportunity__c = proj.pse__Opportunity__c,
                            pse__Group__c = proj.pse__Group__c,
                            Account__c = bhrIdBHRMap.get(proj.Bid_History__c).Bid_History_Account__c,
                            Bid_Category__c = bhrIdBHRMap.get(proj.Bid_History__c).Bid_Number__c > 1 ? 'Re-Bid': 'Initial',
                            Bid_History__c = proj.Bid_History__c,
                            SubGroup__c = CON_OWF.CSMS_LEAD_PD,
                            pse__Start_Date__c = Date.Today(),
                            pse__End_Date__c = bhrIdBHRMap.get(proj.Bid_History__c).Bid_Due_Date__c,
                            pse__SOW_Hours__c = 0.01,
                            Is_Created_Automatically_Initial_Bid__c = true,
                            Is_Created_Automatically__c = true
                        );
                        rrList.add(newRR);
                    }
                }
            }
        } 
        return rrList;
    }
    
    private static List<pse__Resource_Request__c> returnResourceRequestBasedOnProject(List<pse__Proj__c> newList) {
        List<pse__Resource_Request__c> resourceRequestToBeReturnedList = new List<pse__Resource_Request__c>();
         Set<String> resourceRequestFieldSet = new Set<String>{'Id'};
        Map<Id, pse__Proj__c> projectIdtoProjectMap= new Map<Id, pse__Proj__c>();
        for(pse__Proj__c project : newList)
        {
             if(project.recordTypeId == CON_OWF.OWF_BID_PROJECT_RECORD_TYPE_ID) {
                 projectIdtoProjectMap.put(project.ID, project );
             }             
        }
        if(projectIdtoProjectMap.size() > 0) {
            Map<Id, pse__Resource_Request__c> rrIdToResourceRequestMap = new SLT_Resource_Request(false,false).getResourceRequestByProjectID(projectIdtoProjectMap.keySet(),resourceRequestFieldSet );
            resourceRequestToBeReturnedList  = rrIdToResourceRequestMap.values();
        }
        return resourceRequestToBeReturnedList;
    } 
    
    public static void checkExistingProjectForAgreement(List<pse__Proj__c> newList){
        //system.debug('newList-->' + newList);
        Set<Id> agreementIdSet = new Set<Id>();
        for(pse__Proj__c project : newList){
            if(project.recordTypeId == CON_OWF.OWF_BID_PROJECT_RECORD_TYPE_ID && project.Bid_History__c != null){
                agreementIdSet.add(project.Bid_History__c);
            } 
        }
        if(agreementIdSet.size() > 0){
            List<pse__Proj__c> projectList = [Select id, Bid_History__c from pse__Proj__c where Bid_History__c IN: agreementIdSet];
            Map<Id,pse__Proj__c> agreementIdToProjectMap = new Map<Id,pse__Proj__c>();
            if(projectList.size() > 0){
                for(pse__Proj__c project : projectList){
                    agreementIdToProjectMap.put(project.Bid_History__c,project);
                }
                for(pse__Proj__c project : newList){
                    if(agreementIdToProjectMap.containsKey(project.Bid_History__c)){
                        project.addError('Project for this Agreement already Exists with record Id: ' + agreementIdToProjectMap.get(project.Bid_History__c).Id);
                    }
                }
            }
        }
    }
    public static void createRRForContractPostAwardBids(List<pse__Proj__c> newList){
        Map<Id,pse__Proj__c> bidHistoryIdToProjectMap = new  Map<Id,pse__Proj__c>();
        Set<Id> bidHistoryIdsSet = new Set<Id>();
        for(pse__Proj__c project : newList) {
            if(project.recordTypeId == CON_OWF.OWF_BID_PROJECT_RECORD_TYPE_ID && 
               project.Bid_History__c != NULL && project.pse__Opportunity__c != NULL){
                   bidHistoryIdsSet.add(project.Bid_History__c);   
                   bidHistoryIdToProjectMap.put(project.Bid_History__c,project);
            }
        }
        if(!bidHistoryIdsSet.isEmpty()){
            List<pse__Resource_Request__c> resReqs = UTL_OWF.createRRForContractPostAwardBid(bidHistoryIdsSet,bidHistoryIdToProjectMap);
            insert resReqs;
        }
    }
    public static void createRRForCSSBids(List<pse__Proj__c> newList){
        Map<Id,pse__Proj__c> bidHistoryIdToProjectMap = new  Map<Id,pse__Proj__c>();
        Set<Id> bidHistoryIdsSet = new Set<Id>();
        for(pse__Proj__c project : newList) {
            if(project.recordTypeId == CON_OWF.OWF_BID_PROJECT_RECORD_TYPE_ID && 
               project.Bid_History__c != NULL && project.pse__Opportunity__c != NULL){
                   bidHistoryIdsSet.add(project.Bid_History__c);   
                   bidHistoryIdToProjectMap.put(project.Bid_History__c,project);
            }
        }
        if(!bidHistoryIdsSet.isEmpty()){
            List<pse__Resource_Request__c> resReqs = UTL_OWF.createRRForCSSBid(bidHistoryIdsSet,bidHistoryIdToProjectMap);
            insert resReqs;
        }
    }
}