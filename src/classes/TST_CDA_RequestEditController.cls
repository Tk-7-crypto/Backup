/*
 *   @author    : Ajinkya Pande
 *   This Test class for controller EXT_CDA_RequestEditController. (created under ER-3556 on 19/06/2017)
 */

@isTest(SeeAllData = false)
private class TST_CDA_RequestEditController {

    private static TST_CDA_SetupData dataSetUp = new TST_CDA_SetupData();
    public static Integer count = 1;
    @testSetup
    static void setupData() {
        dataSetUp.setupUserRequestor();
        dataSetUp.setUpCustomSetting();
        //Added by Vikram Singh under CR-11576 Start
		CDA_Approved_Governing_Law_Location__c governingLaw = TST_CDA_SetupData.getGoverningLaw('Test GL'+count);
		insert governingLaw;
		QI_Legal_Entity__c testQiLegalEntity = TST_CDA_SetupData.createQiLegalEntity('Test Entity1', UTL_CDAUtility.CDA_BUSINESS_PART_LQ, governingLaw);
		insert testQiLegalEntity;
        count++;
		//Added by Vikram Singh under CR-11576 End
        dataSetUp.setupTestDataForCustomer(testQiLegalEntity);  //Updated by Vikam Singh under CR-11576
        dataSetUp.setupTestDataForAuditor(testQiLegalEntity);   //Updated by Vikam Singh under CR-11576
        dataSetUp.setupTestDataForCEVA(testQiLegalEntity);  //Updated by Vikam Singh under CR-11576
        dataSetUp.setupTestDataForVendor(testQiLegalEntity);    //Updated by Vikam Singh under CR-11576
    }

    @isTest
    static void itShouldSaveRecord() {
        CDA_Request__c cdaRecordCustomer = [SELECT id,Competitor_Contracting_Capacity__c, CDA_Type__c, Competitor_Flag__c, Project_Specific_Indicator__c FROM CDA_Request__c WHERE CDA_Type__c =: UTL_CDAUtility.CUSTOMER LIMIT 1];

        // To Test The new request type
        Test.StartTest();
        PageReference pageRef = Page.VFP_CDA_RequestEditScreen;
        pageRef.getParameters().put(UTL_CDAUtility.REQUEST_ID_STR, cdaRecordCustomer.Id);
        pageRef.getParameters().put(UTL_CDAUtility.REQUEST_TYPE_STR, UTL_CDAUtility.REQUEST_TYPE_NEW);
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController sc = new ApexPages.standardController(cdaRecordCustomer);
        EXT_CDA_RequestEditController cdaRequestController = new EXT_CDA_RequestEditController(sc);
        cdaRequestController.cdaRecord.Competitor_Flag__c = UTL_CDAUtility.YES;
        cdaRequestController.cdaRecord.Project_Specific_Indicator__c = UTL_CDAUtility.YES;
        cdaRequestController.setSpecificIndicatorMethod();
        String nextPage = cdaRequestController.saveRecord().getUrl();
        //System.assertNotEquals(null, cdaRequestController);
        CDA_Request__c cdaRecordCustomerExpected = [SELECT id, What_is_the_Study_Sponsor_situation__c, Competitor_Contracting_Capacity__c, CDA_Type__c, Competitor_Flag__c, Project_Specific_Indicator__c FROM CDA_Request__c WHERE id =: cdaRecordCustomer.Id LIMIT 1];
        //System.assertEquals('Yes', cdaRecordCustomerExpected.Competitor_Flag__c);
        //System.assertEquals('No', cdaRecordCustomerExpected.Project_Specific_Indicator__c);
        //System.assertEquals(UTL_CDAUtility.PAGE_VIEW_SCREEN + UTL_CDAUtility.SP_CHAR_QUESTION + UTL_CDAUtility.REQUEST_ID_STR + UTL_CDAUtility.SP_CHAR_EQUAL + cdaRecordCustomer.Id + UTL_CDAUtility.SP_CHAR_AMPERSAND + UTL_CDAUtility.REQUEST_TYPE_STR + UTL_CDAUtility.SP_CHAR_EQUAL + UTL_CDAUtility.REQUEST_TYPE_NEW, nextPage);
        Test.StopTest();
    }

