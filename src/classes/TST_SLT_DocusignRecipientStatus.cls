@isTest
private class TST_SLT_DocusignRecipientStatus {

    @isTest
    private static void tesetSelectByIdShouldReturnList() {
        dsfs__DocuSign_Status__c status = new dsfs__DocuSign_Status__c();
        insert status;
        dsfs__DocuSign_Recipient_Status__c recipientStatus = new dsfs__DocuSign_Recipient_Status__c();
        recipientStatus.dsfs__Parent_Status_Record__c = status.Id;
        recipientStatus.dsfs__DocuSign_Recipient_Id__c = TST_CLM_TestDataFactory.createAgreement(null, true).Id;
        insert recipientStatus;

        Test.startTest();
            List<dsfs__DocuSign_Recipient_Status__c> recipientStatusList = new SLT_DocusignRecipientStatus().selectById(
                new Set<Id>{recipientStatus.Id});
        Test.stopTest();

        System.assertNotEquals(0, recipientStatusList.size(), 'Recipient Status List should not be empty.');
    }

    @isTest
    private static void testSelectByIdWithDocusignStatusShouldReturnList() {
        Apttus__APTS_Agreement__c agreement = TST_CLM_TestDataFactory.createAgreement(null,true);
        Agreement_Extension__c agreementExt = TST_CLM_TestDataFactory.createAgreementExtension(agreement.Id,true);
        
        dsfs__DocuSign_Status__c statusObj = new dsfs__DocuSign_Status__c();
        statusObj.Agreement__c = agreement.id;  
        statusObj.dsfs__DocuSign_Envelope_ID__c = 'EFFDCCFB-B395-4509-BF5F-004E50A0B893';           
        statusObj.dsfs__Envelope_Status__c = 'Declined';           
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

        Set<String> docusignRecipientStatusFields = new Set<String>{'Id', 'Name', 'dsfs__Parent_Status_Record__c', 
            'dsfs__Recipient_Status__c', 'dsfs__Parent_Status_Record__r.Agreement__c', 'dsfs__Decline_Reason__c'};
        Set<Id> recordTypeIdSet = new Set<Id>{CON_CLM.PSA_RECORDTYPEID};
        String condition = 'Id IN: idSet AND dsfs__Parent_Status_Record__r.Agreement__c != null'
            +' AND dsfs__Parent_Status_Record__r.Agreement__r.RecordTypeId IN: recordTypeIds'
            +' AND dsfs__Recipient_Status__c = \'Declined\'';

        Test.startTest();
            List<dsfs__DocuSign_Recipient_Status__c> recipientStatusList = 
                new SLT_DocusignRecipientStatus().selectByIdWithDocusignStatus(docusignRecipientStatusFields,new Set<Id>{receipient.Id},
                    recordTypeIdSet,condition);
        Test.stopTest();

        System.assertNotEquals(0, recipientStatusList.size(), 'Recipient Status List should not be empty');
    }
}