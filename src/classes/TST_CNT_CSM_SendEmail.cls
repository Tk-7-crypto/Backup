@isTest
public class TST_CNT_CSM_SendEmail {
    @testsetup
    static void setupData(){
        
    }
    
    static testMethod void testGetSendEmail(){
        Test.startTest();
        
        Case c = UTL_TestData.createCase();
        insert c;
        
        Workflow_Email_Record__c record = new Workflow_Email_Record__c();
        record.Content_1__c = '<html><body>Test</body></html>';
        record.Email_Action__c = 'CSM_01_SendEmail';
        record.Module_Name__c = 'CSM';
        record.Related_To_Object_Api__c = 'Case';
        record.Related_To_Object_Id__c = c.Id;
        record.To_Email_1__c = 'abc@mail.com';
        insert record;
        Test.stopTest();
        
        CNT_CSM_SendEmail cntEmail = new CNT_CSM_SendEmail();
        cntEmail.ObjRecId = record.Id;
        System.assert(cntEmail.getSendEmail()!=null, true);
    }
} 