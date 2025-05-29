@isTest
public class TST_SRV_TPA_AMAAgreementDetail {

	private static Address__c testSameClentAccount;
    private static Address__c testVendorAccount;
    private static Address__c testDifferentClentAccount;
    private static Address__c account;
    private static Contact con;
    private static AMA_Agreement_Detail__c amaAgg;

    private static TPA_Request__c tpaRequest1;

    private static TPA_Request__c testTpaRequest;

    private static TPA_Agreement_Additional_Field__c AgrAdditionalObj;

    //private static TPAQueryHelper tPAQueryHelper;

    private static String TEST_REGION = 'US';

    private static String TEST_LOCATION_TYPE = 'US';

    private static TPA_Contact__c tpaContact;

    private static TPA_Approval_Region__c tpaApprovalRegion;

    private static IMS_TPA_Purpose__c imsPurpose1;

    private static TPA_Purpose__c tpaPurpose1;
    private static TPA_Purpose__c tpaPurpose2;
    private static TPA_Purpose__c tpaPurpose3;
    private static TPA_Purpose__c tpaPurpose4;

    private static IMS_TPA_Purpose_Description__c imsPurposeDescription1;

    private static TPA_Purpose_Description__c tpaPurposeDescription1;
    private static TPA_Purpose_Description__c tpaPurposeDescription2;

    private static TPA_Purpose_Category__c purposeCategory1;

    private static IMS_Data_Asset__c imsDataAsset1;
    private static IMS_Data_Asset__c imsDataAsset2;
    private static IMS_Data_Asset__c imsDataAsset3;
    private static IMS_Data_Asset__c imsDataAsset4;
    private static IMS_Data_Asset__c imsDataAsset5;

    private static TPA_Data_Asset__c tpaDataAsset1;
    private static TPA_Data_Asset__c tpaDataAsset2;
    private static TPA_Data_Asset__c tpaDataAsset3;
    private static TPA_Data_Asset__c tpaDataAsset4;
    private static TPA_Data_Asset__c tpaDataAsset5;

    private static IMS_Secondary_Data_Asset__c imsSecondaryDataAsset1;
    private static IMS_Secondary_Data_Asset__c imsSecondaryDataAsset2;

    private static TPA_Secondary_Data_Asset__c tpaSecondaryDataAsset1;
    private static TPA_Secondary_Data_Asset__c tpaSecondaryDataAsset2;

    List<AMA_Contract_Detail__c> amaContracts = new List<AMA_Contract_Detail__c>();
    
    private static testMethod void testevaluateLettershopAndSBIICombination90daysOrLessConditions() {
        TST_SRV_TPA_AMAAgreementDetail instance = new TST_SRV_TPA_AMAAgreementDetail();
        instance.setupTestDataForLettershopConditionOfAMA();
        SRV_TPA_AMAAgreementDetail.reasonForAmaApprovalMap = new Map<String,String>();
        SRV_TPA_AMAAgreementDetail.amaAgreementDetails = new AMA_Agreement_Detail__c();
        insert SRV_TPA_AMAAgreementDetail.amaAgreementDetails;
        AMA_Contract_Detail__c amacontDetail = new AMA_Contract_Detail__c();
        insert amacontDetail;
        Test.startTest();
        SRV_TPA_AMAAgreementDetail.vendor_has_existing_license_with_same_client.put('Service Bureau II', new List<AMA_Contract_Detail__c>{amacontDetail});
        SRV_TPA_AMAAgreementDetail.dblValuesWithSameClient.put('Service Bureau II', new Set<String>{'test'});
        SRV_TPA_AMAAgreementDetail.evaluateLettershopAndSBIICombination90daysOrLessConditions(true, true, '90 days or less', 'test', tpaRequest1);
        SRV_TPA_AMAAgreementDetail.vendor_has_existing_license_with_same_client.put('Service Bureau II', new List<AMA_Contract_Detail__c>{amacontDetail});
        SRV_TPA_AMAAgreementDetail.dblValuesWithSameClient.put('Service Bureau II', new Set<String>{'test', 'test1'});
        SRV_TPA_AMAAgreementDetail.evaluateLettershopAndSBIICombination90daysOrLessConditions(true, true, '90 days or less', 'test', testTpaRequest);
        
        SRV_TPA_AMAAgreementDetail.vendor_has_existing_license_with_other_client.put('Service Bureau II', new List<AMA_Contract_Detail__c>{amacontDetail});
        SRV_TPA_AMAAgreementDetail.dblValuesWithSameClient.put('Service Bureau II', new Set<String>{'test', 'test1'});
        SRV_TPA_AMAAgreementDetail.evaluateLettershopAndSBIICombination90daysOrLessConditions(true, true, '90 days or less', 'test', testTpaRequest);
        
        SRV_TPA_AMAAgreementDetail.vendor_has_existing_license_with_same_client.remove('Service Bureau II');
        Test.stopTest();

        Map<Id,String> agreementTaskSubjectMap = new Map<Id,String>();
        tpaRequest1 = UTL_TPA_SetupTestData.getTPAAgreementBlank(true, testTpaRequest.Id);
        agreementTaskSubjectMap.put(tpaRequest1.id,'Read and Signed:Test Reason:Other Test');
        UTL_TPA_SetupTestData.createMultilingualTemplateSettingData();
        SRV_TPA_AMAAgreementDetail.amaAgreementDetails.TPA_Request__c = tpaRequest1.id;
        SRV_TPA_AMAAgreementDetail.sendEmailToVendor(SRV_TPA_AMAAgreementDetail.amaAgreementDetails); 
    }
    
    private static testMethod void testevaluateLettershopAndSBIICombination90daysOrLessConditions1() {
        TST_SRV_TPA_AMAAgreementDetail instance = new TST_SRV_TPA_AMAAgreementDetail();
        instance.setupTestDataForLettershopConditionOfAMA();
        SRV_TPA_AMAAgreementDetail.reasonForAmaApprovalMap = new Map<String,String>();
        SRV_TPA_AMAAgreementDetail.amaAgreementDetails = new AMA_Agreement_Detail__c();
        insert SRV_TPA_AMAAgreementDetail.amaAgreementDetails;
        AMA_Contract_Detail__c amacontDetail = new AMA_Contract_Detail__c();
        insert amacontDetail;
        Test.startTest();
        SRV_TPA_AMAAgreementDetail.vendor_has_existing_license_with_same_client.put('test', new List<AMA_Contract_Detail__c>{amacontDetail});
        SRV_TPA_AMAAgreementDetail.evaluateLettershopAndSBIICombination90daysOrLessConditions(true, true, '90 days or less', 'test', testTpaRequest);
        
        SRV_TPA_AMAAgreementDetail.vendor_has_existing_license_with_same_client = new Map<String, List<AMA_Contract_Detail__c>>();
        SRV_TPA_AMAAgreementDetail.vendor_has_existing_license_with_same_client.put('Service Bureau I', new List<AMA_Contract_Detail__c>{amacontDetail});
        SRV_TPA_AMAAgreementDetail.evaluateLettershopAndSBIICombination90daysOrLessConditions(true, true, '90 days or less', 'test', testTpaRequest);
        Test.stopTest();

        Map<Id,String> agreementTaskSubjectMap = new Map<Id,String>();
        tpaRequest1 = UTL_TPA_SetupTestData.getTPAAgreementBlank(true, testTpaRequest.Id);
        agreementTaskSubjectMap.put(tpaRequest1.id,'Read and Signed:Test Reason:Other Test');
    }

    private static testMethod void testTPAQueryHelperForLetterShopCondition12() {

        TST_SRV_TPA_AMAAgreementDetail instance = new TST_SRV_TPA_AMAAgreementDetail();
        instance.setupTestDataForLettershopConditionOfAMA();
        Test.startTest();
        instance.runUnitTestsForCondition12();
        Test.stopTest();

        Map<Id,String> agreementTaskSubjectMap = new Map<Id,String>();
        tpaRequest1 = UTL_TPA_SetupTestData.getTPAAgreementBlank(true, testTpaRequest.Id);
        agreementTaskSubjectMap.put(tpaRequest1.id,'Read and Signed:Test Reason:Other Test');
        //TPAQueryHelper.updateActivityHistory( agreementTaskSubjectMap ,'Read Test Signed1' );
    }

    private static testMethod void testTPAQueryHelperForLetterShopCondition13() {
        TST_SRV_TPA_AMAAgreementDetail instance = new TST_SRV_TPA_AMAAgreementDetail();
        instance.setupTestDataForLettershopConditionOfAMA();
        Test.startTest();
        instance.runUnitTestsForCondition13();
        Test.stopTest();
    }

    private static testMethod void testTPAQueryHelperForLetterShopCondition14() {
        TST_SRV_TPA_AMAAgreementDetail instance = new TST_SRV_TPA_AMAAgreementDetail();
        instance.setupTestDataForLettershopConditionOfAMA();
        Test.startTest();
        instance.runUnitTestsForCondition14();
        Test.stopTest();
    }

    private static testMethod void testTPAQueryHelperForLetterShopCondition15() {
        TST_SRV_TPA_AMAAgreementDetail instance = new TST_SRV_TPA_AMAAgreementDetail();
        instance.setupTestDataForLettershopConditionOfAMA();
        Test.startTest();
        instance.runUnitTestsForCondition15();
        Test.stopTest();
    }

    private static testMethod void testTPAQueryHelperForLetterShopCondition23() {
        TST_SRV_TPA_AMAAgreementDetail instance = new TST_SRV_TPA_AMAAgreementDetail();
        instance.setupTestDataForLettershopConditionOfAMA();
        Test.startTest();
        instance.runUnitTestsForCondition23();
        Test.stopTest();
    }

    private static testMethod void testTPAQueryHelperForLetterShopCondition20() {
        TST_SRV_TPA_AMAAgreementDetail instance = new TST_SRV_TPA_AMAAgreementDetail();
        instance.setupTestDataForLettershopConditionOfAMA();
        Test.startTest();
        instance.runUnitTestsForCondition20();
        Test.stopTest();
    }

    private static testMethod void testTPAQueryHelperForLetterShopCondition22() {
        TST_SRV_TPA_AMAAgreementDetail instance = new TST_SRV_TPA_AMAAgreementDetail();
        instance.setupTestDataForLettershopConditionOfAMA();
        Test.startTest();
        instance.runUnitTestsForCondition22();
        Test.stopTest();
    }

    private static testMethod void testTPAQueryHelperForLetterShopCondition22WithDiffDBL() {
        TST_SRV_TPA_AMAAgreementDetail instance = new TST_SRV_TPA_AMAAgreementDetail();
        instance.setupTestDataForLettershopConditionOfAMA();
        Test.startTest();
        instance.runUnitTestsForCondition22WithDiffDBL();
        Test.stopTest();
    }

    private static testMethod void testTPAQueryHelperForLetterShopCondition21A() {
        TST_SRV_TPA_AMAAgreementDetail instance = new TST_SRV_TPA_AMAAgreementDetail();
        instance.setupTestDataForLettershopConditionOfAMA();
        Test.startTest();
        instance.runUnitTestsForCondition21A();
        Test.stopTest();
    }

    private static testMethod void testTPAQueryHelperForLetterShopCondition21B() {
        TST_SRV_TPA_AMAAgreementDetail instance = new TST_SRV_TPA_AMAAgreementDetail();
        instance.setupTestDataForLettershopConditionOfAMA();
        Test.startTest();
        instance.runUnitTestsForCondition21B();
        Test.stopTest();
    }

    private static testMethod void testTPAQueryHelperForServiceBureauI25() {
        TST_SRV_TPA_AMAAgreementDetail instance = new TST_SRV_TPA_AMAAgreementDetail();
        instance.setupTestDataForLettershopConditionOfAMA();
        Test.startTest();
        instance.runUnitTestsForConditionServiceBureauI25();
        Test.stopTest();
    }

    private static testMethod void testTPAQueryHelperForServiceBureauI26() {
        TST_SRV_TPA_AMAAgreementDetail instance = new TST_SRV_TPA_AMAAgreementDetail();
        instance.setupTestDataForLettershopConditionOfAMA();
        Test.startTest();
        instance.runUnitTestsForConditionServiceBureauI26();
        Test.stopTest();
    }

    private static testMethod void testTPAQueryHelperForServiceBureauI27() {
        TST_SRV_TPA_AMAAgreementDetail instance = new TST_SRV_TPA_AMAAgreementDetail();
        instance.setupTestDataForLettershopConditionOfAMA();
        Test.startTest();
        instance.runUnitTestsForConditionServiceBureauI27();
        Test.stopTest();
    }

    private static testMethod void testTPAQueryHelperForServiceBureauII90daysOrLess30() {
        TST_SRV_TPA_AMAAgreementDetail instance = new TST_SRV_TPA_AMAAgreementDetail();
        instance.setupTestDataForLettershopConditionOfAMA();
        Test.startTest();
        instance.runUnitTestsForConditionServiceBureauII90daysOrLess30();
        Test.stopTest();
    }

    private static testMethod void testTPAQueryHelperForServiceBureauII90daysOrLess30WithDiffDBL() {
        TST_SRV_TPA_AMAAgreementDetail instance = new TST_SRV_TPA_AMAAgreementDetail();
        instance.setupTestDataForLettershopConditionOfAMA();
        Test.startTest();
        instance.runUnitTestsForConditionServiceBureauII90daysOrLess30WithDiffDBL();
        Test.stopTest();
    }

    private static testMethod void testTPAQueryHelperForServiceBureauII90daysOrLess31A() {
        TST_SRV_TPA_AMAAgreementDetail instance = new TST_SRV_TPA_AMAAgreementDetail();
        instance.setupTestDataForLettershopConditionOfAMA();
        Test.startTest();
        instance.runUnitTestsForConditionServiceBureauII90daysOrLess31A();
        Test.stopTest();
    }

    private static testMethod void testTPAQueryHelperForServiceBureauII90daysOrLess31B() {
        TST_SRV_TPA_AMAAgreementDetail instance = new TST_SRV_TPA_AMAAgreementDetail();
        instance.setupTestDataForLettershopConditionOfAMA();
        Test.startTest();
        instance.runUnitTestsForConditionServiceBureauII90daysOrLess31B();
        Test.stopTest();
    }

    private static testMethod void testTPAQueryHelperForServiceBureauII90daysOrLess31C() {
        TST_SRV_TPA_AMAAgreementDetail instance = new TST_SRV_TPA_AMAAgreementDetail();
        instance.setupTestDataForLettershopConditionOfAMA();
        Test.startTest();
        instance.runUnitTestsForConditionServiceBureauII90daysOrLess31C();
        Test.stopTest();
    }

    private static testMethod void testTPAQueryHelperForServiceBureauII90daysOrLess31D() {
        TST_SRV_TPA_AMAAgreementDetail instance = new TST_SRV_TPA_AMAAgreementDetail();
        instance.setupTestDataForLettershopConditionOfAMA();
        Test.startTest();
        instance.runUnitTestsForConditionServiceBureauII90daysOrLess31D();
        Test.stopTest();
    }

    private static testMethod void testTPAQueryHelperForServiceBureauII90daysOrLess32() {
        TST_SRV_TPA_AMAAgreementDetail instance = new TST_SRV_TPA_AMAAgreementDetail();
        instance.setupTestDataForLettershopConditionOfAMA();
        Test.startTest();
        instance.runUnitTestsForConditionServiceBureauII90daysOrLess32();
        Test.stopTest();
    }

    private static testMethod void testTPAQueryHelperForServiceBureauIIDueToUse34() {
        TST_SRV_TPA_AMAAgreementDetail instance = new TST_SRV_TPA_AMAAgreementDetail();
        instance.setupTestDataForLettershopConditionOfAMA();
        Test.startTest();
        instance.runUnitTestsForConditionServiceBureauIIDueToUse34();
        Test.stopTest();
    }

