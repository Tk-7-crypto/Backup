@isTest
public class TST_TGR_AccountContactRelation {
    
        
    /**
* This method is used to setup data for all methods.
*/
    @testSetup
    static void dataSetup(){
        
        Account acc1 = UTL_TestData.createAccount();
        acc1.Name = 'Test Parent Acc1';
        insert acc1;
        Contact cnt1 = UTL_TestData.createContact(acc1.Id);
        cnt1.RecordTypeId = CON_CRM.IQVIA_USER_CONTACT_RECORD_TYPE_ID;
        cnt1.LastName = 'TestName';
        cnt1.EmployeeNumber__c = '245';
        insert cnt1;
        Contact cnt2 = UTL_TestData.createContact(acc1.Id);
        cnt2.RecordTypeId = CON_CRM.IQVIA_USER_CONTACT_RECORD_TYPE_ID;
        cnt2.LastName = 'TestName';
        cnt2.EmployeeNumber__c = '345';
        insert cnt2; 
        
    }
    
    @istest
    static void testAccountContactRelation(){
        List<Account> acc = [SELECT Id, Name FROM Account WHERE Name = 'Test Parent Acc1'];
        List<Contact> con = [SELECT Id, LastName FROM Contact WHERE LastName = 'TestName'];
        List<AccountContactRelation> accountContactRelationList = new List<AccountContactRelation>();
        accountContactRelationList.add([SELECT Id, AccountId, ContactId, Focus__c, Function__c, Geographic_Responsibility__c FROM AccountContactRelation WHERE AccountID =: acc[0].Id AND ContactId =: con[0].Id]);
        accountContactRelationList.add([SELECT Id, AccountId, ContactId, Focus__c, Function__c, Geographic_Responsibility__c FROM AccountContactRelation WHERE AccountID =: acc[0].Id AND ContactId =: con[1].Id]);
        Test.startTest();
        upsert accountContactRelationList;
        Test.stopTest();
        List<AccountContactRelation> acrList = [SELECT ID, AccountId FROM AccountContactRelation WHERE AccountId =: acc[0].Id];
        Integer expected = 2;
        Integer actual = acrList.size();
        System.assertEquals(expected,actual);
    }
}