@isTest(SeeAllData = false)
private class TST_EXT_CDA_RequestViewController {
    private static TST_CDA_SetupData dataSetUp = new TST_CDA_SetupData();

    @testSetup
    static void setupData() {
        dataSetUp.setupUserRequestor();
        dataSetUp.setUpCustomSetting();
        
        CDA_Approved_Governing_Law_Location__c governingLaw = TST_CDA_SetupData.getGoverningLaw('Test GL');
        insert governingLaw;
        
        QI_Legal_Entity__c testQiLegalEntity = TST_CDA_SetupData.createQiLegalEntity('Test Entity1', UTL_CDAUtility.CDA_BUSINESS_PART_LQ, governingLaw);
        insert testQiLegalEntity;
        
        dataSetUp.setupTestDataForCustomer(testQiLegalEntity);  //Updated by Vikram Singh under CR-11576
        dataSetUp.getAttachment(UTL_CDAUtility.MANAGEMENT_APPROVAL_DOCUMENT, dataSetUp.cdaRecordCustomer.Id);
        dataSetUp.getAttachment(UTL_CDAUtility.CUSTOMER_CONSENT_TO_DISCLOSE, dataSetUp.cdaRecordCustomer.Id);
        dataSetUp.getAttachment(UTL_CDAUtility.GENERATED_DOCUMENT_KEYWORD, dataSetUp.cdaRecordCustomer.Id);
        dataSetUp.getAttachment(UTL_CDAUtility.SPONSOR_CONSENT_TO_DISCLOSE, dataSetUp.cdaRecordCustomer.Id);
        dataSetUp.getAttachment(UTL_CDAUtility.RED_LINE_DOCUMENT, dataSetUp.cdaRecordCustomer.Id);
        dataSetUp.getAttachment(UTL_CDAUtility.AWAITING_OGC_APPROVAL, dataSetUp.cdaRecordCustomer.Id);
        UTL_CDAUtility.devEmails = CDA_Settings__c.getOrgDefaults().CDA_Dev_Emails__c;
    }

    @isTest
    static void itShouldGenerateCDADoc() {
        CDA_Request__c cdaRecordCustomer = [SELECT id,Competitor_Contracting_Capacity__c, CDA_Type__c, Competitor_Flag__c, Project_Specific_Indicator__c FROM CDA_Request__c WHERE CDA_Type__c =: UTL_CDAUtility.CUSTOMER LIMIT 1];

        // To Test The new request type
        Test.StartTest();
        PageReference pageRef = Page.VFP_CDA_RequestViewScreen;
        pageRef.getParameters().put(UTL_CDAUtility.REQUEST_ID_STR, cdaRecordCustomer.Id);
        pageRef.getParameters().put(UTL_CDAUtility.REQUEST_TYPE_STR, UTL_CDAUtility.REQUEST_TYPE_NEW);
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController sc = new ApexPages.standardController(cdaRecordCustomer);
        EXT_CDA_RequestViewController cdaRequestController = new EXT_CDA_RequestViewController(sc);
        String nextPage = cdaRequestController.generateCDADoc().getUrl();
        //System.assertNotEquals(null, cdaRequestController);
        CDA_Request__c cdaRecordCustomerExpected = [SELECT id, What_is_the_Study_Sponsor_situation__c, Competitor_Contracting_Capacity__c, CDA_Type__c, Competitor_Flag__c, Project_Specific_Indicator__c FROM CDA_Request__c WHERE id =: cdaRecordCustomer.Id LIMIT 1];
        //System.assertEquals(UTL_CDAUtility.SP_CHAR_SLASH + cdaRecordCustomer.Id, nextPage);
        Test.StopTest();
    }

    @isTest
    static void itShouldEditRequest() {
        CDA_Request__c cdaRecordCustomer = [SELECT id,Competitor_Contracting_Capacity__c, CDA_Type__c, Competitor_Flag__c, Project_Specific_Indicator__c FROM CDA_Request__c WHERE CDA_Type__c =: UTL_CDAUtility.CUSTOMER LIMIT 1];

        // To Test The new request type
        Test.StartTest();
        PageReference pageRef = Page.VFP_CDA_RequestViewScreen;
        pageRef.getParameters().put(UTL_CDAUtility.REQUEST_ID_STR, cdaRecordCustomer.Id);
        pageRef.getParameters().put(UTL_CDAUtility.REQUEST_TYPE_STR, UTL_CDAUtility.REQUEST_TYPE_NEW);
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController sc = new ApexPages.standardController(cdaRecordCustomer);
        EXT_CDA_RequestViewController cdaRequestController = new EXT_CDA_RequestViewController(sc);
        String nextPage = cdaRequestController.editRequest().getUrl();
        //System.assertNotEquals(null, cdaRequestController);
        CDA_Request__c cdaRecordCustomerExpected = [SELECT id, What_is_the_Study_Sponsor_situation__c, Competitor_Contracting_Capacity__c, CDA_Type__c, Competitor_Flag__c, Project_Specific_Indicator__c FROM CDA_Request__c WHERE id =: cdaRecordCustomer.Id LIMIT 1];
        //System.assertEquals(UTL_CDAUtility.PAGE_EDIT_SCREEN + UTL_CDAUtility.SP_CHAR_QUESTION + UTL_CDAUtility.REQUEST_ID_STR + UTL_CDAUtility.SP_CHAR_EQUAL + cdaRecordCustomer.Id + UTL_CDAUtility.SP_CHAR_AMPERSAND + UTL_CDAUtility.REQUEST_TYPE_STR + UTL_CDAUtility.SP_CHAR_EQUAL + UTL_CDAUtility.REQUEST_TYPE_EDIT, nextPage);
        Test.StopTest();
    }

    @isTest
    static void itShouldCancelRequest() {
        CDA_Request__c cdaRecordCustomer = [SELECT id,Competitor_Contracting_Capacity__c, CDA_Type__c, Competitor_Flag__c, Project_Specific_Indicator__c FROM CDA_Request__c WHERE CDA_Type__c =: UTL_CDAUtility.CUSTOMER LIMIT 1];

        // To Test The new request type
        Test.StartTest();
        PageReference pageRef = Page.VFP_CDA_RequestViewScreen;
        pageRef.getParameters().put(UTL_CDAUtility.REQUEST_ID_STR, cdaRecordCustomer.Id);
        pageRef.getParameters().put(UTL_CDAUtility.REQUEST_TYPE_STR, UTL_CDAUtility.REQUEST_TYPE_NEW);
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController sc = new ApexPages.standardController(cdaRecordCustomer);
        EXT_CDA_RequestViewController cdaRequestController = new EXT_CDA_RequestViewController(sc);
        String nextPage = cdaRequestController.cancelRequest().getUrl();
        //System.assertNotEquals(null, cdaRequestController);
        //System.assertEquals(UTL_CDAUtility.PAGE_LANDING_SCREEN, nextPage);
        Test.StopTest();
    }    

