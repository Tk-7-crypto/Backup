@isTest(SeeAllData=false) 
private class TST_SRV_TPA_TPARequest { 
    private static TPA_Request__c tpaReq1; 
    private static TPA_Contact__c tpaCon;
    private static IMS_TPA_Purpose__c imsPurpose1;
    private static TPA_Purpose__c tpaPurpose1;
    private static TPA_Purpose__c tpaPurpose2;
    private static TPA_Purpose__c tpaPurpose3;
    private static TPA_Purpose__c tpaPurpose4;
    private static IMS_Data_Asset__c imsDataAss1;
    private static IMS_Data_Asset__c imsDataAss2;
    private static IMS_Data_Asset__c imsDataAss3;
    private static IMS_Data_Asset__c imsDataAss4;
    private static TPA_Data_Asset__c  tpaDataAss1;
    private static TPA_Data_Asset__c tpaDataAss2;
    private static TPA_Data_Asset__c tpaDataAss3;
    private static TPA_Data_Asset__c tpaDataAss4;
    private static TPA_Data_Asset__c tpaDataAss5;
    
    private static IMS_TPA_Purpose_Description__c imsPurposeDescription1;
    private static TPA_Purpose_Description__c tpaPurposeDescription1;
    private static TPA_Purpose_Description__c tpaPurposeDescription2;
    private static TPA_Purpose_Category__c purposeCategory1;
    private static Account acc;
    private static Account_Compliance__c accCompl;
    private static Address__c account;
    private static Contact con;
    private static AMA_Agreement_Detail__c amaAgg;
    private static TPA_Agreement_Additional_Field__c AgrAdditionalObj;
    private static String TEST_REGION = 'US';
    private static String TEST_LOCATION_TYPE = 'US';
    private static TPA_Contact__c tpaContact;
    private static TPA_Approval_Region__c tpaApprovalRegion;
    private static IMS_Secondary_Data_Asset__c imsSecondaryDataAss1;
    private static IMS_Secondary_Data_Asset__c imsSecondaryDataAss2;
    private static TPA_Secondary_Data_Asset__c tpaSecondaryDataAss1;
    private static TPA_Secondary_Data_Asset__c tpaSecondaryDataAss2;
    private static TPA_Secondary_Data_Asset__c tpaSecondaryDataAss3;
    List<AMA_Contract_Detail__c> amaContracts = new List<AMA_Contract_Detail__c>();
    private static Id resId;
    private static String resString;
    private static user resUser;
    private static List<String> resListString;
    private static boolean resBool;
    private static Map<String,String> resMapString;
    private static Map<String, Map<String, String>> resMapOfMapString;
    private static Map<String, Map<String, Map<String, String>>> resMapOfMapOfMapString;
    