    private static testMethod void testTPAQueryHelperForServiceBureauIIDueToUse34WithMultipleDBL() {
        TST_SRV_TPA_AMAAgreementDetail instance = new TST_SRV_TPA_AMAAgreementDetail();
        instance.setupTestDataForLettershopConditionOfAMA();
        Test.startTest();
        instance.runUnitTestsForConditionServiceBureauIIDueToUse34WithMultipleDBL();
        Test.stopTest();
    }

    private static testMethod void testTPAQueryHelperForServiceBureauIIDueToUse35A() {
        TST_SRV_TPA_AMAAgreementDetail instance = new TST_SRV_TPA_AMAAgreementDetail();
        instance.setupTestDataForLettershopConditionOfAMA();
        Test.startTest();
        instance.runUnitTestsForConditionServiceBureauIIDueToUse35A();
        Test.stopTest();
    }

    private static testMethod void testTPAQueryHelperForServiceBureauIIDueToUse35B() {
        TST_SRV_TPA_AMAAgreementDetail instance = new TST_SRV_TPA_AMAAgreementDetail();
        instance.setupTestDataForLettershopConditionOfAMA();
        Test.startTest();
        instance.runUnitTestsForConditionServiceBureauIIDueToUse35B();
        Test.stopTest();
    }

    private static testMethod void testTPAQueryHelperForServiceBureauIIDueToUse35C() {
        TST_SRV_TPA_AMAAgreementDetail instance = new TST_SRV_TPA_AMAAgreementDetail();
        instance.setupTestDataForLettershopConditionOfAMA();
        Test.startTest();
        instance.runUnitTestsForConditionServiceBureauIIDueToUse35C();
        Test.stopTest();
    }

    private static testMethod void testTPAQueryHelperForServiceBureauIIDueToUse35D() {
        TST_SRV_TPA_AMAAgreementDetail instance = new TST_SRV_TPA_AMAAgreementDetail();
        instance.setupTestDataForLettershopConditionOfAMA();
        Test.startTest();
        instance.runUnitTestsForConditionServiceBureauIIDueToUse35D();
        Test.stopTest();
    }

    private static testMethod void testTPAQueryHelperForServiceBureauIIDueToUse36() {
        TST_SRV_TPA_AMAAgreementDetail instance = new TST_SRV_TPA_AMAAgreementDetail();
        instance.setupTestDataForLettershopConditionOfAMA();
        Test.startTest();
        instance.runUnitTestsForConditionServiceBureauIIDueToUse36();
        Test.stopTest();
    }

    private static testMethod void testTPAQueryHelperForServiceBureauIIDueToUse33() {
        TST_SRV_TPA_AMAAgreementDetail instance = new TST_SRV_TPA_AMAAgreementDetail();
        instance.setupTestDataForLettershopConditionOfAMA();
        Test.startTest();
        instance.runUnitTestsForConditionServiceBureauIIDueToUse33();
        Test.stopTest();
    }

    private static testMethod void testTPAQueryHelperForServiceBureauIIGreaterThan90Days37() {
        TST_SRV_TPA_AMAAgreementDetail instance = new TST_SRV_TPA_AMAAgreementDetail();
        instance.setupTestDataForLettershopConditionOfAMA();
        Test.startTest();
        instance.runUnitTestsForConditionServiceBureauIIGreaterThan90Days37();
        Test.stopTest();
    }

    private static testMethod void testTPAQueryHelperForServiceBureauIIGreaterThan90Days37WithMultipleDBL() {
        TST_SRV_TPA_AMAAgreementDetail instance = new TST_SRV_TPA_AMAAgreementDetail();
        instance.setupTestDataForLettershopConditionOfAMA();
        Test.startTest();
        instance.runUnitTestsForConditionServiceBureauIIGreaterThan90Days37WithMultipleDBL();
        Test.stopTest();
    }

    private static testMethod void testTPAQueryHelperForServiceBureauIIGreaterThan90Days39A() {
        TST_SRV_TPA_AMAAgreementDetail instance = new TST_SRV_TPA_AMAAgreementDetail();
        instance.setupTestDataForLettershopConditionOfAMA();
        Test.startTest();
        instance.runUnitTestsForConditionServiceBureauIIGreaterThan90Days39A();
        Test.stopTest();
    }

    private static testMethod void testTPAQueryHelperForServiceBureauIIGreaterThan90Days39B() {
        TST_SRV_TPA_AMAAgreementDetail instance = new TST_SRV_TPA_AMAAgreementDetail();
        instance.setupTestDataForLettershopConditionOfAMA();
        Test.startTest();
        instance.runUnitTestsForConditionServiceBureauIIGreaterThan90Days39B();
        Test.stopTest();
    }

    private static testMethod void testTPAQueryHelperForServiceBureauIIGreaterThan90Days39C() {
        TST_SRV_TPA_AMAAgreementDetail instance = new TST_SRV_TPA_AMAAgreementDetail();
        instance.setupTestDataForLettershopConditionOfAMA();
        Test.startTest();
        instance.runUnitTestsForConditionServiceBureauIIGreaterThan90Days39C();
        Test.stopTest();
    }

    private static testMethod void testTPAQueryHelperForServiceBureauIIGreaterThan90Days39D() {
        TST_SRV_TPA_AMAAgreementDetail instance = new TST_SRV_TPA_AMAAgreementDetail();
        instance.setupTestDataForLettershopConditionOfAMA();
        Test.startTest();
        instance.runUnitTestsForConditionServiceBureauIIGreaterThan90Days39D();
        Test.stopTest();
    }

    private static testMethod void testTPAQueryHelperForServiceBureauIIGreaterThan90Days40() {
        TST_SRV_TPA_AMAAgreementDetail instance = new TST_SRV_TPA_AMAAgreementDetail();
        instance.setupTestDataForLettershopConditionOfAMA();
        Test.startTest();
        instance.runUnitTestsForConditionServiceBureauIIGreaterThan90Days40();
        Test.stopTest();
    }

    private static testMethod void testTPAQueryHelperForServiceBureauIIGreaterThan90Days41() {
        TST_SRV_TPA_AMAAgreementDetail instance = new TST_SRV_TPA_AMAAgreementDetail();
        instance.setupTestDataForLettershopConditionOfAMA();
        Test.startTest();
        instance.runUnitTestsForConditionServiceBureauIIGreaterThan90Days41();
        Test.stopTest();
    }

    private static testMethod void testTPAQueryHelperForServiceBureauIIGreaterThan90Days41With8B() {
        TST_SRV_TPA_AMAAgreementDetail instance = new TST_SRV_TPA_AMAAgreementDetail();
        instance.setupTestDataForLettershopConditionOfAMA();
        Test.startTest();
        instance.runUnitTestsForConditionServiceBureauIIGreaterThan90Days41With8B();
        Test.stopTest();
    }

    private static testMethod void testTPAQueryHelperFor42() {
        TST_SRV_TPA_AMAAgreementDetail instance = new TST_SRV_TPA_AMAAgreementDetail();
        instance.setupTestDataForLettershopConditionOfAMA();
        Test.startTest();
        instance.runUnitTestsForCondition42();
        Test.stopTest();
    }

    private static testMethod void testTPAQueryHelperForServiceBureauIIGreaterThan90Days38() {
        TST_SRV_TPA_AMAAgreementDetail instance = new TST_SRV_TPA_AMAAgreementDetail();
        instance.setupTestDataForLettershopConditionOfAMA();
        Test.startTest();
        instance.runUnitTestsForConditionServiceBureauIIGreaterThan90Days38();
        Test.stopTest();
    }

    private static testMethod void testTPAQueryHelperFor12WithInvalidClient() {
        TST_SRV_TPA_AMAAgreementDetail instance = new TST_SRV_TPA_AMAAgreementDetail();
        //instance.setupTestDataForLettershopConditionOfAMA();
        Test.startTest();
        instance.runUnitTestsForCondition12WithInvalidClient();
        Test.stopTest();
    }

     //Added By Aryen Sharma 
    private static testMethod void testrunUnitTestsForForeignAffiliateofTPAVendor(){
         TST_SRV_TPA_AMAAgreementDetail instance = new TST_SRV_TPA_AMAAgreementDetail();
        instance.setupTestDataForLettershopConditionOfAMA();
        Test.startTest();
        instance.runUnitTestsForForeignAffiliateofTPAVendor();
        Test.stopTest();
    }
    private static testMethod void testTPAQueryHelperForServiceBureauII90daysOrLess31WithNoExistingDiffDBL() {
        TST_SRV_TPA_AMAAgreementDetail instance = new TST_SRV_TPA_AMAAgreementDetail();
        instance.setupTestDataForLettershopConditionOfAMA();
        Test.startTest();
        instance.runUnitTestsForConditionServiceBureauII90daysOrLess31WithNoExistingDiffDBL();
        Test.stopTest();
    }

    private static testMethod void testTPAQueryHelperForServiceBureauIIGreaterThan90Days37With8B() {
        TST_SRV_TPA_AMAAgreementDetail instance = new TST_SRV_TPA_AMAAgreementDetail();
        instance.setupTestDataForLettershopConditionOfAMA();
        Test.startTest();
        instance.runUnitTestsForConditionServiceBureauIIGreaterThan90Days37With8B();
        Test.stopTest();
    }

    private static testMethod void testTPAQueryHelperFor12With4() {
        TST_SRV_TPA_AMAAgreementDetail instance = new TST_SRV_TPA_AMAAgreementDetail();
        Test.startTest();
        instance.runUnitTestsForCondition12With4();
        Test.stopTest();
    }

    private static testMethod void testTPAQueryHelperForLettershopAndSBICondition44() {
        TST_SRV_TPA_AMAAgreementDetail instance = new TST_SRV_TPA_AMAAgreementDetail();
        instance.setupTestDataForLettershopConditionOfAMA();
        Test.startTest();
        instance.runUnitTestsForConditionLettershopAndSBICondition44();
        Test.stopTest();
    }

    private static testMethod void testTPAQueryHelperForLettershopAndSBICondition46() {
        TST_SRV_TPA_AMAAgreementDetail instance = new TST_SRV_TPA_AMAAgreementDetail();
        instance.setupTestDataForLettershopConditionOfAMA();
        Test.startTest();
        instance.runUnitTestsForConditionLettershopAndSBICondition46();
        Test.stopTest();
    }

    private static testMethod void testTPAQueryHelperForLettershopAndSBICondition47() {
        TST_SRV_TPA_AMAAgreementDetail instance = new TST_SRV_TPA_AMAAgreementDetail();
        instance.setupTestDataForLettershopConditionOfAMA();
        Test.startTest();
        instance.runUnitTestsForConditionLettershopAndSBICondition47();
        Test.stopTest();
    }

    private static testMethod void testTPAQueryHelperForLettershopAndSBICondition48() {
        TST_SRV_TPA_AMAAgreementDetail instance = new TST_SRV_TPA_AMAAgreementDetail();
        instance.setupTestDataForLettershopConditionOfAMA();
        Test.startTest();
        instance.runUnitTestsForConditionLettershopAndSBICondition48();
        Test.stopTest();
    }

    private static testMethod void testTPAQueryHelperForLettershopAndSBICondition49() {
        TST_SRV_TPA_AMAAgreementDetail instance = new TST_SRV_TPA_AMAAgreementDetail();
        instance.setupTestDataForLettershopConditionOfAMA();
        Test.startTest();
        instance.runUnitTestsForConditionLettershopAndSBICondition49();
        Test.stopTest();
    }

    private static testMethod void testTPAQueryHelperForLettershopAndSBICondition50() {
        TST_SRV_TPA_AMAAgreementDetail instance = new TST_SRV_TPA_AMAAgreementDetail();
        instance.setupTestDataForLettershopConditionOfAMA();
        Test.startTest();
        instance.runUnitTestsForConditionLettershopAndSBICondition50();
        Test.stopTest();
    }

    // added by Supriya Johari under ER-3886 starts //
    private static testMethod void testTPAQueryHelperForSpecialUseWithSpeccialContractTypes() {
        TST_SRV_TPA_AMAAgreementDetail instance = new TST_SRV_TPA_AMAAgreementDetail();
        instance.setupTestDataForLettershopConditionOfAMA();
        Test.startTest();
        instance.runUnitTestsForConditionforSpecialUseandContractType();
        Test.stopTest();
    }
    // added by Supriya Johari under ER-3886 ends //
    
    private static testMethod void testTPAQueryHelperForPhysicianSpecificAnalyticsWithSameDBL() {
        TST_SRV_TPA_AMAAgreementDetail instance = new TST_SRV_TPA_AMAAgreementDetail();
        instance.setupTestDataForLettershopConditionOfAMA();
        Test.startTest();
        instance.runUnitTestsForConditionforPhysicianSpecificAnalyticsWithSameDBL();
        Test.stopTest();
    }
    
    private static testMethod void testTPAQueryHelperForPhysicianSpecificAnalyticsWithDifDBL() {
        TST_SRV_TPA_AMAAgreementDetail instance = new TST_SRV_TPA_AMAAgreementDetail();
        instance.setupTestDataForLettershopConditionOfAMA();
        Test.startTest();
        instance.runUnitTestsForConditionforPhysicianSpecificAnalyticsWithDifDBL();
        Test.stopTest();
    }

    //Added by Rajendra under ER-11891 -- Start
      private static testMethod void testCondition60to65() {
          TST_SRV_TPA_AMAAgreementDetail instance = new TST_SRV_TPA_AMAAgreementDetail();
          instance.setupTestDataForLettershopConditionOfAMA();
          Test.startTest();
          instance.runUnitTestsForCondition60to65();
          Test.stopTest();
      }
    //Added by Rajendra under ER-11891 -- End
    
