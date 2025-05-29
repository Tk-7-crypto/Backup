/**
* @author   : Ajinkya Pande
* Test Data for CDA Project. (created under ER-3556 on 10/04/2016)
*/

@isTest
public class TST_CDA_SetupData {
    public CDA_Request__c cdaRecordCustomer {get; set;}
    public CDA_Request__c cdaRecordCEVA {get;set;}
    public CDA_Request__c cdaRecordVendor {get; set;}
    public CDA_Request__c cdaRecordAuditor {get; set;}
    public CDA_Settings__c cdaSetting;
    public User user;
    public String cdaQuery = 'SELECT id, CDA_Id__c, Name, CDA_Type__c, Status__c, QI_Legal_Entity_Name__r.Name, Recipient_Account__r.Name, Competitor_Flag__c, What_is_the_Study_Sponsor_situation__c, Recipient_Account_Address__c, Recipient_Point_of_Contact_Name__c, Recipient_Point_of_Contact_Telephone_Num__c, CDA_Effective_Date__c, Negotiator_Assigned_List__c, CreatedBy.Name, LastModifiedDate, Recipient_Account_Name_Formula__c FROM CDA_Request__c';


    // public CDA_Request__c cdaRecordCEVA {
    //     get {
    //         if(cdaRecordCEVA == null) {
    //             setupTestDataForCEVA();
    //         }
    //         return cdaRecordCEVA;
    //     }
    //     set;
    // }

    public CDA_Account__c cdaAccount {
        get {
            if(cdaAccount == null) {
                cdaAccount = new CDA_Account__c();
                cdaAccount.Name = 'Test Account';
                insert cdaAccount;
            }
            return cdaAccount;
        }
        set;
    }

    //Added by Vikram Singh under CR-11576 Start
    public static CDA_Approved_Governing_Law_Location__c getGoverningLaw(String glName) {
        CDA_Approved_Governing_Law_Location__c governingLaw = new CDA_Approved_Governing_Law_Location__c();
        governingLaw.Name = glName;
        governingLaw.Court_of_Jurisdiction__c = 'Test COJ';
        return governingLaw;
    }

    public static RecordType getRecordType() {
        RecordType recordType = [Select Id, Name from RecordType where SobjectType='CDA_Request__c' and Name = 'LegacyCDA' limit 1];
        return recordType;
    }
    //Added by Vikram Singh under CR-11576 End

    //Updated by Vikram Singh under CR-11576 Start
    public static QI_Legal_Entity__c createQiLegalEntity(String entityName, String businessArea, CDA_Approved_Governing_Law_Location__c governingLaw) {
        QI_Legal_Entity__c qiLegalEntity = new QI_Legal_Entity__c();
        qiLegalEntity.Name = entityName;
        qiLegalEntity.QI_Legal_Entity_Address__c = 'Test Address';
        qiLegalEntity.Name_for_Signature__c = 'Test Signature';
        qiLegalEntity.Title__c = 'Test';
        qiLegalEntity.IQVIA_Business_Area__c = businessArea;
        qiLegalEntity.Location_of_Governing_Law__c = governingLaw.Id;
        return qiLegalEntity;
    }
    //Updated by Vikram Singh under CR-11576 End

    public Contact testContact {
        get {
            if(testContact == null) {
                testContact = new Contact(LastName = 'Test Contact');
                insert testContact;
            }
            return testContact;
        }
        set;
    }

    public TST_CDA_SetupData() {

    }



    public void setupUserRequestor() {
        User sys_admin = [SELECT Id FROM User WHERE Profile.Name='System Administrator' AND isActive=true LIMIT 1];
        System.runas(sys_admin) {
            Profile p = [select id from profile where name='CDA Requestor'];
            user = new User (FirstName = 'Test',LastName = 'User1', EmployeeNumber = '090909092', IsActive = true, Username = 'TestUser@quintilesims.com' + String.valueof(DateTime.now().getTime()), Email = 'TestUser1@quintilesims.com', Alias = 'TestUsr1', TimeZoneSidKey = 'America/Los_Angeles', LocaleSidKey = 'en_US', EmailEncodingKey = 'UTF-8', ProfileId = p.id, LanguageLocaleKey ='en_US', Change_Request_Description__c = 'test', Change_Request_Ticket_Number__c ='test description');
            insert user;
        }
    }

