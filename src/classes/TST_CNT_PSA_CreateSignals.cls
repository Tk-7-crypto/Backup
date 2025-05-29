@isTest
public class TST_CNT_PSA_CreateSignals {

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
        Date_Activated__c = system.today(),
        Countries_NA__c = true
        );
        insert target;
        
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
    }
    testmethod static void testautoPopulateFields() {
        Test.startTest();
        pse__Proj__c prjRec = [select id, pse__Parent_Project__r.Project_Code__c from pse__Proj__c limit 1];
        Map<string,string> AutoPopulatedFieldDataMap = CNT_PSA_CreateSignals.autoPopulatedFieldData(prjRec.id);
        System.assertEquals(AutoPopulatedFieldDataMap.get('projectCode'), prjRec.pse__Parent_Project__r.Project_Code__c);
        Test.stopTest();
        
    }
    testmethod static void testHasSignalPermissionCreate() {
        PermissionSet ps = [SELECT ID From PermissionSet WHERE Name = 'RDS_Project_Manager_and_Functional_Lead'];
        List<PermissionSetAssignment> psaList = [Select id from PermissionSetAssignment where AssigneeId =:UserInfo.getUserId() AND PermissionSetId =:ps.Id];
        List<User> userList = UTL_OWF_TestData.createUser('System Administrator', 1);
            userList[0].FirstName = 'TestRunner';
            userList[0].SUBREGION__c = 'United States of America';
            userList[0].IsActive = true;
        insert userList;
        insert new PermissionSetAssignment(AssigneeId =userList[0].Id,PermissionSetId = ps.Id);
        system.RunAs(userList[0])
        {
        Test.startTest();
        pse__Proj__c prjRec = [select id from pse__Proj__c limit 1];
        boolean result = CNT_PSA_CreateSignals.hasSignalPermissionCreate(prjRec.id);
        Test.stopTest();
        }
    }
    testmethod static void testHasSignalPermissionView() {
        PermissionSet ps = [SELECT ID From PermissionSet WHERE Name = 'RDS_Project_Manager_and_Functional_Lead'];
        List<PermissionSetAssignment> psaList = [Select id from PermissionSetAssignment where AssigneeId =:UserInfo.getUserId() AND PermissionSetId =:ps.Id];
        List<User> userList = UTL_OWF_TestData.createUser('System Administrator', 1);
            userList[0].FirstName = 'TestRunner';
            userList[0].SUBREGION__c = 'United States of America';
            userList[0].IsActive = true;
        insert userList;
        insert new PermissionSetAssignment(AssigneeId =userList[0].Id,PermissionSetId = ps.Id);
        system.RunAs(userList[0]){
        Test.startTest();
        boolean result = CNT_PSA_CreateSignals.hasSignalPermissionView();
        Test.stopTest();
        }
    }
    testmethod static void testSignalGetProjectId() {
        Test.startTest();
        Signal__c sig = [select id from Signal__c limit 1];
        string projID = CNT_PSA_CreateSignals.signalGetProjectId(sig.id);
        Test.stopTest();
        
    }
    testmethod static void testGetTargetRecords() {
        Test.startTest();
        pse__Proj__c prjRec = [select id from pse__Proj__c limit 1];
        List<Target__c> targetList = CNT_PSA_CreateSignals.getTargetRecords(prjRec.id);
        Test.stopTest();
    } 

    testmethod static void testGetEvalDate() {
        Test.startTest();
        CNT_PSA_CreateSignals.populateEvalDueDate('Low',System.today());
        CNT_PSA_CreateSignals.populateEvalDueDate('Medium',System.today());
        CNT_PSA_CreateSignals.populateEvalDueDate('High',System.today());
        CNT_PSA_CreateSignals.populateEvalDueDate('Custom',System.today());
        CNT_PSA_CreateSignals.populateEvalDueDate('',System.today());
        CNT_PSA_CreateSignals.hasSignalPermissionView();
        Test.stopTest();
    } 

    testmethod static void testHasRDSAdminPermission() {
        Test.startTest();
        Signal__c sig = [select id from Signal__c limit 1];
        Boolean hasPermission = CNT_PSA_CreateSignals.hasRDSAdminPermission(sig.id);
        Test.stopTest();
    }

    testmethod static void testPopulateSignalStatusValue() {
        Test.startTest();
        Date d1 = Date.today();
        Date d2 = null;
        String vOutcome1 = 'Signal Validated';
        String vOutcome2 = 'Signal Not Validated(Specify Reason)';
        string signalStatus1 = CNT_PSA_CreateSignals.populateSignalStatusValue(d1,vOutcome1);
        string signalStatus2 = CNT_PSA_CreateSignals.populateSignalStatusValue(d2,vOutcome1);
        string signalStatus3 = CNT_PSA_CreateSignals.populateSignalStatusValue(d2,vOutcome2);
        Test.stopTest();
    }
} 
