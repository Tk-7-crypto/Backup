@isTest
private class TST_CNT_TPA_SelectTemplate {
    static testMethod void myUnitTest() {
    	Address__c testAccount1 = UTL_TPA_SetupTestData.getAccount();
        testAccount1.Name = 'Test Acc';
        insert testAccount1;

    	TPA_Request__c tpaRequest1 = UTL_TPA_SetupTestData.getTestTPARequest();
        tpaRequest1.OwnerId = UserInfo.getUserId();
        tpaRequest1.Service_Provider_Address__c = testAccount1.Id;
        tpaRequest1.Client_Address__c = testAccount1.Id;
        tpaRequest1.Client_Language__c = 'Japanese';
        tpaRequest1.Vendor_Language__c = 'Japanese';
        tpaRequest1.Vendor_Billing_Mailing_Country__c = 'united states';
        tpaRequest1.Request_Status__c = 'Expired';
        tpaRequest1.Data_Access_End_Date__c = Date.today().addDays(-1);
        tpaRequest1.Is_Potential_Vendor_Case__c = false;
        insert tpaRequest1;
        
        UTL_TPA_SetupTestData.createTpaRequestATC(tpaRequest1);
        IMS_Master_Legal_Entity__c imsMasterLegalEntity =  UTL_TPA_SetupTestData.getImsMasterLegalEntity();
        IMS_Legal_Entity__c imsLegalEntity = UTL_TPA_SetupTestData.getImsLegalEntity(tpaRequest1, imsMasterLegalEntity);

        IMS_TPA_Purpose__c imsTpaPurpose1 = UTL_TPA_SetupTestData.createImsTPAPurposeData('United States', 'test name');
        imsTpaPurpose1.Purpose_Details__c = 'test detail';
        imsTpaPurpose1.Is_Active__c = true;
        update imsTpaPurpose1;

        IMS_TPA_Purpose__c imsTpaPurpose2 = UTL_TPA_SetupTestData.createImsTPAPurposeData('United States', 'test name2');
        imsTpaPurpose2.Purpose_Details__c = 'test detail2';
        imsTpaPurpose2.Is_Active__c = true;
        update imsTpaPurpose2;

        TPA_Purpose_Category__c tpaPurposeCategory = UTL_TPA_SetupTestData.createTpaPurposeCategory('Expert Analysis');

        TPA_Purpose__c tpaPurpose1 = UTL_TPA_SetupTestData.createTpaPurposeByReqId(tpaRequest1);
        tpaPurpose1.TPA_Purpose_Category__c = tpaPurposeCategory.Id;
        tpaPurpose1.Request__c = tpaRequest1.Id;
        tpaPurpose1.Name = 'Test TPA Purpose';
        tpaPurpose1.BU__c = 'United States';
        insert tpaPurpose1;

        TPA_Purpose__c tpaPurpose2 = UTL_TPA_SetupTestData.createTpaPurposeByReqId(tpaRequest1);
        tpaPurpose2.TPA_Purpose_Category__c = tpaPurposeCategory.Id;
        tpaPurpose2.Name = 'Other';
        tpaPurpose2.BU__c = 'United States';
        insert tpaPurpose2;

        IMS_Data_Asset__c imsDataAsset = UTL_TPA_SetupTestData.createImsDataAsset_Template();
        insert imsDataAsset;

        TPA_Data_Asset__c tpaDataAsset1 = UTL_TPA_SetupTestData.getTpaDataAsset(tpaPurpose1.Id);
        tpaDataAsset1.Request__c = tpaRequest1.id;
        tpaDataAsset1.Data_Asset__c = imsDataAsset.id;
        tpaDataAsset1.BU__c = 'United States';
        tpaDataAsset1.Geo_Level__c = 'Sub-National';
        tpaDataAsset1.Asset_NametText__c = 'MIDAS';
        insert tpaDataAsset1;

        TPA_Data_Asset__c tpaDataAsset2 = UTL_TPA_SetupTestData.getTpaDataAsset(tpaPurpose2.Id);
        tpaDataAsset2.Request__c = tpaRequest1.id;
        tpaDataAsset2.Data_Asset__c = imsDataAsset.id;
        tpaDataAsset2.BU__c = 'United States';
        tpaDataAsset2.Geo_Level__c = 'Sub-National';
        tpaDataAsset2.Asset_NametText__c = 'MIDAS';
        insert tpaDataAsset2;

        IMS_Secondary_Data_Asset__c imsSecondaryDataAsset = UTL_TPA_SetupTestData.getImsSecDataAsset();
        imsSecondaryDataAsset.Primary_Data_Asset__c = imsDataAsset.id;
        imsSecondaryDataAsset.additional_terms_required__c = true;
        insert imsSecondaryDataAsset;

        TPA_Secondary_Data_Asset__c tpaSecondaryDataAsset1 = UTL_TPA_SetupTestData.getTpaSecDataAsset();
        tpaSecondaryDataAsset1.TPA_Data_Asset__c = tpaDataAsset1.id;
        tpaSecondaryDataAsset1.IMS_Secondary_Data_Asset__c = imsSecondaryDataAsset.id;
        insert tpaSecondaryDataAsset1;

        TPA_Secondary_Data_Asset__c tpaSecondaryDataAsset2 = UTL_TPA_SetupTestData.getTpaSecDataAsset();
        tpaSecondaryDataAsset2.TPA_Data_Asset__c = tpaDataAsset2.id;
        tpaSecondaryDataAsset2.IMS_Secondary_Data_Asset__c = imsSecondaryDataAsset.id;
        insert tpaSecondaryDataAsset2;

        IMS_TPA_Purpose_Category__c imsTpaPurposeCategory1 = UTL_TPA_SetupTestData.createImsTpaPurposeCategory(imsTpaPurpose1, tpaPurposeCategory);
        insert imsTpaPurposeCategory1;

        IMS_TPA_Purpose_Category__c imsTpaPurposeCategory2 = UTL_TPA_SetupTestData.createImsTpaPurposeCategory(imsTpaPurpose2, tpaPurposeCategory);
        insert imsTpaPurposeCategory2;

        IMS_TPA_Purpose_Description__c imsTpaPurposeDescription1 = UTL_TPA_SetupTestData.createImsTpaPurposeDescription(imsTpaPurpose1, tpaPurposeCategory);
        insert imsTpaPurposeDescription1;

        IMS_TPA_Purpose_Description__c imsTpaPurposeDescription2 = UTL_TPA_SetupTestData.createImsTpaPurposeDescription(imsTpaPurpose2, tpaPurposeCategory);
        insert imsTpaPurposeDescription2;

        TPA_Purpose_Description__c tpaPurposeDescription1 = UTL_TPA_SetupTestData.createTpaPurposeDescription(tpaPurpose1, imsTpaPurposeDescription1);
        tpaPurposeDescription1.Other_Details__c = 'Test Other details';
        tpaPurposeDescription1.Description_Text__c = 'Test Desc Text';
        insert tpaPurposeDescription1;

        TPA_Purpose_Description__c tpaPurposeDescription2 = UTL_TPA_SetupTestData.createTpaPurposeDescription(tpaPurpose2, imsTpaPurposeDescription2);
        tpaPurposeDescription2.Other_Details__c = 'Test Other details2';
        tpaPurposeDescription2.Description_Text__c = 'Test Desc Text2';
        insert tpaPurposeDescription2;
        
        Apttus__APTS_Template__c template = new Apttus__APTS_Template__c();
        template.Name = 'Test Template';
        template.Apttus__Guidance__c = 'Test Template Guidance';
        template.Apttus__Category__c = 'Test Template Category';
        template.Apttus__Subcategory__c = 'Test Template Subcategory';
        template.Apttus__Type__c = 'Test';
        template.Apttus__Keywords__c = 'TEST';
        insert template;
        
        PageReference pageRef = Page.VFP_TPA_ReportingServices;
		Test.setCurrentPage(pageRef);
		ApexPages.currentPage().getParameters().put('templateType','Test');
		ApexPages.currentPage().getParameters().put('templateKeyword', 'TEST');
        ApexPages.currentPage().getParameters().put('id', tpaRequest1.Id);
        
		Test.startTest();
        CNT_TPA_SelectTemplate controller = new CNT_TPA_SelectTemplate();
        controller.initLightning();
        List<String> docList = controller.getDocFormatList;
        docList.add(controller.outputFormat);
        docList.add(controller.selectedTemplateId);
        CNT_TPA_SelectTemplate.requestDetails wraper = new CNT_TPA_SelectTemplate.requestDetails();
        wraper.templateId = template.Id;
        wraper.requestId = tpaRequest1.Id;
        wraper.docFormat = 'pdf';
        CNT_TPA_SelectTemplate.generateDocument(JSON.serialize(wraper));
        String strRes = controller.jsonlstTpaAdditionalTerm;
        Test.stopTest();
    }
}