    @isTest
    static void itShouldSaveForLaterRecord() {
        CDA_Request__c cdaRecordAuditor = [SELECT id FROM CDA_Request__c WHERE CDA_Type__c =: UTL_CDAUtility.AUDITOR LIMIT 1];
        ApexPages.StandardController sc = new ApexPages.standardController(cdaRecordAuditor);
        EXT_CDA_RequestEditController cdaRequestController = new EXT_CDA_RequestEditController(sc);
        cdaRequestController.isAuthorizedSigner = UTL_CDAUtility.YES;
        // To Test The new request type
        Test.StartTest();
        PageReference pageRef = Page.VFP_CDA_RequestEditScreen;
        pageRef.getParameters().put(UTL_CDAUtility.REQUEST_ID_STR, cdaRecordAuditor.Id);
        pageRef.getParameters().put(UTL_CDAUtility.REQUEST_TYPE_STR, UTL_CDAUtility.REQUEST_TYPE_EDIT);
        Test.setCurrentPage(pageRef);
        cdaRequestController.cdaRecord.Competitor_Flag__c = UTL_CDAUtility.YES;
        cdaRequestController.setSpecificIndicatorMethod();
        cdaRequestController.cdaRecord.Status__c = UTL_CDAUtility.STATUS_INDRAFT;
        cdaRequestController.saveForLaterRecord();
        //System.assertNotEquals(null, cdaRequestController);
        CDA_Request__c cdaRecordAuditorExpected = [SELECT id, What_is_the_Study_Sponsor_situation__c, Competitor_Contracting_Capacity__c, CDA_Type__c, Competitor_Flag__c, Project_Specific_Indicator__c FROM CDA_Request__c WHERE id =: cdaRecordAuditor.Id LIMIT 1];
        //System.assertEquals('No', cdaRecordAuditorExpected.Competitor_Flag__c);
        //System.assertEquals('No', cdaRecordAuditorExpected.Project_Specific_Indicator__c);
        Test.StopTest();
    }

    @isTest
    static void itShouldNotSaveForLaterRecord() {
        try {
            CDA_Request__c cdaRecordAuditor = [SELECT id FROM CDA_Request__c WHERE CDA_Type__c =: UTL_CDAUtility.AUDITOR LIMIT 1];
            ApexPages.StandardController sc = new ApexPages.standardController(cdaRecordAuditor);
            EXT_CDA_RequestEditController cdaRequestController = new EXT_CDA_RequestEditController(sc);
            // To Test The new request type
            Test.StartTest();
            PageReference pageRef = Page.VFP_CDA_RequestEditScreen;
            pageRef.getParameters().put(UTL_CDAUtility.REQUEST_ID_STR, cdaRecordAuditor.Id);
            pageRef.getParameters().put(UTL_CDAUtility.REQUEST_TYPE_STR, UTL_CDAUtility.REQUEST_TYPE_EDIT);
            Test.setCurrentPage(pageRef);
            cdaRequestController.cdaRecord.Id = null;
            cdaRequestController.cdaRecord.Status__c = UTL_CDAUtility.STATUS_INDRAFT;
            cdaRequestController.saveForLaterRecord();
           // System.assertNotEquals(null, cdaRequestController);
        } catch (Exception ex) {
            //system.assertEquals(new Apexpages.Message(ApexPages.severity.INFO, ex.getMessage()), Apexpages.getMessages()[0]);
            Test.StopTest();
        }
    }