    @TestSetup static void setup() {
        TST_SRV_TPA_TPARequest obj = new TST_SRV_TPA_TPARequest();
        UTL_TPA_SetupTestData.createTPASettingsData();
        UTL_TPA_SetupTestData.createTPASettingData();
        //UTL_TPA_SetupTestData.createTPAReqAggMappingSettingsData();
        UTL_TPA_SetupTestData.createCrossWalkData();
        UTL_TPA_SetupTestData.createMultilingualTemplateSettingData();
        UTL_TPA_SetupTestData.createAMASetting();
        UTL_TPA_SetupTestData.createTpaTestEditorData('TPA Email Footer', 'Test', 'emailFooter', 'emailFooter');
        Date todayDate = Date.today();
        acc = new Account(Name = 'Test Account',CustomerSegment__c = 'GOVERNMENT',Sub_Industry__c = 'STATE');
        insert acc;
        System.debug('1.Number of Queries used in this apex code so far: ' + Limits.getQueries());
        accCompl = new Account_Compliance__c(Account__c = acc.Id, Client_TPA_Compliance_Hold__c = true, Vendor_TPA_Compliance_Hold__c = true, Client_TPA_Compliance_Hold_Reason__c = 'Client on Hold', Vendor_TPA_Compliance_Hold_Reason__c = 'Vendor on Hold',TPAs_Require_Secondary_Review_by_Mgmt__c=true);
        insert accCompl;
        
        

        account = UTL_TPA_SetupTestData.getBlankAccount();
        account.Name = 'Test Account veeva medpro repwise Decision Resource source edith salesforce.com';
        account.Account__c = acc.Id;
        account.Vendor_Tier__c = 'Y';
        account.Is_Payment_Risk__c = true;
        account.Vendor_Registration_Number__c = 9999;
        account.is_TPA_Account__c = true;
        account.Street__c = 'test';
        account.City__c = 'test';
        account.Country__c = 'test';
        account.PostalCode__c = 'test';
        account.AMA_Check_List__c = 'Y';
        account.New_Vendor_Checklist__c = true;
        account.Is_Payment_Risk__c = true;
        account.Academia_Checklist__c = true;
        account.Pharma_Company_Checklist__c = true;
        account.Legal_Firm_Checklist__c = true;
        insert account;
        System.debug('2.Number of Queries used in this apex code so far: ' + Limits.getQueries());
        
        con = UTL_TPA_SetupTestData.getContact();
        con.LastName = 'Test Contact';
        con.Email = 'test@test.com';
        con.AccountId = account.Account__c;
        insert con;
        System.debug('3.Number of Queries used in this apex code so far: ' + Limits.getQueries());
        
        TPA_Assigned_TP_Processor__c assObj = new TPA_Assigned_TP_Processor__c(Commercial_Owner_Email__c = 'test@gmail.com', Temporary_Commercial_Owner_Email__c = 'a@a.in', Out_of_Office_Leave_End_Date__c = Date.Today().addDays(10),Out_of_Office_Leave_Start_Date__c = Date.Today().addDays(-10), Is_Active__c = true);
        insert assObj;
        
        // Create test tpa request
        tpaReq1 = UTL_TPA_SetupTestData.getTPARequestBlank(false);
        tpaReq1.OwnerId = UserInfo.getUserId();
        tpaReq1.Client_Region__c = TEST_REGION;
        tpaReq1.Data_Provided_By__c = 'IQVIA in lieu of Client';
        tpaReq1.Is_Data_Accessed_Via_IMS_Software__c = 'Yes';
        tpaReq1.AMA_USPrescriberData__c = 'Yes';
        tpaReq1.Does_the_request_require_information_con__c = 'Yes';
        tpaReq1.Service_Provider_Address__c = account.Id;
        tpaReq1.Client_Address__c = account.Id;
        tpaReq1.ClientContact__c = con.Id;
        tpaReq1.Vendor_Company_Name__c = 'Test company';
        tpaReq1.Is_Potential_Vendor_Case__c = false;
        tpaReq1.TP_Processor_Email__c = 'a.a@g.com';
        tpaReq1.Authorized_Signer_Email__c = 'test@mail.com';
        tpaReq1.Data_Delivered_By__c = 'IQVIA Software';
        tpaReq1.Data_Access_Start_Date__c = Date.newInstance(2016, 10, 20);
        tpaReq1.Data_Access_End_Date__c = Date.newInstance(2017, 12, 31);
        tpaReq1.Is_Submitted__c = true;
        tpaReq1.Is_Manually_Approved__c = true;
        tpaReq1.Client_Off_Notification_Ack_Date__c = Date.newInstance(2017, 12, 31);
        tpaReq1.Is_Exhibit_Required__c = true;
        tpaReq1.Vendor_Language__c = 'Japanese';
        tpaReq1.Client_Language__c = 'English';
        tpaReq1.TPA_Assigned_TP_Processor__c = assObj.id;
        tpaReq1.Client_TPA_Representative_Email__c = 'test@test.com';
        //tpaReq1.Co_Assigned_Global_TP_Processor__c = assObj.Id;
        insert tpaReq1;
        system.assert(tpaReq1.Id != null);
        System.debug('4.Number of Queries used in this apex code so far: ' + Limits.getQueries());
        
        
        
        List<Attachment> lstAttachment = new List<Attachment>();
        lstAttachment.add(UTL_TPA_SetupTestData.addAttachment(tpaReq1.Id, 'Vendor\'s Operation Guide.pdf'));
        lstAttachment.add(UTL_TPA_SetupTestData.addAttachment(tpaReq1.Id, 'Offerings Notification Client.pdf'));
        lstAttachment.add(UTL_TPA_SetupTestData.addAttachment(tpaReq1.Id, 'Protective Order for.pdf'));
        lstAttachment.add(UTL_TPA_SetupTestData.addAttachment(tpaReq1.id, 'AMA_Original TPA- Offerings Notification Limited License Agreement'));
        
        insert lstAttachment;
        System.debug('5.Number of Queries used in this apex code so far: ' + Limits.getQueries());
        
        AMA_Agreement_Detail__c amaAgg = UTL_TPA_SetupTestData.getAMAAgreementDetailBlank(tpaReq1.id);
        amaAgg.AMA_Manual_Review__c = false;
        amaAgg.Is_AMA_License_Required__c = true;
        amaAgg.Current_Year_Fees__c  = 21000;
        amaAgg.Contract_Type__c = 'Service Bureau II';
        amaAgg.Agreement_Start_Date__c = Date.newInstance(2016 , 10 ,20);
        amaAgg.Agreement_End_Date__c = Date.newInstance(2017 , 12 ,31);
        amaAgg.AMA_Howlong_SP_has_Data_Access__c = '90 days or less';
        amaAgg.FrequencyOfDeliveryToServiceProvider__c = 'Quarterly';
        amaAgg.AMA_TypeOfPrescriberLevelData__c='Birth Year;Gender Code';
        amaAgg.AMA_Services_Provided__c='Telemarketing;Labeling';
        amaAgg.Invoice_Contact_Email__c='testinvoice@gmail.com';
        insert amaAgg;
        System.debug('6.Number of Queries used in this apex code so far: ' + Limits.getQueries());
        
        Watch_List__c watchObj = UTL_TPA_SetupTestData.createWatchList(tpaReq1.Service_Provider_Address__c);
        watchObj.Offering__c = 'Asset 1';
        watchObj.Use__c = 'test purpose';
        insert watchObj;
        System.debug('7.Number of Queries used in this apex code so far: ' + Limits.getQueries());
        
        // create test contact
        tpaContact = UTL_TPA_SetupTestData.getTestTPAContact(tpaReq1);
        tpaContact.Name = 'Initiator Contact';
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
        System.debug('8.Number of Queries used in this apex code so far: ' + Limits.getQueries());
        
        // create test ims purpose
        imsPurpose1 = UTL_TPA_SetupTestData.getIMSTpaPurposeData();
        imsPurpose1.Name = 'test purpose';
        imsPurpose1.Purpose_Details__c = 'test purpose details';
        imsPurpose1.Consulting_Area__c = 'test consulting area';
        imsPurpose1.Business_Line__c = 'test business line';
        imsPurpose1.Primary_Purpose_Name__c = 'test purpose';
        insert imsPurpose1;
        system.assert(imsPurpose1.Id != null);
        System.debug('9.Number of Queries used in this apex code so far: ' + Limits.getQueries());
        
        // Create test TPA Purposes
        tpaPurpose1 = UTL_TPA_SetupTestData.createTpaPurposeByReqId(tpaReq1);
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
        //insert tpaPurpose1;
        //system.assert(tpaPurpose1.Id != null);
        System.debug('10.Number of Queries used in this apex code so far: ' + Limits.getQueries());
        
        tpaPurpose2 = UTL_TPA_SetupTestData.createTpaPurposeByReqId(tpaReq1);
        tpaPurpose2.Name = 'Other';
        tpaPurpose2.Region__c = TEST_REGION;
        tpaPurpose2.Purpose__c = imsPurpose1.Id;
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
        //system.assert(tpaPurpose2.Id != null);
        System.debug('11.Number of Queries used in this apex code so far: ' + Limits.getQueries());
        
        tpaPurpose3 = UTL_TPA_SetupTestData.createTpaPurposeByReqId(tpaReq1);
        tpaPurpose3.Name = 'Expert Analysis for Legal or Governmental Purposes';
        tpaPurpose3.Region__c = TEST_REGION;
        tpaPurpose3.Purpose__c = imsPurpose1.Id;
        tpaPurpose3.Prescriber_ID_Number__c = null;
        tpaPurpose3.Prescriber_ID_Number_Details__c = null;
        tpaPurpose3.PrescriberNPINumber__c = null;
        tpaPurpose3.PrescriberNPINumber_Details__c = null;
        tpaPurpose3.OutletReferenceFiles__c = null;
        tpaPurpose3.Other_Reference_File__c = null;
        tpaPurpose3.Other_Details__c = '';
        tpaPurpose3.Other_Text__c = '';
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

        tpaPurpose4 = UTL_TPA_SetupTestData.createTpaPurposeByReqId(tpaReq1);
        tpaPurpose4.Name = 'CRM';
        tpaPurpose4.Region__c = 'South Africa';
        tpaPurpose4.Purpose__c = imsPurpose1.Id;
        tpaPurpose4.Prescriber_ID_Number__c = null;
        tpaPurpose4.Prescriber_ID_Number_Details__c = null;
        tpaPurpose4.PrescriberNPINumber__c = null;
        tpaPurpose4.PrescriberNPINumber_Details__c = null;
        tpaPurpose4.OutletReferenceFiles__c = null;
        tpaPurpose4.Other_Reference_File__c = null;
        tpaPurpose4.Other_Details__c = '';
        tpaPurpose4.Other_Text__c = '';
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



        insert new List<TPA_Purpose__c> {tpaPurpose1, tpaPurpose2,tpaPurpose3,tpaPurpose4};

        //insert tpaPurpose1;
        //system.assert(tpaPurpose1.Id != null);
        System.debug('10.Number of Queries used in this apex code so far: ' + Limits.getQueries());
        
        
        //Create test purpose category
        purposeCategory1 = UTL_TPA_SetupTestData.getTpaPurposeCategory('Test Category');
        insert purposeCategory1;
        System.debug('12.Number of Queries used in this apex code so far: ' + Limits.getQueries());
        
        //Create test ims purpose description
        imsPurposeDescription1 = UTL_TPA_SetupTestData.getImsTpaPurpDes();
        imsPurposeDescription1.Description__c = 'Test Description';
        imsPurposeDescription1.Purpose__c = imsPurpose1.Id;
        imsPurposeDescription1.TPA_Purpose_Category__c = purposeCategory1.Id;
        imsPurposeDescription1.Requires_Manual_Review__c = True;
        insert imsPurposeDescription1;
        System.debug('13.Number of Queries used in this apex code so far: ' + Limits.getQueries());
        
        IMS_Legal_Entity__c imsLegalEntity = UTL_TPA_SetupTestData.getImsLegalEntity_Template();
        imsLegalEntity.Name = 'IQVIA Ltd.';
        imsLegalEntity.Legal_Entity_Name_for_TLLA__c = 'IQVIA Ltd.';
        imsLegalEntity.TPA_Request__c = tpaReq1.Id;
        insert imsLegalEntity;
        System.debug('14.Number of Queries used in this apex code so far: ' + Limits.getQueries());
        
        IMS_Master_Legal_Entity__c imsMasterLegalEntity = UTL_TPA_SetupTestData.getImsMasterLegalEntity();
        imsMasterLegalEntity.Name = 'IQVIA Ltd.';
        update imsMasterLegalEntity;
        System.debug('15.Number of Queries used in this apex code so far: ' + Limits.getQueries());
        
        // create test IMS data assets
        imsDataAss1 = UTL_TPA_SetupTestData.createImsDataAsset_Template();
        imsDataAss1.Region__c = TEST_REGION;
        imsDataAss1.Requires_Manual_Review__c = true;
        imsDataAss1.IMS_Master_Legal_Entity__c = imsMasterLegalEntity.Id;
        imsDataAss1.IMS_Legal_Entity__c = 'IQVIA Ltd.';
        imsDataAss1.Asset_Name__c = 'MIDAS';
        imsDataAss1.Additional_terms_required__c = true;
        //insert imsDataAss1;
        //system.assert(imsDataAss1.Id != null);
        System.debug('16.Number of Queries used in this apex code so far: ' + Limits.getQueries());
        
        imsDataAss2 = UTL_TPA_SetupTestData.createImsDataAsset_Template();
        imsDataAss2.Region__c = TEST_REGION;
        imsDataAss2.Is_Restricted_Data__c = True;
        imsDataAss2.Requires_Fee__c = True;
        imsDataAss2.Requires_Manual_Review__c = true;
        imsDataAss2.IMS_Master_Legal_Entity__c = imsMasterLegalEntity.Id;
        imsDataAss2.IMS_Legal_Entity__c = 'IQVIA Ltd.';
        imsDataAss2.Asset_Name__c = 'Managed Care Workbook - New View';
        imsDataAss2.Needs_license_or_data_supplier_response__c = 'Yes';
        //insert imsDataAss2;
        //system.assert(imsDataAss2.Id != null);
        System.debug('17.Number of Queries used in this apex code so far: ' + Limits.getQueries());
        
        imsDataAss3 = UTL_TPA_SetupTestData.createImsDataAsset_Template();
        imsDataAss3.Asset_Name__c = 'Other';
        imsDataAss3.Region__c = TEST_REGION;
        imsDataAss3.Is_Restricted_Data__c = True;
        imsDataAss3.Requires_Fee__c = True;
        imsDataAss3.Requires_Manual_Review__c = true;
        imsDataAss3.IMS_Master_Legal_Entity__c = imsMasterLegalEntity.Id;
        imsDataAss3.IMS_Legal_Entity__c = 'IQVIA Ltd.';

        imsDataAss4 = UTL_TPA_SetupTestData.createImsDataAsset_Template();
        imsDataAss4.Asset_Name__c = 'IQVIA Consumer Aisle';
        imsDataAss4.Region__c = 'South Africa';
        imsDataAss4.Is_Restricted_Data__c = True;
        imsDataAss4.Requires_Fee__c = True;
        imsDataAss4.Requires_Manual_Review__c = true;
        imsDataAss4.IMS_Master_Legal_Entity__c = imsMasterLegalEntity.Id;
        imsDataAss4.IMS_Legal_Entity__c = 'IQVIA Ltd.';
        //insert imsDataAss3;
        //system.assert(imsDataAss3.Id != null);
        String offNamesUS = 'Patient Reference File;GE Centricity EMR;Managed Care Workbook - New View;PharMetrics® Plus (Health Plan Claims);Patient Companion File (PatCo) - Formerly Patient Reference File;';
        offNamesUS += 'Provider Companion File;Payer Companion File;LAAD - Longitudinal Access and Adjudication Data;Oncology electronic medical records data;Ambulatory electronic medical records data;Xponent;Medpages Data;OneKey Database';

        List<IMS_Data_Asset__c> offeringsToInsert = new List<IMS_Data_Asset__c>();
        for(String offName:offNamesUS.split(';')){
            IMS_Data_Asset__c imsDa = UTL_TPA_SetupTestData.createImsDataAsset_Template();
            imsDa.Region__c = TEST_REGION;
            imsDa.Is_Restricted_Data__c = True;
            imsDa.Requires_Fee__c = True;
            imsDa.Requires_Manual_Review__c = true;
            imsDa.IMS_Master_Legal_Entity__c = imsMasterLegalEntity.Id;
            imsDa.IMS_Legal_Entity__c = 'IQVIA Ltd.';
            imsDa.Asset_Name__c = offName;
            offeringsToInsert.add(imsDa);
        }
        insert offeringsToInsert;
        insert new List<IMS_Data_Asset__c> {imsDataAss1, imsDataAss2, imsDataAss3,imsDataAss4};
        System.debug('18.Number of Queries used in this apex code so far: ' + Limits.getQueries());
        
        // Create test tpa purpose descriptions
        tpaPurposeDescription1 = UTL_TPA_SetupTestData.getTpaPurpDes();
        tpaPurposeDescription1.Purpose__c = tpaPurpose1.Id;
        tpaPurposeDescription1.Description__c = imsPurposeDescription1.Id;
        tpaPurposeDescription1.Requires_Manual_Review__c = imsPurposeDescription1.Requires_Manual_Review__c;
        //insert tpaPurposeDescription1;
        System.debug('19.Number of Queries used in this apex code so far: ' + Limits.getQueries());
        
        tpaPurposeDescription2 = UTL_TPA_SetupTestData.getTpaPurpDes();
        tpaPurposeDescription2.Purpose__c = tpaPurpose2.Id;
        tpaPurposeDescription2.Description__c = imsPurposeDescription1.Id;
        tpaPurposeDescription2.Requires_Manual_Review__c = imsPurposeDescription1.Requires_Manual_Review__c;
        //insert tpaPurposeDescription2; 
        insert new List<TPA_Purpose_Description__c> {tpaPurposeDescription1, tpaPurposeDescription2};
        System.debug('20.Number of Queries used in this apex code so far: ' + Limits.getQueries());
        
        // create test TPA data assets
        tpaDataAss1 = UTL_TPA_SetupTestData.getTpaDataAsset(tpaPurpose1.Id);
        tpaDataAss1.Request__c = tpaReq1.Id;
        tpaDataAss1.Region__c = TEST_REGION;
        tpaDataAss1.Data_Asset__c = imsDataAss1.Id;
        tpaDataAss1.BU__c = TEST_REGION;
        tpaDataAss1.Geo_Level__c = 'Real World Evidence';
        //insert tpaDataAss1;
        //system.assert(tpaDataAss1.Id != null);
        System.debug('21.Number of Queries used in this apex code so far: ' + Limits.getQueries());
        
        tpaDataAss2 = UTL_TPA_SetupTestData.getTpaDataAsset(tpaPurpose1.Id);
        tpaDataAss2.Request__c = tpaReq1.Id;
        tpaDataAss2.Region__c = TEST_REGION;
        tpaDataAss2.Data_Asset__c = imsDataAss2.Id;
        tpaDataAss2.Is_Restricted_Data__c = imsDataAss2.Is_Restricted_Data__c;
        tpaDataAss2.BU__c = TEST_REGION;
        tpaDataAss2.Geo_Level__c = 'Anonymized Patient-Level Data / Transaction-Level';
        //insert tpaDataAss2;
        //system.assert(tpaDataAss2.Id != null);
        System.debug('22.Number of Queries used in this apex code so far: ' + Limits.getQueries());
        
        tpaDataAss3 = UTL_TPA_SetupTestData.getTpaDataAsset(tpaPurpose2.Id);
        tpaDataAss3.Request__c = tpaReq1.Id;
        tpaDataAss3.Region__c = TEST_REGION;
        tpaDataAss3.BU__c = TEST_REGION;
        tpaDataAss3.Data_Asset__c = imsDataAss3.Id;
        tpaDataAss3.Is_Restricted_Data__c = imsDataAss3.Is_Restricted_Data__c;
        tpaDataAss3.Other_Data_Asset_Details__c = 'test';
        tpaDataAss3.Asset_NametText__c = 'Other';
        tpaDataAss3.Geo_Level__c = 'Sub-National';
        
        tpaDataAss4 = UTL_TPA_SetupTestData.getTpaDataAsset(tpaPurpose3.Id);
        tpaDataAss4.Request__c = tpaReq1.Id;
        tpaDataAss4.Region__c = TEST_REGION;
        tpaDataAss4.Data_Asset__c = imsDataAss1.Id;
        tpaDataAss4.Is_Restricted_Data__c = imsDataAss1.Is_Restricted_Data__c;
        tpaDataAss4.BU__c = TEST_REGION;
        tpaDataAss4.Geo_Level__c = 'Reference Data';

        tpaDataAss5 = UTL_TPA_SetupTestData.getTpaDataAsset(tpaPurpose4.Id);
        tpaDataAss5.Request__c = tpaReq1.Id;
        tpaDataAss5.Region__c = 'South Africa';
        tpaDataAss5.Data_Asset__c = imsDataAss4.Id;
        tpaDataAss5.Is_Restricted_Data__c = imsDataAss4.Is_Restricted_Data__c;
        tpaDataAss5.BU__c = 'South Africa';
        tpaDataAss5.Geo_Level__c = 'National';

        List<TPA_Data_Asset__c> offs = new List<TPA_Data_Asset__c>();

        for(IMS_Data_Asset__c imsDa:offeringsToInsert){
            TPA_Data_Asset__c da = UTL_TPA_SetupTestData.getTpaDataAsset(tpaPurpose1.Id);
            da.Request__c = tpaReq1.Id;
            da.Region__c = TEST_REGION;
            da.Data_Asset__c = imsDa.Id;
            da.Is_Restricted_Data__c = imsDa.Is_Restricted_Data__c;
            da.BU__c = 'United States';
            da.Geo_Level__c = 'Reference Data';
            offs.add(da);
        }
        
        insert offs;
        //insert tpaDataAss3;
        //system.assert(tpaDataAss3.Id != null);
        insert new List<TPA_Data_Asset__c> {tpaDataAss1, tpaDataAss2, tpaDataAss3,tpaDataAss4};
        System.debug('23.Number of Queries used in this apex code so far: ' + Limits.getQueries());
        
        imsSecondaryDataAss1 = UTL_TPA_SetupTestData.getImsSecDataAsset();
        imsSecondaryDataAss1.Primary_Data_Asset__c = imsDataAss1.Id;
        imsSecondaryDataAss1.Requires_Manual_Review__c = true;
        imsSecondaryDataAss1.Is_Restricted_Data__c = true;
        imsSecondaryDataAss1.Secondary_Asset_Name__c = 'ims sec asset 1';
        //insert imsSecondaryDataAss1;
        //system.assert(imsSecondaryDataAss1.Id != null);
        System.debug('24.Number of Queries used in this apex code so far: ' + Limits.getQueries());
        
        imsSecondaryDataAss2 = UTL_TPA_SetupTestData.getImsSecDataAsset();
        imsSecondaryDataAss2.Primary_Data_Asset__c = imsDataAss2.Id;
        imsSecondaryDataAss2.Requires_Manual_Review__c = true;
        imsSecondaryDataAss2.Is_Restricted_Data__c = true;
        imsSecondaryDataAss2.Secondary_Asset_Name__c = 'BrandImpact Custom Study Name & Project Delivery Date:';
        //insert imsSecondaryDataAss2;
        //system.assert(imsSecondaryDataAss2.Id != null);
        insert new List<IMS_Secondary_Data_Asset__c> {imsSecondaryDataAss1, imsSecondaryDataAss2};
        System.debug('25.Number of Queries used in this apex code so far: ' + Limits.getQueries());
        
        tpaSecondaryDataAss1 = UTL_TPA_SetupTestData.getTpaSecDataAsset();
        tpaSecondaryDataAss1.TPA_Data_Asset__c = tpaDataAss1.Id;
        tpaSecondaryDataAss1.IMS_Secondary_Data_Asset__c = imsSecondaryDataAss1.id;
        tpaSecondaryDataAss1.Secondary_Asset_Name__c = 'Channel Dynamics Custom Study Name & Project Delivery Date:';
        tpaSecondaryDataAss1.Channel_Dynamics_Delivery_Date__c = Date.today();
        //insert tpaSecondaryDataAss1;
        //system.assert(tpaSecondaryDataAss1.Id != null);
        System.debug('26.Number of Queries used in this apex code so far: ' + Limits.getQueries());
        
        tpaSecondaryDataAss2 = UTL_TPA_SetupTestData.getTpaSecDataAsset();
        tpaSecondaryDataAss2.TPA_Data_Asset__c = tpaDataAss2.Id;
        tpaSecondaryDataAss2.IMS_Secondary_Data_Asset__c = imsSecondaryDataAss2.id;
        tpaSecondaryDataAss2.Secondary_Asset_Name__c = 'tpa sec asset 2';
        //insert tpaSecondaryDataAss2;
        System.debug('27.Number of Queries used in this apex code so far: ' + Limits.getQueries());
        
        tpaSecondaryDataAss3 = UTL_TPA_SetupTestData.getTpaSecDataAsset();
        tpaSecondaryDataAss3.TPA_Data_Asset__c = tpaDataAss1.Id;
        tpaSecondaryDataAss3.IMS_Secondary_Data_Asset__c = imsSecondaryDataAss1.id;
        tpaSecondaryDataAss3.Secondary_Asset_Name__c = 'ProVoice Custom Study Name & Project Delivery Date:';
        tpaSecondaryDataAss3.Pro_Voice_Delivery_Date__c = Date.today();
        insert new List<TPA_Secondary_Data_Asset__c> {tpaSecondaryDataAss1, tpaSecondaryDataAss2, tpaSecondaryDataAss3};
        system.assert(tpaSecondaryDataAss3.Id != null);
        System.debug('28.Number of Queries used in this apex code so far: ' + Limits.getQueries());
        
        IMS_Use_Offering_Atypical_Combination__c IMSUseOfferingAtypicalCombinationObj1 = new IMS_Use_Offering_Atypical_Combination__c(Use_Category__c = purposeCategory1.id,Use_Name__c = imsPurpose1.id, Offering_Name__c =  imsDataAss1.id, Secondary_Offering_Name__c = imsSecondaryDataAss1.id, isActive__c = true, is_Approved_For_Future__c = false);
        //insert IMSUseOfferingAtypicalCombinationObj;
        System.debug('29.Number of Queries used in this apex code so far: ' + Limits.getQueries());
        
        IMS_Use_Offering_Atypical_Combination__c IMSUseOfferingAtypicalCombinationObj2 = new IMS_Use_Offering_Atypical_Combination__c(Use_Category__c = purposeCategory1.id,Use_Name__c = imsPurpose1.id, Offering_Name__c =  imsDataAss2.id, isActive__c = true, is_Approved_For_Future__c = false);
        //insert IMSUseOfferingAtypicalCombinationObj1;
        insert new List<IMS_Use_Offering_Atypical_Combination__c> {IMSUseOfferingAtypicalCombinationObj1, IMSUseOfferingAtypicalCombinationObj2};
        TPA_Use_Offering_Atypical_Combination__c TPAUseOfferingAtypicalCombinationObj1 = new TPA_Use_Offering_Atypical_Combination__c(IMS_Use_Offering_Atypical_Combination__c = IMSUseOfferingAtypicalCombinationObj1.id, TPA_Request__c = tpaReq1.id);
        //insert TPAUseOfferingAtypicalCombinationObj;
        TPA_Use_Offering_Atypical_Combination__c TPAUseOfferingAtypicalCombinationObj2 = new TPA_Use_Offering_Atypical_Combination__c(IMS_Use_Offering_Atypical_Combination__c = IMSUseOfferingAtypicalCombinationObj2.id, TPA_Request__c = tpaReq1.id);
        //insert TPAUseOfferingAtypicalCombinationObj1;
        insert new List<TPA_Use_Offering_Atypical_Combination__c> {TPAUseOfferingAtypicalCombinationObj1, TPAUseOfferingAtypicalCombinationObj2};
        System.debug('30.Number of Queries used in this apex code so far: ' + Limits.getQueries());
        
        TPA_Contact__c tpaContact = UTL_TPA_SetupTestData.getTPAContactByReqId(tpaReq1);
        tpaContact.Subcontractor_TPA_Request__c = tpaReq1.Id;
        tpaContact.Type__c = 'Additional Client Contact';
        update tpaContact;
        System.debug('31.Number of Queries used in this apex code so far: ' + Limits.getQueries());
        
        IMS_Secondary_Data_Asset__c imsSecondaryDataAsset = UTL_TPA_SetupTestData.createIMSSecondaryDataAsset(imsDataAss1, true, 'Test Sec Assest');
        TPA_Secondary_Data_Asset__c tpaSecondaryDataAsset = UTL_TPA_SetupTestData.createTPASecondaryDataAsset(tpaDataAss1, imsSecondaryDataAss1, imsLegalEntity, tpaReq1, 'Xponent PlanTrak');
        TPA_Secondary_Data_Asset__c tpaSecondaryDataAsset2 = UTL_TPA_SetupTestData.createTPASecondaryDataAsset(tpaDataAss2, imsSecondaryDataAss1, imsLegalEntity, tpaReq1, 'Test Sec Asset');
        
        List<TPA_Text_Editor__c> textEditorList = new List<TPA_Text_Editor__c>();

        TPA_Text_Editor__c tpaUseDefinition3 = new TPA_Text_Editor__c(Page_Name__c = 'testOfferings', Content__c = 'Test Offerings Notification 3', Page_Title__c = 'Notification_Content', Page_Type__c = 'TPA Offering Notifications');
        textEditorList.add(tpaUseDefinition3) ;
        System.debug('32.Number of Queries used in this apex code so far: ' + Limits.getQueries());
        
        TPA_Text_Editor__c tpaUseDefinition4 = new TPA_Text_Editor__c(Page_Name__c = 'testOfferings', Content__c = 'Test Offerings Notification 4', Page_Title__c = 'Notification_Content', Page_Type__c = 'TPA Offering Notifications');
        textEditorList.add(tpaUseDefinition4) ;
        System.debug('33.Number of Queries used in this apex code so far: ' + Limits.getQueries());
        
        TPA_Text_Editor__c tpaUseDefinition5 = new TPA_Text_Editor__c(Page_Name__c = 'testOfferings', Content__c = 'Test Offerings Notification  4', Page_Title__c = 'Notification_Content', Page_Type__c = 'TPA Offering Notifications');
        textEditorList.add(tpaUseDefinition5) ;

        TPA_Text_Editor__c tpaUseDefinition6 = new TPA_Text_Editor__c(Page_Name__c = 'testOfferings', Content__c = 'Test Offerings Notification  4', Page_Title__c = 'Notification_Content', Page_Type__c = 'TPA Offering Addendum');
        textEditorList.add(tpaUseDefinition6) ;

        TPA_Text_Editor__c tpaUseDefinition7 = new TPA_Text_Editor__c(Page_Name__c = 'Is_Oncology_EMR__c', Content__c = 'Test Offerings Additional Terms', Page_Title__c = 'Is_Oncology_EMR__c', Page_Type__c = 'IMS_Legal_Entity__c');
        textEditorList.add(tpaUseDefinition7) ;

        TPA_Text_Editor__c tpaUseDefinition8 = new TPA_Text_Editor__c(Page_Name__c = 'Vendor Requires Review', Content__c = 'Vendor Requires Review SPLIT-HERE content1~content2~content3~content4~content5~content6 SPLIT-HERE content1~content2~content3~content4~content5~content6', Page_Title__c = 'Notification_Content', Page_Type__c = 'Manual Review Reasons');
        textEditorList.add(tpaUseDefinition8) ;
        
        TPA_Text_Editor__c tpaUseDefinition9 = new TPA_Text_Editor__c(Page_Name__c = 'Vendor Requires Secondary Review', Content__c = 'Test Offerings Notification 4', Page_Title__c = 'Notification_Content', Page_Type__c = 'Manual Review Reasons');
        textEditorList.add(tpaUseDefinition9) ;
        TPA_Text_Editor__c tpaUseDefinition10 = new TPA_Text_Editor__c(Page_Name__c = 'AI_ML_Restrictions', Content__c = 'Test Offerings Notification 6666', Page_Title__c = 'AI_ML_Restrictions', Page_Type__c = 'TPA_Request__c');
        textEditorList.add(tpaUseDefinition10) ;
        
        TPA_Text_Editor__c tpaUseDefinition11 = new TPA_Text_Editor__c(Page_Name__c = 'is_Xponent__c', Content__c = 'ccccc', Page_Title__c = 'is_Xponent__c', Page_Type__c = 'IMS_Legal_Entity__c');
        textEditorList.add(tpaUseDefinition11) ; 
		TPA_Text_Editor__c tpaUseDefinition12 = new TPA_Text_Editor__c(Page_Name__c = 'is_Veeva_Use_CRM__c', Content__c = 'Test Offerings Notification 666', Page_Title__c = 'is_Veeva_Use_CRM__c', Page_Type__c = 'TPA_Request__c');
        textEditorList.add(tpaUseDefinition12);
       	

        insert textEditorList;
        System.debug('34.Number of Queries used in this apex code so far: ' + Limits.getQueries());
        
        List<TPA_Offering_Notification_Mapping__c> offNotObjList = new List<TPA_Offering_Notification_Mapping__c>();
        TPA_Offering_Notification_Mapping__c offNotObj = new TPA_Offering_Notification_Mapping__c(IMS_Primary_Data_Asset__c = imsDataAss1.Id, IMS_Secondary_Data_Asset__c = imsSecondaryDataAss1.id,IMS_TPA_Purpose__c = imsPurpose1.id,Offering_Notifications__c = tpaUseDefinition3.id, IsActive__c = true,Country__c = 'United States', TLLA_Additional_Terms__c = tpaUseDefinition6.id);
        offNotObjList.add(offNotObj);
        TPA_Offering_Notification_Mapping__c offNotObj1 = new TPA_Offering_Notification_Mapping__c(IMS_Primary_Data_Asset__c = imsDataAss1.Id, IMS_Secondary_Data_Asset__c = imsSecondaryDataAss1.id,IMS_TPA_Purpose__c = imsPurpose1.id,Offering_Notifications__c = tpaUseDefinition4.id, IsActive__c = true,Country__c = 'United States', TLLA_Additional_Terms__c = tpaUseDefinition6.id);
        offNotObjList.add(offNotObj1);
        TPA_Offering_Notification_Mapping__c offNotObj2 = new TPA_Offering_Notification_Mapping__c(IMS_Primary_Data_Asset__c = imsDataAss2.Id, IMS_Secondary_Data_Asset__c = imsSecondaryDataAss2.id, Offering_Notifications__c = tpaUseDefinition4.id, IsActive__c = true,Country__c = 'United States' , TLLA_Additional_Terms__c = tpaUseDefinition6.id);
        offNotObjList.add(offNotObj2);
        TPA_Offering_Notification_Mapping__c offNotObj3 = new TPA_Offering_Notification_Mapping__c(IMS_Primary_Data_Asset__c = imsDataAss2.Id, IMS_TPA_Purpose__c = imsPurpose1.id,Offering_Notifications__c = tpaUseDefinition5.id, IsActive__c = true,Country__c = 'United States',OneKey_Countries__c='United Kingdom' , TLLA_Additional_Terms__c = tpaUseDefinition6.id);
        offNotObjList.add(offNotObj3);
        TPA_Offering_Notification_Mapping__c offNotObj4 = new TPA_Offering_Notification_Mapping__c(IMS_Primary_Data_Asset__c = imsDataAss2.Id, Offering_Notifications__c = tpaUseDefinition5.id, IsActive__c = true,Country__c = 'United States', OneKey_Countries__c='United Kingdom',TLLA_Additional_Terms__c = tpaUseDefinition6.id);
        offNotObjList.add(offNotObj4);
        insert offNotObjList;
        System.debug('35.Number of Queries used in this apex code so far: ' + Limits.getQueries());

        List<TPA_Off_Notification_Account_Mapping__c> accMapList = new List<TPA_Off_Notification_Account_Mapping__c>();

        
        TPA_Off_Notification_Account_Mapping__c accmapObj1 = new TPA_Off_Notification_Account_Mapping__c(Vendor_Account_Address__c = account.id, TPA_Offering_Notification_Mapping_Rule__c = offNotObj.id);
        accMapList.add(accmapObj1);
        TPA_Off_Notification_Account_Mapping__c accmapObj2 = new TPA_Off_Notification_Account_Mapping__c(Vendor_Account_Address__c = account.id, TPA_Offering_Notification_Mapping_Rule__c = offNotObj4.id);
        accMapList.add(accmapObj2);

        insert accMapList;
        List<TPA_Commercial_Review__c> lstComRev = new List<TPA_Commercial_Review__c>();
        TPA_Commercial_Review__c comRev1 = new TPA_Commercial_Review__c(Commercial_Owner_Name__c = UserInfo.getUserName(), 
                                                                        //Is_ReviewForm_Acknowledged__c, 
                                                                        Associated_Offering_to_Review__c = 'test', 
                                                                        Associated_Use_to_Review__c = 'Expert Analysis for Legal or Governmental Purposes', 
                                                                        Manual_Review_Reason__c = 'Vendor Requires Review',  
                                                                        Action_Needed_By__c = 'Commercial Owner', 
                                                                        TPA_Request__c = tpaReq1.Id, 
                                                                        Status__c = 'Approved', 
                                                                        Action__c = 'Approved for this specific TPA request', 
                                                                        Receiver_s_Email__c = 'test@gmail.com',
                                                                        TP_US_Email__c = UserInfo.getUserEmail(), 
                                                                        //Additional_Questions_For_TP_Processor__c, 
                                                                        TP_Country_Email__c = 'test@gmail.com');
        TPA_Commercial_Review__c comRev2 = new TPA_Commercial_Review__c(Commercial_Owner_Name__c = UserInfo.getUserName(), 
                                                                        //Is_ReviewForm_Acknowledged__c, 
                                                                        Associated_Offering_to_Review__c = 'test', 
                                                                        Associated_Use_to_Review__c = 'test', 
                                                                        Manual_Review_Reason__c = 'Vendor Requires Secondary Review',  
                                                                        Action_Needed_By__c = 'Commercial Owner', 
                                                                        TPA_Request__c = tpaReq1.Id, 
                                                                        Status__c = 'Awaiting Review', 
                                                                        Action__c = 'Under Validation', 
                                                                        Receiver_s_Email__c = 'test@gmail.com',
                                                                        TP_US_Email__c = UserInfo.getUserEmail(), 
                                                                        //Additional_Questions_For_TP_Processor__c, 
                                                                        TP_Country_Email__c = 'test@gmail.com');
        TPA_Commercial_Review__c comRev3 = new TPA_Commercial_Review__c(Commercial_Owner_Name__c = UserInfo.getUserName(), 
                                                                        //Is_ReviewForm_Acknowledged__c, 
                                                                        Associated_Offering_to_Review__c = 'test', 
                                                                        Associated_Use_to_Review__c = 'test', 
                                                                        Manual_Review_Reason__c = 'Awaiting to Send: Primary Commercial Owner Not Complete',  
                                                                        Action_Needed_By__c = 'Commercial Owner', 
                                                                        TPA_Request__c = tpaReq1.Id, 
                                                                        Status__c = 'Awaiting Review', 
                                                                        Action__c = 'Under Validation', 
                                                                        Receiver_s_Email__c = 'test@gmail.com',
                                                                        TP_US_Email__c = UserInfo.getUserEmail(), 
                                                                        //Additional_Questions_For_TP_Processor__c, 
                                                                        TP_Country_Email__c = 'test@gmail.com');
        lstComRev.add(comRev1);
        lstComRev.add(comRev2);
        lstComRev.add(comRev3);
        insert lstComRev;
        
        List<TPA_Additional_Term__c> addtionalTermList = new List<TPA_Additional_Term__c>();
        for(Integer i=0;i<3;i++){
            TPA_Additional_Term__c newAdditionalTerm = new TPA_Additional_Term__c();
            newAdditionalTerm.Name = 'Test'+i;
            newAdditionalTerm.TPA_Legal_Entity_1__c = imsLegalEntity.Id;
            newAdditionalTerm.Addtional_Term__c = 'Test Term' + i;
            newAdditionalTerm.Category__c = (i == 0 ? 'Data Asset Specific Ad-Hoc Term' : 'General Ad-Hoc Term' );
            newAdditionalTerm.Primary_Offering_Name__c = (i == 0 ? 'Real World Evidence' : 'Anonymized Patient-Level Data / Transaction-Level');
            newAdditionalTerm.Secondary_Offering_Name__c = (i == 0 ? 'Channel Dynamics Custom Study Name & Project Delivery Date:' : '');
            newAdditionalTerm.Country_of_Offering__c = (i == 0 ? 'US' : 'South Africa' );
            newAdditionalTerm.TPA_Request__c = tpaReq1.Id;
            addtionalTermList.add(newAdditionalTerm);    
            
        }
        for(Integer i=0;i<3;i++){
            TPA_Additional_Term__c newUseAdditionalTerm = new TPA_Additional_Term__c();
            newUseAdditionalTerm.Name = 'Test'+i;
            newUseAdditionalTerm.TPA_Legal_Entity_1__c = imsLegalEntity.Id;
            newUseAdditionalTerm.Addtional_Term__c = 'Test Term' + i;
            newUseAdditionalTerm.Category__c = (i == 0 ? 'Use Specific Ad-Hoc Terms' : 'Use/Offering Specific Ad-Hoc Terms' );
            newUseAdditionalTerm.Primary_Offering_Name__c = (i == 0 ? 'Real World Evidence' : 'Anonymized Patient-Level Data / Transaction-Level');
            newUseAdditionalTerm.Secondary_Offering_Name__c = (i == 0 ? 'tpa sec asset 2' : 'tpa sec asset 2');
            newUseAdditionalTerm.Use_Name__c = (i == 0 ? 'Expert Analysis for Legal or Governmental Purposes' : 'test purpose');
            newUseAdditionalTerm.Country_of_Offering__c = (i == 0 ? 'South Africa' : 'US' );
            newUseAdditionalTerm.TPA_Request__c = tpaReq1.Id;
            addtionalTermList.add(newUseAdditionalTerm);            
        }
        
        insert addtionalTermList;
        
        Attachment testAttachment = UTL_TPA_SetupTestData.addAttachmentToParent(addtionalTermList[1].id, 'test Attachment');
        Attachment testAttachment2 = UTL_TPA_SetupTestData.addAttachmentToParent(addtionalTermList[3].id, 'test Attachment');
        
        TPA_Table_Of_Responsibility_Settings__c respSetting1 = new TPA_Table_Of_Responsibility_Settings__c(Name='test',MANUAL_TRIGGER_REASONS__c = 'Vendor Requires Secondary Review',OWNER_REVIEW__c ='Commercial Owner');
        TPA_Table_Of_Responsibility_Settings__c respSetting2 = new TPA_Table_Of_Responsibility_Settings__c(Name='tt',MANUAL_TRIGGER_REASONS__c = 'Vendor Requires Review',OWNER_REVIEW__c ='Commercial Owner');
        insert new List<TPA_Table_Of_Responsibility_Settings__c>{respSetting1,respSetting2};
        System.debug('36.Number of Queries used in this apex code so far: ' + Limits.getQueries());
    }
    
