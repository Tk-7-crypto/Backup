@isTest
public class TST_EmailDataWrapper {

    @isTest
    private static void testEmailDataWrapper() {
        EmailDataWrapper wrapper = new EmailDataWrapper();
        
        Test.startTest();
        	wrapper.toAddressList = new List<String>{'ABC'};
            wrapper.senderDisplayName ='Test';
        	wrapper.body = 'body';
        	wrapper.subject = 'subject';
        Test.stopTest();

        System.assertNotEquals(true, wrapper.toAddressList.isEmpty(), 'toAddressList must not be empty.');
    }
}