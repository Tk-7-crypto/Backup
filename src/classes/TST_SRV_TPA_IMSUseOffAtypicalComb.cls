@isTest(seeAllData=false)
public class TST_SRV_TPA_IMSUseOffAtypicalComb {
    @isTest
    public static void testGetAtypicalCombinationsMethod() {
        TPA_Purpose_Category__c tpaPurposeCategory = UTL_TPA_SetupTestData.createTpaPurposeCategory('Expert Analysis');
        IMS_TPA_Purpose__c imsTpaPurpose = UTL_TPA_SetupTestData.createIMSTpaPurposeData('United States', 'test name');
        IMS_Data_Asset__c imsDataAsset = UTL_TPA_SetupTestData.createImsDataAsset(true);
        Address__c vendAddress = UTL_TPA_SetupTestData.getAddress();
        insert vendAddress;
        
        Id atyRcrdTypeID = Schema.SObjectType.IMS_Use_Offering_Atypical_Combination__c.getRecordTypeInfosByName().get('Use Offering Atypical Combination').getRecordTypeId();
        
        
        Id secRcrdTypeID = Schema.SObjectType.IMS_Use_Offering_Atypical_Combination__c.getRecordTypeInfosByName().get('TPA Secondary Reviews').getRecordTypeId();
        
        
        IMS_Use_Offering_Atypical_Combination__c imsUseOfferingAtypicalCombinationObj1 = new IMS_Use_Offering_Atypical_Combination__c(Use_Category__c = tpaPurposeCategory.id,
                                                                                                                                      Use_Name__c = imsTpaPurpose.id,
                                                                                                                                      Offering_Name__c = imsDataAsset.id,
                                                                                                                                      isActive__c = true,Vendor_Name__c = vendAddress.Id,
                                                                                                                                      is_Approved_For_Future__c = false);        
        imsUseOfferingAtypicalCombinationObj1.RecordTypeId = atyRcrdTypeID;
        insert imsUseOfferingAtypicalCombinationObj1;
        
        IMS_Use_Offering_Atypical_Combination__c imsUseOfferingAtypicalCombinationObj2 = new IMS_Use_Offering_Atypical_Combination__c(Use_Category__c = tpaPurposeCategory.id,
                                                                                                                                      Use_Name__c = imsTpaPurpose.id,
                                                                                                                                      Offering_Name__c = imsDataAsset.id,
                                                                                                                                      isActive__c = true,Vendor_Name__c = vendAddress.Id,
                                                                                                                                      is_Approved_For_Future__c = false);
        imsUseOfferingAtypicalCombinationObj2.RecordTypeId = secRcrdTypeID;
        insert imsUseOfferingAtypicalCombinationObj2;
        Set<Id> vendorIdSet = new Set<Id>();
        vendorIdSet.add(vendAddress.Id);
        Test.startTest();
        SRV_TPA_IMSUseOffAtypicalComb.getAtypicalCombinations();
        SRV_TPA_IMSUseOffAtypicalComb.getSecReviewCombinations(vendorIdSet);
        Test.stopTest();
    }    
}
