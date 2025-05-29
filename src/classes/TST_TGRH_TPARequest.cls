@isTest(seeAllData=false)
public class TST_TGRH_TPARequest {  
    
    private static TPA_Request__c tpaRequest;
    private static User Usr;
    private static TPA_Request__c TestAgreement;
    public static Attachment testAttachment;
    public static Attachment testAttachmentCompleted;
    private static Account testVendorAccount;
    private static TPA_Commercial_Review__c tpaComRev;
    
    /**
* Setup test data required to run tests in a data independent fashion
*/
    @TestSetup
    static void setupTestData() {
        UTL_TPA_SetupTestData.createCrossWalkData();
        UTL_TPA.Inserted_To_AMA_Data = False;
        SRV_TPA_TPARequest.isDirectToClientExeMode = true;
        UTL_TPA.notificationsTriggerExecuted=false;
        UTL_TPA.modifyRequest = true;
        UTL_TPA.batchEmailAddresses = 'test@test.com';
        
        Address__c testAccount1 = UTL_TPA_SetupTestData.getAccount();
        testAccount1.Name = 'Test Account 1';
        insert testAccount1;
        
        Address__c testAddress = UTL_TPA_SetupTestData.getAddress();
        insert testAddress;
        Address__c testParentAddress = UTL_TPA_SetupTestData.getTestAccountByNameAndRegNum('test Parent vendor',1102);
        Address__c testAccount = UTL_TPA_SetupTestData.getTestAccountByNameAndRegNum('test vendor',1201);
        testAccount.Parent_Vendor_Name__c = testParentAddress.id;
        update testAccount;
        
        Contact testContact1 = UTL_TPA_SetupTestData.getContact();
        testContact1.AccountId = testAccount1.Account__c;
        testContact1.LastName = 'Test Contact 1';
        insert testContact1;

          
        List<Contact_Address_Crosswalk__c> crosswalkObjList = new List<Contact_Address_Crosswalk__c>();
        Contact_Address_Crosswalk__c crosswalkObj1 = UTL_TPA_SetupTestData.getjunctionRecord(testContact1.Id, testAccount1.Id);
        crosswalkObjList.add(crosswalkObj1);
        insert crosswalkObjList;
        
        Datetime currentDate = System.now();
        
        
        date strtDate1 = date.today();
        List<TPA_Request__c> listtpa = new List<TPA_Request__c>();
        TestAgreement = UTL_TPA_SetupTestData.gettestAgreement();
        TestAgreement.Is_TPA_Signed_Contract_Attached__c = true;
        TestAgreement.TP_Processor_Email__c = 'ab@gmail.com';
        TestAgreement.Is_MailSend_For_DataAccess__c = false;
        TestAgreement.Service_Provider_Address__c = TestAccount.id;
        TestAgreement.Client_Address__c = TestAccount.id;
        TestAgreement.TPA_Authorised_Signer__c = 'No';
        TestAgreement.Authorized_Signer_Email__c = 'test1@mail.com';
        TestAgreement.Vendor_Contact_e_mail__c = 'test2@mail.com';
        TestAgreement.Request_Status__c = 'Awaiting Vendor Signature';
        TestAgreement.TPA_Processor_Account_Address__c = testAccount.id;
        TestAgreement.Data_Access_Start_Date__c = strtDate1;
        TestAgreement.Data_Access_End_Date__c = strtDate1.addDays(5);
        TestAgreement.Vendor_First_Name__c = 'VFName';
        TestAgreement.Vendor_Contact_Last_Name__c = 'VLName';
        TestAgreement.Vendor_Contact_Title__c = 'VTitle';
        TestAgreement.Vendor_Contact_e_mail__c = 'VFName@metacube.com';
        TestAgreement.TPA_Processor_Account_Address__c = testAccount.id;
        TestAgreement.Sent_for_Signature__c = strtDate1.addDays(2);
        TestAgreement.Prevent_Cancellation__c = true;
        TestAgreement.Employee_Accessing_Data_Location__c = 'Japan';
        TestAgreement.client_language__c = 'English';
        TestAgreement.Vendor_Language__c = 'English';
        TestAgreement.Pending_Acknowledgements__c = 'Pending Commercial Review Acknowledgements;';
        listtpa.add(TestAgreement);
        
        TPA_Request__c TestAgreement2 = UTL_TPA_SetupTestData.gettestAgreement();
        TestAgreement2.Is_TPA_Signed_Contract_Attached__c = true;
        TestAgreement2.TP_Processor_Email__c = 'ab@gmail.com';
        TestAgreement2.Is_MailSend_For_DataAccess__c = false;
        TestAgreement2.Service_Provider_Address__c = TestAccount.id;
        TestAgreement2.Client_Address__c = TestAccount.id;
        TestAgreement2.TPA_Authorised_Signer__c = 'Yes';
        TestAgreement2.Authorized_Signer_Email__c = 'test1@mail.com';
        TestAgreement2.Vendor_Contact_e_mail__c = 'test2@mail.com';
        TestAgreement2.Request_Status__c = 'Awaiting Vendor Signature';
        TestAgreement2.TPA_Processor_Account_Address__c = testAccount.id;
        TestAgreement2.Data_Access_Start_Date__c = strtDate1;
        TestAgreement2.Data_Access_End_Date__c = strtDate1.addDays(5);
        TestAgreement2.Vendor_First_Name__c = 'VFName';
        TestAgreement2.Vendor_Contact_Last_Name__c = 'VLName';
        TestAgreement2.Vendor_Contact_Title__c = 'VTitle';
        TestAgreement2.Vendor_Contact_e_mail__c = 'VFName@metacube.com';
        TestAgreement2.TPA_Processor_Account_Address__c = testAccount.id;
        TestAgreement2.Sent_for_Signature__c = strtDate1.addDays(2);
        TestAgreement2.Prevent_Cancellation__c = true;
        TestAgreement2.Employee_Accessing_Data_Location__c = 'Japan';
        TestAgreement2.client_language__c = 'English';
        TestAgreement2.Vendor_Language__c = 'English';
        listtpa.add(TestAgreement2);
        insert listtpa;
        
        List<TPA_Commercial_Review__c> lstComrev = new List<TPA_Commercial_Review__c>();
        tpaComRev = new TPA_Commercial_Review__c();
        tpaComRev.Status__c = 'Combination Approved';
        tpaComRev.TPA_Request__c = listtpa[0].id;
        tpaComRev.Manual_Review_Reason__c = 'Nooff';
		lstComRev.add(tpaComRev);
        insert lstComrev;
        
        getAMAChildRecord(TestAgreement.id);
        
        Document document = UTL_TPA_SetupTestData.getTestDocument('Public Folder');
        
        List<TPA_Contact__c> lsttpaContact = new List<TPA_Contact__c>();
        TPA_Contact__c tpaContact = new TPA_Contact__c(Type__c ='Additional Client Contact',
                                                        Email__c = 'test@gmail.com',
                                                        TPA_Request__c = TestAgreement.Id);
        lsttpaContact.add(tpaContact);
        TPA_Contact__c tpaContact2 = new TPA_Contact__c(Type__c ='Additional Vendor Contact',
                                                        Email__c = 'test2@gmail.com',
                                                        TPA_Request__c = TestAgreement.Id);
        lsttpaContact.add(tpaContact2);
        insert lsttpaContact;
        
        

        TPA_AMA_Settings__c amaObj = UTL_TPA_SetupTestData.createAMASetting();
        amaObj.Mail_Addresses_for_signed_AMA_Agreement__c = 'supriya.johari@metacube.com';
        amaObj.Vendor_Canceled_AMA_TPA_EXP_12_31__c = currentDate;
        update amaObj; 
        
        UTL_TPA_SetupTestData.createMultilingualTemplateSettingData();
        
        TPA_Settings__c tpaSetting = UTL_TPA_SetupTestData.getTPASettingsData();
        tpaSetting.SetupOwnerId = UserInfo.getOrganizationId();
        tpaSetting.TPA_Admin_Email_Address__c = 'test111@metacube.com';
        tpaSetting.TPA_BCC_Emails__c = 'test111@metacube.com';
        insert tpaSetting;
        
        List<Document>  docList = new List<Document>();
        Document doc = new Document(name = 'Compliance Program',FolderId = document.FolderId);
        docList.add(doc);
        Document doc2 = new Document(name = 'STANDARD TERMS AND CONDITIONS',FolderId = document.FolderId);
        docList.add(doc2);
        Document doc3 = new Document(name = 'Restricted Data Security Requirement',FolderId = document.FolderId);
        docList.add(doc3);
        Document doc4 = new Document(name = 'Compliance Program Japanese',FolderId = document.FolderId);
        docList.add(doc4);
        Document doc5 = new Document(name = 'STANDARD TERMS AND CONDITIONS JAPANESE',FolderId = document.FolderId);
        docList.add(doc5);
          insert docList;
        
        TestAgreement = [Select id,
                         Name,Vendor_Contact_e_mail__c,
                         createddate,ClientContact__c,TPA_Authorised_Signer__c,Authorized_Signer_Email__c, Client_Address__c, Client_Address__r.TPAOtherEmailIds__c,
                         TP_Processor_Email__c,Service_Provider_Address__c, Is_Restricted_Data_Asset__c From TPA_Request__c where  Authorized_Signer_Email__c = 'test1@mail.com' LIMIT 1];
        
        List<TPA_RequestDocument__c> lstRequestDocuments = new List<TPA_RequestDocument__c>();
        TPA_RequestDocument__c requestdocument = new TPA_RequestDocument__c(Name = 'test',Document_Id__c = doc.id,TPA_Request_Id__c = TestAgreement.id);
        lstRequestDocuments.add(requestdocument);
        TPA_RequestDocument__c requestdocument2 = new TPA_RequestDocument__c(Name = 'test',Document_Id__c = doc2.id,TPA_Request_Id__c = TestAgreement.id);
        lstRequestDocuments.add(requestdocument2);
        TPA_RequestDocument__c requestdocument3 = new TPA_RequestDocument__c(Name = 'test',Document_Id__c = doc4.id,TPA_Request_Id__c = TestAgreement.id);
        lstRequestDocuments.add(requestdocument3);
        TPA_RequestDocument__c requestdocument4 = new TPA_RequestDocument__c(Name = 'test',Document_Id__c = doc5.id,TPA_Request_Id__c = TestAgreement.id);
        lstRequestDocuments.add(requestdocument4);
        insert lstRequestDocuments;
        
        List<Attachment> attchlist = new List<Attachment>();
        attchlist.add(UTL_TPA_SetupTestData.addAttachment(TestAgreement.id,'Original TLLA TPA Limited License Agreement'));
        attchlist.add(UTL_TPA_SetupTestData.addAttachment(TestAgreement.id,'Original TLLA TPA Limited License Agreement.pdf_Completed'));
        attchlist.add(UTL_TPA_SetupTestData.addAttachment(TestAgreement.id,'AMA_Service Bureau II_'+TestAgreement.name+'_Test AMA Accou_Test AMA A_2016.pdf'));
        attchlist.add(UTL_TPA_SetupTestData.addAttachment(TestAgreement.id,'AMA_Service Bureau II_'+TestAgreement.name+'_Test AMA Accou_Test AMA A_2016.pdf_Completed'));
        attchlist.add(UTL_TPA_SetupTestData.addAttachment(TestAgreement.id,TestAgreement.name+'_TPA Helpful Hints Addendum_2023.pdf'));
        attchlist.add(UTL_TPA_SetupTestData.addAttachment(TestAgreement.id,TestAgreement.name+'_TPA Helpful Hints Addendum_2023.pdf_Completed'));
        attchlist.add(UTL_TPA_SetupTestData.addAttachment(TestAgreement.id,TestAgreement.name+ '_Test AMA Accou_TLLA_Test AMA A_2016.pdf_Completed'));
        attchlist.add(UTL_TPA_SetupTestData.addAttachment(TestAgreement.id,'original Use Definition Template.pdf'));
        attchlist.add(UTL_TPA_SetupTestData.addAttachment(TestAgreement.id,'Offerings Notification Vendor.pdf'));
        attchlist.add(UTL_TPA_SetupTestData.addAttachment(TestAgreement.id,'test Offerings Notification.pdf'));
        attchlist.add(UTL_TPA_SetupTestData.addAttachment(TestAgreement.id,'Offerings Notification Client.pdf'));
        attchlist.add(UTL_TPA_SetupTestData.addAttachment(TestAgreement.id,'Addendum Notification.pdf'));
        attchlist.add(UTL_TPA_SetupTestData.addAttachment(TestAgreement.id,'Compliance Program.pdf'));
        attchlist.add(UTL_TPA_SetupTestData.addAttachment(TestAgreement.id,'STANDARD TERMS AND CONDITIONS.pdf'));
        attchlist.add(UTL_TPA_SetupTestData.addAttachment(TestAgreement.id,'Compliance Program Japanese.pdf'));
        attchlist.add(UTL_TPA_SetupTestData.addAttachment(TestAgreement.id,'STANDARD TERMS AND CONDITIONS Japanese.pdf'));
        
        insert attchlist;
        
        TPA_Agreement_Additional_Field__c aggAdditionalFieldObj1 = UTL_TPA_SetupTestData.getTPAAgreementAdditionalFieldObj(TestAgreement);
        aggAdditionalFieldObj1.Vendor_Specific_Notification_Response__c = 'Acknowledge Request';
        update aggAdditionalFieldObj1;
    }
   
