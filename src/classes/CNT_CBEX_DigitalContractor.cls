/**************************************************************************************************
* @Author:      Ashish Verma
* @Date:        29/11/2022
* @PageCode:    
* @CurErrCode: 
* @Description: IQVIACBEX-2837: This is a class for callout to Digi Contractor API and fetch cost estimates based on Bid and Opportunity data
* @Revision(s): [Date] - [Change Reference] - [Changed By] - [Description]   
***************************************************************************************************/
public class CNT_CBEX_DigitalContractor {
    /**********************************************************************************************
    * @Author:      Ashish
    * @Date:        29/11/2022
    * @Description: IQVIACBEX-2837: This method is called from Flow to parse bid record data 
    * @Revision(s): [Date] - [Change Reference] - [Changed By] - [Description]   
    ***********************************************************************************************/ 
    @InvocableMethod(label = 'Get Cost'description = ''category = 'Callout')
    public static void getCostEstimation(List<String> bidsIdList ) {
        //Add all required fields which are to be passed in Request params
        Set<String> agreementFieldSet = new Set<String>{'Id', 'OwnerId','Therapeutic_Area__c',
            'Phase__c','Patients_Enrolled__c','Number_of_Sites__c','Bid_History_Related_Opportunity__r.Id',
            'Bid_History_Related_Opportunity__r.Potential_Regions__c'};
                if(bidsIdList.size() > 1) {
                    return;
                }
        Bid_History__c bidRecord;
        //Fetch bid history and related data
        Map<Id, Bid_History__c> idToBidHistoryMap = new SLT_Bid_History(false,false).getBidHistoriesById(new Set<Id>{(Id)bidsIdList[0]},agreementFieldSet);
        //contain the values of map in a list and then the current record
        List<Bid_History__c> bidsList = new List<Bid_History__c>();
        bidsList.addall(idToBidHistoryMap.values());
        bidRecord = bidsList[0];
        
        //Call the method to fetch and match metadata records with selected regions
        Map<String, boolean> regionBooleanMap = getAllPotentialRegionsForBid(bidRecord.Bid_History_Related_Opportunity__r.Potential_Regions__c);
        
        //Create wrapper instance and populate values for all elements
        CNT_CBEX_BidWrapper bidWrapperObj = new CNT_CBEX_BidWrapper();
        bidWrapperObj.therapeutic_area = bidRecord.Therapeutic_Area__c;
        bidWrapperObj.phase = getPhaseValue(bidRecord.Phase__c);		//As Phase value are String in Salesforce, we need to convert to an integer for DC request
        bidWrapperObj.total_patients = (Integer)bidRecord.Patients_Enrolled__c;
        bidWrapperObj.total_sites = (Integer)bidRecord.Number_of_Sites__c;
        bidWrapperObj.regions = regionBooleanMap;						//Fetch Regions from Opportunity and convert them to a map for DC request
        //Callout to DC API with parameters
        if(!System.isFuture()){
            getCost(bidsIdList.get(0), JSON.serialize(bidWrapperObj), bidRecord.Bid_History_Related_Opportunity__r.Id);
        }
    }
    
    /**********************************************************************************************
    * @Author:      Ashish
    * @Date:        29/11/2022
    * @Description: IQVIACBEX-2837: This method makes callout to DC API with required parameters
    * @Revision(s): [Date] - [Change Reference] - [Changed By] - [Description]   
    ***********************************************************************************************/ 
    @future(callout = true)
    public static void getCost(String bidId, String payload, String opportunityId) {
        HttpResponse response = new HttpResponse();
        try{
            //As Digital Contractor API is accessible only over company network, we are hitting Mulesoft(in IQVIA VPN) API endpoint
            response = SRV_CBEX_PriceModularCallOuts.getCostPriceModuleAPICall(payload);
            // Parse the JSON response
            if (response.getStatusCode() == 200) {        
                CNT_CBEX_Response_Wrapper wrapper = ( CNT_CBEX_Response_Wrapper ) JSON.deSerialize( response.getBody(), CNT_CBEX_Response_Wrapper.class );
                //Update the DC estimate value 
                updateOpportunity(opportunityId,wrapper.cost);
            } else {
                //creating the Audi logs
                insertIntegrationLogs(payload, response.getbody());
            }
        } catch(exception ex) {
             //creating the Audi logs
            insertIntegrationLogs(payload, ex.getMessage());
        }        
    }
    