    public void setupUserNegotiator() {
        User sys_admin = [SELECT Id FROM User WHERE Profile.Name='System Administrator' AND isActive=true LIMIT 1];
        System.runas(sys_admin) {
            Profile p = [select id from profile where name='CDA Negotiator'];
            user = new User (FirstName = 'Test',LastName = 'User1', EmployeeNumber = '090909093', IsActive = true, Username = 'TestUser@quintilesims.com' + String.valueof(DateTime.now().getTime()), Email = 'TestUser1@quintilesims.com', Alias = 'TestUsr2', TimeZoneSidKey = 'America/Los_Angeles', LocaleSidKey = 'en_US', EmailEncodingKey = 'UTF-8', ProfileId = p.id, LanguageLocaleKey ='en_US', Change_Request_Description__c = 'test', Change_Request_Ticket_Number__c ='test description');
            insert user;
        }
    }

    CDA_Approved_Governing_Law_Location__c governingLaw;
    QI_Legal_Entity__c qiLegalEntityLI;
    QI_Legal_Entity__c qiLegalEntityLQ;
    public void setUpCustomSetting() {
        cdaSetting = new CDA_Settings__c(Name = 'MyCustSettingName');
        cdaSetting.CDAContractPassword__c = 'TestPassword ';
        cdaSetting.CDAContractServerUrl__c = '/services/Soap/u/14.0/';
        cdaSetting.CDA_Negotiator_central_Mailbox__c = 'Test@quintilesims.com';
        cdaSetting.Docusign_Account_Id__c = 'a';
        cdaSetting.Docusign_URL__c = 'a';
        cdaSetting.Docusign_Username__c = 'a';
        cdaSetting.Email_Communication_Flag__c = true;
        cdaSetting.forceUpdateStatus__c = true;
        cdaSetting.Integration_Key__c =  'a';
        cdaSetting.CDA_Reminders_Interval__c =  1;
        cdaSetting.CDA_Reminders_Interval_for_Customer__c =  2;
        cdaSetting.LanguageReviewReminderPrimary__c = 2;
        cdaSetting.LanguageReviewReminderSecondary__c = 1;
        
        //Added by Vikram Singh under CR-11576 Start
        if(governingLaw == null) {
            governingLaw = getGoverningLaw('United States, State of Delaware');
            insert governingLaw;
        }
        cdaSetting.Default_Governing_Law_Id__c = governingLaw.Id;
        if(qiLegalEntityLI == null) {
            qiLegalEntityLI = createQiLegalEntity('Test Entity1', UTL_CDAUtility.CDA_BUSINESS_PART_LI, governingLaw);
            insert qiLegalEntityLI;
        }
        cdaSetting.Default_Legal_Entity_Id_IQVIA_Commercial__c = qiLegalEntityLI.Id;
        if(qiLegalEntityLQ == null) {
            qiLegalEntityLQ = createQiLegalEntity('Test Entity2', UTL_CDAUtility.CDA_BUSINESS_PART_LQ, governingLaw);
            insert qiLegalEntityLQ;
        }
        //Added by Vikram Singh under CR-11576 End
        cdaSetting.Default_QI_Legal_Entity_Id__c = qiLegalEntityLQ.Id; //Updated by Vikram Singh under CR-11576
        cdaSetting.HistoricalDataRecordType__c = 'HistoricalData';   //Added by Vikram Singh under CR-11691
        cdaSetting.CDADocTemplateMapping__c = 'Customer~Test Customer Mutual CDA Template,Auditor~Test Test Auditor CDA Template,Vendor~Test Vendor Mutual CDA Template,CEVA~Test Vendor Mutual CDA Template';
        cdaSetting.CDA_Dev_Emails__c = 'abc@quintilesims.com';
        cdaSetting.Is_CDA_System_Down__c = false;
        if(cdaSetting.Id == null) {
            insert cdaSetting;
        }
        setupCDAMultilingualTemplateListSettings();
    }

