@isTest
public class TST_CNT_OWF_CreatePrismQuote {
 @testSetup
    static void setupTestData() {
        List<User> userList = UTL_OWF_TestData.createUser('System Administrator', 1);
        userList[0].IsActive = true;
        userList[0].LQ_User_Id__c ='005D2000004r4poIff';
        insert userList;
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
        opp.LQ_Opportunity_Id__c = '006D200000XgxcjInn';
        insert opp;
        Mulesoft_Integration_Control__c mulesoftIntegrationSettings = UTL_TestData.createMulesoftIntegrationControl(UserInfo.getUserId());
        mulesoftIntegrationSettings.Ignore_Validation_Rules__c = true;
        upsert mulesoftIntegrationSettings;
        Bid_History__c bidHistory = UTL_OWF_TestData.createBidHistoryByRecordType(acc.id,opp.id,CON_OWF.OWF_Q2_Solutions_BID_HISTORY_RECORD_TYPE_ID);
        bidHistory.OwnerId = userList[0].id;
        insert bidHistory;
        Legacy_Org_Link__c cs = new Legacy_Org_Link__c();
        cs.Legacy_IMS_URL__c='imshealth--dev6.my.salesforce.com	';
        cs.Legacy_Quintiles_URL__c ='quintiles--crm.sandbox.my.salesforce.com';
        cs.IQVIA_Domain_URL__c ='IQVIA_Domain_URL__c';
        insert cs;
    }
    
    @isTest
    public static void testGetOpportunityFields(){
        List<Bid_History__c> bid=[select id from Bid_History__c];
        Test.startTest();
        Map<String,String> testReturnMap = CNT_OWF_CreatePrismQuote.getOpportunityFields(bid[0].id);
        Test.stopTest();
        Map<String,String> returnMap = new Map<String,String>();
        List<Bid_History__c> opportunityToBidhistory = new List<Bid_History__c>([SELECT Id, OwnerId, Bid_History_Related_Opportunity__r.LQ_Opportunity_Id__c FROM Bid_History__c where Id =:bid[0].id]);
        List<User> lqOwnerId = new List<User>([SELECT LQ_User_Id__c FROM User where Id =:opportunityToBidhistory[0].OwnerId]);
        List<Legacy_Org_Link__c> LqLink = new List<Legacy_Org_Link__c>([SELECT Legacy_Quintiles_URL__c FROM Legacy_Org_Link__c ]);
        returnMap.put('lqOpportunityId',opportunityToBidhistory[0].Bid_History_Related_Opportunity__r.LQ_Opportunity_Id__c);
        returnMap.put('lqLegacyOrgLink',LqLink[0].Legacy_Quintiles_URL__c);
        returnMap.put('lqOwnerId',lqOwnerId[0].LQ_User_Id__c);
        
        system.assertEquals(returnMap,testReturnMap,'Actual Data is Not Matching With Expected Data');     
    }


}