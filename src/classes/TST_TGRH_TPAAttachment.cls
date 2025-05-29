/**
 * Updated by: Vikram Singh Fartyal on 31 March, 2018
 * @Purpose: Test Class for TGRH_TPAAttachment class
 */

@isTest(SeeAllData=false)
public class TST_TGRH_TPAAttachment {
    static void setupData() {
        TPA_Settings__c objTpaSett = UTL_TPA_SetupTestData.createTPASettingsDataBasedOnOrganization();
        objTpaSett.TPA_BCC_Emails__c = 'testbcc@test.com';
        update objTpaSett;
        
        UTL_TPA_SetupTestData.createAMASetting();

        Date todayDate = Date.today();
        
        Account testAccount2 = new Account( name = 'TPA Test Account',
                                          BillingCountry = 'India',
                                          BillingState = 'Delhi',
                                          BillingCity = 'Test',
                                          BillingStreet = 'Test',
                                          BillingPostalCode = '123',CustomerSegment__c = 'GOVERNMENT',Sub_Industry__c = 'STATE' );
        insert testAccount2;
        List<Address__c> acclst = new List<Address__c>();
        Address__c testAccount1 = UTL_TPA_SetupTestData.getAddress();
        acclst.add(testAccount1);
        insert acclst;
        Contact  con = new Contact(FirstName = 'TestFirstName', LastName = 'Test Contact', Email = 'sunny.bansal@metacube.com', AccountId = testAccount2.id);
        
        insert con;
        
        List<TPA_Request__c> lstAgreement = new List<TPA_Request__c>();

        TPA_Request__c testAgreement2 = UTL_TPA_SetupTestData.gettestAgreement();
        testAgreement2.AMA_USPrescriberData__c = 'Yes';
        testAgreement2.Data_Access_Start_Date__c = todayDate;
        testAgreement2.Data_Access_End_Date__c = todayDate.addDays(2);
        testAgreement2.Requires_Manual_Review__c = false;
        testAgreement2.TP_Processor_Email__c = 'a.a@gmail.com';
        testAgreement2.TP_Processor_Name__c = 'Test TP Processor';
        testAgreement2.Vendor_Contact_e_mail__c = 'vendor.email@gmail.com';
        testAgreement2.TPA_Authorised_Signer__c = 'Yes';
        testAgreement2.Client_Address__c = testAccount1.Id;
        testAgreement2.Service_Provider_Address__c = testAccount1.Id;
        testAgreement2.ClientContact__c = con.Id;
        testAgreement2.Authorized_Signer_Email__c = 'email.authorised@gmail.com';
        testAgreement2.Vendor_First_Name__c ='FName';
        testAgreement2.Vendor_Contact_Last_Name__c ='LName';
        testAgreement2.Client_Contact_Territory__c = 'USA';
        testAgreement2.Vendor_App_Submitted__c = Date.newInstance(2015, 10, 20);
        testAgreement2.Request_Status__c = 'In Auto Approval Process';
        testAgreement2.is_Addendum_Attachment_Required__c = true;
        lstAgreement.add(testAgreement2);
        insert lstAgreement;
        TPA_Contact__c tpacontact =  new TPA_Contact__c(Name = 'test contact', TPA_Request__c = testAgreement2.Id, Type__c = 'Additional Client Contact', Email__c = 'test@gmail.com');
        insert tpacontact;
        Test.startTest();
        AMA_Agreement_Detail__c amaAgg = UTL_TPA_SetupTestData.getAMAAgreementDetailBlank(testAgreement2.id);
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

        List<Attachment> lstAttachment1 = new List<Attachment>();
        
        lstAttachment1.add(UTL_TPA_SetupTestData.addAttachment(testAgreement2.id, 'STANDARD TERMS AND CONDITIONS.pdf'));
        lstAttachment1.add(UTL_TPA_SetupTestData.addAttachment(testAgreement2.id, 'Original_Use Defination Template'));
        lstAttachment1.add(UTL_TPA_SetupTestData.addAttachment(testAgreement2.id, 'Original TLLA TPA Limited License Agreement Regenerated'));
        lstAttachment1.add(UTL_TPA_SetupTestData.addAttachment(testAgreement2.id, Label.TPSA_Client_Template_Name));
        lstAttachment1.add(UTL_TPA_SetupTestData.addAttachment(testAgreement2.id, 'AMA_Original TPA- Use Defination Limited License Agreement.pdf'));
        lstAttachment1.add(UTL_TPA_SetupTestData.addAttachment(testAgreement2.id, 'AMA_Original TPA- Use Defination Limited License Agreement.pdf_Completed'));
        lstAttachment1.add(UTL_TPA_SetupTestData.addAttachment(testAgreement2.id, 'Addendum Notification.pdf'));
        lstAttachment1.add(UTL_TPA_SetupTestData.addAttachment(testAgreement2.id, 'Addendum Notification.pdf_Completed'));
        
        insert lstAttachment1;
        Test.stopTest();

    }
    