    public static AMA_Agreement_Detail__c getAMAChildRecord(Id ReqId){
        AMA_Agreement_Detail__c amaAgg = UTL_TPA_SetupTestData.getAMAAgreementDetailBlank(ReqId);
        amaAgg.Contract_Type__c = 'Service Bureau II';
        amaAgg.Agreement_Start_Date__c = Date.newInstance(2019 , 10 ,20);
        amaAgg.Agreement_End_Date__c = Date.newInstance(2017 , 12 ,31);
        amaAgg.AMA_Howlong_SP_has_Data_Access__c = '90 days or less';
        amaAgg.FrequencyOfDeliveryToServiceProvider__c = 'Quarterly';
        amaAgg.AMA_TypeOfPrescriberLevelData__c='Birth Year;Gender Code';
        amaAgg.AMA_Services_Provided__c='Telemarketing;Labeling';
        amaAgg.Ex_Client__c = 'test old Client';
        amaAgg.Ex_DBL__c='DMD';
        amaAgg.DBL__c='IQVIA (IQVIA)';
        amaAgg.Ex_Client_Services_On_Behalf_Of__c='old Client Services';
        amaAgg.Ex_Contract_Type__c= 'old contract type';
        amaAgg.Ex_Contract_End_Date__c=Date.newInstance(2019, 12, 31);
        amaAgg.Ex_Contract_List_Type__c='old list';
        amaAgg.Ex_Max_Fee_Reached__c=True;
        amaAgg.Ex_Offshore_Approval__c=True;
        amaAgg.Ex_Offshore_Location__c='old location';
        amaAgg.Ex_Special_Terms_Conditions__c='old Terms Conditions';
        amaAgg.AMA_Amount_to_be_Credited_Billed__c = 2000;
        amaAgg.Send_DBL_Notification_To_AMA__c = true;
        amaAgg.Is_AMA_License_Required__c = true;
        amaAgg.AMA_Manual_Review__c = false;
        amaAgg.Next_Year_Fees__c = 21000;
        amaAgg.Current_Year_Fees__c = 21000;
        amaAgg.Vendor_Employee_Accessed_Data_in_country__c = 'USA;US';
        insert amaAgg;        
        return amaAgg;
        
    }
    
    
    public static testMethod void setDataToSendDataAuthorizationMail() {
        Test.startTest();
        TST_TGRH_TPARequest instance = new TST_TGRH_TPARequest();
        
        Address__c acc = UTL_TPA_SetupTestData.getTestAccountByNameAndRegNum('test vendor',1201);
        
        List<TPA_Request__c> ListAgg = new List<TPA_Request__c>();
        
        TestAgreement = [Select id,
                         Name,Vendor_Contact_e_mail__c,
                         createddate,ClientContact__c,Client_Language__c,TPA_Authorised_Signer__c,Authorized_Signer_Email__c, Client_Address__c, Client_Address__r.TPAOtherEmailIds__c,
                         TP_Processor_Email__c,Service_Provider_Address__c, Is_Restricted_Data_Asset__c From TPA_Request__c where  Authorized_Signer_Email__c = 'test1@mail.com' LIMIT 1];
        //TestAgreement.
        system.debug('TestAgreement 2: '+TestAgreement);
        ListAgg.add(TestAgreement);
        
        UTL_TPA.notificationsTriggerExecuted = true;
        
        TGRH_TPARequest controller = new TGRH_TPARequest();
        
        controller.sendAgreementsForDataAuthorizationMail(TestAgreement);
        controller.sendMailToDblForExecutedAmaAgreement(TestAgreement.id); 
        TGRH_TPARequest.sendMailToTPAAdmintoExtractAMADocumentFromSignedOnPaperDoc(TestAgreement.id);
        Test.stopTest();     
        UTL_TPA.notificationsTriggerExecuted = false;

    }
    