    public void setupCDAMultilingualTemplateListSettings() {
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        System.runAs (thisUser) {
            EmailTemplate et = new EmailTemplate();
            et.isActive = true;
            et.Name = 'testTemplate';
            et.DeveloperName = 'testTemplate' + System.now().getTime();
            et.TemplateType = 'text';
            et.FolderId = UserInfo.getUserId();
            et.Body = '';
            insert et;
        
            List<CDA_Multilingual_Template_List_Settings__c> cdaTempSettings = new List<CDA_Multilingual_Template_List_Settings__c>{
                new CDA_Multilingual_Template_List_Settings__c( Name = 'MyCDATemplate1', Label__c = UTL_CDAUtility.EMAIL_EXTERNAL_PAPER_REVIEW, Language__c = 'English', Template_Id__c = et.Id, Template_Name__c = UTL_CDAUtility.EMAIL_EXTERNAL_PAPER_REVIEW),
                new CDA_Multilingual_Template_List_Settings__c( Name = 'MyCDATemplate2', Label__c = UTL_CDAUtility.EMAIL_REQ_EXCU8_AGGR_RECVD, Language__c = 'English', Template_Id__c = et.Id, Template_Name__c = UTL_CDAUtility.EMAIL_REQ_EXCU8_AGGR_RECVD),
                new CDA_Multilingual_Template_List_Settings__c( Name = 'MyCDATemplate3', Label__c = UTL_CDAUtility.EMAIL_RECIPIENT_REVIEW_REQUEST, Language__c = 'English', Template_Id__c = et.Id, Template_Name__c = UTL_CDAUtility.EMAIL_RECIPIENT_REVIEW_REQUEST),
                new CDA_Multilingual_Template_List_Settings__c( Name = 'MyCDATemplate4', Label__c = UTL_CDAUtility.EMAIL_INTERNAL_SIGNATURE_REQ, Language__c = 'English', Template_Id__c = et.Id, Template_Name__c = UTL_CDAUtility.EMAIL_INTERNAL_SIGNATURE_REQ),
                new CDA_Multilingual_Template_List_Settings__c( Name = 'MyCDATemplate5', Label__c = UTL_CDAUtility.EMAIL_OGC_COMPETITOR_REVW_REQ, Language__c = 'English', Template_Id__c = et.Id, Template_Name__c = UTL_CDAUtility.EMAIL_OGC_COMPETITOR_REVW_REQ),
                new CDA_Multilingual_Template_List_Settings__c( Name = 'MyCDATemplate6', Label__c = UTL_CDAUtility.EMAIL_RESPONSE_RECEIVED, Language__c = 'English', Template_Id__c = et.Id, Template_Name__c = UTL_CDAUtility.EMAIL_RESPONSE_RECEIVED),
                new CDA_Multilingual_Template_List_Settings__c( Name = 'MyCDATemplate7', Label__c = UTL_CDAUtility.EMAIL_RECIPIENT_EXC8_CONFIRM, Language__c = 'English', Template_Id__c = et.Id, Template_Name__c = UTL_CDAUtility.EMAIL_RECIPIENT_EXC8_CONFIRM),
                new CDA_Multilingual_Template_List_Settings__c( Name = 'MyCDATemplate8', Label__c = UTL_CDAUtility.EMAIL_CANCEL_BY_REQUESTOR, Language__c = 'English', Template_Id__c = et.Id, Template_Name__c = UTL_CDAUtility.EMAIL_CANCEL_BY_REQUESTOR),
                new CDA_Multilingual_Template_List_Settings__c( Name = 'MyCDATemplate9', Label__c = UTL_CDAUtility.EMAIL_NEGOTIATOR_ASSIGNED, Language__c = 'English', Template_Id__c = et.Id, Template_Name__c = UTL_CDAUtility.EMAIL_NEGOTIATOR_ASSIGNED),
                new CDA_Multilingual_Template_List_Settings__c( Name = 'MyCDATemplate10', Label__c = UTL_CDAUtility.EMAIL_RESPONSE_TO_REQUESTOR, Language__c = 'English', Template_Id__c = et.Id, Template_Name__c = UTL_CDAUtility.EMAIL_RESPONSE_TO_REQUESTOR),
                new CDA_Multilingual_Template_List_Settings__c( Name = 'MyCDATemplate12', Label__c = UTL_CDAUtility.EMAIL_RECIPIENT_REVIEW_REMINDER, Language__c = 'English', Template_Id__c = et.Id, Template_Name__c = UTL_CDAUtility.EMAIL_RECIPIENT_REVIEW_REMINDER),
                new CDA_Multilingual_Template_List_Settings__c( Name = 'MyCDATemplate13', Label__c = UTL_CDAUtility.EMAIL_RECIPIENT_REVIEW_REMINDER_Auditor, Language__c = 'English', Template_Id__c = et.Id, Template_Name__c = UTL_CDAUtility.EMAIL_RECIPIENT_REVIEW_REMINDER_Auditor),
                new CDA_Multilingual_Template_List_Settings__c( Name = 'MyCDATemplate14', Label__c = UTL_CDAUtility.CDA_ORG_WIDE_EMAIL_ID, Language__c = 'English', Template_Id__c = et.Id, Template_Name__c = UTL_CDAUtility.CDA_ORG_WIDE_EMAIL_ID),
                new CDA_Multilingual_Template_List_Settings__c( Name = 'MyCDATemplate15', Label__c = 'Docusign Branding', Language__c = 'English', Template_Id__c = '12233344-5678-9999-1111-2343467567', Template_Name__c = 'Docusign Branding'),
                new CDA_Multilingual_Template_List_Settings__c( Name = 'MyCDATemplate16', Label__c = UTL_CDAUtility.EMAIL_LEGAL_POC_ASSIGNMENT, Language__c = 'NonEnglish', Template_Id__c = et.Id, Template_Name__c = UTL_CDAUtility.EMAIL_LEGAL_POC_ASSIGNMENT),
                new CDA_Multilingual_Template_List_Settings__c( Name = 'MyCDATemplate17', Label__c = UTL_CDAUtility.EMAIL_LEGAL_POC_REMINDER, Language__c = 'NonEnglish', Template_Id__c = et.Id, Template_Name__c = UTL_CDAUtility.EMAIL_LEGAL_POC_REMINDER)                
            };
            insert cdaTempSettings;
        }
    }
    // For LQ org.
    /*public void setUpContactForEmail() {
        SObject obj;
        Id parentRecordTypeId;
        Schema.SObjectType targetType = Schema.getGlobalDescribe().get('Account');
        if (targetType != null) {
            obj = targetType.newSObject();
            Schema.DescribeSObjectResult d = obj.getSObjectType().getDescribe();
            if (d != null) {
                Map<String, Schema.RecordTypeInfo> rtMap = d.getRecordTypeInfosByName();
                if (rtMap != null) {
                    Schema.RecordTypeInfo rtInfo = rtMap.get('Parent Account');
                    if (rtInfo != null) {
                        parentRecordTypeId= rtInfo.getRecordTypeId();
                    }
                }
            }
        }

        Account parentAccount = new Account ( Name='Master - PARENT', RecordTypeId = parentRecordTypeId,CustomerSegment__c = 'GOVERNMENT',Sub_Industry__c = 'STATE' ) ;
        insert parentAccount;

        Account testAccount;
        testAccount = new Account();
        testAccount.ParentId = parentAccount.Id ;
        testAccount.Name = 'IMS Health Global';
		testAccount.CustomerSegment__c = 'GOVERNMENT';
		testAccount.Sub_Industry__c = 'STATE';
        insert testAccount;

        contact tstcontact = new Contact();
        tstcontact.Account = testAccount;
        tstcontact.Lastname = 'testContact';
        insert tstcontact;
    }*/

