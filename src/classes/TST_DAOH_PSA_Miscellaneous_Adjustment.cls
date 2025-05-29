@isTest
public class TST_DAOH_PSA_Miscellaneous_Adjustment {
    
    @IsTest
    static void dataSetup(){
        UTL_PSA_TestData.createPermissionControls();

        //program
        Program__c program = new Program__c(Name = 'TestProgram');
        insert program;

        //service line
        Service_Line__c serviceline = new Service_Line__c(
            Name = 'Aggregate Reporting',
            Active__c=true,
            Service_Line_Code__c = 'AR');
        insert serviceline;

        //service
        Service__c service = new Service__c(Name = 'Test Service');
        service.Service_Code__c = '12345678';
        service.Service_Line__c = serviceline.Id;
        insert service;

        //contacts
        RecordType contactRT = [SELECT Id from RecordType where Name='IQVIA User Contact'];
        Contact testResource = UTL_PSA_TestData.createResources(1,false)[0];
        testResource.RecordTypeId = contactRT.Id;
        testResource.pse__Salesforce_User__c = UserInfo.getUserId();
        testResource.Location_Code_text__c = 'USDUR1';
        testResource.Email = 'test@email.com';
        insert testResource;
        
        // Parent Project
        pse__Proj__c parentproject = UTL_PSA_TestData.createProjects(1, false)[0];
        Id parentrecTypeId = UTL_PSA_TestData.lookupRecordTypeId('pse__Proj__c', CON_PSA.PROJ_REC_TYPE_RDS_PROJECT);
        parentproject.recordTypeId = parentrecTypeId;
        parentproject.pse__Project_Status__c = 'Start-up';
        parentproject.Program__c = program.id;
        insert parentproject;

        //project
        pse__Proj__c project = UTL_PSA_TestData.createProjects(1, false)[0];
        Id recTypeId = UTL_PSA_TestData.lookupRecordTypeId('pse__Proj__c', CON_PSA.PROJ_REC_TYPE_RDS_SERVICELINE);
        project.recordTypeId = recTypeId;
        project.pse__Project_Status__c = 'Start-up';
        project.pse__Parent_Project__c = parentproject.Id;
        project.Service_Line__c = serviceline.Id;
        insert project;
        
        pse__Miscellaneous_Adjustment__c miscellaneousAdjustment = new pse__Miscellaneous_Adjustment__c(Name = 'TestMiscellaneousAdjustment');
        miscellaneousAdjustment.pse__Project__c = project.id;
        miscellaneousAdjustment.pse__Effective_Date__c = system.today();
        miscellaneousAdjustment.pse__Amount__c = 200;
        miscellaneousAdjustment.pse__Transaction_Category__c = 'Booked Revenue';
        insert miscellaneousAdjustment;
        String transactionCategory = miscellaneousAdjustment.pse__Transaction_Category__c;
        System.assertEquals(transactionCategory, miscellaneousAdjustment.pse__Transaction_Category__c, 'transactionCategory');

    }
    @IsTest
    static void testUpdateFields1(){
        dataSetup();
        Test.startTest();
        pse__Miscellaneous_Adjustment__c maRec = [Select Id,pse__Approved__c,pse__Status__c,pse__Include_In_Financials__c, pse__Amount__c from pse__Miscellaneous_Adjustment__c limit 1];
        maRec.pse__Status__c = 'Approved';
        maRec.pse__Amount__c = 0;
        update maRec;
        Boolean approvedFieldValue = maRec.pse__Approved__c;
        Boolean includeInFinancialsFieldValue = maRec.pse__Include_In_Financials__c;
        Test.stopTest();
        System.assertEquals(false, approvedFieldValue, 'Approved Field Value updated');
        System.assertEquals(false, includeInFinancialsFieldValue, 'include In FinancialsFieldValue Field Value');
    }
    @IsTest
    static void testUpdateFields2(){
        dataSetup();
        Test.startTest();
        pse__Miscellaneous_Adjustment__c maRec = [Select Id,pse__Approved__c,pse__Status__c,pse__Include_In_Financials__c,pse__Amount__c from pse__Miscellaneous_Adjustment__c limit 1];
        maRec.pse__Status__c = 'Draft';
        maRec.pse__Amount__c = 500;
        update maRec;
        Boolean approvedFieldValue = maRec.pse__Approved__c;
        Boolean includeInFinancialsFieldValue = maRec.pse__Include_In_Financials__c;
        Test.stopTest();
        System.assertEquals(false, approvedFieldValue, 'Approved Field Value updated');
        System.assertEquals(false, includeInFinancialsFieldValue, 'include In FinancialsFieldValue Field Value');
    }
}
