@isTest
public class TST_CNT_TPA_DynamicAttachments {
    public static Workflow_Email_Record__c objWorkFlowRecord;
    @testSetup static void setup() {
        objWorkFlowRecord = new Workflow_Email_Record__c(Email_Action__c = 'TPA_01_SendEmail', content_1__c = 'Main Content', Module_Name__c = 'TPA', isAttachmentRequired__c = TRUE, Attachment_Details__c = 'attName~~attId;');
        insert objWorkFlowRecord;
        
        Date todayDate = Date.today();
        
        Account testAccount1 = new Account();
        testAccount1.Name = 'Test Acc';
        testAccount1.CustomerSegment__c = 'GOVERNMENT';
        testAccount1.Sub_Industry__c = 'STATE';
        insert testAccount1;
        
        Account_Compliance__c accCompl = new Account_Compliance__c(Account__c = testAccount1.Id, Client_TPA_Compliance_Hold__c = true, Vendor_TPA_Compliance_Hold__c = true, Client_TPA_Compliance_Hold_Reason__c = 'Client on Hold', Vendor_TPA_Compliance_Hold_Reason__c = 'Vendor on Hold');
        insert accCompl;
        
        Address__c testNewClientAccount = UTL_TPA_SetupTestData.getAddress();
        testNewClientAccount.Name = 'test New Client';
        testNewClientAccount.is_TPA_Account__c = true;
        testNewClientAccount.Account__c = testAccount1.Id;
        testNewClientAccount.Street__c = 'test';
        testNewClientAccount.City__c = 'test';
        testNewClientAccount.Country__c = 'test';
        testNewClientAccount.PostalCode__c = 'test';
        insert testNewClientAccount;
        
        Contact testContact = UTL_TPA_SetupTestData.getContact();
        testContact.AccountId = testNewClientAccount.Account__r.Id;
        insert testContact;
        
        TPA_Request__c tpaRequest1 = UTL_TPA_SetupTestData.getTestTPARequest();
        tpaRequest1.OwnerId = UserInfo.getUserId();
        tpaRequest1.Service_Provider_Address__c = testNewClientAccount.Id;
        tpaRequest1.Client_Address__c = testNewClientAccount.Id;
        tpaRequest1.Client_Language__c = 'Japanese';
        tpaRequest1.Vendor_Language__c = 'Japanese';
        tpaRequest1.Vendor_Billing_Mailing_Country__c = 'united states';
        tpaRequest1.Request_Status__c = 'In Review by IQVIA';
        tpaRequest1.Data_Access_End_Date__c = todayDate.addDays(-1);
        tpaRequest1.ClientContact__c = testContact.Id;
        tpaRequest1.Is_Renewed__c = false;
        tpaRequest1.Purpose_List__c = 'Test Purpose List';
        tpaRequest1.Data_Asset_List__c = 'AAN';
        tpaRequest1.IMS_Legal_Entity_List__c = 'test';
        tpaRequest1.Secondary_Data_Asset_List__c = 'Test';
        tpaRequest1.Client_Request_Submission__c = todayDate.addDays(2);
        tpaRequest1.TP_Processor_Email__c = 'test@mail.com';
        tpaRequest1.Data_access_end_date__c = (Date.today()).addDays(3);
        tpaRequest1.Vendor_Language__c =  'English';
        insert tpaRequest1;

        TPA_Agreement_Additional_Field__c tpaReqAdditionalDetail = new TPA_Agreement_Additional_Field__c(Related_TPA_Request__c = tpaRequest1.id);
        insert tpaReqAdditionalDetail;
    }
    
    @isTest
    private static void testMethod1(){
        setup();
        CNT_TPA_DynamicAttachments objCntTpaVfEmail = new CNT_TPA_DynamicAttachments();
        objCntTpaVfEmail.ObjRecId = [Select Id from Workflow_Email_Record__c LIMIT 1].Id;
        string objWorkFlowRecordDetail = objCntTpaVfEmail.getWorkflowRecordDetail();
        TPA_Request__c tpaRequest1 = [select Id from TPA_Request__c limit 1];

        objCntTpaVfEmail.attDetRecId = tpaRequest1.Id;
        string baseUrl = objCntTpaVfEmail.baseOrgUrl;
        objCntTpaVfEmail.getTpaReqAdditionalDetail();        
    }
}