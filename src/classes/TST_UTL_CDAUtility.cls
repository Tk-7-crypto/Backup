@isTest(seeAllData=false)
public class TST_UTL_CDAUtility {
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

        CDA_Account__c testCdaAccount = testSetup.cdaAccount;

        CDA_Request__c cdaRequest = testSetup.setupTestDataForCustomer(testQiLegalEntity);
        cdaRequest.Originating_Requestor_Flag__c = 'Yes';
        cdaRequest.Originating_Requestor_IQVIA_Email__c = 'orignating@req.com';
        cdaRequest.What_documents_would_you_like_to_provide__c = UTL_CDAUtility.CDA_RESPONSE_DOCTYPE_REDLINED;
        update cdaRequest;

        CDA_Request__c cdaRequest2 = testSetup.setupTestDataForAuditor(testQiLegalEntity);

        Attachment testAttachment1 = testSetup.getAttachment(UTL_CDAUtility.GENERATED_DOCUMENT_KEYWORD + '_Test Attachment' + UTL_CDAUtility.EXTENTION_DOC , cdaRequest2.Id);
        Attachment testAttachment2 = testSetup.getAttachment(UTL_CDAUtility.RED_LINE_KEYWORD , cdaRequest.Id);
        Attachment testAttachment3 = testSetup.getAttachment(UTL_CDAUtility.RED_LINE_KEYWORD + UTL_CDAUtility.COMPLETED_KEYWORD, cdaRequest.Id);
        Attachment testAttachment4 = testSetup.getAttachment(UTL_CDAUtility.RED_LINE_KEYWORD + UTL_CDAUtility.CLEANED_DOC_KEYWORD, cdaRequest.Id);
    }

    @isTest
    public static void runCdaUtilityTest() {
        map<String, CDA_Governing_Law_Name_and_PrintName__mdt> tstGoverningLawNameAndPrintNameMap = UTL_CDAUtility.governingLawNameAndPrintNameMap;
        Set<String> tstSetOfUserIdsHavingApttusLicense = UTL_CDAUtility.setOfUserIdsHavingApttusLicense;
        CDA_Request__c cdaRequest = new CDA_Request__c();
        String query = 'SELECT id, Name, CDA_Id__c, CDA_Type__c, CDA_Format__c, Status__c, What_is_the_Study_Sponsor_situation__c, Recipient_Point_of_Contact_Name__c, Negotiator_Assigned_List__c, CDA_Language__c, OwnerId, RecordTypeId, Requestor_Admin_Email_Flag__c, Originating_Requestor_Flag__c, Originating_Requestor_IQVIA_Email__c, Recipient_Account_Name_Formula__c FROM CDA_Request__c';
        List<CDA_Request__c> cdaRequestList = Database.query(query);
        
        if(cdaRequestList.size() > 0) {
            cdaRequest = cdaRequestList[0];
        }
        
        cdaRequest.Additional_Contact_Flag__c = 'Yes';
        cdaRequest.Additional_Contact_Details__c = 'TEST,TEST1,Test2';
        update cdaRequest;

        UTL_CDAUtility.logRef();
        UTL_CDAUtility.setLogObject(cdaRequest.Id, 'logDetail', 'otherDetail');
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        email.setTemplateId(UTL_CDAUtility.getTemplateId('templateName', 'language'));
        email.setCcAddresses(new List<String>{'test@test.com'});
        email.setToAddresses(new List<String>{'test@test.com'});
        Contact con = new Contact(FirstName = 'Test', LastName = 'Con', email = 'test@test.com');
        insert con;
        email.setTargetObjectId(con.Id);
        email.setWhatId(cdaRequest.Id);
        UTL_CDAUtility.sendNotificationEmail(new List <Messaging.SingleEmailMessage>{email});
        UTL_CDAUtility.sendEmailThroughWorkflow(email);
        UTL_CDAUtility.getDocumentName(cdaRequest, UTL_CDAUtility.CDASOURCE_QUINTILESIMS);
        UTL_CDAUtility.getRelationObjectFieldStr('QI_Legal_Entity__c', 'QI_Legal_Entity_Name__c');
        UTL_CDAUtility.getObjectFieldStr('CDA_Request__c');
        UTL_CDAUtility.getUserDetails();
        UTL_CDAUtility.getAdditionalContactsDetails(cdaRequest.Id);
        UTL_CDAUtility.login('user', 'password');
        Boolean isSandbox = UTL_CDAUtility.isSandboxOrg;
    } 
}