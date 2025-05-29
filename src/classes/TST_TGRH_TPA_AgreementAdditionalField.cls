@isTest(seeAllData=false)
public class TST_TGRH_TPA_AgreementAdditionalField {
    static TPA_Agreement_Additional_Field__c tpaAgreeAdditionalObj;
    static TPA_Request__c tpaRequest;
    static void setup() {
        
        // create account 
        Account testAccount = new Account(Name = 'Test Account', CurrencyIsoCode = 'USD', Region_Territory__c = 'India', Industry_IMS__c = 'Biotech',  Is_Payment_Risk__c = true,  BillingStreet = 'test', BillingCity = 'test', BillingCountry = 'test', BillingPostalCode = 'test',CustomerSegment__c = 'GOVERNMENT',Sub_Industry__c = 'STATE');
        insert testAccount;
        System.debug('CD::01.Number of Queries used in this apex code so far: ' + Limits.getQueries());
        
        Address__c testAddress = new Address__c(Account__c = testAccount.Id, recordTypeId = UTL_TPA_SetupTestData.getTPAVendorAddressRecordTypeId, is_TPA_Account__c=true, Vendor_Tier__c = 'Y', Vendor_Registration_Number__c = 9999);
        insert testAddress;
        System.debug('CD::02.Number of Queries used in this apex code so far: ' + Limits.getQueries());
        
        // Create Contact
        Contact tpaContact = new Contact(FirstName = 'Test',LastName = 'Test', AccountId = testAccount.Id, CurrencyIsoCode = 'USD', Email = 'test@mail.com', Title = 'Dev');
        insert tpaContact;
        System.debug('CD::03.Number of Queries used in this apex code so far: ' + Limits.getQueries());
        
        tpaRequest = UTL_TPA_SetupTestData.getTPARequestByVendorAccount(testAddress.id);
        System.debug('CD::04.Number of Queries used in this apex code so far: ' + Limits.getQueries());
        tpaAgreeAdditionalObj = new TPA_Agreement_Additional_Field__c();
        tpaAgreeAdditionalObj.Related_TPA_Request__c = tpaRequest.Id;
        insert tpaAgreeAdditionalObj;
        List<Attachment> attchs = new List<Attachment>();
        String tpaName = [Select Name from TPA_Request__c where Id = :tpaRequest.Id].get(0).Name;
        attchs.add(UTL_TPA_SetupTestData.addAttachment(tpaRequest.Id,tpaName+ '_TLLA' + '.pdf'));
        attchs.add(UTL_TPA_SetupTestData.addAttachment(tpaRequest.Id,tpaName+ '_TLLA' + '.pdf_Completed'));
        attchs.add(UTL_TPA_SetupTestData.addAttachment(tpaRequest.Id,UTL_TPA.helpfulHintsDocLabel+'.pdf'));
        attchs.add(UTL_TPA_SetupTestData.addAttachment(tpaRequest.Id,UTL_TPA.helpfulHintsDocLabel+'.pdf_Completed'));
        insert attchs;
        System.debug('CD::06.Number of Queries used in this apex code so far: ' + Limits.getQueries());
        tpaRequest.Request_Status__c = UTL_TPA.SIGNATURE_UNDER_VALIDATION;
        update tpaRequest;
        System.debug('CD::07.Number of Queries used in this apex code so far: ' + Limits.getQueries());
        
    }
    
