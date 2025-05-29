@isTest(seeAllData=false)
public class TST_SRV_CDA_DocusignStatus {
	@testSetup
    public static void setupData() {
        TST_CDA_SetupData testSetup = new TST_CDA_SetupData();
        testSetup.setUpCustomSetting();
        testSetup.setUpContactForEmail();
        testSetup.setupUserRequestor();
        testSetup.setupUserNegotiator();

        //Added by Vikram Singh under CR-11576 Start
        CDA_Approved_Governing_Law_Location__c governingLaw = TST_CDA_SetupData.getGoverningLaw('Test GL');
        insert governingLaw;

        QI_Legal_Entity__c testQiLegalEntity = TST_CDA_SetupData.createQiLegalEntity('Test Entity1', UTL_CDAUtility.CDA_BUSINESS_PART_LQ, governingLaw); //Updated by Vikram Singh under CR-11576
        insert testQiLegalEntity;

        //create Legal POC Attorney record
        CDA_Legal_POC_Cross_Walk__c testLegalPOC = new CDA_Legal_POC_Cross_Walk__c(CDA_Language__c='Chinese',Legal_POC_First_Name__c='TestChinese',Legal_POC_Last_Name__c='Attorney',Legal_POC_Email_Address__c='test@abc.com');
        insert testLegalPOC;
        
        CDA_Request__c cdaRequest = testSetup.setupTestDataForAuditor(testQiLegalEntity);
        cdaRequest.CDA_Type__c = UTL_CDAUtility.AUDITOR;
        cdaRequest.Customer_Consent_to_Disclose__c = UTL_CDAUtility.YES;
        update cdaRequest;
        Attachment testAttachment = testSetup.getAttachment(UTL_CDAUtility.GENERATED_DOCUMENT_KEYWORD + '_Test Attachment' + UTL_CDAUtility.EXTENTION_DOC , cdaRequest.Id, false);
        Attachment testAttachment1 = testSetup.getAttachment(UTL_CDAUtility.UPLOADED_AUDIT_SCOPE_AGENDA_FILE + '_Test Attachment' + UTL_CDAUtility.EXTENTION_DOC , cdaRequest.Id, false);
        Attachment testAttachment2 = testSetup.getAttachment(UTL_CDAUtility.UPLOADED_CUSTOMER_CONSENT_TO_DISCLOSE_FILE + '_Test Attachment' + UTL_CDAUtility.EXTENTION_DOC , cdaRequest.Id, false);
        List<Attachment> attchs = new List<Attachment>();
        attchs.add(testAttachment);
        attchs.add(testAttachment1);
        attchs.add(testAttachment2);
        insert attchs;

        DocuSign_Auth_Data__c docAuthData = new DocuSign_Auth_Data__c();
        docAuthData.User_Name__c = 'CDA';
        docAuthData.Name = 'CDA';
        docAuthData.Base_URL__c = 'account-d.docusign.com';
        docAuthData.Client_Id__c = 'Integrator';
        docAuthData.DocuSign_Pwd__c = 'Docusign Password';
        docAuthData.DocusignUser_Id__c = 'User Id';
        docAuthData.Private_Key__c = 'Private Key';
        docAuthData.Public_Key__c = 'Public Key';
        docAuthData.Access_Token__c = ' ';
        insert docAuthData;

    }
    
    public static testMethod void testCreateAndSendEnvelope() {
        
        CDA_Request__c cdaRequest = new CDA_Request__c();
        String query = 'SELECT id, Name, CDA_Id__c, CDA_Type__c, Status__c, What_is_the_Study_Sponsor_situation__c, Recipient_Point_of_Contact_Name__c, Negotiator_Assigned_List__c, CDA_Language__c, Requestor_Carbon_Copies__c, Requestor_Admin_Email_Flag__c, On_Behalf_of_User_Full_Name__c, On_Behalf_Of_User_Email__c, Recipient_Point_of_Contact_Email_Address__c, Recipient_Authorized_Signer_Email_Addres__c, Legal_POC_Cross_Walk__c, Legal_POC_Cross_Walk__r.Legal_POC_Full_Name__c, Legal_POC_Cross_Walk__r.Legal_POC_Email_Address__c, Negotiator_Assigned__c, What_documents_would_you_like_to_provide__c, Originating_Requestor_Flag__c, Originating_Requestor_IQVIA_Email__c, Owner.Name, Owner.Email FROM CDA_Request__c';
        List<CDA_Request__c> cdaRequestList = Database.query(query);
        cdaRequest = cdaRequestList[0];
        Test.StartTest();
        SRV_CDA_DocusignStatus.createAndSendEnvelope(cdaRequest.Id);
        Test.stopTest();
    }
    
    public static testMethod void testSplitSigned() {
        
        CDA_Request__c cdaRequest = new CDA_Request__c();
        String query = 'SELECT id, Name, CDA_Id__c, CDA_Type__c, Status__c, What_is_the_Study_Sponsor_situation__c, Recipient_Point_of_Contact_Name__c, Negotiator_Assigned_List__c, CDA_Language__c, Requestor_Carbon_Copies__c, Requestor_Admin_Email_Flag__c, On_Behalf_of_User_Full_Name__c, On_Behalf_Of_User_Email__c, Recipient_Point_of_Contact_Email_Address__c, Recipient_Authorized_Signer_Email_Addres__c, Legal_POC_Cross_Walk__c, Legal_POC_Cross_Walk__r.Legal_POC_Full_Name__c, Legal_POC_Cross_Walk__r.Legal_POC_Email_Address__c, Negotiator_Assigned__c, What_documents_would_you_like_to_provide__c, Originating_Requestor_Flag__c, Originating_Requestor_IQVIA_Email__c, Owner.Name, Owner.Email FROM CDA_Request__c';
        List<CDA_Request__c> cdaRequestList = Database.query(query);
        cdaRequest = cdaRequestList[0];
        
        dsfs__DocuSign_Status__c testDSStatus = TST_CDA_SetupData.getDSStatusByRequestId(cdaRequest.Name);
        testDSStatus.CDA_Request__c = cdaRequest.Id;
        testDSStatus.dsfs__Envelope_Status__c = 'Sent';
        update testDSStatus;
        Set<String> cdas = new Set<String>();
        cdas.add(cdaRequest.CDA_Id__c);
        Test.StartTest();
        SRV_CDA_DocusignStatus.splitSignedDocument(cdaRequest.Id,testDSStatus.dsfs__DocuSign_Envelope_ID__c);
        Test.stopTest();
    }
}