/*
* Version       : 1.0
* Description   : Test Class for SLT_RevenueAnalyst
*/
@isTest
public class TST_SLT_RevenueAnalyst {
    /**
    * This method used to set up testdata
    */ 
    @testSetup
    static void dataSetup() {
        Revenue_Analyst__c TestLocalRA =new Revenue_Analyst__c(User__c=userInfo.getUserId(),Is_SAP_Revenue_Analyst__c = false,name='SAPRAUser, Test');
        insert TestLocalRA;
    }
    @IsTest
    static void testSelectById() {
        Revenue_Analyst__c revRec = [SELECT Id FROM Revenue_Analyst__c];	
        Test.startTest();
        list<Revenue_Analyst__c> accMap1 = new SLT_RevenueAnalyst().selectById(new Set<Id> {revRec.Id});
        Map<Id, Revenue_Analyst__c> accMap = new SLT_RevenueAnalyst().selectByRevAnalystId(new Set<Id> {revRec.Id},new Set<String>{'Id'});
    	Test.stopTest();
    }
}