@isTest(seeAllData=false)
public class TST_DAO_DocuSignRecipientStatus {
    @isTest
    static void testCreateUpdateDocuSignReciStatus() {
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
        
        dsfs__DocuSign_Status__c statusObj = new dsfs__DocuSign_Status__c();
        statusObj.TPA_Request__c = tpaRequest1.id;  
        statusObj.dsfs__DocuSign_Envelope_ID__c = 'EFFDCCFB-B395-4509-BF5F-004E50A0B893';           
        statusObj.dsfs__Envelope_Status__c = 'Completed';           
        statusObj.dsfs__Sender__c = 'IMS Alliance Team'; 
        statusObj.dsfs__Sender_Email__c = 'testbmanning@us.imshealth.com';
        statusObj.dsfs__Subject__c = tpaRequest1.Name;
        insert statusObj;
        
        dsfs__DocuSign_Recipient_Status__c receipient = new dsfs__DocuSign_Recipient_Status__c();
        receipient.dsfs__Parent_Status_Record__c = statusObj.id; 
        receipient.dsfs__DocuSign_Recipient_Id__c = 'C54833C0-7664-42D4-B7F3-8B59653F1076';
        receipient.dsfs__Date_Signed__c = Date.today();
        receipient.dsfs__Recipient_Status__c = 'AutoResponded';
        insert receipient;
        update receipient;
    }

    @isTest
    private static void testInsertUpdateDRSWithAgreeemnt(){
        Apttus__APTS_Agreement__c agreement = TST_CLM_TestDataFactory.createAgreement(null,true);
        Agreement_Extension__c agreementExt = TST_CLM_TestDataFactory.createAgreementExtension(agreement.Id,true);
        
        dsfs__DocuSign_Status__c statusObj = new dsfs__DocuSign_Status__c();
        statusObj.Agreement__c = agreement.id;  
        statusObj.dsfs__DocuSign_Envelope_ID__c = 'EFFDCCFB-B395-4509-BF5F-004E50A0B893';           
        statusObj.dsfs__Envelope_Status__c = 'Completed';           
        statusObj.dsfs__Sender__c = 'IMS Alliance Team'; 
        statusObj.dsfs__Sender_Email__c = 'testbmanning@us.imshealth.com';
        statusObj.dsfs__Subject__c = agreement.Name;
        insert statusObj;
        
        dsfs__DocuSign_Recipient_Status__c receipient = new dsfs__DocuSign_Recipient_Status__c();
        receipient.dsfs__Parent_Status_Record__c = statusObj.id; 
        receipient.dsfs__DocuSign_Recipient_Id__c = 'C54833C0-7664-42D4-B7F3-8B59653F1076';
        receipient.dsfs__Date_Signed__c = Date.today();
        receipient.dsfs__Recipient_Status__c = 'Declined';
        insert receipient;
        
        update receipient;
    }
}