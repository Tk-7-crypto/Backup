/**
 * This class is used to test SCH_CRM_AutoCloseOpportunity Batch class
 */ 
@isTest
public class TST_SCH_CRM_AutoCloseOpportunity {

    @testSetup
    static void dataSetup() {
        upsert new  Mulesoft_Integration_Control__c(Ignore_Validation_Rules__c = true);
        Account parentAccount = UTL_TestData.createAccount();
        parentAccount.MDM_Validation_Status__c = 'Pending Validation';
        parentAccount.RecordTypeId = CON_CRM.GLOBAL_CUSTOMER_ACCOUNT_RECORD_TYPE_ID;
        parentAccount.Risk_Rating__c = '6- Do Not Sell';
        parentAccount.Date_Risk_Assessed__c = System.today().addMonths(-6);
        insert parentAccount;
        Account testAccount = UTL_TestData.createAccount();
        testAccount.ParentId = parentAccount.id;
        insert testAccount;
        List<Opportunity> oppList = new List<Opportunity>();
        Opportunity opp1 = UTL_TestData.createOpportunity(testAccount.id);
        opp1.StageName = CON_CRM.IDENTIFYING_OPP_STAGE;
        opp1.Lost_Date__c = null;
        oppList.add(opp1);
        Opportunity opp2 = UTL_TestData.createOpportunity(testAccount.id);
        opp2.StageName = CON_CRM.QUALIFYING_OPP_STAGE;
        opp2.Lost_Date__c = null;
        oppList.add(opp2);
        Opportunity opp3 = UTL_TestData.createOpportunity(testAccount.id);
        opp3.StageName = CON_CRM.DEVELOPING_PROP_STAGE;
        opp3.Lost_Date__c = null;
        oppList.add(opp3);
        Opportunity opp4 = UTL_TestData.createOpportunity(testAccount.id);
        opp4.StageName = CON_CRM.DELIVERING_PROP_STAGE;
        opp4.Lost_Date__c = null;
        oppList.add(opp4);
        Opportunity opp5 = UTL_TestData.createOpportunity(testAccount.id);
        opp5.StageName = CON_CRM.FINALIZING_DEAL_STAGE;
        opp5.Lost_Date__c = null;
        oppList.add(opp5);
        Opportunity opp6 = UTL_TestData.createOpportunity(testAccount.id);
        opp6.StageName = CON_CRM.RECEIVED_ATP_STAGE;
        opp6.Lost_Date__c = null;
        oppList.add(opp6);
        insert oppList;
    }
    
    static testMethod void testSCHCRMOpportunityStageBatch() {
        String CRON_EXP = '0 0 12 * * ?'; 
        Test.startTest();
        SCH_CRM_AutoCloseOpportunity.scheduleJob('test Auto close opportunity',CRON_EXP);
        Test.stopTest();
    }
}