    // For LI Org

    public void setUpContactForEmail() {
        setUpPseSecurity();
        Account testAccount;
        testAccount = new Account();
        testAccount.Name = 'IMS Health Global';
		testAccount.CustomerSegment__c = 'GOVERNMENT';
		testAccount.Sub_Industry__c = 'STATE';
        insert testAccount;
        contact tstcontact = new Contact();
        tstcontact.Account = testAccount;
        tstcontact.Firstname = 'testfirstname';
        tstcontact.Lastname = 'testContact';
        insert tstcontact;
    }

    /**
    * Purpose : Default settings to be created For LI Org
    */

    public static void setUpPseSecurity()
    {
        // Create PseSecurityConfig__c
        //upsert new PseSecurityConfig__c( DisableSecurityTriggers__c = true, UserName__c = 'testt@imshealth1.com.dev2',
                                       // DefaultOwnerUsername__c = 'integration@uk.imshealth1.com.dev2', SetupOwnerId = UserInfo.getOrganizationId());

        // Create QuickOppLimit__c
        //QuickOppLimit__c quickOp = new QuickOppLimit__c( Amount__c = 10000.0, Name = 'Default' );
        //insert quickOp ;

        // Create IsTest__c
        //IsTest__c it = IsTest__c.getInstance('Default');

        //if(it == null)
        //    it = new IsTest__c( Name='Default' );
        //it.isTest__c = true;
        //upsert it;

        // Create  pse__Region__c
        //insert new pse__Region__c( Name='xz', pse__Hierarchy_Depth__c = 0, ProfitCenterCode__c = 'GIMsS-STD' );
    }