   public static testMethod void setDataToSendDataAuthorizationMail7() {
       List<TPA_Request__c> ObjTpaList = [select id from TPA_Request__c];
        TGRH_TPARequest controller = new TGRH_TPARequest();
        controller.onBeforeDelete(ObjTpaList);
    }
    
    public static testMethod void setDataToSendDataAuthorizationMail1() {
        Test.startTest();
        TST_TGRH_TPARequest instance = new TST_TGRH_TPARequest();
        
        UTL_TPA.notificationsTriggerExecuted=true;
        UTL_TPA.DBL_Notification_Mail_Sent = false;
        UTL_TPA.dblContractContactEmail = 'DBL@metacube.com';
        
        List<TPA_Request__c> ObjTpaList = [select id from TPA_Request__c];
        ObjTpaList[0].Is_CPC_Renewal_Notice_Sent__c = true;
        ObjTpaList[0].Request_Status__c = 'In Effect';
        ObjTpaList[0].CPC_Renewal_Notice_Sent_Last_Date__c = null;
        ObjTpaList[0].Is_CPC_Expiration_Notice_Sent__c = true;
        ObjTpaList[0].Is_CPC_Post_Expiration_Notice_Sent__c = true;
        update ObjTpaList[0];
        
        TGRH_TPARequest controller = new TGRH_TPARequest();
        UTL_TPA_SetupTestData.getDocusignStatus(ObjTpaList[0].id);
        TGRH_TPARequest.voidEnvelopeCall(new set<id>{ObjTpaList[0].id}, 'Resubmission Void Reason');
        
        Test.stopTest();
    }
    public static testMethod void setDataToSendDataAuthorizationMail2() {
        Test.startTest();
        TST_TGRH_TPARequest instance = new TST_TGRH_TPARequest();
        
        UTL_TPA.notificationsTriggerExecuted=true;
        UTL_TPA.modifyRequest = true;
        TPA_Request__c tpa= new TPA_Request__c();
        tpa.Is_TPA_Signed_Contract_Attached__c = true;
        tpa.TP_Processor_Email__c = 'ab@gmail.com';
        tpa.Is_MailSend_For_DataAccess__c = false;
        tpa.TPA_Authorised_Signer__c = 'Yes';
        tpa.Authorized_Signer_Email__c = 'test1@mail.com';
        tpa.Vendor_Contact_e_mail__c = 'test2@mail.com';
        tpa.Request_Status__c = 'Cancelled';
        tpa.Vendor_First_Name__c = 'VFName';
        tpa.Vendor_Contact_Last_Name__c = 'VLName';
        tpa.Vendor_Contact_Title__c = 'VTitle';
        tpa.Vendor_Contact_e_mail__c = 'VFName@metacube.com';
        tpa.Prevent_Cancellation__c = true;
        tpa.Employee_Accessing_Data_Location__c = 'Japan';
        tpa.client_language__c = 'English';
        tpa.Vendor_Language__c = 'English';
        insert tpa;
        Date datere = Date.today()-10;
        TPA_Agreement_Additional_Field__c aggAdditionalFieldObj1 = UTL_TPA_SetupTestData.getTPAAgreementAdditionalFieldObj(tpa);
        aggAdditionalFieldObj1.Early_Contract_Expiry_Date__c = datere;
        update aggAdditionalFieldObj1;
        update tpa;
        List<TPA_Request__c> ObjTpaList = [select id from TPA_Request__c];
        ObjTpaList[0].Request_Status__c = tpa.Id;
        ObjTpaList[0].Is_CPC_Renewal_Notice_Sent__c = true;
        ObjTpaList[0].Request_Status__c = 'Cancelled';
        ObjTpaList[0].CPC_Renewal_Notice_Sent_Last_Date__c = null;
        ObjTpaList[0].Is_CPC_Expiration_Notice_Sent__c = true;
        ObjTpaList[0].Is_CPC_Post_Expiration_Notice_Sent__c = true;
        update ObjTpaList[0];
        Test.stopTest();
    }
    