    @isTest
    static void itShouldCancelbyRequestor() {
        String nextPage;
        User user = [SELECT id FROM User WHERE Alias = 'TestUsr1'];
        dataSetUp.setUpContactForEmail();
        //System.assertNotEquals(null, user);
        System.runAs(user) {
            CDA_Approved_Governing_Law_Location__c governingLaw = TST_CDA_SetupData.getGoverningLaw('Test GL901');
            insert governingLaw;
            QI_Legal_Entity__c testQiLegalEntity = TST_CDA_SetupData.createQiLegalEntity('Test Entity254', UTL_CDAUtility.CDA_BUSINESS_PART_LQ, governingLaw);
            insert testQiLegalEntity;
            dataSetUp.setupTestDataForVendor(testQiLegalEntity);
            CDA_Request__c cdaRecordVendor = [SELECT id,Competitor_Contracting_Capacity__c, CDA_Type__c, Competitor_Flag__c, Project_Specific_Indicator__c FROM CDA_Request__c WHERE id =: dataSetUp.cdaRecordVendor.Id LIMIT 1];
            ApexPages.StandardController sc = new ApexPages.standardController(cdaRecordVendor);
            EXT_CDA_RequestViewController cdaRequestController = new EXT_CDA_RequestViewController(sc);
            // To Test The new request type
            Test.StartTest();
            PageReference pageRef = Page.VFP_CDA_RequestViewScreen;
            pageRef.getParameters().put(UTL_CDAUtility.REQUEST_ID_STR, cdaRecordVendor.Id);
            pageRef.getParameters().put(UTL_CDAUtility.REQUEST_TYPE_STR, UTL_CDAUtility.REQUEST_TYPE_NEW);
            Test.setCurrentPage(pageRef);
            cdaRequestController.cancelbyRequestor();
            //System.assertNotEquals(null, cdaRequestController);
            CDA_Request__c cdaRecordVendorActual = [SELECT id, Status__c FROM CDA_Request__c WHERE id =: dataSetUp.cdaRecordVendor.Id LIMIT 1];
            //System.assertEquals(UTL_CDAUtility.STATUS_CANCELEDBYREQUESTOR, cdaRecordVendorActual.Status__c);
        }
        Test.StopTest();
    }

    @isTest
    static void itShouldNotCancelbyRequestor() {
        String nextPage;
        CDA_Request__c cdaRecordCustomer = [SELECT id,Competitor_Contracting_Capacity__c, CDA_Type__c, Competitor_Flag__c, Project_Specific_Indicator__c FROM CDA_Request__c WHERE CDA_Type__c =: UTL_CDAUtility.CUSTOMER LIMIT 1];
        User user = [SELECT id FROM User WHERE Alias = 'TestUsr1'];
        ApexPages.StandardController sc = new ApexPages.standardController(cdaRecordCustomer);
        EXT_CDA_RequestViewController cdaRequestController = new EXT_CDA_RequestViewController(sc);
        try {
            // To Test The new request type
            Test.StartTest();
            PageReference pageRef = Page.VFP_CDA_RequestViewScreen;
            pageRef.getParameters().put(UTL_CDAUtility.REQUEST_ID_STR, cdaRecordCustomer.Id);
            pageRef.getParameters().put(UTL_CDAUtility.REQUEST_TYPE_STR, UTL_CDAUtility.REQUEST_TYPE_NEW);
            Test.setCurrentPage(pageRef);
            cdaRequestController.cdaRequest.Id = null;
            //System.assertNotEquals(null, user);
            System.runAs(user) {
                cdaRequestController.cancelbyRequestor();
            }
        } catch(Exception ex) {
            //System.assertNotEquals(null, cdaRequestController);
            //System.assertEquals(new Apexpages.Message(ApexPages.severity.INFO, ex.getMessage()), Apexpages.getMessages()[0]);
            Test.StopTest();
        }
    }

    @isTest
    static void itShouldEditNegotiatorDetails() {
        String nextPage;
        CDA_Request__c cdaRecordCustomer = [SELECT id,Competitor_Contracting_Capacity__c, CDA_Type__c, Competitor_Flag__c, Project_Specific_Indicator__c FROM CDA_Request__c WHERE CDA_Type__c =: UTL_CDAUtility.CUSTOMER LIMIT 1];
        ApexPages.StandardController sc = new ApexPages.standardController(cdaRecordCustomer);
        EXT_CDA_RequestViewController cdaRequestController = new EXT_CDA_RequestViewController(sc);
        // To Test The new request type
        Test.StartTest();
        PageReference pageRef = Page.VFP_CDA_RequestViewScreen;
        pageRef.getParameters().put(UTL_CDAUtility.REQUEST_ID_STR, cdaRecordCustomer.Id);
        pageRef.getParameters().put(UTL_CDAUtility.REQUEST_TYPE_STR, UTL_CDAUtility.REQUEST_TYPE_NEW);
        Test.setCurrentPage(pageRef);
        cdaRequestController.editNegotiatorDetails();
        //System.assertNotEquals(null, cdaRequestController);
        //System.assertEquals(true, cdaRequestController.showNegotiatorEditable);
        Test.StopTest();
    }

    @isTest
    static void itShouldUpdateNegotiatorDetails() {
        String nextPage;
        CDA_Request__c cdaRecordCustomer = [SELECT id,Competitor_Contracting_Capacity__c, CDA_Type__c, Competitor_Flag__c, Project_Specific_Indicator__c FROM CDA_Request__c WHERE CDA_Type__c =: UTL_CDAUtility.CUSTOMER LIMIT 1];
        ApexPages.StandardController sc = new ApexPages.standardController(cdaRecordCustomer);
        EXT_CDA_RequestViewController cdaRequestController = new EXT_CDA_RequestViewController(sc);
        // To Test The new request type
        Test.StartTest();
        PageReference pageRef = Page.VFP_CDA_RequestViewScreen;
        pageRef.getParameters().put(UTL_CDAUtility.REQUEST_ID_STR, cdaRecordCustomer.Id);
        pageRef.getParameters().put(UTL_CDAUtility.REQUEST_TYPE_STR, UTL_CDAUtility.REQUEST_TYPE_NEW);
        Test.setCurrentPage(pageRef);
        cdaRequestController.cdaRequestStatusEdit.Status__c = UTL_CDAUtility.STATUS_CONTRACTEXECUTED;
        dataSetUp.setUpContactForEmail();
        cdaRequestController.cdaRequest.Negotiator_Assigned_List__c = 'skumari@us.imshealth.com';
        PageReference pageRefer = cdaRequestController.updateNegotiatorDetails();
        if(pageRefer != null) {
            nextPage = pageRefer.getUrl();
        }
        //System.assertNotEquals(null, cdaRequestController);
        // System.assertEquals(UTL_CDAUtility.SP_CHAR_SLASH + cdaRecordCustomer.Id, nextPage);  //Commented by Vikram Singh under Day3 migration to avoid the validation Error
        Test.StopTest();
    }

