@isTest
public class TST_CNT_OWF_RefreshBidHistoryPage {
    private static date strtDate = date.newInstance(2019, 1, 1);
    @testSetup
    public static void setUp(){
        Account acc = UTL_OWF_TestData.createAccount();
        insert acc;
        pse__Grp__c grp = UTL_OWF_TestData.createGroup();
        insert grp;
        Contact cont = UTL_OWF_TestData.createContact(acc.Id);
        cont.pse__Is_Resource__c = true;
        cont.pse__Is_Resource_Active__c = true;
        cont.pse__Group__c = grp.Id;
        cont.FirstName = 'Test';
        cont.LastName = 'Contact';
        cont.sub_group__c = 'TSL-Japan';
        cont.available_for_triage_flag__c = true;   
        insert cont;
        pse__Permission_Control__c permissionControlGroup = UTL_OWF_TestData.createPermissionControl(null, null, grp, null);
        insert permissionControlGroup;
        Opportunity opp = UTL_OWF_TestData.createOpportunity(acc.Id);
        insert opp;
        Mulesoft_Integration_Control__c mulesoftIntegrationSettings = UTL_TestData.createMulesoftIntegrationControl(UserInfo.getUserId());
        mulesoftIntegrationSettings.Ignore_Validation_Rules__c = true;
        upsert mulesoftIntegrationSettings;
        Apttus__APTS_Agreement__c agreement =  UTL_OWF_TestData.createAgreement(acc.Id, opp.Id);
        insert agreement;
        Bid_History__c bidHistory =  UTL_OWF_TestData.createBidHistoryByRecordType(acc.Id, opp.Id, CON_OWF.OWF_CLINICAL_BID_BID_HISTORY_RECORD_TYPE_ID);
        bidHistory.Bid_Number__c = 0;
        bidHistory.Opportunity_Type__c = CON_OWF.OPPORTUNITY_TYPE;
        bidHistory.RFP_Ranking__c = '2';
        bidHistory.Budget_Deliverable__c= CON_OWF.BUDGET_DELIVERABLE;
        bidHistory.Migrated_Agreement_Id__c = agreement.Id;
        bidHistory.Is_Box_Folder_Migrated__c = true;
        insert bidHistory;
    }
    @isTest
    public static void testRefresh(){
        Bid_History__c bidHistory = [Select Id from Bid_History__c Limit 1];
        box__FRUP__c  box = new box__FRUP__c (box__Record_ID__c = bidHistory.Id);
        insert box;
        ApexPages.StandardController sc = new Apexpages.Standardcontroller(bidHistory);
        Test.startTest();
        CNT_OWF_RefreshBidHistoryPage ref = new CNT_OWF_RefreshBidHistoryPage(sc);
        ref.recordId = bidHistory.Id;
        ref.refresh();
        Test.stopTest();
    }
    @isTest
    public static void testRefresh1(){
        Bid_History__c bidHistory = [Select Id from Bid_History__c Limit 1];
        bidHistory.Is_Box_Folder_Migrated__c = false;
        update bidHistory;
        box__FRUP__c  box = new box__FRUP__c (box__Record_ID__c = bidHistory.Id);
        box.CreatedDate = system.today().addDays(-1);
        insert box;
        ApexPages.StandardController sc = new Apexpages.Standardcontroller(bidHistory);
        Test.startTest();
        CNT_OWF_RefreshBidHistoryPage ref = new CNT_OWF_RefreshBidHistoryPage(sc);
        ref.recordId = bidHistory.Id;
        ref.refresh();
        Test.stopTest();
    }
    
     @isTest
    public static void testRefresh2(){
        Bid_History__c bidHistory = [Select Id from Bid_History__c Limit 1];
        ApexPages.StandardController sc = new Apexpages.Standardcontroller(bidHistory);
        Test.startTest();
        CNT_OWF_RefreshBidHistoryPage ref = new CNT_OWF_RefreshBidHistoryPage(sc);
        ref.recordId = bidHistory.Id;
        ref.refresh();
        Test.stopTest();
    }
    
    @isTest
    public static void testRefresh3(){
        Bid_History__c bidHistory = [Select Id,Is_Box_Folder_Migrated__c from Bid_History__c Limit 1];
        Apttus__APTS_Agreement__c agreement = [Select Id from Apttus__APTS_Agreement__c Limit 1];
        bidHistory.Is_Box_Folder_Migrated__c = false;
        update bidHistory;
        box__FRUP__c  box = new box__FRUP__c (box__Record_ID__c = agreement.Id);
        insert box;
        ApexPages.StandardController sc = new Apexpages.Standardcontroller(bidHistory);
        Test.startTest();
        CNT_OWF_RefreshBidHistoryPage ref = new CNT_OWF_RefreshBidHistoryPage(sc);
        Test.stopTest();
    }

}