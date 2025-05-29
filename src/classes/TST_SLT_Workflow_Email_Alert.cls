@isTest
public class TST_SLT_Workflow_Email_Alert {
    
    public static Workflow_Email_Record__c objWorkFlowRecord;
    @testSetup 
    static void setup() {
        objWorkFlowRecord = new Workflow_Email_Record__c(Email_Action__c = 'CDA_01_SendEmail', content_1__c = 'Main Content', Module_Name__c = 'CDA', isAttachmentRequired__c = false, Attachment_Details__c = '');
        insert objWorkFlowRecord;
    }
    
    static testMethod void testWorkFlow() 
    {
        List<Schema.SObjectField> WorkflowList = new SLT_Workflow_Email_Alert().getSObjectFieldList();
        Schema.SObjectType objWorkFlowEmail = new SLT_Workflow_Email_Alert(true).getSObjectType();
        
        Integer expected = 0;
        System.assertEquals(expected, workflowList.size());
    } 
    
    @IsTest
    static void testGetSObject () 
    {
        Test.startTest();
        SLT_Workflow_Email_Alert sltworkflow = new SLT_Workflow_Email_Alert(true,true);
        sltworkflow.getSObjectType();
        Test.stopTest();
    }
    
    @IsTest
    static void testselectWorkflowsByIdSet() 
    {
        setup();
        Test.startTest();
        Set<String> fieldSet = new Set<String>{'id'};
        Map<Id, Workflow_Email_Record__c> idtoWorkflow = new SLT_Workflow_Email_Alert().selectWorkflowsByIdSet(new Set<Id> {objWorkFlowRecord.id}, fieldSet );
        Test.stopTest();
    }
}