    public static testMethod void setDataToSendDataAuthorizationMail3() {
        Test.startTest();
        Address__c testAccount1 = UTL_TPA_SetupTestData.getTestAccountByNameAndRegNum('test vendor1',1207);
        
        //UTL_TPA.notificationsTriggerExecuted=true;
        UTL_TPA.modifyRequest = true;
        List<TPA_Request__c> ObjTpaList = [select id from TPA_Request__c];
        ObjTpaList[0].Request_Status__c = 'Signature Under Validation';
        ObjTpaList[0].LastAction__c = 'Request Edited By Client';
        update ObjTpaList[0];
        
        
        ObjTpaList[0].Is_CPC_Renewal_Notice_Sent__c = true;
        ObjTpaList[0].Request_Status__c = 'in effect';
        ObjTpaList[0].CPC_Renewal_Notice_Sent_Last_Date__c = null;
        ObjTpaList[0].Is_CPC_Expiration_Notice_Sent__c = true;
        ObjTpaList[0].Is_CPC_Post_Expiration_Notice_Sent__c = true;
        ObjTpaList[0].Is_CPC_Post_Expiration_Notice_Sent__c = true;
        ObjTpaList[0].Service_Provider_Address__c = testAccount1.id;
        update ObjTpaList[0];
        
        
        Test.stopTest();
    }
    