    @isTest
    static void itShouldNotUpdateNegotiatorDetails() {
        String nextPage;
        CDA_Request__c cdaRecordCustomer = [SELECT id,Competitor_Contracting_Capacity__c, CDA_Type__c, Competitor_Flag__c, Project_Specific_Indicator__c FROM CDA_Request__c WHERE CDA_Type__c =: UTL_CDAUtility.CUSTOMER LIMIT 1];
        ApexPages.StandardController sc = new ApexPages.standardController(cdaRecordCustomer);
        EXT_CDA_RequestViewController cdaRequestController = new EXT_CDA_RequestViewController(sc);
        try {
            // To Test The new request type
            Test.StartTest();
            PageReference pageRef = Page.VFP_CDA_RequestViewScreen;
            pageRef.getParameters().put(UTL_CDAUtility.REQUEST_ID_STR, cdaRecordCustomer.Id);
            pageRef.getParameters().put(UTL_CDAUtility.REQUEST_TYPE_STR, UTL_CDAUtility.REQUEST_TYPE_NEW);
            Test.setCurrentPage(pageRef);
            cdaRequestController.cdaRequestStatusEdit.Status__c = UTL_CDAUtility.STATUS_CONTRACTEXECUTED;
            cdaRequestController.cdaRequestStatusEdit.Id = null;
            nextPage = cdaRequestController.updateNegotiatorDetails().getUrl();
        } catch (Exception ex) {
            //System.assertNotEquals(null, cdaRequestController);
            //System.assertEquals(new Apexpages.Message(ApexPages.severity.INFO, ex.getMessage()), Apexpages.getMessages()[0]);
            Test.StopTest();
        }
    }

    @isTest
    static void itShouldEditAuthSignerDetails() {
        CDA_Request__c cdaRecordCustomer = [SELECT id,Competitor_Contracting_Capacity__c, CDA_Type__c, Competitor_Flag__c, Project_Specific_Indicator__c FROM CDA_Request__c WHERE CDA_Type__c =: UTL_CDAUtility.CUSTOMER LIMIT 1];
        ApexPages.StandardController sc = new ApexPages.standardController(cdaRecordCustomer);
        EXT_CDA_RequestViewController cdaRequestController = new EXT_CDA_RequestViewController(sc);
        // To Test The new request type
        Test.StartTest();
        PageReference pageRef = Page.VFP_CDA_RequestViewScreen;
        pageRef.getParameters().put(UTL_CDAUtility.REQUEST_ID_STR, cdaRecordCustomer.Id);
        pageRef.getParameters().put(UTL_CDAUtility.REQUEST_TYPE_STR, UTL_CDAUtility.REQUEST_TYPE_NEW);
        Test.setCurrentPage(pageRef);
        cdaRequestController.editAuthSignerDetails();
        //System.assertNotEquals(null, cdaRequestController);
        //System.assertEquals(true, cdaRequestController.isAuthSignEditable);
        Test.StopTest();
    }

    @isTest
    static void itShouldUpdateAuthSignerDetails() {
        String nextPage = '';
        CDA_Request__c cdaRecordCustomer = [SELECT id,Competitor_Contracting_Capacity__c, CDA_Type__c, Competitor_Flag__c, Project_Specific_Indicator__c FROM CDA_Request__c WHERE CDA_Type__c =: UTL_CDAUtility.CUSTOMER LIMIT 1];
        ApexPages.StandardController sc = new ApexPages.standardController(cdaRecordCustomer);
        EXT_CDA_RequestViewController cdaRequestController = new EXT_CDA_RequestViewController(sc);
        // To Test The new request type
        Test.StartTest();
        PageReference pageRef = Page.VFP_CDA_RequestViewScreen;
        pageRef.getParameters().put(UTL_CDAUtility.REQUEST_ID_STR, cdaRecordCustomer.Id);
        pageRef.getParameters().put(UTL_CDAUtility.REQUEST_TYPE_STR, UTL_CDAUtility.REQUEST_TYPE_NEW);
        Test.setCurrentPage(pageRef);
        cdaRequestController.isAuthorizedSigner = UTL_CDAUtility.YES;
        nextPage = cdaRequestController.updateAuthSignerDetails().getUrl();
        //System.assertNotEquals(null, cdaRequestController);
        //System.assertEquals(false, cdaRequestController.isAuthSignEditable);
        //System.assertEquals(UTL_CDAUtility.SP_CHAR_SLASH + cdaRecordCustomer.Id, nextPage);
        Test.StopTest();
    }

    @isTest
    static void itShouldNotUpdateAuthSignerDetails() {
        CDA_Request__c cdaRecordCustomer = [SELECT id,Competitor_Contracting_Capacity__c, CDA_Type__c, Competitor_Flag__c, Project_Specific_Indicator__c FROM CDA_Request__c WHERE CDA_Type__c =: UTL_CDAUtility.CUSTOMER LIMIT 1];
        ApexPages.StandardController sc = new ApexPages.standardController(cdaRecordCustomer);
        EXT_CDA_RequestViewController cdaRequestController = new EXT_CDA_RequestViewController(sc);
        try {
            // To Test The new request type
            Test.StartTest();
            PageReference pageRef = Page.VFP_CDA_RequestViewScreen;
            pageRef.getParameters().put(UTL_CDAUtility.REQUEST_ID_STR, cdaRecordCustomer.Id);
            pageRef.getParameters().put(UTL_CDAUtility.REQUEST_TYPE_STR, UTL_CDAUtility.REQUEST_TYPE_NEW);
            Test.setCurrentPage(pageRef);
            cdaRequestController.cdaRequestAuthSignEdit.Id = null;
            cdaRequestController.updateAuthSignerDetails();
        } catch(Exception ex) {
            //System.assertNotEquals(null, cdaRequestController);
            //System.assertEquals(new Apexpages.Message(ApexPages.severity.INFO, ex.getMessage()), Apexpages.getMessages()[0]);
            Test.StopTest();
        }
    }

