@isTest
public class TST_BCH_TPA_Update_Commercial_Review {
    static TPA_Request__c tpaRequest;
    static void setup() {
        
        // create account 
        Account testAccount = new Account(Name = 'Test acc', CurrencyIsoCode = 'USD', Region_Territory__c = 'China', BillingStreet = 'test1', BillingCity = 'test1', BillingCountry = 'test1', BillingPostalCode = 'test1',CustomerSegment__c = 'GOVERNMENT',Sub_Industry__c = 'STATE');
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
        
        TPA_Commercial_Review__c comRev = new TPA_Commercial_Review__c(Is_ReviewForm_Acknowledged__c = true,Associated_Offering_to_Review__c = 'test',Associated_Use_to_Review__c='Test TPA Purpose',Associated_Offering_s_Use_Category_s__c='Expert Analysis',Associated_Offering_Category__c='Sub-National',BU__c='United States',Action_Needed_By__c='TP-country',Status__c='Awaiting Review',Receiver_s_Email__c='test1@mail.com',TP_Country_Email__c='test1@mail.com',Manual_Review_Reason__c='Selected Offering requires Manual Review',TPA_Request__c=tpaRequest.Id);
        insert comRev;
        TPA_Commercial_Review__c comRev2 = new TPA_Commercial_Review__c(Is_ReviewForm_Acknowledged__c = true,Associated_Offering_to_Review__c = 'test',Associated_Use_to_Review__c='Test TPA Purpose',Associated_Offering_s_Use_Category_s__c='Expert Analysis',Associated_Offering_Category__c='Sub-National',BU__c='United States',Action_Needed_By__c='TP-country',Status__c='Awaiting Review',Receiver_s_Email__c='test1@mail.com',TP_Country_Email__c='test3@mail.com',Manual_Review_Reason__c='Offering Requires Secondary Commercial Review',TPA_Request__c=tpaRequest.Id);
        insert comRev2;
        TPA_Commercial_Review__c comRev3 = new TPA_Commercial_Review__c(Is_ReviewForm_Acknowledged__c = true,Action_Needed_By__c='TP-country',Status__c='Awaiting Review',Receiver_s_Email__c='test1@mail.com',TP_Country_Email__c='test3@mail.com',Manual_Review_Reason__c='Vendor Requires Secondary Review',TPA_Request__c=tpaRequest.Id);
        insert comRev3;
        imsDataAsset.Commercial_Owner_Email__c = 'test@gmail.com';
        update imsDataAsset;
        Test.stopTest();
    }

    private static testmethod void testExecutedBatchFortemporayEamilUpdate(){
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

        List<TPA_Commercial_Review__c> listcom = new List<TPA_Commercial_Review__c>();

        TPA_Commercial_Review__c comRev7 = new TPA_Commercial_Review__c(Is_ReviewForm_Acknowledged__c = false,Action_Needed_By__c='Legal',Status__c='Awaiting Review',Receiver_s_Email__c='test@mail.com',TP_Country_Email__c='test1@mail.com',Manual_Review_Reason__c='IQVIA Legal Approval Required: New TPA - Ad-hoc Additional Term(s) / Exhibit Page(s) Requested',TPA_Request__c=tpaRequest.Id);
        listcom.add(comRev7);

        insert listcom;

        TPA_Assigned_TP_Processor__c obj1 = new TPA_Assigned_TP_Processor__c(Is_Commercial_Owner__c = true, Commercial_Owner_Email__c = 'test@mail.com', Temporary_Commercial_Owner_Email__c = 'a@a.in', Out_of_Office_Leave_End_Date__c = Date.Today().addDays(10),Out_of_Office_Leave_Start_Date__c = Date.Today().addDays(-10));
        insert obj1;

        Set<Id> reqsSet =  new Set<Id>();
        reqsSet.add(tpaRequest.id);
        BCH_TPA_Update_Commercial_Review bchObj = new BCH_TPA_Update_Commercial_Review(true,'test@mail.com','update',True,'test');
        bchObj.reqsSet = reqsSet;
        bchObj.includeTestDataOnly = true;
        Database.executeBatch(bchObj);

        Test.stopTest();

    }

}