@istest
public class TST_OrgREST {

    @istest
    private static void testRetrieveMethod(){
         string strNotifiTypeDevName ='NotificationBellForCaseComment';
        String strResourceQuery = 'tooling/query/?q=select+id,customNotifTypeName+from+CustomNotificationType+where+DeveloperName=\''+ strNotifiTypeDevName +'\'';
        test.startTest();
        OrgREST.retriveResult(strResourceQuery, 'GET', 'Test');
        Test.stopTest();
    }
    
}