    public static testMethod void setDataToSendDataAuthorizationMail4() {
        Test.startTest();
        TST_TGRH_TPARequest instance = new TST_TGRH_TPARequest();
        
        UTL_TPA.notificationsTriggerExecuted=true;
        UTL_TPA.modifyRequest = true;
        List<TPA_Request__c> ObjTpaList = [select id from TPA_Request__c];
        
        ObjTpaList[0].Request_Status__c = 'Awaiting Vendor Submission';
        ObjTpaList[0].Prevent_Cancellation__c = false;
        update ObjTpaList[0];
        
        UTL_TPA.modifyRequestNonSysAdminUser = true;
        ObjTpaList[0].Is_CPC_Renewal_Notice_Sent__c = true;
        ObjTpaList[0].Request_Status__c = 'In Review By IQVIA';
        ObjTpaList[0].CPC_Renewal_Notice_Sent_Last_Date__c = null;
        ObjTpaList[0].Is_CPC_Expiration_Notice_Sent__c = true;
        ObjTpaList[0].Is_CPC_Post_Expiration_Notice_Sent__c = true;
        ObjTpaList[0].Prevent_Cancellation__c = false;
        update ObjTpaList[0];
        
        ObjTpaList[0].Is_Contract_Generated__c = true;
        ObjTpaList[0].Prevent_Cancellation__c = false;
        ObjTpaList[0].Request_Status__c = 'Awaiting Vendor Signature';
        update ObjTpaList[0];
        
        Test.stopTest();
    }
    public static testMethod void setDataToSendDataAuthorizationMail5() {
        
        List<TPA_Request__c> ObjTpaList = [select id from TPA_Request__c];
        ObjTpaList[0].Request_Status__c = 'Expired';
        Test.startTest();
        update ObjTpaList[0];
        Test.stopTest();
    }
    
