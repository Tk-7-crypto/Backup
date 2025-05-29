@isTest
public class TST_CNT_TPA_CustomPrimaryOffLookup { 
	@isTest
    static void CNT_TPA_CustomPrimaryOffLookupTest1(){
        PageReference pageRef = Page.VFP_TPA_Offering_Notification_Mapping;
        Test.setCurrentPage(pageRef);
        
        ApexPages.currentPage().getParameters().put('ksrch', 'testsearch');
        ApexPages.currentPage().getParameters().put('country', 'testcountry');
        
        CNT_TPA_CustomPrimaryOffLookup ctrlInstance = new CNT_TPA_CustomPrimaryOffLookup();
        Test.startTest();
        ctrlInstance.getFormTag();
        ctrlInstance.getTextBox();
        Test.stopTest();
    }
}