@isTest
public class TST_CNT_CDA_VisualForceEmail { 
	public static Workflow_Email_Record__c objWorkFlowRecord;
    @testSetup 
    static void setup() {
        objWorkFlowRecord = new Workflow_Email_Record__c(Email_Action__c = 'CDA_01_SendEmail', content_1__c = 'Main Content', Module_Name__c = 'CDA', isAttachmentRequired__c = false, Attachment_Details__c = '');
        insert objWorkFlowRecord;
    }
    
    @isTest
    private static void testMethod1(){
        CNT_CDA_VisualForceEmail objCntTpaVfEmail = new CNT_CDA_VisualForceEmail();
        objCntTpaVfEmail.ObjRecId = [Select Id from Workflow_Email_Record__c LIMIT 1].Id;
        objWorkFlowRecord = objCntTpaVfEmail.getSendEmail();
    }
}