/**
* @Author: Babita Dadarwal
* @Description: Test Class for TPA_Client_Request_ControllerListView class
*/
@isTest(SeeAllData=false)
private class TST_CNT_TPA_ListView {

    @TestSetup static void setup() {
        Date todayDate = Date.today();

        Address__c testAccount1 = UTL_TPA_SetupTestData.getAccount();
        testAccount1.Name = 'Test Acc';
        insert testAccount1;

        Address__c testAccount2 = UTL_TPA_SetupTestData.getAddress();
        testAccount2.Name = 'Test Account 2233333';
        testAccount2.Vendor_Registration_Number__c = 124;
        insert testAccount2;

        TPA_Request__c tpaRequest1 = UTL_TPA_SetupTestData.getTestTPARequest();
        tpaRequest1.OwnerId = UserInfo.getUserId();
        tpaRequest1.Service_Provider_Address__c = testAccount1.Id;
        tpaRequest1.Client_Address__c = testAccount1.Id;
        tpaRequest1.Client_Language__c = 'Japanese';
        tpaRequest1.Vendor_Language__c = 'Japanese';
        tpaRequest1.Vendor_Billing_Mailing_Country__c = 'united states';
        tpaRequest1.Request_Status__c = 'Expired';
        tpaRequest1.Data_Access_End_Date__c = todayDate.addDays(-1);
        tpaRequest1.Is_Potential_Vendor_Case__c = false;
        insert tpaRequest1;

        TPA_Contact__c tpaContact = UTL_TPA_SetupTestData.getTPAContactByReqId(tpaRequest1);
        tpaContact.Name = 'SubContractor Contact1';
        tpaContact.Type__c = 'SubContractor Contact';
        tpaContact.Company_Name__c = 'Test Company';
        tpaContact.Email__c = 'testcontact@apttus.com';
        tpaContact.Title__c = 'Test Manager';
        tpaContact.Phone__c = '408-123-5678';
        tpaContact.AddressLine1__c = '1400 Fashion Island Blvd';
        tpaContact.City__c = 'San Mateo';
        tpaContact.State__c = 'CA';
        tpaContact.ZipCode__c = '94404';
        update tpaContact;

        IMS_TPA_Purpose__c imsTpaPurpose = UTL_TPA_SetupTestData.createIMSTpaPurposeData('United States', 'test purpose');

        TPA_Purpose__c tpaPurpose = UTL_TPA_SetupTestData.createTpaPurposeByReqId(tpaRequest1);
        tpaPurpose.Purpose__c = imsTpaPurpose.Id;
        tpaPurpose.Region__c = 'US';
        insert tpaPurpose;

        IMS_Data_Asset__c imsDataAsset = UTL_TPA_SetupTestData.createImsDataAsset_Template();
        imsDataAsset.BU__c = 'United States';
        imsDataAsset.Asset_Name__c = 'Asset 1';
        imsDataAsset.Region__c = 'US';
        insert imsDataAsset;

        IMS_Data_Asset__c imsDataAsset2 = UTL_TPA_SetupTestData.createImsDataAsset_Template();
        imsDataAsset2.BU__c = 'United States';
        imsDataAsset2.Asset_Name__c = 'Asset 2';
        imsDataAsset2.Region__c = 'US';
        imsDataAsset2.Is_Restricted_Data__c = true;
        imsDataAsset2.Requires_Fee__c = true;
        insert imsDataAsset2;

        TPA_Data_Asset__c tpaDataAsset = UTL_TPA_SetupTestData.getTpaDataAsset(tpaPurpose.Id);
        tpaDataAsset.Request__c = tpaRequest1.Id;
        tpaDataAsset.Purpose__c = tpaPurpose.Id;
        tpaDataAsset.Data_Asset__c = imsDataAsset.Id;
        insert tpaDataAsset;

        TPA_Secondary_Data_Asset__c tpaSecondaryDataAsset = UTL_TPA_SetupTestData.getTpaSecDataAsset();
        tpaSecondaryDataAsset.TPA_Data_Asset__c = tpaDataAsset.Id;
        insert tpaSecondaryDataAsset;

        TPA_Purpose_Category__c tpaPurposeCategory = UTL_TPA_SetupTestData.createTpaPurposeCategory('Test Category');

        IMS_TPA_Purpose_Description__c imsTpaPurpDes = UTL_TPA_SetupTestData.createImsTpaPurposeDescription(imsTpaPurpose, tpaPurposeCategory);
        imsTpaPurpDes.Requires_Manual_Review__c = true;
        insert imsTpaPurpDes;

        TPA_Purpose_Description__c tpaPurpDes = UTL_TPA_SetupTestData.getTpaPurpDes();
        tpaPurpDes.Purpose__c = tpaPurpose.Id;
        tpaPurpDes.Description__c = imsTpaPurpDes.Id;
        tpaPurpDes.Other_Details__c = 'Test Other details';
        tpaPurpDes.Description_Text__c = 'Test Desc Text';
        tpaPurpDes.Requires_Manual_Review__c = imsTpaPurpDes.Requires_Manual_Review__c;
        insert tpaPurpDes;
        
        TPA_Settings__c setting = TPA_Settings__c.getOrgDefaults();
        setting.Base_Url__c = String.valueOf(URL.getOrgDomainUrl());
        setting.TPA_RequestSubmitted_Email__c = 'test@test.com';
        setting.Request_Submission_Form_URL__c = '/imshealthPortal/VFP_TPA_RequestSubmissionForm';
        upsert setting;

    }
    
    @isTest static void test_TPAControllerListView() { 
        PageReference pageRef = new PageReference('/imshealthPortal/VFP_TPA_ListView');
        Test.setCurrentPageReference(pageRef);
        TPA_Request__c tpaRequest = [SELECT Id FROM TPA_Request__c LIMIT 1];
        ApexPages.CurrentPage().getparameters().put('id', tpaRequest.Id);
        Test.StartTest();
        CNT_TPA_ListView listViewObject = new CNT_TPA_ListView();//Added by Babita on 15 may 2015
        listViewObject.cloneOrRenewRecord(tpaRequest);//Added by Babita on 15 may 2015
        listViewObject.executeAction();

        ApexPages.CurrentPage().getparameters().put('name', 'View');
        listViewObject.executeAction();

        ApexPages.CurrentPage().getparameters().put('name', 'Edit');
        listViewObject.executeAction();

        ApexPages.CurrentPage().getparameters().put('name', 'clone');
        listViewObject.executeAction();

        ApexPages.CurrentPage().getparameters().put('name', 'renew');
        listViewObject.executeAction();

        ApexPages.CurrentPage().getparameters().put('name', 'Cancel');
        listViewObject.executeAction();
        Test.StopTest();
    }
}