    private void setupTestData() {

        UTL_TPA_SetupTestData.createCrossWalkData();

        // create test account for Vendor
        account = UTL_TPA_SetupTestData.getBlankAccount();
        account.Name = 'Test Account';
        account.Vendor_Tier__c = 'Y';
        account.Is_Payment_Risk__c = true;
        account.Vendor_Registration_Number__c = 9999;
        account.is_TPA_Account__c = true;
        account.Street__c = 'test';
        account.City__c = 'test';
        account.Country__c = 'test';
        account.PostalCode__c = 'test';
        insert account;

        con = UTL_TPA_SetupTestData.getContact();
        con.LastName = 'Test Contact';
        con.Email = 'test@test.com';
        con.AccountId = account.id;
        insert con;

        // Create test tpa request
        tpaRequest1 = UTL_TPA_SetupTestData.getTPARequestBlank(false);
        tpaRequest1.OwnerId = UserInfo.getUserId();
        tpaRequest1.Client_Region__c = TEST_REGION;
        tpaRequest1.Data_Provided_By__c = 'IQVIA in lieu of Client';
        tpaRequest1.Is_Data_Accessed_Via_IMS_Software__c = 'Yes';
        tpaRequest1.AMA_USPrescriberData__c = 'Yes';
        tpaRequest1.Does_the_request_require_information_con__c = 'Yes';
        tpaRequest1.Service_Provider_Address__c = account.Id;
        tpaRequest1.Client_Address__c = account.Id;
        tpaRequest1.ClientContact__c = con.Id;
        tpaRequest1.Vendor_Company_Name__c = 'Test company';
        tpaRequest1.Is_Potential_Vendor_Case__c = false;
        tpaRequest1.TP_Processor_Email__c = 'a.a@g.com';
        tpaRequest1.Authorized_Signer_Email__c = 'test@mail.com';
        tpaRequest1.Data_Delivered_By__c = 'IQVIA Software';
        tpaRequest1.Data_Access_Start_Date__c = Date.newInstance(2016, 10, 20);
        tpaRequest1.Data_Access_End_Date__c = Date.newInstance(2017, 12, 31);
        tpaRequest1.vendor_language__c = 'English';
        insert tpaRequest1;
        system.assert(tpaRequest1.Id != null);

        Attachment attachment = UTL_TPA_SetupTestData.addAttachment(tpaRequest1.Id, 'Vendor\'s Operation Guide.pdf');
        insert(attachment);

        UTL_TPA_SetupTestData.createTPASettingData();

        Watch_List__c watchObj = UTL_TPA_SetupTestData.createWatchList(tpaRequest1.Service_Provider_Address__c);
        watchObj.Offering__c = 'Asset 1';
        watchObj.Use__c = 'test purpose';
        insert watchObj;

        amaAgg = UTL_TPA_SetupTestData.getAMAAgreementDetailBlank(tpaRequest1.Id);
        amaAgg.Agreement_Start_Date__c = Date.newInstance(2016, 10, 20);
        amaAgg.Agreement_End_Date__c = Date.newInstance(2017, 12, 31);
        amaAgg.AMA_Howlong_SP_has_Data_Access__c = '90 days or less';
        amaAgg.FrequencyOfDeliveryToServiceProvider__c = 'Quarterly';
        amaAgg.AMA_TypeOfPrescriberLevelData__c = 'Birth Year;Gender Code';
        amaAgg.AMA_Services_Provided__c = 'Telemarketing;Labeling';
        insert amaAgg;

        // create test contact
        tpaContact = UTL_TPA_SetupTestData.getTestTPAContact(tpaRequest1);
        tpaContact.Name = 'Initiator Contact';
        tpaContact.Type__c = 'Initiator Contact';
        tpaContact.Company_Name__c = 'Test Company';
        tpaContact.Email__c = 'testcontact@apttus.com';
        tpaContact.Title__c = 'Test Manager';
        tpaContact.Phone__c = '408-123-5678';
        tpaContact.AddressLine1__c = '1400 Fashion Island Blvd';
        tpaContact.City__c = 'San Mateo';
        tpaContact.State__c = 'CA';
        tpaContact.ZipCode__c = '94404';
        insert tpaContact;
        system.assert(tpaContact.Id != null);

        // create test ims purpose
        imsPurpose1 = UTL_TPA_SetupTestData.getIMSTpaPurposeData();
        imsPurpose1.Name = 'test purpose';
        imsPurpose1.Purpose_Details__c = 'test purpose details';
        imsPurpose1.Consulting_Area__c = 'test consulting area';
        imsPurpose1.Business_Line__c = 'test business line';
        imsPurpose1.Primary_Purpose_Name__c = 'test purpose';
        insert imsPurpose1;
        system.assert(imsPurpose1.Id != null);
        // Create test TPA Purposes
        tpaPurpose1 = UTL_TPA_SetupTestData.createTpaPurposeByReqId(tpaRequest1);
        tpaPurpose1.Name = 'test purpose';
        tpaPurpose1.Region__c = TEST_REGION;
        tpaPurpose1.Purpose__c = imsPurpose1.Id;
        tpaPurpose1.Prescriber_ID_Number__c = null;
        tpaPurpose1.Prescriber_ID_Number_Details__c = null;
        tpaPurpose1.PrescriberNPINumber__c = null;
        tpaPurpose1.PrescriberNPINumber_Details__c = null;
        tpaPurpose1.OutletReferenceFiles__c = null;
        tpaPurpose1.Other_Reference_File__c = null;
        tpaPurpose1.Other_Details__c = '';
        tpaPurpose1.Other_Text__c = '';
        tpaPurpose1.NCPDPIDorNPIOutletNumber__c = null;
        tpaPurpose1.NCPDPIDorNPIOutletNumber_Details__c = null;
        tpaPurpose1.Managed_Care__c = null;
        tpaPurpose1.Managed_Care_Details__c = null;
        tpaPurpose1.Linked_Data_Description__c = null;
        tpaPurpose1.IMSPrescriberIDNumber__c = null;
        tpaPurpose1.IMSPrescriberIDNumber_Details__c = null;
        tpaPurpose1.FinDr_ID__c = null;
        tpaPurpose1.Extended_Category_Codes__c = null;
        tpaPurpose1.Deliverables_Freq_To_Client__c = null;
        tpaPurpose1.Data_Usage__c = null;
        tpaPurpose1.Data_Assets__c = null;
        tpaPurpose1.Client_Deliverables__c = null;
        tpaPurpose1.Additional_Reference_Info__c = null;
        tpaPurpose1.AMABridgeFile__c = null;
        tpaPurpose1.AMABridgeFile_Details__c = null;
        insert tpaPurpose1;
        system.assert(tpaPurpose1.Id != null);

        tpaPurpose2 = UTL_TPA_SetupTestData.createTpaPurposeByReqId(tpaRequest1);
        tpaPurpose2.Name = 'Other';
        tpaPurpose2.Region__c = TEST_REGION;
        tpaPurpose2.Purpose__c = null;
        tpaPurpose2.Prescriber_ID_Number__c = null;
        tpaPurpose2.Prescriber_ID_Number_Details__c = null;
        tpaPurpose2.PrescriberNPINumber__c = null;
        tpaPurpose2.PrescriberNPINumber_Details__c = null;
        tpaPurpose2.OutletReferenceFiles__c = null;
        tpaPurpose2.Other_Reference_File__c = null;
        tpaPurpose2.Other_Details__c = '';
        tpaPurpose2.other_Text__c = 'Other use 1';
        tpaPurpose2.NCPDPIDorNPIOutletNumber__c = null;
        tpaPurpose2.NCPDPIDorNPIOutletNumber_Details__c = null;
        tpaPurpose2.Managed_Care__c = null;
        tpaPurpose2.Managed_Care_Details__c = null;
        tpaPurpose2.Linked_Data_Description__c = null;
        tpaPurpose2.IMSPrescriberIDNumber__c = null;
        tpaPurpose2.IMSPrescriberIDNumber_Details__c = null;
        tpaPurpose2.FinDr_ID__c = null;
        tpaPurpose2.Extended_Category_Codes__c = null;
        tpaPurpose2.Deliverables_Freq_To_Client__c = null;
        tpaPurpose2.Data_Usage__c = null;
        tpaPurpose2.Data_Assets__c = null;
        tpaPurpose2.Client_Deliverables__c = null;
        tpaPurpose2.Additional_Reference_Info__c = null;
        tpaPurpose2.AMABridgeFile__c = null;
        tpaPurpose2.AMABridgeFile_Details__c = null;
        insert tpaPurpose2;
        system.assert(tpaPurpose2.Id != null);

        tpaPurpose3 = UTL_TPA_SetupTestData.createTpaPurposeByReqId(tpaRequest1);
        tpaPurpose3.Name = null;
        tpaPurpose3.Region__c = TEST_REGION;
        tpaPurpose3.Purpose__c = null;
        tpaPurpose3.Prescriber_ID_Number__c = null;
        tpaPurpose3.Prescriber_ID_Number_Details__c = null;
        tpaPurpose3.PrescriberNPINumber__c = null;
        tpaPurpose3.PrescriberNPINumber_Details__c = null;
        tpaPurpose3.OutletReferenceFiles__c = null;
        tpaPurpose3.Other_Reference_File__c = null;
        tpaPurpose3.Other_Details__c = '';
        tpaPurpose3.other_Text__c = '';
        tpaPurpose3.NCPDPIDorNPIOutletNumber__c = null;
        tpaPurpose3.NCPDPIDorNPIOutletNumber_Details__c = null;
        tpaPurpose3.Managed_Care__c = null;
        tpaPurpose3.Managed_Care_Details__c = null;
        tpaPurpose3.Linked_Data_Description__c = null;
        tpaPurpose3.IMSPrescriberIDNumber__c = null;
        tpaPurpose3.IMSPrescriberIDNumber_Details__c = null;
        tpaPurpose3.FinDr_ID__c = null;
        tpaPurpose3.Extended_Category_Codes__c = null;
        tpaPurpose3.Deliverables_Freq_To_Client__c = null;
        tpaPurpose3.Data_Usage__c = null;
        tpaPurpose3.Data_Assets__c = null;
        tpaPurpose3.Client_Deliverables__c = null;
        tpaPurpose3.Additional_Reference_Info__c = null;
        tpaPurpose3.AMABridgeFile__c = null;
        tpaPurpose3.AMABridgeFile_Details__c = null;
        insert tpaPurpose3;
        system.assert(tpaPurpose3.Id != null);

        tpaPurpose4 = UTL_TPA_SetupTestData.createTpaPurposeByReqId(tpaRequest1);
        tpaPurpose4.Name = null;
        tpaPurpose4.Region__c = TEST_REGION;
        tpaPurpose4.Purpose__c = null;
        tpaPurpose4.Prescriber_ID_Number__c = null;
        tpaPurpose4.Prescriber_ID_Number_Details__c = null;
        tpaPurpose4.PrescriberNPINumber__c = null;
        tpaPurpose4.PrescriberNPINumber_Details__c = null;
        tpaPurpose4.OutletReferenceFiles__c = null;
        tpaPurpose4.Other_Reference_File__c = null;
        tpaPurpose4.Other_Details__c = '';
        tpaPurpose4.other_Text__c = '';
        tpaPurpose4.NCPDPIDorNPIOutletNumber__c = null;
        tpaPurpose4.NCPDPIDorNPIOutletNumber_Details__c = null;
        tpaPurpose4.Managed_Care__c = null;
        tpaPurpose4.Managed_Care_Details__c = null;
        tpaPurpose4.Linked_Data_Description__c = null;
        tpaPurpose4.IMSPrescriberIDNumber__c = null;
        tpaPurpose4.IMSPrescriberIDNumber_Details__c = null;
        tpaPurpose4.FinDr_ID__c = null;
        tpaPurpose4.Extended_Category_Codes__c = null;
        tpaPurpose4.Deliverables_Freq_To_Client__c = null;
        tpaPurpose4.Data_Usage__c = null;
        tpaPurpose4.Data_Assets__c = null;
        tpaPurpose4.Client_Deliverables__c = null;
        tpaPurpose4.Additional_Reference_Info__c = null;
        tpaPurpose4.AMABridgeFile__c = null;
        tpaPurpose4.AMABridgeFile_Details__c = null;
        insert tpaPurpose4;
        system.assert(tpaPurpose4.Id != null);

        //Create test purpose category
        purposeCategory1 = UTL_TPA_SetupTestData.getTpaPurposeCategory('Test Category');
        insert purposeCategory1;

        //Create test ims purpose description
        imsPurposeDescription1 = UTL_TPA_SetupTestData.getImsTpaPurpDes();
        imsPurposeDescription1.Description__c = 'Test Description';
        imsPurposeDescription1.Purpose__c = imsPurpose1.Id;
        imsPurposeDescription1.TPA_Purpose_Category__c = purposeCategory1.Id;
        imsPurposeDescription1.Requires_Manual_Review__c = True;
        insert imsPurposeDescription1;

        // create test IMS data assets
        imsDataAsset1 = UTL_TPA_SetupTestData.createImsDataAsset_Template();
        imsDataAsset1.Asset_Name__c = 'Asset 1';
        imsDataAsset1.Region__c = TEST_REGION;
        imsDataAsset1.Requires_Manual_Review__c = true;
        insert imsDataAsset1;
        system.assert(imsDataAsset1.Id != null);

        imsDataAsset2 = UTL_TPA_SetupTestData.createImsDataAsset_Template();
        imsDataAsset2.Asset_Name__c = 'Asset 2';
        imsDataAsset2.Region__c = TEST_REGION;
        imsDataAsset2.Is_Restricted_Data__c = True;
        imsDataAsset2.Requires_Fee__c = True;
        imsDataAsset2.Requires_Manual_Review__c = true;
        insert imsDataAsset2;
        system.assert(imsDataAsset2.Id != null);

        imsDataAsset3 = UTL_TPA_SetupTestData.createImsDataAsset_Template();
        imsDataAsset3.Asset_Name__c = 'Asset 3';
        imsDataAsset3.Region__c = TEST_REGION;
        imsDataAsset3.Is_Restricted_Data__c = True;
        imsDataAsset3.Requires_Fee__c = True;
        imsDataAsset3.Requires_Manual_Review__c = true;
        insert imsDataAsset3;
        system.assert(imsDataAsset3.Id != null);

        imsDataAsset4 = UTL_TPA_SetupTestData.createImsDataAsset_Template();
        imsDataAsset4.Asset_Name__c = 'Other';
        imsDataAsset4.Region__c = TEST_REGION;
        imsDataAsset4.Is_Restricted_Data__c = True;
        imsDataAsset4.Requires_Fee__c = True;
        imsDataAsset4.Requires_Manual_Review__c = true;
        insert imsDataAsset4;
        system.assert(imsDataAsset4.Id != null);

        imsDataAsset5 = UTL_TPA_SetupTestData.createImsDataAsset_Template();
        imsDataAsset5.Asset_Name__c = 'RWE Custom Study Name & Project Delivery Date:';
        imsDataAsset5.Region__c = TEST_REGION;
        imsDataAsset5.Is_Restricted_Data__c = True;
        imsDataAsset5.Requires_Fee__c = True;
        imsDataAsset5.Requires_Manual_Review__c = true;
        insert imsDataAsset5;
        system.assert(imsDataAsset5.Id != null);

        // Create test tpa purpose descriptions
        tpaPurposeDescription1 = UTL_TPA_SetupTestData.getTpaPurpDes();
        tpaPurposeDescription1.Purpose__c = tpaPurpose1.Id;
        tpaPurposeDescription1.Description__c = imsPurposeDescription1.Id;
        tpaPurposeDescription1.Requires_Manual_Review__c = imsPurposeDescription1.Requires_Manual_Review__c;
        insert tpaPurposeDescription1;

        tpaPurposeDescription2 = UTL_TPA_SetupTestData.getTpaPurpDes();
        tpaPurposeDescription2.Purpose__c = tpaPurpose2.Id;
        tpaPurposeDescription2.Description__c = imsPurposeDescription1.Id;
        tpaPurposeDescription2.Requires_Manual_Review__c = imsPurposeDescription1.Requires_Manual_Review__c;
        insert tpaPurposeDescription2;

        // create test TPA data assets
        tpaDataAsset1 = UTL_TPA_SetupTestData.getTpaDataAsset(tpaPurpose1.Id);
        tpaDataAsset1.Request__c = tpaRequest1.Id;
        tpaDataAsset1.Region__c = TEST_REGION;
        tpaDataAsset1.Data_Asset__c = imsDataAsset1.Id;
        tpaDataAsset1.BU__c = TEST_REGION;
        tpaDataAsset1.Geo_Level__c = 'Real World Evidence';
        insert tpaDataAsset1;
        system.assert(tpaDataAsset1.Id != null);

        tpaDataAsset2 = UTL_TPA_SetupTestData.getTpaDataAsset(tpaPurpose1.Id);
        tpaDataAsset2.Request__c = tpaRequest1.Id;
        tpaDataAsset2.Region__c = TEST_REGION;
        tpaDataAsset2.Data_Asset__c = imsDataAsset2.Id;
        tpaDataAsset2.Is_Restricted_Data__c = imsDataAsset2.Is_Restricted_Data__c;
        tpaDataAsset2.BU__c = TEST_REGION;
        tpaDataAsset2.Geo_Level__c = 'Anonymized Patient-Level Data / Transaction-Level';
        insert tpaDataAsset2;
        system.assert(tpaDataAsset2.Id != null);

        tpaDataAsset3 = UTL_TPA_SetupTestData.getTpaDataAsset(tpaPurpose1.Id);
        tpaDataAsset3.Request__c = tpaRequest1.Id;
        tpaDataAsset3.Region__c = TEST_REGION;
        tpaDataAsset3.Data_Asset__c = imsDataAsset3.Id;
        tpaDataAsset3.Is_Restricted_Data__c = imsDataAsset3.Is_Restricted_Data__c;
        insert tpaDataAsset3;
        system.assert(tpaDataAsset3.Id != null);

        tpaDataAsset4 = UTL_TPA_SetupTestData.getTpaDataAsset(tpaPurpose1.Id);
        tpaDataAsset4.Request__c = tpaRequest1.Id;
        tpaDataAsset4.Region__c = TEST_REGION;
        tpaDataAsset4.Data_Asset__c = imsDataAsset4.Id;
        tpaDataAsset4.Other_Data_Asset_Details__c = 'Other Data Asset';
        tpaDataAsset4.Is_Restricted_Data__c = imsDataAsset4.Is_Restricted_Data__c;
        insert tpaDataAsset4;
        system.assert(tpaDataAsset4.Id != null);

        date myDate = date.newInstance(2016, 11, 21);
        tpaDataAsset5 = UTL_TPA_SetupTestData.getTpaDataAsset(tpaPurpose1.Id);
        tpaDataAsset5.Request__c = tpaRequest1.Id;
        tpaDataAsset5.Asset_NametText__c = 'RWE Custom Study Name & Project Delivery Date:';
        tpaDataAsset5.RWE_Delivery_Date__c = myDate;
        tpaDataAsset5.RWE_Study_Name__c = 'test stude';
        tpaDataAsset5.Region__c = TEST_REGION;
        tpaDataAsset5.Data_Asset__c = imsDataAsset5.Id;
        tpaDataAsset5.BU__c = TEST_REGION;
        tpaDataAsset5.Geo_Level__c = 'Real World Evidence';
        insert tpaDataAsset5;
        system.assert(tpaDataAsset5.Id != null);

        imsSecondaryDataAsset1 = UTL_TPA_SetupTestData.getImsSecDataAsset();
        imsSecondaryDataAsset1.Primary_Data_Asset__c = imsDataAsset1.Id;
        imsSecondaryDataAsset1.Requires_Manual_Review__c = true;
        imsSecondaryDataAsset1.Is_Restricted_Data__c = true;
        imsSecondaryDataAsset1.Secondary_Asset_Name__c = 'ims sec asset 1';
        insert imsSecondaryDataAsset1;
        system.assert(imsSecondaryDataAsset1.Id != null);

        imsSecondaryDataAsset2 = UTL_TPA_SetupTestData.getImsSecDataAsset();
        imsSecondaryDataAsset2.Primary_Data_Asset__c = imsDataAsset2.Id;
        imsSecondaryDataAsset2.Requires_Manual_Review__c = true;
        imsSecondaryDataAsset2.Is_Restricted_Data__c = true;
        imsSecondaryDataAsset2.Secondary_Asset_Name__c = 'ims sec asset 2';
        insert imsSecondaryDataAsset2;
        system.assert(imsSecondaryDataAsset2.Id != null);

        tpaSecondaryDataAsset1 = UTL_TPA_SetupTestData.getTpaSecDataAsset();
        tpaSecondaryDataAsset1.TPA_Data_Asset__c = tpaDataAsset1.Id;
        tpaSecondaryDataAsset1.IMS_Secondary_Data_Asset__c = imsSecondaryDataAsset1.id;
        tpaSecondaryDataAsset1.Secondary_Asset_Name__c = 'tpa sec asset 1';
        insert tpaSecondaryDataAsset1;
        system.assert(tpaSecondaryDataAsset1.Id != null);

        tpaSecondaryDataAsset2 = UTL_TPA_SetupTestData.getTpaSecDataAsset();
        tpaSecondaryDataAsset2.TPA_Data_Asset__c = tpaDataAsset2.Id;
        tpaSecondaryDataAsset2.IMS_Secondary_Data_Asset__c = imsSecondaryDataAsset2.id;
        tpaSecondaryDataAsset2.Secondary_Asset_Name__c = 'tpa sec asset 2';
        insert tpaSecondaryDataAsset2;
        system.assert(tpaSecondaryDataAsset2.Id != null);

        IMS_Use_Offering_Atypical_Combination__c IMSUseOfferingAtypicalCombinationObj = new IMS_Use_Offering_Atypical_Combination__c(Use_Category__c = purposeCategory1.id,Use_Name__c = imsPurpose1.id, Offering_Name__c =  imsDataAsset1.id, Secondary_Offering_Name__c = imsSecondaryDataAsset1.id, isActive__c = true, is_Approved_For_Future__c = false);
        insert IMSUseOfferingAtypicalCombinationObj;
        TPA_Use_Offering_Atypical_Combination__c TPAUseOfferingAtypicalCombinationObj = new TPA_Use_Offering_Atypical_Combination__c(IMS_Use_Offering_Atypical_Combination__c = IMSUseOfferingAtypicalCombinationObj.id, TPA_Request__c = tpaRequest1.id);
        insert TPAUseOfferingAtypicalCombinationObj;

        IMS_Use_Offering_Atypical_Combination__c IMSUseOfferingAtypicalCombinationObj1 = new IMS_Use_Offering_Atypical_Combination__c(Use_Category__c = purposeCategory1.id,Use_Name__c = imsPurpose1.id, Offering_Name__c =  imsDataAsset5.id, isActive__c = true, is_Approved_For_Future__c = false);
        insert IMSUseOfferingAtypicalCombinationObj1;
        TPA_Use_Offering_Atypical_Combination__c TPAUseOfferingAtypicalCombinationObj1 = new TPA_Use_Offering_Atypical_Combination__c(IMS_Use_Offering_Atypical_Combination__c = IMSUseOfferingAtypicalCombinationObj.id, TPA_Request__c = tpaRequest1.id);
        insert TPAUseOfferingAtypicalCombinationObj1;
    }