    @isTest
    static void itShouldSaveRecordWithCustomerLegalAddress() {
        CDA_Request__c cdaRecordAuditor = [SELECT id FROM CDA_Request__c WHERE CDA_Type__c =: UTL_CDAUtility.AUDITOR LIMIT 1];

        // To Test The new request type
        Test.StartTest();
        PageReference pageRef = Page.VFP_CDA_RequestEditScreen;
        pageRef.getParameters().put(UTL_CDAUtility.REQUEST_ID_STR, cdaRecordAuditor.Id);
        pageRef.getParameters().put(UTL_CDAUtility.REQUEST_TYPE_STR, UTL_CDAUtility.REQUEST_TYPE_NEW);
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController sc = new ApexPages.standardController(cdaRecordAuditor);
        EXT_CDA_RequestEditController cdaRequestController = new EXT_CDA_RequestEditController(sc);
        cdaRequestController.cdaRecord.Customer_Specified_Vendor_Template__c = UTL_CDAUtility.NO;
        cdaRequestController.customerSpecifiedVendorTemplateChanged();
        cdaRequestController.cdaSourceChanged();
        cdaRequestController.cdaRecord.Cust_Legal_Entity_Name__c = dataSetUp.cdaAccount.Id;
        cdaRequestController.customerLegalEntityNameChanged();
        cdaRequestController.customerLegalEntityStreet = 'Street';
        cdaRequestController.customerLegalEntityCity = 'city';
        cdaRequestController.customerLegalEntityState = 'state';
        cdaRequestController.customerLegalEntitycountry = 'country';
        cdaRequestController.customerLegalEntityZipCode = '123434';
        String nextPage = cdaRequestController.saveRecord().getUrl();
        //System.assertNotEquals(null, cdaRequestController);
        CDA_Account__c expectedCDAAccount = [SELECT id, Street__c, State__c, Country__c, City__c, Zip_Postal_Code__c, Name, Complete_Address__c FROM CDA_Account__c WHERE id =:dataSetUp.cdaAccount.Id LIMIT 1];
        //System.assertEquals('Street, city, state 123434 country', expectedCDAAccount.Street__c);
        //System.assertEquals(UTL_CDAUtility.PAGE_VIEW_SCREEN + UTL_CDAUtility.SP_CHAR_QUESTION + UTL_CDAUtility.REQUEST_ID_STR + UTL_CDAUtility.SP_CHAR_EQUAL + cdaRecordAuditor.Id + UTL_CDAUtility.SP_CHAR_AMPERSAND + UTL_CDAUtility.REQUEST_TYPE_STR + UTL_CDAUtility.SP_CHAR_EQUAL + UTL_CDAUtility.REQUEST_TYPE_NEW, nextPage);
        Test.StopTest();
    }

