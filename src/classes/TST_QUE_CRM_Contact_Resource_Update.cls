@isTest
private  class TST_QUE_CRM_Contact_Resource_Update {
    
    @isTest
    public static  void test() {
        Account testAcc = UTL_TestData.createAccount();
        insert testAcc;
        Contact testCon = UTL_TestData.createContact(testAcc.Id);
        Contact testCon1 = UTL_TestData.createContact(testAcc.Id);
        List<Contact> conList = new List<Contact>{};
        conList.add(testCon);
        conList.add(testCon1);
        insert conList;
        
        User testUser = UTL_TestData.createUser(CON_CRM.SYSTEM_ADMIN_PROFILE,1)[0];
        List<User> userList = new List<User>();
        userList.add(testUser);
             
        Test.startTest();  
        System.enqueueJob(new QUE_CRM_Contact_Resource_Active_Updated(conList,conList,userList));
        Test.stopTest();
    }
    
    @isTest
    public static  void test2() {
  
        Account testAcc = UTL_TestData.createAccount();
        insert testAcc;
        
        Contact testCon = UTL_TestData.createContact(testAcc.Id);
        Contact testCon2 = UTL_TestData.createContact(testAcc.Id);
        List<Contact> conList = new List<Contact>{};
        conList.add(testCon);
        conList.add(testCon2);
        insert conList;
        
        User testUser = UTL_TestData.createUser(CON_CRM.SYSTEM_ADMIN_PROFILE,1)[0];
        testUser.EmployeeNumber = '99887766';
        User testUser2 = UTL_TestData.createUser(CON_CRM.SYSTEM_ADMIN_PROFILE,1)[0];
        testUser2.EmployeeNumber = '99887755';
        List<User> userList = new List<User>();
        userList.add(testUser);
        userList.add(testUser2);
        
        Test.startTest();
        insert userList;
        testCon.Salesforce_User__c = testUser.Id;
        testCon.EmployeeNumber__c = '99887766';
        testCon.LastName = '';
        
        testCon2.Salesforce_User__c = testUser2.Id;
        testCon2.EmployeeNumber__c = '99887755';
        testCon2.LastName = '';
        
        Map<Id,Contact> userIdToContactMap = new Map<Id, Contact>(); 
        userIdToContactMap.put(testUser.Id,testCon);
        userIdToContactMap.put(testUser2.Id,testCon2);
		
		Survey_Setting__c surveySetting = new Survey_Setting__c(Survey_Error_Email_Ids__c = 'test@gmail.com');
        insert surveySetting;
        
        List<Database.UpsertResult> updateResultsList = Database.upsert(conList, false);
        new QUE_CRM_Contact_Resource_Active_Updated(conList, userIdToContactMap, userList).upsertContactExceptionHandling(updateResultsList);
        Test.stopTest();
    }
}