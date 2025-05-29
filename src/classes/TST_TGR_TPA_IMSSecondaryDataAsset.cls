@isTest(seeAllData=false)
public class TST_TGR_TPA_IMSSecondaryDataAsset {

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
        IMS_Secondary_Data_Asset__c imsSecondaryDataAsset = new IMS_Secondary_Data_Asset__c(Primary_Data_Asset__c = imsDataAsset.id, Is_Active__c = true,
                                                                                            additional_terms_required__c = true, Requires_Manual_Review__c = true,Commercial_Manager_Email__c = 'test@gmail.co');
        insert imsSecondaryDataAsset;
        imsSecondaryDataAsset.Commercial_Manager_Email__c = 'test@gmail.com';
        update imsSecondaryDataAsset;
        Test.stopTest();
    }
}