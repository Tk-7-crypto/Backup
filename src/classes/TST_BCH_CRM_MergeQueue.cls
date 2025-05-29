@isTest
private class TST_BCH_CRM_MergeQueue {
    
    @testSetup
    static void setUpData() {
        List<Account> accList = new List<Account>();
        Account acc = UTL_TestData.createAccount();
        Account acc1 = UTL_TestData.createAccount();
        accList.add(acc);
        accList.add(acc1);
        insert accList;
        acc.LI_Account_Id__c = acc1.Id;
        acc.LQ_Account_Id__c = acc1.Id;
        update acc;
        Merge_Queue__c mergeQueue = UTL_TestData.createMergeQueue();
        mergeQueue.MasterRecordId__c = acc.Id;
        mergeQueue.Dupe_Id_1__c = acc1.Id;
        insert mergeQueue;
        upsert new Account_Setting__c(Exception_Email_Notifier__c = 'test@gmail.com');
        
    }
    
    static testmethod void test1() {
        BCH_CRM_MergeQueue mergeQueue = new BCH_CRM_MergeQueue();
        Test.startTest();
          Database.executeBatch(mergeQueue);
          mergeQueue.sendMailOnException(new List<String>());
        Test.stopTest();
    }

}