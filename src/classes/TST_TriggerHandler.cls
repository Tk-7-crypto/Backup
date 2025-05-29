/**
 * @author Vlad Tyazhov
 * Apex test for: DAO_TriggerHandler, DAO_TriggerHandlerProvider.
 */
@IsTest
private class TST_TriggerHandler {
    @IsTest
    static void testHandlerProvider() {
        DAO_TriggerHandlerProvider.setDebugMode(true);
        DAO_TriggerHandlerProvider.isDebugMode();
        DAO_TriggerHandlerProvider.setMockMetadata(new Trigger_Handler__mdt(
                DeveloperName = 'Account Billing',
                sObjectName__c = 'Account',
                HandlerName__c = 'TST_TriggerHandler.AccountBillingMockHandler'
        ));

        DAO_TriggerHandlerProvider.bypassSObjectType(Account.getSObjectType());
        DAO_TriggerHandlerProvider.clearBypass(Account.getSObjectType());
        DAO_TriggerHandlerProvider.bypassHandler(AccountBillingMockHandler.class);
        DAO_TriggerHandlerProvider.clearBypass(AccountBillingMockHandler.class);
        DAO_TriggerHandlerProvider.bypassHandler(AccountBillingMockHandler.class, TriggerOperation.AFTER_DELETE);
        DAO_TriggerHandlerProvider.bypassHandler(AccountBillingMockHandler.class, TriggerOperation.AFTER_DELETE);
        DAO_TriggerHandlerProvider.clearBypass(AccountBillingMockHandler.class, TriggerOperation.AFTER_DELETE);

        List<Account> accounts = new List<Account>();
        Map<Id, Account> accountMap = new Map<Id, Account>();
        for (TriggerOperation operation : TriggerOperation.values()) {
            executeOperation(accounts, accountMap, operation);
        }
    }

    @IsTest
    static void testError() {
        // given
        copado__User_Story__c us =  new copado__User_Story__c();
        insert us;

        // when - trying remove Id in existing record
        DAO_TriggerHandlerProvider.ApexLogException ex;
        Test.startTest();
        try {
            us.Id = null;
            update us;
        } catch(Exception e) {
            ex = new DAO_TriggerHandlerProvider.ApexLogException(e, null);
        }
        Test.stopTest();

        // then - verify that DML error was logged
        List<Apex_Error_Log__c> logs = [SELECT Id, Object__c, Source_Module__c, Error_Message__c FROM Apex_Error_Log__c];
        System.assertNotEquals(null, ex);
        System.assertEquals(1, logs.size());
        System.assertEquals('Copado', logs[0].Source_Module__c);
        System.assert(logs[0].Error_Message__c.contains('MISSING_ARGUMENT'));
//        System.assertEquals('copado__User_Story__c', logs[0].Object__c);
    }

    private static void executeOperation(List<SObject> sObjects, Map<Id, SObject> sObjectMap, TriggerOperation operation) {
        DAO_TriggerHandlerProvider.setMockTriggerContext(sObjects, sObjectMap, sObjects, sObjectMap, operation);
        DAO_TriggerHandlerProvider.execute();
    }

    public class AccountBillingMockHandler extends DAO_TriggerHandler {}
}