    private void setupTestDataForLettershopConditionOfAMA() {
        // create test account for Vendor
        testVendorAccount = UTL_TPA_SetupTestData.getBlankAccount();
        testVendorAccount.Name = 'test Vendor';
        testVendorAccount.Vendor_Tier__c = 'Y';
        testVendorAccount.Is_Payment_Risk__c = true;
        testVendorAccount.Vendor_Registration_Number__c = 9991;
        testVendorAccount.is_TPA_Account__c = true;
        testVendorAccount.Street__c = 'test';
        testVendorAccount.City__c = 'test';
        testVendorAccount.Country__c = 'test';
        testVendorAccount.PostalCode__c = 'test';
        insert testVendorAccount;

        // create test account for client
        testSameClentAccount = UTL_TPA_SetupTestData.getBlankAccount();
        testSameClentAccount.Name = 'test Same Clent';
        testSameClentAccount.is_TPA_Account__c = true;
        testSameClentAccount.Street__c = 'test';
        testSameClentAccount.City__c = 'test';
        testSameClentAccount.Country__c = 'test';
        testSameClentAccount.PostalCode__c = 'test';
        testSameClentAccount.AMA_Special_Handling__c = true;
        insert testSameClentAccount;

        // create test account for client
        testDifferentClentAccount = UTL_TPA_SetupTestData.getBlankAccount();
        testDifferentClentAccount.Name = 'test Different Clent';
        testDifferentClentAccount.is_TPA_Account__c = true;
        testDifferentClentAccount.Street__c = 'test';
        testDifferentClentAccount.City__c = 'test';
        testDifferentClentAccount.Country__c = 'test';
        testDifferentClentAccount.PostalCode__c = 'test';
        insert testDifferentClentAccount;

        // create test account for Client Vendor Search Map
        TPA_AMA_Client_Vendor_Search_Map__c clientVendorMatchRecord1 = UTL_TPA_SetupTestData.getTpaAmaClientVendSearchMap();
        clientVendorMatchRecord1.TPA_Account_Address__c = testVendorAccount.id;
        clientVendorMatchRecord1.AMA_Account_Search_Text__c = 'test Vendor';
        insert clientVendorMatchRecord1;
        TPA_AMA_Client_Vendor_Search_Map__c clientVendorMatchRecord2 = UTL_TPA_SetupTestData.getTpaAmaClientVendSearchMap();
        clientVendorMatchRecord2.TPA_Account_Address__c = testSameClentAccount.id;
        clientVendorMatchRecord2.AMA_Account_Search_Text__c = 'test Same Clent';
        insert clientVendorMatchRecord2;
        TPA_AMA_Client_Vendor_Search_Map__c clientVendorMatchRecord3 = UTL_TPA_SetupTestData.getTpaAmaClientVendSearchMap();
        clientVendorMatchRecord3.TPA_Account_Address__c = testDifferentClentAccount.id;
        clientVendorMatchRecord3.AMA_Account_Search_Text__c = 'test Different Clent';
        insert clientVendorMatchRecord3;

        //   create contract of the client with itself
        createContract('test Same Clent', 'test Same Clent', 'Biotech Firm', 'DMD', False);

        UTL_TPA_SetupTestData.createTPASettingData();

        // Create test Tpa Request
        testTpaRequest = UTL_TPA_SetupTestData.getTPARequestBlank(false);
        testTpaRequest.OwnerId = UserInfo.getUserId();
        testTpaRequest.AMA_USPrescriberData__c = 'Yes';
        testTpaRequest.Service_Provider_Address__c = testVendorAccount.Id;
        testTpaRequest.Client_Address__c = testSameClentAccount.Id;
        testTpaRequest.Vendor_Company_Name__c = 'Test company';
        testTpaRequest.data_access_start_date__c = Date.newInstance(2016, 10, 20);
        testTpaRequest.data_access_end_date__c = Date.newInstance(2017, 8, 20);
        insert testTpaRequest;
        system.assert(testTpaRequest.Id != null);


        AMA_Fee_Master__c feeRule1 = new AMA_Fee_Master__c(Contract_Type__c = 'Service Bureau II',Fee__c = 21000,
                                                           Fee_Calculated__c = 'Calculate Fee',
                                                           Proration_Rules_Applied__c = True,
                                                           Vendor_has_Licence__c = 'has no existing License with AMA',
                                                           Year__c = '2016');
        insert feeRule1;

        AMA_Fee_Master__c feeRule2 = new AMA_Fee_Master__c(Contract_Type__c = 'Contract Sales Force',Fee__c = 36000,
                                                           Fee_Calculated__c = 'Calculate Fee',
                                                           Proration_Rules_Applied__c = True,
                                                           Vendor_has_Licence__c = 'has no existing License with AMA',
                                                           Year__c = '2016');
        insert feeRule2;

        AMA_Fee_Master__c feeRule3 = new AMA_Fee_Master__c(Contract_Type__c = 'Lettershop',Fee__c = 0,
                                                           Fee_Calculated__c = 'No Fee',
                                                           Proration_Rules_Applied__c = False,
                                                           Vendor_has_Licence__c = 'has no existing License with AMA',
                                                           Year__c = '2016');
        insert feeRule3;

        AMA_Fee_Master__c feeRule4 = new AMA_Fee_Master__c(Contract_Type__c = 'Service Bureau II',Fee__c = 21000,
                                                           Fee_Calculated__c = 'Calculate Fee if vendor has not reached �Maxed Fees�',
                                                           Proration_Rules_Applied__c = True,
                                                           Vendor_has_Licence__c = 'has existing licence with different client listed on TPA form',
                                                           Year__c = '2016');
        insert feeRule4;

        AMA_Fee_Master__c feeRule5 = new AMA_Fee_Master__c(Contract_Type__c = 'Service Bureau I',Fee__c = 0,
                                                           Fee_Calculated__c = 'No Fee',
                                                           Proration_Rules_Applied__c = False,
                                                           Vendor_has_Licence__c = 'has no existing Licence with AMA',
                                                           Year__c = '2016');
        insert feeRule5;

        AMA_Fee_Master__c feeRule6 = new AMA_Fee_Master__c(Contract_Type__c = 'Service Bureau II',Fee__c = 21000,
                                                           Fee_Calculated__c = 'Calculate Fee',
                                                           Proration_Rules_Applied__c = True,
                                                           Vendor_has_Licence__c = 'has no existing Licence with AMA',
                                                           Year__c = '2016');
        insert feeRule6;

        AMA_Fee_Master__c feeRule7 = new AMA_Fee_Master__c(Contract_Type__c = 'Contract Sales Force',Fee__c = 36000,
                                                           Fee_Calculated__c = 'Calculate Fee',
                                                           Proration_Rules_Applied__c = True,
                                                           Vendor_has_Licence__c = 'has existing licence either with same or different client listed on TPA form',
                                                           Year__c = '2016');
        insert feeRule7;

        AMA_Fee_Master__c feeRule8 = new AMA_Fee_Master__c(Contract_Type__c = 'Service Bureau II',Fee__c = 21000,
                                                           Fee_Calculated__c = 'Calculate Fee',
                                                           Proration_Rules_Applied__c = True,
                                                           Vendor_has_Licence__c = 'has no existing Licence with AMA',
                                                           Year__c = '2016');
        insert feeRule8;
    }

     static String getJsonStringOfTPARequest() {
        TPA_Request__c objRequest = [select id,(select id,Contract_Type__c,Agreement_Start_Date__c,Agreement_End_Date__c,Current_Year__c,AMA_Howlong_SP_has_Data_Access__c,FrequencyOfDeliveryToServiceProvider__c, Client_AMA_Manually_Validated__c, AMA_TypeOfPrescriberLevelData__c,AMA_Services_Provided__c from AMA_Agreement_Details__r) , AMA_USPrescriberData__c, data_access_start_date__c,data_access_end_date__c,TP_Processor_Email__c,Service_Provider_Address__c,Service_Provider_Address__r.Vendor_Registration_Number__c,Client_Address__c,Vendor_e_mail__c,IMS_Data_Country_Location__c,Employee_Accessing_Data_Location__c,Vendor_Billing_Mailing_Country__c from TPA_request__c where id =: testTpaRequest.Id];
        String JSONString = JSON.serialize(objRequest);
        return JSONString;
    }

    static void createContract(String clientName, String vendorName, String contractType, String DBL,Boolean isMaxFeeReached) {
        AMA_Contract_Detail__c amaContract1;
        if(clientName.equalsIgnoreCase(vendorName)){
            amaContract1 = UTL_TPA_SetupTestData.getAmaContractDetail();
            amaContract1.Client__c = vendorName;
            amaContract1.Client_Services_On_Behalf_Of__c = '(Own Behalf)';
            amaContract1.Contract_End_Date__c = Date.newInstance(2018, 10, 20);
            amaContract1.Contract_List_Type__c = 'Client';
            amaContract1.Contract_Type__c = contractType;
            amaContract1.DBL__c = DBL;
            amaContract1.Max_Fee_Reached__c = isMaxFeeReached;
            amaContract1.Offshore_Approval__c = false;
        }
        else{
            amaContract1 = UTL_TPA_SetupTestData.getAmaContractDetail();
            amaContract1.Client__c = vendorName;
            amaContract1.Client_Services_On_Behalf_Of__c = clientName;
            amaContract1.Contract_End_Date__c = Date.newInstance(2018, 10, 20);
            amaContract1.Contract_List_Type__c = 'Client';
            amaContract1.Contract_Type__c = contractType;
            amaContract1.DBL__c = DBL;
            amaContract1.Max_Fee_Reached__c = isMaxFeeReached;
            amaContract1.Offshore_Approval__c = false;
        }
        insert amaContract1;
    }

