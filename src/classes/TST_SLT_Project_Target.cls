/*
 * Version       : 1.0
 * Description   : Test Class for SLT_Project_Target
 */
@isTest
public class TST_SLT_Project_Target {

    /**
     * This method used to get Project Target by Project 
     */
    @IsTest
    static void testGetProjectTargetByProject() {
        setupTestData();
        Test.startTest();
        Set<String> fieldSet = new SLT_Project_Target().getSObjectFieldSet();
        Set<Id> projectIds = new Set<Id>{parentProject.Id};
        List<Project_Target__c> projectTargets = new SLT_Project_Target().getProjectTargetByProject(projectIds, fieldSet);
        Test.stopTest();
        Decimal expectedCount = 2;
        System.assertEquals(expectedCount, projectTargets.size()); 
    }

    /**
     * This method used to get Project Target by Service Line Project 
     */
    @IsTest
    static void getProjectTargetByServiceLineProject() {
        setupTestData();
        Test.startTest();
        Set<String> fieldSet = new SLT_Project_Target().getSObjectFieldSet();
        Set<Id> projectIds = new Set<Id>{project.Id};
        List<Project_Target__c> projectTargets = new SLT_Project_Target().getProjectTargetByServiceLineProject(projectIds, fieldSet);
        Test.stopTest();
        Decimal expectedCount = 1;
        System.assertEquals(expectedCount, projectTargets.size()); 
    }

    static Program__c program;
    static pse__Proj__c parentproject;
    static pse__Proj__c project;
    static Target__c target;

    static void setupTestData () {

        program = new Program__c(Name = 'TestClassProgram');
        insert program;  

        // Parent Project
        parentproject = UTL_PSA_TestData.createProjects(1, false)[0];
        Id parentrecTypeId = UTL_PSA_TestData.lookupRecordTypeId('pse__Proj__c', CON_PSA.PROJ_REC_TYPE_RDS_PROJECT);  
        parentproject.recordTypeId = parentrecTypeId;
        parentproject.pse__Project_Status__c = 'Start-up';
        parentproject.Name = 'TestClassParentProject';
        parentproject.Program__c = program.id;
        parentproject.Project_Code__c ='12345';
        insert parentproject;
      
        // Project
        project = UTL_PSA_TestData.createProjects(1, false)[0];
        Id recTypeId = UTL_PSA_TestData.lookupRecordTypeId('pse__Proj__c', CON_PSA.PROJ_REC_TYPE_RDS_SERVICELINE);  
        project.recordTypeId = recTypeId;
        project.pse__Project_Status__c = 'Start-up';
        project.Name = 'TestClassServiceLineProject';
        project.pse__Parent_Project__c = parentproject.id;
        
        insert project;    

        // Target
        target = new Target__C(
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

        // Project Targets
        List<Project_Target__c> projectTargets = new List<Project_Target__c>();
        projectTargets.add(new Project_Target__c(
            Project__c=parentproject.Id,
            Target__c=target.Id
        ));
        projectTargets.add(new Project_Target__c(
            Project__c=parentproject.Id,
            Service_Line_Project__c=project.Id,
            Target__c=target.Id
        ));
        insert projectTargets;
    }
}
