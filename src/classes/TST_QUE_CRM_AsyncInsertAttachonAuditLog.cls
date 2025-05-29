@isTest
private class TST_QUE_CRM_AsyncInsertAttachonAuditLog {
    
    @isTest
    public static  void test2() {
        User testUser = UTL_TestData.createUser(CON_CRM.SYSTEM_ADMIN_PROFILE,1)[0];
        insert testUser;
        List<User> userList = new List<User>();
        userList.add(testUser);	   
        List<User_Audit_Log__c> userAuditLogList = new List<User_Audit_Log__c>();
        User_Audit_Log__c userAuditLog = new User_Audit_Log__c();
        userAuditLog.User__c = testUser.id;
        userAuditLog.Field_Name__c = 'isActive';
        userAuditLog.Old_Value__c = 'true';
        userAuditLog.New_Value__c = 'false';          
        userAuditLogList.add(userAuditLog);
        insert userAuditLogList;
        
        Account testAcc = UTL_TestData.createAccount();
        insert testAcc;
        Contact testCon = UTL_TestData.createContact(testAcc.Id);
        List<Contact> conList = new List<Contact>{};
        conList.add(testCon);
        insert conList;
        Test.startTest();        
        System.enqueueJob(new QUE_CRM_AsyncInsertAttachonAuditLog(userAuditLogList, conList, conList, userList));
        //System.enqueueJob(new QUE_CRM_AsyncInsertAttachonAuditLog(userAuditLogList));
        Test.stopTest();
    }

}