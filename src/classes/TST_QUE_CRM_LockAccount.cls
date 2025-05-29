@IsTest
public class TST_QUE_CRM_LockAccount {
    
    @IsTest
    public static void testLockAccount(){
        Account newAccount = UTL_TestData.createAccount();
        insert newAccount;
        Test.startTest();
        System.enqueueJob(new QUE_CRM_LockAccount(newAccount.Id));
        Test.stopTest();
    }
}