/**
 * This test class is used to test the AgreementPayerController class
 * version : 1.0
 */
@IsTest
public class TST_CNT_CLM_AgreementPayerController {
    @IsTest
    static void testUpdatePayerNewAgreement() {
        Account account = UTL_TestData.createAccount();
        insert account;
        Contact contact = UTL_TestData.createContact(account.Id);
        insert contact;
        Opportunity opportunity = UTL_TestData.createOpportunity(account.Id);
        insert opportunity;        
        Apttus__APTS_Agreement__c agreement = TST_CLM_TestDataFactory.createAgreement(CON_CLM.SOW_RECORDTYPEID, false);
        agreement.Name = 'Test Agreement';
        agreement.Apttus__Related_Opportunity__c = opportunity.Id;
        agreement.Special_Terms_Included__c = 'MDSA';
        insert agreement;
        Agreement_Payer__c payeerSetup = new Agreement_Payer__c();
        payeerSetup.Name = 'Agreement_Payer_Data';
        payeerSetup.Notice1__c = 'Test Notice1';
        payeerSetup.Notice_2__c = 'Test Notice2';
        insert payeerSetup;
        
        Test.startTest(); 
            List<CNT_CLM_AgreementPayerController.SpecialTermsWrapper> specialTermsList = CNT_CLM_AgreementPayerController.getSpecialTerms(agreement.Id);
            String specialTermJSONString = JSON.serialize(specialTermsList);
            CNT_CLM_AgreementPayerController.updateSpecialTerms(agreement.Id, specialTermJSONString);
            CNT_CLM_AgreementPayerController.showCustomSettingData();
        Test.stopTest();
    }
}