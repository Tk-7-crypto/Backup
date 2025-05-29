@IsTest
private class TST_SCH_CSM_SendReminderForApproval {
    @TestSetup 
    static void setup() {
        List<Group> listOfGroup = new List<Group>();
        Group newGroup = new Group();
        newGroup.Name = 'Test_Group';
        listOfGroup.add(newGroup); 
        insert listOfGroup;
        
        List<User> listOfUser = UTL_TestData.createUser(CON_CSM.S_PROFILENAME, 2);
        listOfUser[1].Email = 'test@iqvia.com';
        insert listOfUser;
        
        GroupMember groupMember1 = new GroupMember( GroupId = newGroup.Id, UseroRGroupId =  listOfUser[0].Id);
        GroupMember groupMember2 = new GroupMember( GroupId = newGroup.Id, UseroRGroupId =  listOfUser[1].Id);
        insert new List<GroupMember>{groupMember1, groupMember2};
    }
    
    @IsTest
    private static void testBatch() {
        OneKey_Config__c oneKey = new OneKey_Config__c(OneKey_Request_1__c = '{"fields": [{"name": "individual.individualEid","values":[',
                                                       OneKey_Request_2__c = '],"codBase": [{0}"]}', Exact_Search_Method__c = '],"method": "EXACT"},',
                                                       Phonetic_Search_Method__c = '],"method": "PHONETIC"},', OneKey_Request_3__c = '{"name": "individual.firstNameLastName","values":[');
        insert oneKey;
        Test.setMock(HttpCalloutMock.class, new TST_Mock_WSC_CSM_OneKeyCaseVerification());
        CSM_Onekey_Email__c custsettObj1 = new CSM_Onekey_Email__c();
        custsettObj1.Public_Group_Name__c = 'Test_Group';
        custsettObj1.Template_Name__c = 'CAS_Onekey_ReminderForApproval';
        custsettObj1.From_Email_Address__c = 'no.reply.support@iqvia.com';
        insert custsettObj1;
        
        Case newCase1 = UTL_TestData.createCase();
        newCase1.status = 'Request for Approval';
        newCase1.Customer_Requested_Date__c = Date.today().addDays(21);
        Case newCase2 = UTL_TestData.createCase();
        newCase2.status = 'Request for Approval';
        newCase2.Customer_Requested_Date__c = Date.today().addDays(30);
        insert new List<Case>{newCase1, newCase2};
        
        Test.startTest();
            SCH_CSM_SendReminderForApproval btchQueue = new SCH_CSM_SendReminderForApproval();
            String sch = '0 00 10 * * ?';
            String jobID = System.schedule('SCH_CSM_SendReminderForApproval_Batch_Test', sch, btchQueue);
        Test.stopTest();
    }
}