/**
* @author : Babita Dadarwal
* @description : Test Class of CNT_TPA_Atyp_UseOff_DataUpload class.
*/
@isTest(SeeAllData=false)
public class TST_CNT_TPA_AtypicalUseOffDataUpldXML {

    public static testMethod void testAtypicalUseOffManualReview() {        
        IMS_TPA_Purpose__c imsTpaPurpose = UTL_TPA_SetupTestData.createIMSTpaPurposeData('United States','test name');
        IMS_TPA_Purpose__c imsTpaPurpose1 = UTL_TPA_SetupTestData.createIMSTpaPurposeData('United States','test name1');
        TPA_Purpose_Category__c tpaPurposeCategory = UTL_TPA_SetupTestData.createTpaPurposeCategory('Expert Analysis');
        IMS_Data_Asset__c imsDataAsset = UTL_TPA_SetupTestData.createImsDataAsset(true);

        IMS_Use_Offering_Atypical_Combination__c imsUseOfferingAtypicalCombinationObj = new IMS_Use_Offering_Atypical_Combination__c(Use_Category__c = tpaPurposeCategory.id,Use_Name__c = imsTpaPurpose.id, Offering_Name__c = imsDataAsset.id, isActive__c = true, is_Approved_For_Future__c = false);

        String tpaUseOffAtypicalCombinationListJSON = Json.serialize(IMSUseOfferingAtypicalCombinationObj);

        CNT_TPA_AtypicalUseOffDataUpldXML testObj = new CNT_TPA_AtypicalUseOffDataUpldXML();
        Test.startTest();
        String offList = CNT_TPA_AtypicalUseOffDataUpldXML.jsonOfferingList;
        String use_categoryCombList = CNT_TPA_AtypicalUseOffDataUpldXML.jsonUse_categoryCombList;
        String useCategoryList = CNT_TPA_AtypicalUseOffDataUpldXML.jsonUseCategoryList;
        testObj.getRegionList();
        testObj.getOfferingCategoryList();
        testObj.getJSONAtypicalUseOffCombMap();
        Map<String, IMS_Use_Offering_Atypical_Combination__c> atypicalUseOffCombMap = new map<String, IMS_Use_Offering_Atypical_Combination__c>();
        atypicalUseOffCombMap = CNT_TPA_AtypicalUseOffDataUpldXML.saveRequest(tpaUseOffAtypicalCombinationListJSON);
        System.assertEquals(1, atypicalUseOffCombMap.size());
        Test.stopTest();
    }
}