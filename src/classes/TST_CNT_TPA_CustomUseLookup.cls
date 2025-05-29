@isTest
public class TST_CNT_TPA_CustomUseLookup { 
	@isTest
    static void CNT_TPA_CustomUseLookupTest1(){
        PageReference pageRef = Page.VFP_TPA_Offering_Notification_Mapping;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('ksrch', 'testsearch');
        
        CNT_TPA_CustomUseLookup ctrlInstance = new CNT_TPA_CustomUseLookup();
        Test.startTest();
        ctrlInstance.getFormTag();
        ctrlInstance.getTextBox();
        Test.stopTest();
    }
}