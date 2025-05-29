@isTest
public class TST_CNT_OWF_BidHistoryWarningMessage {
     @testSetup
    static void dataSetup() {
        Test.startTest();
        Account acc = UTL_TestData.createAccount();
        insert acc;
        
        Opportunity opp = UTL_TestData.createOpportunity(acc.Id);
        insert opp;

        Bid_History__c bidHistory = UTL_OWF_TestData.createBidHistoryByRecordType(acc.Id, opp.Id, CON_OWF.OWF_Q2_Solutions_BID_HISTORY_RECORD_TYPE_ID);
        bidHistory.Q2_Business_Area__c = 'BioSciences';
        bidHistory.Bid_Type__c = 'Initial';
        bidHistory.Study_Number__c='02';
        insert bidHistory;

        Product2 product = UTL_TestData.createProduct();
        product.SAP_Code__c='Q_111814';
        product.ProductCode='Q_111814';
        insert product; 
        CollectionTool__c collectionTool = UTL_OWF_TestData.createCollectionTool(bidHistory.Id,product.id);
        collectionTool.Scenario_Number__c = 1.00;
        collectionTool.recordTypeId = CON_OWF.OWF_COLLECTIONTOOL_Q2_Solutions_RECORD_TYPE_ID;
        insert collectionTool;
        Test.StopTest();
    }
    @isTest
    public static void testgetBidHistoryData1(){
        Test.startTest();
        List<Bid_History__c> bidHistoryList = [Select id from Bid_History__c];
        CNT_OWF_BidHistoryWarningMessage.getBidHistoryData(bidHistoryList.get(0).id);
        Test.StopTest();
        system.assertEquals(CNT_OWF_BidHistoryWarningMessage.getBidHistoryData(bidHistoryList.get(0).id),true);
    }
     @isTest
    public static void testgetBidHistoryData2(){
        Test.startTest();
        List<Bid_History__c> bidHistoryList = [Select id from Bid_History__c];
        List<Product2> Product2List = [Select id from Product2];
        CollectionTool__c collectionTool = UTL_OWF_TestData.createCollectionTool(bidHistoryList.get(0).id,Product2List.get(0).id);
        collectionTool.Scenario_Number__c = 1.00;
        collectionTool.recordTypeId = CON_OWF.OWF_COLLECTIONTOOL_Q2_Solutions_RECORD_TYPE_ID;
        insert collectionTool;
        CNT_OWF_BidHistoryWarningMessage.getBidHistoryData(bidHistoryList.get(0).id);
        Test.StopTest();
        system.assertEquals(CNT_OWF_BidHistoryWarningMessage.getBidHistoryData(bidHistoryList.get(0).id),false);
    }
}