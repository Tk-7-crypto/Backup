@IsTest
public class TST_CNT_CRM_MQL_Tasks {
	@IsTest
    public static void testGetTasks(){
        Account acc = UTL_TestData.createAccount();
        insert acc;
        Task task = UTL_TestData.createTask('Call', acc.Id, 'open', 'normal');
        insert task;
        CNT_CRM_MQL_Tasks.TasksWrapper taskWrapper = CNT_CRM_MQL_Tasks.getTasks();
        System.assertEquals(taskWrapper.tasks.size() == 0, true);
    }
}