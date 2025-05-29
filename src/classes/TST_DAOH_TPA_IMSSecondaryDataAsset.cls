@isTest(seeAllData=false)
public class TST_DAOH_TPA_IMSSecondaryDataAsset {

    static TPA_Request__c tpaRequest;
    static void setup() {
        
        // create account 
        Account testAccount = new Account(Name = 'Test Account', CurrencyIsoCode = 'USD', Region_Territory__c = 'India', Industry_IMS__c = 'Biotech',  Is_Payment_Risk__c = true,  BillingStreet = 'test', BillingCity = 'test', BillingCountry = 'test', BillingPostalCode = 'test',CustomerSegment__c = 'GOVERNMENT',Sub_Industry__c = 'STATE');
        insert testAccount;
        System.debug('CD::01.Number of Queries used in this apex code so far: ' + Limits.getQueries());
        
        Address__c testAddress = new Address__c(Account__c = testAccount.Id, is_TPA_Account__c=true, Vendor_Tier__c = 'Y', Vendor_Registration_Number__c = 9999);
        insert testAddress;
        System.debug('CD::02.Number of Queries used in this apex code so far: ' + Limits.getQueries());
        
        // Create Contact
        Contact tpaContact = new Contact(FirstName = 'Test',LastName = 'Test', AccountId = testAccount.Id, CurrencyIsoCode = 'USD', Email = 'test@mail.com', Title = 'Dev');
        insert tpaContact;
        System.debug('CD::03.Number of Queries used in this apex code so far: ' + Limits.getQueries());
        
        tpaRequest = UTL_TPA_SetupTestData.getTPARequestByVendorAccount(testAddress.id);
        System.debug('CD::04.Number of Queries used in this apex code so far: ' + Limits.getQueries());
        
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
        tpaRequest.Request_Status__c = 'In Review By IQVIA';
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
                                                               Commercial_Owner_Email__c = 'test@gmail.co',
                                                               Requires_Manual_Review__c = true,
                                                               Asset_Name__c = 'test');
        insert imsDataAsset;
        
        TPA_Data_Asset__c tpaDataAsset = new TPA_Data_Asset__c(Request__c = tpaRequest.id, 
                                                               Data_Asset__c = imsDataAsset.id,
                                                               BU__c = 'United States', 
                                                               Purpose__c = tpaPurpose.Id,
                                                               Geo_Level__c = 'Sub-National', 
                                                               Asset_NametText__c = 'MIDAS');
        insert tpaDataAsset;
        
        IMS_Secondary_Data_Asset__c imsSecondaryDataAsset = new IMS_Secondary_Data_Asset__c(Primary_Data_Asset__c = imsDataAsset.id, Is_Active__c = true,
                                                                                            additional_terms_required__c = true, Requires_Manual_Review__c = true,Commercial_Manager_Email__c = 'test@gmail.co');
        insert imsSecondaryDataAsset;

        TPA_Secondary_Data_Asset__c tpaSecondaryDataAsset = new TPA_Secondary_Data_Asset__c(TPA_Data_Asset__c = tpaDataAsset.id, 
                                                                                            IMS_Secondary_Data_Asset__c = imsSecondaryDataAsset.id,TPA_Request_Secondary_Assets__c=tpaRequest.Id,
                                                                                           Secondary_Asset_Name__c = 'testSec1');
        insert tpaSecondaryDataAsset;
        
        TPA_Commercial_Review__c comRev = new TPA_Commercial_Review__c(Is_ReviewForm_Acknowledged__c = false,Action_Needed_By__c='TP-country',Status__c='Awaiting Review',Receiver_s_Email__c='test@mail.com',TP_Country_Email__c='test1@mail.com',Manual_Review_Reason__c='test Reason',TPA_Request__c=tpaRequest.Id,Primary_Data_Asset__c = tpaDataAsset.Id,Secondary_Data_Asset__c=tpaSecondaryDataAsset.Id);
        insert comRev;
        imsSecondaryDataAsset.Commercial_Manager_Email__c = 'test@gmail.com';
        update imsSecondaryDataAsset;
        Test.stopTest();
    }
}