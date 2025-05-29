@isTest
public class TST_CNT_CRM_VisualForceEmail {

    @testsetup
    static void setupData(){
        
    }
    
    static testMethod void testGetSendEmail(){
        Test.startTest();
        
        Lead lead = UTL_TestData.createLead();
        insert lead;
        
        Workflow_Email_Record__c record = new Workflow_Email_Record__c();
        record.Content_1__c = '<html><body>Test</body></html>';
        record.Email_Action__c = 'CRM_01_SendEmail';
        record.Module_Name__c = 'CRM';
        record.Related_To_Object_Api__c = 'Lead';
        record.Related_To_Object_Id__c = lead.Id;
        record.To_Email_1__c = 'abc@mail.com';
        insert record;
        Test.stopTest();
        
        CNT_CRM_VisualForceEmail cntEmail = new CNT_CRM_VisualForceEmail();
        cntEmail.ObjRecId = record.Id;
        System.assert(cntEmail.getSendEmail()!=null, true);
    }
}