@istest
public with sharing class TST_OWF_CollectionToolCSSeTMFValidate {
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
        product.SAP_Code__c='Q_111815';
          product.ProductCode='Q_111815';
        insert product;
        
        OWF_Config__c owfConfig = UTL_OWF_TestData.createOWFConfig(grp.Id);
        insert owfConfig;
        
        Bid_History__c bidHistory = UTL_OWF_TestData.createBidHistoryByRecordType(acc.Id, opp.Id, CON_OWF.OWF_CSS_BID_BID_HISTORY_RECORD_TYPE_ID);
        bidHistory.Bid_Number__c = 0;
        bidHistory.Bid_Type__c = CON_CPQ.INITIAL;
        bidHistory.PCS__c = True;
        bidHistory.Bid_Category__c = 'Combined';
        bidHistory.Proposal_Deliverable__c = 'Experience tables and budget range';
        bidHistory.Rate_card_MSA_explanation__c = 'Test Class';
        bidHistory.Estimated_Fees__c = CON_OWF.ESTIMATED_FEE_LESS_THAN_5M;
        bidHistory.LPI_Date__c = System.today();
        bidHistory.DBL_Date__c = System.today();
        bidHistory.Number_of_Scenarios__c = 2;
        bidHistory.Requested_Services__c = 'CD - ECG';
        bidHistory.Cardiac_Safety_Equipment_Vendor__c = 'TT';
        bidHistory.Connected_Devices_Logistics_Vendor__c = 'Test';
        bidHistory.OWF_Potential_Regions__c = 'Latin America';
        bidHistory.Study_Start_Date__c =  system.today();
        bidHistory.Study_End_Date__c = system.today().addMonths(1);
        insert bidHistory;
        
        List<CollectionTool__c> listCollectionToolData = new List<CollectionTool__c>();
        CollectionTool__c collectionTool =  UTL_OWF_TestData.createCollectionTool(bidHistory.Id,product.id);
      	collectionTool.eTMF_Module__c = 'eTMF Essentials';
      	listCollectionToolData.add(collectionTool);
        
        CollectionTool__c collectionTool2 =  UTL_OWF_TestData.createCollectionTool(bidHistory.Id,product.id);
      	collectionTool2.eTMF_Module__c = 'eArchive';
      	listCollectionToolData.add(collectionTool2);
        CollectionTool__c collectionTool3 =  UTL_OWF_TestData.createCollectionTool(bidHistory.Id,product.id);
      	collectionTool3.eTMF_Module__c = 'Migration';
      	listCollectionToolData.add(collectionTool3);
        
        CollectionTool__c collectionTool4 =  UTL_OWF_TestData.createCollectionTool(bidHistory.Id,product.id);
      	collectionTool4.eTMF_Module__c = 'eTMF SaaS Subscription';
      	listCollectionToolData.add(collectionTool4);
        insert listCollectionToolData;
        
        Test.stopTest();        
    }
    @istest
    public static void validate()
    {
            Bid_History__c bidHistory = [Select Id,RecordTypeId from  Bid_History__c where RecordTypeId = : CON_OWF.OWF_CSS_BID_BID_HISTORY_RECORD_TYPE_ID LIMIT 1];
            List<CollectionTool__c> collectionTool  = [Select Id,eTMF_Module__c,Number_of_Sites__c,Number_of_Studies__c,Number_of_Documents__c,Source_of_TMFs__c from  CollectionTool__c where Bid_History__c =: bidHistory.Id  ];
        	Test.startTest();
          OWF_GenericCollectionToolHelper helper = new OWF_GenericCollectionToolHelper(bidHistory.Id, 'CSS_4_eTMF');
        	OWF_GenericCollectionToolHelper.CollectionToolData collectionData = helper.getCollectionData();
     		OWF_CollectionToolCSSeTMFValidate obj = new OWF_CollectionToolCSSeTMFValidate();
        	Set<String> errors = obj.validate(collectionData.config,collectionTool);
        	Test.stopTest(); 
        	System.assertEquals(3,errors.size());
        
    }
}