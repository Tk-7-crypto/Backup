/*
*@Author  : Neha Bansal
*@Purpose : 1. Test class for SRV_TPA_DocusignEnvelope
*/
@isTest(seeAllData=false)
public class TST_SRV_TPA_DocusignEnvelope {

    @testSetup
    static void setupData() {
        
        UTL_TPA_SetupTestData.createTPASettingsDataBasedOnOrganization();
        UTL_TPA_SetupTestData.createMultilingualTemplateSettingData();
        UTL_TPA_SetupTestData.createCrossWalkData();
        UTL_TPA_SetupTestData.createAMASetting();

        Date todayDate = Date.today();
        Profile testProfile = [SELECT Id FROM Profile WHERE Name LIKE 'System Administrator%' LIMIT 1];

        Address__c testAccount = UTL_TPA_SetupTestData.getAccount();
        testAccount.Name = 'Test Acc';
        testAccount.Vendor_Registration_Number__c = 9999;
        insert testAccount;
        
        Address__c testAddress = UTL_TPA_SetupTestData.getAddress();
        insert testAddress;
        Contact testContact = UTL_TPA_SetupTestData.getContact();
        testContact.AccountId = testAccount.Account__c;
        testContact.LastName = 'Test';
      //testContact.AccountId = testAccount.Id;
        testContact.CurrencyIsoCode = 'USD';
        testContact.email = 'test@test.com';
        insert testContact;

        TPA_Request__c tpaRequest = UTL_TPA_SetupTestData.getTestTPARequest();
        tpaRequest.OwnerId = UserInfo.getUserId();
        tpaRequest.Client_Region__c = 'US';
        tpaRequest.Data_Provided_By__c = 'IMS in lieu of Client';
        tpaRequest.Is_Data_Accessed_Via_IMS_Software__c = 'Yes';
        tpaRequest.AMA_USPrescriberData__c = 'Yes';
        tpaRequest.Does_the_request_require_information_con__c = 'Yes';
        tpaRequest.Service_Provider_Address__c = testAccount.Id;
        tpaRequest.Service_Provider_Address__c = testAddress.Id;
        tpaRequest.Vendor_Company_Name__c = 'Test company';
        tpaRequest.Client_Off_Notification_Ack_Date__c = todayDate;
        tpaRequest.Vendor_Off_Notification_Ack_Date__c = todayDate;
        insert tpaRequest;

        

        List<TPA_Request__c> lstAgreement = new List<TPA_Request__c>();
        TPA_Request__c testAgreement = UTL_TPA_SetupTestData.getTestAgreement();
        testAgreement.Data_Access_Start_Date__c=todayDate;
        testAgreement.Data_Access_End_Date__c=todayDate.addDays(2);
        testAgreement.Requires_Manual_Review__c = false;
        testAgreement.TP_Processor_Email__c = 'a.a@gmail.com';
        testAgreement.TP_Processor_Name__c = 'Test TP Processor';
        testAgreement.Vendor_Contact_e_mail__c = 'vendor.email@gmail.com';
        testAgreement.TPA_Authorised_Signer__c = 'Yes';
        testAgreement.Client_Address__c = testAccount.Id;
        testAgreement.Client_Address__c = testAddress.Id;
        testAgreement.Service_Provider_Address__c = testAccount.Id;
        testAgreement.Service_Provider_Address__c = testAddress.Id;
        testAgreement.Authorized_Signer_Email__c = 'email.authorised@gmail.com';
        testAgreement.Vendor_First_Name__c ='FName';
        testAgreement.Vendor_Contact_Last_Name__c ='LName';
        testAgreement.Request_Status__c = 'Awaiting Vendor Submission';
        insert testAgreement;

        AMA_Agreement_Detail__c amaAgg = UTL_TPA_SetupTestData.getAMAAgreementDetailBlank(testAgreement.Id);
        amaAgg.AMA_Manual_Review__c = false;
        amaAgg.Is_AMA_License_Required__c = true;
        insert amaAgg;

        TPA_RequestDocument__c testTPARequestDocument =  UTL_TPA_SetupTestData.getTPARequestDocument(tpaRequest);

        dsfs__DocuSign_Status__c testDocusignStatus = UTL_TPA_SetupTestData.getNewDocusignStatus();
        testDocusignStatus.TPA_Request__c = testAgreement.Id;
        testDocusignStatus.dsfs__Envelope_Status__c = 'Delivered';
        testDocusignStatus.dsfs__DocuSign_Envelope_ID__c = '86D7009C-8254-4835-B52E-F3A98757AAAE';
        testDocusignStatus.dsfs__Subject__c = ' IMS TPA Program:'+tpaRequest.Name+', Signature Request for TPA Test A TLLA';
        testDocusignStatus.dsfs__Sender__c ='IMS Third Party Access Program';
        testDocusignStatus.dsfs__Sender_Email__c = 'sender.mail@gmail.com';
        insert testDocusignStatus;

        List<Attachment> lstAttachment = new List<Attachment>();
        lstAttachment.add(UTL_TPA_SetupTestData.addAttachment(testAgreement.id, 'Test Attachment TLLA'));
        lstAttachment.add(UTL_TPA_SetupTestData.addAttachment(testAgreement.id, 'AMA_TPA-Test Attachment'));
        lstAttachment.add(UTL_TPA_SetupTestData.addAttachment(testAgreement.id, 'AMA_TPA-Service Bureau II Test Attachment'));
        insert lstAttachment;
        
        DocuSign_Auth_Data__c docAuthData = new DocuSign_Auth_Data__c();
        docAuthData.Name = 'TPA';
        docAuthData.User_Name__c = 'TPA Docusign Username';
        docAuthData.Base_URL__c = 'account-d.docusign.com';
        docAuthData.Client_Id__c = 'Integrator';
        docAuthData.DocuSign_Pwd__c = 'Docusign Password';
        docAuthData.DocusignUser_Id__c = 'User Id';
        docAuthData.Private_Key__c = 'Private Key';
        docAuthData.Public_Key__c = 'Public Key';
        docAuthData.Access_Token__c = ' ';
        docAuthData.Docusign_Auth_Endpoint__c = 'https://account-d.docusign.com/oauth/token';
        docAuthData.Docusign_Auth_ContentType__c = 'application/x-www-form-urlencoded';
        docAuthData.Docusign_Auth_Scope__c = 'signature spring_read spring_write';
        insert docAuthData;
    }