    public static testMethod void setDataToSendDataAuthorizationMail6() {
        Test.startTest();
        List<TPA_Request__c> ObjTpaList = [select id from TPA_Request__c];
        ObjTpaList[0].Request_Status__c = 'TPA Approved Awaiting AMA Approval';
        update ObjTpaList[0];
        Test.stopTest();
    }
  	public static testMethod void setDataToSendDataAuthorizationMail8() {
        Test.startTest();
        List<TPA_Request__c> ObjTpaList = [select id from TPA_Request__c];
        ObjTpaList[0].Request_Status__c = 'Vendor Canceled ?17 AMA-TPA Exp-12/31/16';
        update ObjTpaList[0];
        Test.stopTest();
    }
    public static testMethod void testStatusToCoveredByMOU() {
        Test.startTest();
        List<TPA_Request__c> ObjTpaList = [select id from TPA_Request__c];
        ObjTpaList[0].Request_Status__c = 'Covered By MOU';
        update ObjTpaList[0];
        Test.stopTest();
    }
	
    public static testMethod void testStatusFromFinalStatusToCoveredByMOU() {
        Test.startTest();
        List<TPA_Request__c> ObjTpaList = [select id from TPA_Request__c];
        ObjTpaList[0].Request_Status__c = 'In Effect';
        update ObjTpaList[0];
        ObjTpaList = [select id from TPA_Request__c];
        ObjTpaList[0].Request_Status__c = 'Covered By MOU';
        try{
        	update ObjTpaList[0];
        }
 		catch (DMLException e) {
		}

        Test.stopTest();
    }
    