    /**********************************************************************************************
    * @Author:      Ashish
    * @Date:        29/11/2022
    * @Description: IQVIACBEX-2837: get All mappings from metadata and match with selected regions and then return a map of Digi regions with boolean
    * @Revision(s): [Date] - [Change Reference] - [Changed By] - [Description]   
    ***********************************************************************************************/
    public static Map<String, Boolean> getAllPotentialRegionsForBid(String selectedRegionsFromOpportunity) {
        List<String> lstAlpha = selectedRegionsFromOpportunity.split(';');
        List<DC_Regions_with_Opportunity_mapping__mdt> ropList = DC_Regions_with_Opportunity_mapping__mdt.getAll().values();
        Map<String, Boolean> mapForJSON = new Map<String,Boolean>();
        for(DC_Regions_with_Opportunity_mapping__mdt mdtRecord : ropList) {
            if(lstAlpha.contains(mdtRecord.Potential_Region__c)) {
                mapForJSON.put(mdtRecord.Digital_Contractor_Region__c, true);
            } else {
                mapForJSON.put(mdtRecord.Digital_Contractor_Region__c, false);
            }
        }
        return mapForJSON;
    }
    
    /**********************************************************************************************
    * @Author:      Ashish
    * @Date:        29/11/2022
    * @Description: IQVIACBEX-2837: get phase value in required format.
    * @Revision(s): [Date] - [Change Reference] - [Changed By] - [Description]   
    ***********************************************************************************************/
    public static String getPhaseValue(String phaseString){
        switch on phaseString {
            when 'Phase 1' {		// when Phase 1
                return '1';
            }
            when 'Phase 2' {		// when phase 2
                return '2';
            }
            when 'Phase 3' {		// when phase 3
                return '3';
            }
            when 'Phase 3b' {		// when phase 3b
                return '3';
            }
            when 'Phase 4' {		// when phase 4
                return '4';
            }
            when null {
                phaseString = '';
                return 'N/A';
            }
            when else {		  // when else block, optional
                return 'N/A';
            }
        }
    }
    public class CNT_CBEX_Response_Wrapper {
        public Decimal cost;
    }
    
    /**********************************************************************************************
    * @Author:      Ashish
    * @Date:        29/11/2022
    * @Description: IQVIACBEX-2837: Wrapper to contain all required parameters for callout.
    * @Revision(s): [Date] - [Change Reference] - [Changed By] - [Description]   
    ***********************************************************************************************/
    public class CNT_CBEX_BidWrapper {
        String therapeutic_area;
        String phase;
        Integer total_patients;
        Integer total_sites;
        Map<String,Boolean> regions;  
    }
    
  	/**********************************************************************************************
    * @Author:      Ashish
    * @Date:        29/11/2022
    * @Description: IQVIACBEX-2837: insert logs in Apex error logs
    * @Revision(s): [Date] - [Change Reference] - [Changed By] - [Description]   
    ***********************************************************************************************/
    public static void insertIntegrationLogs(String requestString, String responseString){
        Apex_Error_Log__c errorLogInstance = new Apex_Error_Log__c();
        errorLogInstance.Source_Module__c = 'CBEX DIGITAL CONTRACTOR API (fetch Cost estimates from Webservice)';
        errorLogInstance.Failed_Job_Type__c = 'WebService (REST)';
        if(requestString!=null) {
            errorLogInstance.Job_Request_JSON__c = requestString;
        }
        errorLogInstance.Job_Response_JSON__c = responseString;
        errorLogInstance.Running_User__c = UserInfo.getUserId();
        errorLogInstance.Record_Processed_Date__c = system.today();
        errorLogInstance.Object__c = 'Opportunity';
        errorLogInstance.Record_Processed__c = false;
        errorLogInstance.Error_Message__c = 'API Response: ' + responseString ;
        fflib_SObjectUnitOfWork uowForAPexErrorLog = new fflib_SObjectUnitOfWork(
            new Schema.SObjectType[] {
                Apex_Error_Log__c.SObjectType   
            });
        uowForAPexErrorLog.registerNew(errorLogInstance);
        uowForAPexErrorLog.commitwork();
    }
    
    public static void updateOpportunity(String OpportunityId,Decimal cost){
        Opportunity opp = new Opportunity();        
        opp.id = (ID)OpportunityId;
        // Update DC estimate value whic will in turn update the formula field- Price Modeler value
        opp.Digital_Contractor_Estimate__c = cost;
         fflib_SObjectUnitOfWork uowForOpportunity = new fflib_SObjectUnitOfWork(
            new Schema.SObjectType[] {
                Opportunity.SObjectType   
            });
        uowForOpportunity.registerDirty(opp);
        UTL_ExecutionControl.stopTriggerExecution = true;
        uowForOpportunity.commitwork();
        UTL_ExecutionControl.stopTriggerExecution = false;
    }
    
}