    static void createClientVendorAccount() {
          // create test account for Vendor
        testVendorAccount = UTL_TPA_SetupTestData.getBlankAccount();
        testVendorAccount.Name = 'test Vendor';
        testVendorAccount.Vendor_Tier__c = 'Y';
        testVendorAccount.Is_Payment_Risk__c = true;
        testVendorAccount.Vendor_Registration_Number__c = 9991;
        testVendorAccount.is_TPA_Account__c  =true;
        testVendorAccount.Street__c = 'test';
        testVendorAccount.City__c = 'test';
        testVendorAccount.Country__c = 'test';
        testVendorAccount.PostalCode__c = 'test';
        insert testVendorAccount;

        // create test account for client
        testSameClentAccount = UTL_TPA_SetupTestData.getBlankAccount();
        testSameClentAccount.Name = 'test Same Clent';
        testSameClentAccount.is_TPA_Account__c = true;
        testSameClentAccount.Street__c = 'test';
        testSameClentAccount.City__c = 'test';
        testSameClentAccount.Country__c = 'test';
        testSameClentAccount.PostalCode__c = 'test';
        insert testSameClentAccount;

        // create test account for Client Vendor Search Map
        TPA_AMA_Client_Vendor_Search_Map__c clientVendorMatchRecord1 = UTL_TPA_SetupTestData.getTpaAmaClientVendSearchMap();
        clientVendorMatchRecord1.TPA_Account_Address__c = testVendorAccount.id;
        clientVendorMatchRecord1.AMA_Account_Search_Text__c = 'test Vendor';
        insert clientVendorMatchRecord1;
        TPA_AMA_Client_Vendor_Search_Map__c clientVendorMatchRecord2 = UTL_TPA_SetupTestData.getTpaAmaClientVendSearchMap();
        clientVendorMatchRecord2.TPA_Account_Address__c = testSameClentAccount.id;
        clientVendorMatchRecord2.AMA_Account_Search_Text__c = 'test Same Clent';
        insert clientVendorMatchRecord2;

        UTL_TPA_SetupTestData.createTPASettingData();
    }
    
    private void runUnitTestsForCondition12() {
        // Create test AMA Agreement Detail
        AMA_Agreement_Detail__c amaAgg = UTL_TPA_SetupTestData.getAMAAgreementDetailBlank(testTpaRequest.Id);
        amaAgg.Contract_Type__c = 'Lettershop';
        amaAgg.Agreement_Start_Date__c = Date.newInstance(2016, 10, 20);
        amaAgg.Agreement_End_Date__c = Date.newInstance(2017, 12, 31);
        amaAgg.AMA_Howlong_SP_has_Data_Access__c = '90 days or less';
        amaAgg.FrequencyOfDeliveryToServiceProvider__c = 'Quarterly';
        amaAgg.AMA_TypeOfPrescriberLevelData__c = 'Birth Year;Gender Code';
        amaAgg.AMA_Services_Provided__c = 'Telemarketing;Labeling';
        amaAgg.Is_Offshore_Access_Amendment_Required__c = false;
        insert amaAgg;

        TPA_Request__c testRequest = [select id,(select id, Contract_Type__c,Is_Offshore_Access_Amendment_Required__c,Current_Year__c, TPA_Request__c from AMA_Agreement_Details__r) from TPA_Request__c where id = : testTpaRequest.id];
        SRV_TPA_AMAAgreementDetail.generateAmaAgreement(testRequest);
        SRV_TPA_AMAAgreementDetail.validateFunctionalRequirements(getJsonStringOfTPARequest());
    }

    //Added By Aryen Sharma

    private void runUnitTestsForForeignAffiliateofTPAVendor() {
        // Create test AMA Agreement Detail
        AMA_Agreement_Detail__c amaAgg = UTL_TPA_SetupTestData.getAMAAgreementDetailBlank(testTpaRequest.Id);
        amaAgg.Contract_Type__c = 'Lettershop';
        amaAgg.Agreement_Start_Date__c = Date.newInstance(2016, 10, 20);
        amaAgg.Agreement_End_Date__c = Date.newInstance(2017, 12, 31);
        amaAgg.AMA_Howlong_SP_has_Data_Access__c = '90 days or less';
        amaAgg.FrequencyOfDeliveryToServiceProvider__c = 'Quarterly';
        amaAgg.AMA_TypeOfPrescriberLevelData__c = 'Birth Year;Gender Code';
        amaAgg.AMA_Services_Provided__c = 'Telemarketing;Labeling';
        amaAgg.Is_Offshore_Access_Amendment_Required__c = false;
        amaAgg.Ex_US_Foreign_Affiliate_of_TPA_Vendor__c = false;
        amaAgg.Vendor_require_Remote_Access_from_NonUS__c = 'Yes';
        insert amaAgg;

        TPA_Request__c testRequest = [select id,(select id, Contract_Type__c,Is_Offshore_Access_Amendment_Required__c,Current_Year__c, TPA_Request__c from AMA_Agreement_Details__r) from TPA_Request__c where id = : testTpaRequest.id];
        SRV_TPA_AMAAgreementDetail.generateAmaAgreement(testRequest);
        SRV_TPA_AMAAgreementDetail.validateFunctionalRequirements(getJsonStringOfTPARequest());
    }



    private void runUnitTestsForCondition13() {
        system.debug('***In test method runUnitTestsForCondition13****');
        createContract('test Same Clent', 'test Vendor', 'Lettershop', 'DMD', False);

        AMA_Agreement_Detail__c amaAgg = UTL_TPA_SetupTestData.getAMAAgreementDetailBlank(testTpaRequest.Id);
        amaAgg.Contract_Type__c = 'Lettershop';
        amaAgg.Agreement_Start_Date__c = Date.newInstance(2016, 10, 20);
        amaAgg.Agreement_End_Date__c = Date.newInstance(2017, 12, 31);
        amaAgg.AMA_Howlong_SP_has_Data_Access__c = '90 days or less';
        amaAgg.FrequencyOfDeliveryToServiceProvider__c = 'Quarterly';
        amaAgg.AMA_TypeOfPrescriberLevelData__c = 'Birth Year;Gender Code';
        amaAgg.AMA_Services_Provided__c = 'Telemarketing;Labeling';
        insert amaAgg;

        SRV_TPA_AMAAgreementDetail.validateFunctionalRequirements(getJsonStringOfTPARequest());
    }

    private void runUnitTestsForCondition14() {
        system.debug('***In test method runUnitTestsForCondition14****');
        createContract('test Different Clent', 'test Vendor', 'Lettershop', 'DMD', False);

        AMA_Agreement_Detail__c amaAgg = UTL_TPA_SetupTestData.getAMAAgreementDetailBlank(testTpaRequest.Id);
        amaAgg.Agreement_Start_Date__c = Date.newInstance(2016, 10, 20);
        amaAgg.Agreement_End_Date__c = Date.newInstance(2017, 12, 31);
        amaAgg.AMA_Howlong_SP_has_Data_Access__c = '90 days or less';
        amaAgg.FrequencyOfDeliveryToServiceProvider__c = 'Quarterly';
        amaAgg.AMA_TypeOfPrescriberLevelData__c = 'Birth Year;Gender Code';
        amaAgg.AMA_Services_Provided__c = 'Telemarketing;Labeling';
        insert amaAgg;

        SRV_TPA_AMAAgreementDetail.validateFunctionalRequirements(getJsonStringOfTPARequest());
    }

    private void runUnitTestsForCondition15() {
        createContract('test Same Clent', 'test Vendor', 'Medical/Diagnostic Equipment & Supply', 'DMD', False);
        AMA_Agreement_Detail__c amaAgg = UTL_TPA_SetupTestData.getAMAAgreementDetailBlank(testTpaRequest.Id);
        amaAgg.Agreement_Start_Date__c = Date.newInstance(2016, 10, 20);
        amaAgg.Agreement_End_Date__c = Date.newInstance(2017, 12, 31);
        amaAgg.AMA_Howlong_SP_has_Data_Access__c = '90 days or less';
        amaAgg.FrequencyOfDeliveryToServiceProvider__c = 'Quarterly';
        amaAgg.AMA_TypeOfPrescriberLevelData__c = 'Birth Year;Gender Code';
        amaAgg.AMA_Services_Provided__c = 'Telemarketing;Labeling';
        insert amaAgg;

        SRV_TPA_AMAAgreementDetail.validateFunctionalRequirements(getJsonStringOfTPARequest());
    }

    private void runUnitTestsForCondition23() {
        createContract('test Same Clent', 'test Vendor', 'Lettershop', 'DMD', False);
        AMA_Agreement_Detail__c amaAgg = UTL_TPA_SetupTestData.getAMAAgreementDetailBlank(testTpaRequest.Id);
        amaAgg.Agreement_Start_Date__c = Date.newInstance(2016, 10, 20);
        amaAgg.Agreement_End_Date__c = Date.newInstance(2017, 12, 31);
        amaAgg.AMA_Howlong_SP_has_Data_Access__c = '90 days or less';
        amaAgg.FrequencyOfDeliveryToServiceProvider__c = 'Quarterly';
        amaAgg.AMA_TypeOfPrescriberLevelData__c = 'Birth Year;Gender Code';
        amaAgg.AMA_Services_Provided__c = 'Provide a supplemental sales force';
        insert amaAgg;

        SRV_TPA_AMAAgreementDetail.validateFunctionalRequirements(getJsonStringOfTPARequest());
    }

    private void runUnitTestsForCondition20() {
        //createContract('test Same Clent', 'test Vendor', 'Service Bureau I', 'DMD', False);
        AMA_Agreement_Detail__c amaAgg = UTL_TPA_SetupTestData.getAMAAgreementDetailBlank(testTpaRequest.Id);
        amaAgg.Agreement_Start_Date__c = Date.newInstance(2016, 10, 20);
        amaAgg.Agreement_End_Date__c = Date.newInstance(2017, 12, 31);
        amaAgg.AMA_Howlong_SP_has_Data_Access__c = '90 days or less';
        amaAgg.FrequencyOfDeliveryToServiceProvider__c = 'Quarterly';
        amaAgg.AMA_TypeOfPrescriberLevelData__c = 'Birth Year;Gender Code';
        amaAgg.AMA_Services_Provided__c = 'Provide a supplemental sales force';
        insert amaAgg;

        SRV_TPA_AMAAgreementDetail.validateFunctionalRequirements(getJsonStringOfTPARequest());
    }

    private void runUnitTestsForCondition22() {
        createContract('test Same Clent', 'test Vendor', 'Contract Sales Force', 'DMD', False);
        AMA_Agreement_Detail__c amaAgg = UTL_TPA_SetupTestData.getAMAAgreementDetailBlank(testTpaRequest.Id);
        amaAgg.Agreement_Start_Date__c = Date.newInstance(2016, 10, 20);
        amaAgg.Agreement_End_Date__c = Date.newInstance(2017, 12, 31);
        amaAgg.AMA_Howlong_SP_has_Data_Access__c = '90 days or less';
        amaAgg.FrequencyOfDeliveryToServiceProvider__c = 'Quarterly';
        amaAgg.AMA_TypeOfPrescriberLevelData__c = 'Birth Year;Gender Code';
        amaAgg.AMA_Services_Provided__c = 'Provide a supplemental sales force';
        insert amaAgg;

        SRV_TPA_AMAAgreementDetail.validateFunctionalRequirements(getJsonStringOfTPARequest());
    }

    private void runUnitTestsForCondition22WithDiffDBL() {
        createContract('test Same Clent', 'test Vendor', 'Contract Sales Force', 'DMD', False);
        createContract('test Same Clent', 'test Vendor', 'Contract Sales Force', 'IQVIA', False);
        createContract('test Same Clent', 'test Vendor', 'Contract Sales Force', 'SHA', False);
        AMA_Agreement_Detail__c amaAgg = UTL_TPA_SetupTestData.getAMAAgreementDetailBlank(testTpaRequest.Id);
        amaAgg.Agreement_Start_Date__c = Date.newInstance(2016, 10, 20);
        amaAgg.Agreement_End_Date__c = Date.newInstance(2017, 12, 31);
        amaAgg.AMA_Howlong_SP_has_Data_Access__c = '90 days or less';
        amaAgg.FrequencyOfDeliveryToServiceProvider__c = 'Quarterly';
        amaAgg.AMA_TypeOfPrescriberLevelData__c = 'Birth Year;Gender Code';
        amaAgg.AMA_Services_Provided__c = 'Provide a supplemental sales force';
        insert amaAgg;

        SRV_TPA_AMAAgreementDetail.validateFunctionalRequirements(getJsonStringOfTPARequest());
    }

    private void runUnitTestsForCondition21A() {
        createContract('test Different Clent', 'test Vendor', 'Contract Sales Force', 'DMD', False);
        AMA_Agreement_Detail__c amaAgg = UTL_TPA_SetupTestData.getAMAAgreementDetailBlank(testTpaRequest.Id);
        amaAgg.Agreement_Start_Date__c = Date.newInstance(2016, 10, 20);
        amaAgg.Agreement_End_Date__c = Date.newInstance(2017, 12, 31);
        amaAgg.AMA_Howlong_SP_has_Data_Access__c = '90 days or less';
        amaAgg.FrequencyOfDeliveryToServiceProvider__c = 'Quarterly';
        amaAgg.AMA_TypeOfPrescriberLevelData__c = 'Birth Year;Gender Code';
        amaAgg.AMA_Services_Provided__c = 'Provide a supplemental sales force';
        insert amaAgg;

        SRV_TPA_AMAAgreementDetail.validateFunctionalRequirements(getJsonStringOfTPARequest());
    }

    private void runUnitTestsForCondition21B() {
        createContract('test Different Clent', 'test Vendor', 'Contract Sales Force', 'IQVIA', False);
        AMA_Agreement_Detail__c amaAgg = UTL_TPA_SetupTestData.getAMAAgreementDetailBlank(testTpaRequest.Id);
        amaAgg.Agreement_Start_Date__c = Date.newInstance(2016, 10, 20);
        amaAgg.Agreement_End_Date__c = Date.newInstance(2017, 12, 31);
        amaAgg.AMA_Howlong_SP_has_Data_Access__c = '90 days or less';
        amaAgg.FrequencyOfDeliveryToServiceProvider__c = 'Quarterly';
        amaAgg.AMA_TypeOfPrescriberLevelData__c = 'Birth Year;Gender Code';
        amaAgg.AMA_Services_Provided__c = 'Provide a supplemental sales force';
        insert amaAgg;

        SRV_TPA_AMAAgreementDetail.validateFunctionalRequirements(getJsonStringOfTPARequest());
    }

    private void runUnitTestsForConditionServiceBureauI25() {
        createContract('test Same Clent', 'test Vendor', 'Service Bureau I', 'IQVIA', False);
        AMA_Agreement_Detail__c amaAgg = UTL_TPA_SetupTestData.getAMAAgreementDetailBlank(testTpaRequest.Id);
        amaAgg.Agreement_Start_Date__c = Date.newInstance(2016, 10, 20);
        amaAgg.Agreement_End_Date__c = Date.newInstance(2017, 12, 31);
        amaAgg.AMA_Howlong_SP_has_Data_Access__c = '90 days or less';
        amaAgg.FrequencyOfDeliveryToServiceProvider__c = 'Quarterly';
        amaAgg.AMA_TypeOfPrescriberLevelData__c = 'Birth Year;Gender Code';
        amaAgg.AMA_Services_Provided__c = 'Technical Support';
        insert amaAgg;

        SRV_TPA_AMAAgreementDetail.validateFunctionalRequirements(getJsonStringOfTPARequest());
    }

    private void runUnitTestsForConditionServiceBureauI26() {
        createContract('test Same Clent', 'test Vendor', 'Service Bureau II', 'IQVIA', False);
        AMA_Agreement_Detail__c amaAgg = UTL_TPA_SetupTestData.getAMAAgreementDetailBlank(testTpaRequest.Id);
        amaAgg.Agreement_Start_Date__c = Date.newInstance(2016, 10, 20);
        amaAgg.Agreement_End_Date__c = Date.newInstance(2017, 12, 31);
        amaAgg.AMA_Howlong_SP_has_Data_Access__c = '90 days or less';
        amaAgg.FrequencyOfDeliveryToServiceProvider__c = 'Quarterly';
        amaAgg.AMA_TypeOfPrescriberLevelData__c = 'Birth Year;Gender Code';
        amaAgg.AMA_Services_Provided__c='Technical Support';
        insert amaAgg;

        SRV_TPA_AMAAgreementDetail.validateFunctionalRequirements(getJsonStringOfTPARequest());
    }