    @isTest
    static void itShouldSaveRecordWithSponsorLegalAddress() {
        CDA_Request__c cdaRecordCEVA = [SELECT id FROM CDA_Request__c WHERE CDA_Type__c =: UTL_CDAUtility.CEVA LIMIT 1];

        // To Test The new request type
        Test.StartTest();
        PageReference pageRef = Page.VFP_CDA_RequestEditScreen;
        pageRef.getParameters().put(UTL_CDAUtility.REQUEST_ID_STR, cdaRecordCEVA.Id);
        pageRef.getParameters().put(UTL_CDAUtility.REQUEST_TYPE_STR, UTL_CDAUtility.REQUEST_TYPE_EDIT);
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController sc = new ApexPages.standardController(cdaRecordCEVA);
        EXT_CDA_RequestEditController cdaRequestController = new EXT_CDA_RequestEditController(sc);
        cdaRequestController.cdaRecord.Customer_Specified_Vendor_Template__c = UTL_CDAUtility.YES;
        cdaRequestController.customerSpecifiedVendorTemplateChanged();
        cdaRequestController.cdaSourceChanged();
        cdaRequestController.cdaTypeChanged();
        cdaRequestController.cdaRecord.Sponsor_Legal_Entity__c = dataSetUp.cdaAccount.Id;
        SRV_CDA_CDARequest.accountListMap = null;
        cdaRequestController.sponsorLegalEntityNamechanged();
        cdaRequestController.sponsorLegalEntityStreet = 'Street';
        cdaRequestController.sponsorLegalEntityCity = 'city';
        cdaRequestController.cdaRecord.Sponsor_Legal_Entity_State_Other_PL__c = 'state';
        cdaRequestController.cdaRecord.Sponsor_Legal_Entity_Country_Other_PL__c = 'country';
        cdaRequestController.sponsorLegalEntityZipCode = '123434';
        String nextPage = cdaRequestController.saveRecord().getUrl();
        //System.assertNotEquals(null, cdaRequestController);
        CDA_Account__c expectedCDAAccount = [SELECT id, Street__c, State__c, Country__c, City__c, Zip_Postal_Code__c, Name, Complete_Address__c FROM CDA_Account__c WHERE id =:cdaRequestController.cdaRecord.Sponsor_Legal_Entity__c];
        //System.assertEquals('Street, city, state 123434 country', expectedCDAAccount.Complete_Address__c);
        //System.assertEquals(UTL_CDAUtility.PAGE_VIEW_SCREEN + UTL_CDAUtility.SP_CHAR_QUESTION + UTL_CDAUtility.REQUEST_ID_STR + UTL_CDAUtility.SP_CHAR_EQUAL + cdaRecordCEVA.Id + UTL_CDAUtility.SP_CHAR_AMPERSAND + UTL_CDAUtility.REQUEST_TYPE_STR + UTL_CDAUtility.SP_CHAR_EQUAL + UTL_CDAUtility.REQUEST_TYPE_EDIT, nextPage);
        Test.StopTest();
    }

    @isTest
    static void itShouldSaveRecordWithRecipientAccountAddress() {
        CDA_Request__c cdaRecordAuditor = [SELECT id FROM CDA_Request__c WHERE CDA_Type__c =: UTL_CDAUtility.VENDOR LIMIT 1];

        // To Test The new request type
        Test.StartTest();
        PageReference pageRef = Page.VFP_CDA_RequestEditScreen;
        pageRef.getParameters().put(UTL_CDAUtility.REQUEST_ID_STR, cdaRecordAuditor.Id);
        pageRef.getParameters().put(UTL_CDAUtility.REQUEST_TYPE_STR, UTL_CDAUtility.REQUEST_TYPE_NEW);
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController sc = new ApexPages.standardController(cdaRecordAuditor);
        EXT_CDA_RequestEditController cdaRequestController = new EXT_CDA_RequestEditController(sc);
        cdaRequestController.cdaSourceChanged();
        cdaRequestController.cdaRecord.Recipient_Account__c = dataSetUp.cdaAccount.Id;
        cdaRequestController.recipientAccountNameChanged();
        //Added by Vikram Singh under CR-11576 Start
        CDA_Approved_Governing_Law_Location__c governingLaw = TST_CDA_SetupData.getGoverningLaw('Test GL');
        insert governingLaw;
        QI_Legal_Entity__c testQiLegalEntity = TST_CDA_SetupData.createQiLegalEntity('Test Entity288', UTL_CDAUtility.CDA_BUSINESS_PART_LQ, governingLaw);
        insert testQiLegalEntity;
        //Added by Vikram Singh under CR-11576 End
        cdaRequestController.cdaRecord.QI_Legal_Entity_Name__c = testQiLegalEntity.Id;    //Updated by Vikram Singh under CR-11576
        cdaRequestController.qiLegalEntityNameChanged();
        cdaRequestController.recipientAccountStreet = 'Street';
        cdaRequestController.recipientAccountCity = 'city';
        cdaRequestController.recipientAccountState = 'state';
        cdaRequestController.recipientAccountCountry = 'country';
        cdaRequestController.recipientAccountZipCode = '123434';
        cdaRequestController.setSpecificIndicatorMethod();
        String nextPage = cdaRequestController.saveRecord().getUrl();
        // System.assertNotEquals(null, cdaRequestController);
        CDA_Account__c expectedCDAAccount = [SELECT id, Street__c, State__c, Country__c, City__c, Zip_Postal_Code__c, Name, Complete_Address__c FROM CDA_Account__c WHERE id =:dataSetUp.cdaAccount.Id];
        //System.assertEquals('Street, city, state 123434 country', expectedCDAAccount.Complete_Address__c);
        //System.assertEquals(UTL_CDAUtility.PAGE_VIEW_SCREEN + UTL_CDAUtility.SP_CHAR_QUESTION + UTL_CDAUtility.REQUEST_ID_STR + UTL_CDAUtility.SP_CHAR_EQUAL + cdaRecordAuditor.Id + UTL_CDAUtility.SP_CHAR_AMPERSAND + UTL_CDAUtility.REQUEST_TYPE_STR + UTL_CDAUtility.SP_CHAR_EQUAL + UTL_CDAUtility.REQUEST_TYPE_NEW, nextPage);
        Test.StopTest();
    }

