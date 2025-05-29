/*
* Test class for FLOW- BEVFL01PSABillingEventRecordUpdate
*/
@IsTest
public class TST_BEVFL01PSABillingEventRecordUpdate {
    
    @isTest
    static void testProjectCodeUpdate(){
        pse__Proj__c parentproject = UTL_PSA_TestData.createProjects(1, false)[0];
        Id parentrecTypeId = UTL_PSA_TestData.lookupRecordTypeId('pse__Proj__c', CON_PSA.PROJ_REC_TYPE_RDS_PROJECT);  
        parentproject.recordTypeId = parentrecTypeId;
        parentproject.pse__Project_Status__c = 'Start-up';
        insert parentproject;
      
        pse__Proj__c project = UTL_PSA_TestData.createProjects(1, false)[0];
        Id recTypeId = UTL_PSA_TestData.lookupRecordTypeId('pse__Proj__c', CON_PSA.PROJ_REC_TYPE_RDS_SERVICELINE);  
        project.recordTypeId = recTypeId;
        project.pse__Project_Status__c = 'Start-up';
        project.pse__Parent_Project__c = parentproject.id;
        insert project;
        
        UTL_PSA_TestData.createPermissionControls();
       
        pse__Resource_Request__c resourcerequest = UTL_PSA_TestData.createResourceRequests(1, false)[0];
        resourceRequest.pse__Project__c = project.Id; 
        insert resourceRequest;

        pse__Billing_Event__c billingevent = new pse__Billing_Event__c();
        billingevent.pse__Project__c = parentproject.id;
        insert billingevent;
        String projectCode = billingevent.Project_Code__c;
        
        test.startTest();
        billingevent.pse__Project__c = project.id;
        update billingevent;
        test.stopTest();
        
        System.assertEquals(projectCode, billingevent.Project_Code__c, 'testProjectCodeUpdate');
    } 
}
