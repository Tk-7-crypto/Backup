@isTest
public class TST_CNT_CLM_IQVIARelatedList {
    @testSetup
    static void testSetupData() {
        Apttus__APTS_Agreement__c agreement = TST_CLM_TestDataFactory.createAgreement(CON_CLM.GENERIC_RECORDTYPEID, false);
        agreement.Name = 'Test Generic';
        agreement.Apttus__Status_Category__c = CON_CLM.REQUEST;
        agreement.Apttus__Status__c = CON_CLM.REQUEST;       
        insert agreement;
        
        IQVIA_Agreement__c iqAGR = TST_CLM_TestDataFactory.createIQAgreement(CON_CLM.USBU_IQVIA_RECORDTYPEID, false);
        iqAGR.Name = 'Test IQVIA AGR';
        iqAGR.Conga_Agreement_Id__c = agreement.Id;
        insert iqAGR;
        
        List<Apttus__Agreement_Clause__c> lstAgreementClause = new List<Apttus__Agreement_Clause__c>();
        Apttus__Agreement_Clause__c agreementClause = new Apttus__Agreement_Clause__c();
        agreementClause.Apttus__Agreement__c = agreement.Id;
        agreementClause.Apttus__Action__c = CON_CLM.MODIFIED;
        agreementClause.Apttus__Clause__c = 'US_SplTerm_Common_Fax Numbers';
        lstAgreementClause.add(agreementClause); 
        insert lstAgreementClause;
    }
    
    @isTest
    private static void testGetAgreementClause(){
        IQVIA_Agreement__c iqAgr = [Select Id, Conga_Agreement_Id__c From IQVIA_Agreement__c where Name ='Test IQVIA AGR' LIMIT 1];
        Test.startTest();
            List<Apttus__Agreement_Clause__c> agrClauses = CNT_CLM_IQVIARelatedList.getAgreementClause(iqAGr.Id);
        Test.stopTest();
        Assert.areEqual('US_SplTerm_Common_Fax Numbers', agrClauses[0].Apttus__Clause__c, 'Clause Shoulde be same');
        
    }

    @isTest
    private static void testHasEditDeleteAccess(){
        Boolean isEdit = true;
        Boolean isDelete = true;
        User salesUser = UTL_TestData.createUser('Sales User', 1).get(0);
        insert salesUser;
        
        List<PermissionSetAssignment> lstPSA = new List<PermissionSetAssignment>();
        lstPSA.add(UTL_TestData.createPermissionSetAssignmentRecord('CLM_USBU', salesUser.Id));
        lstPSA.add(UTL_TestData.createPermissionSetAssignmentRecord('CLM_IQVIA_Licensed_User', salesUser.Id));
        lstPSA.add(UTL_TestData.createPermissionSetAssignmentRecord('CLM_IQVIA_Base', salesUser.Id));
        insert lstPSA;
        
        User sUser = [SELECT Id FROM User WHERE Email = 'testuser3133@iqvia.com' LIMIT 1];
        
        System.runAs(sUser){
            Test.startTest();
                isEdit = CNT_CLM_IQVIARelatedList.hasEditAccess('Apttus__Agreement_Clause__c');
                isDelete = CNT_CLM_IQVIARelatedList.hasDeleteAccess('Apttus__Agreement_Clause__c');
            Test.stopTest();
        }
        
        Assert.areEqual(false,isEdit, 'Should return false');
        Assert.areEqual(false,isDelete, 'Should return false');
    }
}