    @isTest static void test_createOrUpdateAgreementForClient() {
        List<TPA_Request__c> requestList = [SELECT Id FROM TPA_Request__c LIMIT 2];
        TPA_Request__c request =  SRV_TPA_TPARequest.getRequestInfo(requestList[0].id);
        SRV_TPA_TPARequest classInstance = new SRV_TPA_TPARequest();
        TPA_Country_Codes__c countryCode = new TPA_Country_Codes__c(Name = 'USA',Country_Possible_Codes__c = 'US;U.S.;USA;United States Of America;U.S;U.S.A;United States;U.S.A.');
        insert countryCode;
        countryCode = new TPA_Country_Codes__c(Name = 'United Kingdom',Country_Possible_Codes__c = 'UK;GB;GBR');
        insert countryCode;
        Test.startTest();
        
        List<TPA_Additional_Term__c> addtionalTermList = new List<TPA_Additional_Term__c>();
        IMS_Legal_Entity__c imsLE = [Select Id, IMS_Master_Legal_Entity__c from IMS_Legal_Entity__C where TPA_Request__c = :request.Id][0];
        for(Integer i=0;i<3;i++){
            TPA_Additional_Term__c newAdditionalTerm = new TPA_Additional_Term__c();
            newAdditionalTerm.Name = 'Test'+i;
            newAdditionalTerm.TPA_Legal_Entity_1__c = imsLE.Id;
            newAdditionalTerm.Addtional_Term__c = 'Test Term' + i;
            newAdditionalTerm.Category__c = (i == 0 ? 'Data Asset Specific Ad-Hoc Term' : 'General Ad-Hoc Term' );
            newAdditionalTerm.Primary_Offering_Name__c = (i == 0 ? 'Real World Evidence' : 'Anonymized Patient-Level Data / Transaction-Level');
            newAdditionalTerm.Secondary_Offering_Name__c = (i == 0 ? 'Channel Dynamics Custom Study Name & Project Delivery Date:' : '');
            newAdditionalTerm.Country_of_Offering__c = (i == 0 ? 'US' : 'South Africa' );
            newAdditionalTerm.TPA_Request__c = request.Id;
            addtionalTermList.add(newAdditionalTerm);
        }
        for(Integer i=0;i<3;i++){
            TPA_Additional_Term__c newUseAdditionalTerm = new TPA_Additional_Term__c();
            newUseAdditionalTerm.Name = 'Test'+i;
            newUseAdditionalTerm.TPA_Legal_Entity_1__c = imsLE.Id;
            newUseAdditionalTerm.Addtional_Term__c = 'Test Term' + i;
            newUseAdditionalTerm.Category__c = (i == 0 ? 'Use Specific Ad-Hoc Terms' : 'Use/Offering Specific Ad-Hoc Terms' );
            newUseAdditionalTerm.Primary_Offering_Name__c = (i == 0 ? 'Real World Evidence' : 'Anonymized Patient-Level Data / Transaction-Level');
            newUseAdditionalTerm.Secondary_Offering_Name__c = (i == 0 ? 'tpa sec asset 2' : 'tpa sec asset 2');
            newUseAdditionalTerm.Use_Name__c = (i == 0 ? 'Expert Analysis for Legal or Governmental Purposes' : 'test purpose');
            newUseAdditionalTerm.Country_of_Offering__c = (i == 0 ? 'South Africa' : 'US' );
            newUseAdditionalTerm.TPA_Request__c = request.Id;
            addtionalTermList.add(newUseAdditionalTerm);            
        }
        
        insert addtionalTermList;
        request.Vendor_e_mail__c = 'test@test.com';
        request.Vendor_First_Name__c = 'firstName';
        request.Vendor_Contact_Last_Name__c = 'lastName';
        SRV_TPA_TPARequest.MlegalEntityToAdditionalTermsMap.put(imsLE.IMS_Master_Legal_Entity__c,addtionalTermList);
        SRV_TPA_TPARequest.updateAgreementFieldsForClient(request);
        request = SRV_TPA_TPARequest.tpaRequest;
		request = SRV_TPA_TPARequest.parentRequest;
		resString = SRV_TPA_TPARequest.dataAssetList;
        resId = classInstance.tpaRequestId;
		resString = SRV_TPA_TPARequest.requestNumber;
		resString = SRV_TPA_TPARequest.type;
		resString = SRV_TPA_TPARequest.LastAction;
		resUser = SRV_TPA_TPARequest.currentUser;
		resBool = SRV_TPA_TPARequest.create;
		//resMapString = SRV_TPA_TPARequest.resonForApprovalMap;
		resMapString = SRV_TPA_TPARequest.reasonForAmaApprovalMap;
		//resMapString = SRV_TPA_TPARequest.geoLevelDataAssetMap;
		//resMapOfMapString = SRV_TPA_TPARequest.PurposeGeoLevelDataAssetMap;
		resMapOfMapOfMapString = SRV_TPA_TPARequest.BUPurposeGeoLevelDataAssetMap;
        resMapString = SRV_TPA_TPARequest.getCountryCodeMap('TPA_Region_Country__c', 'Country__c');
        Test.stopTest();
    }
    
