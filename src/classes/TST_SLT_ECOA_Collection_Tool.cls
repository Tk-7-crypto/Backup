@isTest
private class TST_SLT_ECOA_Collection_Tool {
	
    @testSetup
    static void dataSetup() 
	{
        Account testAccount = UTL_OWF_TestData.createAccount();
        Insert testAccount;
        Opportunity testOpp =UTL_OWF_TestData.createOpportunity(testAccount.Id);
        Insert testOpp;
        pse__Grp__c grp = UTL_OWF_TestData.createGroup();
        insert grp;
        OWF_Config__c owfConfig = UTL_OWF_TestData.createOWFConfig(grp.Id);
        insert owfConfig;
        RecordType testRecordtypeCollectionTool = [Select id from RecordType where name = 'Applicable to Others' and SObjectType ='ECOA_Collection_Tool__c'];
        RecordType testRecordtypeCSSBid = [Select id from RecordType where name = 'CSS Bid' and SObjectType ='Bid_History__c'];
        Bid_History__c testBidHistory =UTL_OWF_TestData.createBidHistoryByRecordType(testAccount.Id, testOpp.Id, testRecordtypeCSSBid.Id);
        testBidHistory.Number_of_Scenarios__c = 3.00;
        testBidHistory.eCOA__c=true;
        testBidHistory.Rate_card_MSA_explanation__c ='test';
        Insert testBidHistory;
        List<ECOA_Collection_Tool__c> listECOAtool = new List<ECOA_Collection_Tool__c>();
        ECOA_Collection_Tool__c eCOA1 = new ECOA_Collection_Tool__c();
        eCOA1.List_the_Countries_No_abbreviations__c = 'United States of America';
        eCOA1.Bid_History__c = testBidHistory.Id;
        eCOA1.Number_of_Sites__c =2.00;
        eCOA1.Description_if_not_within_library__c = 'NA';
        eCOA1.RecordTypeId = testRecordtypeCollectionTool.Id;
        eCOA1.COA_Library_Assessment__c = '01_Not within Library'; 
        eCOA1.Select_Device_Type__c = 'Tablet';
        eCOA1.Specific_Device_Strategy__c = 'TEST';   
        eCOA1.Scenario_Number__c =1.00;
        eCOA1.Number_of_Enrolled_Patients__c = 10.00;
        listECOAtool.add(eCOA1);
        insert listECOAtool;
    }
    @isTest
    public static void testGetEcoaCollectionToolByBidHistoryId(){
        RecordType testRecordtypeCollectionTool = [Select id from RecordType where name = 'Applicable to Others' and SObjectType ='ECOA_Collection_Tool__c'];
		Bid_History__c testBidHistory =[Select id,Number_of_Scenarios__c from Bid_History__c limit 1];
        Set<String> fieldSet =  new Set<String>{ 'Id', 'Number_of_Enrolled_Patients__c', 'Number_of_Sites__c', 'Scenario_Number__c', 'Bid_History__c',
                                                'Description_if_not_within_library__c', 'Specific_Device_Strategy__c', 'COA_Library_Assessment__c', 
                                                'Select_Device_Type__c', 'Bid_History__r.Number_of_Scenarios__c', 'List_the_Countries_No_abbreviations__c' };
        String condition = 'AND RecordType.Id = \''+testRecordtypeCollectionTool.Id+'\'';
        Test.startTest();
        List<ECOA_Collection_Tool__c> collectionToolList = new SLT_ECOA_Collection_Tool(false,false).getEcoaCollectionToolByBidHistoryId(testBidHistory.Id, fieldSet,condition);
        List<ECOA_Collection_Tool__c> collectionToolList2 = new SLT_ECOA_Collection_Tool(false).getEcoaCollectionToolByBidHistoryId(testBidHistory.Id, fieldSet,condition);
        Test.stopTest();
        Integer expected = 1;
        System.assertEquals(expected, collectionToolList.size());
    }
}