    private void runUnitTestsForConditionServiceBureauI27() {
        AMA_Agreement_Detail__c amaAgg = UTL_TPA_SetupTestData.getAMAAgreementDetailBlank(testTpaRequest.Id);
        amaAgg.Agreement_Start_Date__c = Date.newInstance(2016, 10, 20);
        amaAgg.Agreement_End_Date__c = Date.newInstance(2017, 12, 31);
        amaAgg.AMA_Howlong_SP_has_Data_Access__c = '90 days or less';
        amaAgg.FrequencyOfDeliveryToServiceProvider__c = 'Quarterly';
        amaAgg.AMA_TypeOfPrescriberLevelData__c = 'Birth Year;Gender Code';
        amaAgg.AMA_Services_Provided__c = 'Technical Support';
        insert amaAgg;

        SRV_TPA_AMAAgreementDetail.validateFunctionalRequirements(getJsonStringOfTPARequest());
    }

    private void runUnitTestsForConditionServiceBureauII90daysOrLess30() {
        createContract('test Same Clent', 'test Vendor', 'Service Bureau II', 'IQVIA', False);
        AMA_Agreement_Detail__c amaAgg = UTL_TPA_SetupTestData.getAMAAgreementDetailBlank(testTpaRequest.Id);
        amaAgg.Agreement_Start_Date__c = Date.newInstance(2016, 10, 20);
        amaAgg.Agreement_End_Date__c = Date.newInstance(2017, 12, 31);
        amaAgg.AMA_Howlong_SP_has_Data_Access__c = '90 days or less';
        amaAgg.FrequencyOfDeliveryToServiceProvider__c = 'Annual';
        amaAgg.AMA_TypeOfPrescriberLevelData__c = 'Birth Year;Gender Code';
        amaAgg.AMA_Services_Provided__c = 'Territory Alignment';
        insert amaAgg;

        SRV_TPA_AMAAgreementDetail.validateFunctionalRequirements(getJsonStringOfTPARequest());
    }

    private void runUnitTestsForConditionServiceBureauII90daysOrLess30WithDiffDBL() {
        createContract('test Same Clent', 'test Vendor', 'Service Bureau II', 'IQVIA', False);
        createContract('test Same Clent', 'test Vendor', 'Service Bureau II', 'DMD', False);
        createContract('test Same Clent', 'test Vendor', 'Service Bureau II', 'SHA', False);
        AMA_Agreement_Detail__c amaAgg = UTL_TPA_SetupTestData.getAMAAgreementDetailBlank(testTpaRequest.Id);
        amaAgg.Agreement_Start_Date__c = Date.newInstance(2016, 10, 20);
        amaAgg.Agreement_End_Date__c = Date.newInstance(2017, 12, 31);
        amaAgg.AMA_Howlong_SP_has_Data_Access__c = '90 days or less';
        amaAgg.FrequencyOfDeliveryToServiceProvider__c = 'Annual';
        amaAgg.AMA_TypeOfPrescriberLevelData__c = 'Birth Year;Gender Code';
        amaAgg.AMA_Services_Provided__c = 'Territory Alignment';
        insert amaAgg;

        SRV_TPA_AMAAgreementDetail.validateFunctionalRequirements(getJsonStringOfTPARequest());
    }

    private void runUnitTestsForConditionServiceBureauII90daysOrLess31A() {
        createContract('test Different Clent', 'test Vendor', 'Service Bureau II', 'IQVIA', True);
        AMA_Agreement_Detail__c amaAgg = UTL_TPA_SetupTestData.getAMAAgreementDetailBlank(testTpaRequest.Id);
        amaAgg.Agreement_Start_Date__c = Date.newInstance(2016, 10, 20);
        amaAgg.Agreement_End_Date__c = Date.newInstance(2017, 12, 31);
        amaAgg.AMA_Howlong_SP_has_Data_Access__c = '90 days or less';
        amaAgg.FrequencyOfDeliveryToServiceProvider__c = 'Annual';
        amaAgg.AMA_TypeOfPrescriberLevelData__c = 'Birth Year;Gender Code';
        amaAgg.AMA_Services_Provided__c = 'Territory Alignment';
        insert amaAgg;

        SRV_TPA_AMAAgreementDetail.validateFunctionalRequirements(getJsonStringOfTPARequest());
    }

    private void runUnitTestsForConditionServiceBureauII90daysOrLess31WithNoExistingDiffDBL() {
        createContract('test Different Clent', 'test Vendor', 'Service Bureau II', 'JKC', True);
        AMA_Agreement_Detail__c amaAgg = UTL_TPA_SetupTestData.getAMAAgreementDetailBlank(testTpaRequest.Id);
        amaAgg.Agreement_Start_Date__c = Date.newInstance(2016, 10, 20);
        amaAgg.Agreement_End_Date__c = Date.newInstance(2017, 12, 31);
        amaAgg.AMA_Howlong_SP_has_Data_Access__c = '90 days or less';
        amaAgg.FrequencyOfDeliveryToServiceProvider__c = 'Annual';
        amaAgg.AMA_TypeOfPrescriberLevelData__c = 'Birth Year;Gender Code';
        amaAgg.AMA_Services_Provided__c = 'Territory Alignment';
        insert amaAgg;

        SRV_TPA_AMAAgreementDetail.validateFunctionalRequirements(getJsonStringOfTPARequest());
    }

    private void runUnitTestsForConditionServiceBureauII90daysOrLess31B() {
        createContract('test Different Clent', 'test Vendor', 'Service Bureau II', 'IQVIA', False);
        AMA_Agreement_Detail__c amaAgg = UTL_TPA_SetupTestData.getAMAAgreementDetailBlank(testTpaRequest.Id);
        amaAgg.Agreement_Start_Date__c = Date.newInstance(2016, 3, 20);
        amaAgg.Agreement_End_Date__c = Date.newInstance(2017, 12, 31);
        amaAgg.AMA_Howlong_SP_has_Data_Access__c = '90 days or less';
        amaAgg.FrequencyOfDeliveryToServiceProvider__c = 'Annual';
        amaAgg.AMA_TypeOfPrescriberLevelData__c = 'Birth Year;Gender Code';
        amaAgg.AMA_Services_Provided__c='Territory Alignment';
        insert amaAgg;

        SRV_TPA_AMAAgreementDetail.validateFunctionalRequirements(getJsonStringOfTPARequest());
    }

    private void runUnitTestsForConditionServiceBureauII90daysOrLess31C() {
        createContract('test Different Clent', 'test Vendor', 'Service Bureau II', 'DMD', True);
        AMA_Agreement_Detail__c amaAgg = UTL_TPA_SetupTestData.getAMAAgreementDetailBlank(testTpaRequest.Id);
        amaAgg.Agreement_Start_Date__c = Date.newInstance(2016, 10, 20);
        amaAgg.Agreement_End_Date__c = Date.newInstance(2017, 12, 31);
        amaAgg.AMA_Howlong_SP_has_Data_Access__c = '90 days or less';
        amaAgg.FrequencyOfDeliveryToServiceProvider__c = 'Annual';
        amaAgg.AMA_TypeOfPrescriberLevelData__c = 'Birth Year;Gender Code';
        amaAgg.AMA_Services_Provided__c = 'Territory Alignment';
        insert amaAgg;

        SRV_TPA_AMAAgreementDetail.validateFunctionalRequirements(getJsonStringOfTPARequest());
    }

    private void runUnitTestsForConditionServiceBureauII90daysOrLess31D() {
        createContract('test Different Clent', 'test Vendor', 'Service Bureau II', 'DMD', False);
        AMA_Agreement_Detail__c amaAgg = UTL_TPA_SetupTestData.getAMAAgreementDetailBlank(testTpaRequest.Id);
        amaAgg.Agreement_Start_Date__c = Date.newInstance(2016, 9, 1);
        amaAgg.Agreement_End_Date__c = Date.newInstance(2017, 12, 31);
        amaAgg.AMA_Howlong_SP_has_Data_Access__c = '90 days or less';
        amaAgg.FrequencyOfDeliveryToServiceProvider__c = 'Annual';
        amaAgg.AMA_TypeOfPrescriberLevelData__c = 'Birth Year;Gender Code';
        amaAgg.AMA_Services_Provided__c = 'Territory Alignment';
        insert amaAgg;

        SRV_TPA_AMAAgreementDetail.validateFunctionalRequirements(getJsonStringOfTPARequest());
    }

    private void runUnitTestsForConditionServiceBureauII90daysOrLess32() {
        createContract('test Same Clent', 'test Vendor', 'Service Bureau I', 'DMD', False);
        AMA_Agreement_Detail__c amaAgg = UTL_TPA_SetupTestData.getAMAAgreementDetailBlank(testTpaRequest.Id);
        amaAgg.Agreement_Start_Date__c = Date.newInstance(2016, 10, 20);
        amaAgg.Agreement_End_Date__c = Date.newInstance(2017, 12, 31);
        amaAgg.AMA_Howlong_SP_has_Data_Access__c = '90 days or less';
        amaAgg.FrequencyOfDeliveryToServiceProvider__c = 'Annual';
        amaAgg.AMA_TypeOfPrescriberLevelData__c = 'Birth Year;Gender Code';
        amaAgg.AMA_Services_Provided__c = 'Territory Alignment';
        insert amaAgg;

        SRV_TPA_AMAAgreementDetail.validateFunctionalRequirements(getJsonStringOfTPARequest());
    }

    private void runUnitTestsForConditionServiceBureauIIDueToUse34() {
        createContract('test Same Clent', 'test Vendor', 'Service Bureau II', 'DMD', False);
        AMA_Agreement_Detail__c amaAgg = UTL_TPA_SetupTestData.getAMAAgreementDetailBlank(testTpaRequest.Id);
        amaAgg.Agreement_Start_Date__c = Date.newInstance(2016, 10, 20);
        amaAgg.Agreement_End_Date__c = Date.newInstance(2017, 12, 31);
        amaAgg.AMA_Howlong_SP_has_Data_Access__c = '90 days or less';
        amaAgg.FrequencyOfDeliveryToServiceProvider__c = 'Annual';
        amaAgg.AMA_TypeOfPrescriberLevelData__c = 'Birth Year;Gender Code';
        amaAgg.AMA_Services_Provided__c = 'Salesforce Automation';
        insert amaAgg;

        SRV_TPA_AMAAgreementDetail.validateFunctionalRequirements(getJsonStringOfTPARequest());
    }

    private void runUnitTestsForConditionServiceBureauIIDueToUse34WithMultipleDBL() {
        createContract('test Same Clent', 'test Vendor', 'Service Bureau II', 'IQVIA', False);
        createContract('test Same Clent', 'test Vendor', 'Service Bureau II', 'DMD', False);
        createContract('test Same Clent', 'test Vendor', 'Service Bureau II', 'SHA', False);
        AMA_Agreement_Detail__c amaAgg = UTL_TPA_SetupTestData.getAMAAgreementDetailBlank(testTpaRequest.Id);
        amaAgg.Agreement_Start_Date__c = Date.newInstance(2016, 10, 20);
        amaAgg.Agreement_End_Date__c = Date.newInstance(2017, 12, 31);
        amaAgg.AMA_Howlong_SP_has_Data_Access__c = '90 days or less';
        amaAgg.FrequencyOfDeliveryToServiceProvider__c = 'Annual';
        amaAgg.AMA_TypeOfPrescriberLevelData__c = 'Birth Year;Gender Code';
        amaAgg.AMA_Services_Provided__c = 'Salesforce Automation';
        insert amaAgg;

        SRV_TPA_AMAAgreementDetail.validateFunctionalRequirements(getJsonStringOfTPARequest());
    }

    private void runUnitTestsForConditionServiceBureauIIDueToUse35A() {
        createContract('test Different Clentt', 'test Vendor', 'Service Bureau II', 'IQVIA', True);
        AMA_Agreement_Detail__c amaAgg = UTL_TPA_SetupTestData.getAMAAgreementDetailBlank(testTpaRequest.Id);
        amaAgg.Agreement_Start_Date__c = Date.newInstance(2016, 10, 20);
        amaAgg.Agreement_End_Date__c = Date.newInstance(2017, 12, 31);
        amaAgg.AMA_Howlong_SP_has_Data_Access__c = '90 days or less';
        amaAgg.FrequencyOfDeliveryToServiceProvider__c = 'Annual';
        amaAgg.AMA_TypeOfPrescriberLevelData__c = 'Birth Year;Gender Code';
        amaAgg.AMA_Services_Provided__c = 'Salesforce Automation';
        insert amaAgg;

        SRV_TPA_AMAAgreementDetail.validateFunctionalRequirements(getJsonStringOfTPARequest());
    }

    private void runUnitTestsForConditionServiceBureauIIDueToUse35B() {
        createContract('test Different Clent', 'test Vendor', 'Service Bureau II', 'IQVIA', False);
        AMA_Agreement_Detail__c amaAgg = UTL_TPA_SetupTestData.getAMAAgreementDetailBlank(testTpaRequest.Id);
        amaAgg.Agreement_Start_Date__c = Date.newInstance(2016, 12, 19);
        amaAgg.Agreement_End_Date__c = Date.newInstance(2017, 12, 31);
        amaAgg.AMA_Howlong_SP_has_Data_Access__c = '90 days or less';
        amaAgg.FrequencyOfDeliveryToServiceProvider__c = 'Annual';
        amaAgg.AMA_TypeOfPrescriberLevelData__c = 'Birth Year;Gender Code';
        amaAgg.AMA_Services_Provided__c = 'Salesforce Automation';
        insert amaAgg;

        SRV_TPA_AMAAgreementDetail.validateFunctionalRequirements(getJsonStringOfTPARequest());
    }

    private void runUnitTestsForConditionServiceBureauIIDueToUse35C() {
        createContract('test Different Clent', 'test Vendor', 'Service Bureau II', 'DMD', True);
        AMA_Agreement_Detail__c amaAgg = UTL_TPA_SetupTestData.getAMAAgreementDetailBlank(testTpaRequest.Id);
        amaAgg.Agreement_Start_Date__c = Date.newInstance(2016, 10, 20);
        amaAgg.Agreement_End_Date__c = Date.newInstance(2017, 12, 31);
        amaAgg.AMA_Howlong_SP_has_Data_Access__c = '90 days or less';
        amaAgg.FrequencyOfDeliveryToServiceProvider__c = 'Annual';
        amaAgg.AMA_TypeOfPrescriberLevelData__c = 'Birth Year;Gender Code';
        amaAgg.AMA_Services_Provided__c = 'Salesforce Automation';
        insert amaAgg;

        SRV_TPA_AMAAgreementDetail.validateFunctionalRequirements(getJsonStringOfTPARequest());
    }

    private void runUnitTestsForConditionServiceBureauIIDueToUse35D() {
        createContract('test Different Clent', 'test Vendor', 'Service Bureau II', 'DMD', False);
        AMA_Agreement_Detail__c amaAgg = UTL_TPA_SetupTestData.getAMAAgreementDetailBlank(testTpaRequest.Id);
        amaAgg.Agreement_Start_Date__c = Date.newInstance(2016, 10, 20);
        amaAgg.Agreement_End_Date__c = Date.newInstance(2017, 12, 31);
        amaAgg.AMA_Howlong_SP_has_Data_Access__c = '90 days or less';
        amaAgg.FrequencyOfDeliveryToServiceProvider__c = 'Annual';
        amaAgg.AMA_TypeOfPrescriberLevelData__c = 'Birth Year;Gender Code';
        amaAgg.AMA_Services_Provided__c = 'Salesforce Automation';
        insert amaAgg;

        SRV_TPA_AMAAgreementDetail.validateFunctionalRequirements(getJsonStringOfTPARequest());
    }

