/**
* Author: Neetu Bansal
* Since: June 25, 2015
* Name: TST_CNT_TPA_ManualReviewView
* Description: Test class of controller class TPA_ManualReviewViewController
*               Added by Neetu Bansal under Issue-07325
**/
@isTest(SeeAllData=False)
private class TST_CNT_TPA_ManualReviewView {
    /**
* To test the data
**/
    private static testmethod void insertUpdateTest() 
    {
        // Call default settings
        // Create Account   
        Address__c acc = UTL_TPA_SetupTestData.getAccount();
        acc.Is_TPA_Account__c = true;
        insert acc;
        
        // Create Watch List
        Watch_List__c watch = UTL_TPA_SetupTestData.createWatchList( acc.Id );
        insert watch;
        
        List<Watch_List__c> lstwatch = new List<Watch_List__c>();
        lstwatch.add(watch);
        
        test.startTest();
        // Create the instance of visualforce page and put contact id into parameters
        Test.setCurrentPageReference(new PageReference('Page.VFP_TPA_ManualReviewView')); 
        System.currentPageReference().getParameters().put('vendorId', acc.Id);
        
        // Create instance of controller
        CNT_TPA_ManualReviewView controller = new CNT_TPA_ManualReviewView();
        controller.getVendors();
        CNT_TPA_ManualReviewView.searchWatchList(new list<string>{acc.Id},null);
        CNT_TPA_ManualReviewView.submitApproval(JSON.serialize(lstwatch));
        
        List<Address__c> accounts = [ Select Id from Address__c ];
        system.assertEquals( 1, accounts.size() );
        test.stopTest();
    }
}