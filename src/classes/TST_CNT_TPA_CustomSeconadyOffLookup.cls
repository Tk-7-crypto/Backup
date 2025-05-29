@isTest
private class TST_CNT_TPA_CustomSeconadyOffLookup {	
    static testMethod void myUnitTest() {
        IMS_Master_Legal_Entity__c imsMasterLegalEntity = new IMS_Master_Legal_Entity__c(Name = 'test', Legal_Entity_Name_for_TLLA__c = 'test Name', Name_for_ESign__c = 'Test Esign',Legal_Entity_Title__c = 'test title');
        insert imsMasterLegalEntity;
        
    	IMS_Data_Asset__c imsDataAsset = new IMS_Data_Asset__c( BU__c = 'United States', 
                                                                Is_Notification_Required__c = true,
                                                                Is_Active__c = true, 
                                                                IMS_Legal_Entity__c = imsMasterLegalEntity.Id);
        insert imsDataAsset;
        List<IMS_Data_Asset__c> lstprimaryOff = [SELECT id, name,BU__c,Asset_Name__c from IMS_Data_Asset__c]; 
        
        PageReference pageRef = Page.VFP_TPA_NewClientVendorMatch;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('ksrch', 'testsearch');
        ApexPages.currentPage().getParameters().put('primaryOff', lstprimaryOff[0].Name);
        
        CNT_TPA_CustomSeconadyOffLookup ctrlInstance = new CNT_TPA_CustomSeconadyOffLookup();
        Test.startTest();
        ctrlInstance.getFormTag();
        ctrlInstance.getTextBox();
        Test.stopTest();
    }
}