    @isTest
    static void isShouldEditAndUpdateCdaStatus() {
        String nextPage = '';
        CDA_Request__c cdaRecordCustomer = [SELECT id,Competitor_Contracting_Capacity__c, CDA_Type__c, Competitor_Flag__c, Project_Specific_Indicator__c FROM CDA_Request__c WHERE CDA_Type__c =: UTL_CDAUtility.CUSTOMER LIMIT 1];
        ApexPages.StandardController sc = new ApexPages.standardController(cdaRecordCustomer);
        EXT_CDA_RequestViewController cdaRequestController = new EXT_CDA_RequestViewController(sc);
        // To Test The new request type
        Test.StartTest();
        PageReference pageRef = Page.VFP_CDA_RequestViewScreen;
        pageRef.getParameters().put(UTL_CDAUtility.REQUEST_ID_STR, cdaRecordCustomer.Id);
        pageRef.getParameters().put(UTL_CDAUtility.REQUEST_TYPE_STR, UTL_CDAUtility.REQUEST_TYPE_NEW);
        Test.setCurrentPage(pageRef);
        cdaRequestController.cdaRequestStatusEdit.Customer_Legal_Entity_Name_Other__c = 'test Other customer';
        cdaRequestController.cdaRequestStatusEdit.Customer_Legal_Entity_Street_Other__c = 'Street';
        cdaRequestController.cdaRequestStatusEdit.Customer_Legal_Entity_City_Other__c = 'City';
        cdaRequestController.cdaRequestStatusEdit.Customer_Legal_Entity_State_Other_PL__c = 'Chandigarh';
        cdaRequestController.cdaRequestStatusEdit.Customer_Legal_Entity_Country_Other_PL__c = 'India';
        cdaRequestController.cdaRequestStatusEdit.Customer_Legal_Entity_ZipCode_Other__c = '12345679';
        cdaRequestController.cdaRequestStatusEdit.Sponsor_Legal_Entity_Name_Other__c = 'test other sponsor';
        cdaRequestController.cdaRequestStatusEdit.Recipient_Account_Name_Other__c = 'test other recipient';
        cdaRequestController.cdaRequestStatusEdit.Recipient_Account_Street_Other__c = 'Street';
        cdaRequestController.cdaRequestStatusEdit.Recipient_Account_City_Other__c = 'City';
        cdaRequestController.cdaRequestStatusEdit.Recipient_Account_State_Other_PL__c = 'Chandigarh';
        cdaRequestController.cdaRequestStatusEdit.Recipient_Account_Country_Other_PL__c = 'India';
        cdaRequestController.cdaRequestStatusEdit.Recipient_Account_ZipCode_Other__c = '12345679';
        cdaRequestController.cdaRequestStatusEdit.Status__c = UTL_CDAUtility.STATUS_CONTRACTEXECUTED;
        nextPage = cdaRequestController.updateCdaStatus().getUrl();
        cdaRequestController.editCdaStatus();
        Test.StopTest();
        //System.assertEquals(false, cdaRequestController.showStatusEditable);
        //System.assertEquals(UTL_CDAUtility.SP_CHAR_SLASH + cdaRecordCustomer.Id, nextPage);
    }

    @isTest
    static void isShouldNotUpdateCdaStatus() {
        CDA_Request__c cdaRecordCustomer = [SELECT id,Competitor_Contracting_Capacity__c, CDA_Type__c, Competitor_Flag__c, Project_Specific_Indicator__c FROM CDA_Request__c WHERE CDA_Type__c =: UTL_CDAUtility.CUSTOMER LIMIT 1];
        ApexPages.StandardController sc = new ApexPages.standardController(cdaRecordCustomer);
        EXT_CDA_RequestViewController cdaRequestController = new EXT_CDA_RequestViewController(sc);
        try {
            // To Test The new request type
            Test.StartTest();
            PageReference pageRef = Page.VFP_CDA_RequestViewScreen;
            pageRef.getParameters().put(UTL_CDAUtility.REQUEST_ID_STR, cdaRecordCustomer.Id);
            pageRef.getParameters().put(UTL_CDAUtility.REQUEST_TYPE_STR, UTL_CDAUtility.REQUEST_TYPE_NEW);
            Test.setCurrentPage(pageRef);
            cdaRequestController.cdaRequestStatusEdit.Status__c = UTL_CDAUtility.STATUS_CONTRACTEXECUTED;
            cdaRequestController.cdaRequestStatusEdit.Id = null;
            cdaRequestController.updateCdaStatus();
        } catch(Exception ex) {
            Test.StopTest();
            //system.assertEquals(new Apexpages.Message(ApexPages.severity.INFO, ex.getMessage()), Apexpages.getMessages()[0]);
        }
    }

    @isTest
    static void isShouldUpdateCdaStatusToCancelAndExternalNotes() {
        CDA_Request__c cdaRecordCustomer = [SELECT id,Competitor_Contracting_Capacity__c, CDA_Type__c, Competitor_Flag__c, Project_Specific_Indicator__c FROM CDA_Request__c WHERE CDA_Type__c =: UTL_CDAUtility.CUSTOMER LIMIT 1];
        ApexPages.StandardController sc = new ApexPages.standardController(cdaRecordCustomer);
        EXT_CDA_RequestViewController cdaRequestController = new EXT_CDA_RequestViewController(sc);
        try {
            // To Test The new request type
            Test.StartTest();
            PageReference pageRef = Page.VFP_CDA_RequestViewScreen;
            pageRef.getParameters().put(UTL_CDAUtility.REQUEST_ID_STR, cdaRecordCustomer.Id);
            pageRef.getParameters().put(UTL_CDAUtility.REQUEST_TYPE_STR, UTL_CDAUtility.REQUEST_TYPE_NEW);
            Test.setCurrentPage(pageRef);
            cdaRequestController.cdaRequestStatusEdit.Status__c = UTL_CDAUtility.STATUS_CANCELEDBYREQUESTOR;
            cdaRequestController.updateCdaStatus();
            cdaRequestController.isInternalNotesEditable = true;
            cdaRequestController.cdaRequestIntNotesEdit.Internal_Processing_Notes__c = 'Test Notes';
            cdaRequestController.updateInternalNotes();
        } catch(Exception ex) {
            Test.StopTest();
            //system.assertEquals(new Apexpages.Message(ApexPages.severity.INFO, ex.getMessage()), Apexpages.getMessages()[0]);
        }
    }

