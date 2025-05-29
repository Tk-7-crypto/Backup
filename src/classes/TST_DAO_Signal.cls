@isTest
public class TST_DAO_Signal{
    @testSetup static void setup() {
        UTL_PSA_TestData.createPermissionControls();
        
        Program__c program = new Program__c(Name = 'TestProgram');
        insert program;
        
        Service_Line__c serviceline = new Service_Line__c(
            Name = 'Signal Management',
            Active__c=true,
            Service_Line_Code__c = 'SM');
        insert serviceline;
        
        //contacts
        RecordType contactRT = [SELECT Id from RecordType where Name='IQVIA User Contact'];
        Contact testResource = UTL_PSA_TestData.createResources(1,false)[0];
        testResource.RecordTypeId = contactRT.Id;
        testResource.pse__Salesforce_User__c = UserInfo.getUserId();
        testResource.Location_Code_text__c = 'USDUR1';
        insert testResource;
        
        
        // Parent Project
        pse__Proj__c parentproject = UTL_PSA_TestData.createProjects(1, false)[0];
        Id parentrecTypeId = UTL_PSA_TestData.lookupRecordTypeId('pse__Proj__c', CON_PSA.PROJ_REC_TYPE_RDS_PROJECT);
        parentproject.recordTypeId = parentrecTypeId;
        parentproject.pse__Project_Status__c = 'Start-up';
        parentproject.Program__c = program.id;
        insert parentproject;
        
        pse__Proj__c project = UTL_PSA_TestData.createProjects(1, false)[0];
        Id recTypeId = UTL_PSA_TestData.lookupRecordTypeId('pse__Proj__c', CON_PSA.PROJ_REC_TYPE_RDS_SERVICELINE);
        project.recordTypeId = recTypeId;
        project.pse__Project_Status__c = 'Start-up';
        project.pse__Parent_Project__c = parentproject.Id;
        project.Service_Line__c = serviceline.Id;
        insert project;
        
        Id targetRecordTypeId = UTL_PSA_TestData.lookupRecordTypeId('Target__c', CON_PSA.TARGET_REC_TYPE_RDS_PRODUCT_LINE);
        Target__c target = new Target__c(
            recordTypeId=targetRecordTypeId,
            Name='Test Target',
            API__c='Test API',
            Strength__c='Super strong',
            Dosage_Form__c='Huge pill',
            Program__c=program.Id,
            Inactivated_Date__c = system.today(),
            Date_Activated__c = System.today(),
            Countries_NA__c = true
        );
        insert target;
        try{
            Signal__c sig = new Signal__c();
            sig.project__c = project.id;
            sig.Source_or_Trigger_of_Signal__c = 'FAERS';
            sig.Date_Detected__c = Date.newInstance(2030, 4, 5);
            sig.Validation_Date__c = Date.newInstance(2030, 3, 4);
            sig.Date_Medical_Review_Completed_SVF__c = Date.newInstance(2030, 3, 4);
            sig.Date_BRM_Review_Completed_SVF__c = Date.newInstance(2030, 3, 4);
            sig.Date_QC_Completed_SVF__c = Date.newInstance(2030, 3, 4);
            sig.Date_Closed_Evaluation_Completed__c = Date.newInstance(2030, 3, 4);
            sig.Date_BRM_Review_Completed_SER__c = Date.newInstance(2030, 3, 4);
            sig.Date_QC_Completed_SER__c = Date.newInstance(2030, 3, 4);
            sig.Dt_Transfer_of_Resp_for_Impl_of_Actions__c = Date.newInstance(2030, 3, 4);
            insert sig;
        }
        catch (DMLException ex) {
            Signal__c sigRec = new Signal__c();
            sigRec.project__c = project.id;
            sigRec.Source_or_Trigger_of_Signal__c = 'FAERS';
            sigRec.Product__c = target.Id;
            sigRec.Date_Detected__c = Date.newInstance(2020, 3, 4);
            sigRec.Signal_Term__c = 'Test';
            sigRec.SM_Service_Line_Lead_New__c = testResource.id;
            sigRec.Incl_Signal_Val_in_Metrics_Invoices__c = 'Yes';
            sigRec.Signal_Validation_Complexity__c = 'Simple';
            sigRec.Incl_Signal_Eval_in_Metrics_Invoices__c = 'Yes';
            insert sigRec;
            Signal__c sigRecord = [select id from Signal__c limit 1];
            sigRecord.Source_or_Trigger_of_Signal__c = 'FAERS';
            update sigRecord;
        }
    }
    testmethod static void testSignalTrigger() {
        Test.startTest();
        pse__proj__c project = [select id from pse__Proj__c limit 1];
        Target__c target = [select id from target__c limit 1];
        Contact testResource = [select id from contact limit 1];
        Signal__c sigRec = new Signal__c();
        sigRec.project__c = project.id;
        sigRec.Source_or_Trigger_of_Signal__c = 'FAERS';
        sigRec.Product__c = target.Id;
        sigRec.Date_Detected__c = Date.newInstance(2020, 3, 4);
        sigRec.Signal_Term__c = 'Test';
        sigRec.SM_Service_Line_Lead_New__c = testResource.id;
        sigRec.Incl_Signal_Val_in_Metrics_Invoices__c = 'Yes';
        sigRec.Signal_Validation_Complexity__c = 'Simple';
        sigRec.Incl_Signal_Eval_in_Metrics_Invoices__c = 'Yes';
        insert sigRec;  
        delete sigRec;        
        Test.stopTest();
        
    }
    
}