    @isTest
    static void itShouldResetDefaults() {
        CDA_Request__c cdaRecordCustomer = [SELECT id,Competitor_Contracting_Capacity__c, CDA_Type__c FROM CDA_Request__c WHERE CDA_Type__c =: UTL_CDAUtility.CUSTOMER LIMIT 1];
        // To Test The new request type
        Test.StartTest();
        PageReference pageRef = Page.VFP_CDA_RequestEditScreen;
        pageRef.getParameters().put(UTL_CDAUtility.REQUEST_ID_STR, cdaRecordCustomer.Id);
        pageRef.getParameters().put(UTL_CDAUtility.REQUEST_TYPE_STR, UTL_CDAUtility.REQUEST_TYPE_NEW);
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController sc = new ApexPages.standardController(cdaRecordCustomer);
        EXT_CDA_RequestEditController cdaRequestController = new EXT_CDA_RequestEditController(sc);
        cdaRequestController.resetDefaults();
        //System.assertNotEquals(null, cdaRequestController);
        Test.StopTest();
    }

    @isTest
    static void itShouldCancelRequest() {
        CDA_Request__c cdaRecordCustomer = [SELECT id,Competitor_Contracting_Capacity__c, CDA_Type__c FROM CDA_Request__c WHERE CDA_Type__c =: UTL_CDAUtility.CUSTOMER LIMIT 1];
        // To Test The new request type
        Test.StartTest();
        PageReference pageRef = Page.VFP_CDA_RequestEditScreen;
        pageRef.getParameters().put(UTL_CDAUtility.REQUEST_ID_STR, cdaRecordCustomer.Id);
        pageRef.getParameters().put(UTL_CDAUtility.REQUEST_TYPE_STR, UTL_CDAUtility.REQUEST_TYPE_NEW);
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController sc = new ApexPages.standardController(cdaRecordCustomer);
        EXT_CDA_RequestEditController cdaRequestController = new EXT_CDA_RequestEditController(sc);
        String nextPage = cdaRequestController.cancel().getUrl();
        //System.assertNotEquals(null, cdaRequestController);
        //System.assertEquals(UTL_CDAUtility.PAGE_LANDING_SCREEN, nextPage);
        Test.StopTest();
    }

