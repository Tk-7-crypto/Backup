/*
*@Author  : Jay Vardhan Singh
*@Purpose : 1. Test class for Controller of SCM_TestClass_Agrmnt_GenerateAndSendDoc page 
               to override of Agreement GenerateAndSendDoc.
     
*/
@isTest(seeAllData = false)
public class TST_EXT_TPA_GenerateAndSendDoc {
    
    //*** This method disables the trigger End ***//
    public static User getAdminUser() {       
         List<User> ListUsr = [Select id,FirstName ,LastName ,Username ,Email  From User where Username like 'Jayvardhan' LIMIT 1];
         User Usr;
         if(ListUsr.size() == 0) {
             Profile P = [select id from profile where name='System Administrator']; 
             Usr = new User (FirstName = 'Jay',LastName = 'vardhan',Username = 'Jayvardhan@metacube.com.test',Email =  'test@metacube.com',Alias = 'TestUsr1',TimeZoneSidKey = 'America/Los_Angeles',LocaleSidKey = 'en_US',EmailEncodingKey = 'UTF-8',ProfileId = P.id ,LanguageLocaleKey ='en_US', Change_Request_Description__c = 'Test');
             Usr.EmployeeNumber = '0909090924';
             insert Usr;
         }
         else {
            Usr = ListUsr[0];
         }
        
        return Usr;
    }
    
    public static User getTPProcessor() {
        Id contactID = getTestContact(getTestAccount()).Id;
        Profile p = [SELECT Id FROM Profile WHERE Name like 'TPA Processor Profile%' LIMIT 1];
        UserRole ur = [Select Id from UserRole where Name = 'GLOBAL'];
        User usr = new User(Alias = 'standt', Email='standarduser@testorg.com', 
        EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
        LocaleSidKey='en_US', ProfileId = p.Id, 
        TimeZoneSidKey='America/Los_Angeles', UserName='standarduser@testorg.com',contactId = contactID, UserRoleId = ur.Id);
        usr.EmployeeNumber = '0909090925';
        insert usr;
        return usr;
    }
    
    public static Contact getTestContact(Address__c testAccount) {
        Contact TestContact ;
        List<Contact > ListContact = [Select id,Name  From Contact where Name like 'JayVardhan' LIMIT 1];
        if(ListContact.size() == 0) {
            TestContact = new Contact();
            TestContact.LastName = 'Test';
            TestContact.AccountId = testAccount.Account__c; 
            TestContact.CurrencyIsoCode = 'USD';
               
            insert TestContact ;
        }
        else {
            TestContact = ListContact [0];
        }
        return TestContact ;
    }
    
    public static Address__c getTestAccount() {
        Address__c TestAccount;
        List<Address__c> ListAccount = [Select id, Name,Account__c From Address__c where Name like 'JayVardhan' LIMIT 1];
        if(ListAccount.size() == 0) {
            TestAccount = new Address__c (Name = 'JayVardhan',CurrencyIsoCode = 'USD',is_tpa_account__c = true,vendor_registration_number__c = 9999, Street__c = 'test', City__c = 'test', Country__c = 'test', PostalCode__c = 'test');
            insert TestAccount;
        }
        else {
            TestAccount = ListAccount[0];
        }
        return TestAccount;
    }
    
    public static TPA_Request__c getTestAgreement() {
        Address__c TestAccount = TST_EXT_TPA_GenerateAndSendDoc.getTestAccount();  
        date strtDate = date.newInstance(2014, 1, 1);
        
        // create test request
        TPA_Request__c tpaRequest = new TPA_Request__c(
            OwnerId = UserInfo.getUserId(),
            Client_Region__c = 'US',
            Data_Provided_By__c = 'IMS in lieu of Client',
            Is_Data_Accessed_Via_IMS_Software__c = 'Yes',
            AMA_USPrescriberData__c = 'Yes',
            Does_the_request_require_information_con__c = 'Yes',
            Service_Provider_Address__c = TestAccount.Id,
            Vendor_Company_Name__c = 'Test company',
            Vendor_Billing_Mailing_Country__c = 'united states', 
            Data_Access_Start_Date__c=strtDate,
            Data_Access_End_Date__c=strtDate.addDays(2),
            Requires_Manual_Review__c = false,
            TP_Processor_Email__c = 'a.a@gmail.com',
            TP_Processor_Name__c = 'Test TP Processor',
            Vendor_Contact_e_mail__c = 'vendor.email@gmail.com',
            TPA_Authorised_Signer__c = 'Yes',
            Client_Address__c = TestAccount.Id,
            Authorized_Signer_Email__c = 'email.authorised@gmail.com',
            Request_Status__c = 'Expired'
        );
        insert tpaRequest;
        
        return tpaRequest; 
    }
    
