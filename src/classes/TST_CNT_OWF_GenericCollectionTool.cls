@isTest
public class TST_CNT_OWF_GenericCollectionTool {
    @testSetup
    private static void setupData() {
        Test.startTest();
        Account acc = UTL_TestData.createAccount();
        insert acc;
        
        Opportunity opp = UTL_TestData.createOpportunity(acc.Id);
        insert opp;
        pse__Grp__c grp = UTL_OWF_TestData.createGroup();
        insert grp;
        
        OWF_Config__c owfConfig = UTL_OWF_TestData.createOWFConfig(grp.Id);
        insert owfConfig;
        List<OWF_Resources_Needed_to_SubGroup_Map__c> resourceToSubGroupSettingList = new List<OWF_Resources_Needed_to_SubGroup_Map__c>();
        resourceToSubGroupSettingList.add(new OWF_Resources_Needed_to_SubGroup_Map__c(
            Resources_Needed__c = 'MSL',
            Sub_Group__c = 'Medical-MSL',
            Name = 'MSL'
        ));
        
        insert resourceToSubGroupSettingList;
        
        Bid_History__c bidHistory = UTL_OWF_TestData.createBidHistoryByRecordType(acc.Id, opp.Id, CON_OWF.OWF_Q2_Solutions_BID_HISTORY_RECORD_TYPE_ID);
        bidHistory.Q2_Business_Area__c = 'BioSciences';
        bidHistory.Bid_Type__c = 'Initial';
        bidHistory.Study_Number__c = '02';
        insert bidHistory;

        Bid_History__c gccBidHistory = UTL_OWF_TestData.createBidHistoryByRecordType(acc.Id, opp.Id, CON_OWF.OWF_GCC_SHORT_FORM_BID_HISTORY_RECORD_TYPE_ID);
        gccBidHistory.Bid_History_Status__c = CON_OWF.OWF_BID_HISTORY_STATUS_AWAITING_CUSTOMER_FEEDBACK;
        gccBidHistory.Opportunity_Type__c = CON_OWF.OWF_BID_HISTORY_OPPORTUNITY_TYPE_INTERNAL;
        gccBidHistory.RFP_Deliverables__c = CON_OWF.OWF_BID_HISTORY_RFP_DELIVERABLES_HIGH_LEVEL_COST;
        gccBidHistory.One_Off_Fees_For_Service_Implementation__c = 50;
        gccBidHistory.Number_of_Scenarios__c = 1;
        insert gccBidHistory;
        
        Bid_History__c bidHistory2 = UTL_OWF_TestData.createBidHistoryByRecordType(acc.Id, opp.Id, CON_OWF.OWF_CSS_BID_BID_HISTORY_RECORD_TYPE_ID);
        bidHistory2.Bid_Number__c = 0;
        bidHistory2.Bid_Type__c = CON_CPQ.INITIAL;
        bidHistory2.PCS__c = True;
        bidHistory2.Payments_Forecasting__c = true;
        bidHistory2.eCOA__c = true;
        bidHistory2.Complete_Consent__c	 = true;
        bidHistory2.Grant_Plan__c = true;
        bidHistory2.eTMF__c = true;
        bidHistory2.Risk_Based_Monitoring__c = true;
        bidHistory2.Site_Portal__c = true;
        bidHistory2.Clinical_Trial_Payments__c = true;
        bidHistory2.IRT__c = true;
        bidHistory2.One_Home_for_Sites__c = true;
        bidHistory2.Participant_Payments__c = true;
        bidHistory2.Bid_Category__c = 'Combined';
        bidHistory2.Proposal_Deliverable__c = 'Experience tables and budget range';
        bidHistory2.Rate_card_MSA_explanation__c = 'Test Class';
        bidHistory2.Estimated_Fees__c = CON_OWF.ESTIMATED_FEE_LESS_THAN_5M;
        bidHistory2.LPI_Date__c = System.today();
        bidHistory2.DBL_Date__c = System.today();
        bidHistory2.Number_of_Scenarios__c = 2;
        bidHistory2.Requested_Services__c = 'CD - ECG';
        bidHistory2.Cardiac_Safety_Equipment_Vendor__c = 'TT';
        bidHistory2.Connected_Devices_Logistics_Vendor__c = 'Test';
        bidHistory2.OWF_Potential_Regions__c = 'Latin America';
        bidHistory2.Study_Start_Date__c =  system.today();
        bidHistory2.Study_End_Date__c = system.today().addMonths(1);
        insert bidHistory2;

        Bid_History__c techSolutionsSUpportRequestBidHistory = UTL_OWF_TestData.createBidHistoryByRecordType(acc.Id, opp.Id, CON_OWF.OWF_TECH_SOLUTIONS_SUPPORT_REQUEST_BID_HISTORY_RECORD_TYPE_ID);
        techSolutionsSUpportRequestBidHistory.Do_You_Need_Global_RFP_Team_Support__c = FALSE;
        techSolutionsSUpportRequestBidHistory.Do_You_Need_Global_SE_Support__c = TRUE;
        techSolutionsSUpportRequestBidHistory.Bid_Due_Date__c = NULL;
        techSolutionsSUpportRequestBidHistory.Safety_Technologies__c = TRUE;
        insert techSolutionsSUpportRequestBidHistory;
        
        Test.stopTest();        
    }
    