    // Creating data for new request for customer
    public CDA_Request__c setupTestDataForCustomer(QI_Legal_Entity__c qiLegalEntity) {  //Updated by Vikram Singh under CR-11576
        cdaRecordCustomer = new CDA_Request__c();
        cdaRecordCustomer.RecordTypeId = getRecordType().Id; //Added by Vikram Singh under CR-11691
        cdaRecordCustomer.QuintilesIMS_Business__c = UTL_CDAUtility.CDA_BUSINESS_PART_LI;
        cdaRecordCustomer.CDA_Type__c = UTL_CDAUtility.CUSTOMER;
        cdaRecordCustomer.CDA_Effective_Date__c = Date.today();
        cdaRecordCustomer.Disclosure_Period__c = '5';
        cdaRecordCustomer.Holding_Period__c = '3';
        cdaRecordCustomer.QuintilesIMS_Affiliates_Value__c = 'Yes';
        cdaRecordCustomer.Requestor_Carbon_Copies__c = false;
        cdaRecordCustomer.SOPs_Provided__c = UTL_CDAUtility.YES;
        cdaRecordCustomer.CDA_Source__c = UTL_CDAUtility.CDASOURCE_QUINTILESIMS;
        cdaRecordCustomer.CDA_Format__c = UTL_CDAUtility.CDA_FORMAT_PDF;
        cdaRecordCustomer.Competitor_Flag__c = UTL_CDAUtility.YES; // Project specific Indicator to Yes
        cdaRecordCustomer.QI_Legal_Entity_Name__c = qiLegalEntity.Id;    //Updated by Vikram Singh under CR-11576
        cdaRecordCustomer.Recipient_Account__c = cdaAccount.Id;
        cdaRecordCustomer.Competitor_Contracting_Capacity__c = UTL_CDAUtility.CONTRACTINGCAPACITY_CUSTOMER;
        cdaRecordCustomer.What_is_the_Study_Sponsor_situation__c = UTL_CDAUtility.STUDYSPONSORIDENTIFIED;
        cdaRecordCustomer.Customer_Consent_to_Disclose__c = UTL_CDAUtility.YES;
        cdaRecordCustomer.Sponsor_Legal_Entity__c = cdaAccount.Id;
        cdaRecordCustomer.Competitor_System_Access__c =  UTL_CDAUtility.NO;
        cdaRecordCustomer.Recipient_Point_of_Contact_First_Name__c = 'testFirstName';
        cdaRecordCustomer.Recipient_Point_of_Contact_Last_Name__c = 'testLastName';
        cdaRecordCustomer.Recipient_Point_of_Contact_Title__c = 'SE';
        cdaRecordCustomer.Recipient_Point_of_Contact_Telephone_Num__c = '1234567891';
        cdaRecordCustomer.Recipient_Point_of_Contact_Email_Address__c = 'test@quintilesims.com';
        cdaRecordCustomer.Recipient_Point_of_Contact_Preferred_Met__c = 'Email';
        cdaRecordCustomer.Recipient_Authorized_Signer_First_Name__c = 'TestUser1';
        cdaRecordCustomer.Recipient_Authorized_Signer_Last_Name__c = 'TestLastName';
        cdaRecordCustomer.Recipient_Authorized_Signer_Title__c = 'SSE';
        cdaRecordCustomer.Recipient_Authorized_Signer_Email_Addres__c = 'test@quintilesims.com';
        cdaRecordCustomer.CDA_Language__c = 'English';
        cdaRecordCustomer.Status__c = UTL_CDAUtility.STATUS_INDRAFT;
        insert cdaRecordCustomer;
        return cdaRecordCustomer;
    }

