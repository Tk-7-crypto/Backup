@istest
public class TST_TGR_CollectionTool {
@testSetup
  private static void setupData() {
        Test.startTest();
        Account acc = UTL_TestData.createAccount();
        insert acc;        
        Opportunity opp = UTL_TestData.createOpportunity(acc.Id);
        insert opp;
        pse__Grp__c grp = UTL_OWF_TestData.createGroup();
        insert grp;
        Product2 product = UTL_TestData.createProduct();
        product.SAP_Code__c='Q_111814';
        product.ProductCode='Q_111814';
        insert product; 
        Bid_History__c bidHistory = UTL_OWF_TestData.createBidHistoryByRecordType(acc.Id, opp.Id, CON_OWF.OWF_Q2_Solutions_BID_HISTORY_RECORD_TYPE_ID);
        bidHistory.Q2_Business_Area__c = 'BioSciences';
        bidHistory.Bid_Type__c = 'Initial';
        bidHistory.Study_Number__c='02';
        insert bidHistory;
        List<CollectionTool__c> listCollectionToolData = new List<CollectionTool__c>();
        CollectionTool__c collectionTool = UTL_OWF_TestData.createCollectionTool(bidHistory.Id,product.id);
        collectionTool.Countries__c = 'United States of America';
        collectionTool.Site_Global__c='Ithaca';
        collectionTool.RecordTypeId = CON_OWF.OWF_COLLECTIONTOOL_Q2_Solutions_RECORD_TYPE_ID;
        collectionTool.ServiceLine__c=product.id;
        collectionTool.Type__c = 'BioSciences';
        collectionTool.Bid_History__c = bidHistory.Id;
        collectionTool.Number_of_Sites__c = 2.00;
        collectionTool.Description_if_not_within_library__c = 'NA';
        collectionTool.COA_Library_Assessment__c = '01_Not within Library'; 
        collectionTool.Select_Device_Type__c = 'Tablet';
        collectionTool.Specific_Device_Strategy__c = 'TEST';   
        collectionTool.Scenario_Number__c = 1.00;
        collectionTool.Number_of_Enrolled_Patients__c = 10.00;
        listCollectionToolData.add(collectionTool);
        CollectionTool__c collectionTool2 = UTL_OWF_TestData.createCollectionTool(bidHistory.Id,product.id);
        collectionTool2.Countries__c = 'United States of America';
        collectionTool2.Site_Global__c='Indianapolis - ADME';
        collectionTool2.ServiceLine__c=product.id;
        collectionTool2.Bid_History__c = bidHistory.Id;
        collectionTool.Type__c = 'BioSciences';
        collectionTool2.Number_of_Sites__c = 2.00;
        collectionTool2.Description_if_not_within_library__c = 'NA';
        collectionTool.RecordTypeId = CON_OWF.OWF_COLLECTIONTOOL_Q2_SOLUTIONS_RECORD_TYPE_ID;
        collectionTool2.COA_Library_Assessment__c = '01_Not within Library'; 
        collectionTool2.Select_Device_Type__c = 'Tablet';
        collectionTool2.Specific_Device_Strategy__c = 'TEST';   
        collectionTool2.Scenario_Number__c = 1.00;
        collectionTool2.Number_of_Enrolled_Patients__c = 10.00;
        listCollectionToolData.add(collectionTool2);
        insert listCollectionToolData;
        
        Test.stopTest();
       
    }
    @isTest
    private static void testRevId() {
        List<CollectionTool__c> collectionRecords = [Select Id,Rev_Lab_ID__c from CollectionTool__c];
        List<OWF_Q2_RevLabId_Matrix__mdt> revLabMetadata = [Select Id,DeveloperName, Site__c ,Rev_Lab_Id__c ,Service_Line__c From OWF_Q2_RevLabId_Matrix__mdt];
        if(!revLabMetadata.isEmpty()){
        System.assertEquals(true,collectionRecords[0].Rev_Lab_ID__c!=null,'revId updated');
        }
    }   
}