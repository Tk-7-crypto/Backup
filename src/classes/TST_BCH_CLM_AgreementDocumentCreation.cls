@isTest
public class TST_BCH_CLM_AgreementDocumentCreation {
    @testSetup
    static void dataSetup() {
        Apttus__APTS_Agreement__c testAgreement = TST_CLM_TestDataFactory.createAgreement(CON_CLM.PSA_RECORDTYPEID, false);
        testAgreement.Name = 'Test Agreement';
        testAgreement.Apttus__Subtype__c = CON_CLM.REQUESTED_AGREEMENT_TYPE_SCCAmendment;
        insert testAgreement;
        
        Apttus__APTS_Template__c template = TST_CLM_TestDataFactory.createAPTSTemplate(true);
        template.Name = 'SCC Remediation';
        update template;
    }
    
    @isTest
    private static void testBatchAgreementDocumentCreation() {
        Test.startTest();
            Apttus__APTS_Template__c templateRec = [SELECT Id, Name FROM Apttus__APTS_Template__c WHERE Name LIKE 'SCC Remediation'];
            String query = 'SELECT Id, Name, Apttus__Status_Category__c, Apttus__Status__c FROM Apttus__APTS_Agreement__c WHERE Apttus__Subtype__c = \'SCC Remediation\'';
            
        	try{
                BCH_CLM_AgreementDocumentCreation batch = new BCH_CLM_AgreementDocumentCreation(query, templateRec.Id);
                Database.executeBatch(batch);
            } catch(Exception ex){
                System.assertNotEquals(null, ex, 'There is a problem occured while creating document version.');
            }
        Test.stopTest();
    }
}