    static void setupData1() {
        TPA_Settings__c objTpaSett = UTL_TPA_SetupTestData.createTPASettingsDataBasedOnOrganization();
        objTpaSett.TPA_BCC_Emails__c = 'testbcc@test.com';
        update objTpaSett;
        
        UTL_TPA_SetupTestData.createAMASetting();

        Date todayDate = Date.today();
        
        Address__c testAccount1 = UTL_TPA_SetupTestData.getAddress();
        insert testAccount1;
        
        TPA_Request__c testAgreement = UTL_TPA_SetupTestData.gettestAgreement();
        testAgreement.Request_Status__c = 'Awaiting Vendor Submission';
        testAgreement.AMA_USPrescriberData__c = 'Yes';
        testAgreement.Data_Access_Start_Date__c = todayDate;
        testAgreement.Data_Access_End_Date__c = todayDate.addDays(2);
        testAgreement.Requires_Manual_Review__c = false;
        testAgreement.TP_Processor_Email__c = 'a.a@gmail.com';
        testAgreement.TP_Processor_Name__c = 'Test TP Processor';
        testAgreement.Vendor_Contact_e_mail__c = 'vendor.email@gmail.com';
        testAgreement.TPA_Authorised_Signer__c = 'Yes';
        testAgreement.Client_Address__c = testAccount1.Id;
        testAgreement.Service_Provider_Address__c = testAccount1.Id;
        testAgreement.Authorized_Signer_Email__c = 'email.authorised@gmail.com';
        testAgreement.Vendor_First_Name__c ='FName';
        testAgreement.Vendor_Contact_Last_Name__c ='LName';
        testAgreement.Client_Contact_Territory__c = 'USA';
        testAgreement.Vendor_App_Submitted__c = Date.newInstance(2015, 10, 20);
        insert testAgreement;
        
        AMA_Agreement_Detail__c amaAgg = UTL_TPA_SetupTestData.getAMAAgreementDetailBlank(testAgreement.id);
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
        
        dsfs__DocuSign_Status__c objDocusignStatus = UTL_TPA_SetupTestData.getDocusignStatus(testAgreement.id);
        
        List<Attachment> lstAttachment1 = new List<Attachment>();
        lstAttachment1.add(UTL_TPA_SetupTestData.addAttachment(objDocusignStatus.id, 'Signed-on Paper'));
        lstAttachment1.add(UTL_TPA_SetupTestData.addAttachment(testAgreement.id, 'Original_Use Defination Template'));
        lstAttachment1.add(UTL_TPA_SetupTestData.addAttachment(testAgreement.id, 'Original TLLA TPA Limited License Agreement'));
        lstAttachment1.add(UTL_TPA_SetupTestData.addAttachment(testAgreement.id, 'AMA_Original TPA- Offerings Notification Limited License Agreement'));
        lstAttachment1.add(UTL_TPA_SetupTestData.addAttachment(testAgreement.id, 'AMA_Original TPA- TLLA Limited License Agreement'));
        lstAttachment1.add(UTL_TPA_SetupTestData.addAttachment(testAgreement.id, 'AMA_Original TPA- Use Defination Limited License Agreement'));
        lstAttachment1.add(UTL_TPA_SetupTestData.addAttachment(testAgreement.id, 'AMA_Original TPA- Use Defination Limited License Agreement.pdf_Completed'));
        insert lstAttachment1;
        
    }

