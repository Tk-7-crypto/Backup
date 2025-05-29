@IsTest
public class TST_CNT_CRM_Other_MQL_Tasks {
    @IsTest
    static void testGetTaskDetails(){

        Account acc = UTL_TestData.createAccount();
        insert acc;
        Contact cont = UTL_TestData.createContact(acc.Id);
        insert cont;
        
        List<Task> mqlTasks = new List<Task>();
        
        Id RecordTypeIdTask = Schema.SObjectType.Task.getRecordTypeInfosByName().get('MQL Task').getRecordTypeId();
        
        mqlTasks.add(UTL_TestData.createTask(cont.Id, 'Not Started', 'Normal', 'Call', RecordTypeIdTask));
        mqlTasks.add(UTL_TestData.createTask(cont.Id, 'Not Started', 'Normal', 'Call', RecordTypeIdTask));
        mqlTasks.add(UTL_TestData.createTask(cont.Id, 'Not Started', 'Normal', 'Call', RecordTypeIdTask));

        insert mqlTasks;
		System.debug(mqlTasks.get(0).RecordType.DeveloperName);
        
		List<Task> tasks = CNT_CRM_Other_MQL_Tasks.getTaskDetails(mqlTasks.get(0).Id);
        System.assertEquals(tasks.size(), 2);
    }
}