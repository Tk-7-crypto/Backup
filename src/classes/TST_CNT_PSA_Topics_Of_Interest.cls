@isTest 
public class TST_CNT_PSA_Topics_Of_Interest {
    @testSetup static void setup() {
        Topics_of_Interest__c toiRecord = UTL_PSA_TestData.createTopicOfInterest(1);
           insert toiRecord;   
    }
    testmethod static void testautoPopulateFields() {
        Test.startTest();
        //pse__Proj__c prjRec = [select id from pse__Proj__c limit 1];
        pse__Proj__c prjRec = [select id from pse__Proj__c where Service_Line__r.name =  'Signal Management' limit 1];
        Map<string,string> AutoPopulatedFieldDataMap = CNT_PSA_Topics_Of_Interest.autoPopulateFields(prjRec.id);
        Test.stopTest();
        
    }
    testmethod static void testhasToiPermissionCreate() {
        Test.startTest();
        pse__Proj__c prjRec = [select id from pse__Proj__c limit 1];
        boolean result = CNT_PSA_Topics_Of_Interest.hasHAPermissionCreate(prjRec.id);
        Test.stopTest();
        
    }
    testmethod static void testHasToiPermissionEdit() {
        Test.startTest();
        Topics_of_Interest__c toi = [select id from Topics_of_Interest__c limit 1];
        boolean result = CNT_PSA_Topics_Of_Interest.hasTOIPermissionEdit(toi.id);
        Test.stopTest();
        
    }
    testmethod static void testToiProjectGetId() {
        Test.startTest();
        Topics_of_Interest__c toi = [select id from Topics_of_Interest__c limit 1];
        string projID = CNT_PSA_Topics_Of_Interest.haGetProjectId(toi.id);
        Test.stopTest();
        
    }
    
    testmethod static void testpopulateStatus() {
        Test.startTest();
        Date d1 = Date.today();
        Date d2 = Date.today()+1;
        String status = CNT_PSA_Topics_Of_Interest.populateStatus(d1,d2);
        String status2 = CNT_PSA_Topics_Of_Interest.populateStatus(d1,null);
        String status3 = CNT_PSA_Topics_Of_Interest.populateStatus(null,null);
        Test.stopTest();
        
    }
    
    testmethod static void testgetTargetRecords() {
        Test.startTest();
        pse__Proj__c prjRec = [select id from pse__Proj__c where Service_Line__r.name =  'Signal Management' limit 1];
        List<Target__c> targetList = CNT_PSA_Topics_Of_Interest.getTargetRecords(prjRec.id);
        Test.stopTest();
    }
    testmethod static void testHasRDSAdminPermission() {
        Test.startTest();
        Topics_of_Interest__c toi = [select id from Topics_of_Interest__c limit 1];
        Boolean hasPermission = CNT_PSA_Topics_Of_Interest.hasRDSAdminPermission(toi.id);
        Test.stopTest();
        
    }
    testmethod static void testcloneTOIRecord() {
        Test.startTest();
        Topics_of_Interest__c toi = [select id from Topics_of_Interest__c limit 1];
        Target__c target = [select id from Target__c limit 1];
        list<id> targetIdList = new List<id>();
        targetIdList.add(target.id);
        Map<String, String> cloneMap = new Map<String, String>();
        cloneMap.put('Internal_Comments__c','true');
        cloneMap.put('Date_Started__c','2021-08-06');
        cloneMap.put('Date_Reminder_Calendar__c','2021-08-06');
        
        string recordID = CNT_PSA_Topics_Of_Interest.cloneTOIRecord(toi.id,targetIdList,cloneMap);
        targetIdList.clear();
        string recordID2 = CNT_PSA_Topics_Of_Interest.cloneTOIRecord(toi.id,targetIdList,cloneMap);
        Test.stopTest();
        
    }
    
    testmethod static void testcreateTOIRecord() {
        Test.startTest();
        
        UTL_PSA_TestData.createPermissionControls();
        
        Program__c program = UTL_PSA_TestData.programs[0];
        Account account = UTL_PSA_TestData.accounts[0];
        Service_Line__c serviceline = [Select Id, Name from Service_Line__c where Service_Line_Code__c = 'SM'];
        //insert serviceline;
        
        //contacts
        /*RecordType contactRT = [SELECT Id from RecordType where Name='IQVIA User Contact'];
        Contact testResource = UTL_PSA_TestData.createResources(1,false)[0];
        testResource.RecordTypeId = contactRT.Id;
        testResource.pse__Salesforce_User__c = UserInfo.getUserId();
        testResource.Location__c = 'USDUR1';
        insert testResource;*/
        
        
        // Parent Project
        pse__Proj__c parentproject = UTL_PSA_TestData.createProjects(1, false)[0];
        Id parentrecTypeId = UTL_PSA_TestData.lookupRecordTypeId('pse__Proj__c', CON_PSA.PROJ_REC_TYPE_RDS_PROJECT);
        parentproject.recordTypeId = parentrecTypeId;
        parentproject.pse__Project_Status__c = 'Start-up';
        parentproject.Actual_Go_Live_Date__c = System.today();
        parentproject.Go_Live_Date__c = System.today();
        parentproject.Program__c = program.id;
        insert parentproject;
        
        pse__Proj__c project = UTL_PSA_TestData.createProjects(1, false)[0];
        Id recTypeId = UTL_PSA_TestData.lookupRecordTypeId('pse__Proj__c', CON_PSA.PROJ_REC_TYPE_RDS_SERVICELINE);
        project.recordTypeId = recTypeId;
        project.pse__Project_Status__c = 'Start-up';
        project.pse__Parent_Project__c = parentproject.Id;
        project.Service_Line__c = serviceline.Id;
        project.Go_Live_Date__c = System.today();
        insert project;
        
        Target__c target = [select id from Target__c limit 1];
        list<id> targetIdList = new List<id>();
        targetIdList.add(target.id);
        Map<String, String> cloneMap = new Map<String, String>();
        cloneMap.put('Account__c',account.id);
        cloneMap.put('project__c',project.id);
        cloneMap.put('Status__c','New');
        cloneMap.put('Topic_Term__c','Test');
        cloneMap.put('Topic_Category__c','Potential Risk (important)');
        cloneMap.put('Search_Variable_in_Data_Source__c','Adverse Events');
        cloneMap.put('Type_of_MedDRA_Query__c','HLGT');
        cloneMap.put('MedDRA_Search_Specifications__c','Test');
        cloneMap.put('Date_Started__c','2021-08-06');
        cloneMap.put('Date_Reminder_Calendar__c','2021-08-06');
        cloneMap.put('Part_of_Additional_RMM__c','No');
        cloneMap.put('In_RMP__c','No');
        cloneMap.put('Part_of_Commitment_to_HA__c','No');
        cloneMap.put('Rationale_Started__c','test');    
        cloneMap.put('Internal_Comments__c','true');
        cloneMap.put('Document_Name_1__c','test');
        cloneMap.put('Document_Link_1__c','test');
        string recordID = CNT_PSA_Topics_Of_Interest.createTOIRecord(targetIdList,cloneMap);
        Test.stopTest();
        
    }
}
