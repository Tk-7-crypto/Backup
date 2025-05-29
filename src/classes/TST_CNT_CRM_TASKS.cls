@IsTest
public class TST_CNT_CRM_TASKS {
	@IsTest
    public static void testGetTasks(){
        Account acc = UTL_TestData.createAccount();
        insert acc;
        Task task = UTL_TestData.createTask('Call', acc.Id, 'open', 'normal');
        insert task;
        List<Task> tasks = CNT_CRM_Tasks.getTasks(acc.Id);
        System.assertEquals(tasks.size() == 1, true);
    }
}