    public static testMethod void testStatusCoveredByMOUToOther() {
        Test.startTest();
        List<TPA_Request__c> ObjTpaList = [select id from TPA_Request__c];
        ObjTpaList[0].Request_Status__c = 'Covered By MOU';
        update ObjTpaList[0];
        ObjTpaList = [select id from TPA_Request__c];
        ObjTpaList[0].Request_Status__c = 'In Effect';
        try{
        	update ObjTpaList[0];
        }
 		catch (DMLException e) {
		}
        Test.stopTest();
    }
	public static testMethod void testStatusInReviewToCancelled() {
        Test.startTest();
        List<TPA_Request__c> ObjTpaList = [select id,Request_Status__c from TPA_Request__c];
        ObjTpaList[0].Request_Status__c = 'In Review by IQVIA';
        update ObjTpaList[0];
        ObjTpaList = [select id,Request_Status__c from TPA_Request__c];
        ObjTpaList[0].Request_Status__c = 'Cancelled';
        try{
        	update ObjTpaList[0];
        }
 		catch (DMLException e) {
		}
        Test.stopTest();
    }
    public static testMethod void testStatusInReviewToCancelled2() {
        Test.startTest();
        TGRH_TPARequest.runAllCompletedBlock = true;
        List<TPA_Request__c> ObjTpaList = [select id,Request_Status__c from TPA_Request__c];
        ObjTpaList[0].Request_Status__c = 'Awaiting Vendor Submission';
        update ObjTpaList[0];
        TPA_Request__c ObjTpa = [select id,Request_Status__c from TPA_Request__c where id = :ObjTpaList[0].id];
        ObjTpa.Request_Status__c = 'In Review by IQVIA';
        try{
        	update ObjTpa;
        }
 		catch (DMLException e) {
		}
        Test.stopTest();
    }
    public static testMethod void testTPAAgreementAdditionalFieldUpdate(){
        Test.startTest();
        TPA_Request__c Testrequest = [select id from TPA_Request__c limit 1];
        TestRequest.Request_Status__c = 'Cancelled';
        update TestRequest;
        
        TPA_Agreement_Additional_Field__c aggAdditionalFieldObj1 = UTL_TPA_SetupTestData.getTPAAgreementAdditionalFieldObj(TestRequest);
        aggAdditionalFieldObj1.Early_Contract_Expiry_Date__c = date.today();
        update aggAdditionalFieldObj1;
        
        TPA_Request__c tpa= new TPA_Request__c();
        tpa.Is_TPA_Signed_Contract_Attached__c = true;
        tpa.TP_Processor_Email__c = 'ab@gmail.com';
        tpa.Is_MailSend_For_DataAccess__c = false;
        tpa.TPA_Authorised_Signer__c = 'Yes';
        tpa.Authorized_Signer_Email__c = 'test1@mail.com';
        tpa.Vendor_Contact_e_mail__c = 'test2@mail.com';
        tpa.Request_Status__c = 'In Review by IQVIA';
        tpa.Vendor_First_Name__c = 'VFName';
        tpa.Vendor_Contact_Last_Name__c = 'VLName';
        tpa.Vendor_Contact_Title__c = 'VTitle';
        tpa.Vendor_Contact_e_mail__c = 'VFName@metacube.com';
        tpa.Prevent_Cancellation__c = true;
        tpa.Employee_Accessing_Data_Location__c = 'Japan';
        tpa.client_language__c = 'English';
        tpa.Vendor_Language__c = 'English';
        tpa.Is_Renewed__c = true;
        tpa.In_Effect_Date__c = Date.today();
        tpa.Parent_Request__c = TestRequest.id;
        insert tpa;
        tpa.Request_Status__c = 'Cancelled';
        update tpa;
        TestRequest.Renewed_As__c = tpa.id;
        TestRequest.Is_Renewed__c = true;
        TestRequest.In_Effect_Date__c = Date.Today().addDays(-2);
        update TestRequest;
        Test.stopTest();
    }
    public static testMethod void testUserContainsUSTPAccessSetStatusChange(){
        Test.startTest();
        TGRH_TPARequest.doesUserContainsUSTPAccessSet = true;
        TPA_Request__c testRequest = [select id, Request_Status__c from TPA_Request__c where Request_Status__c <> 'Cancelled' limit 1];
        testRequest.Request_Status__c = 'Cancelled';
        update testRequest;
        Test.stopTest();
    }
    public static testMethod void testUserContainsUSTPAccessSetStatusChange2(){
        Test.startTest();
        TGRH_TPARequest.doesUserContainsUSTPAccessSet = true;
        TPA_Request__c testRequest = [select id, Request_Status__c from TPA_Request__c where Request_Status__c <> 'Signature Under Validation' limit 1];
        testRequest.Request_Status__c = 'Signature Under Validation';
        update testRequest;
        testRequest.Request_Status__c = 'In Effect';
        testRequest.Data_Access_End_Date__c = date.today().addDays(-2); // when Data Access end date is over
        testRequest.Data_Access_Start_Date__c = date.today().addDays(-5);
        update testRequest;
        testRequest.Request_Status__c = 'Expired';
        update testRequest;
        Test.stopTest();
    }
}