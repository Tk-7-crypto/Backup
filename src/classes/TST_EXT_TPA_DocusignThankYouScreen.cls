/**
 * Author: Babita Dadarwal
 * Date : 22 Sep 2016 (Updated by Vikram Singh on 14 Dec 2017)
 * Name: TST_TPA_DocusignThankyouScreen_Cont
 * Description: Test class of TPA_DocusignThankyouScreen_Controller
**/
@isTest
private class TST_EXT_TPA_DocusignThankYouScreen {
    private static testMethod void testDSThnkuConrtTest() {
        //Setup test data
        Address__c acc = UTL_TPA_SetupTestData.getAccount();

        Test.StartTest();

            // Set the current page to TPA_DocusignThankyouScreen Page
            
            PageReference pageRef = Page.VFP_TPA_DocusignThankYouScreen;
            pageRef.getParameters().put('language', 'Japanese');
            Test.setCurrentPage(pageRef);
            ApexPages.StandardController sc = new ApexPages.standardController(acc);
            EXT_TPA_DocusignThankYouScreen DSThankUScreenController = new EXT_TPA_DocusignThankYouScreen(sc);

            //When vendor language is null
            pageRef = Page.VFP_TPA_DocusignThankYouScreen;
            Test.setCurrentPage(pageRef);
            sc = new ApexPages.standardController(acc);
            DSThankUScreenController = new EXT_TPA_DocusignThankYouScreen(sc);
    }
}