    public CDA_Request__c setupTestDataForVendor(QI_Legal_Entity__c qiLegalEntity) {    //Updated by Vikram Singh under CR-11576
        cdaRecordVendor = new CDA_Request__c();
        cdaRecordVendor.RecordTypeId = getRecordType().Id; //Added by Vikram Singh under CR-11691
        cdaRecordVendor.QuintilesIMS_Business__c = UTL_CDAUtility.CDA_BUSINESS_PART_LQ;
        cdaRecordVendor.CDA_Type__c = UTL_CDAUtility.VENDOR;
        cdaRecordVendor.CDA_Effective_Date__c = Date.today();
        cdaRecordVendor.Disclosure_Period__c = '5';
        cdaRecordVendor.Holding_Period__c = '3';
        cdaRecordVendor.QuintilesIMS_Affiliates_Value__c = 'Yes';
        cdaRecordVendor.Requestor_Carbon_Copies__c = false;
        cdaRecordVendor.SOPs_Provided__c = UTL_CDAUtility.YES;
        cdaRecordVendor.CDA_Source__c = UTL_CDAUtility.CDASOURCE_QUINTILESIMS;
        cdaRecordVendor.CDA_Format__c = UTL_CDAUtility.CDA_FORMAT_PDF;
        cdaRecordVendor.Competitor_Flag__c = UTL_CDAUtility.YES; // Project specific Indicator to Yes
        cdaRecordVendor.QI_Legal_Entity_Name__c = qiLegalEntity.Id;    //Updated by Vikram Singh under CR-11576
        cdaRecordVendor.Recipient_Account__c = cdaAccount.Id;
        cdaRecordVendor.Competitor_Contracting_Capacity__c = UTL_CDAUtility.CONTRACTINGCAPACITY_VENDOR;
        cdaRecordVendor.What_is_the_Study_Sponsor_situation__c = UTL_CDAUtility.STUDYSPONSORIDENTIFIED;
        cdaRecordVendor.Sponsor_Legal_Entity__c = cdaAccount.Id;
        cdaRecordVendor.Competitor_System_Access__c =  UTL_CDAUtility.NO;
        cdaRecordVendor.Recipient_Point_of_Contact_First_Name__c = 'testFirstName';
        cdaRecordVendor.Recipient_Point_of_Contact_Last_Name__c = 'testLastName';
        cdaRecordVendor.Recipient_Point_of_Contact_Title__c = 'SE';
        cdaRecordVendor.Recipient_Point_of_Contact_Telephone_Num__c = '1234567891';
        cdaRecordVendor.Recipient_Point_of_Contact_Email_Address__c = 'test@quintilesims.com';
        cdaRecordVendor.Recipient_Point_of_Contact_Preferred_Met__c = 'Email';
        cdaRecordVendor.Recipient_Authorized_Signer_First_Name__c = 'TestUser1';
        cdaRecordVendor.Recipient_Authorized_Signer_Last_Name__c = 'TestLastName';
        cdaRecordVendor.Recipient_Authorized_Signer_Title__c = 'SSE';
        cdaRecordVendor.Recipient_Authorized_Signer_Email_Addres__c = 'test@quintilesims.com';
        cdaRecordVendor.CDA_Language__c = 'English';
        insert cdaRecordVendor;
        return cdaRecordVendor;
    }