    public static testmethod void testExhibitPageFlow() {
        TPA_Settings__c objTpaSett = UTL_TPA_SetupTestData.createTPASettingsDataBasedOnOrganization();
        objTpaSett.TPA_BCC_Emails__c = 'testbcc@test.com';
        update objTpaSett;
        
        UTL_TPA_SetupTestData.createAMASetting();

        Date todayDate = Date.today();
        
        Address__c testAccount1 = UTL_TPA_SetupTestData.getAddress();
        insert testAccount1;
        
        TPA_Request__c testAgreement = UTL_TPA_SetupTestData.gettestAgreement();
        testAgreement.Request_Status__c = 'In Review by IQVIA';
        testAgreement.AMA_USPrescriberData__c = 'Yes';
        testAgreement.Data_Access_Start_Date__c = todayDate;
        testAgreement.Data_Access_End_Date__c = todayDate.addDays(2);
        testAgreement.Requires_Manual_Review__c = false;
        testAgreement.TP_Processor_Email__c = 'a.a@gmail.com';
        testAgreement.TP_Processor_Name__c = 'Test TP Processor';
        testAgreement.Vendor_Contact_e_mail__c = 'vendor.email@gmail.com';
        testAgreement.TPA_Authorised_Signer__c = 'Yes';
        testAgreement.Client_Address__c = testAccount1.Id;
        testAgreement.Service_Provider_Address__c = testAccount1.Id;
        testAgreement.Authorized_Signer_Email__c = 'email.authorised@gmail.com';
        testAgreement.Vendor_First_Name__c ='FName';
        testAgreement.Vendor_Contact_Last_Name__c ='LName';
        testAgreement.Client_Contact_Territory__c = 'USA';
        testAgreement.Vendor_App_Submitted__c = Date.newInstance(2015, 10, 20);
        testAgreement.Exhibit_Page_Required__c = true;
        testAgreement.Vendor_Language__c = 'English';
        insert testAgreement;
        
        AMA_Agreement_Detail__c amaAgg = UTL_TPA_SetupTestData.getAMAAgreementDetailBlank(testAgreement.id);
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
        
        dsfs__DocuSign_Status__c objDocusignStatus = UTL_TPA_SetupTestData.getDocusignStatus(testAgreement.id);
        
        List<Attachment> lstAttachment1 = new List<Attachment>();
        lstAttachment1.add(UTL_TPA_SetupTestData.addAttachment(testAgreement.id, 'MergedAdHocDocs.pdf'));
        lstAttachment1.add(UTL_TPA_SetupTestData.addAttachment(testAgreement.id, 'Merged TLLA.pdf'));
        insert lstAttachment1;
        
    }

    
    public static testMethod void testBeforeInsertMethod()
    {
        setupData();
        //Test.startTest();
		//TGRH_TPAAttachment objController =  new TGRH_TPAAttachment();
        //TPA_Request__c objAgreement = [SELECT Id, Name, Service_Provider_Address__c FROM TPA_Request__c  LIMIT 1];
        
        List<Attachment> lstAttachment = [SELECT Id, Name, ParentId From Attachment where name like '%TLLA TPA Limited License Agreement%'];
        update lstAttachment;
                delete lstAttachment;
        //String agrId = objAgreement.id;
        //Test.stopTest();
    }

