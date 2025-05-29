@isTest
private class TST_DAOH_Agreement_Email_Alert {

    @testSetup
    static void dataSetup(){
        List<User> users = UTL_TestData.createUser('RDS User', 1);
        users[0].Email = 'test@Iqvia.com';
        insert users;
        Agreement_Email_Alert__c emailAlert = new Agreement_Email_Alert__c();
        emailAlert.Alerting_Email__c = 'test@test.com';
        insert emailAlert;
    }
    
    @isTest
    static void test(){
        User user = [select Id from User where Email = 'test@Iqvia.com' limit 1];
        Agreement_Email_Alert__c emailAlert = [Select Id from Agreement_Email_Alert__c limit 1];
        System.runAS(user){
            Test.startTest();
            Try{
                update emailAlert;
            }catch(Exception e){}
            Test.stopTest();
        }
    }
}