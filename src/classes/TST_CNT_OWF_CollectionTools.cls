@isTest
public class TST_CNT_OWF_CollectionTools {
	@testSetup
    Public static void setupData(){
        Account testAccount = UTL_OWF_TestData.createAccount();
        Insert testAccount;
        Opportunity testOpp =UTL_OWF_TestData.createOpportunity(testAccount.Id);
        Insert testOpp;
        pse__Grp__c grp = UTL_OWF_TestData.createGroup();
        insert grp;
        OWF_Config__c owfConfig = UTL_OWF_TestData.createOWFConfig(grp.Id);
        insert owfConfig;
        Bid_History__c testBidHistory = UTL_OWF_TestData.createBidHistoryByRecordType(testAccount.Id, testOpp.Id, CON_OWF.OWF_CSS_BID_BID_HISTORY_RECORD_TYPE_ID);
        testBidHistory.Number_of_Scenarios__c = 3.00;
        testBidHistory.eCOA__c=true;
        testBidHistory.FPI_Date__c=System.today();
        testBidHistory.LPO_Date__c=System.today();
        testBidHistory.LPI_Date__c=System.today();
        testBidHistory.DBL_Date__c=System.today();
        testBidHistory.Bid_Number__c = 1;
        Insert testBidHistory;
        List<CollectionTool__c> listECOAtool = new List<CollectionTool__c>();
        CollectionTool__c eCOA1 = new CollectionTool__c();
        eCOA1.Countries__c = 'United States of America';
        eCOA1.Bid_History__c = testBidHistory.Id;
        eCOA1.Number_of_Sites__c =2.00;
        eCOA1.Description_if_not_within_library__c = 'NA';
        eCOA1.RecordTypeId = CON_OWF.OWF_COLLECTIONTOOL_IQVIA_TECHNOLOGIES_RECORD_TYPE_ID;
        eCOA1.COA_Library_Assessment__c = '01_Not within Library'; 
        eCOA1.Select_Device_Type__c = 'Tablet';
        eCOA1.Specific_Device_Strategy__c = 'TEST';   
        eCOA1.Scenario_Number__c =1.00;
        eCOA1.Number_of_Enrolled_Patients__c = 10.00;
		eCOA1.Type__c = 'Other';
        eCOA1.FPI_Date__c=System.today();
        eCOA1.LPO_Date__c=System.today();
        eCOA1.LPI_Date__c=System.today();
        eCOA1.DBL_Date__c=System.today();
        listECOAtool.add(eCOA1);
        CollectionTool__c eCOA2 = new CollectionTool__c();
        eCOA2.Countries__c = 'United States of America';
        eCOA2.Bid_History__c = testBidHistory.Id;
        eCOA2.Number_of_Sites__c =2.00;
        eCOA2.Description_if_not_within_library__c = 'NA';
        eCOA2.RecordTypeId = CON_OWF.OWF_COLLECTIONTOOL_IQVIA_TECHNOLOGIES_RECORD_TYPE_ID;
        eCOA2.COA_Library_Assessment__c = '01_Not within Library'; 
        eCOA2.Select_Device_Type__c = 'Tablet';
        eCOA2.Specific_Device_Strategy__c = 'TEST';   
        eCOA2.Scenario_Number__c =1.00;
        eCOA2.Number_of_Enrolled_Patients__c = 10.00;
		eCOA1.Type__c = 'Other';
        eCOA1.FPI_Date__c=System.today();
        eCOA1.LPO_Date__c=System.today();
        eCOA1.LPI_Date__c=System.today();
        eCOA1.DBL_Date__c=System.today();
        listECOAtool.add(eCOA2);
        CollectionTool__c eCOA3 = new CollectionTool__c();
        eCOA3.Countries__c = 'United States of America';
        eCOA3.Bid_History__c = testBidHistory.Id;
        eCOA3.Number_of_Sites__c =2.00;
        eCOA3.Description_if_not_within_library__c = 'NA';
        eCOA3.RecordTypeId = CON_OWF.OWF_COLLECTIONTOOL_IQVIA_TECHNOLOGIES_RECORD_TYPE_ID;
        eCOA3.COA_Library_Assessment__c = '01_Not within Library'; 
        eCOA3.Select_Device_Type__c = 'Tablet';
        eCOA3.Specific_Device_Strategy__c = 'TEST';   
        eCOA3.Scenario_Number__c =1.00;
        eCOA3.Number_of_Enrolled_Patients__c = 10.00;
        listECOAtool.add(eCOA3);
		eCOA1.Type__c = 'Other';
        eCOA1.FPI_Date__c=System.today();
        eCOA1.LPO_Date__c=System.today();
        eCOA1.LPI_Date__c=System.today();
        eCOA1.DBL_Date__c=System.today();
        insert listECOAtool;
    }
    @isTest
    Public Static void testfetchCollectionTool(){
		Bid_History__c testData =[Select id,DBL_Date__c,LPO_Date__c,LPI_Date__c,FPI_Date__c,Number_of_Scenarios__c,Bid_Number__c,Bid_History_Related_Opportunity__c from Bid_History__c limit 1];
        Test.startTest();
        List<CNT_OWF_CollectionTools.CollectionToolWrapper> listWrapper = CNT_OWF_CollectionTools.fetchCollectionTool(testData.Id, testData, testData.Number_of_Scenarios__c, CON_OWF.OWF_COLLECTIONTOOL_IQVIA_TECHNOLOGIES_RECORD_TYPE_ID);
        Test.stopTest();
		system.assertEquals(3,listWrapper.size(), 'length of Collection Tool Wrapper list is 3' );
    }
    @isTest
    Public Static void testfetchBidHistory(){
		Bid_History__c testData =[Select id, Number_of_Scenarios__c from Bid_History__c limit 1];
        Test.startTest();
        Bid_History__c bidHistory = CNT_OWF_CollectionTools.fetchBidHistory(testData.Id);
        Test.stopTest();
        system.assertEquals(testData.Number_of_Scenarios__c,bidHistory.Number_of_Scenarios__c, 'Number of scenarios matches' );
    }
     @isTest
    Public Static void testupsertCollectionTools(){
		List<CollectionTool__c> testData =[Select id,Number_of_Enrolled_Patients__c,Number_of_Sites__c,Scenario_Number__c,Bid_History__c,Description_if_not_within_library__c,
                                                 Specific_Device_Strategy__c,COA_Library_Assessment__c,Select_Device_Type__c,Bid_History__r.Number_of_Scenarios__c,
                                                 Countries__c,RecordType.Id,FPI_Date__c,DBL_Date__c,LPO_Date__c,LPI_Date__c, Type__c,COA_Type__c,Screened_Patients__c from CollectionTool__c ];
        Bid_History__c testDataBid =[Select id from Bid_History__c limit 1];
        List<CNT_OWF_CollectionTools.CollectionToolWrapper> ListtestWrapper = new List<CNT_OWF_CollectionTools.CollectionToolWrapper>();
        CNT_OWF_CollectionTools.CollectionToolWrapper testWrapper = new CNT_OWF_CollectionTools.CollectionToolWrapper();
        testWrapper.collectionToolRecords =new List<CollectionTool__c>{testData[0]};
        testWrapper.Key = 1;
        testWrapper.hideCopyFromPreviousTableButton = false;
       	testWrapper.sumOfEnrolledPatients =1;
        testWrapper.sumOfSites = 5;
        testWrapper.noOfCountries = 5;
        ListtestWrapper.add(testWrapper);
		List<String> deletedRecordsIdList = new List<String>();
        deletedRecordsIdList.add(testData[0].Id);
        Test.startTest();
        CNT_OWF_CollectionTools.upsertCollectionTools(ListtestWrapper,testData,deletedRecordsIdList,String.valueOf(testDataBid.Id));
        Test.stopTest();
        List<CollectionTool__c> testDataAfterInsertAndDeletion =[Select id from CollectionTool__c];
       	system.assertEquals(1,testDataAfterInsertAndDeletion.size()-testData.size(), '2 records are newly created and 1 is being deleted. So the difference should be 1' );
    }
	