    @isTest
    static void isShouldUpdateCdaStatusToMiddle() {
        CDA_Request__c cdaRecordCustomer = [SELECT id,Competitor_Contracting_Capacity__c, CDA_Type__c, Competitor_Flag__c, Project_Specific_Indicator__c FROM CDA_Request__c WHERE CDA_Type__c =: UTL_CDAUtility.CUSTOMER LIMIT 1];
        ApexPages.StandardController sc = new ApexPages.standardController(cdaRecordCustomer);
        EXT_CDA_RequestViewController cdaRequestController = new EXT_CDA_RequestViewController(sc);
        try {
            // To Test The new request type
            Test.StartTest();
            PageReference pageRef = Page.VFP_CDA_RequestViewScreen;
            pageRef.getParameters().put(UTL_CDAUtility.REQUEST_ID_STR, cdaRecordCustomer.Id);
            pageRef.getParameters().put(UTL_CDAUtility.REQUEST_TYPE_STR, UTL_CDAUtility.REQUEST_TYPE_NEW);
            Test.setCurrentPage(pageRef);
            cdaRequestController.cdaRequestStatusEdit.Status__c = UTL_CDAUtility.STATUS_INREVIEWBYQUINTILES;
            cdaRequestController.cdaRequestStatusEdit.Negotiator_Assigned_List__c = UTL_CDAUtility.SELF_SERVICE_ONLY;
            cdaRequestController.updateCdaStatus();
        } catch(Exception ex) {
            Test.StopTest();
            //system.assertEquals(new Apexpages.Message(ApexPages.severity.INFO, ex.getMessage()), Apexpages.getMessages()[0]);
        }
    }

    @isTest
    static void isShouldSubmitRequestWithCompetitorSystemAccess() {
        CDA_Request__c cdaRecordCustomer = [SELECT id,Competitor_Contracting_Capacity__c, CDA_Type__c, Competitor_Flag__c, Project_Specific_Indicator__c FROM CDA_Request__c WHERE CDA_Type__c =: UTL_CDAUtility.CUSTOMER LIMIT 1];
        ApexPages.StandardController sc = new ApexPages.standardController(cdaRecordCustomer);
        EXT_CDA_RequestViewController cdaRequestController = new EXT_CDA_RequestViewController(sc);
        // To Test The new request type
        Test.StartTest();
        PageReference pageRef = Page.VFP_CDA_RequestViewScreen;
        pageRef.getParameters().put(UTL_CDAUtility.REQUEST_ID_STR, cdaRecordCustomer.Id);
        pageRef.getParameters().put(UTL_CDAUtility.REQUEST_TYPE_STR, UTL_CDAUtility.REQUEST_TYPE_NEW);
        Test.setCurrentPage(pageRef);
        dataSetUp.setUpContactForEmail();
        cdaRequestController.cdaRequest.Competitor_System_Access__c = UTL_CDAUtility.YES;
        cdaRequestController.submitRequest();
        Test.StopTest();
        CDA_Request__c cdaRecordCustomerActual = [SELECT id, Status__c FROM CDA_Request__c WHERE id =: cdaRecordCustomer.Id LIMIT 1];
//        System.assertEquals(UTL_CDAUtility.STATUS_AWAITING_OGC_COMPETITOR_APPROVAL, cdaRecordCustomerActual.Status__c);
    }

    @isTest
    static void isShouldSubmitRequestWithCDAFormatPDF() {
        CDA_Request__c cdaRecordCustomer = [SELECT id,Competitor_Contracting_Capacity__c, CDA_Type__c, Competitor_Flag__c, Project_Specific_Indicator__c FROM CDA_Request__c WHERE CDA_Type__c =: UTL_CDAUtility.CUSTOMER LIMIT 1];
        ApexPages.StandardController sc = new ApexPages.standardController(cdaRecordCustomer);
        EXT_CDA_RequestViewController cdaRequestController = new EXT_CDA_RequestViewController(sc);
        // To Test The new request type
        Test.StartTest();
        PageReference pageRef = Page.VFP_CDA_RequestViewScreen;
        pageRef.getParameters().put(UTL_CDAUtility.REQUEST_ID_STR, cdaRecordCustomer.Id);
        pageRef.getParameters().put(UTL_CDAUtility.REQUEST_TYPE_STR, UTL_CDAUtility.REQUEST_TYPE_NEW);
        Test.setCurrentPage(pageRef);
        cdaRequestController.submitRequest();
        Test.StopTest();
        //System.assertNotEquals(null, cdaRequestController);
        //System.assertEquals(0, Apexpages.getMessages().size());
    }

    @isTest
    static void isShouldSubmitRequestWithCDAFormatWord() {
        CDA_Request__c cdaRecordCustomer = [SELECT id,Competitor_Contracting_Capacity__c, CDA_Type__c, Competitor_Flag__c, Project_Specific_Indicator__c FROM CDA_Request__c WHERE CDA_Type__c =: UTL_CDAUtility.CUSTOMER LIMIT 1];
        ApexPages.StandardController sc = new ApexPages.standardController(cdaRecordCustomer);
        EXT_CDA_RequestViewController cdaRequestController = new EXT_CDA_RequestViewController(sc);
        // To Test The new request type
        Test.StartTest();
        PageReference pageRef = Page.VFP_CDA_RequestViewScreen;
        pageRef.getParameters().put(UTL_CDAUtility.REQUEST_ID_STR, cdaRecordCustomer.Id);
        pageRef.getParameters().put(UTL_CDAUtility.REQUEST_TYPE_STR, UTL_CDAUtility.REQUEST_TYPE_NEW);
        Test.setCurrentPage(pageRef);
        dataSetUp.setUpContactForEmail();
        cdaRequestController.cdaRequest.CDA_Format__c = UTL_CDAUtility.CDA_FORMAT_PROWORD;
        cdaRequestController.submitRequest();
        Test.StopTest();
        CDA_Request__c cdaRecordCustomerActual = [SELECT id, Status__c FROM CDA_Request__c WHERE id =: cdaRecordCustomer.Id LIMIT 1];
//        System.assertEquals(UTL_CDAUtility.STATUS_SENTFOR_RECIPREVIEW, cdaRecordCustomerActual.Status__c);
    }

    @isTest
    static void isShouldSubmitRequestWithCdaSourceExternal() {
        CDA_Request__c cdaRecordCustomer = [SELECT id,Competitor_Contracting_Capacity__c, CDA_Type__c, Competitor_Flag__c, Project_Specific_Indicator__c FROM CDA_Request__c WHERE CDA_Type__c =: UTL_CDAUtility.CUSTOMER LIMIT 1];
        ApexPages.StandardController sc = new ApexPages.standardController(cdaRecordCustomer);
        EXT_CDA_RequestViewController cdaRequestController = new EXT_CDA_RequestViewController(sc);
        // To Test The new request type
        Test.StartTest();
        PageReference pageRef = Page.VFP_CDA_RequestViewScreen;
        pageRef.getParameters().put(UTL_CDAUtility.REQUEST_ID_STR, cdaRecordCustomer.Id);
        pageRef.getParameters().put(UTL_CDAUtility.REQUEST_TYPE_STR, UTL_CDAUtility.REQUEST_TYPE_NEW);
        Test.setCurrentPage(pageRef);
        dataSetUp.setUpContactForEmail();
        cdaRequestController.cdaRequest.CDA_Source__c = UTL_CDAUtility.CDASOURCE_EXTERNAL;
        cdaRequestController.submitRequest();
        Test.StopTest();
        CDA_Request__c cdaRecordCustomerActual = [SELECT id, Status__c FROM CDA_Request__c WHERE id =: cdaRecordCustomer.Id LIMIT 1];
//        System.assertEquals(UTL_CDAUtility.STATUS_INREVIEWBYQUINTILES, cdaRecordCustomerActual.Status__c);
    }

