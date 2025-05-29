@isTest
public class TST_CNT_CRM_AllAccountCompetitors {
    
    @testsetup
    static void setupData(){
        Account aG = UTL_TestData.createAccount();
        aG.RecordTypeId = CON_CRM.GLOBAL_CUSTOMER_ACCOUNT_RECORD_TYPE_ID;
        insert aG;
        
        Account acc = UTL_TestData.createAccount();
        acc.ParentId = aG.Id;
        insert acc;
        
        acc.MDM_Validation_Status__c = CON_CRM.MDM_VALIDATION_STATUS_VALIDATED;
        update acc;
        
        Account_Competitor__c ac = new Account_Competitor__c(Account__c = acc.Id, Competitor_Category__c = 'IQVIA', Contract_Start_Date__c = System.today(), Contract_End_Date__c = System.today() + 30);
        insert ac;
    }
    
    @isTest
    public static void getAccountCompetitors(){
        Account AG = [SELECT Id FROM Account where RecordTypeId =:CON_CRM.GLOBAL_CUSTOMER_ACCOUNT_RECORD_TYPE_ID];
        Test.startTest();
        List<Account_Competitor__c> listOfAc = CNT_CRM_AllAccountCompetitors.getAccountCompetitors(AG.Id); 
        System.assertEquals(1,listOfAc.size());
        Test.stopTest();
    }
}