    public static testMethod void redirectToSendForSignature() {
        User Usr = getAdminUser();
        TPA_Request__c  ObjAgg  = getTestAgreement();
        UTL_TPA_SetupTestData.createMultilingualTemplateSettingData();
        TPA_Agreement_Additional_Field__c agreementAdditionalFieldData = new TPA_Agreement_Additional_Field__c();
        agreementAdditionalFieldData.Related_TPA_Request__c = ObjAgg.Id;
        insert agreementAdditionalFieldData;
        TPA_Settings__c TPA_SettingObj1 = new TPA_Settings__c(Name = 'Test1', VendorMessageBoardId__c = 'test id', TPA_RequestSubmitted_Email__c = 'Test Email', Base_Url__c = String.valueOf(URL.getOrgDomainUrl()), Is_TPA_Permanent_Down__c = true, Generate_TLLA_Automatically__c = true);
        
        insert TPA_SettingObj1 ;
        
        system.runAs(Usr) {    
            //Case 1         
            Test.startTest();
            ApexPages.StandardController   StdCtrl = new ApexPages.StandardController(ObjAgg);            
            PageReference pageRef = Page.VFP_TPA_GenerateAndSendDoc;
	        pageRef.getParameters().put('reqId', ObjAgg.Id);
	        pageRef.getParameters().put('id', ObjAgg.Id);
	        pageRef.getParameters().put('type', 'test');
	        Test.setCurrentPage(pageRef);
            EXT_TPA_GenerateAndSendDoc controller = new EXT_TPA_GenerateAndSendDoc(StdCtrl);
            controller.serverUrl = '';
            controller.urlId = '';
            controller.generateAndSendForSignDoc(); 
            PageRef.getParameters().put('reqId',ObjAgg.Id); 
            PageRef.getParameters().put('type','vpsubmit');
            PageRef.getParameters().put('isRunAllTpaRule','false');
            PageRef.getParameters().put('client','yes');
            controller.generateAndSendForSignDoc(); 
            
            string reqNo = EXT_TPA_GenerateAndSendDoc.getRequestNo();
            controller.generateAndSendForSignDocPotentialVendorCase(ObjAgg.Id);               
            Test.stopTest();
        }
    }
    
