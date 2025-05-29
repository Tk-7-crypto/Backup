/**
* @author : Babita Dadarwal
* @description : Test Class of TPA_Atypical_UseOfferings_ManualReview class.
*/
@isTest(SeeAllData=false)
public class TST_CNT_TPA_AtypUseOffMnnualReview {
    public static testMethod void testAtypicalUseOffManualReview() {
        Date todayDate = Date.today();
        Address__c testAccount = UTL_TPA_SetupTestData.getAccount();
        testAccount.Name = 'test vendor';
        testAccount.Vendor_Registration_Number__c = 1200;
        insert testAccount;  

        Contact tpaContact = UTL_TPA_SetupTestData.getTestContact(testAccount);

        TPA_Request__c tpaRequest1 = UTL_TPA_SetupTestData.getTestTPARequest();
        tpaRequest1.Client_Address__c = testAccount.Id;
        tpaRequest1.Service_Provider_Address__c = testAccount.Id;
        tpaRequest1.Data_Access_End_Date__c = todayDate.addDays(-3);
        tpaRequest1.Sent_for_Signatures_on__c = todayDate;
        tpaRequest1.Data_Access_Start_Date__c = todayDate.addDays(-8);
        tpaRequest1.Data_Access_End_Date__c = todayDate.addDays(-3);
        tpaRequest1.Service_Provider_Address__c = testAccount.Id;
        insert tpaRequest1;

        IMS_Master_Legal_Entity__c imsMasterLegalEntity = UTL_TPA_SetupTestData.getImsMasterLegalEntity();

        IMS_Legal_Entity__c imsLegalEntity = UTL_TPA_SetupTestData.getImsLegalEntity(tpaRequest1, imsMasterLegalEntity);

        IMS_TPA_Purpose__c imsTpaPurpose = UTL_TPA_SetupTestData.createIMSTpaPurposeData('United States', 'test name');
        TPA_Purpose_Category__c tpaPurposeCategory = UTL_TPA_SetupTestData.createTpaPurposeCategory('Expert Analysis');
        TPA_Purpose__c tpaPurpose = UTL_TPA_SetupTestData.createTpaPurpose('Test TPA Purpose', tpaRequest1, tpaPurposeCategory, imsTpaPurpose, imsLegalEntity);

        IMS_TPA_Purpose__c imsTpaPurpose1 = UTL_TPA_SetupTestData.createIMSTpaPurposeData('United States', 'test name1');
        TPA_Purpose__c tpaPurpose1 = UTL_TPA_SetupTestData.createTpaPurpose('Test TPA Purpose1', tpaRequest1, tpaPurposeCategory, imsTpaPurpose1, imsLegalEntity);

        IMS_Data_Asset__c imsDataAsset = UTL_TPA_SetupTestData.createImsDataAsset(true);
        TPA_Data_Asset__c tpaDataAsset = UTL_TPA_SetupTestData.createTpaDataAsset(tpaRequest1, tpaPurpose, imsDataAsset, imsLegalEntity);

        IMS_Use_Offering_Atypical_Combination__c imsUseOfferingAtypicalCombinationObj = new IMS_Use_Offering_Atypical_Combination__c(Use_Category__c = tpaPurposeCategory.id,
                                                                                                                                     Use_Name__c = imsTpaPurpose.id,
                                                                                                                                     Offering_Name__c = imsDataAsset.id,
                                                                                                                                     isActive__c = true,
                                                                                                                                     is_Approved_For_Future__c = false);
        insert imsUseOfferingAtypicalCombinationObj;

        TPA_Use_Offering_Atypical_Combination__c tpaUseOfferingAtypicalCombinationObj = new TPA_Use_Offering_Atypical_Combination__c(IMS_Use_Offering_Atypical_Combination__c = imsUseOfferingAtypicalCombinationObj.id,
                                                                                                                                     TPA_Request__c = tpaRequest1.id);
        insert tpaUseOfferingAtypicalCombinationObj;

        CNT_TPA_AtypUseOffMnnualReview obj = new CNT_TPA_AtypUseOffMnnualReview();
        PageReference pageRef = Page.VFP_TPA_AtypUseOffMnnualReview;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('requestID', tpaRequest1.Id);

        Test.startTest();
        obj.loadData();
        CNT_TPA_AtypUseOffMnnualReview.submitApproval(obj.JsonUseOfferingList);
        Test.stopTest();
    }
}