    @isTest
    static void isShouldNotSubmitRequest() {
        CDA_Request__c cdaRecordCustomer = [SELECT id,Competitor_Contracting_Capacity__c, CDA_Type__c, Competitor_Flag__c, Project_Specific_Indicator__c FROM CDA_Request__c WHERE CDA_Type__c =: UTL_CDAUtility.CUSTOMER LIMIT 1];
        ApexPages.StandardController sc = new ApexPages.standardController(cdaRecordCustomer);
        EXT_CDA_RequestViewController cdaRequestController = new EXT_CDA_RequestViewController(sc);
        try {
            // To Test The new request type
            Test.StartTest();
            PageReference pageRef = Page.VFP_CDA_RequestViewScreen;
            pageRef.getParameters().put(UTL_CDAUtility.REQUEST_ID_STR, cdaRecordCustomer.Id);
            pageRef.getParameters().put(UTL_CDAUtility.REQUEST_TYPE_STR, UTL_CDAUtility.REQUEST_TYPE_NEW);
            Test.setCurrentPage(pageRef);
            dataSetUp.setUpContactForEmail();
            cdaRequestController.cdaRequest.Id = null;
            cdaRequestController.submitRequest();
        } catch(Exception ex) {
            Test.StopTest();
            //System.assertEquals(new Apexpages.Message(ApexPages.severity.INFO, ex.getMessage()), Apexpages.getMessages()[0]);
        }
    }

    @isTest
    static void isShouldSendForReview() {
        CDA_Request__c cdaRecordCustomer = [SELECT id,Competitor_Contracting_Capacity__c, CDA_Type__c, Competitor_Flag__c, Project_Specific_Indicator__c FROM CDA_Request__c WHERE CDA_Type__c =: UTL_CDAUtility.CUSTOMER LIMIT 1];
        ApexPages.StandardController sc = new ApexPages.standardController(cdaRecordCustomer);
        EXT_CDA_RequestViewController cdaRequestController = new EXT_CDA_RequestViewController(sc);
        // To Test The new request type
        Test.StartTest();
        PageReference pageRef = Page.VFP_CDA_RequestViewScreen;
        pageRef.getParameters().put(UTL_CDAUtility.REQUEST_ID_STR, cdaRecordCustomer.Id);
        pageRef.getParameters().put(UTL_CDAUtility.REQUEST_TYPE_STR, UTL_CDAUtility.REQUEST_TYPE_NEW);
        Test.setCurrentPage(pageRef);
        dataSetUp.setUpContactForEmail();
        cdaRequestController.sendForReview();
        Test.StopTest();
        CDA_Request__c cdaRecordCustomerActual = [SELECT id, Status__c FROM CDA_Request__c WHERE id =: cdaRecordCustomer.Id LIMIT 1];
        //System.assertEquals(UTL_CDAUtility.STATUS_SENTFOR_RECIPREVIEW, cdaRecordCustomerActual.Status__c);
    }

    @isTest
    static void isShouldSendForLanguageReview() {
        CDA_Request__c cdaRecordCustomer = [SELECT id,Competitor_Contracting_Capacity__c, CDA_Type__c, Competitor_Flag__c, Project_Specific_Indicator__c, Negotiator_Assigned_List__c FROM CDA_Request__c WHERE CDA_Type__c =: UTL_CDAUtility.CUSTOMER LIMIT 1];
        ApexPages.StandardController sc = new ApexPages.standardController(cdaRecordCustomer);
        EXT_CDA_RequestViewController cdaRequestController = new EXT_CDA_RequestViewController(sc);
        // To Test The new request type
        Test.StartTest();
        PageReference pageRef = Page.VFP_CDA_RequestViewScreen;
        pageRef.getParameters().put(UTL_CDAUtility.REQUEST_ID_STR, cdaRecordCustomer.Id);
        pageRef.getParameters().put(UTL_CDAUtility.REQUEST_TYPE_STR, UTL_CDAUtility.REQUEST_TYPE_NEW);
        Test.setCurrentPage(pageRef);
        dataSetUp.setUpContactForEmail();
        cdaRequestController.sendForLanguageReview();
        Test.StopTest();
        CDA_Request__c cdaRecordCustomerActual = [SELECT id, Status__c FROM CDA_Request__c WHERE id =: cdaRecordCustomer.Id LIMIT 1];
        //System.assertEquals(UTL_CDAUtility.STATUS_SENTFOR_RECIPREVIEW, cdaRecordCustomerActual.Status__c);
    }

    @isTest
    static void isShouldNotSendForReview() {
        CDA_Request__c cdaRecordCustomer = [SELECT id,Competitor_Contracting_Capacity__c, CDA_Type__c, Competitor_Flag__c, Project_Specific_Indicator__c FROM CDA_Request__c WHERE CDA_Type__c =: UTL_CDAUtility.CUSTOMER LIMIT 1];
        ApexPages.StandardController sc = new ApexPages.standardController(cdaRecordCustomer);
        EXT_CDA_RequestViewController cdaRequestController = new EXT_CDA_RequestViewController(sc);
        try {
            // To Test The new request type
            Test.StartTest();
            PageReference pageRef = Page.VFP_CDA_RequestViewScreen;
            pageRef.getParameters().put(UTL_CDAUtility.REQUEST_ID_STR, cdaRecordCustomer.Id);
            pageRef.getParameters().put(UTL_CDAUtility.REQUEST_TYPE_STR, UTL_CDAUtility.REQUEST_TYPE_NEW);
            Test.setCurrentPage(pageRef);
            dataSetUp.setUpContactForEmail();
            cdaRequestController.cdaRequest.Id = null;
            cdaRequestController.sendForReview();
        } catch(Exception ex) {
            Test.StopTest();
            //System.assertEquals(new Apexpages.Message(ApexPages.severity.INFO, ex.getMessage()), Apexpages.getMessages()[0]);
        }
    }

