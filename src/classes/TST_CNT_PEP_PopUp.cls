/*
* Version       : 1.0
* Description   : Test Class for CNT_PEP_PopUp
*/
@isTest
public class TST_CNT_PEP_PopUp {
    @testSetup
    static void dataSetup()
    {
        In_App_Guidance__c testGuidance = TST_PEP_TestDataFactory.createInAppGuidance('PRM Home Page');
        insert testGuidance;
    }
    
    @isTest
    static void testGetPageDetails()
    {
        In_App_Guidance__c testGuidance = [SELECT Name FROM In_App_Guidance__c WHERE Name = 'PRM Home Page'];
        In_App_Guidance__c appGuidance = new In_App_Guidance__c();
        Test.startTest();
        	appGuidance = CNT_PEP_PopUp.getPageDetails('PRM Home Page');
        Test.stopTest();
        System.assertEquals('PRM Home Page', testGuidance.Name);
    }
}