    private void runUnitTestsForConditionServiceBureauIIDueToUse36() {
        createContract('test Same Clent', 'test Vendor', 'Service Bureau I', 'DMD', False);
        AMA_Agreement_Detail__c amaAgg = UTL_TPA_SetupTestData.getAMAAgreementDetailBlank(testTpaRequest.Id);
        amaAgg.Agreement_Start_Date__c = Date.newInstance(2016, 10, 20);
        amaAgg.Agreement_End_Date__c = Date.newInstance(2017, 12, 31);
        amaAgg.AMA_Howlong_SP_has_Data_Access__c = '90 days or less';
        amaAgg.FrequencyOfDeliveryToServiceProvider__c = 'Annual';
        amaAgg.AMA_TypeOfPrescriberLevelData__c = 'Birth Year;Gender Code';
        amaAgg.AMA_Services_Provided__c = 'Salesforce Automation';
        insert amaAgg;

        SRV_TPA_AMAAgreementDetail.validateFunctionalRequirements(getJsonStringOfTPARequest());
    }

    private void runUnitTestsForConditionServiceBureauIIDueToUse33() {
        AMA_Agreement_Detail__c amaAgg = UTL_TPA_SetupTestData.getAMAAgreementDetailBlank(testTpaRequest.Id);
        amaAgg.Agreement_Start_Date__c = Date.newInstance(2016, 10, 20);
        amaAgg.Agreement_End_Date__c = Date.newInstance(2017, 12, 31);
        amaAgg.AMA_Howlong_SP_has_Data_Access__c = '90 days or less';
        amaAgg.FrequencyOfDeliveryToServiceProvider__c = 'Annual';
        amaAgg.AMA_TypeOfPrescriberLevelData__c = 'Birth Year;Gender Code';
        amaAgg.AMA_Services_Provided__c = 'Salesforce Automation';
        insert amaAgg;

        SRV_TPA_AMAAgreementDetail.validateFunctionalRequirements(getJsonStringOfTPARequest());
    }

    private void runUnitTestsForConditionServiceBureauIIGreaterThan90Days37() {
        createContract('test Same Clent', 'test Vendor', 'Service Bureau II', 'DMD', False);
        AMA_Agreement_Detail__c amaAgg = UTL_TPA_SetupTestData.getAMAAgreementDetailBlank(testTpaRequest.Id);
        amaAgg.Agreement_Start_Date__c = Date.newInstance(2016, 10, 20);
        amaAgg.Agreement_End_Date__c = Date.newInstance(2017, 12, 31);
        amaAgg.AMA_Howlong_SP_has_Data_Access__c = 'Greater than 90 days';
        amaAgg.FrequencyOfDeliveryToServiceProvider__c = 'Annual';
        amaAgg.AMA_TypeOfPrescriberLevelData__c = 'Birth Year;Gender Code';
        amaAgg.AMA_Services_Provided__c = 'Prescriber Recruitment';
        insert amaAgg;

        SRV_TPA_AMAAgreementDetail.validateFunctionalRequirements(getJsonStringOfTPARequest());
    }

    private void runUnitTestsForConditionServiceBureauIIGreaterThan90Days37WithMultipleDBL() {
        createContract('test Same Clent', 'test Vendor', 'Service Bureau II', 'IQVIA', False);
        createContract('test Same Clent', 'test Vendor', 'Service Bureau II', 'DMD', False);
        createContract('test Same Clent', 'test Vendor', 'Service Bureau II', 'SHA', False);
        AMA_Agreement_Detail__c amaAgg = UTL_TPA_SetupTestData.getAMAAgreementDetailBlank(testTpaRequest.Id);
        amaAgg.Agreement_Start_Date__c = Date.newInstance(2016, 10, 20);
        amaAgg.Agreement_End_Date__c = Date.newInstance(2017, 12, 31);
        amaAgg.AMA_Howlong_SP_has_Data_Access__c = 'Greater than 90 days';
        amaAgg.FrequencyOfDeliveryToServiceProvider__c = 'Annual';
        amaAgg.AMA_TypeOfPrescriberLevelData__c = 'Birth Year;Gender Code';
        amaAgg.AMA_Services_Provided__c = 'Prescriber Recruitment';
        insert amaAgg;

        SRV_TPA_AMAAgreementDetail.validateFunctionalRequirements(getJsonStringOfTPARequest());
    }

    private void runUnitTestsForConditionServiceBureauIIGreaterThan90Days39A() {
        createContract('test Different Clent', 'test Vendor', 'Service Bureau II', 'IQVIA', True);
        AMA_Agreement_Detail__c amaAgg = UTL_TPA_SetupTestData.getAMAAgreementDetailBlank(testTpaRequest.Id);
        amaAgg.Agreement_Start_Date__c = Date.newInstance(2016, 10, 20);
        amaAgg.Agreement_End_Date__c = Date.newInstance(2017, 12, 31);
        amaAgg.AMA_Howlong_SP_has_Data_Access__c = 'Greater than 90 days';
        amaAgg.FrequencyOfDeliveryToServiceProvider__c = 'Annual';
        amaAgg.AMA_TypeOfPrescriberLevelData__c = 'Birth Year;Gender Code';
        amaAgg.AMA_Services_Provided__c = 'Prescriber Recruitment';
        insert amaAgg;

        SRV_TPA_AMAAgreementDetail.validateFunctionalRequirements(getJsonStringOfTPARequest());
    }

    private void runUnitTestsForConditionServiceBureauIIGreaterThan90Days39B() {
        createContract('test Different Clent', 'test Vendor', 'Service Bureau II', 'IQVIA', False);
        AMA_Agreement_Detail__c amaAgg = UTL_TPA_SetupTestData.getAMAAgreementDetailBlank(testTpaRequest.Id);
        amaAgg.Agreement_Start_Date__c = Date.newInstance(2016, 10, 20);
        amaAgg.Agreement_End_Date__c = Date.newInstance(2017, 12, 31);
        amaAgg.AMA_Howlong_SP_has_Data_Access__c = 'Greater than 90 days';
        amaAgg.FrequencyOfDeliveryToServiceProvider__c = 'Annual';
        amaAgg.AMA_TypeOfPrescriberLevelData__c = 'Birth Year;Gender Code';
        amaAgg.AMA_Services_Provided__c = 'Prescriber Recruitment';
        insert amaAgg;

        SRV_TPA_AMAAgreementDetail.validateFunctionalRequirements(getJsonStringOfTPARequest());
    }

    private void runUnitTestsForConditionServiceBureauIIGreaterThan90Days39C() {
        createContract('test Different Clent', 'test Vendor', 'Service Bureau II', 'DMD', True);
        AMA_Agreement_Detail__c amaAgg = UTL_TPA_SetupTestData.getAMAAgreementDetailBlank(testTpaRequest.Id);
        amaAgg.Agreement_Start_Date__c = Date.newInstance(2016, 10, 20);
        amaAgg.Agreement_End_Date__c = Date.newInstance(2017, 12, 31);
        amaAgg.AMA_Howlong_SP_has_Data_Access__c = 'Greater than 90 days';
        amaAgg.FrequencyOfDeliveryToServiceProvider__c = 'Annual';
        amaAgg.AMA_TypeOfPrescriberLevelData__c = 'Birth Year;Gender Code';
        amaAgg.AMA_Services_Provided__c = 'Prescriber Recruitment';
        insert amaAgg;

        SRV_TPA_AMAAgreementDetail.validateFunctionalRequirements(getJsonStringOfTPARequest());
    }

    private void runUnitTestsForConditionServiceBureauIIGreaterThan90Days39D() {
        createContract('test Different Clent', 'test Vendor', 'Service Bureau II', 'DMD', False);
        AMA_Agreement_Detail__c amaAgg = UTL_TPA_SetupTestData.getAMAAgreementDetailBlank(testTpaRequest.Id);
        amaAgg.Agreement_Start_Date__c = Date.newInstance(2016, 10, 20);
        amaAgg.Agreement_End_Date__c = Date.newInstance(2017, 12, 31);
        amaAgg.AMA_Howlong_SP_has_Data_Access__c = 'Greater than 90 days';
        amaAgg.FrequencyOfDeliveryToServiceProvider__c = 'Annual';
        amaAgg.AMA_TypeOfPrescriberLevelData__c = 'Birth Year;Gender Code';
        amaAgg.AMA_Services_Provided__c = 'Prescriber Recruitment';
        insert amaAgg;

        SRV_TPA_AMAAgreementDetail.validateFunctionalRequirements(getJsonStringOfTPARequest());
    }

    private void runUnitTestsForConditionServiceBureauIIGreaterThan90Days40() {
        createContract('test Same Clent', 'test Vendor', 'Lettershop', 'DMD', False);
        AMA_Agreement_Detail__c amaAgg = UTL_TPA_SetupTestData.getAMAAgreementDetailBlank(testTpaRequest.Id);
        amaAgg.Agreement_Start_Date__c = Date.newInstance(2016, 10, 20);
        amaAgg.Agreement_End_Date__c = Date.newInstance(2017, 12, 31);
        amaAgg.AMA_Howlong_SP_has_Data_Access__c = 'Greater than 90 days';
        amaAgg.FrequencyOfDeliveryToServiceProvider__c = 'Annual';
        amaAgg.AMA_TypeOfPrescriberLevelData__c = 'Birth Year;Gender Code';
        amaAgg.AMA_Services_Provided__c = 'Prescriber Recruitment';
        insert amaAgg;

        SRV_TPA_AMAAgreementDetail.validateFunctionalRequirements(getJsonStringOfTPARequest());
        List<AMA_Fee_Master__c> feeRules = [Select id, Contract_Type__c,Fee__c, Fee_Calculated__c, Proration_Rules_Applied__c, Template__r.Name, Vendor_has_Licence__c, Year__c
                                            FROM AMA_Fee_Master__c];
        System.debug('**feeRules phle**'+feeRules);
        feeRules = [Select id, Contract_Type__c, Fee__c, Fee_Calculated__c, Proration_Rules_Applied__c, Template__r.Name, Vendor_has_Licence__c, Year__c
                    FROM AMA_Fee_Master__c
                    Where Contract_Type__c = 'Service Bureau II' AND Vendor_has_Licence__c = 'has no existing Licence with AMA' AND Year__c = '2016'];
        System.debug('**feeRules size**' + feeRules.size());
        System.debug('**feeRules**' + feeRules);
    }

    private void runUnitTestsForConditionServiceBureauIIGreaterThan90Days41() {
        createContract('test Same Clent', 'test Vendor', 'Service Bureau I', 'DMD', False);
        AMA_Agreement_Detail__c amaAgg = UTL_TPA_SetupTestData.getAMAAgreementDetailBlank(testTpaRequest.Id);
        amaAgg.Agreement_Start_Date__c = Date.newInstance(2016, 10, 20);
        amaAgg.Agreement_End_Date__c = Date.newInstance(2017, 12, 31);
        amaAgg.AMA_Howlong_SP_has_Data_Access__c = 'Greater than 90 days';
        amaAgg.FrequencyOfDeliveryToServiceProvider__c = 'Annual';
        amaAgg.AMA_TypeOfPrescriberLevelData__c = 'Birth Year;Gender Code';
        amaAgg.AMA_Services_Provided__c = 'Prescriber Recruitment';
        insert amaAgg;

        SRV_TPA_AMAAgreementDetail.validateFunctionalRequirements(getJsonStringOfTPARequest());
    }

    private void runUnitTestsForConditionServiceBureauIIGreaterThan90Days41With8B() {
        createContract('test Same Clent', 'test Vendor', 'Contract Sales Force', 'DMD', False);
        AMA_Agreement_Detail__c amaAgg = UTL_TPA_SetupTestData.getAMAAgreementDetailBlank(testTpaRequest.Id);
        amaAgg.Agreement_Start_Date__c = Date.newInstance(2016, 10, 20);
        amaAgg.Agreement_End_Date__c = Date.newInstance(2017, 12, 31);
        amaAgg.Ex_Contract_End_Date__c = Date.newInstance(2015, 12, 31);
        amaAgg.AMA_Howlong_SP_has_Data_Access__c = 'Greater than 90 days';
        amaAgg.FrequencyOfDeliveryToServiceProvider__c = 'Annual';
        amaAgg.AMA_TypeOfPrescriberLevelData__c = 'Birth Year;Gender Code';
        amaAgg.AMA_Services_Provided__c = 'Prescriber Recruitment';
        insert amaAgg;

        SRV_TPA_AMAAgreementDetail.validateFunctionalRequirements(getJsonStringOfTPARequest());
    }

    private void runUnitTestsForCondition42() {
        createContract('test Same Clent', 'test Vendor', 'Service Bureau I', 'DMD', False);
        AMA_Agreement_Detail__c amaAgg = UTL_TPA_SetupTestData.getAMAAgreementDetailBlank(testTpaRequest.Id);
        amaAgg.Contract_Type__c = 'Service Bureau II';
        amaAgg.Agreement_Start_Date__c = Date.newInstance(2016, 10, 20);
        amaAgg.Agreement_End_Date__c = Date.newInstance(2017, 12, 31);
        amaAgg.AMA_Howlong_SP_has_Data_Access__c = 'Greater than 90 days';
        amaAgg.FrequencyOfDeliveryToServiceProvider__c = 'Annual';
        amaAgg.AMA_TypeOfPrescriberLevelData__c = 'Birth Year;Gender Code';
        amaAgg.AMA_Services_Provided__c = 'Prescriber Recruitment;Telemarketing';
        insert amaAgg;

        SRV_TPA_AMAAgreementDetail.validateFunctionalRequirements(getJsonStringOfTPARequest());
    }

    private void runUnitTestsForConditionServiceBureauIIGreaterThan90Days38() {
        // createContract('test Different Clent', 'test Vendor', 'Service Bureau II', 'DMD', False);
        AMA_Agreement_Detail__c amaAgg = UTL_TPA_SetupTestData.getAMAAgreementDetailBlank(testTpaRequest.Id);
        amaAgg.Agreement_Start_Date__c = Date.newInstance(2016, 10, 20);
        amaAgg.Agreement_End_Date__c = Date.newInstance(2017, 12, 31);
        amaAgg.AMA_Howlong_SP_has_Data_Access__c = 'Greater than 90 days';
        amaAgg.FrequencyOfDeliveryToServiceProvider__c = 'Annual';
        amaAgg.AMA_TypeOfPrescriberLevelData__c = 'Birth Year;Gender Code';
        amaAgg.AMA_Services_Provided__c = 'Prescriber Recruitment';
        insert amaAgg;

        SRV_TPA_AMAAgreementDetail.validateFunctionalRequirements(getJsonStringOfTPARequest());
    }

    private void runUnitTestsForConditionServiceBureauIIGreaterThan90Days37With8B() {
        AMA_Contract_Detail__c amaContract1 = new AMA_Contract_Detail__c(Client__c = 'test Vendor', Client_Services_On_Behalf_Of__c = 'test Same Clent'
                                                                        ,Contract_End_Date__c = Date.newInstance(2015, 10, 20), Contract_List_Type__c = 'Client', Contract_Type__c = 'Service Bureau II', DBL__c = 'DMD', Max_Fee_Reached__c = False, Offshore_Approval__c = false);

        insert amaContract1;
        AMA_Agreement_Detail__c amaAgg = UTL_TPA_SetupTestData.getAMAAgreementDetailBlank(testTpaRequest.Id);
        amaAgg.Agreement_Start_Date__c = Date.newInstance(2016, 10, 20);
        amaAgg.Agreement_End_Date__c = Date.newInstance(2017, 12, 31);
        amaAgg.AMA_Howlong_SP_has_Data_Access__c = 'Greater than 90 days';
        amaAgg.FrequencyOfDeliveryToServiceProvider__c = 'Annual';
        amaAgg.AMA_TypeOfPrescriberLevelData__c = 'Birth Year;Gender Code';
        amaAgg.AMA_Services_Provided__c = 'Prescriber Recruitment';
        insert amaAgg;

        SRV_TPA_AMAAgreementDetail.validateFunctionalRequirements(getJsonStringOfTPARequest());
    }

