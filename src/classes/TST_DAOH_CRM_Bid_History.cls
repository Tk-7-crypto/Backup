@isTest
public class TST_DAOH_CRM_Bid_History {
    
    @testSetup
    static void setUpTestData() {
        Account testAccount = UTL_TestData.createAccount();
        insert testAccount;
        Indication_List__c indicationList = new Indication_List__c(Therapy_Area__c = 'Oncology');
        insert indicationList;
        pse__Grp__c grp = UTL_OWF_TestData.createGroup();
        insert grp;
        OWF_Config__c owfConfig = UTL_OWF_TestData.createOWFConfig(grp.Id);
        insert owfConfig;
        pse__Permission_Control__c permissionControlGroup = UTL_OWF_TestData.createPermissionControl(null, null, grp, null);
        insert permissionControlGroup;
        Opportunity testOpportunity= UTL_TestData.createOpportunity(testAccount.id);
        testOpportunity.Line_of_Business__c = CON_CPQ.SAMPLE_LINE_OF_BUSINESS;
        testOpportunity.Is_this_IQVIA_Biotech__c = CON_CPQ.YES_TITLE_CASE;
        testOpportunity.CurrencyIsoCode = CON_CPQ.USD;
        testOpportunity.Legacy_Quintiles_Opportunity_Number__c='MVP123';
        testOpportunity.Indication_List__c = indicationList.Id; 
        testOpportunity.Path_Probability__c = 'Advance to Potential';
        insert testOpportunity;
        
        Product2 testProduct = UTL_TestData.createProduct();
        insert testProduct;
        
        PricebookEntry testPricebookEntry = UTL_TestData.createPricebookEntry(testProduct.id);
        testPricebookEntry.CurrencyIsoCode = CON_CPQ.USD;
        testPricebookEntry.Pricebook2Id = Test.getStandardPricebookId();
        insert testPricebookEntry;
        
        List<Bid_History__c> testAgreementList = new List<Bid_History__c>();
        Bid_History__c agreement = UTL_OWF_TestData.createBidHistoryByRecordType(testAccount.Id, testOpportunity.Id, CON_CRM.CLINICAL_BID_BID_HISTORY_RECORD_TYPE_ID);
        testAgreementList.add(agreement);
        Bid_History__c agreement2 = UTL_OWF_TestData.createBidHistoryByRecordType(testAccount.Id, testOpportunity.Id, CON_CRM.EARLY_ENGAGEMENT_BID_BID_HISTORY_RECORD_TYPE_ID);
        agreement2.LQ_Bid_Histroy_Id__c = ''+System.now().time()+ 5;
        testAgreementList.add(agreement2);
        insert testAgreementList;
    }
    
    @isTest
    static void testUpdateRfpReceivedDate(){
        Bid_History__c agr = [SELECT Id,Bid_History_Related_Opportunity__c FROM Bid_History__c WHERE RecordType.DeveloperName = 'Clinical_Bid' LIMIT 1];
        Test.startTest();
            agr.Bid_Number__c = 1;
            agr.RFP_Received_Date__c = System.today();
            update agr;
        Test.stopTest();
        Opportunity opp = [SELECT Id,RFP_ReceivedDate__c FROM Opportunity Where Id = :agr.Bid_History_Related_Opportunity__c LIMIT 1];
        System.assertEquals(System.today(), opp.RFP_ReceivedDate__c);
    }
    
    @isTest
    static void testUpdateEarlyEngagementCOE(){
        Bid_History__c agr = [SELECT Id,Bid_History_Related_Opportunity__c FROM Bid_History__c WHERE RecordType.DeveloperName = 'Early_Engagement_Bid' LIMIT 1];
        Test.startTest();
            agr.TSSU_Early_Engagement_COE__c = 'Biosimilars';
            update agr;
        Test.stopTest();
        Opportunity opp = [SELECT Id,Early_Engagement_COE__c FROM Opportunity Where Id = :agr.Bid_History_Related_Opportunity__c LIMIT 1];
        System.assertEquals('Biosimilars', opp.Early_Engagement_COE__c);
    }
}