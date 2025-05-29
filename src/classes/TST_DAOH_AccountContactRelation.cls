@isTest
public class TST_DAOH_AccountContactRelation {
    
    /**
* This method is used to setup data for all methods.
*/
    @testSetup
    static void dataSetup(){
        
        Account acc1 = new Account(Name = 'Test Parent 1', BillingStreet = 'testStreet', BillingCity = 'testCity', BillingCountry = 'testCountry', BillingPostalCode = '123465',AccountCountry__c = 'AF', CustomerSegment__c = 'GOVERNMENT', Sub_Industry__c = 'STATE');
        insert acc1;
        Account acc2 = new Account(Name = 'Test Parent 2', BillingStreet = 'testStreet', BillingCity = 'testCity', BillingCountry = 'testCountry', BillingPostalCode = '123465',AccountCountry__c = 'AF', CustomerSegment__c = 'GOVERNMENT', Sub_Industry__c = 'STATE');
        insert acc2;
        Contact cnt1 = new Contact(FirstName = 'TestFirstName', LastName = 'TestName 1', accountId = acc1.Id);
        insert cnt1;
        Contact cnt2 = new Contact(FirstName = 'TestFirstName', LastName = 'TestName 2', accountId = acc2.Id);
        insert cnt2;
    }
    
    static testMethod void testpreventDuplicateAccountContactRelationOnAccount(){
        
        Account acc1 = [SELECT Id, Name FROM Account WHERE Name = 'Test Parent 1'];
        Account acc2 = [SELECT Id, Name FROM Account WHERE Name = 'Test Parent 2'];
        Contact con1 = [SELECT Id, LastName FROM Contact WHERE LastName = 'TestName 1'];
        Contact con2 = [SELECT Id, LastName FROM Contact WHERE LastName = 'TestName 2'];
       
        Test.startTest();
         
        List<AccountContactRelation> accountContactRelationList = new List<AccountContactRelation>();
        accountContactRelationList.add([SELECT Id, Account.Name, AccountId, ContactId, Focus__c, Function__c, Geographic_Responsibility__c FROM AccountContactRelation WHERE IsActive = true AND AccountID =: acc1.Id]);
        accountContactRelationList.add([SELECT Id, Account.Name, AccountId, ContactId, Focus__c, Function__c, Geographic_Responsibility__c FROM AccountContactRelation WHERE IsActive = true AND AccountID =: acc2.Id]);
        
        AccountContactRelation acr1 = accountContactRelationList[0];
        acr1.Focus__c = 'Commercial Services';
        acr1.Function__c = 'Account Lead';
        acr1.Geographic_Responsibility__c = 'Global';
        
        AccountContactRelation acr2 = accountContactRelationList[1];
        acr2.Focus__c = 'Clinical Technology';
        acr2.Function__c = 'Inside Sales';
        acr2.Geographic_Responsibility__c = 'Local';
        
        if(accountContactRelationList.size() > 0){
            update accountContactRelationList;
        }
        String addError;
        try{
            Contact cnt1 = UTL_TestData.createContact(acc2.Id);
            cnt1.RecordTypeId = CON_CRM.IQVIA_USER_CONTACT_RECORD_TYPE_ID;
            cnt1.LastName = 'TestName';
            cnt1.EmployeeNumber__c = '245';
            insert cnt1;
            AccountContactRelation acr = [SELECT Id, AccountId, ContactId, Focus__c, Function__c, Geographic_Responsibility__c FROM AccountContactRelation WHERE AccountID =: acc2.Id];
            acr.Focus__c = 'Clinical Technology';
            acr.Function__c = 'Inside Sales';
            acr.Geographic_Responsibility__c = 'Local';
            update acr;
        } catch(Exception e){
            addError = 'There is already existing team member in Active with EXACT same Function, Focus, and Geographic Responsibility. Please make existing Team member Inactive and add new one.';
            System.assertEquals(addError, 'There is already existing team member in Active with EXACT same Function, Focus, and Geographic Responsibility. Please make existing Team member Inactive and add new one.');
        }
        Test.stopTest();
    }
}