    /*public static testMethod void redirectToSendForSignatureTPProcessor() {
		UserRole ur = [Select Id from UserRole where Name = 'GLOBAL'];
        Profile p = [SELECT Id FROM Profile WHERE Name like 'System Administrator' Limit 1];
        User user = new User(Alias = 'standt', Email='standarduser123@metacube.com', EmailEncodingKey='UTF-8', LastName='Testing',
                             ProfileId = p.id, LanguageLocaleKey='en_US', LocaleSidKey='en_US', UserName='testuser123@metacube.com',
                             TimeZoneSidKey='America/Los_Angeles', UserRoleId = ur.Id);
        insert user;
        User Usr;
        
        System.runAs(user){
            Usr = getTPProcessor();
            PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'CSM_CSH_Community_Access'];
            insert new PermissionSetAssignment(AssigneeId = Usr.Id, PermissionSetId = ps.Id);
        }
        
        Test.startTest();
        redirectToSendForSignatureTPProcessorFuture(Usr.Id, user.Id);
        Test.stopTest();
    } 
    
    @future
    public static void redirectToSendForSignatureTPProcessorFuture(String usrId, string admUserId){    
        User Usr = [Select Id, Email from User where Id =: usrId];
        User user = [Select Id, Email from User where Id =: admUserId];
        TPA_Request__c  ObjAgg;
        system.runAs(user) {
        	ObjAgg  = getTestAgreement();
        }
        system.runAs(Usr) { 
            UTL_TPA_SetupTestData.createMultilingualTemplateSettingData();
            
            PageReference pageRef = Page.VFP_TPA_GenerateAndSendDoc;
            pageRef.getParameters().put('reqId', ObjAgg.Id);
            pageRef.getParameters().put('type', 'test');
            Test.setCurrentPage(pageRef);
            
            ApexPages.StandardController   StdCtrl = new ApexPages.StandardController(ObjAgg);            
            EXT_TPA_GenerateAndSendDoc controller = new EXT_TPA_GenerateAndSendDoc(StdCtrl);
            controller.serverUrl = '';
            controller.urlId = '';
            controller.generateAndSendForSignDocPotentialVendorCase(ObjAgg.Id);
        }
    }*/
      public static testMethod void redirectToSendForSignatureBulk_AMA_test() {
        UTL_TPA_SetupTestData.createMultilingualTemplateSettingData();
        //User Usr = getTPProcessor();
        TPA_Request__c  ObjAgg  = getTestAgreement();
        ObjAgg.AMA_USPrescriberData__c = 'No';
        update ObjAgg;
        TPA_Request__c tpaRequest = [Select id, AMA_USPrescriberData__c from TPA_Request__c where id = :ObjAgg.Id];
        tpaRequest.AMA_USPrescriberData__c = 'No';
        tpaRequest.is_Bulk_TPA_Request__c = true;
        update tpaRequest;
        AMA_Agreement_Detail__c amaAgg = new AMA_Agreement_Detail__c(TPA_Request__c = tpaRequest.id);
        insert amaAgg; 
        
        Test.startTest();
        PageReference pageRef = Page.VFP_TPA_GenerateAndSendDoc;
        pageRef.getParameters().put('reqId', ObjAgg.Id);
        pageRef.getParameters().put('type', 'test');
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController   StdCtrl = new ApexPages.StandardController(ObjAgg);
        EXT_TPA_GenerateAndSendDoc controller = new EXT_TPA_GenerateAndSendDoc(StdCtrl);
        controller.serverUrl = '';
        controller.urlId = '';
        TPA_Request__c tpaReq = SRV_TPA_TPARequest.getRequestInfo( tpaRequest.id );
        tpaReq = SRV_TPA_TPARequest.manualApproval(tpaReq);
        controller.generateAndSendForSignDocPotentialVendorCase(tpaReq.id);               
        Test.stopTest();
    }
    public static testMethod void redirectToSendForSignature_AMA_test() {
        UTL_TPA_SetupTestData.createMultilingualTemplateSettingData();
        //User Usr = getTPProcessor();
        TPA_Request__c  ObjAgg  = getTestAgreement();
        ObjAgg.AMA_USPrescriberData__c = 'No';
        update ObjAgg;
        TPA_Request__c tpaRequest = [Select id, AMA_USPrescriberData__c from TPA_Request__c where id = :ObjAgg.Id];
        tpaRequest.AMA_USPrescriberData__c = 'No';
        update tpaRequest;
        AMA_Agreement_Detail__c amaAgg = new AMA_Agreement_Detail__c(TPA_Request__c = tpaRequest.id);
        insert amaAgg; 
        
        Test.startTest();
        PageReference pageRef = Page.VFP_TPA_GenerateAndSendDoc;
        pageRef.getParameters().put('reqId', ObjAgg.Id);
        pageRef.getParameters().put('type', 'test');
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController   StdCtrl = new ApexPages.StandardController(ObjAgg);
        EXT_TPA_GenerateAndSendDoc controller = new EXT_TPA_GenerateAndSendDoc(StdCtrl);
        controller.serverUrl = '';
        controller.urlId = '';
        TPA_Request__c tpaReq = SRV_TPA_TPARequest.getRequestInfo( tpaRequest.id );
        tpaReq = SRV_TPA_TPARequest.manualApproval(tpaReq);
        controller.generateAndSendForSignDocPotentialVendorCase(tpaReq.id);               
        Test.stopTest();
    }
}