    @isTest
    private static void testGetCollectionDataQ2SolutionBioScieces() {
        Bid_History__c bidHistory = [Select Id from  Bid_History__c WHERE RecordTypeId = : CON_OWF.OWF_Q2_Solutions_BID_HISTORY_RECORD_TYPE_ID LIMIT 1];
        Test.startTest();
        	OWF_GenericCollectionToolHelper.CollectionToolData collectionData =
                CNT_OWF_GenericCollectionTool.getCollectionData(bidHistory.Id,null);
        Test.stopTest();
        System.assertEquals(true, collectionData.tables.size() == 2);
    }
    
    @isTest
    private static void testSaveCollectionDataQ2SolutionBioScieces() {
        Bid_History__c bidHistory = [Select Id from  Bid_History__c WHERE RecordTypeId =: CON_OWF.OWF_Q2_Solutions_BID_HISTORY_RECORD_TYPE_ID LIMIT 1];
        OWF_GenericCollectionToolHelper.CollectionToolData collectionConfig =  CNT_OWF_GenericCollectionTool.getCollectionData(bidHistory.Id,null);
        Test.startTest();
            try {
                CNT_OWF_GenericCollectionTool.saveCollectionData(bidHistory.Id, JSON.serialize(collectionConfig.tables),null);
            } catch (Exception e) {
                throw new AuraHandledException(e.getMessage());
            }
        Test.stopTest();
        List<CollectionTool__c> collectionTool  = [Select Id from  CollectionTool__c where Bid_History__c =: bidHistory.Id];
        System.assertEquals(2, collectionTool.size());        
    }
    
    @isTest
    private static void testGetCollectionDataError() {
        try{
            Test.startTest(); 
                OWF_GenericCollectionToolHelper.CollectionToolData collectionConfig =  CNT_OWF_GenericCollectionTool.getCollectionData('aNXKQ000000013f4AA',null);
            Test.stopTest();
        } catch(Exception e) {}
    }
    
    @isTest
    private static void testGetCollectionDataQ2SolutionNoConfigFound() {
        Bid_History__c bidHistory = [Select Id from  Bid_History__c WHERE RecordTypeId = : CON_OWF.OWF_Q2_Solutions_BID_HISTORY_RECORD_TYPE_ID LIMIT 1];
        bidHistory.Q2_Business_Area__c = null;
        Update bidHistory;
        try{
            Test.startTest();
                OWF_GenericCollectionToolHelper.CollectionToolData collectionData =
                    CNT_OWF_GenericCollectionTool.getCollectionData(bidHistory.Id,null);
            Test.stopTest();
        } catch(Exception e) {}
    }
    @isTest
    private static void testgetConfig() {
        Bid_History__c bidHistory = [Select Id,RecordTypeId from  Bid_History__c where RecordTypeId = : CON_OWF.OWF_CSS_BID_BID_HISTORY_RECORD_TYPE_ID LIMIT 1];
        Bid_History__c bidHistory2 = [Select Id,RecordTypeId from  Bid_History__c where RecordTypeId = : CON_OWF.OWF_Q2_Solutions_BID_HISTORY_RECORD_TYPE_ID LIMIT 1];
        Bid_History__c bidHistory3 = [Select Id,RecordTypeId from  Bid_History__c where RecordType.name =: CON_OWF.RECORD_TYPE_GCC LIMIT 1];
        Bid_History__c bidHistory4 = [Select id,RecordTypeId, Name, Bid_Due_Date__c from Bid_History__c where RecordTypeId = :CON_OWF.OWF_TECH_SOLUTIONS_SUPPORT_REQUEST_BID_HISTORY_RECORD_TYPE_ID];
        try{
            Test.startTest();
            CNT_OWF_GenericCollectionTool.getConfig(bidHistory.Id);
            CNT_OWF_GenericCollectionTool.getConfig(bidHistory2.Id);
            CNT_OWF_GenericCollectionTool.getConfig(bidHistory3.Id);
            CNT_OWF_GenericCollectionTool.getConfig(bidHistory4.Id);
            Test.stopTest();
        } catch(Exception e) {}
    }
    @IsTest
    private static void getConfigNameTest() {
        Bid_History__c bidHistory2 = [Select Id,RecordTypeId from  Bid_History__c where RecordTypeId = : CON_OWF.OWF_Q2_Solutions_BID_HISTORY_RECORD_TYPE_ID LIMIT 1];
        Bid_History__c bidHistory3 = [Select Id,RecordTypeId from  Bid_History__c where RecordType.name =: CON_OWF.RECORD_TYPE_GCC LIMIT 1];
        Test.startTest();
            CNT_OWF_GenericCollectionTool.getCollectionData(bidHistory2.Id,null);
            CNT_OWF_GenericCollectionTool.getCollectionData(bidHistory3.Id,null);
        	bidHistory2.Q2_Business_Area__c = CON_OWF.Q2_BUSINESS_AREA_VACCINES;
        	update bidHistory2;
            CNT_OWF_GenericCollectionTool.getCollectionData(bidHistory2.Id,null);
        	bidHistory2.Q2_Business_Area__c = CON_OWF.Q2_BUSINESS_AREA_DISCOVERY;
        	update bidHistory2;
        	CNT_OWF_GenericCollectionTool.getCollectionData(bidHistory2.Id,null);
        Test.stopTest();
    }
}