    public CDA_Request__c setupTestDataForAuditor(QI_Legal_Entity__c qiLegalEntity) {   //Updated by Vikram Singh under CR-11576
        cdaRecordAuditor =  new CDA_Request__c();
        cdaRecordAuditor.RecordTypeId = getRecordType().Id; //Added by Vikram Singh under CR-11691
        cdaRecordAuditor.QuintilesIMS_Business__c = UTL_CDAUtility.CDA_BUSINESS_PART_LQ;
        cdaRecordAuditor.CDA_Type__c = UTL_CDAUtility.AUDITOR;
        cdaRecordAuditor.CDA_Effective_Date__c = Date.today();
        // cdaRecordAuditor.QuintilesIMS_Affiliates_Value__c = 'Yes';
        cdaRecordAuditor.CDA_Language__c = 'English';
        cdaRecordAuditor.Requestor_Carbon_Copies__c = false;
        // cdaRecordAuditor.SOPs_Provided__c = UTL_CDAUtility.YES;
        cdaRecordAuditor.CDA_Source__c = UTL_CDAUtility.CDASOURCE_QUINTILESIMS;
        cdaRecordAuditor.CDA_Format__c = UTL_CDAUtility.CDA_FORMAT_PDF;
        cdaRecordAuditor.Competitor_Flag__c = UTL_CDAUtility.NO; // Project specific Indicator to Yes
        // cdaRecordAuditor.Competitor_Contracting_Capacity__c = UTL_CDAUtility.CONTRACTINGCAPACITY_CUSTOMER;
        // cdaRecordAuditor.What_is_the_Study_Sponsor_situation__c = UTL_CDAUtility.STUDYSPONSORIDENTIFIED;
        cdaRecordAuditor.Audit_Type__c = UTL_CDAUtility.QUALIFICATION;
        cdaRecordAuditor.QI_Legal_Entity_Governing_Law__c = 'India';
        cdaRecordAuditor.QI_Legal_Entity_Name__c = qiLegalEntity.Id;    //Updated by Vikram Singh under CR-11576
        cdaRecordAuditor.Recipient_Account__c = cdaAccount.Id;
        cdaRecordAuditor.Cust_Legal_Entity_Name__c = cdaAccount.Id;
        // cdaRecordAuditor.Sponsor_Legal_Entity__c = cdaAccount.Id;
        // cdaRecordAuditor.Competitor_System_Access__c =  UTL_CDAUtility.NO;
        cdaRecordAuditor.Recipient_Point_of_Contact_First_Name__c = 'testFirstName';
        cdaRecordAuditor.Recipient_Point_of_Contact_Last_Name__c = 'testLastName';
        cdaRecordAuditor.Recipient_Point_of_Contact_Title__c = 'SE';
        cdaRecordAuditor.Recipient_Point_of_Contact_Telephone_Num__c = '1234567891';
        cdaRecordAuditor.Recipient_Point_of_Contact_Email_Address__c = 'test@quintilesims.com';
        // cdaRecordAuditor.Recipient_Point_of_Contact_Preferred_Met__c = 'Email';
        // cdaRecordAuditor.Recipient_Authorized_Signer_First_Name__c = 'TestUser1';
        // cdaRecordAuditor.Recipient_Authorized_Signer_Last_Name__c = 'TestLastName';
        // cdaRecordAuditor.Recipient_Authorized_Signer_Title__c = 'SSE';
        // cdaRecordAuditor.Recipient_Authorized_Signer_Email_Addres__c = 'test@quintilesims.com';
        insert cdaRecordAuditor;
        return cdaRecordAuditor;
    }

    public CDA_Request__c setupTestDataForCEVA(QI_Legal_Entity__c qiLegalEntity) {  //Updated by Vikram Singh under CR-11576
        cdaRecordCEVA =  new CDA_Request__c();
        cdaRecordCEVA.RecordTypeId = getRecordType().Id; //Added by Vikram Singh under CR-11691
        cdaRecordCEVA.QuintilesIMS_Business__c = UTL_CDAUtility.CDA_BUSINESS_PART_LQ;
        cdaRecordCEVA.CDA_Type__c = UTL_CDAUtility.CEVA;
        cdaRecordCEVA.CDA_Effective_Date__c = Date.today();
        cdaRecordCEVA.QuintilesIMS_Affiliates_Value__c = 'Yes';
        cdaRecordCEVA.Requestor_Carbon_Copies__c = false;
        cdaRecordCEVA.SOPs_Provided__c = UTL_CDAUtility.YES;
        cdaRecordCEVA.CDA_Source__c = UTL_CDAUtility.CDASOURCE_QUINTILESIMS;
        cdaRecordCEVA.CDA_Format__c = UTL_CDAUtility.CDA_FORMAT_PDF;
        cdaRecordCEVA.Competitor_Flag__c = UTL_CDAUtility.YES; // Project specific Indicator to Yes
        cdaRecordCEVA.QI_Legal_Entity_Name__c = qiLegalEntity.Id;    //Updated by Vikram Singh under CR-11576
        cdaRecordCEVA.Recipient_Account__c = cdaAccount.Id;
        cdaRecordCEVA.Sponsor_Legal_Entity__c = cdaAccount.Id;
        cdaRecordCEVA.Competitor_System_Access__c =  UTL_CDAUtility.NO;
        cdaRecordCEVA.Recipient_Point_of_Contact_First_Name__c = 'testFirstName';
        cdaRecordCEVA.Recipient_Point_of_Contact_Last_Name__c = 'testLastName';
        cdaRecordCEVA.Recipient_Point_of_Contact_Title__c = 'SE';
        cdaRecordCEVA.Recipient_Point_of_Contact_Telephone_Num__c = '1234567891';
        cdaRecordCEVA.Recipient_Point_of_Contact_Email_Address__c = 'test@quintilesims.com';
        cdaRecordCEVA.Recipient_Point_of_Contact_Preferred_Met__c = 'Email';
        cdaRecordCEVA.Recipient_Authorized_Signer_First_Name__c = 'TestUser1';
        cdaRecordCEVA.Recipient_Authorized_Signer_Last_Name__c = 'TestLastName';
        cdaRecordCEVA.Recipient_Authorized_Signer_Title__c = 'SSE';
        cdaRecordCEVA.Recipient_Authorized_Signer_Email_Addres__c = 'test@quintilesims.com';
        cdaRecordCEVA.CDA_Language__c = 'English';
        insert cdaRecordCEVA;
        return cdaRecordCEVA;
    }

