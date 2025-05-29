@isTest
public class TST_DAO_Docusign_Envelope {
    @testSetup
    static void dataSetup() {
        TST_CLM_TestDataFactory.createClmConfigurationSetting(true);
        
        List<Apttus__APTS_Agreement__c> agreementList = new List<Apttus__APTS_Agreement__c>();
        Apttus__APTS_Agreement__c agreement = TST_CLM_TestDataFactory.createAgreement(null, false);
        agreement.Name = 'Test agreement Rapid SOW';
        Apttus__APTS_Agreement__c agreementGCE = TST_CLM_TestDataFactory.createAgreement(CON_CLM.PSA_RECORDTYPEID, false);
        agreementGCE.Name = 'Test GCE agreement';
        agreementList.add(agreement);
        agreementList.add(agreementGCE);
        insert agreementList;
        
        
        Agreement_Extension__c agreementExt = TST_CLM_TestDataFactory.createAgreementExtension(agreement.Id, false);
        agreementExt.Submitting_Country__c = 'GMI';
        insert agreementExt;
        
        TST_CLM_TestDataFactory.createAttachment(agreement.Id, 'Generated Document.pdf', true);
    }
    
}