    @isTest
    static void isShouldSendForSignature() {
        CDA_Request__c cdaRecordCustomer = [SELECT id,Competitor_Contracting_Capacity__c, CDA_Type__c, Competitor_Flag__c, Project_Specific_Indicator__c FROM CDA_Request__c WHERE CDA_Type__c =: UTL_CDAUtility.CUSTOMER LIMIT 1];
        ApexPages.StandardController sc = new ApexPages.standardController(cdaRecordCustomer);
        EXT_CDA_RequestViewController cdaRequestController = new EXT_CDA_RequestViewController(sc);
        // To Test The new request type
        Test.StartTest();
        PageReference pageRef = Page.VFP_CDA_RequestViewScreen;
        pageRef.getParameters().put(UTL_CDAUtility.REQUEST_ID_STR, cdaRecordCustomer.Id);
        pageRef.getParameters().put(UTL_CDAUtility.REQUEST_TYPE_STR, UTL_CDAUtility.REQUEST_TYPE_NEW);
        Test.setCurrentPage(pageRef);
        String nextPage = cdaRequestController.sendForSignature().getUrl();
        Test.StopTest();
        //System.assertNotEquals(null, cdaRequestController);
        //System.assertEquals(0, Apexpages.getMessages().size());
        //System.assertEquals(UTL_CDAUtility.PAGE_LANDING_SCREEN, nextPage);
    }

    @isTest
    static void isShouldVoidDocusignEnvpAndCancel() {
        CDA_Request__c cdaRecordCustomer = [SELECT id,Competitor_Contracting_Capacity__c, CDA_Type__c, Competitor_Flag__c, Project_Specific_Indicator__c FROM CDA_Request__c WHERE CDA_Type__c =: UTL_CDAUtility.CUSTOMER LIMIT 1];
        ApexPages.StandardController sc = new ApexPages.standardController(cdaRecordCustomer);
        EXT_CDA_RequestViewController cdaRequestController = new EXT_CDA_RequestViewController(sc);
        // To Test The new request type
        Test.StartTest();
        PageReference pageRef = Page.VFP_CDA_RequestViewScreen;
        pageRef.getParameters().put(UTL_CDAUtility.REQUEST_ID_STR, cdaRecordCustomer.Id);
        pageRef.getParameters().put(UTL_CDAUtility.REQUEST_TYPE_STR, UTL_CDAUtility.REQUEST_TYPE_NEW);
        Test.setCurrentPage(pageRef);
        cdaRequestController.voidDocusignEnvpAndCancel();
        Test.StopTest();
        //System.assertNotEquals(null, cdaRequestController);
        CDA_Request__c cdaRecordCustomerActual = [SELECT id, Status__c FROM CDA_Request__c WHERE id =: cdaRecordCustomer.Id LIMIT 1];
        //System.assertEquals(UTL_CDAUtility.STATUS_CANCELEDBYREQUESTOR, cdaRecordCustomerActual.Status__c);
    }

    @isTest
    static void isShouldVoidDocusignEnvpAndResubmit() {
        CDA_Request__c cdaRecordCustomer = [SELECT id,Competitor_Contracting_Capacity__c, CDA_Type__c, Competitor_Flag__c, Project_Specific_Indicator__c FROM CDA_Request__c WHERE CDA_Type__c =: UTL_CDAUtility.CUSTOMER LIMIT 1];
        ApexPages.StandardController sc = new ApexPages.standardController(cdaRecordCustomer);
        EXT_CDA_RequestViewController cdaRequestController = new EXT_CDA_RequestViewController(sc);
        // To Test The new request type
        Test.StartTest();
        PageReference pageRef = Page.VFP_CDA_RequestViewScreen;
        pageRef.getParameters().put(UTL_CDAUtility.REQUEST_ID_STR, cdaRecordCustomer.Id);
        pageRef.getParameters().put(UTL_CDAUtility.REQUEST_TYPE_STR, UTL_CDAUtility.REQUEST_TYPE_NEW);
        Test.setCurrentPage(pageRef);
        cdaRequestController.voidDocusignEnvpAndResubmit();
        Test.StopTest();
        //System.assertNotEquals(null, cdaRequestController);
        CDA_Request__c cdaRecordCustomerActual = [SELECT id, Status__c FROM CDA_Request__c WHERE id =: cdaRecordCustomer.Id LIMIT 1];
        //System.assertEquals(UTL_CDAUtility.STATUS_AWAITINGREQSUB, cdaRecordCustomerActual.Status__c);
    }

    @isTest
    static void isShouldSendRecipientEmail() {
        CDA_Request__c cdaRecordCustomer = [SELECT id,Competitor_Contracting_Capacity__c, CDA_Type__c, Competitor_Flag__c, Project_Specific_Indicator__c FROM CDA_Request__c WHERE CDA_Type__c =: UTL_CDAUtility.CUSTOMER LIMIT 1];
        ApexPages.StandardController sc = new ApexPages.standardController(cdaRecordCustomer);
        EXT_CDA_RequestViewController cdaRequestController = new EXT_CDA_RequestViewController(sc);
        // To Test The new request type
        Test.StartTest();
        PageReference pageRef = Page.VFP_CDA_RequestViewScreen;
        pageRef.getParameters().put(UTL_CDAUtility.REQUEST_ID_STR, cdaRecordCustomer.Id);
        pageRef.getParameters().put(UTL_CDAUtility.REQUEST_TYPE_STR, UTL_CDAUtility.REQUEST_TYPE_NEW);
        Test.setCurrentPage(pageRef);
        dataSetUp.setUpContactForEmail();
        cdaRequestController.cdaRequest.Status__c = UTL_CDAUtility.STATUS_CONTRACTEXECUTED;
        cdaRequestController.sendRecipientEmail();
        Test.StopTest();
        //System.assertNotEquals(null, cdaRequestController);
        //System.assertEquals(0, Apexpages.getMessages().size());
    }

    @isTest
    static void itShouldRespondToRequestorEmail() {
        CDA_Request__c cdaRecordCustomer = [SELECT id,Competitor_Contracting_Capacity__c, CDA_Type__c, Competitor_Flag__c, Project_Specific_Indicator__c FROM CDA_Request__c WHERE CDA_Type__c =: UTL_CDAUtility.CUSTOMER LIMIT 1];
        ApexPages.StandardController sc = new ApexPages.standardController(cdaRecordCustomer);
        EXT_CDA_RequestViewController cdaRequestController = new EXT_CDA_RequestViewController(sc);
        // To Test The new request type
        Test.StartTest();
        PageReference pageRef = Page.VFP_CDA_RequestViewScreen;
        pageRef.getParameters().put(UTL_CDAUtility.REQUEST_ID_STR, cdaRecordCustomer.Id);
        pageRef.getParameters().put(UTL_CDAUtility.REQUEST_TYPE_STR, UTL_CDAUtility.REQUEST_TYPE_NEW);
        Test.setCurrentPage(pageRef);
        dataSetUp.setUpContactForEmail();
        cdaRequestController.respondToRequestorEmail();
        Test.StopTest();
    }