    public static testMethod void testAMAMethods() {
        setupData1();
        TGRH_TPAAttachment objController =  new TGRH_TPAAttachment();
        objController.mails = new List<Messaging.SingleEmailMessage>();
        AMA_Agreement_Detail__c objAmaAgreement = [SELECT Id, Invoice_Contact_Email__c, TPA_Request__r.ClientContact__r.email, TPA_Request__r.Assigned_TP_Processor__c, TPA_Request__r.TPA_Assigned_TP_Processor__r.Initials__c, TPA_Request__r.Client_TPA_Representative_Email__c, TPA_Request__r.TPA_Assigned_TP_Processor__r.Is_Active__c, TPA_Request__r.Co_Assigned_Global_TP_Processor__c, TPA_Request__r.Co_Assigned_Global_TP_Processor__r.Is_Active__c,  TPA_Request__r.Co_Assigned_Global_TP_Processor__r.Initials__c FROM AMA_Agreement_Detail__c];
        TPA_Request__c tpaRequest = [Select id, Owner.Type, Owner.Email, Name, TPA_Assigned_TP_Processor__c, TPA_Assigned_TP_Processor__r.Initials__c, TPA_Assigned_TP_Processor__r.Is_Active__c, Co_Assigned_Global_TP_Processor__c, Co_Assigned_Global_TP_Processor__r.Is_Active__c,  Co_Assigned_Global_TP_Processor__r.Initials__c, Client_Address__r.TPAOtherEmailIds__c from TPA_Request__c where Id =: objAmaAgreement.TPA_Request__c];
        
        
        List<String> toAddress = new List<String>();
        toAddress.add('test@gmail.com');
        Test.startTest();
            objController.addAMAFeeInvoicedConfirmationMail(objAmaAgreement, toAddress, tpaRequest);
            objController.addAMAFeeInvoicedBeforeSignConfirmationMail(objAmaAgreement, toAddress, tpaRequest);
        TPA_Request__c objAgreement = [SELECT Id, Name, Request_Status__c FROM TPA_Request__c where Request_Status__c = 'Awaiting Vendor Submission' LIMIT 1];
        objAgreement.Request_Status__c = 'In Auto Approval Process';
        objAgreement.Data_Access_Start_Date__c = date.today();
        update objAgreement;
        List<Attachment> lstAttachment1 = new List<Attachment>();
        lstAttachment1.add(UTL_TPA_SetupTestData.addAttachment(objAgreement.id, 'Original TLLA TPA Limited License Agreement'));
            lstAttachment1.add(UTL_TPA_SetupTestData.addAttachment(objAgreement.id, 'AMA_Foreign License TPA Limited License Agreement Regenerated'));
            //insert   lstAttachment1;
        Attachment objAttach = UTL_TPA_SetupTestData.addAttachment(objAgreement.id, 'Original TLLA TPA, Signature Request for');
        lstAttachment1.add(objAttach);
        insert lstAttachment1;
        //insert objAttach;
        Test.stopTest();
    }
    
    public static testMethod void testMethodForHelpful() {
        TPA_Settings__c objTpaSett = UTL_TPA_SetupTestData.createTPASettingsDataBasedOnOrganization();
        objTpaSett.TPA_BCC_Emails__c = 'testbcc@test.com';
        update objTpaSett;
        
        UTL_TPA_SetupTestData.createAMASetting();

        Date todayDate = Date.today();
        
        Account testAccount2 = new Account( name = 'TPA Test Account',
                                          BillingCountry = 'India',
                                          BillingState = 'Delhi',
                                          BillingCity = 'Test',
                                          BillingStreet = 'Test',
                                          BillingPostalCode = '123',CustomerSegment__c = 'GOVERNMENT',Sub_Industry__c = 'STATE' );
        insert testAccount2;
        List<Address__c> acclst = new List<Address__c>();
        Address__c testAccount1 = UTL_TPA_SetupTestData.getAddress();
        acclst.add(testAccount1);
        insert acclst;
        Contact  con = new Contact(FirstName = 'TestFirstName', LastName = 'Test Contact', Email = 'sunny.bansal@metacube.com', AccountId = testAccount2.id);
        
        insert con;
        
        List<TPA_Request__c> lstAgreement = new List<TPA_Request__c>();

        TPA_Request__c testAgreement2 = UTL_TPA_SetupTestData.gettestAgreement();
        testAgreement2.AMA_USPrescriberData__c = 'Yes';
        testAgreement2.Data_Access_Start_Date__c = todayDate;
        testAgreement2.Data_Access_End_Date__c = todayDate.addDays(2);
        testAgreement2.Requires_Manual_Review__c = false;
        testAgreement2.TP_Processor_Email__c = 'a.a@gmail.com';
        testAgreement2.TP_Processor_Name__c = 'Test TP Processor';
        testAgreement2.Vendor_Contact_e_mail__c = 'vendor.email@gmail.com';
        testAgreement2.TPA_Authorised_Signer__c = 'Yes';
        testAgreement2.Client_Address__c = testAccount1.Id;
        testAgreement2.Service_Provider_Address__c = testAccount1.Id;
        testAgreement2.ClientContact__c = con.Id;
        testAgreement2.Authorized_Signer_Email__c = 'email.authorised@gmail.com';
        testAgreement2.Vendor_First_Name__c ='FName';
        testAgreement2.Vendor_Contact_Last_Name__c ='LName';
        testAgreement2.Client_Contact_Territory__c = 'USA';
        testAgreement2.Vendor_App_Submitted__c = Date.newInstance(2015, 10, 20);
        testAgreement2.Request_Status__c = 'In Auto Approval Process';
        testAgreement2.is_Addendum_Attachment_Required__c = true;
        lstAgreement.add(testAgreement2);
        insert lstAgreement;
        TPA_Contact__c tpacontact =  new TPA_Contact__c(Name = 'test contact', TPA_Request__c = testAgreement2.Id, Type__c = 'Additional Client Contact', Email__c = 'test@gmail.com');
        insert tpacontact;
        Test.startTest();

        List<Attachment> lstAttachment1 = new List<Attachment>();
        
        lstAttachment1.add(UTL_TPA_SetupTestData.addAttachment(testAgreement2.id, 'Original_Use Defination Template'));
        lstAttachment1.add(UTL_TPA_SetupTestData.addAttachment(testAgreement2.id, 'Original TLLA TPA Limited License Agreement'));
        lstAttachment1.add(UTL_TPA_SetupTestData.addAttachment(testAgreement2.id, Label.TPSA_Client_Template_Name));
        lstAttachment1.add(UTL_TPA_SetupTestData.addAttachment(testAgreement2.id, 'Addendum Notification.pdf'));
        lstAttachment1.add(UTL_TPA_SetupTestData.addAttachment(testAgreement2.id, 'TPA Helpful Hints Addendum.pdf'));
        
        insert lstAttachment1;
        Test.stopTest();
    }

