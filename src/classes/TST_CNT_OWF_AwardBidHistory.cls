@isTest
public class TST_CNT_OWF_AwardBidHistory {
    @testSetup
    static void dataSetup() {
        Account acc = UTL_OWF_TestData.createAccount();
        insert acc;
        
        pse__Grp__c grp = UTL_OWF_TestData.createGroup();
        insert grp;
        
        OWF_Config__c owfConfig = UTL_OWF_TestData.createOWFConfig(grp.Id);
        insert owfConfig;
        
        Contact cont = UTL_OWF_TestData.createContact(acc.Id);
        cont.pse__Is_Resource__c = true;
        cont.pse__Is_Resource_Active__c = true;
        cont.pse__Group__c = grp.Id;
        cont.sub_group__c = CON_OWF.RES_REQ_TYPE_JAPAN;
        cont.available_for_triage_flag__c = true;
        cont.pse__Salesforce_User__c = userInfo.getUserId();
        insert cont;
        
        pse__Permission_Control__c permissionControlGroup = UTL_OWF_TestData.createPermissionControl(null, null, grp, null);
        insert permissionControlGroup;
        
        Opportunity opp = UTL_OWF_TestData.createOpportunity(acc.Id);
        insert opp;
        
        Bid_History__c bidHistory = UTL_OWF_TestData.createBidHistoryByRecordType(acc.Id, opp.Id, CON_OWF.OWF_CLINICAL_BID_BID_HISTORY_RECORD_TYPE_ID);
        bidHistory.Bid_Number__c = 0;
        insert bidHistory;
        CNT_OWF_AwardBidHistory.WPR_OWF_BidHistoryWrapper wprOwfBidHistoryWrapper = new CNT_OWF_AwardBidHistory.WPR_OWF_BidHistoryWrapper(bidHistory);
        String url = wprOwfBidHistoryWrapper.bidHistoryRecordUrl;
    }
    
    @IsTest
    static void testGetBidHistoryRelatedToOpportunity() 
    {
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        Test.startTest();
        List<Object> bidHistoryRelatedToOpportunityList1 = CNT_OWF_AwardBidHistory.getBidHistoryRelatedToOpportunity(null);
        List<Object> bidHistoryRelatedToOpportunityList = CNT_OWF_AwardBidHistory.getBidHistoryRelatedToOpportunity(opp.Id);
        System.assertEquals(1, bidHistoryRelatedToOpportunityList != null ? bidHistoryRelatedToOpportunityList.size() : 0, 'Success: testGetBidHistoryRelatedToOpportunity');
        Test.stopTest();
    }
    
    @IsTest
    static void testAwardBidHistoryRecord() 
    {
        Bid_History__c bidHistoryRecord = [SELECT Id FROM Bid_History__c LIMIT 1];
        Test.startTest();
        CNT_OWF_AwardBidHistory.awardBidHistoryRecord(bidHistoryRecord.Id, FALSE, null);
        Bid_History__c bidHistoryRecordAfterUpdation = [SELECT Id, Is_Study_Awarded__c FROM Bid_History__c LIMIT 1];
        System.assertEquals('Yes', bidHistoryRecordAfterUpdation != null ? bidHistoryRecordAfterUpdation.Is_Study_Awarded__c : '', 'Success: testAwardBidHistoryRecord');
        Test.stopTest();
    }
}