    @isTest static void test_createOrUpdateAgreementForVendor() {
        List<TPA_Request__c> requestList = [SELECT Id FROM TPA_Request__c LIMIT 3];
        SRV_TPA_TPARequest.tpaRequest = SRV_TPA_TPARequest.getRequestInfo(requestList[0].Id);
        TPA_Text_Editor__c  texteditor = [select Id, Page_Name__c, Page_Title__c, Page_Type__c, Content__c from TPA_Text_Editor__c where Page_Name__c = 'Is_Oncology_EMR__c'];
        Test.startTest();
        
        TPA_Request__c tpaRequest = SRV_TPA_TPARequest.updateAgreementFieldsForVendor(false);
        //SRV_TPA_TPARequest.tpaRequestAttachments = null;
        SRV_TPA_TPARequest.LastAction = 'Request Submitted By Client';
        SRV_TPA_TPARequest.requestNumber = 'TPA-028383';
        TPA_Request__c tpaParent = UTL_TPA_SetupTestData.getTestTPARequest();
        insert tpaParent;
        AgrAdditionalObj = UTL_TPA_SetupTestData.returnTPAAgreementAdditionalFieldObj(SRV_TPA_TPARequest.tpaRequest);
        insert AgrAdditionalObj;
        SRV_TPA_TPARequest.parentRequest = tpaParent;
        SRV_TPA_TPARequest.type = 'renew';
        SRV_TPA_TPARequest.createActivityHistoryForClient();
        SRV_TPA_TPARequest.type = 'clone';
        SRV_TPA_TPARequest.createActivityHistoryForClient();
        SRV_TPA_TPARequest.type = 'New';
        SRV_TPA_TPARequest.createActivityHistoryForClient();
        SRV_TPA_TPARequest.setEmailInitials('TU', 'BU', 'Test Subject');
        SRV_TPA_TPARequest.retriggerManualReviewEmail = true;
        SRV_TPA_TPARequest.retriggerManualReviewMail(tpaRequest);
        SRV_TPA_TPARequest.insertCommercialReasons();
        Test.stopTest();
    }
    
    @isTest static void test_createOrUpdateAgreementForRenewOrClone() {
        List<TPA_Request__c> requestList = [SELECT Id FROM TPA_Request__c LIMIT 3];
        SRV_TPA_TPARequest.tpaRequest = SRV_TPA_TPARequest.getRequestInfo(requestList[0].Id);
        
        Test.startTest();
        SRV_TPA_TPARequest.requestNumber = '123';
        SRV_TPA_TPARequest.LastAction = 'Request Edited By Client';
        SRV_TPA_TPARequest.type = 'Renew';
        TPA_Request__c tpaRequest = SRV_TPA_TPARequest.updateAgreementFieldsForVendor(false);
        
        SRV_TPA_TPARequest.type = 'Clone';
        tpaRequest = SRV_TPA_TPARequest.updateAgreementFieldsForVendor(false);
        Map<Id, Set<Id>> tmpSet = SRV_TPA_TPARequest.tpaOfferingNotificationAcctMappingMap;
        Test.stopTest();
    }
    
    
    @isTest static void test_createOrUpdateAgreement() {
        List<TPA_Request__c> requestList = [SELECT Id FROM TPA_Request__c LIMIT 3];
        SRV_TPA_TPARequest.tpaRequest = SRV_TPA_TPARequest.getRequestInfo(requestList[0].Id);
        SRV_TPA_TPARequest.reasonForAmaApprovalMap = new Map<String,String>();
        Test.startTest();
        TPA_Request__c tpaRequest = SRV_TPA_TPARequest.updateAgreementFieldsForVendor(true);
        Test.stopTest();        
    }
    
    @isTest static void test_useDefinationAttachment() {
        List<TPA_Request__c> requestList = [SELECT Id FROM TPA_Request__c LIMIT 1];
        SRV_TPA_TPARequest.tpaRequest = SRV_TPA_TPARequest.getRequestInfo(requestList[0].Id);
        Test.startTest();
        List<Attachment> lstAttachment = new List<Attachment>();
        lstAttachment.add(UTL_TPA_SetupTestData.addAttachment(requestList[0].Id, [Select Name from TPA_Request__c where Id = :requestList[0].Id].get(0).Name + '_TLLA' + '.pdf'));
        lstAttachment.add(UTL_TPA_SetupTestData.addAttachment(requestList[0].Id, [Select Name from TPA_Request__c where Id = :requestList[0].Id].get(0).Name + 'AMA_CSF' + '.pdf'));
        lstAttachment.add(UTL_TPA_SetupTestData.addAttachment(requestList[0].Id, [Select Name from TPA_Request__c where Id = :requestList[0].Id].get(0).Name + '_TLLA' + '.pdf_Completed'));
        lstAttachment.add(UTL_TPA_SetupTestData.addAttachment(requestList[0].Id, [Select Name from TPA_Request__c where Id = :requestList[0].Id].get(0).Name + 'AMA_CSF' + '.pdf_completed'));
        insert lstAttachment;
        //SRV_TPA_TPARequest.tpaAttachmentId = [Select Id, Name, Body from Attachment where ParentId = :requestList[0].Id][0].Id;
        SRV_TPA_TPARequest o = new SRV_TPA_TPARequest();
        SRV_TPA_TPARequest.getTPAContactEmailList(new List<Id>{requestList[0].Id});
        SRV_TPA_TPARequest.getLocalizedRequests(requestList[0].Id);
        SRV_TPA_TPARequest.IMSMasterLegalEntityList();
        SRV_TPA_TPARequest.getContactsForRequest(requestList[0].Id);
        SRV_TPA_TPARequest.validateAgreementForInEffect(requestList[0].Id);
        SRV_TPA_TPARequest.isDynamicNotificationRequiredForVendor(SRV_TPA_TPARequest.tpaRequest);
        SRV_TPA_TPARequest.getTPANotificationEmailDraft(new List<String>{'test@test.com'}, new List<string>{'testcc@test.com'}, 'VSN TP Processor Notification', 'English', requestList[0].Id, true, [Select Id,Name, Body from Attachment where ParentId = :requestList[0].Id], null, TRUE, FALSE, SRV_TPA_TPARequest.tpaRequest);
        SRV_TPA_TPARequest.sendEmailDirectToClient(SRV_TPA_TPARequest.tpaRequest,'Email to Client IQVIA Aisle off', 'bodtext');
        SRV_TPA_TPARequest.sendEmailDirectToClient(SRV_TPA_TPARequest.tpaRequest,'Email Direct to Client Offering', 'bodtext');
        SRV_TPA_TPARequest.sendEmailToClientToNotifyAisleOff(SRV_TPA_TPARequest.tpaRequest,'Email to Client IQVIA Aisle off');
        Test.stopTest();
    }
    