    static testMethod void unitTest1() {
        setup();
        Test.startTest();
        String query = 'Select Id, Vendor_Contact_e_mail__c, TP_Processor_Email__c, ClientContact__c, Authorized_Signer_Email__c, (Select Email__c from TPA_Request_Contacts__r where Type__c = \'Additional Vendor Contact\') from TPA_Request__c where Request_Status__c = \'In Effect\' AND In_Effect_Date__c = YESTERDAY';
        System.debug('----------------------------> ' + Database.Query(query));
        tpaRequest.Data_Access_Start_Date__c  = date.newInstance(2017, 1, 1);
        Date endDate = date.today();
        tpaRequest.TPA_Authorised_Signer__c = 'No';
        tpaRequest.Data_Access_End_Date__c  = endDate.addDays(20);
        tpaRequest.Request_Status__c = 'In Effect';
        tpaRequest.Vendor_Contact_e_mail__c = 'test@test.com';
        tpaRequest.Authorized_Signer_Email__c = 'test@test.com';
        tpaRequest.In_Effect_Date__c = Date.today().addDays(-1);
        update tpaRequest;
        
        IMS_TPA_Purpose__c imsTpaPurpose = new IMS_TPA_Purpose__c(BU__c = 'United States', 
                                                                  Primary_Purpose_Name__c = 'test name', 
                                                                  Purpose_Details__c = 'test detail',
                                                                  Is_Active__c = true);
        insert imsTpaPurpose;
        
        TPA_Purpose_Category__c tpaPurposeCategory = new TPA_Purpose_Category__c(Category_Alias__c = 'Expert', 
                                                                                 Category_Name__c = 'Expert Analysis', 
                                                                                 isActive__c = true);
        insert tpaPurposeCategory;
        
        TPA_Purpose__c tpaPurpose = new TPA_Purpose__c(Name = 'Test TPA Purpose',
                                                       Request__c = tpaRequest.id, 
                                                       BU__c = 'United States', 
                                                       TPA_Purpose_Category__c = tpaPurposeCategory.id,
                                                       Purpose__c = imsTpaPurpose.id);
        insert tpaPurpose;
        
        IMS_Data_Asset__c imsDataAsset = new IMS_Data_Asset__c(BU__c = 'United States', 
                                                               Geo_Level__c = 'Sub-National', 
                                                               Is_Active__c = true, 
                                                               IMS_Legal_Entity__c='IQVIA AG', 
                                                               Asset_Name__c = 'test');
        insert imsDataAsset;
        
        IMS_Data_Asset__c imsDataAsset2 = new IMS_Data_Asset__c(BU__c = 'United States', 
                                                               Geo_Level__c = 'Sub-National', 
                                                               Is_Active__c = true, 
                                                               IMS_Legal_Entity__c='IQVIA AG', 
                                                               Asset_Name__c = 'Other');
        insert imsDataAsset2;
        
        TPA_Data_Asset__c tpaDataAsset = new TPA_Data_Asset__c(Request__c = tpaRequest.id, 
                                                               Data_Asset__c = imsDataAsset.id,
                                                               BU__c = 'United States', 
                                                               Purpose__c = tpaPurpose.Id,
                                                               Geo_Level__c = 'Sub-National', 
                                                               Asset_NametText__c = 'MIDAS');
        insert tpaDataAsset;
        
        TPA_Data_Asset__c tpaDataAsset2 = new TPA_Data_Asset__c(Request__c = tpaRequest.id, 
                                                               Data_Asset__c = imsDataAsset2.id,
                                                               BU__c = 'United States', 
                                                               Purpose__c = tpaPurpose.Id,
                                                               Geo_Level__c = 'Sub-National', 
                                                               Asset_NametText__c = 'Other',
                                                               Other_Text__c = 'test',
                                                               Other_Data_Asset_Details__c = 'test123');
        insert tpaDataAsset2;
        
        IMS_Secondary_Data_Asset__c imsSecondaryDataAsset = new IMS_Secondary_Data_Asset__c(Primary_Data_Asset__c = imsDataAsset.id, 
                                                                                            additional_terms_required__c = true);
        insert imsSecondaryDataAsset;

        TPA_Secondary_Data_Asset__c tpaSecondaryDataAsset = new TPA_Secondary_Data_Asset__c(TPA_Data_Asset__c = tpaDataAsset.id, 
                                                                                            IMS_Secondary_Data_Asset__c = imsSecondaryDataAsset.id,
                                                                                           Secondary_Asset_Name__c = 'testSec1');
        insert tpaSecondaryDataAsset;
        
        
        System.debug('CD::08.Number of Queries used in this apex code so far: ' + Limits.getQueries());
        System.debug('CD::09.Number of Queries used in this apex code so far: ' + Limits.getQueries());
        tpaAgreeAdditionalObj = [select Id, Related_TPA_Request__c, Related_TPA_Request__r.Id,Related_TPA_Request__r.Request_Status__c from TPA_Agreement_Additional_Field__c where id =: tpaAgreeAdditionalObj.Id];
        tpaAgreeAdditionalObj.Vendor_Contact_First_Name__c = 'Test0';
        tpaAgreeAdditionalObj.Vendor_Contact_Last_Name__c = 'Test11';
        tpaAgreeAdditionalObj.Vendor_Contact_Title__c = 'Test21';
        tpaAgreeAdditionalObj.Vendor_Contact_e_mail__c = 'test1@gmail.com';
        tpaAgreeAdditionalObj.Authorized_Signer_First_Name__c = 'Test21';
        tpaAgreeAdditionalObj.Authorized_Signer_Last_Name__c = 'Test31';
        tpaAgreeAdditionalObj.Authorized_Signer_Title__c = 'Test51';
        tpaAgreeAdditionalObj.Authorized_Signer_Email__c = 'test11@gmail.com';
        tpaAgreeAdditionalObj.Vendor_Compliance_First_Name__c = 'Test61';
        tpaAgreeAdditionalObj.Vendor_Compliance_Last_Name__c = 'Test71';
        tpaAgreeAdditionalObj.Vendor_Compliance_Job_Title__c = 'Test81';
        tpaAgreeAdditionalObj.Vendor_Compliance_Email__c = 'test12@gmail.com';
        tpaAgreeAdditionalObj.Parent_TPA_Request_Offering_Data__c = 'USA:PriOff1:SecOff1;USA:PriOff2;UK:PriOff3;UK:PriOff4';
        tpaAgreeAdditionalObj.Parent_TPA_Request_Offering_Country_s__c = 'USA,USA,UK,UK';
        tpaAgreeAdditionalObj.Parent_TPA_Request_Offering_Category_s__c = 'Cat1,Cat2,Cat3';
        tpaAgreeAdditionalObj.Parent_TPA_Request_Use_Data__c = 'Use1,Use2';
        


        CNT_TPA_RequestSubmissionForm.IsUpdateRenewalOfferinfDetail = true;
        update tpaAgreeAdditionalObj;
        CNT_TPA_RequestSubmissionForm.IsUpdateRenewalOfferinfDetail = false;
        tpaAgreeAdditionalObj = [select Id, Excluded_Offerings_In_Renewal__c,Description_of_Removal__c from TPA_Agreement_Additional_Field__c where id =: tpaAgreeAdditionalObj.Id];
        tpaAgreeAdditionalObj.Excluded_Offerings_In_Renewal__c = ';;UK:PriOff3;UK:PriOff4';
        tpaAgreeAdditionalObj.Description_of_Removal__c = 'test';
        update tpaAgreeAdditionalObj;
        tpaAgreeAdditionalObj = [select Id, Excluded_Offerings_In_Renewal__c from TPA_Agreement_Additional_Field__c where id =: tpaAgreeAdditionalObj.Id];
        tpaAgreeAdditionalObj.Excluded_Offerings_In_Renewal__c = '';
        update tpaAgreeAdditionalObj;
        System.debug('CD::10.Number of Queries used in this apex code so far: ' + Limits.getQueries());
        Test.stopTest();
    }
    
}