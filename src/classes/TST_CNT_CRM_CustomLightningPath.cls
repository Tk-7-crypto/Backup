@isTest
public class TST_CNT_CRM_CustomLightningPath {
    
    @testSetup
    static void setUpTestData() {
        Account acc = UTL_TestData.createAccount();
        insert acc;
        Opportunity opp = UTL_TestData.createOpportunity(acc.Id);
        insert opp;
    }
    
    @isTest
    static void testGetData(){
        Test.startTest();
        	map<String,Custom_Sales_Path_Configuration__mdt> mdt = CNT_CRM_CustomLightningPath.getData();
        Test.stopTest();
        System.assertEquals(mdt.keySet().size() > 0, true);
    }
    
    @isTest
    static void testGetKeyFields(){
        map<String,Custom_Sales_Path_Configuration__mdt> mdt = CNT_CRM_CustomLightningPath.getData();
        Opportunity opp = [SELECT Id,StageName from Opportunity LIMIT 1];
        mdt.get(opp.StageName).Key_Field6__c = 'Name';
        mdt.get(opp.StageName).Key_Field7__c = 'Name';
        mdt.get(opp.StageName).Key_Field8__c = 'Name';
        mdt.get(opp.StageName).Key_Field9__c = 'Name';
        mdt.get(opp.StageName).Key_Field10__c = 'Name';
        mdt.get(opp.StageName).Key_Field11__c = 'Name';
        mdt.get(opp.StageName).Key_Field12__c = 'Name';
        mdt.get(opp.StageName).Key_Field13__c = 'Name';
        mdt.get(opp.StageName).Key_Field14__c = 'Name';
        mdt.get(opp.StageName).Key_Field15__c = 'Name';
        Test.startTest();
        List<String> fields = CNT_CRM_CustomLightningPath.getKeyFields(opp.StageName, mdt);
        Test.stopTest();
        System.assertEquals(fields.size() > 0, true);
    }
    
    @isTest
    static void testGetGuidance(){
        map<String,Custom_Sales_Path_Configuration__mdt> mdt = CNT_CRM_CustomLightningPath.getData();
        Opportunity opp = [SELECT Id,StageName from Opportunity LIMIT 1];
        Test.startTest();
        String guildlines = CNT_CRM_CustomLightningPath.getGuidance(opp.StageName, mdt);
        Test.stopTest();
        System.assertEquals(guildlines != null, true);
    }
}