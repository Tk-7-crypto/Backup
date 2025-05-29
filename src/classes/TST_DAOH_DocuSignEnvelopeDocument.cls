@isTest
public class TST_DAOH_DocuSignEnvelopeDocument {
    @isTest
    static void TestDAO_DocusignEnveDoc() {
        TPA_Multilingual_Template_Setting__c templateobj = new TPA_Multilingual_Template_Setting__c( Name = 'Test template', 
                                                                                                     Translated_Template_Id__c = '95E7F69B-6828-4A8B-93B9-20E73F2CE4DC', 
                                                                                                     label__c = 'Docusign Template');
        insert templateobj;
        
        
        Address__c testAccount1 = UTL_TPA_SetupTestData.getAccount();
        testAccount1.Name = 'Test Acc';
        insert testAccount1;

        TPA_Request__c tpaRequest1 = UTL_TPA_SetupTestData.getTestTPARequest();
        tpaRequest1.Request_Status__c = 'In Effect';
        tpaRequest1.OwnerId = UserInfo.getUserId();
        tpaRequest1.Service_Provider_Address__c = testAccount1.Id;
        tpaRequest1.Client_Address__c = testAccount1.Id;
        tpaRequest1.Client_Language__c = 'Japanese';
        tpaRequest1.Vendor_Language__c = 'Japanese';
        tpaRequest1.Vendor_Billing_Mailing_Country__c = 'united states';
        tpaRequest1.Is_CPC_Renewal_Notice_Sent__c = true;
        tpaRequest1.Is_CPC_Expiration_Notice_Sent__c = true;
        tpaRequest1.Is_CPC_Post_Expiration_Notice_Sent__c = true;
        insert tpaRequest1;
        
        Attachment attachment1 = new Attachment();
        attachment1.OwnerId = UserInfo.getUserId();
        attachment1.Name= 'Att1.pdf';
        attachment1.body= Blob.valueOf('Test Body');
        attachment1.ParentId = tpaRequest1.ID ;
        attachment1.IsPrivate = true;
        insert attachment1;
        
        dsfs__DocuSign_Envelope__c ene = new dsfs__DocuSign_Envelope__c(dsfs__Source_Object__c = tpaRequest1.id);
        insert ene;
        
        dsfs__DocuSign_Envelope_Document__c eneDoc = new dsfs__DocuSign_Envelope_Document__c( dsfs__Attachment_NameEx__c = 'Att1.pdf', 
                                                                                             dsfs__Document_ID__c = attachment1.id, 
                                                                                             dsfs__Document_Name__c = 'Att1.pdf', 
                                                                                             dsfs__DocuSign_EnvelopeID__c = ene.id, 
                                                                                             dsfs__External_Document_Id__c = '95E7F69B-6828-4A8B-93B9-20E73F2CE4DC');
        insert eneDoc;
        update eneDoc; 
        delete eneDoc;
    }
}