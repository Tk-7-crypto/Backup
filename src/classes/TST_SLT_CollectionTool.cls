@isTest
private class TST_SLT_CollectionTool {
    
    @testSetup
    static void dataSetup() {
        Account testAccount = UTL_OWF_TestData.createAccount();
        Insert testAccount;
        
        Opportunity testOpp = UTL_OWF_TestData.createOpportunity(testAccount.Id);
        Insert testOpp;
        
        pse__Grp__c grp = UTL_OWF_TestData.createGroup();
        insert grp;
        
        OWF_Config__c owfConfig = UTL_OWF_TestData.createOWFConfig(grp.Id);
        insert owfConfig;
        
        RecordType testRecordtypeCSSBid = [Select id from RecordType where name = 'CSS Bid' and SObjectType = 'Bid_History__c'];
        
        Bid_History__c testBidHistory = UTL_OWF_TestData.createBidHistoryByRecordType(testAccount.Id, testOpp.Id, testRecordtypeCSSBid.Id);
        testBidHistory.Number_of_Scenarios__c = 3.00;
        testBidHistory.eCOA__c = true;
        testBidHistory.Rate_card_MSA_explanation__c ='test';
        Insert testBidHistory;
        
        List<CollectionTool__c> listECOAtool = new List<CollectionTool__c>();
        CollectionTool__c eCOA1 = new CollectionTool__c();
        eCOA1.Countries__c = 'United States of America';
        eCOA1.Bid_History__c = testBidHistory.Id;
        eCOA1.Number_of_Sites__c = 2.00;
        eCOA1.Description_if_not_within_library__c = 'NA';
        eCOA1.COA_Library_Assessment__c = '01_Not within Library'; 
        eCOA1.Select_Device_Type__c = 'Tablet';
        eCOA1.Specific_Device_Strategy__c = 'TEST';   
        eCOA1.Scenario_Number__c = 1.00;
        eCOA1.Study_Number__c = 1;
        eCOA1.Number_of_Enrolled_Patients__c = 10.00;
        listECOAtool.add(eCOA1);
        insert listECOAtool;
    }
    
    @isTest
    public static void testGetCollectionToolsByCondition() {
        Bid_History__c testBidHistory = [Select id, Number_of_Scenarios__c from Bid_History__c limit 1];
        Set<String> fieldSet =  (new Set<String> {'Id', 'Name'});
        
        Test.startTest();
       		List<CollectionTool__c> collectionToolList1 = new SLT_CollectionTool(false, false).getCollectionToolsByCondition(testBidHistory.Id, fieldSet, '');
            List<CollectionTool__c> collectionToolList2 = new SLT_CollectionTool(false).getCollectionToolsByCondition(testBidHistory.Id, fieldSet, '');
            List<CollectionTool__c> collectionToolList3 = new SLT_CollectionTool().getCollectionToolsByCondition(testBidHistory.Id, fieldSet, '');
        	List<CollectionTool__c> collectionToolList4 = new SLT_CollectionTool(false, false).getCollectionToolsByBidHistoryId(testBidHistory.Id, fieldSet);
        Test.stopTest();
        
        System.assertEquals(1, collectionToolList1.size(), 'Test: testGetCollectionToolsByCondition');
        System.assertEquals(1, collectionToolList2.size(), 'Test: testGetCollectionToolsByCondition');
        System.assertEquals(1, collectionToolList3.size(), 'Test: testGetCollectionToolsByCondition');
        System.assertEquals(1, collectionToolList4.size(), 'Test: testGetCollectionToolsByCondition');
    }

    @isTest 
    static void testCollectionToolRecords() { 
        Bid_History__c bidHistory = [Select Id From Bid_History__c limit 1];
        List<CollectionTool__c> collectionToolRecord = new List<CollectionTool__c>();
        String ctRecordTypeID = Schema.getGlobalDescribe().get('CollectionTool__c').getDescribe().getRecordTypeInfosByName().get(CON_CPQ.IQVIA_TECHNOLOGIES).getRecordTypeId();
        CollectionTool__c collectionToolRecord1 = new CollectionTool__c(Bid_History__c = bidHistory.Id, Countries__c = 'United States of America', Scenario_Number__c = 1, Type__c = 'Other', RecordTypeId = ctRecordTypeID);
        collectionToolRecord.add(collectionToolRecord1);
        CollectionTool__c collectionToolRecord2 = new CollectionTool__c(Bid_History__c = bidHistory.Id, Countries__c = 'United States of America', Scenario_Number__c = 2, Type__c = 'Other', RecordTypeId = ctRecordTypeID);
        collectionToolRecord.add(collectionToolRecord2);
        insert collectionToolRecord;
        
        Set<String> collectionToolFieldSet = new Set<String> {'Id','Scenario_Number__c'};
        String condition = 'Bid_History__c = \'' + bidHistory.Id + '\'';
        Test.startTest();
            List<CollectionTool__c> collectionToolRecordList = new SLT_CollectionTool().getCollectionToolRecords(condition, collectionToolFieldSet);
        Test.stopTest(); 
        System.assertEquals(collectionToolRecord.size(), collectionToolRecordList[0].Scenario_Number__c);
    }

    @isTest
    public static void testGetCollectionToolsByConditionOrderByStudyNumber() {
        Bid_History__c testBidHistory = [SELECT id, Study_Number__c, Number_of_Scenarios__c FROM Bid_History__c LIMIT 1];
        Test.startTest();
       		List<CollectionTool__c> collectionToolList = new SLT_CollectionTool(false, false).getCollectionToolsByConditionOrderByStudyNumber(testBidHistory.Id, new Set<String> {CON_CPQ.ID, CON_CPQ.NAME}, '');
        Test.stopTest();
        Assert.areEqual(1, collectionToolList.size(), 'Expected result is not returned.');
    }
}