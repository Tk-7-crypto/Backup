@IsTest
public class TST_QUE_CRM_UnlockAccount {
    
    @IsTest
    public static void testUnlockAccount(){
        Account newAccount = UTL_TestData.createAccount();
        insert newAccount;
        Test.startTest();
        System.enqueueJob(new QUE_CRM_UnlockAccount(newAccount.Id));
        Test.stopTest();
    }
    
}