    @isTest
    static void itShouldNotCancelRequest() {
        PageReference nextPage;
        CDA_Request__c cdaRecordCustomer = [SELECT id,Competitor_Contracting_Capacity__c, CDA_Type__c FROM CDA_Request__c WHERE CDA_Type__c =: UTL_CDAUtility.CUSTOMER LIMIT 1];
        try {
            // To Test The new request type
            PageReference pageRef = Page.VFP_CDA_RequestEditScreen;
            pageRef.getParameters().put(UTL_CDAUtility.REQUEST_ID_STR, cdaRecordCustomer.Id);
            pageRef.getParameters().put(UTL_CDAUtility.REQUEST_TYPE_STR, UTL_CDAUtility.REQUEST_TYPE_NEW);
            Test.setCurrentPage(pageRef);
            ApexPages.StandardController sc = new ApexPages.standardController(cdaRecordCustomer);
            EXT_CDA_RequestEditController cdaRequestController = new EXT_CDA_RequestEditController(sc);
            cdaRequestController.cdaRecord.Id = null;
            Test.StartTest();
            nextPage = cdaRequestController.cancel();
            Test.StopTest();
        } catch(Exception ex) {
            //system.assertEquals(null, nextpage, 'Redirect should be cancelled');
            Test.StopTest();
        }
    }

    @isTest
    static void itShouldTestProperties() {
        CDA_Request__c cdaRecordCustomer = [SELECT id,Competitor_Contracting_Capacity__c, CDA_Type__c FROM CDA_Request__c WHERE CDA_Type__c =: UTL_CDAUtility.CUSTOMER LIMIT 1];
        PageReference pageRef = Page.VFP_CDA_RequestEditScreen;
        pageRef.getParameters().put(UTL_CDAUtility.REQUEST_ID_STR, cdaRecordCustomer.Id);
        pageRef.getParameters().put(UTL_CDAUtility.REQUEST_TYPE_STR, UTL_CDAUtility.REQUEST_TYPE_NEW);
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController sc = new ApexPages.standardController(cdaRecordCustomer);
        EXT_CDA_RequestEditController cdaRequestController = new EXT_CDA_RequestEditController(sc);
        Test.StartTest();
        String dateFormatActual = cdaRequestController.dateFormatString;
        Boolean isCompetitorActual = cdaRequestController.isCompetitor;
        Boolean isNegotiatorActual = cdaRequestController.isNegotiator;
        Boolean isProtocolNumberKnownActual = cdaRequestController.isProtocolNumberKnown;
        Boolean isProtocolNumberNotKnownActual = cdaRequestController.isProtocolNumberNotKnown;
        Boolean isProtocolTitleKnownActual = cdaRequestController.isProtocolTitleKnown;
        Boolean isProtocolTitleNotKnownActual = cdaRequestController.isProtocolTitleNotKnown;
        Boolean isProtocolHasToRenderActual = cdaRequestController.isProtocolHasToRender;
        Boolean isCompetitorContractingCapacityCollaboratorActual = cdaRequestController.isCompetitorContractingCapacityCollaborator;
        Boolean isCompetitorContractingCapacityVendorActual = cdaRequestController.isCompetitorContractingCapacityVendor;
        Boolean isCompetitorContractingCapacityCustomerActual = cdaRequestController.isCompetitorContractingCapacityCustomer;
        Boolean whatIsTheStudySponsorSituationStudySponsorIdentifiedActual = cdaRequestController.whatIsTheStudySponsorSituationStudySponsorIdentified;
        Boolean showCdaFormatActual = cdaRequestController.showCdaFormat;
        Test.StopTest();
        /*System.assertEquals('(MM/DD/YYYY)', dateFormatActual);
        System.assertEquals(true, isCompetitorActual);
        System.assertEquals(true, isNegotiatorActual);
        System.assertEquals(false, isProtocolNumberKnownActual);
        System.assertEquals(false, isProtocolNumberNotKnownActual);
        System.assertEquals(false, isProtocolTitleKnownActual);
        System.assertEquals(false, isProtocolTitleNotKnownActual);
        System.assertEquals(true, isProtocolHasToRenderActual);
        System.assertEquals(false, isCompetitorContractingCapacityCollaboratorActual);
        System.assertEquals(false, isCompetitorContractingCapacityVendorActual);
        System.assertEquals(true, isCompetitorContractingCapacityCustomerActual);
        System.assertEquals(true, whatIsTheStudySponsorSituationStudySponsorIdentifiedActual);
        System.assertEquals(true, showCdaFormatActual);*/
    }

