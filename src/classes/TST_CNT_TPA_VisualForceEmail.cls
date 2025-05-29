@isTest
public class TST_CNT_TPA_VisualForceEmail {
    public static Workflow_Email_Record__c objWorkFlowRecord;
    @testSetup static void setup() {
        objWorkFlowRecord = new Workflow_Email_Record__c(Email_Action__c = 'TPA_01_SendEmail', content_1__c = 'Main Content', Module_Name__c = 'TPA', isAttachmentRequired__c = TRUE, Attachment_Details__c = 'attName~~attId;');
        insert objWorkFlowRecord;
    }
    
    @isTest
    private static void testMethod1(){
        CNT_TPA_VisualForceEmail objCntTpaVfEmail = new CNT_TPA_VisualForceEmail();
        objCntTpaVfEmail.ObjRecId = [Select Id from Workflow_Email_Record__c LIMIT 1].Id;
        objCntTpaVfEmail.isReportAttach = false;
        String objWorkFlowRecordDetail  = objCntTpaVfEmail.getSendEmail();
    }
}