    public static testMethod void generateDocForSign()
    {
        
        dsfs__DocuSign_Status__c objDocusignStatus = [select id,TPA_Request__c,dsfs__DocuSign_Envelope_ID__c,dsfs__Envelope_Status__c, TPA_Request__r.name from dsfs__DocuSign_Status__c limit 1 ];
        dsfs__DocuSign_Recipient_Status__c objDocusignRecipient = UTL_TPA_SetupTestData.getNewDocusignRecipientStatus(objDocusignStatus);//[select id,name,dsfs__Envelope_Id__c,dsfs__Parent_Status_Record__c,dsfs__Recipient_Status__c,dsfs__DocuSign_Recipient_Email__c from dsfs__DocuSign_Recipient_Status__c where dsfs__Parent_Status_Record__c =: objDocusignStatus.id];
       TPA_Request__c  objAgreement  = [SELECT Id, Name FROM TPA_Request__c where id = : objDocusignStatus.TPA_Request__c LIMIT 1];
        List<Attachment> lstAttachment = [SELECT Id, Name, ParentId From Attachment];
		Attachment addHocAttch = UTL_TPA_SetupTestData.addAttachment(objAgreement.id, 'test.pdf');
        insert addHocAttch;
        Test.startTest();
            SRV_TPA_DocusignEnvelope.generateDocForSign(objAgreement.id, UTL_LogFactory.GUID);
            SRV_TPA_DocusignEnvelope.generateAmaDocForSign(''+objAgreement.id, UTL_LogFactory.GUID);    //added by neha bansal
            SRV_TPA_DocusignEnvelope.sendEnvelope(objAgreement.id);
            SRV_TPA_DocusignEnvelope.sendReminderForEnvelope(objAgreement.id);
            SRV_TPA_DocusignEnvelope.resendEnvelope(objDocusignRecipient);
            SRV_TPA_DocusignEnvelope.createAndSendEnvelopeForAgreement(objAgreement.id, null);
            SRV_TPA_DocusignEnvelope.voidEnvelopeCallout(objAgreement.id , 'English'); //Updated by Babita Dadarwal under ER-1940 on 24 Oct 2016
            SRV_TPA_DocusignEnvelope.voidEnvelope(objDocusignStatus.dsfs__DocuSign_Envelope_ID__c , 'Envelope is corrected'); //Updated by Babita Dadarwal under ER-1940 on 24 Oct 2016
            SRV_TPA_DocusignEnvelope.updateAgreement(objDocusignStatus.TPA_Request__c, date.today(), objDocusignStatus.dsfs__DocuSign_Envelope_ID__c, objDocusignStatus.id);
            SRV_TPA_DocusignEnvelope.getEnvelopeStatus(objDocusignStatus.dsfs__DocuSign_Envelope_ID__c);
            SRV_TPA_DocusignEnvelope.voidEnvelope(new set<id>{objAgreement.id}, 'test reason');
        	SRV_TPA_DocusignEnvelope.mergeAddHocDocsWithTLLA(objAgreement.id,'');
        	SRV_TPA_DocusignEnvelope.mergeAddHocDocs(objAgreement.id,new List<Id>{addHocAttch.Id},'','');
        Test.stopTest();
    }
}
