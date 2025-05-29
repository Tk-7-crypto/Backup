/**
* This test class is used to test all methods in UTL_CRM_SendEmail class.
* version : 1.0
*/
@isTest
public class TST_UTL_CRM_SendEmail {
    
    @testsetup
    static void setupData(){
        
    }
    
    static testMethod void testSendEmailThroughWorkflow() {
        
        Test.startTest();
        Lead lead = UTL_TestData.createLead();
        insert lead;
        
        EmailTemplate template = [select id from EmailTemplate  where Name = 'CRM Send Email By Workflow' limit 1];
        
        Test.stopTest();
        
        List<UTL_CRM_SendEmail.MessageWrapper> messageList = new List<UTL_CRM_SendEmail.MessageWrapper>();
        UTL_CRM_SendEmail.MessageWrapper message = new UTL_CRM_SendEmail.MessageWrapper();
        message.toEmails = new List<String>{'xyz@abc.com'};
            message.ccEmails = new List<String>{'abc@abc.com'};
                message.staticContent = '<html><body>Test Email</body></html>';
        message.subject = 'Test Mail';
        message.whatId = lead.Id;
        messageList.add(message);
        
        message = new UTL_CRM_SendEmail.MessageWrapper();
        message.toUserIds = new List<String>{UserInfo.getUserId()};
        message.ccUserIds = new List<String>{UserInfo.getUserId()};
        message.targetObjectId = lead.Id;
        message.isTargetObjectAsRecipient = false;
        message.templateId = template.Id;
        messageList.add(message);

        UTL_CRM_SendEmail.sendEmailThroughWorkflow(messageList);

        List<Workflow_Email_Record__c> records = [Select Id from Workflow_Email_Record__c];
        System.assertEquals(records.size(), 2); 
    }
    
    static testMethod void testsetWorkflowParameter(){
        Test.startTest();
        Lead lead = UTL_TestData.createLead();
        insert lead;
        UTL_CRM_SendEmail.MessageWrapper message = new UTL_CRM_SendEmail.MessageWrapper();
        Workflow_Email_Record__c record = new Workflow_Email_Record__c();
        
        message.whatId = lead.Id;
        message.toEmails = new List<String>{'xyz@abc.com'};
		message.ccEmails = new List<String>{'abc@abc.com'};
            message.toUserIds = new List<String>{UserInfo.getUserId()};
                message.ccUserIds = new List<String>{UserInfo.getUserId()};
		UTL_CRM_SendEmail.setWorkflowParameter(record, message);
        Test.stopTest();
        
        System.assertEquals(record.To_Email_1__c, 'xyz@abc.com');
        System.assertEquals(record.To_Email_2__c, 'abc@abc.com');
        System.assertEquals(record.To_User_1__c, UserInfo.getUserId());
        System.assertEquals(record.To_User_2__c, UserInfo.getUserId());
        System.assertEquals(record.Related_To_Object_Id__c, lead.Id);
        System.assertEquals(record.Related_To_Object_Api__c, 'Lead');
        System.assertEquals(record.Module_Name__c, 'CRM');
        System.assertEquals(record.Email_Action__c, 'CRM_01_SendEmail');
     }
    
    static testMethod void testIsValidEmailId(){
        System.assertEquals(UTL_CRM_SendEmail.isValidEmailId('xyz@abc.com'), true);
        System.assertEquals(UTL_CRM_SendEmail.isValidEmailId('xy___33z@abc.com'), true); 
        System.assertEquals(UTL_CRM_SendEmail.isValidEmailId('@abc.com'), false); 
        System.assertEquals(UTL_CRM_SendEmail.isValidEmailId('abc.com'), false); 
    }
}