    public static testMethod void testBeforeInsertMethod1()
    {
            TGRH_TPAAttachment objController =  new TGRH_TPAAttachment();
         Test.startTest();

 Address__c testAccount1 = UTL_TPA_SetupTestData.getAddress();
        testAccount1.Name = 'Test Acc1';
        testAccount1.Vendor_Registration_Number__c = 8787;
        insert testAccount1;
        Address__c testAddress1 = UTL_TPA_SetupTestData.getAddress();
Date todayDate = Date.today();
            TPA_Request__c testAgreement2 = UTL_TPA_SetupTestData.gettestAgreement();
        testAgreement2.AMA_USPrescriberData__c = 'Yes';
        testAgreement2.Data_Access_Start_Date__c = todayDate;
        testAgreement2.Data_Access_End_Date__c = todayDate.addDays(2);
        testAgreement2.Requires_Manual_Review__c = false;
        testAgreement2.TP_Processor_Email__c = 'a.a@gmail.com';
        testAgreement2.TP_Processor_Name__c = 'Test TP Processor';
        testAgreement2.Vendor_Contact_e_mail__c = 'vendor.email@gmail.com';
        testAgreement2.TPA_Authorised_Signer__c = 'Yes';
        testAgreement2.Client_Address__c = testAddress1.Id;
        testAgreement2.Service_Provider_Address__c = testAddress1.Id;
        testAgreement2.Authorized_Signer_Email__c = 'email.authorised@gmail.com';
        testAgreement2.Vendor_First_Name__c ='FName';
        testAgreement2.Vendor_Contact_Last_Name__c ='LName';
        testAgreement2.Client_Contact_Territory__c = 'USA';
        testAgreement2.Vendor_App_Submitted__c = Date.newInstance(2015, 10, 20);
        testAgreement2.Request_Status__c = 'In Auto Approval Process';
        insert testAgreement2;

 Attachment objAttach = UTL_TPA_SetupTestData.addAttachmentToParent(testAgreement2.Id, 'Original_Use DefinationRegenerated Template');

             List<Attachment> oldList = new List<Attachment>();
             List<Attachment> newList = new List<Attachment>();
             Map<Id,Attachment> oMap = new Map<Id,Attachment>();
             Map<Id,Attachment> nMap = new Map<Id,Attachment>();
             oldList.add(objAttach);
             oMap.put(objAttach.id,objAttach);
             objAttach.name = 'Original_Use DefinationRegenerated Template';
             newList.add(objAttach);
        	 Attachment newObj = new Attachment();
        	 newObj.Id = objAttach.id;
        	 newObj.Name = 'Test11';
             nMap.put(objAttach.id,newObj);
             objController.OnAfterUpdate(oldList ,newList ,oMap,nMap);
        	 TGRH_TPAAttachment.listTemplates = null;
             objController.OnBeforeUpdate(newList ,newList ,new map<id,Attachment>(), oMap);
                          objController.OnAfterDelete(newList, nMap);

        Test.stopTest();
    }
}
