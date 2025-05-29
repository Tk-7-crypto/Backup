/**
* This Apex class is test class for SLT_DocuSign_Auth_Data
*/
@isTest
private class TST_SLT_DocuSign_Auth_Data {
    
    @testSetup
    static void setupData() {
        Apttus_DocuApi__DocuSignEnvelope__c docuApiEnvelope = new Apttus_DocuApi__DocuSignEnvelope__c(Name='Test DocuSign Envelope', Docusign_AccountId__c = '12345');
        insert docuApiEnvelope;
        
        DocuSign_Auth_Data__c dsAuthData = new DocuSign_Auth_Data__c();
        dsAuthData.DocusignUser_Id__c = 'abc';
        dsAuthData.User_Name__c = 'dsuser001';
        dsAuthData.Account_Id__c = docuApiEnvelope.Docusign_AccountId__c;
        dsAuthData.Base_URL__c = 'https://demo.docusign.net';
        dsAuthData.Name = 'CLM Test';
        //dsAuthData.Redirect_url__c = '';
        insert dsAuthData;
    }

    @isTest
    private static void testGetDocusignAuthDataDetails() {
        SLT_DocuSign_Auth_Data sltDSAuthData = new SLT_DocuSign_Auth_Data();
        List<DocuSign_Auth_Data__c> lstDocusignAuthData = new List<DocuSign_Auth_Data__c>();
        Test.startTest();
        	lstDocusignAuthData = sltDSAuthData.getDocusignAuthDataDetails(new Set<String>{'Id'}, 1);
        Test.stopTest();
        System.assertEquals(1, lstDocusignAuthData.size(), 'SLT_DocuSign_Auth_Data not returned as expected.');
    }
    
    @isTest
    private static void testGetDocusignAuthDataDetailsByAccountId() {
        SLT_DocuSign_Auth_Data sltDSAuthData = new SLT_DocuSign_Auth_Data();
        List<DocuSign_Auth_Data__c> lstDocusignAuthData = new List<DocuSign_Auth_Data__c>();
        List<Apttus_DocuApi__DocuSignEnvelope__c> testDocusignEnvelope = [SELECT Docusign_AccountId__c FROM Apttus_DocuApi__DocuSignEnvelope__c WHERE Name = 'Test DocuSign Envelope' LIMIT 1];
        Test.startTest();
        	lstDocusignAuthData = sltDSAuthData.getDocusignAuthDataDetailsByAccountId(new Set<String>{'Id'}, 'CLM Test', 1);
        Test.stopTest();
        System.assertEquals(1, lstDocusignAuthData.size(), 'SLT_DocuSign_Auth_Data not returned as expected.');
    }
}