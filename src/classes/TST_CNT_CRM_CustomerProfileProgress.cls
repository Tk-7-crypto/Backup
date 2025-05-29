/**
 * Author: Kimberly Small
 * Description: Test Class for CNT_CRM_CustomerProfileProgress
**/
@isTest
public class TST_CNT_CRM_CustomerProfileProgress {
    @testSetup static void dataSetup(){
        Customer_Profile__c cProfile1 = UTL_TestData.createCustomerProfileRecord('Description', true, 2, false, null);
        insert cProfile1;
        
        Customer_Profile__c cProfile2 = UTL_TestData.createCustomerProfileRecord('Phone', true, 2, false, null);
        insert cProfile2;
        
        Account acc1 = UTL_TestData.createAccount();
        acc1.Description = 'This is a data quality test.';
        acc1.Phone='123-456-5790';
        insert acc1;
        
        Account acc2 = UTL_TestData.createAccount();
        acc2.Name = 'TestAccount2';
        insert acc2;
        
        Account acc3 = UTL_TestData.createAccount();
        acc3.Name = 'TestAccount3';
        acc3.Description = 'This is a data quality test.';
        insert acc3;
    }
    
    @isTest static void testMaxAccScores(){
		List<Account> acc = [SELECT Id FROM Account WHERE Name = 'TestAccount' LIMIT 1];
        
        Test.startTest();
        Map<String, Decimal> scores = CNT_CRM_CustomerProfileProgress.getScores(acc[0].Id, 'Account');
        Test.stopTest();
        
        System.assertEquals(100, scores.get('Data Quality Score'));
    }
    
    @isTest static void testMinAccScores(){
        List<Account> acc = [SELECT Id FROM Account WHERE Name = 'TestAccount2' LIMIT 1];
        
        Test.startTest();
        Map<String, Decimal> scores = CNT_CRM_CustomerProfileProgress.getScores(acc[0].Id, 'Account');
        Test.stopTest();

        System.assertEquals(0, scores.get('Data Quality Score'));
    }
    
        @isTest static void testPartialAccScores(){
		List<Account> acc = [SELECT Id FROM Account WHERE Name = 'TestAccount3' LIMIT 1];
        
        Test.startTest();
        Map<String, Decimal> scores = CNT_CRM_CustomerProfileProgress.getScores(acc[0].Id, 'Account');
        Test.stopTest();
        
        System.assertEquals(50, scores.get('Data Quality Score'));
    }
}