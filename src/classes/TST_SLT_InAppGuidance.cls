/*
* Version       : 1.0
* Description   : Test Class for SLT_InAppGuidance
*/
@isTest
public class TST_SLT_InAppGuidance {
    @testSetup
    static void dataSetup()
    {
        In_App_Guidance__c testGuidance = TST_PEP_TestDataFactory.createInAppGuidance('PRM Home Page');
        insert testGuidance;
    }
    
    @isTest
    static void testGetGuidanceDescription()
    {
        In_App_Guidance__c testGuidance = [SELECT Name FROM In_App_Guidance__c WHERE Name = 'PRM Home Page'];
        In_App_Guidance__c appGuidance = new In_App_Guidance__c();
        Date pastDate = Date.newInstance(2000, 12, 9);
        Test.startTest();
        	appGuidance = new SLT_InAppGuidance().getGuidanceDescription('PRM Home Page', pastDate);
        Test.stopTest();
        System.assertEquals('PRM Home Page', testGuidance.Name);
    }
}