@isTest
public class TST_CNT_CRM_AgreementBox {
	@testsetup
    static void setupTestData(){
        Account testAccount = UTL_TestData.createAccount();
        insert testAccount;
        Opportunity testOpportunity = UTL_TestData.createOpportunity(testAccount.Id);
        testOpportunity.Line_of_Business__c = CON_CPQ.SAMPLE_LINE_OF_BUSINESS;
        testOpportunity.Is_this_IQVIA_Biotech__c = CON_CPQ.YES_TITLE_CASE;
        insert testOpportunity;

        Stage_Gate_Status_Values__c statusvalue = new Stage_Gate_Status_Values__c();
        statusvalue.Name = 'AnalystPP';
        statusvalue.Status__c = 'Analyst Preparing Customer Budget Deliverable';
        upsert statusvalue;
        IQVIA_Legal_Entity__c iqviaLegalEntity = UTL_TestData.createIQVIALegalEntity();
        insert iqviaLegalEntity;
        Contract cntrt = new Contract();
        cntrt.AccountId = testAccount.Id;
        cntrt.Status = 'Draft';
        cntrt.CurrencyIsoCode = 'INR';
        cntrt.Status = 'Analyst Preparing Customer Budget Deliverable';
        cntrt.StartDate = System.today();
        cntrt.ContractTerm = 12;
        cntrt.Parent_Contract_Number__c = 1234;
        cntrt.Ultimate_Parent_Contract_Number__c = 5678;
        cntrt.Legal_Entity_IQVIA__c = iqviaLegalEntity.Id;
        cntrt.Legal_Entity_Customer__c = 'Test';
        cntrt.Opportunity__c = testOpportunity.Id;
        insert cntrt;
    }
    static Apttus__APTS_Agreement__c getAgreementData(Id OpportuntiyId, String recordTypeAPIName){
        Id recordTypeId = SObjectType.Apttus__APTS_Agreement__c.getRecordTypeInfosByDeveloperName().get(recordTypeAPIName).getRecordTypeId();
        Apttus__APTS_Agreement__c testAgreement = UTL_TestData.createAgreement();
        testAgreement.Apttus__Related_Opportunity__c = OpportuntiyId;
        testAgreement.RecordTypeId = recordTypeId;
        return testAgreement;
    }
    @isTest
    static void testM1(){
        List<Contract> conList = [select Id,Name from Contract limit 1];
        CNT_CRM_AgreementBox.fetchAgreement(conList[0].Id);
    }
}