    @isTest static void test_sendRenewalAndExpirationMail() {
        Address__c testAccount1 = UTL_TPA_SetupTestData.getAccount();
        testAccount1.Name = 'Test Acc';
        insert testAccount1;
        Test.startTest();
        TPA_Request__c tpaRequest1 = UTL_TPA_SetupTestData.getTestTPARequest();
        tpaRequest1.Request_Status__c = 'In Effect';
        tpaRequest1.OwnerId = UserInfo.getUserId();
        tpaRequest1.Service_Provider_Address__c = testAccount1.Id;
        tpaRequest1.Client_Address__c = testAccount1.Id;
        tpaRequest1.TP_Processor_Email__c = 'test@test.com';
        tpaRequest1.Client_Language__c = 'Japanese';
        tpaRequest1.Vendor_Language__c = 'Japanese';
        tpaRequest1.Vendor_Billing_Mailing_Country__c = 'united states';
        tpaRequest1.Is_CPC_Renewal_Notice_Sent__c = true;
        tpaRequest1.Is_CPC_Expiration_Notice_Sent__c = true;
        tpaRequest1.Is_CPC_Post_Expiration_Notice_Sent__c = true;
        tpaRequest1.Vendor_Compliance_Email__c = 'test@test.com';
        insert tpaRequest1;
        SRV_TPA_TPARequest.tpaRequest = SRV_TPA_TPARequest.getRequestInfo(tpaRequest1.Id);
        SRV_TPA_TPARequest.getTpaDataAssetReqsMap(new Set<id>{tpaRequest1.Id});

        SRV_TPA_TPARequest.sendRenewalAndExpirationMail(new List<TPA_Request__c>{SRV_TPA_TPARequest.tpaRequest});
        Test.stopTest();
    }
    
    @isTest static void test_updateAgreementFieldsForVendorSpecialVendor(){
       Address__c testAccount1 = UTL_TPA_SetupTestData.getAccount();
        Map<Id,List<TPA_Request__c>> mapIdwithRequests = new Map<Id,List<TPA_Request__c>>();
        List<TPA_Request__c> reqList = new List<TPA_Request__c>();
        Map<Id,Id> reqIdVendorId = new Map<Id,Id>();
        Test.startTest();
        testAccount1.Name = 'Test Komodo';
        testAccount1.Primary_Vendor_Address__c = true;
        insert testAccount1;

        TPA_Request__c tpaRequest1 = UTL_TPA_SetupTestData.getTestTPARequest();
        tpaRequest1.Request_Status__c = 'In Effect';
        tpaRequest1.OwnerId = UserInfo.getUserId();
        tpaRequest1.Service_Provider_Address__c = testAccount1.Id;
        tpaRequest1.TP_Processor_Email__c = 'test@test.com';
        tpaRequest1.Client_Address__c = testAccount1.Id;
        tpaRequest1.Client_Language__c = 'Japanese';
        tpaRequest1.Vendor_Language__c = 'Japanese';
        tpaRequest1.Vendor_Billing_Mailing_Country__c = 'united states';
        insert tpaRequest1;
        SRV_TPA_TPARequest.tpaRequest = SRV_TPA_TPARequest.getRequestInfo(tpaRequest1.Id);
        SRV_TPA_TPARequest.sendReminderMailtoTPProcessorAbtStatusUpdate(SRV_TPA_TPARequest.tpaRequest);
        TPA_Request__c tpaRequest = SRV_TPA_TPARequest.updateAgreementFieldsForVendor(false);
        Address__c testAccount3 = [select id, name from Address__c where name = 'Test Komodo'];
        SRV_TPA_TPARequest.gettpaOfferingNotificationAcctMappingMap(testAccount3.id);
        SRV_TPA_TPARequest.retriggerManualReviewMail(tpaRequest);
        Test.stopTest();
    }
    @isTest static void test_updateAgreementFieldsForVendorDLIMI() {
        Address__c testAccount1 = UTL_TPA_SetupTestData.getAccount();
        Map<Id,List<TPA_Request__c>> mapIdwithRequests = new Map<Id,List<TPA_Request__c>>();
        List<TPA_Request__c> reqList = new List<TPA_Request__c>();
        Map<Id,Id> reqIdVendorId = new Map<Id,Id>();
        Test.startTest();
        testAccount1.Name = 'Test Signum';
        testAccount1.Primary_Vendor_Address__c = true;
        insert testAccount1;

        TPA_Request__c tpaRequest1 = UTL_TPA_SetupTestData.getTestTPARequest();
        tpaRequest1.Request_Status__c = 'In Effect';
        tpaRequest1.OwnerId = UserInfo.getUserId();
        tpaRequest1.Service_Provider_Address__c = testAccount1.Id;
        tpaRequest1.TP_Processor_Email__c = 'test@test.com';
        tpaRequest1.Client_Address__c = testAccount1.Id;
        tpaRequest1.Client_Language__c = 'Japanese';
        tpaRequest1.Vendor_Language__c = 'Japanese';
        tpaRequest1.Vendor_Billing_Mailing_Country__c = 'united states';
        insert tpaRequest1;
        List<TPA_Contact__c> tpaContacts = new List<TPA_Contact__c>();
        tpaContacts.add(new TPA_Contact__c(TPA_Request__c = tpaRequest1.Id, Email__c = 'test@mail.com', Type__c ='Additional Vendor Contact'));
        tpaContacts.add(new TPA_Contact__c(TPA_Request__c = tpaRequest1.Id, Email__c = 'test@mail.com', Type__c ='Additional Client Contact'));
		insert tpaContacts;
        SRV_TPA_TPARequest.tpaRequest = SRV_TPA_TPARequest.getRequestInfo(tpaRequest1.Id);
        SRV_TPA_TPARequest.DDNAckPendingRecords = new List<TPA_Request__c>();
        SRV_TPA_TPARequest.DDNAckPendingRecords.add(SRV_TPA_TPARequest.tpaRequest);
        SRV_TPA_TPARequest.sendDataDestructionAckOutstandingMail(SRV_TPA_TPARequest.tpaRequest);
        reqList.add(SRV_TPA_TPARequest.tpaRequest);
        mapIdwithRequests.put(tpaRequest1.Service_Provider_Address__c,reqList);
        reqIdVendorId.put(tpaRequest1.Id,tpaRequest1.Service_Provider_Address__c);
        SRV_TPA_TPARequest.sendDataDestructionAckOutstandingMailforBulkRequest(reqList,mapIdwithRequests,mapIdwithRequests,reqIdVendorId);
        SRV_TPA_TPARequest.sendMailtoTPProcessorAbtStatusUpdate(SRV_TPA_TPARequest.tpaRequest,'Awaiting Vendor Submission', 'Pending Vendor Response on Data Destruction from Prior TPAs');
        SRV_TPA_TPARequest.sendReminderMailtoTPProcessorAbtStatusUpdate(SRV_TPA_TPARequest.tpaRequest);
        TPA_Request__c tpaRequest = SRV_TPA_TPARequest.updateAgreementFieldsForVendor(false);
        Address__c testAccount3 = [select id, name from Address__c where name = 'Test Signum'];
        SRV_TPA_TPARequest.gettpaOfferingNotificationAcctMappingMap(testAccount3.id);
        SRV_TPA_TPARequest.retriggerManualReviewMail(tpaRequest);
        Test.stopTest();
    }
    @isTest static void test_updateAgreementFieldsForVendorMedpro() {
        Address__c testAccount1 = UTL_TPA_SetupTestData.getAccount();
        Map<Id,List<TPA_Request__c>> mapIdwithRequests = new Map<Id,List<TPA_Request__c>>();
        List<TPA_Request__c> reqList = new List<TPA_Request__c>();
        Map<Id,Id> reqIdVendorId = new Map<Id,Id>();
        Test.startTest();
        testAccount1.Name = 'Test Medpro';
        testAccount1.Primary_Vendor_Address__c = true;
        insert testAccount1;
        
        TPA_Request__c tpaRequest1 = UTL_TPA_SetupTestData.getTestTPARequest();
        tpaRequest1.Request_Status__c = 'In Effect';
        tpaRequest1.OwnerId = UserInfo.getUserId();
        tpaRequest1.Service_Provider_Address__c = testAccount1.Id;
        tpaRequest1.TP_Processor_Email__c = 'test@test.com';
        tpaRequest1.Client_Address__c = testAccount1.Id;
        tpaRequest1.Client_Language__c = 'Japanese';
        tpaRequest1.Vendor_Language__c = 'Japanese';
        tpaRequest1.Vendor_Billing_Mailing_Country__c = 'united states';
        insert tpaRequest1;
        SRV_TPA_TPARequest.tpaRequest = SRV_TPA_TPARequest.getRequestInfo(tpaRequest1.Id);
        SRV_TPA_TPARequest.DDNAckPendingRecords = new List<TPA_Request__c>();
        SRV_TPA_TPARequest.DDNAckPendingRecords.add(SRV_TPA_TPARequest.tpaRequest);
        SRV_TPA_TPARequest.sendDataDestructionAckOutstandingMail(SRV_TPA_TPARequest.tpaRequest);
        reqList.add(SRV_TPA_TPARequest.tpaRequest);
        mapIdwithRequests.put(tpaRequest1.Service_Provider_Address__c,reqList);
        reqIdVendorId.put(tpaRequest1.Id,tpaRequest1.Service_Provider_Address__c);
        SRV_TPA_TPARequest.sendDataDestructionAckOutstandingMailforBulkRequest(reqList,mapIdwithRequests,mapIdwithRequests,reqIdVendorId);
        SRV_TPA_TPARequest.sendMailtoTPProcessorAbtStatusUpdate(SRV_TPA_TPARequest.tpaRequest,'Awaiting Vendor Submission', 'Pending Vendor Response on Data Destruction from Prior TPAs');
        SRV_TPA_TPARequest.sendReminderMailtoTPProcessorAbtStatusUpdate(SRV_TPA_TPARequest.tpaRequest);
        TPA_Request__c tpaRequest = SRV_TPA_TPARequest.updateAgreementFieldsForVendor(false);
        Address__c testAccount3 = [select id, name from Address__c where name = 'Test Medpro'];
        SRV_TPA_TPARequest.gettpaOfferingNotificationAcctMappingMap(testAccount3.id);
        Test.stopTest();
    }
    
    @isTest static void test_expiration() {
        Test.startTest();
        //UTL_TPA_SetupTestData.createTPASettingsDataBasedOnOrganization();
        TPA_Request__c reqObj = [Select id,name from TPA_Request__c limit 1];
        AgrAdditionalObj = UTL_TPA_SetupTestData.getTPAAgreementAdditionalFieldObj(reqObj);
        SRV_TPA_TPARequest.tpaRequest = SRV_TPA_TPARequest.getRequestInfo(reqObj.Id);
        SRV_TPA_TPARequest.getDDNAckPendingRequests(SRV_TPA_TPARequest.tpaRequest.Service_Provider_Address__c);
        SRV_TPA_TPARequest.manualApproval(SRV_TPA_TPARequest.tpaRequest);
        SRV_TPA_TPARequest.sendDataDestructionAckOutstandingMail(SRV_TPA_TPARequest.tpaRequest);
        SRV_TPA_TPARequest.sendMailtoTPProcessorAbtSignaturetoHoldForBulk(new List<TPA_Request__c>{SRV_TPA_TPARequest.tpaRequest},new Map<Id,String>{reqObj.Id => 'Awaiting Vendor Submisssion'});
        List<TPA_Request__c> reqList = new List<TPA_Request__c>();
        Map<Id,String> mapIdwithRequests = new Map<Id,String>();
        reqList.add(SRV_TPA_TPARequest.tpaRequest);
       	mapIdwithRequests.put(SRV_TPA_TPARequest.tpaRequest.Service_Provider_Address__c,'In Review by IQVIA');
        SRV_TPA_TPARequest.sendMailtoTPProcessorAbtSignaturetoHoldForBulk(reqList,mapIdwithRequests);
        SRV_TPA_TPARequest.sendMailtoTPProcessorAbtStatusUpdateFromComplianceHold(SRV_TPA_TPARequest.tpaRequest);
        Test.stopTest();
    }
    
    @isTest static void test_updateAgreementFieldsForVendorRepwise() {
        Address__c testAccount1 = UTL_TPA_SetupTestData.getAccount();
        testAccount1.Name = 'Test Repwise';
        insert testAccount1;
        Test.startTest();
        TPA_Request__c tpaRequest1 = UTL_TPA_SetupTestData.getTestTPARequest();
        tpaRequest1.Request_Status__c = 'In Effect';
        tpaRequest1.OwnerId = UserInfo.getUserId();
        tpaRequest1.Service_Provider_Address__c = testAccount1.Id;
        tpaRequest1.TP_Processor_Email__c = 'test@test.com';
        tpaRequest1.Client_Address__c = testAccount1.Id;
        tpaRequest1.Client_Language__c = 'English';
        tpaRequest1.Vendor_Language__c = 'Japanese';
        tpaRequest1.Vendor_Billing_Mailing_Country__c = 'united states';
        insert tpaRequest1;
        SRV_TPA_TPARequest.tpaRequest = SRV_TPA_TPARequest.getRequestInfo(tpaRequest1.Id);
        SRV_TPA_TPARequest.isUseCRM = true;
        SRV_TPA_TPARequest.isSouthAfrica = true;
        SRV_TPA_TPARequest.isSubnationalOff = true;
        
        SRV_TPA_TPARequest.sendDataDestructionAckOutstandingMail(SRV_TPA_TPARequest.tpaRequest);
        SRV_TPA_TPARequest.sendMailtoTPProcessorAbtStatusUpdate(SRV_TPA_TPARequest.tpaRequest,'Awaiting Vendor Submission', 'Pending Vendor Response on Data Destruction from Prior TPAs');
        SRV_TPA_TPARequest.sendReminderMailtoTPProcessorAbtStatusUpdate(SRV_TPA_TPARequest.tpaRequest);
        TPA_Request__c tpaRequest = SRV_TPA_TPARequest.updateAgreementFieldsForVendor(false);
        Address__c testAccount3 = [select id, name from Address__c where name = 'Test Repwise'];
        SRV_TPA_TPARequest.gettpaOfferingNotificationAcctMappingMap(testAccount3.id);
        Test.stopTest();
    }
    