    /**
    * Purpose : Get a Docusign Status for specified CDA Request.
    */
    public static dsfs__DocuSign_Status__c getDSStatusByRequestId(String requestName) {
        dsfs__DocuSign_Envelope__c testDSEnvelope = new dsfs__DocuSign_Envelope__c();
        insert testDSEnvelope;

        dsfs__DocuSign_Status__c testDSStatus = new dsfs__DocuSign_Status__c();
        testDSStatus.dsfs__Envelope_Status__c = 'Sent';
        testDSStatus.dsfs__DocuSign_Envelope_ID__c = testDSEnvelope.Id;
        testDSStatus.dsfs__Subject__c = requestName + '- REQUEST FOR SIGNATURE';
        testDSStatus.dsfs__Sender__c = 'IQVIA';  //Modified by Vikram Singh under CR-11577
        testDSStatus.dsfs__Sender_Email__c = 'sender.mail@quintilesims.com';

        insert testDSStatus;
        return testDSStatus;
    }

    /**
    * Retrives list of record sizes/page to display on the page.
    */
    public List <SelectOption> setRecordsPerPage() {
        List <SelectOption> recordsPerPag = new List <SelectOption> ();
        recordsPerPag.add(new SelectOption('10', '10'));
        recordsPerPag.add(new SelectOption('20', '20'));
        recordsPerPag.add(new SelectOption('50', '50'));
        recordsPerPag.add(new SelectOption('100', '100'));
        return recordsPerPag;
    }

    /**
     * Purpose : Get an attachment of a given name and parent id.
     */
    public Attachment getAttachment(String attachName, Id parentId) {
        Attachment testAttachment = new Attachment(Name = attachName, ParentId = parentId, Body=Blob.valueOf('Test Data'));
        insert testAttachment;
        return testAttachment;
    }

    /**Overriding
     * Purpose : Insert/Get an attachment of a given name and parent id.
     */
    public Attachment getAttachment(String attachName, Id parentId, Boolean isInsert) {
        Attachment testAttachment = new Attachment(Name = attachName, ParentId = parentId, Body=Blob.valueOf('Test Data'));
        
        if(isInsert) {
            insert testAttachment;
        }
        return testAttachment;
    }

    /**
     * CrossWalk data record creation
     */
    public CDA_Language_Cross_Walk__c setCDAMultilingualCrossWalkData() {
        CDA_Language_Cross_Walk__c cwRecord = new CDA_Language_Cross_Walk__c();
        cwRecord.Object_Type__c = 'CDA_Request__c';
        // cwRecord.Object_Label__c = 'CDA Request';
        cwRecord.Control_Type__c = 'Picklist';
        cwRecord.Field_Type__c = 'QI_Legal_Entity_Governing_Law__c';
        // cwRecord.Field_Label__c = 'Governing Law';
        cwRecord.English_Translation__c = 'Test GL';
        cwRecord.Japanese_Translation__c = 'Test GL';
        cwRecord.Default_Value__c = 'Test GL';
        cwRecord.isDeleted__c = false;
        insert cwRecord;

        return cwRecord;
    }
}