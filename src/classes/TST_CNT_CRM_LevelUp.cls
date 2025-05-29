@isTest
public class TST_CNT_CRM_LevelUp {
    @testSetup static void dataSetup(){
        Level_Up__c levelUp1 = UTL_TestData.createLevelUpRecord('Description', true, 1, false, null);
        insert levelUp1;

        Level_Up__c levelUp2 = UTL_TestData.createLevelUpRecord('Phone', true, 2, false, null);
        insert levelUp2;
        
        Level_Up__c levelUp3 = UTL_TestData.createLevelUpRecord('Website', true, 3, false, null);
        insert levelUp3;

        Account acc1 = UTL_TestData.createAccount();
        insert acc1;

        Account acc2 = UTL_TestData.createAccount();
        acc2.Name = 'TestAccount2';
        acc2.Description = 'This is a data quality test.';
        insert acc2;

        Account acc3 = UTL_TestData.createAccount();
        acc3.Name = 'TestAccount3';
        acc3.Description = 'This is a data quality test.';
        acc3.Phone = '123-456-5790';
        insert acc3;

        Account acc4 = UTL_TestData.createAccount();
        acc4.Name = 'TestAccount4';
        acc4.Description = 'This is a data quality test.';
        acc4.Phone = '123-456-5790';
        acc4.Website = 'www.test.com';
        insert acc4;
    }

    @isTest static void testLevelOne() {
        List<Account> acc = [SELECT Id FROM Account WHERE Name = 'TestAccount' LIMIT 1];

        Test.startTest();
        List<Map<String,Object>> currentLevelFields = CNT_CRM_LevelUp.getLevelProgression(acc[0].Id, 'Account', 4);
        Test.stopTest();

        System.assertEquals(1, currentLevelFields[0].get('Level'));
        System.assertEquals('Description', currentLevelFields[0].get('Field'));
        System.assertEquals(false, currentLevelFields[0].get('Completed'));
    }

    @isTest static void testLevelTwo() {
        List<Account> acc = [SELECT Id FROM Account WHERE Name = 'TestAccount2' LIMIT 1];

        Test.startTest();
        List<Map<String,Object>> currentLevelFields = CNT_CRM_LevelUp.getLevelProgression(acc[0].Id, 'Account', 4);
        Test.stopTest();

        System.assertEquals(2, currentLevelFields[0].get('Level'));
        System.assertEquals('Phone', currentLevelFields[0].get('Field'));
        System.assertEquals(false, currentLevelFields[0].get('Completed'));
    }

    @isTest static void testLevelThree() {
        List<Account> acc = [SELECT Id FROM Account WHERE Name = 'TestAccount3' LIMIT 1];

        Test.startTest();
        List<Map<String,Object>> currentLevelFields = CNT_CRM_LevelUp.getLevelProgression(acc[0].Id, 'Account', 4);
        Test.stopTest();

        System.assertEquals(3, currentLevelFields[0].get('Level'));
        System.assertEquals('Website', currentLevelFields[0].get('Field'));
        System.assertEquals(false, currentLevelFields[0].get('Completed'));
    }

    @isTest static void testCompletion() {
        List<Account> acc = [SELECT Id FROM Account WHERE Name = 'TestAccount4' LIMIT 1];

        Test.startTest();
        List<Map<String,Object>> currentLevelFields = CNT_CRM_LevelUp.getLevelProgression(acc[0].Id, 'Account', 4);
        Test.stopTest();

        System.assertEquals(4, currentLevelFields[0].get('Level'));
    }
}