    @isTest static void test_updateAgreementFieldsForVendorRepwise2() {
        Address__c testAccountyy = UTL_TPA_SetupTestData.getAccount();
        testAccountyy.Name = 'Test deepintent Precision';
        insert testAccountyy;
        Test.startTest();
        TPA_Request__c tpaRequest1 = UTL_TPA_SetupTestData.getTestTPARequest();
        tpaRequest1.Request_Status__c = 'In Effect';
        tpaRequest1.OwnerId = UserInfo.getUserId();
        tpaRequest1.Service_Provider_Address__c = testAccountyy.Id;
        tpaRequest1.TP_Processor_Email__c = 'test@test.com';
        tpaRequest1.Client_Address__c = testAccountyy.Id;
        tpaRequest1.Client_Language__c = 'English';
        tpaRequest1.Vendor_Language__c = 'Japanese';
        tpaRequest1.Vendor_Billing_Mailing_Country__c = 'united states';
        insert tpaRequest1;
        SRV_TPA_TPARequest.tpaRequest = SRV_TPA_TPARequest.getRequestInfo(tpaRequest1.Id);
        
        SRV_TPA_TPARequest.isUseCRM = true;
        SRV_TPA_TPARequest.isSouthAfrica = true;
        SRV_TPA_TPARequest.isSubnationalOff = true;
        SRV_TPA_TPARequest.isLAADOffering = true;
        SRV_TPA_TPARequest.isAPLDOffSpecVendors = true;
        SRV_TPA_TPARequest.isLongPrescriData = true;
        SRV_TPA_TPARequest.isMedClaimsData = true;
        SRV_TPA_TPARequest.isVendorChecklistChanges = true;
        SRV_TPA_TPARequest.isVendorChecklistChanges = true;
        SRV_TPA_TPARequest.updateAgreementFieldsForVendor(true);
        
        
        SRV_TPA_TPARequest.sendDataDestructionAckOutstandingMail(SRV_TPA_TPARequest.tpaRequest);
        SRV_TPA_TPARequest.sendMailtoTPProcessorAbtStatusUpdate(SRV_TPA_TPARequest.tpaRequest,'Awaiting Vendor Submission', 'Pending Vendor Response on Data Destruction from Prior TPAs');
        SRV_TPA_TPARequest.sendReminderMailtoTPProcessorAbtStatusUpdate(SRV_TPA_TPARequest.tpaRequest);
        TPA_Request__c tpaRequest = SRV_TPA_TPARequest.updateAgreementFieldsForVendor(false);
        Address__c testAccount123 = [select id, name from Address__c where name = 'Test deepintent Precision'];
        SRV_TPA_TPARequest.gettpaOfferingNotificationAcctMappingMap(testAccount123.id);
        Test.stopTest();
    }
    
    @isTest static void test_getTPASecondaryDataAsset() {
        List<TPA_Data_Asset__c> dataAssetList = [SELECT Id,Is_IMS_AGProduct__c,Asset_Name__c FROM TPA_Data_Asset__c LIMIT 1];
        Set<Id> setTPADataAsset = new Set<Id>();
        setTPADataAsset.add(dataAssetList[0].id);
        SRV_TPA_TPARequest.getTPASecondaryDataAsset(setTPADataAsset);
        Test.startTest();
        List<TPA_Purpose__c> purposeList = [SELECT Id FROM TPA_Purpose__c LIMIT 1];
        Set<Id> setTPAPurpose = new Set<Id>();
        setTPAPurpose.add(purposeList[0].id);
        SRV_TPA_TPARequest.getPrimaryDataAssetMap(setTPAPurpose);
        SRV_TPA_TPARequest.tpaDataAssetListCopy(setTPAPurpose);
        SRV_TPA_TPARequest.getPurposeIdDataAssetMap(setTPAPurpose);
        Test.stopTest(); 
    } 
    
    @isTest static void test_updateActivityHistory() {
        List<TPA_Request__c> requestList = [SELECT Id FROM TPA_Request__c LIMIT 1];
        
        Account acc2 = [select id, Name,Client_Account_Compliance__c, Vendor_Account_Compliance__c from Account limit 1];
        Address__c testAccountAddress = UTL_TPA_SetupTestData.getAccount();
        testAccountAddress.Account__c = acc2.Id;
        testAccountAddress.Name = 'Medpro Repwise deepintent';
        insert testAccountAddress;
        Test.startTest();
        
        
        AgrAdditionalObj = UTL_TPA_SetupTestData.getTPAAgreementAdditionalFieldObj(requestList[0]);
        SRV_TPA_TPARequest.tpaRequest = SRV_TPA_TPARequest.getRequestInfo(requestList[0].Id);
        SRV_TPA_TPARequest.tpaRequest.Service_Provider_Address__c = testAccountAddress.Id;
        SRV_TPA_TPARequest.tpaRequest.isClientOnComplianceHold__c = true;
        SRV_TPA_TPARequest.tpaRequest.isVendorOnComplianceHold__c = true;
        SRV_TPA_TPARequest.tpaRequest.Data_Period_Start_Date__c = Date.Today().addDays(-40);
        SRV_TPA_TPARequest.tpaRequest.Data_Period_End_Date__c = Date.today();
        SRV_TPA_TPARequest.tpaRequest.Vendor_Website__c = 'testWebsite';
        update SRV_TPA_TPARequest.tpaRequest;
        List<TPA_Additional_Term__c> addtionalTermList = new List<TPA_Additional_Term__c>();
        IMS_Legal_Entity__c imsLE = [Select Id, IMS_Master_Legal_Entity__c from IMS_Legal_Entity__C where TPA_Request__c = :SRV_TPA_TPARequest.tpaRequest.Id][0];
        for(Integer i=0;i<3;i++){
            TPA_Additional_Term__c newAdditionalTerm = new TPA_Additional_Term__c();
            newAdditionalTerm.Name = 'Test'+i;
            newAdditionalTerm.TPA_Legal_Entity_1__c = imsLE.Id;
            newAdditionalTerm.Addtional_Term__c = 'Test Term' + i;
            newAdditionalTerm.Category__c = (i == 0 ? 'Data Asset Specific Ad-Hoc Term' : 'General Ad-Hoc Term' );
            newAdditionalTerm.Primary_Offering_Name__c = (i == 0 ? 'Real World Evidence' : 'Anonymized Patient-Level Data / Transaction-Level');
            newAdditionalTerm.Secondary_Offering_Name__c = (i == 0 ? 'Channel Dynamics Custom Study Name & Project Delivery Date:' : '');
            newAdditionalTerm.Country_of_Offering__c = (i == 0 ? 'US' : 'South Africa' );
            newAdditionalTerm.TPA_Request__c = SRV_TPA_TPARequest.tpaRequest.Id;
            addtionalTermList.add(newAdditionalTerm);            
        }
        for(Integer i=0;i<3;i++){
            TPA_Additional_Term__c newUseAdditionalTerm = new TPA_Additional_Term__c();
            newUseAdditionalTerm.Name = 'Test'+i;
            newUseAdditionalTerm.TPA_Legal_Entity_1__c = imsLE.Id;
            newUseAdditionalTerm.Addtional_Term__c = 'Test Term' + i;
            newUseAdditionalTerm.Category__c = (i == 0 ? 'Use Specific Ad-Hoc Terms' : 'Use/Offering Specific Ad-Hoc Terms' );
            newUseAdditionalTerm.Primary_Offering_Name__c = (i == 0 ? 'Real World Evidence' : 'Anonymized Patient-Level Data / Transaction-Level');
            newUseAdditionalTerm.Secondary_Offering_Name__c = (i == 0 ? 'tpa sec asset 2' : 'tpa sec asset 2');
            newUseAdditionalTerm.Use_Name__c = (i == 0 ? 'Expert Analysis for Legal or Governmental Purposes' : 'test purpose');
            newUseAdditionalTerm.Country_of_Offering__c = (i == 0 ? 'South Africa' : 'US' );
            newUseAdditionalTerm.TPA_Request__c = SRV_TPA_TPARequest.tpaRequest.Id;
            addtionalTermList.add(newUseAdditionalTerm);            
        }
        
        insert addtionalTermList;
        List<TPA_Additional_Term__c> addocList = new List<TPA_Additional_Term__c>();
        TPA_Additional_Term__c addTerm = new TPA_Additional_Term__c(Name = 'name', Addtional_Term__c  = 'test123',Primary_Offering_Name__c = 'Oncology', Category__c = 'Data Asset Specific Ad-Hoc Term', TPA_Request__c =SRV_TPA_TPARequest.tpaRequest.Id );
        addocList.add(addTerm);
        TPA_Additional_Term__c addTerm1 = new TPA_Additional_Term__c(Name = 'name2', Addtional_Term__c  = 'test1234', Category__c = 'General Ad-Hoc Term', TPA_Request__c =SRV_TPA_TPARequest.tpaRequest.Id );
        addocList.add(addTerm1);
        insert addocList;
        List<TPA_Commercial_Review__c> tpaCommercialReviewList = new List<TPA_Commercial_Review__c>();
        
        TPA_Commercial_Review__c comRev1 = new TPA_Commercial_Review__c(Commercial_Owner_Name__c = UserInfo.getUserName(), 
                                                                        Associated_Offering_to_Review__c = 'Oncology electronic medical records data', 
                                                                        Associated_Use_to_Review__c = 'Data Cleansing', 
                                                                        Manual_Review_Reason__c = 'Other Offering Selected',  
                                                                        Action_Needed_By__c = 'Commercial Owner', 
                                                                        TPA_Request__c = requestList[0].Id, 
                                                                        Action__c = 'Under Validation', 
                                                                        Receiver_s_Email__c = 'test@gmail.com',
                                                                        TP_US_Email__c = UserInfo.getUserEmail(), 
                                                                        Date_of_Action_Response__c = Date.today(), 
                                                                        TP_Country_Email__c = 'test@gmail.com');
        tpaCommercialReviewList.add(comRev1);
        
        TPA_Commercial_Review__c comRev2 = new TPA_Commercial_Review__c(Commercial_Owner_Name__c = UserInfo.getUserName(), 
                                                                        Associated_Offering_to_Review__c = 'test', 
                                                                        Associated_Use_to_Review__c = 'Data Cleansing', 
                                                                        Manual_Review_Reason__c = 'Other Offering Selected', 
                                                                        Action_Needed_By__c = 'TP-country', 
                                                                        TPA_Request__c = requestList[0].Id, 
                                                                        Action__c = 'Assigned to Commercial Owner (CO) – Awaiting CO Review', 
                                                                        Receiver_s_Email__c = 'test@gmail.com',
                                                                        TP_US_Email__c = UserInfo.getUserEmail(), 
                                                                        Date_of_Action_Response__c = Date.today(), 
                                                                        TP_Country_Email__c = 'test@gmail.com');
        tpaCommercialReviewList.add(comRev2);
        
        TPA_Commercial_Review__c comRev3 = new TPA_Commercial_Review__c(Commercial_Owner_Name__c = UserInfo.getUserName(), 
                                                                        Associated_Offering_to_Review__c = 'Xponent PlanTrak MIDAS Promo', 
                                                                        Associated_Use_to_Review__c = 'test', 
                                                                        Manual_Review_Reason__c = 'Other Use Selected',  
                                                                        Action_Needed_By__c = 'Commercial Owner', 
                                                                        Additional_Questions_For_TP_Processor__c = 'Question;',
                                                                        TPA_Request__c = requestList[0].Id, 
                                                                        Receiver_s_Email__c = 'test@gmail.com',
                                                                        Action__c = 'Approved for this specific TPA. The Vendor and specified Use(s) and IQVIA Offerings specific combination can be auto-approved moving forward for future requests', 
                                                                        TP_US_Email__c = UserInfo.getUserEmail(), 
                                                                        Date_of_Action_Response__c = Date.today(), 
                                                                        TP_Country_Email__c = 'test@gmail.com');
        tpaCommercialReviewList.add(comRev3);
        
        TPA_Commercial_Review__c comRev4 = new TPA_Commercial_Review__c(Commercial_Owner_Name__c = UserInfo.getUserName(), 
                                                                        Associated_Offering_to_Review__c = 'Patient Reference File', 
                                                                        Associated_Use_to_Review__c = 'test', 
                                                                        Manual_Review_Reason__c = 'Other Use Selected', 
                                                                        Action_Needed_By__c = 'Commercial Owner', 
                                                                        Status__c = 'Complete',
                                                                        TPA_Request__c = requestList[0].Id, 
                                                                        Action__c = 'Assigned to Commercial Owner (CO) – Awaiting CO Review', 
                                                                        Receiver_s_Email__c = 'test1@gmail.com;test@gmail.com',
                                                                        TP_US_Email__c = UserInfo.getUserEmail(), 
                                                                        Date_of_Action_Response__c = Date.today(), 
                                                                        TP_Country_Email__c = 'test@gmail.com');
        tpaCommercialReviewList.add(comRev4);
        
        TPA_Commercial_Review__c comRev5 = new TPA_Commercial_Review__c(Commercial_Owner_Name__c = UserInfo.getUserName(), 
                                                                        Associated_Offering_to_Review__c = 'TERRITORIAL', 
                                                                        Associated_Use_to_Review__c = 'test', 
                                                                        Manual_Review_Reason__c = 'Other Use', 
                                                                        Action_Needed_By__c = 'TP-US',
                                                                        Action__c = 'Questions / Comments',
                                                                        TPA_Request__c = requestList[0].Id, 
                                                                        Receiver_s_Email__c = 'test1@gmail.com;test@gmail.com',
                                                                        TP_US_Email__c = UserInfo.getUserEmail(), 
                                                                        Date_of_Action_Response__c = date.today(), 
                                                                        TP_Country_Email__c = 'test@gmail.com');
        tpaCommercialReviewList.add(comRev5);
        TPA_Commercial_Review__c comRev6 = new TPA_Commercial_Review__c(Commercial_Owner_Name__c = UserInfo.getUserName(), 
                                                                        Associated_Offering_to_Review__c = 'MIDAS', 
                                                                        Associated_Use_to_Review__c = 'aTest TPA Purpose', 
                                                                        Manual_Review_Reason__c = 'Offering Requires Secondary Commercial Review', 
                                                                        Action_Needed_By__c = 'TP-US',
                                                                        TPA_Request__c = requestList[0].Id, 
                                                                        Status__c = 'Awaiting to Send: Primary Commercial Owner Not Complete', 
                                                                        TP_US_Email__c = UserInfo.getUserEmail(), 
                                                                        Date_of_Action_Response__c = date.today(), 
                                                                        TP_Country_Email__c = 'test@gmail.com');
        tpaCommercialReviewList.add(comRev6);
        
        insert tpaCommercialReviewList;
        SRV_TPA_TPARequest.updateActivityHistory(requestList[0].Id, 'Test Subject', true);
        //SRV_TPA_TPARequest.resonForApprovalMap = new Map<String,String>();
        SRV_TPA_TPARequest.reasonForAmaApprovalMap = new Map<String,String>();
        SRV_TPA_TPARequest.approvalNotificationMap = new Map<String,String>();
        List<String> tpProcessorEmailId = new List<String>();
        tpProcessorEmailId.add('Test@gmail.com');
        SRV_TPA_TPARequest.manualApproval(SRV_TPA_TPARequest.tpaRequest);
        SRV_TPA_TPARequest.sendApprovalMail('Test@gmail.com', tpProcessorEmailId );
        SRV_TPA_TPARequest.sendTPAComplianceHoldMail('Test@gmail.com', tpProcessorEmailId );
        SRV_TPA_TPARequest.sendAutoApprovalMail('Test@gmail.com', tpProcessorEmailId );
        SRV_TPA_TPARequest.sendApprovalMailToCommericialOwnerForBulk();
        comRev2 = new TPA_Commercial_Review__c(Commercial_Owner_Name__c = UserInfo.getUserName(), 
                                               Associated_Offering_to_Review__c = 'test', 
                                               Associated_Use_to_Review__c = 'Data Cleansing', 
                                               Manual_Review_Reason__c = 'Vendor Requires Secondary Review',  
                                               Action_Needed_By__c = 'Management', 
                                               TPA_Request__c = requestList[0].Id, 
                                               Action__c = 'Under Validation', 
                                               Receiver_s_Email__c = 'test@gmail.com',
                                               TP_US_Email__c = UserInfo.getUserEmail(), 
                                               TP_Country_Email__c = 'test@gmail.com');
        insert comRev2;
        SRV_TPA_TPARequest.sendFinalReviewMail = true;
        SRV_TPA_TPARequest.sendApprovalMailToCommericialOwnerForBulk();
        SRV_TPA_TPARequest.sendFinalReviewMail = false;
        comRev3 = new TPA_Commercial_Review__c(Commercial_Owner_Name__c = UserInfo.getUserName(), 
                                               Associated_Offering_to_Review__c = 'test', 
                                               Associated_Use_to_Review__c = 'Data Cleansing', 
                                               Manual_Review_Reason__c = 'Offering Requires Secondary Commercial Review',  
                                               Action_Needed_By__c = 'Commercial Owner', 
                                               TPA_Request__c = requestList[0].Id, 
                                               Action__c = 'Under Validation', 
                                               Receiver_s_Email__c = 'test@gmail.com',
                                               TP_US_Email__c = UserInfo.getUserEmail(), 
                                               TP_Country_Email__c = 'test@gmail.com');
        insert comRev3;
        comRev4 = new TPA_Commercial_Review__c(Commercial_Owner_Name__c = UserInfo.getUserName(), 
                                                                        //Is_ReviewForm_Acknowledged__c, 
                                                                        Associated_Offering_to_Review__c = 'test', 
                                                                        Associated_Use_to_Review__c = 'test', 
                                                                        Manual_Review_Reason__c = 'Vendor - Use Secondary Review by',  
                                                                        Action_Needed_By__c = 'Commercial Owner', 
                                                                        TPA_Request__c = requestList[0].Id, 
                                                                        Status__c = 'Approved', 
                                                                        Action__c = 'Approved for this specific TPA request', 
                                                                        Receiver_s_Email__c = 'test@gmail.com',
                                                                        TP_US_Email__c = UserInfo.getUserEmail(), 
                                                                        //Additional_Questions_For_TP_Processor__c, 
                                                                        TP_Country_Email__c = 'test@gmail.com');
        insert comrev4;
        SRV_TPA_TPARequest.sendSecondaryOffReviewMail = true;
        SRV_TPA_TPARequest.sendApprovalMailToCommericialOwnerForBulk();
        SRV_TPA_TPARequest.sendSecondaryOffReviewMail = false;
        Test.stopTest();
    }
    
