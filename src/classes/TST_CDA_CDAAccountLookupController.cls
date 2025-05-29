/**
 * @author : Babita Dadarwal
 * Test class for CNT_CDA_CDAAccountLookupController
 */

@isTest(seeAllData = false)
public class TST_CDA_CDAAccountLookupController {

    @testSetup
    public static void setupData() {
        TST_CDA_SetupData testSetup = new TST_CDA_SetupData();
        CDA_Account__c testCdaAccount = testSetup.cdaAccount;
        testSetup.setUpCustomSetting();

        //Added by Vikram Singh under CR-11576 .Start
        CDA_Approved_Governing_Law_Location__c governingLaw = TST_CDA_SetupData.getGoverningLaw('Test GL');
        insert governingLaw;
        //Added by Vikram Singh under CR-11576 End

        QI_Legal_Entity__c testQiLegalEntity = TST_CDA_SetupData.createQiLegalEntity('Test Entity1', UTL_CDAUtility.CDA_BUSINESS_PART_LQ, governingLaw); //Updated by Vikram Singh under CR-11576
        insert testQiLegalEntity;   //Added by Vikram Singh under CR-11576

        testSetup.setupTestDataForCustomer(testQiLegalEntity);  //Updated by Vikram Singh under CR-11576
    }

    @isTest
    public static void accountLookupContrlTest() {
        Test.StartTest();

        PageReference pageRef = Page.VFP_CDA_CDAAccountLookup;
        pageRef.getParameters().put('value', 'IQVIA Inc.'); //Updated by Vikram Singh under CR-11385
        pageRef.getParameters().put('entityType', 'qiLegalEntity');
        Test.setCurrentPage(pageRef);

        CNT_CDA_CDAAccountLookupController conObj = new CNT_CDA_CDAAccountLookupController();

        conObj.refresh();
        //system.assertEquals(1, conObj.setCon.getRecords().size());
        // system.assertEquals(10, conObj.setCon.getPageSize());

        conObj.toggleSort();
        // system.assertEquals('desc', conObj.sortDir);
        conObj.clearSearch();
        List<SelectOption> pagesizeList = conObj.getRecordsPerPage();
        // system.assertEquals(5, pagesizeList.size());

        pageRef.getParameters().put('value', 'Test Account');
        pageRef.getParameters().put('entityType', 'qiLegalEntityTest');
        Test.setCurrentPage(pageRef);
        CNT_CDA_CDAAccountLookupController conObj1 = new CNT_CDA_CDAAccountLookupController();
        conObj1.refresh();
        conObj.clearSearch();

        Test.StopTest();
    }
}