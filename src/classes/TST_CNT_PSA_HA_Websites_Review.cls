@isTest 
public class TST_CNT_PSA_HA_Websites_Review {
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
        
        HA_Websites_Review__c hr = new HA_Websites_Review__c();
        hr.Product__c = target.id;
        hr.Client_marketing_author_in_the_country__c = 'Yes';
        insert hr;    
    }
    testmethod static void testautoPopulateFields() {
        Test.startTest();
        pse__Proj__c prjRec = [select id from pse__Proj__c limit 1];
        Map<string,string> AutoPopulatedFieldDataMap = CNT_PSA_HA_Websites_Review.autoPopulateFields(prjRec.id);
        Test.stopTest();
        
    }
    testmethod static void testHasSDRunPermissionCreate() {
        Test.startTest();
        pse__Proj__c prjRec = [select id from pse__Proj__c limit 1];
        boolean result = CNT_PSA_HA_Websites_Review.hasHAPermissionCreate(prjRec.id);
        Test.stopTest();
        
    }
    testmethod static void testHasSDRunPermissionView() {
        Test.startTest();
        HA_Websites_Review__c hr = [select id from HA_Websites_Review__c limit 1];
        boolean result = CNT_PSA_HA_Websites_Review.hasHAPermissionEdit(hr.id);
        Test.stopTest();
        
    }
    testmethod static void testSdRunProjectIDView() {
        Test.startTest();
        HA_Websites_Review__c hr = [select id from HA_Websites_Review__c limit 1];
        string projID = CNT_PSA_HA_Websites_Review.haGetProjectId(hr.id);
        Test.stopTest();
        
    }
    
    testmethod static void testpopulateDate() {
        Test.startTest();
        Date d1 = Date.today();
        HA_Websites_Review__c hr = [select id from HA_Websites_Review__c limit 1];
        Date d2 = CNT_PSA_HA_Websites_Review.populateDate(d1);
        Test.stopTest();
        
    }
    testmethod static void testpopulatePublishDate() {
        Test.startTest();
        Date d1 = Date.today();
        Map<String,Date> hrDetail = new Map<String,Date>();
        HA_Websites_Review__c hr = [select id from HA_Websites_Review__c limit 1];
        hrDetail = CNT_PSA_HA_Websites_Review.populatePublishDateFields(hr.id);
        Test.stopTest();
        
    }
    
    testmethod static void testpopulateCountries() {
        Test.startTest();
        HA_Websites_Review__c hr = [select id from HA_Websites_Review__c limit 1];
        Target__c target = [select id from Target__c limit 1];
        String country = CNT_PSA_HA_Websites_Review.populateCountries(target.id);
        Test.stopTest();
        
    }
    testmethod static void testGetTargetRecords() {
        Test.startTest();
        pse__Proj__c prjRec = [select id from pse__Proj__c limit 1];
        List<Target__c> targetList = CNT_PSA_HA_Websites_Review.getTargetRecords(prjRec.id);
        Test.stopTest();
        
    }  
    testmethod static void testHasRDSAdminPermission() {
        Test.startTest();
        HA_Websites_Review__c hr = [select id from HA_Websites_Review__c limit 1];
        Boolean hasPermission = CNT_PSA_HA_Websites_Review.hasRDSAdminPermission(hr.id);
        Test.stopTest();
        
    }
} 