	@isTest
    Public Static void testfetchCollectionToolforRebid(){
        Account acc = [Select id from Account limit 1];
        Opportunity opp = [Select id from Opportunity limit 1];
		Bid_History__c testBidHistory = UTL_OWF_TestData.createBidHistoryByRecordType(acc.Id, opp.Id, CON_OWF.OWF_CSS_BID_BID_HISTORY_RECORD_TYPE_ID);
        testBidHistory.Number_of_Scenarios__c = 3.00;
        testBidHistory.eCOA__c=true;
        testBidHistory.FPI_Date__c=System.today();
        testBidHistory.LPO_Date__c=System.today();
        testBidHistory.LPI_Date__c=System.today();
        testBidHistory.DBL_Date__c=System.today();
        testBidHistory.Bid_Number__c = 2;
        Insert testBidHistory;
        CollectionTool__c eCOA1 = new CollectionTool__c();
        eCOA1.Countries__c = 'United States of America';
        eCOA1.Bid_History__c = testBidHistory.Id;
        eCOA1.Number_of_Sites__c =2.00;
        eCOA1.Description_if_not_within_library__c = 'NA';
        eCOA1.RecordTypeId = CON_OWF.OWF_COLLECTIONTOOL_IQVIA_TECHNOLOGIES_RECORD_TYPE_ID;
        eCOA1.COA_Library_Assessment__c = '01_Not within Library'; 
        eCOA1.Select_Device_Type__c = 'Tablet';
        eCOA1.Specific_Device_Strategy__c = 'TEST';   
        eCOA1.Scenario_Number__c =1.00;
        eCOA1.Number_of_Enrolled_Patients__c = 10.00;
        eCOA1.Type__c = 'Other';
        eCOA1.FPI_Date__c=System.today();
        eCOA1.LPO_Date__c=System.today();
        eCOA1.LPI_Date__c=System.today();
        eCOA1.DBL_Date__c=System.today();
        insert eCOA1;
        Test.startTest();
        List<CNT_OWF_CollectionTools.CollectionToolWrapper> listWrapper = CNT_OWF_CollectionTools.fetchCollectionTool(testBidHistory.Id, testBidHistory, testBidHistory.Number_of_Scenarios__c, 'Other');
        Test.stopTest();
		system.assertNotEquals(0,listWrapper.size(), 'length of Collection Tool Wrapper list is not empty' );
    }
}
