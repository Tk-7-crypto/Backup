@isTest(seeAllData=false)
public class TST_DAOH_TPA_IMSDataAsset {

    static testMethod void unitTest1() {
        Test.startTest();
        
        IMS_Data_Asset__c imsDataAsset = new IMS_Data_Asset__c(BU__c = 'United States', 
                                                               Geo_Level__c = 'Sub-National', 
                                                               Is_Active__c = true, 
                                                               IMS_Legal_Entity__c='IQVIA AG',
                                                               Commercial_Owner_Email__c = 'test@gmail.co',
                                                               Requires_Manual_Review__c = true,
                                                               Asset_Name__c = 'test');
        insert imsDataAsset;
        imsDataAsset.Commercial_Owner_Email__c = 'test@gmail.com';
        update imsDataAsset;
        Test.stopTest();
    }
}