    private void runUnitTestsForCondition12With4() {
        TPA_Country_Codes__c tpaCountryCode = new TPA_Country_Codes__c();
        tpaCountryCode.Name = 'USA';
        tpaCountryCode.Country_Possible_Codes__c ='US; U.S.; USA; United States';
        tpaCountryCode.Code_Type__c = 'C';
        insert tpaCountryCode;
        createClientVendorAccount();
        //   create contract of the client with itself
        createContract('test Same Clent', 'test Same Clent', 'Biotech Firm', 'DMD', False);

        // Create test Tpa Request
        testTpaRequest = UTL_TPA_SetupTestData.getTPARequestBlank(false);
        testTpaRequest.OwnerId = UserInfo.getUserId();
        testTpaRequest.AMA_USPrescriberData__c = 'Yes';
        testTpaRequest.Service_Provider_Address__c = testVendorAccount.Id;
        testTpaRequest.Client_Address__c = testSameClentAccount.Id;
        testTpaRequest.Vendor_Company_Name__c = 'Test company';
        testTpaRequest.data_access_start_date__c = Date.newInstance(2016, 10, 20);
        testTpaRequest.data_access_end_date__c = Date.newInstance(2017, 8, 20);
        testTpaRequest.Employee_Accessing_Data_Location__c = 'India';
        testTpaRequest.Vendor_Billing_Mailing_Country__c = 'India';
        insert testTpaRequest;
        system.assert(testTpaRequest.Id != null);

        AMA_Agreement_Detail__c amaAgg = UTL_TPA_SetupTestData.getAMAAgreementDetailBlank(testTpaRequest.Id);
        amaAgg.Agreement_Start_Date__c = Date.newInstance(2016, 10, 20);
        amaAgg.Agreement_End_Date__c = Date.newInstance(2017, 12, 31);
        amaAgg.AMA_Howlong_SP_has_Data_Access__c = '90 days or less';
        amaAgg.FrequencyOfDeliveryToServiceProvider__c = 'Quarterly';
        amaAgg.AMA_TypeOfPrescriberLevelData__c = 'Birth Year;Gender Code';
        amaAgg.AMA_Services_Provided__c = 'Telemarketing;Labeling';
        insert amaAgg;

        SRV_TPA_AMAAgreementDetail.validateFunctionalRequirements(getJsonStringOfTPARequest());
    }

    private void runUnitTestsForCondition12WithInvalidClient() {
        // createClientVendorAccount();
        UTL_TPA_SetupTestData.createTPASettingData();

        Address__c testNewClientAccount = UTL_TPA_SetupTestData.getBlankAccount();
        testNewClientAccount.Name = 'test New Client';
        testNewClientAccount.is_TPA_Account__c = true;
        testNewClientAccount.Street__c = 'test';
        testNewClientAccount.City__c = 'test';
        testNewClientAccount.Country__c = 'test';
        testNewClientAccount.PostalCode__c = 'test';
        insert testNewClientAccount;

        // Create test Tpa Request
        testTpaRequest = UTL_TPA_SetupTestData.getTPARequestBlank(false);
        testTpaRequest.OwnerId = UserInfo.getUserId();
        testTpaRequest.AMA_USPrescriberData__c = 'Yes';
        testTpaRequest.Service_Provider_Address__c = testNewClientAccount.Id;
        testTpaRequest.Client_Address__c = testNewClientAccount.Id;
        testTpaRequest.Vendor_Company_Name__c = 'Test company';
        testTpaRequest.data_access_start_date__c = Date.newInstance(2016, 10, 20);
        testTpaRequest.data_access_end_date__c = Date.newInstance(2017, 8, 20);
        testTpaRequest.IMS_Data_Country_Location__c = 'United States';
        testTpaRequest.Employee_Accessing_Data_Location__c = 'United States';
        insert testTpaRequest;
        system.assert(testTpaRequest.Id != null);

        AMA_Agreement_Detail__c amaAgg = UTL_TPA_SetupTestData.getAMAAgreementDetailBlank(testTpaRequest.Id);
        amaAgg.Agreement_Start_Date__c = Date.newInstance(2016, 10, 20);
        amaAgg.Agreement_End_Date__c = Date.newInstance(2017, 12, 31);
        amaAgg.AMA_Howlong_SP_has_Data_Access__c = '90 days or less';
        amaAgg.FrequencyOfDeliveryToServiceProvider__c = 'Quarterly';
        amaAgg.AMA_TypeOfPrescriberLevelData__c = 'Birth Year;Gender Code';
        amaAgg.AMA_Services_Provided__c = 'Telemarketing;Labeling';
        insert amaAgg;

        SRV_TPA_AMAAgreementDetail.validateFunctionalRequirements(getJsonStringOfTPARequest());
    }

    private void runUnitTestsForConditionLettershopAndSBICondition44() {
        createContract('test Same Clent', 'test Vendor', 'Service Bureau I', 'DMD', False);
        AMA_Agreement_Detail__c amaAgg = UTL_TPA_SetupTestData.getAMAAgreementDetailBlank(testTpaRequest.Id);
        amaAgg.Agreement_Start_Date__c = Date.newInstance(2016, 10, 20);
        amaAgg.Agreement_End_Date__c = Date.newInstance(2017, 12, 31);
        amaAgg.AMA_Howlong_SP_has_Data_Access__c = '90 days or less';
        amaAgg.FrequencyOfDeliveryToServiceProvider__c = 'Quarterly';
        amaAgg.AMA_TypeOfPrescriberLevelData__c = 'Birth Year;Gender Code';
        amaAgg.AMA_Services_Provided__c = 'Prescriber Recruitment;Territory Alignment';
        insert amaAgg;

        SRV_TPA_AMAAgreementDetail.validateFunctionalRequirements(getJsonStringOfTPARequest());
    }

    private void runUnitTestsForConditionLettershopAndSBICondition46() {
        createContract('test Different Clent', 'test Vendor', 'Service Bureau II', 'IQVIA', True);
        AMA_Agreement_Detail__c amaAgg = UTL_TPA_SetupTestData.getAMAAgreementDetailBlank(testTpaRequest.Id);
        amaAgg.Agreement_Start_Date__c = Date.newInstance(2016, 10, 20);
        amaAgg.Agreement_End_Date__c = Date.newInstance(2017, 12, 31);
        amaAgg.AMA_Howlong_SP_has_Data_Access__c = '90 days or less';
        amaAgg.FrequencyOfDeliveryToServiceProvider__c = 'Annual';
        amaAgg.AMA_TypeOfPrescriberLevelData__c = 'Birth Year;Gender Code';
        amaAgg.AMA_Services_Provided__c = 'Prescriber Recruitment;Territory Alignment';
        insert amaAgg;

        SRV_TPA_AMAAgreementDetail.validateFunctionalRequirements(getJsonStringOfTPARequest());
    }

    private void runUnitTestsForConditionLettershopAndSBICondition47() {
        createContract('test Same Clent', 'test Vendor', 'Service Bureau II', 'IQVIA', True);
        AMA_Agreement_Detail__c amaAgg = UTL_TPA_SetupTestData.getAMAAgreementDetailBlank(testTpaRequest.Id);
        amaAgg.Agreement_Start_Date__c = Date.newInstance(2016, 10, 20);
        amaAgg.Agreement_End_Date__c = Date.newInstance(2017, 12, 31);
        amaAgg.AMA_Howlong_SP_has_Data_Access__c = '90 days or less';
        amaAgg.FrequencyOfDeliveryToServiceProvider__c = 'Quarterly';
        amaAgg.AMA_TypeOfPrescriberLevelData__c = 'Birth Year;Gender Code';
        amaAgg.AMA_Services_Provided__c = 'Prescriber Recruitment;Territory Alignment';
        insert amaAgg;

        SRV_TPA_AMAAgreementDetail.validateFunctionalRequirements(getJsonStringOfTPARequest());
    }

    private void runUnitTestsForConditionLettershopAndSBICondition48() {
        createContract('test Same Clent', 'test Vendor', 'Service Bureau II', 'IQVIA', false);
        AMA_Agreement_Detail__c amaAgg = UTL_TPA_SetupTestData.getAMAAgreementDetailBlank(testTpaRequest.Id);
        amaAgg.Agreement_Start_Date__c = Date.newInstance(2016, 10, 20);
        amaAgg.Agreement_End_Date__c = Date.newInstance(2017, 12, 31);
        amaAgg.AMA_Howlong_SP_has_Data_Access__c = '90 days or less';
        amaAgg.FrequencyOfDeliveryToServiceProvider__c = 'Annual';
        amaAgg.AMA_TypeOfPrescriberLevelData__c = 'Birth Year;Gender Code';
        amaAgg.AMA_Services_Provided__c = 'Prescriber Recruitment;Territory Alignment';
        insert amaAgg;

        SRV_TPA_AMAAgreementDetail.validateFunctionalRequirements(getJsonStringOfTPARequest());
    }

    private void runUnitTestsForConditionLettershopAndSBICondition49() {
        AMA_Agreement_Detail__c amaAgg = UTL_TPA_SetupTestData.getAMAAgreementDetailBlank(testTpaRequest.Id);
        amaAgg.Agreement_Start_Date__c = Date.newInstance(2016, 10, 20);
        amaAgg.Agreement_End_Date__c = Date.newInstance(2017, 12, 31);
        amaAgg.AMA_Howlong_SP_has_Data_Access__c = '90 days or less';
        amaAgg.FrequencyOfDeliveryToServiceProvider__c = 'Quarterly';
        amaAgg.AMA_TypeOfPrescriberLevelData__c = 'Birth Year;Gender Code';
        amaAgg.AMA_Services_Provided__c = 'Prescriber Recruitment;Territory Alignment';
        insert amaAgg;

        SRV_TPA_AMAAgreementDetail.validateFunctionalRequirements(getJsonStringOfTPARequest());
    }

    private void runUnitTestsForConditionLettershopAndSBICondition50() {
        AMA_Agreement_Detail__c amaAgg = UTL_TPA_SetupTestData.getAMAAgreementDetailBlank(testTpaRequest.Id);
        amaAgg.Agreement_Start_Date__c = Date.newInstance(2016, 10, 20);
        amaAgg.Agreement_End_Date__c = Date.newInstance(2017, 12, 31);
        amaAgg.AMA_Howlong_SP_has_Data_Access__c = '90 days or less';
        amaAgg.FrequencyOfDeliveryToServiceProvider__c = 'Annual';
        amaAgg.AMA_TypeOfPrescriberLevelData__c = 'Birth Year;Gender Code';
        amaAgg.AMA_Services_Provided__c = 'Prescriber Recruitment;Territory Alignment';
        insert amaAgg;

        SRV_TPA_AMAAgreementDetail.validateFunctionalRequirements(getJsonStringOfTPARequest());
    }

    private void runUnitTestsForConditionforSpecialUseandContractType() {
        createContract('test Vendor', 'test Vendor', 'Healthcare Provider', 'IQVIA', false);
        AMA_Agreement_Detail__c amaAgg = UTL_TPA_SetupTestData.getAMAAgreementDetailBlank(testTpaRequest.Id);
        amaAgg.Agreement_Start_Date__c = Date.newInstance(2016, 10, 20);
        amaAgg.Agreement_End_Date__c = Date.newInstance(2017, 12, 31);
        amaAgg.AMA_Howlong_SP_has_Data_Access__c = '90 days or less';
        amaAgg.FrequencyOfDeliveryToServiceProvider__c = 'Quarterly';
        amaAgg.AMA_TypeOfPrescriberLevelData__c = 'Birth Year;Gender Code';
        amaAgg.AMA_Services_Provided__c = 'Prescriber List Match only for overlap analysis, no prescriber communication';
        insert amaAgg;

        SRV_TPA_AMAAgreementDetail.validateFunctionalRequirements(getJsonStringOfTPARequest());
    }
    
    private void runUnitTestsForConditionforPhysicianSpecificAnalyticsWithSameDBL() {
        createContract('test Vendor', 'test Vendor', 'Physician Specific Analytics', 'IQVIA', false);
        createContract('test Same Clent', 'test Vendor', 'Biotech Firm', 'IQVIA', false);
        AMA_Agreement_Detail__c amaAgg = UTL_TPA_SetupTestData.getAMAAgreementDetailBlank(testTpaRequest.Id);
        amaAgg.Agreement_Start_Date__c = Date.newInstance(2016, 10, 20);
        amaAgg.Agreement_End_Date__c = Date.newInstance(2017, 12, 31);
        amaAgg.AMA_Howlong_SP_has_Data_Access__c = '90 days or less';
        amaAgg.FrequencyOfDeliveryToServiceProvider__c = 'Quarterly';
        amaAgg.AMA_TypeOfPrescriberLevelData__c = 'Birth Year;Gender Code';
        amaAgg.AMA_Services_Provided__c = 'Prescriber List Match only for overlap analysis, no prescriber communication';
        insert amaAgg;

        SRV_TPA_AMAAgreementDetail.validateFunctionalRequirements(getJsonStringOfTPARequest());
    }
    
    private void runUnitTestsForConditionforPhysicianSpecificAnalyticsWithDifDBL() {
        createContract('test Vendor', 'test Vendor', 'Physician Specific Analytics', 'SHA', false);
        createContract('test Same Clent', 'test Vendor', 'Biotech Firm', 'IQVIA', false);
        AMA_Agreement_Detail__c amaAgg = UTL_TPA_SetupTestData.getAMAAgreementDetailBlank(testTpaRequest.Id);
        amaAgg.Agreement_Start_Date__c = Date.newInstance(2016, 10, 20);
        amaAgg.Agreement_End_Date__c = Date.newInstance(2017, 12, 31);
        amaAgg.AMA_Howlong_SP_has_Data_Access__c = '90 days or less';
        amaAgg.FrequencyOfDeliveryToServiceProvider__c = 'Quarterly';
        amaAgg.AMA_TypeOfPrescriberLevelData__c = 'Birth Year;Gender Code';
        amaAgg.AMA_Services_Provided__c = 'Prescriber List Match only for overlap analysis, no prescriber communication';
        insert amaAgg;

        SRV_TPA_AMAAgreementDetail.validateFunctionalRequirements(getJsonStringOfTPARequest());
    }

    private void runUnitTestsForCondition60to65(){
      createContract('test Same Clent', 'test Vendor', 'Service Bureau II', 'IQVIA', false);
        AMA_Agreement_Detail__c amaAgg = UTL_TPA_SetupTestData.getAMAAgreementDetailBlank(testTpaRequest.Id);
        amaAgg.Agreement_Start_Date__c = Date.newInstance(2016, 10, 20);
        amaAgg.Agreement_End_Date__c = Date.newInstance(2017, 12, 31);
        amaAgg.AMA_Howlong_SP_has_Data_Access__c = '90 days or less';
        amaAgg.FrequencyOfDeliveryToServiceProvider__c = 'Monthly';
        amaAgg.AMA_TypeOfPrescriberLevelData__c = 'Birth Year;Gender Code';
        amaAgg.AMA_Services_Provided__c = 'Prescriber List Match only for overlap analysis, no prescriber communication';
        insert amaAgg;

        SRV_TPA_AMAAgreementDetail.validateFunctionalRequirements(getJsonStringOfTPARequest());
    }
}