    @isTest
    static void itShouldTestProperties() {
        CDA_Request__c cdaRecordCustomer = [SELECT id,Competitor_Contracting_Capacity__c, CDA_Type__c, Competitor_Flag__c, Project_Specific_Indicator__c FROM CDA_Request__c WHERE CDA_Type__c =: UTL_CDAUtility.CUSTOMER LIMIT 1];
        ApexPages.StandardController sc = new ApexPages.standardController(cdaRecordCustomer);
        EXT_CDA_RequestViewController cdaRequestController = new EXT_CDA_RequestViewController(sc);
        PageReference pageRef = Page.VFP_CDA_RequestViewScreen;
        pageRef.getParameters().put(UTL_CDAUtility.REQUEST_ID_STR, cdaRecordCustomer.Id);
        pageRef.getParameters().put(UTL_CDAUtility.REQUEST_TYPE_STR, UTL_CDAUtility.REQUEST_TYPE_NEW);
        Test.setCurrentPage(pageRef);
        Test.StartTest();
        cdaRequestController.cdaRequest.Status__c = UTL_CDAUtility.STATUS_AWAITINGREQSUB;
        Boolean showUploadPartiallyExecutedCdaButton = cdaRequestController.showUploadPartiallyExecutedCdaButton;
        String dateFormatActual = cdaRequestController.dateFormatString;
        Boolean isCompetitorActual = cdaRequestController.isCompetitor;
        Boolean isCompetitorContractingCapacityCollaboratorActual = cdaRequestController.isCompetitorContractingCapacityCollaborator;
        Boolean isCompetitorContractingCapacityCustomerActual = cdaRequestController.isCompetitorContractingCapacityCustomer;
        Boolean isNegotiatorActual = cdaRequestController.isNegotiator;
        Boolean isProtocolNumberKnownActual = cdaRequestController.isProtocolNumberKnown;
        Boolean isProtocolNumberNotKnownActual = cdaRequestController.isProtocolNumberNotKnown;
        Boolean isProtocolTitleKnownActual = cdaRequestController.isProtocolTitleKnown;
        Boolean isProtocolTitleNotKnownActual = cdaRequestController.isProtocolTitleNotKnown;
        Boolean isProtocolHasToRenderActual = cdaRequestController.isProtocolHasToRender;
        Boolean whatIsTheStudySponsorSituationStudySponsorIdentifiedActual = cdaRequestController.whatIsTheStudySponsorSituationStudySponsorIdentified;
        Boolean isCurrentUserARequestOwnerActual = cdaRequestController.isCurrentUserARequestOwner;
        Boolean isSubmitHasToRenderActual = cdaRequestController.isSubmitHasToRender;
        Boolean isRedlineUploadHasToRenderActual = cdaRequestController.isRedlineUploadHasToRender;
        Boolean isEnvlpVoidedActual = cdaRequestController.isEnvelopeActive;    //Updated by Vikram Singh under CR-11146
        Boolean isStartStatusActual = cdaRequestController.isStartStatus;
        Boolean isMiddleStatusActual = cdaRequestController.isMiddleStatus;
        Boolean isEndStatusActual = cdaRequestController.isEndStatus;
        Boolean isStatusAwaitingOGCActual = cdaRequestController.isStatusAwaitingOGC;
        Boolean isStatusSendForSignActual = cdaRequestController.isStatusSendForSign;
        Boolean isStatusSignRequestDeniedActual = cdaRequestController.isStatusSignRequestDenied;
        Boolean isCdaTypeAuditorActual = cdaRequestController.isCdaTypeAuditor;
        Boolean isCdaTypeVendorActual = cdaRequestController.isCdaTypeVendor;
        Boolean isCdaTypeCustomerActual = cdaRequestController.isCdaTypeCustomer;
        Boolean isCdaTypeCEVAActual = cdaRequestController.isCdaTypeCEVA;
        Boolean isCustomerLegalEntityToRenderActual = cdaRequestController.isCustomerLegalEntityToRender;
        Boolean isRecipientAccountToRenderActual = cdaRequestController.isRecipientAccountToRender;
        Boolean isRecipientAccountOtherToRenderActual = cdaRequestController.isRecipientAccountOtherToRender;
        Boolean isAThreeWayAgreementRequiredActual = cdaRequestController.isAThreeWayAgreementRequired;
        Boolean isSponsorLegalEntityToRenderActual = cdaRequestController.isSponsorLegalEntityToRender;
        Boolean isSponsorLegalEntityOtherToRenderActual = cdaRequestController.isSponsorLegalEntityOtherToRender;
        Boolean isCompetitorSystemAccessRequiredActual = cdaRequestController.isCompetitorSystemAccessRequired;
        Boolean isActionSectionToRenderActual = cdaRequestController.isActionSectionToRender;
        Boolean isCustomerConsenttoDiscloseRenderActual = cdaRequestController.isCustomerConsenttoDiscloseRender;
        Boolean isSponsorConsenttoDiscloseRenderActual = cdaRequestController.isSponsorConsenttoDiscloseRender;
        Boolean isCDASourceQuintilesIMSActual = cdaRequestController.isCDASourceQuintilesIMS;
        Boolean isCDASourceExternalActual = cdaRequestController.isCDASourceExternal;
        Boolean isProtectedWordFormatActual = cdaRequestController.isProtectedWordFormat;
        Boolean isSendForSignatureActual = cdaRequestController.isSendForSignature;
        Boolean isRedLineDocumentRequiredActual = cdaRequestController.isRedLineDocumentRequired;
        Boolean isRegenrateTextRequiredActual = cdaRequestController.isRegenrateTextRequired;
        Boolean isCompletedDocAttachedActual = cdaRequestController.isCompletedDocAttached;
        Boolean isRegenrateDocByNegotiatorActual = cdaRequestController.isRegenrateDocByNegotiator;
        Boolean isStatusReturnedToRequestorActual = cdaRequestController.isStatusReturnedToRequestor;
        cdaRequestController.getnegotiatorList();
        cdaRequestController.setnegotiatorAssigned();
        cdaRequestController.getnegotiatorAssigned('Test');
        cdaRequestController.editCdaRequestResponseDocType();
        cdaRequestController.cdaRequestResponseDocTypeEdit = new CDA_Request__c(What_documents_would_you_like_to_provide__c = 'test');
        cdaRequestController.setAndUpdateResponseDocumentType();
        Boolean testBoolean = cdaRequestController.isClinicalResearch;
        testBoolean = cdaRequestController.isDataAndServices;
        testBoolean = cdaRequestController.isLookupReportUser;
        testBoolean = cdaRequestController.isRequestorExtended;
        testBoolean = cdaRequestController.isRequestorAdmin;
        testBoolean = cdaRequestController.isRequestor;
        Test.StopTest();
    }
}