    @isTest static void test_updateActivityHistory1() {
        List<TPA_Request__c> requestList = [SELECT Id FROM TPA_Request__c LIMIT 1];
        AgrAdditionalObj = UTL_TPA_SetupTestData.getTPAAgreementAdditionalFieldObj(requestList[0]);
        SRV_TPA_TPARequest.tpaRequest = SRV_TPA_TPARequest.getRequestInfo(requestList[0].Id);
        
        //SRV_TPA_TPARequest.resonForApprovalMap = new Map<String,String>();
        SRV_TPA_TPARequest.reasonForAmaApprovalMap = new Map<String,String>();
        SRV_TPA_TPARequest.approvalNotificationMap = new Map<String,String>();
        List<String> tpProcessorEmailId = new List<String>();
        tpProcessorEmailId.add('Test@gmail.com');
        Test.startTest();
        SRV_TPA_TPARequest.manualApproval(SRV_TPA_TPARequest.tpaRequest);
        Set<Id> purposeIds = new Set<Id>();
        for(TPA_Purpose__c purpose : SRV_TPA_TPARequest.getPurposesList(SRV_TPA_TPARequest.tpaRequest.Id)) {
            purposeIds.add(purpose.Id);
        }
		(new SRV_TPA_TPARequest()).getPrimaryDataAssetMapCopy(purposeIds);
        (new SRV_TPA_TPARequest()).tpaDataAssetListNew(purposeIds);
        
        SRV_TPA_TPARequest.getOfferingsList(purposeIds);
        SRV_TPA_TPARequest.getUseIdOfferingsMap(purposeIds);
        List<TPA_Commercial_Review__c> temp = SRV_TPA_TPARequest.ListOfComReviwer;
        set<String> tme = SRV_TPA_TPARequest.TpaTextTerms;
        
       Map<Id, List<TPA_Data_Asset__c>> useIdDataAssetMap = SRV_TPA_TPARequest.getPurposeIdDataAssetMap( purposeIds );
        SRV_TPA_TPARequest.useOfferingsCategoryWatchMap = new Map<String, Watch_List__c>();
        SRV_TPA_TPARequest.watchListsToBeUpserted = new List<Watch_List__c>();
        SRV_TPA_TPARequest.isRunCommercialAutoLogic = true;
        SRV_TPA_TPARequest.createUpdateWatchList(SRV_TPA_TPARequest.tpaRequest,true,null,null,null,useIdDataAssetMap);
        SRV_TPA_TPARequest.getPurposeAndDescriptionList(requestList[0].Id);
        Test.stopTest();
    }
    
    @isTest static void test_updateActivityHistory2() {
        List<TPA_Request__c> requestList = [SELECT Id FROM TPA_Request__c LIMIT 1];
        SRV_TPA_TPARequest.tpaRequest = SRV_TPA_TPARequest.getRequestInfo(requestList[0].Id);
        List<String> tpProcessorEmailId = new List<String>();
        tpProcessorEmailId.add('Test@gmail.com');
        Test.startTest();
        SRV_TPA_TPARequest.gileadRequestSubmissionEmail(SRV_TPA_TPARequest.tpaRequest);
        SRV_TPA_TPARequest.getAtypicalUseOffCombByRequestID(requestList[0].Id);
        SRV_TPA_TPARequest.sendAtypicalUseOffClientNotification(SRV_TPA_TPARequest.tpaRequest);
        SRV_TPA_TPARequest.tpaRequest.isClientOnComplianceHold__c = true;
        SRV_TPA_TPARequest.tpaRequest.isVendorOnComplianceHold__c = true;
        SRV_TPA_TPARequest.tpaRequest = SRV_TPA_TPARequest.getRequestStatus(SRV_TPA_TPARequest.tpaRequest);
        Test.stopTest();
    }
    
    @isTest static void test_generateAddendumNotif() {
        List<TPA_Request__c> requestList = [SELECT Id, Service_Provider_Address__c,Is_VSN_Acknowlege_By_Client__c,isClientOnComplianceHold__c,isVendorOnComplianceHold__c,Is_Potential_Vendor_Case__c,isLegalEntityPresent__c,Pending_Acknowledgements__c FROM TPA_Request__c LIMIT 1];
        Test.startTest();
        SRV_TPA_TPARequest.isReqReadyForSignatures(requestList[0]);
        SRV_TPA_TPARequest.generateAddendumNotificationDoc(requestList[0].id,'pdf', UTL_LogFactory.Guid);
        SRV_TPA_TPARequest.generateOffNotificationDoc(requestList[0].id,'Client',requestList[0].Service_Provider_Address__c, 'English', 'test TPA','testEmail@gmail.com', false, UTL_TPA.AWAITING_CLIENT_CONFIRMATION, UTL_LogFactory.Guid);
        SRV_TPA_TPARequest.generateHelpfulHintsAddendumDoc(requestList[0].id);

        Test.stopTest();
    }
    
    @isTest static void test_LaadResponse() {
        List<TPA_Request__c> requestList = [SELECT Id, Service_Provider_Address__c FROM TPA_Request__c LIMIT 1];
        SRV_TPA_TPARequest.tpaRequest = SRV_TPA_TPARequest.getRequestInfo(requestList[0].Id);
        Test.startTest();
        AgrAdditionalObj = UTL_TPA_SetupTestData.getTPAAgreementAdditionalFieldObj(SRV_TPA_TPARequest.tpaRequest);
        SRV_TPA_TPARequest.sendCompetitiveMail(requestList[0]);
        SRV_TPA_TPARequest.VendorSpecificNotificationSendConfirmationToClient(SRV_TPA_TPARequest.tpaRequest, 'test@a.in');
        SRV_TPA_TPARequest.VendorSpecificNotificationSendConfirmationToTPProcessor(SRV_TPA_TPARequest.tpaRequest, 'test@a.in');
        SRV_TPA_TPARequest.VendorSpecificNotificationSendCancellationConfirmationToClient(SRV_TPA_TPARequest.tpaRequest);
        SRV_TPA_TPARequest.VendorSpecificNotificationSendTPProcessorNotificationofSalesCommunicationResult(SRV_TPA_TPARequest.tpaRequest, AgrAdditionalObj, 'Cancel');
        SRV_TPA_TPARequest.VendorSpecificNotificationSendTPProcessorNotificationofSalesCommunicationResult(SRV_TPA_TPARequest.tpaRequest, AgrAdditionalObj, 'Modify');
        SRV_TPA_TPARequest.VendorSpecificNotificationSendTPProcessorNotificationofSalesCommunicationResult(SRV_TPA_TPARequest.tpaRequest, AgrAdditionalObj, 'Acknowledge');
        
        //SRV_TPA_TPARequest.ReqLAADResponseInDirecttoClientNotification(SRV_TPA_TPARequest.tpaRequest,'test@a.in');
        
        SRV_TPA_TPARequest.DirectToClientNotificationSendTPProcessorNotificationofClientLAADResponce(SRV_TPA_TPARequest.tpaRequest, AgrAdditionalObj);
        
        Test.stopTest();
    }
    
    @isTest static void testAdditionalTerms(){
        List<TPA_Request__c> requestList = [SELECT Id, Service_Provider_Address__c FROM TPA_Request__c LIMIT 1];
        SRV_TPA_TPARequest.tpaRequest = SRV_TPA_TPARequest.getRequestInfo(requestList[0].Id);
        String offs = 'MIDAS;Patient Reference File;Medpages Data;GE Centricity EMR;Promo;AIM XR Website Data;Managed Care Workbook;IQVIA Global Promo.track™;IQVIA Consumer Aisle;PharMetrics® Plus;Patient Companion File;Provider Companion File;Payer Companion File;LAAD - Longitudinal Access and Adjudication Data;Oncology electronic medical records data;Ambulatory electronic medical records data;Xponent;Sell-Out - ImpactRX Data;Xponent PlanTrak';
        List<String> offeringNames = offs.split(';');
        List<TPA_Commercial_Review__c> comRevs = new List<TPA_Commercial_Review__c>();
        for(String offName: offeringNames){
            comRevs.add(new TPA_Commercial_Review__c(Associated_Offering_to_Review__c = offName, 
                                                                        Associated_Use_to_Review__c = 'Data Cleansing', 
                                                                        Manual_Review_Reason__c = 'Selected Offering Requires Review',  
                                                                        Action_Needed_By__c = 'commercial owner', 
                                                                        TPA_Request__c = requestList[0].Id));
        }
        insert comRevs;
        Set<String> terms = SRV_TPA_TPARequest.TpaTextTerms;
        SRV_TPA_TPARequest.isRunCommercialAutoLogic = true;
        List<TPA_Data_Asset__c> daList = [select BU__c, geo_Level__c from TPA_Data_Asset__c where Request__c = :SRV_TPA_TPARequest.tpaRequest.id];
        IMS_Use_Offering_Atypical_Combination__c comObj = new IMS_Use_Offering_Atypical_Combination__c(Action_Needed_By__c = 'Vendor - Use Secondary Review by Mgmt',Mgmt_Review_email__c='a@a.in');
        insert comObj;
        SRV_TPA_TPARequest.tempComOwnerMap = new Map<String,TPA_Assigned_TP_Processor__c>();
        SRV_TPA_TPARequest.addReasonCommercial(SRV_TPA_TPARequest.tpaRequest, 'Vendor Requires Secondary Review', 'a@a.in', 'Per this TPA Request', 'Per this TPA Request', daList[0], null, null, null,null);
        SRV_TPA_TPARequest.addReasonCommercial(SRV_TPA_TPARequest.tpaRequest, 'Offering Requires Secondary Commercial Review',   'a@a.in', 'test', 'test use', null, null, 'test category', null,null);
        SRV_TPA_TPARequest.addReasonCommercial(SRV_TPA_TPARequest.tpaRequest, 'Offering Requires Secondary Commercial Review',   'a@a.in', 'testOffering:Study Name', 'test use', null, null, 'test category', null,null);
        SRV_TPA_TPARequest.addReasonCommercial(SRV_TPA_TPARequest.tpaRequest, 'Vendor - Use Secondary Review by ',  null, null, 'test use', null, null, 'test category',comObj,null);
    }
    