    @isTest
    static void itShouldNotSaveRecord() {
        String nextPage;
        try {
            CDA_Request__c cdaRecordCustomer = [SELECT id,Competitor_Contracting_Capacity__c, CDA_Type__c FROM CDA_Request__c WHERE CDA_Type__c =: UTL_CDAUtility.CUSTOMER LIMIT 1];
            CDA_Account__c cdaAccount = [SELECT id FROM CDA_Account__c LIMIT 1];
            PageReference pageRef = Page.VFP_CDA_RequestEditScreen;
            pageRef.getParameters().put(UTL_CDAUtility.REQUEST_ID_STR, cdaRecordCustomer.Id);
            pageRef.getParameters().put(UTL_CDAUtility.REQUEST_TYPE_STR, UTL_CDAUtility.REQUEST_TYPE_NEW);
            Test.setCurrentPage(pageRef);
            ApexPages.StandardController sc = new ApexPages.standardController(cdaRecordCustomer);
            EXT_CDA_RequestEditController cdaRequestController = new EXT_CDA_RequestEditController(sc);
            Test.StartTest();
            cdaRequestController.cdaRecord.Location_of_Governing_Law__c = 'Test';   //Updated by Vikram Singh under CR-11576
            nextPage = cdaRequestController.saveRecord().getUrl();
        } catch (Exception ex) {
            //System.assertEquals(null, nextPage, ex.getMessage());
            Test.StopTest();
        }
    }

    @isTest
    static void itShouldGetIsAuditorIsEmp() {
        CDA_Request__c cdaRecordCustomer = [SELECT id,Competitor_Contracting_Capacity__c, CDA_Type__c FROM CDA_Request__c WHERE CDA_Type__c =: UTL_CDAUtility.CUSTOMER LIMIT 1];
        CDA_Account__c cdaAccount = [SELECT id FROM CDA_Account__c LIMIT 1];
        PageReference pageRef = Page.VFP_CDA_RequestEditScreen;
        pageRef.getParameters().put(UTL_CDAUtility.REQUEST_ID_STR, cdaRecordCustomer.Id);
        pageRef.getParameters().put(UTL_CDAUtility.REQUEST_TYPE_STR, UTL_CDAUtility.REQUEST_TYPE_NEW);
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController sc = new ApexPages.standardController(cdaRecordCustomer);
        EXT_CDA_RequestEditController cdaRequestController = new EXT_CDA_RequestEditController(sc);
        List<SelectOption> expectedOptions = new List<SelectOption>();
        expectedOptions.add(new SelectOption('', '--None--'));
        expectedOptions.add(new SelectOption(UTL_CDAUtility.YES, 'Yes'));
        expectedOptions.add(new SelectOption(UTL_CDAUtility.NO, 'No'));
        // expectedOptions[1].setValue(UTL_CDAUtility.YES);
        Test.StartTest();
        List<SelectOption> actualOptions = cdaRequestController.getIsAuditorIsEmp();
        // actualOptions[1].setValue(UTL_CDAUtility.YES);
        Test.StopTest();
       // System.assertEquals(expectedOptions, actualOptions);
    }

    @isTest
    static void itShouldDeleteCdaRequest() {
        CDA_Request__c cdaReqObj = new CDA_Request__c();
        insert cdaReqObj;
        ApexPages.StandardController sc = new ApexPages.standardController(cdaReqObj);
        EXT_CDA_RequestEditController cdaRequestController = new EXT_CDA_RequestEditController(sc);
        cdaRequestController.cdaRequestDeleteAndReturnToLanding();
    }
}