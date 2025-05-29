/*
 * TST_CNT_PSA_TargetGrid
 *
 * Exhaustive unit tests for Target Grid LWC page
 * 
 */
/*
   sfdx force:apex:test:run -t TST_CNT_PSA_TargetGrid -c -r json
 */
@isTest(isParallel=false)
public class TST_CNT_PSA_TargetGrid 
{
    @testSetup
    static void dataSetup() 
    {
        Program__c program = new Program__c(Name = 'TestClassProgram');
        insert program;  

        pse__Proj__c parentproject = UTL_PSA_TestData.createProjects(1, false)[0];
        Id parentrecTypeId = UTL_PSA_TestData.lookupRecordTypeId('pse__Proj__c', CON_PSA.PROJ_REC_TYPE_RDS_PROJECT);  
        parentproject.recordTypeId = parentrecTypeId;
        parentproject.pse__Project_Status__c = 'Start-up';
        parentproject.Name = 'TestClassParentProject';
        parentproject.Program__c = program.id;
        parentproject.Project_Code__c ='12345';
        insert parentproject;
      
        pse__Proj__c project = UTL_PSA_TestData.createProjects(1, false)[0];
        Id recTypeId = UTL_PSA_TestData.lookupRecordTypeId('pse__Proj__c', CON_PSA.PROJ_REC_TYPE_RDS_SERVICELINE);  
        project.recordTypeId = recTypeId;
        project.pse__Project_Status__c = 'Start-up';
        project.Name = 'TestClassServiceLineProject';
        project.Program__c = program.id;
        project.pse__Parent_Project__c = parentproject.id;
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

    /*
     * Gets all projects on a program and their project codes
     */
    @IsTest
    public static void testGetProjectsForProgram(){
        //setupTestData();
        Program__c program = [Select Id, Name from Program__c limit 1];
        pse__Proj__c parentproject = [Select Id, Name, Project_Code__c from pse__Proj__c where Name = 'TestClassParentProject' limit 1];
        Test.startTest();
        List<pse__Proj__c> projects = CNT_PSA_TargetGrid.getProjectsForProgram(program.Id);
        Test.stopTest();

        Decimal expectedCount = 1;
        Id expectedId = parentproject.Id;
        System.assertEquals(expectedCount, projects.size()); 
        System.assertEquals(expectedId, projects.get(0).Id); 
    }

    /*
     * Gets all targets on a program
     */
    @IsTest
    public static void testGetTargets(){
        //setupTestData();
        Program__c program = [Select Id, Name from Program__c limit 1];
        Id targetRecordTypeId = UTL_PSA_TestData.lookupRecordTypeId('Target__c', CON_PSA.TARGET_REC_TYPE_RDS_PRODUCT_LINE);

        Test.startTest();
        List<Target__c> targets = CNT_PSA_TargetGrid.getTargets(program.Id, targetRecordTypeId);
        Test.stopTest();

        Decimal expectedCount = 1;
        System.assertEquals(expectedCount, targets.size()); 
    }

    /*
     * Gets all project targets on a project or else on a service line
     */
    @IsTest
    public static void testGetProjectTargets(){
        //setupTestData();
        pse__Proj__c parentproject = [Select Id, Name, Project_Code__c from pse__Proj__c where Name = 'TestClassParentProject' limit 1];
        pse__Proj__c project = [Select Id, Name, Project_Code__c from pse__Proj__c where Name = 'TestClassServiceLineProject' limit 1];
        
        List<Id> projectIds = new List<Id>{parentProject.Id};
        List<Id> serviceLineIds = new List<Id>{project.Id};

        Test.startTest();
        //Test both modes
        List<Project_Target__c> projectTargetsProjectMode = CNT_PSA_TargetGrid.getProjectTargets('project',projectIds);
        List<Project_Target__c> projectTargetsServiceLineMode = CNT_PSA_TargetGrid.getProjectTargets('serviceLine',serviceLineIds);

        //Make sure it catches invalid input
        Boolean catchesInvalidInput = false;
        try {
            List<Project_Target__c> projectTargetsInvalidMode = CNT_PSA_TargetGrid.getProjectTargets('invalid',projectIds);
        } catch (Exception e) {
            catchesInvalidInput = true;
        }
        Test.stopTest();

        Decimal expectedProjectMode = 2;
        Decimal expectedServiceLineMode = 1;
        System.assertEquals(expectedProjectMode, projectTargetsProjectMode.size()); 
        System.assertEquals(expectedServiceLineMode, projectTargetsServiceLineMode.size()); 
        System.assert(catchesInvalidInput == true, 'Expected an error when invalid mode is input, but it succeeded!');
    }

    /*
     * Gets the service line projects for a program
     */
    @IsTest
    public static void testGetServiceLines(){
        //setupTestData();
        pse__Proj__c project = [Select Id, Name, Project_Code__c from pse__Proj__c where Name = 'TestClassServiceLineProject' limit 1];
        Program__c program = [Select Id, Name from Program__c limit 1];
        Test.startTest();
        List<pse__Proj__c> serviceLines = CNT_PSA_TargetGrid.getServiceLines(program.Id);
        Test.stopTest();

        Decimal expectedCount = 1;
        Id expectedId = project.Id;
        System.assertEquals(expectedCount, serviceLines.size()); 
        System.assertEquals(expectedId, serviceLines.get(0).Id); 
    }

    /*
     * Creates a project target for a target, project, and optional service line 
     */
    @IsTest
    public static void testCreateProjectTarget(){
        //setupTestData();
        pse__Proj__c parentproject = [Select Id, Name, Project_Code__c from pse__Proj__c where Name = 'TestClassParentProject' limit 1];
        pse__Proj__c project = [Select Id, Name, Project_Code__c from pse__Proj__c where Name = 'TestClassServiceLineProject' limit 1];
        Target__c target = [Select Id, Name from Target__c limit 1];

        List<Id> projectIds = new List<Id>{parentProject.Id};
        List<Project_Target__c> projectTargetsBefore = CNT_PSA_TargetGrid.getProjectTargets('project',projectIds);

        Test.startTest();
        CNT_PSA_TargetGrid.createProjectTarget(parentproject.Id,project.Id,target.Id,true);
        Test.stopTest();

        List<Project_Target__c> projectTargetsAfter = CNT_PSA_TargetGrid.getProjectTargets('project',projectIds);

        Decimal expectedBefore = 2;
        Decimal expectedAfter = 3;
        System.assertEquals(expectedBefore, projectTargetsBefore.size()); 
        System.assertEquals(expectedAfter, projectTargetsAfter.size()); 
    }
    
    /*
     * Update a project target
     */
    @IsTest
    public static void  updateProjectTarget(){
        //setupTestData();
        pse__Proj__c parentproject = [Select Id, Name, Project_Code__c from pse__Proj__c where Name = 'TestClassParentProject' limit 1];
        pse__Proj__c project = [Select Id, Name, Project_Code__c from pse__Proj__c where Name = 'TestClassServiceLineProject' limit 1];
        Target__c target = [Select Id, Name from Target__c limit 1];
        
        List<Id> projectIds = new List<Id>{parentProject.Id};
        
        Project_Target__c toUpdate = new Project_Target__c(
            Project__c=parentproject.Id,
            Service_Line_Project__c=project.Id,
            Target__c=target.Id
        );
        insert toUpdate;
        List<Project_Target__c> projectTargetsBefore = CNT_PSA_TargetGrid.getProjectTargets('project',projectIds);

        Test.startTest();
        CNT_PSA_TargetGrid.updateProjectTarget(toUpdate.Id,false);
        Test.stopTest();
    }

    /*
     * Deletes a project target
     */
    
    /*
    @IsTest
    public static void  deleteProjectTarget(){
        //setupTestData();
        pse__Proj__c parentproject = [Select Id, Name, Project_Code__c from pse__Proj__c where Name = 'TestClassParentProject' limit 1];
        pse__Proj__c project = [Select Id, Name, Project_Code__c from pse__Proj__c where Name = 'TestClassServiceLineProject' limit 1];
        Target__c target = [Select Id, Name from Target__c limit 1];
        
        List<Id> projectIds = new List<Id>{parentProject.Id};
        
        Project_Target__c toDelete = new Project_Target__c(
            Project__c=parentproject.Id,
            Service_Line_Project__c=project.Id,
            Target__c=target.Id
        );
        insert toDelete;
        List<Project_Target__c> projectTargetsBefore = CNT_PSA_TargetGrid.getProjectTargets('project',projectIds);

        Test.startTest();
        CNT_PSA_TargetGrid.deleteProjectTarget(toDelete.Id);
        Test.stopTest();

        List<Project_Target__c> projectTargetsAfter = CNT_PSA_TargetGrid.getProjectTargets('project',projectIds);

        Decimal expectedBefore = 3;
        Decimal expectedAfter = 2;
        System.assertEquals(expectedBefore, projectTargetsBefore.size()); 
        System.assertEquals(expectedAfter, projectTargetsAfter.size()); 
    }
    */
    
    /*
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
        project.Program__c = program.id;
        project.pse__Parent_Project__c = parentproject.id;
        
        insert project;    

        // Target
        Id targetRecordTypeId = UTL_PSA_TestData.lookupRecordTypeId('Target__c', CON_PSA.TARGET_REC_TYPE_RDS_PRODUCT_LINE);
        target = new Target__C(
            recordTypeId=targetRecordTypeId,
            Name='Test Target',
            API__c='Test API',
            Strength__c='Super strong',
            Dosage_Form__c='Huge pill',
            Program__c=program.Id
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
    */
} 