    @isTest 
    public static void testGreaterthan50License(){
        
        final Integer COUNT = 101; 
        
        Test.startTest();
        Address__c testAccount1 = UTL_TPA_SetupTestData.getAccount();
        testAccount1.Name = 'Test 50plus';
        testAccount1.Primary_Vendor_Address__c = true;
        insert testAccount1;

        TPA_Request__c tpaRequest = UTL_TPA_SetupTestData.getTestTPARequest();
        tpaRequest.Request_Status__c = 'Expired';
        tpaRequest.List_Of_Uses__c = 'Use0,Use1,Use2,Use3,Use4,Use5';
        tpaRequest.OwnerId = UserInfo.getUserId();
        tpaRequest.Service_Provider_Address__c = testAccount1.Id;
        tpaRequest.TP_Processor_Email__c = 'test@test.com';
        tpaRequest.Client_Address__c = testAccount1.Id;
        tpaRequest.Client_Language__c = 'English';
        tpaRequest.Vendor_Language__c = 'English';
        tpaRequest.Is_Renewed__c = true;
        tpaRequest.Vendor_Billing_Mailing_Country__c = 'united states';
        insert tpaRequest;
        
        TPA_Request__c tpaRequest1 = UTL_TPA_SetupTestData.getTestTPARequest();
        tpaRequest1.Request_Status__c = 'In Review by IQVIA';
        tpaRequest1.Parent_Request__c = tparequest.id;
        tpaRequest1.List_Of_Uses__c = 'Use0,Use1,Use2,Use3,Use4,Use5';
        tpaRequest1.OwnerId = UserInfo.getUserId();
        tpaRequest1.Service_Provider_Address__c = testAccount1.Id;
        tpaRequest1.TP_Processor_Email__c = 'test@test.com';
        tpaRequest1.Client_Address__c = testAccount1.Id;
        tpaRequest1.Client_Language__c = 'English';
        tpaRequest1.Vendor_Language__c = 'English';
        tpaRequest1.Is_VSN_Acknowlege_By_Client__c = true;
        tpaRequest1.Vendor_Billing_Mailing_Country__c = 'united states';
        insert tpaRequest1;
        
        tpaRequest.Renewed_As__c = tpaRequest1.id;
        tpaRequest.Renewed_Type__c = 'Modified Renewal';
        update tpaRequest;
        
        TPA_Agreement_Additional_Field__c agreementAdditionalFieldData = new TPA_Agreement_Additional_Field__c();
        
        agreementAdditionalFieldData.Related_TPA_Request__c = tpaRequest1.id;
        insert agreementAdditionalFieldData;
        
        IMS_Master_Legal_Entity__c imsMasterLegalEntity = UTL_TPA_SetupTestData.getImsMasterLegalEntity();
        imsMasterLegalEntity.Name = 'IQVIA Ltd.';
        update imsMasterLegalEntity;
        
        List<IMS_Data_Asset__c> offeringsToInsert = new List<IMS_Data_Asset__c>();
        for(Integer index = 0 ; index < COUNT ;index++){
            IMS_Data_Asset__c imsDa = UTL_TPA_SetupTestData.createImsDataAsset_Template();
            imsDa.Region__c = TEST_REGION;
            imsDa.Is_Restricted_Data__c = True;
            imsDa.Requires_Fee__c = True;
            imsDa.Requires_Manual_Review__c = true;
            imsDa.IMS_Master_Legal_Entity__c = imsMasterLegalEntity.Id;
            imsDa.IMS_Legal_Entity__c = 'IQVIA Ltd.';
            imsDa.Asset_Name__c = 'Off' + index;
            offeringsToInsert.add(imsDa);
        }
        insert offeringsToInsert;
        
        imsPurpose1 = UTL_TPA_SetupTestData.getIMSTpaPurposeData();
        imsPurpose1.Name = 'test';
        imsPurpose1.Purpose_Details__c = 'test purpose details';
        imsPurpose1.Consulting_Area__c = 'test consulting area';
        imsPurpose1.Business_Line__c = 'test business line';
        imsPurpose1.Primary_Purpose_Name__c = 'test1';
        insert imsPurpose1;
        system.assert(imsPurpose1.Id != null);
        
        List<TPA_Purpose__c> purposeToInsert = new List<TPA_Purpose__c>();
        for(Integer index = 0 ; index < COUNT ;index++){
            TPA_Purpose__c tpaPurpose = UTL_TPA_SetupTestData.createTpaPurposeByReqId(tpaRequest1);
            tpaPurpose.Name = 'testName' + index;
            tpaPurpose.Region__c = 'TEST_REGION';
            tpaPurpose.Purpose__c = imsPurpose1.Id;
            purposeToInsert.add(tpaPurpose);
        }
        insert purposeToInsert;
        
        List<TPA_Data_Asset__c> daToInsert = new List<TPA_Data_Asset__c>();
        for(Integer index = 0 ; index < COUNT;index++){
            TPA_Data_Asset__c tpaDataAss1 = UTL_TPA_SetupTestData.getTpaDataAsset(purposeToInsert[index].Id);
            tpaDataAss1.Request__c = tpaRequest1.Id;
            tpaDataAss1.Region__c = TEST_REGION;
            tpaDataAss1.Data_Asset__c = offeringsToInsert[index].Id;
            tpaDataAss1.BU__c = TEST_REGION;
            tpaDataAss1.Geo_Level__c = 'Test';
            daToInsert.add(tpaDataAss1);
        }
        insert daToInsert;
        Assert.areEqual(SRV_TPA_TPARequest.getTpaDataAssetReqsMap(new Set<Id>{tpaRequest1.id}).get(tpaRequest1.id).size(), COUNT);
        List<TPA_Additional_Term__c> addocList = new List<TPA_Additional_Term__c>();
        TPA_Additional_Term__c addTerm = new TPA_Additional_Term__c(Name = 'name', Addtional_Term__c  = 'test123',Primary_Offering_Name__c = 'Oncology', Category__c = 'Data Asset Specific Ad-Hoc Term', TPA_Request__c =tpaRequest1.Id, Is_Future_Approved__c = true, Type__c = 'Renewed' );
        addocList.add(addTerm);
        TPA_Additional_Term__c addTerm1 = new TPA_Additional_Term__c(Name = 'name2', Addtional_Term__c  = 'test1234', Category__c = 'General Ad-Hoc Term', TPA_Request__c =tpaRequest1.Id );
        addocList.add(addTerm1);
        TPA_Additional_Term__c addTerm2 = new TPA_Additional_Term__c(Name = 'name', Addtional_Term__c  = 'test123',Primary_Offering_Name__c = 'Oncology', Category__c = 'Use Specific Ad-Hoc Terms', TPA_Request__c =tpaRequest1.Id, Is_Future_Approved__c = false, Type__c = 'Renewed' );
        addocList.add(addTerm2);
        TPA_Additional_Term__c addTerm3 = new TPA_Additional_Term__c(Name = 'name', Addtional_Term__c  = 'test123',Primary_Offering_Name__c = 'Oncology', Category__c = 'Use/Offering Specific Ad-Hoc Terms', TPA_Request__c =tpaRequest1.Id, Is_Future_Approved__c = false, Type__c = 'Renewed' );
        addocList.add(addTerm3);
        insert addocList;
        SRV_TPA_TPARequest.updateActivityHistoryForBulk(new Set<id>{tpaRequest.id}, COUNT + '+ offerings Updated !' , true);
        SRV_TPA_TPARequest.retriggerManualReviewMail(tpaRequest1);
        Test.stopTest();
    }
     @isTest
    public static void testDraftRequests(){
		TPA_Request__c testDraftRequest = UTL_TPA_SetupTestData.getTestTPARequest();
		testDraftRequest.Request_Status__c = 'Client Draft';
        testDraftRequest.Client_TPA_Representative_Email__c = 'test@test.com';
        insert testDraftRequest;
        TPA_Contact__c testTPAContact = UTL_TPA_SetupTestData.getTPAContactByReqId(testDraftRequest);
        Test.startTest();
        SRV_TPA_TPARequest.sendDraftMail(testDraftRequest);
        testDraftRequest.Request_Status__c = 'Draft Closed';
        update testDraftRequest;
        SRV_TPA_TPARequest.sendClosedRequestMail(testDraftRequest, false);
        Test.stoptest();
    }
    @isTest
    public static void testVendorSpecificNotificationClientContactAcknowledgment(){
        TPA_Request__c tpaRequest = [select id from TPA_Request__c limit 1];
        TPA_Agreement_Additional_Field__c agreementAdditionalFieldData = new TPA_Agreement_Additional_Field__c();
        agreementAdditionalFieldData.Related_TPA_Request__c = tpaRequest.id;
        insert agreementAdditionalFieldData;
        TPA_contact__c tpacontact = new TPA_Contact__c( Type__c = 'Additional Client Contact', Email__c = 'test@test.com', tpa_Request__c = tpaRequest.id);
        insert tpaContact;
        tpaRequest = SRV_TPA_TPARequest.getRequestInfo(tpaRequest.id);
        TPA_Agreement_Additional_Field__c aggr = tpaRequest.TPA_Agreement_Additional_Fields__r;
        agreementAdditionalFieldData.Client_Contact_First_Name__c = 'firstName';
        agreementAdditionalFieldData.QuintilesIMS_Account_Team_First_Name__c = 'Test title';
        agreementAdditionalFieldData.Offering_Notification_Ack_By_Email__c = 'test@test.com';
        
        tpaRequest.Client_TPA_Representative_Email__c = 'test@test.com';
        tpaRequest.TP_Processor_Email__c = 'test@test.com';
		Test.startTest();
        SRV_TPA_TPARequest.VendorSpecificNotificationClientContactAcknowledgment(tpaRequest, agreementAdditionalFieldData);
        test.stopTest();
    }
    
    @isTest
    public static void testIsComRevApprovedStatusIsTrue(){
        Test.startTest();
        SRV_TPA_TPARequest.isComRevApproved('test');
        test.stopTest();
    }
    @isTest
    public static void testIsComRevApprovedStatusIsFalse(){
        Test.startTest();
        SRV_TPA_TPARequest.isComRevApproved(null);
        test.stopTest();
    }
    
    @isTest
    public static void testInsertComReview(){
		 TPA_Request__c tpaRequest = [SELECT Id,TP_Processor_Email__c FROM TPA_Request__c where Vendor_Company_Name__c ='Test company' LIMIT 1]; 
         Test.startTest();
         SRV_TPA_TPARequest.insertComReview('test',tpaRequest);
		 test.stopTest();
    }
    
    @isTest
    public static void testDeleteComReview(){
        TPA_Request__c tpaRequest = [SELECT Id,TP_Processor_Email__c FROM TPA_Request__c where Vendor_Company_Name__c ='Test company' LIMIT 1];
        Test.startTest();
        SRV_TPA_TPARequest.deleteComReview('Vendor Requires Review',tpaRequest);
		test.stopTest();
    }
    @isTest
    public static void testOnOfferingDeleteScenario(){
        TPA_Request__c tpaRequest = [select id from TPA_Request__c limit 1];
        SRV_TPA_TPARequest.tpaRequest = SRV_TPA_TPARequest.getRequestInfo(tpaRequest.id);
        
        Set<String> stComRevEmail = new Set<String>();
        List<TPA_Commercial_Review__c> lstComRevToDelete = new List<TPA_Commercial_Review__c>();
        SRV_TPA_TPARequest.tpaRequest.TPA_Commercial_Reviews__r[0].Action__c = 'Questions / Comments';
		update SRV_TPA_TPARequest.tpaRequest.TPA_Commercial_Reviews__r; 
        for(TPA_Commercial_Review__c reason : SRV_TPA_TPARequest.tpaRequest.TPA_Commercial_Reviews__r){
            System.debug('reason' + reason);
            System.debug((reason.Action__c != null && (reason.Action__c == 'Questions / Comments' || reason.Action__c.contains('Potential Denial'))));
            if(reason.Action__c != null && (reason.Action__c == 'Questions / Comments' || reason.Action__c.contains('Potential Denial'))){
                System.debug(reason);
                lstComRevToDelete.add(reason);
                stComRevEmail.add(reason.Receiver_s_Email__c);
            }
        }
        System.debug('SRV_TPA_TPARequest.tpaRequest.TPA_Commercial_Reviews__r ' + SRV_TPA_TPARequest.tpaRequest.TPA_Commercial_Reviews__r);
        System.debug('lstComRevToDelete' + lstComRevToDelete);
        System.debug('stComRevEmail' + stComRevEmail);
        
        Test.startTest();
        if(lstComRevToDelete.size() > 0){
            for(String comRevEmail : stComRevEmail){
                List<TPA_Commercial_Review__c> comRevForSameReviewer = new List<TPA_Commercial_Review__c>();
                for(TPA_Commercial_Review__c reason : SRV_TPA_TPARequest.tpaRequest.TPA_Commercial_Reviews__r){
                    System.debug('reason' + reason); 
                    if(reason?.Receiver_s_Email__c != null && comRevEmail == reason.Receiver_s_Email__c){
                        comRevForSameReviewer.add(reason);
                    }
                }
                System.debug('comRevForSameReviewer' + comRevForSameReviewer);
                SRV_TPA_TPARequest.sendForYourRecordsOnDeletionMail(lstComRevToDelete, comRevForSameReviewer, comRevEmail);
            }
        }
        Test.stopTest();
    }
}