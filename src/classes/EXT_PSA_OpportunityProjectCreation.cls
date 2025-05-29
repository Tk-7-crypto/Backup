/**
 * @author	: Leo De Bruyn <ldebruyn@cldpartners.com>
 * VisualForce controller extension for creating PSA projects from an Opportunity
 */
public class EXT_PSA_OpportunityProjectCreation {

    public pse__Proj__c placeholderProject {get; set;}
    public String opportunityId {get;set;}
    public Boolean validStage {get;set;}

    private static String HIERARCHY_MERGE_MISSING_SOBJECTS = 'Cannot merge project hierarchies without SObject information.';
    private static String MISSING_SERVICE_CODES = 'Cannot have services without service codes: ';
    private static String MISSING_SERVICE_DATES = 'Service Sold must have valid Start Date and End Date: ';
    private static String ZERO_SERVICE_SOLD = 'You may not have a quantity of zero for service sold: ';
    private static String MISSING_SERVICE_LINE_MISX = 'Service Line cannot be blank for MISX services.';
    private static String INVALID_SERVICE_CODES = 'Cannot find service matching service code: ';
    private static String INVALID_SERVICE_LINES = 'Cannot find service line matching name: ';
    private static String MISMATCHING_SERVICE_AND_LINE = 'Could not find matching service line for service ';
    private static String INVALID_QIP_TEMPLATE_NAME = 'Invalid QIP Template Name: ';
    private static String MISSING_PROJECT_CATEGORY = 'Project Category must be set to a valid picklist value.';
    private static String MISSING_PROJECT_CATEGORY_FIELD = 'Project Category field cannot be empty.';
    private static String REGION_NOT_SET = 'A Project Region must be set.';
    private static String OPPORTUNITY_MISMATCH = 'Project Code already in use on a different opportunity: ';
    private static String INVALID_COUNTRY_CODE = 'Cannot find matching country code: ';
    private static String MISSING_PROJECT_DATE = 'Missing project date. Project must have all date fields filled out and in correct yyyy-mm-dd format.';
    private static String SERVICE_DATE_BEFORE_RANGE = 'There is a service with a start date before the project\'s contract start date: ';
    private static String SERVICE_DATE_AFTER_RANGE = 'There is a service with an end date after the project\'s contract end date: ';
    private static String RESOURCE_DATE_BEFORE_RANGE = 'There is a resource request with a start date before the project\'s contract start date: ';
    private static String RESOURCE_DATE_AFTER_RANGE = 'There is a resource request with an end date after the project\'s contract end date';
    private static String MISSING_GENERIC_RESOURCE = 'You must set the Resource Demand Contact ID in PSA RDS Settings for forecasting to work.';
    private static Set<String> FIELDS_ACCOUNT = new Set<String>{'Id', 'Name'};
    private static Set<String> FIELDS_OPPORTUNITY = new Set<String>{'Id', 'AccountId'};
    private static Set<String> FIELDS_PROGRAM = new Set<String>{'Id', 'Name', 'Account__c', 'Start_Date__c', 'End_Date__c', 'CurrencyIsoCode'};
    private static Set<String> FIELDS_PROJECT = new Set<String>{'Id', 'Legacy_ID__c', 'Name', 'Program__c', 'pse__Account__c', 'pse__Opportunity__c', 'pse__Region__c', 'pse__Group__c', 'Project_Code__c',
                                                'Contract_Type__c', 'Budget_Type__c', 'pse__Stage__c', 'pse__Start_Date__c', 'pse__End_Date__c', 'Go_Live_Date__c', 'Close_Out_Date__c',
                                                'pse__Billing_Type__c', 'Project_Category__c', 'pse__Project_Type__c', 'pse__Is_Active__c', 'pse__Is_Billable__c', 'RecordTypeId', 'CurrencyIsoCode', 'Training_Required__c'};
    private static Set<String> FIELDS_SERVICE_LINE_PROJECT = new Set<String>{'Id', 'Legacy_ID__c', 'Name', 'pse__Parent_Project__c', 'Program__c', 'pse__Account__c', 'pse__Opportunity__c', 'Service_Line__c',
                                                'pse__Region__c', 'pse__Group__c', 'pse__Start_Date__c', 'pse__End_Date__c', 'Go_Live_Date__c', 'Close_Out_Date__c', 'pse__Is_Active__c',
                                                'pse__Stage__c', 'pse__Is_Billable__c', 'RecordTypeId', 'CurrencyIsoCode', 'Training_Required__c','Service_Line_Scope__c' ,'Service_Line_Lead__c' };
    private static Set<String> FIELDS_MILESTONE = new Set<String>{'Id', 'Name', 'pse__Project__c', 'Service__c', 'Service_Line__c', 'Include_Tasks_on_Deliverables__c', 'Client_Grid_Name__c', 'Client_Grid_Code__c',
                                                'Countries__c', '', 'Start_Date__c', 'End_Date__c', 'pse__Target_Date__c', 'Unit_of_Measure__c', 'Billing_Type__c', 'Budget_Hours__c',
                                                'Budget_Quantity__c', 'Unit_Price__c', 'Budget_Amount__c', 'RecordTypeId', 'CurrencyIsoCode', 'pse__Status__c'};
    private static Set<String> FIELDS_BUDGET = new Set<String>{'Id', 'Name', 'pse__Project__c', 'pse__Account__c', 'pse__Opportunity__c', 'pse__Effective_Date__c', 'pse__Amount__c', 'RecordTypeId', 'CurrencyIsoCode'};
    private static Set<String> FIELDS_PRICING_TASK = new Set<String>{'Id', 'Name', 'Project__c', 'Country__c', 'Primary_service__c', 'Service__c', 'Task_Id__c', 'Budget_Hours__c', 'Service_Line_Project__c', 'Service_Milestone__c'};
    private static Set<String> FIELDS_RESOURCE_REQUEST = new Set<String>{'Id', 'Name', 'pse__Project__c', 'pse__Resource_Request_Name__c', 'pse__Opportunity__c', 'pse__Region__c', 'pse__Group__c', 'Country__c', 'pse__Resource_Held__c',
                                                'pse__Resource_Role__c', 'Job_Grade__c', 'pse__Resource__c', 'pse__Staffer_Resource__c', 'Requested_FTE__c', 'Hours_per_FTE__c', 'pse__Start_Date__c', 'pse__End_Date__c', 'pse__SOW_Hours__c', 'pse__Requested_Bill_Rate__c', 'RecordTypeId', 'CurrencyIsoCode'};
    private static Set<String> FIELDS_SERVICE_LINE = new Set<String>{'Id', 'Name', 'Group__c'};
    private static Set<String> FIELDS_SERVICE = new Set<String>{'Id', 'Name', 'Service_Code__c', 'Service_Line__c', 'Service_Line__r.Name', 'Include_Tasks_on_Deliverables__c'};
    private static Set<String> FIELDS_ID = new Set<String>{'Id'};

    private static Integer NAME_MAX_LENGTH = 80;

    public EXT_PSA_OpportunityProjectCreation(ApexPages.StandardController sc){
        //We use a blank project to generate a valid Program__c lookup field for the VF page layout
        placeholderProject = new pse__Proj__c();
        opportunityId = sc.getRecord().Id;
        String opportunityStage = new SLT_Opportunity().getOpportunityById(new Set<Id>{opportunityId}, new Set<String>{'Id','StageName'}).get(opportunityId).StageName;
        List<String> validStages = new SLT_PSA_ProjectCreationValidStage().selectValidStages();
        validStage = validStages.contains(opportunityStage);
        if(!validStage){
            ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, 'Sorry, you may not create projects on opportunities in stage '+opportunityStage+'.'));
        }
    }

    /**
     * Create a PSA Project hierarchy (optionally on an existing Program) from a QIP PSA Report
     */
    @RemoteAction
    public static String createProjectFromReport(Map<String,String> options, Map<String,List<Map<String,String>>> psaReport ){
        validateReportFormat(psaReport);
        EXT_PSA_OpportunityProjectCreation.ProjectHierarchy projectHierarchy = EXT_PSA_OpportunityProjectCreation.createProjectFromPSAReport(
                options.get('opportunityId'),
                options.get('programId'),
                psaReport,
                Boolean.valueOf(options.get('createResourceRequests')));

        //We want the Project Id, not the Program Id
        String projectId = projectHierarchy.getChildren().get(0).obj.id;
        logImportProcess(psaReport, projectId);

        // On success, we expect to be able to redirect the user to the newly created program
        PageReference redirectSuccess = new ApexPages.StandardController(projectHierarchy.obj).view();
        return redirectSuccess.getUrl();
    }

    @RemoteAction
    public static List<Program__c> getAvailableProgramsForOpportunity(Map<String,String> options){
        String opportunityId = options.get('opportunityId');
        return EXT_PSA_OpportunityProjectCreation.getProgramsForOpportunity(opportunityId);
    }

    @RemoteAction
    public static EXT_PSA_OpportunityProjectCreation.ProjectHierarchy getProjectHierarchyPreview(Map<String,String> options, Map<String,List<Map<String,String>>> psaReport){
        if(psaReport != null){
            validateReportFormat(psaReport);
        }
        String programId = options.get('programId');
        String opportunityId = options.get('opportunityId');
        return EXT_PSA_OpportunityProjectCreation.getProjectHierarchyPreview(programId, opportunityId, psaReport );
    }

    private static void logImportProcess(Map<String,List<Map<String,String>>> psaReport, String relatedObjectId){
        validateReportFormat(psaReport);
        fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(
            new Schema.SObjectType[] {
                Import_Process_Log__c.SObjectType,
                Attachment.SObjectType
            }
        );
        Import_Process_Log__c importLog = new Import_Process_Log__c();
        Map<String,String> projectInfo = psaReport.get('project').get(0);
        importLog.Template_Name__c = projectInfo.get('qip template name');
        importLog.Version__c = projectInfo.get('pricing tool version');
        importLog.Version_Date__c = Datetime.newInstance(Date.valueOf(projectInfo.get('version date')),Time.newInstance(0, 0, 0, 0));
        importLog.Related_Object_ID__c = relatedObjectId;
        uow.registerNew(importLog);
        String serializedReport = JSON.serialize(psaReport);
        Integer fieldLength = Import_Process_Log__c.File_String__c.getDescribe().getLength();
        system.debug('Report size: '+serializedReport.length());
        if( serializedReport.length() > fieldLength){
            importLog.File_String__c = 'Oversize file. See attached.';
            uow.registerNew(new Attachment(Body=Blob.valueOf(serializedReport),Name='QIP.JSON'),Attachment.ParentId, importLog);
        } else {
            importLog.File_String__c = serializedReport;
        }
        uow.commitWork();
    }

    private static pse__Grp__c getQIPGroup( String QIPType ){
        Map<String,String> QIPNameToGroupNameMap = new Map<String,String>{
            'LCS/RADDS QIP' => 'DSSR',
            'RADDS' => 'RADDS',
            'CLIN QIP' => 'Clinical Operations',
            'LCS QIP' => 'Lifecycle Safety'
        };
        String groupName = QIPNameToGroupNameMap.get(QIPType);
        if(groupName == null){
            String validTypes = String.join(new List<String>(QIPNameToGroupNameMap.keySet()),',  ');
            throw new EXT_PSA_OpportunityProjectCreation_Exception(INVALID_QIP_TEMPLATE_NAME+QIPType+'. Valid types are: '+validTypes);
        }
        pse__Grp__c QIPGroup = new SLT_Grp().selectSingleGroupByName(groupName, FIELDS_ID);
        return QIPGroup;
    }

    private static Program__c getProgramByProjectCode(String projectCode){
        List<pse__Proj__c> projectsWithProgramCode = new SLT_Project().selectByProjectCode(new Set<String>{projectCode}, new Set<String>{'Id', 'Program__c', 'Project_Code__c'});
        for(pse__Proj__c proj : projectsWithProgramCode){
            if(proj.Program__c != null){
                return new SLT_Program().selectByProgramId(new Set<Id>{proj.Program__c}, FIELDS_PROGRAM);
            }
        }
        return null;
    }

    private static Boolean projectCodeExists(String projectCode){
        List<pse__Proj__c> projects = new SLT_Project().selectByProjectCode(new Set<String>{projectCode}, new Set<String>{'Id'});
        return (projects.size() > 0);
    }

    /**
     * Create a DSSR PSA Project hierarchy, based on a report from another source such as a QIP
     */
    public static ProjectHierarchy createProjectFromPSAReport(Id opportunityId, Id programId, Map<String,List<Map<String,String>>> psaReport, Boolean createResourceRequests) {
        validateReportFormat(psaReport);
        //Make sure Project Code isn't already in use
        String projCode = psaReport.get('project').get(0).get('project code');
        Boolean isChangeOrder = (psaReport.get('project').get(0).get('is change order') == 'Y');
        Program__c existingProgram = getProgramByProjectCode(projCode);

        Id programIdOverride = (existingProgram != null) ? existingProgram.Id : programId;

        ProjectHierarchy oldHierarchy = EXT_PSA_OpportunityProjectCreation.getExistingProjectHierarchy(programIdOverride, opportunityId, true);
        ProjectHierarchy newHierarchy = EXT_PSA_OpportunityProjectCreation.createNewProjectHierarchy(programIdOverride, opportunityId, psaReport, true);
        ProjectHierarchy projectToCreate = EXT_PSA_OpportunityProjectCreation.mergeProjectHierarchies(oldHierarchy, newHierarchy, isChangeOrder);
        
        if(psaReport != null && psaReport.size() > 0 && psaReport.get('project') != null){
        	List<Map<String,String>> projectSheet = psaReport.get('project');
        	Map<String,String> projectData = projectSheet.get(0);
            if(projectData != null && projectData.size() > 0){
        		String projectCategory = projectData.get('project category');
        		if(projectCategory == null || projectCategory == ''){
            		throw new EXT_PSA_OpportunityProjectCreation_Exception(MISSING_PROJECT_CATEGORY_FIELD);
        		}
            }
    	}

        Map<String,List<pse__Proj__c>> projectCodeToServiceLineProjectListMap = new Map<String,List<pse__Proj__c>>();
        List<Pricing_Task__c> pricingTaskList = new List<Pricing_Task__c>();
        Map<Id,pse__Milestone__c> serviceIdToMilestoneMap = new Map<Id,pse__Milestone__c>();
        Map<Id,pse__Proj__c> serviceLineIdToProjectMap = new Map<Id,pse__Proj__c>();

        fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(
                new Schema.SObjectType[] {
                    Program__c.SObjectType,
                    pse__Proj__c.SObjectType,
                    Pricing_Task__c.SObjectType,
                    pse__Budget__c.sObjectType,
                    pse__Milestone__c.sObjectType,
                    pse__Resource_Request__c.sObjectType
                }
        );

        fflib_SObjectUnitOfWork uow2 = new fflib_SObjectUnitOfWork(
                new Schema.SObjectType[] { pse__Proj__c.SObjectType }
        );

        Program__c program = (Program__c)projectToCreate.obj;
        if(projectToCreate.status == 'new'){
            system.debug('Register new program'+projectToCreate.name);
            uow.registerNew(program);
        }
        else if(projectToCreate.status == 'modified'){
            system.debug('Register modified program'+projectToCreate.name);
            uow.registerDirty(program);
        }

        for(ProjectHierarchy parentProject : projectToCreate.getChildren()){
            pse__Proj__c proj = (pse__Proj__c)parentProject.obj;
            if(parentProject.status == 'new'){
                system.debug('Register new project'+parentProject.name);
                uow.registerNew(proj, pse__Proj__c.Program__c, program);
            }
            else if(parentProject.status == 'modified'){
                system.debug('Register modified project'+parentProject.name);
                uow.registerDirty(proj);
            }

            for(ProjectHierarchy childProject : parentProject.getChildren()){

                if(childProject.objectType == 'Budget'){
                    pse__Budget__c budget = (pse__Budget__c)childProject.obj;
                    if(childProject.status == 'new'){
                        system.debug('Register new budget'+childProject.name);
                        uow.registerNew(budget,pse__Budget__c.pse__Project__c,proj);
                    }
                    else if(childProject.status == 'modified'){
                        system.debug('Register modified budget'+childProject.name);
                        uow.registerDirty(budget);
                    }
                    continue;
                }

                if(childProject.objectType == 'Pricing Task'){
                    Pricing_Task__c task = (Pricing_Task__c)childProject.obj;
                    if(childProject.status == 'new'){
                        system.debug('Register new task'+childProject.name);
                        uow.registerNew(task,Pricing_task__c.Project__c,proj);
                        pricingTaskList.add(task);
                    }
                    else if(childProject.status == 'modified'){
                        system.debug('Register modified task'+childProject.name);
                        uow.registerDirty(task);
                    }
                    else if(childProject.status == 'deleted' && !isChangeOrder){
                        system.debug('Register deleted task '+childProject.name);
                        uow.registerDeleted(task);
                    }
                    continue;
                }

                if(childProject.objectType != 'Project'){
                    continue;
                }
                pse__Proj__c serviceLineProj = (pse__Proj__c)childProject.obj;
                if(parentProject.status == 'existing' || parentProject.status == 'modified'){
                    serviceLineProj.pse__Parent_Project__c = proj.Id;
                }
                if(childProject.status == 'new'){
                    system.debug('Register new service line project'+childProject.name);
                    uow.registerNew(serviceLineProj, pse__Proj__c.Program__c, program);
                }
                else if(childProject.status == 'modified'){
                    system.debug('Register modified service line project'+childProject.name);
                    uow.registerDirty(serviceLineProj);
                }
                else if(childProject.status == 'deleted' && !isChangeOrder){
                    system.debug('Register deleted service line project '+childProject.name);
                    //Projects have to be deleted in a different unit of work, or we get dependency issues
                    uow2.registerDeleted(serviceLineProj);
                }

                if(serviceLineProj.pse__Parent_Project__c == null){
                    if(projectCodeToServiceLineProjectListMap.get(proj.Project_Code__c) == null){
                        projectCodeToServiceLineProjectListMap.put(proj.Project_Code__c,new List<pse__Proj__c>());
                    }
                    projectCodeToServiceLineProjectListMap.get(proj.Project_Code__c).add(serviceLineProj);
                }
                serviceLineIdToProjectMap.put(serviceLineProj.Service_Line__c,serviceLineProj);

                for(ProjectHierarchy childObject : childProject.getChildren()){

                    if(childObject.objectType == 'Milestone'){
                        system.debug('Milestone '+childObject.name+' status is: '+childObject.status);
                        pse__Milestone__c milestone = (pse__Milestone__c)childObject.obj;
                        if(childObject.status == 'modified'){
                            system.debug('Register modified milestone'+childObject.name);
                            uow.registerDirty(milestone);
                        }
                        else if(childObject.status == 'new'){
                            system.debug('Register new milestone'+childObject.name);
                            if(childProject.status == 'existing' || childProject.status == 'modified'){
                                milestone.pse__Project__c = serviceLineProj.Id;
                                uow.registerNew(milestone);
                            } else {
                                uow.registerNew(milestone,pse__Milestone__c.pse__Project__c,serviceLineProj);
                            }
                        }
                        else if(childObject.status == 'deleted' && !isChangeOrder){
                            system.debug('Register deleted milestone '+childObject.name);
                            uow.registerDeleted(milestone);
                        }

                        system.debug('Service Id: '+milestone.Service__c+' Milestone: '+milestone);
                        serviceIdToMilestoneMap.put(milestone.Service__c, milestone);
                        continue;
                    }

                    if(createResourceRequests && childObject.objectType == 'Resource Request' && !isChangeOrder && childObject.status == 'deleted'){
                        //We delete unwanted requests, but additions and modifications will require a separate context due to performance-- see below
                        pse__Resource_Request__c request = (pse__Resource_Request__c)childObject.obj;
                        system.debug('Register deleted resource request '+childObject.name);
                        uow.registerDeleted(request);
                        continue;
                    }
                }
            }
        }

        //Apply Service Line Projects and Service Milestones to pricing tasks, using gathered Service data
        system.debug('SERVICE LINES: '+serviceLineIdToProjectMap.keySet());
        for(Pricing_Task__c task : pricingTaskList){
            system.debug('TASK Service Id: '+task.Service__c);
            system.debug('TASK Primary Service Id: '+task.Primary_Service__c);
            pse__Milestone__c serviceMilestone = serviceIdToMilestoneMap.get(task.Primary_Service__c);
            system.debug('TASK SERVICE MILESTONE: '+serviceMilestone);
            if(serviceMilestone == null){
                serviceMilestone = serviceIdToMilestoneMap.get(task.Service__c);
            }
            if(serviceMilestone != null){
                uow.registerRelationship(task, Pricing_Task__c.Service_Milestone__c, serviceMilestone);
                system.debug('TASK Service Line Id: '+serviceMilestone.Service_Line__c);
                pse__Proj__c serviceLineProject = serviceLineIdToProjectMap.get(serviceMilestone.Service_Line__c);
                system.debug('TASK SERVICE LINE PROJECT: '+serviceLineProject);
                if(serviceLineProject != null){
                    uow.registerRelationship(task, Pricing_Task__c.Service_Line_Project__c, serviceLineProject);
                }
            }
        }

        uow.commitWork();

        //Now, link child projects to parent projects and update once more (because of limitations in how UOW handles lookups between objects of same type)
        for(ProjectHierarchy parentProject : projectToCreate.getChildren()){
            pse__Proj__c project = (pse__Proj__c)parentProject.obj;
            String projectCode = project.Project_Code__c;
            List<pse__Proj__c> serviceLineProjects = projectCodeToServiceLineProjectListMap.get(projectCode);
            if(serviceLineProjects == null){
                continue;
            }
            for(pse__Proj__c serviceLineProject : serviceLineProjects){
                serviceLineProject.pse__Parent_Project__c = project.Id;
                uow2.registerDirty(serviceLineProject);
            }
        }
        uow2.commitWork();

        //For performance reasons, we gather our resource requests here for separate processing
        List<pse__Resource_Request__c> resourceRequestList = new List<pse__Resource_Request__c>();
        for(ProjectHierarchy parentProject : projectToCreate.getChildren()){
            for(ProjectHierarchy childProject : parentProject.getChildren()){
                if(childProject.objectType != 'Project'){
                    continue;
                }
                pse__Proj__c serviceLineProj = (pse__Proj__c)childProject.obj;
                for(ProjectHierarchy childObject : childProject.getChildren()){
                    if(createResourceRequests && childObject.objectType == 'Resource Request'){
                        pse__Resource_Request__c request = (pse__Resource_Request__c)childObject.obj;
                        if(childProject.status == 'new'){
                            system.debug('Register new resource request'+childObject.name+' on new project '+serviceLineProj.name);
                            request.pse__Project__c = serviceLineProj.Id;
                            //resourceRequestList.add(request);
                            /* Story 4572
                             * 'Safety System' Resource Requests should not be auto-created during project creation
                             */
                            System.debug( 'Service Line Project Object--'+serviceLineProj );
                            System.debug( 'request Object--'+request );
                            if( !serviceLineProj.Name.contains('Safety System') ){
                                resourceRequestList.add(request); 
                            }
                        }

                        //On change orders, we only add new resource requests and only on new services
                        if(isChangeOrder) {
                            continue;
                        }

                        //For all other projects, we add/modify/delete
                        if(childObject.status == 'modified'){
                            system.debug('Register modified resource request'+childObject.name);
                            resourceRequestList.add(request);
                        }
                        else if(childObject.status == 'new'){
                            if(childProject.status == 'existing' || childProject.status == 'modified'){
                                system.debug('Register new resource request'+childObject.name+' on existing project '+serviceLineProj.name);
                                request.pse__Project__c = serviceLineProj.Id;
                                resourceRequestList.add(request);
                            }
                        }
                    }
                }
            }
        }

        //Resource requests are created separately for performance reasons
        if(resourceRequestList.size() > 0){
            System.enqueueJob(new QUE_PSA_AddResourceRequestsToProject(resourceRequestList));
        }

        //With creation finished, kick of creation of dependent objects async
        system.debug('Setting up project task templates and metric templates async.');
        BCH_PSA_InsertTaskTemplates.batchRun(serviceLineIdToProjectMap.values());
        System.enqueueJob(new QUE_PSA_ApplyRDSMetricTemplates(serviceIdToMilestoneMap.values()));

        return projectToCreate;
    }

    public static List<Program__c> getProgramsForOpportunity(Id opportunityId){
        Opportunity opp = new SLT_Opportunity().getOpportunityById(new Set<Id>{opportunityId},FIELDS_OPPORTUNITY).get(opportunityId);
        return new SLT_Program().selectByAccount(new Set<Id>{opp.AccountId}, new Set<String>{'Id', 'Name', 'Account__r.Name'});
    }

    public static ProjectHierarchy getProjectHierarchyPreview(Id programId, Id opportunityId, Map<String,List<Map<String,String>>> psaReport) {
        if( psaReport == null){
            return EXT_PSA_OpportunityProjectCreation.getExistingProjectHierarchy(programId, opportunityId, true);
        }
        validateReportFormat(psaReport);
        Map<String,String> projectData = psaReport.get('project').get(0);
        String projectCode = projectData.get('project code');
        Program__c program = getProgramByProjectCode(projectCode);
        if( program == null && programId == null ) {
            return EXT_PSA_OpportunityProjectCreation.createNewProjectHierarchy(null, opportunityId, psaReport, true);
        }

        Id programIdOverride = (program != null) ? program.Id : programId;

        Boolean isChangeOrder = (projectData.get('is change order') == 'Y');

        ProjectHierarchy oldHierarchy = EXT_PSA_OpportunityProjectCreation.getExistingProjectHierarchy(programIdOverride, opportunityId, true);
        ProjectHierarchy newHierarchy = EXT_PSA_OpportunityProjectCreation.createNewProjectHierarchy(programIdOverride, opportunityId, psaReport, true);
        return EXT_PSA_OpportunityProjectCreation.mergeProjectHierarchies(oldHierarchy, newHierarchy, isChangeOrder);
    }

    /**
     * Looks up an existing program and creates a hierarchy based on it
     */
    private static ProjectHierarchy getExistingProjectHierarchy(Id programId, Id opportunityId, Boolean createSObjects){
        if(programId == null) {
            return null;
        }

        Program__c programData = new SLT_Program().selectByProgramId(new Set<Id>{programId}, FIELDS_PROGRAM);

        List<pse__Proj__c> projects = new SLT_Project().selectByProgramId(new Set<Id>{programId}, FIELDS_PROJECT);
        Set<Id> projectIdSet = new Map<Id,pse__Proj__c>(projects).keySet();

        List<pse__Proj__c> serviceLines = new SLT_Project().selectByParentProjectId(projectIdSet, FIELDS_SERVICE_LINE_PROJECT);
        Set<Id> serviceProjectIdSet = new Map<Id,pse__Proj__c>(serviceLines).keySet();

        List<pse__Milestone__c> milestones = new SLT_Milestone().selectMilestoneByRDSServiceProjectId(serviceProjectIdSet, FIELDS_MILESTONE);
        List<pse__Budget__c> budgets = new SLT_Budget().selectByProject(projectIdSet, FIELDS_BUDGET);
        List<Pricing_Task__c> tasks = new SLT_Pricing_Task().selectByProject(projectIdSet, FIELDS_PRICING_TASK);
        List<pse__Resource_Request__c> requests = new SLT_Resource_Request().getResourceRequestByProjectID(serviceProjectIdSet, FIELDS_RESOURCE_REQUEST).values();

        ProjectHierarchy program = new ProjectHierarchy();
        program.id = programData.Id;
        program.status = 'existing';
        program.name = programData.Name;
        program.recordType = '';
        program.objectType = 'Program';
        if(createSObjects){
            program.obj = programData;
        }

        Map<Id,ProjectHierarchy> idProjectMap = new Map<Id,ProjectHierarchy>();
        for(pse__Proj__c proj : projects){
            ProjectHierarchy project = new ProjectHierarchy();
            project.id = proj.Id;
            project.status = 'existing';
            project.name = proj.Name;
            project.recordType = 'RDS Project';
            project.objectType = 'Project';
            program.addChild(project);
            idProjectMap.put(project.id, project);
            if(createSObjects){
                project.obj = proj;
            }
        }

        Map<Id,ProjectHierarchy> idServiceLineMap = new Map<Id,ProjectHierarchy>();
        for(pse__Proj__c sl : serviceLines){
            ProjectHierarchy serviceLine = new ProjectHierarchy();
            if(createSObjects){
                serviceLine.obj = sl;
            }
            serviceLine.id = sl.Id;
            serviceLine.status = 'existing';
            serviceLine.name = sl.Name;
            serviceLine.recordType = 'RDS Service';
            serviceLine.objectType = 'Project';
            idProjectMap.get(sl.pse__Parent_Project__c).addChild(serviceLine);
            idServiceLineMap.put(serviceLine.id, serviceLine);
        }

        for(pse__Milestone__c ms : milestones){
            ProjectHierarchy service = new ProjectHierarchy();
            if(createSObjects){
                service.obj = ms;
            }
            service.id = ms.Id;
            service.status = 'existing';
            service.name = ms.Name;
            service.recordType = '';
            service.objectType = 'Milestone';
            service.details.put('Budgeted Quantity', String.valueOf(ms.get('Budget_Quantity__c')));
            idServiceLineMap.get(ms.pse__Project__c).addChild(service);
        }

        for(Pricing_Task__c pt : tasks){
            ProjectHierarchy task = new ProjectHierarchy();
            if(createSObjects){
                task.obj = pt;
            }
            task.id = pt.Id;
            task.status = 'existing';
            task.hidden = true;
            task.name = pt.Name;
            task.recordType = '';
            task.objectType = 'Pricing Task';
            idProjectMap.get(pt.Project__c).addChild(task);
        }

        //If we are creating sObjects, also create budgets and requests
        for(pse__Budget__c bt : budgets){
            ProjectHierarchy budget = new ProjectHierarchy();
            if(createSObjects){
                budget.obj = bt;
            }
            budget.id = bt.Id;
            budget.status = 'existing';
            budget.name = bt.Name;
            budget.recordType = '';
            budget.objectType = 'Budget';
            idProjectMap.get(bt.pse__Project__c).addChild(budget);
        }

        for(pse__Resource_Request__c req : requests){
            ProjectHierarchy request = new ProjectHierarchy();
            if(createSObjects){
                request.obj = req;
            }
            request.id = req.Id;
            request.status = 'existing';
            request.hidden = true;
            request.name = req.pse__Resource_Request_Name__c;
            request.recordType = '';
            request.objectType = 'Resource Request';
            idServiceLineMap.get(req.pse__Project__c).addChild(request);
        }

        System.debug('Finished getting old hierarchy.');
        program.log();
        return program;
    }

    /**
     * Takes a workbook and turns it into a new project hierarchy
     */
    private static ProjectHierarchy createNewProjectHierarchy(Id programId, Id opportunityId, Map<String,List<Map<String,String>>> psaReport, Boolean createSObjects ) {
        validateReportFormat(psaReport);
        //If we are creating sObject, initialize Account, RecordTypes, Services, and ServiceLines
        List<Map<String,String>> projectSheet = psaReport.get('project');
        List<Map<String,String>> servicesSheet = psaReport.get('services');
        List<Map<String,String>> tasksSheet = psaReport.get('tasks');
        List<Map<String,String>> requestsSheet = psaReport.get('resources');
        Map<String,ProjectHierarchy> nameToServiceLineWrapperMap = new Map<String,ProjectHierarchy>();

        Map<String,String> projectData = projectSheet.get(0);
        Opportunity opp = new SLT_Opportunity().getOpportunityById(new Set<Id>{opportunityId},FIELDS_OPPORTUNITY).get(opportunityId);
        String AccountId = opp.AccountId;
        Account customer = new SLT_Account().selectByAccountId(new Set<Id>{AccountId}, FIELDS_ACCOUNT).get(AccountId);
        Id ProjectRecordTypeId = Schema.SObjectType.pse__Proj__c.getRecordTypeInfosByName().get('RDS Project').getRecordTypeId();
        Id ServiceLineRecordTypeId = Schema.SObjectType.pse__Proj__c.getRecordTypeInfosByName().get('RDS Service Line').getRecordTypeId();
        Id BudgetRecordTypeId = Schema.SObjectType.pse__Budget__c.getRecordTypeInfosByName().get('RDS Budget').getRecordTypeId();
        Id MilestoneRecordTypeId = Schema.SObjectType.pse__Milestone__c.getRecordTypeInfosByName().get('RDS Service').getRecordTypeId();
        Id ResourceRequestRecordTypeId = Schema.SObjectType.pse__Resource_Request__c.getRecordTypeInfosByName().get('RDS Request').getRecordTypeId();
        pse__Grp__c dssrGroup = EXT_PSA_OpportunityProjectCreation.getQIPGroup(projectData.get('qip template name'));
        pse__Region__c projectRegion = new SLT_Region().selectSingleRegionByName(projectData.get('region'), new Set<String>{'Id'});
        Map<String,pse__Region__c> countryCodeToRegionMap;
        Map<String,PSA_Country_Region_Map__mdt> countryCodeMappingMap;
        String projectCategory = projectData.get('project category');
        Boolean isChangeOrder = (projectData.get('is change order') == 'Y');
        system.debug('Change order? '+isChangeOrder);
        Datetime todaysDate = Datetime.now();
        Integer fakeId = 1;
        Date projectStartDate = makeDate(projectData.get('contract start date'));
        Date projectEndDate = makeDate(projectData.get('contract end date'));

        if(projectCategory == null){
            throw new EXT_PSA_OpportunityProjectCreation_Exception(MISSING_PROJECT_CATEGORY);
        }
        if(projectRegion == null){
            throw new EXT_PSA_OpportunityProjectCreation_Exception(REGION_NOT_SET);
        }

        //Some values must be calculated by examining all services
        Map<String,Date> serviceLineToStartDateMap = new Map<String,Date>();
        Map<String,Date> serviceLineToEndDateMap = new Map<String,Date>();
        Date budgetEffectiveDate = null;
        Decimal budgetAmount = 0.0;
        Map<String,Map<String,Decimal>> serviceLineToCountryHoursMap = new Map<String,Map<String,Decimal>>();
        String projectBillingType = null;
        Set<String> serviceLineNames = new Set<String>();
        Set<String> serviceCodes = new Set<String>();
        String duplicateServiceCodes = '';
        Set<String> countryCodeSet = new Set<String>();
        Map<String,Service_Line__c> nameToServiceLineMap = new Map<String,Service_Line__c>();
        Map<String,Service__c> serviceCodeToServiceMap;
        Map<String,String> serviceCodeToServiceLineNameMap = new Map<String,String>();
        List<String> servicesWithoutCodes = new List<String>();
        for(Map<String,String> serviceSheetRow : servicesSheet){
            String serviceLineName = serviceSheetRow.get('service line');
            String serviceLineProjectName = makeName(new List<String>{customer.name+' ',projectData.get('project code')+' ',serviceLineName},3,'middle','...');
            String serviceName = serviceSheetRow.get('service');
            String serviceCode = serviceSheetRow.get('service code');
            String countryCode = serviceSheetRow.get('country');
            Decimal serviceHours = Decimal.valueOf(serviceSheetRow.get('budgeted hours'));
            Date startDate = makeDate(serviceSheetRow.get('start date'), MISSING_SERVICE_DATES+serviceName);
            Date endDate = makeDate(serviceSheetRow.get('end date'), MISSING_SERVICE_DATES+serviceName);
            Date existingLineStartDate = serviceLineToStartDateMap.get(serviceLineName);
            Date existingLineEndDate = serviceLineToEndDateMap.get(serviceLineName);

            if(countryCode != null){
                countryCodeSet.add(countryCode);
            }

            if(serviceLineName != null){
                serviceLineNames.add(serviceLineName);
            } else {
                if(serviceCode == 'MISX'){
                    throw new EXT_PSA_OpportunityProjectCreation_Exception(MISSING_SERVICE_LINE_MISX);
                }
            }

            if(serviceCode != null){
                serviceCodes.add(serviceCode);
                serviceCodeToServiceLineNameMap.put(serviceCode,serviceLineName);
            } else {
                servicesWithoutCodes.add(serviceName);
            }

            if(startDate < projectStartDate){
                throw new EXT_PSA_OpportunityProjectCreation_Exception(SERVICE_DATE_BEFORE_RANGE+serviceName);
            }
            if(endDate > projectEndDate) {
                throw new EXT_PSA_OpportunityProjectCreation_Exception(SERVICE_DATE_AFTER_RANGE+serviceName);
            }

            if(existingLineStartDate == null || existingLineStartDate > startDate){
                serviceLineToStartDateMap.put(serviceLineName, startDate);
            }
            if(existingLineEndDate == null || existingLineEndDate < endDate) {
                serviceLineToEndDateMap.put(serviceLineName, endDate);
            }
            if(budgetEffectiveDate == null || budgetEffectiveDate > startDate){
                budgetEffectiveDate = startDate;
            }
            Decimal serviceQuantity = Decimal.valueOf(serviceSheetRow.get('quantity'));
            if( serviceQuantity == null || serviceQuantity == 0.0 ) {
                throw new EXT_PSA_OpportunityProjectCreation_Exception(ZERO_SERVICE_SOLD+serviceLineName+' / '+serviceName);
            }
            Decimal serviceAmount = Decimal.valueOf(serviceSheetRow.get('amount'));
            budgetAmount += serviceAmount;
            system.debug('Budget amount: '+budgetAmount);


            if(projectBillingType != 'Mixed'){
                String billingType = serviceSheetRow.get('billing type');
                if(projectBillingType == null){
                    projectBillingType = billingType;
                } else if(projectBillingType != billingType){
                    projectBillingType = 'Mixed';
                }
            }

            if(serviceLineToCountryHoursMap.get(serviceLineProjectName) == null){
                serviceLineToCountryHoursMap.put(serviceLineProjectName, new Map<String,Decimal>());
            }
            Map<String,Decimal> countryToHoursMap = serviceLineToCountryHoursMap.get(serviceLineProjectName);
            if(countryToHoursMap.get(countryCode) == null) {
                countryToHoursMap.put(countryCode, serviceHours);
            } else {
                countryToHoursMap.put(countryCode, countryToHoursMap.get(countryCode) + serviceHours);
            }
        }

        String missingServiceCodes = '';
        for(String code : servicesWithoutCodes){
            missingServiceCodes += (missingServiceCodes.length() > 0) ? ', '+code : code;
        }

        if(missingServiceCodes.length() > 0){
            throw new EXT_PSA_OpportunityProjectCreation_Exception(MISSING_SERVICE_CODES+missingServiceCodes);
        }

        for(Map<String,String> taskSheetRow : tasksSheet){
            String primary = taskSheetRow.get('primary service code');
            String secondary = taskSheetRow.get('service code');
            String countryCode = taskSheetRow.get('country');
            if(primary != null){
                serviceCodes.add(primary);
            }
            if(secondary != null){
                serviceCodes.add(secondary);
            }

            if(countryCode != null){
                countryCodeSet.add(countryCode);
            }

        }
        for(Map<String,String> requestSheetRow : requestsSheet){
            String countryCode = requestSheetRow.get('country');
            if(countryCode != null){
                countryCodeSet.add(countryCode);
            }
        }
        List<Service_Line__c> serviceLines = new SLT_Service_Line().selectByName(serviceLineNames, FIELDS_SERVICE_LINE);
        for(Service_Line__c sl : serviceLines){
            nameToServiceLineMap.put(sl.Name, sl);
            system.debug('Service Line: '+sl.Name);
        }
        String missingServiceLines = '';
        for(String name : serviceLineNames){
            if(nameToServiceLineMap.get(name) == null){
                missingServiceLines += (missingServiceLines.length() > 0) ? ', '+name : name;
            }
        }
        if(missingServiceLines.length() > 0){
            throw new EXT_PSA_OpportunityProjectCreation_Exception(INVALID_SERVICE_LINES+missingServiceLines);
        }

        serviceCodeToServiceMap = new SLT_Service().getActiveServiceByServiceCode(serviceCodes, FIELDS_SERVICE);
        for(Service__c sv : serviceCodeToServiceMap.values()){
            if( sv.Service_Code__c != 'MISX' &&
                ( serviceCodeToServiceLineNameMap.get(sv.Service_Code__c) == null ||
                  serviceCodeToServiceLineNameMap.get(sv.Service_Code__c) != sv.Service_Line__r.Name ||
                  nameToServiceLineMap.get(sv.Service_Line__r.Name) == null ||
                  nameToServiceLineMap.get(sv.Service_Line__r.Name).Id != sv.Service_Line__c ) ){
                    throw new EXT_PSA_OpportunityProjectCreation_Exception(MISMATCHING_SERVICE_AND_LINE+serviceCodeToServiceLineNameMap.get(sv.Service_Code__c)+'/'+sv.Service_Code__c);
                }
        }

        String missingServices = '';
        for(String code : serviceCodes){
            if(serviceCodeToServiceMap.get(code) == null){
                missingServices += (missingServices.length() > 0) ? ', '+code : code;
            }
        }
        if(missingServices.length() > 0){
            throw new EXT_PSA_OpportunityProjectCreation_Exception(INVALID_SERVICE_CODES+missingServices);
        }

        Set<String> invalidCountryCodes = new SLT_PSA_CountryRegionMap().findInvalidCountryCodes(countryCodeSet);
        if(invalidCountryCodes.size() > 0){
            String concatCodes = '';
            for(String code : invalidCountryCodes){
                concatCodes += (concatCodes.length() > 0) ? ', '+code : code;
            }
            throw new EXT_PSA_OpportunityProjectCreation_Exception(INVALID_COUNTRY_CODE+concatCodes);
        }
        countryCodeToRegionMap = new SLT_Region().selectRegionByCountryCode(countryCodeSet);
        countryCodeMappingMap = new SLT_PSA_CountryRegionMap().selectMappingsByCountryCode(countryCodeSet);

        ProjectHierarchy program = new ProjectHierarchy();

        //If project code is in use we must create under that program
        //Otherwise we can specify a program
        //Otherwise, it will create one
        String QIPprojectCode = projectData.get('project code').trim();
        Program__c programData = getProgramByProjectCode(QIPprojectCode);
        if(programData == null && programId != null){
            programData = new SLT_Program().selectByProgramId(new Set<Id>{programId}, FIELDS_PROGRAM);
        }
        if(programData != null){
            program.id = programData.Id;
            program.status = 'existing';
            program.name = programData.Name;
            if(createSObjects){
                Date reportStartDate = Date.valueOf(projectData.get('contract start date'));
                Date reportEndDate = Date.valueOf(projectData.get('contract end date'));
                Date startDate = (reportStartDate < programData.Start_Date__c) ? reportStartDate : programData.Start_Date__c;
                Date endDate = (reportEndDate > programData.End_Date__c) ? reportEndDate : programData.End_Date__c;
                program.obj = new Program__c(
                    Id=programData.Id,
                    Name=programData.Name,
                    Account__c=customer.Id,
                    Start_Date__c=startDate,
                    End_Date__c=endDate,
                    CurrencyIsoCode=programData.CurrencyIsoCode
                );
            }
            system.debug('Updated Program: '+program.name);
        } else {
            program.Id = String.valueOf(fakeId);
            fakeId++;
            program.status = 'new';
            program.name = makeName(customer.Name+' '+QIPprojectCode);
            if(createSObjects){
                Date reportStartDate = Date.valueOf(projectData.get('contract start date'));
                Date reportEndDate = Date.valueOf(projectData.get('contract end date'));
                program.obj = new Program__c(
                    Name=program.name,
                    Account__c=customer.Id,
                    Start_Date__c=reportStartDate,
                    End_Date__c=reportEndDate,
                    CurrencyIsoCode=projectData.get('currency')
                );
            }
            system.debug('Added Program: '+program.name);
        }
        program.recordType = '';
        program.objectType = 'Program';

        String opportunityStage = new SLT_Opportunity().getOpportunityById(new Set<Id>{opportunityId}, new Set<String>{'Id','StageName'}).get(opportunityId).StageName;
        String maxPlannedStage = PSA_RDS_Settings__c.getInstance().Max_Planned_Stage__c;
        ProjectHierarchy project = new ProjectHierarchy();
        project.name = makeName(customer.Name+' '+projectData.get('project code').trim()+'-Project');
        project.Id = String.valueOf(fakeId);
        fakeId++;
        project.status = 'new';
        project.recordType = 'RDS Project';
        project.objectType = 'Project';
        if(createSObjects){
            project.obj = new pse__Proj__c(
                Name=project.name,
                pse__Account__c=customer.Id,
                pse__Opportunity__c=opportunityId,
                pse__Region__c=projectRegion.Id,
                pse__Group__c=dssrGroup.Id,
                Project_Code__c=projectData.get('project code'),
                Project_Category__c=projectCategory,
                Contract_Type__c=projectData.get('contract type'),
                Budget_Type__c=projectData.get('budget type'),
                pse__Stage__c=(opportunityStage > maxPlannedStage) ? 'Start-up' : 'Planned',
                pse__Start_Date__c=Date.valueOf(projectData.get('contract start date')),
                pse__End_Date__c=Date.valueOf(projectData.get('contract end date')),
                Go_Live_Date__c=Date.valueOf(projectData.get('go-live date')),
                Close_Out_Date__c=Date.valueOf(projectData.get('close-out date')),
                pse__Billing_Type__c='Unit-Based',
                pse__Project_Type__c='Customer Project',
                pse__Is_Active__c=true,
                pse__Is_Billable__c=true,
                RecordTypeId=ProjectRecordTypeId,
                CurrencyIsoCode=projectData.get('currency'),
                Training_Required__c=true
            );
        }
        program.addChild(project);
        system.debug('Added Project: '+project.name+' to program '+program.name);

        ProjectHierarchy budget = new ProjectHierarchy();
        budget.id = String.valueOf(fakeId);
        fakeId++;
        budget.status = 'new';
        budget.name = makeName(customer.Name+' '+projectData.get('project code').trim());
        budget.changeOrder = isChangeOrder;
        if (isChangeOrder) {
            budget.name += ' CO'+projectData.get('change order number');
        }
        budget.name += '-Budget';
        budget.recordType = '';
        budget.objectType = 'Budget';
        if(createSObjects){
            String changeOrderNumber = (isChangeOrder) ? projectData.get('change order number') : null;
            if(budgetEffectiveDate == null){
                budgetEffectiveDate = Date.today();
            }
            budget.obj = new pse__Budget__c(
                Name=budget.name,
                pse__Account__c=customer.Id,
                pse__Opportunity__c=opportunityId,
                pse__Effective_Date__c=budgetEffectiveDate,
                pse__Amount__c=budgetAmount,
                Change_Order_Number__c=changeOrderNumber,
                pse__Description__c=projectData.get('change order description'),
                RecordTypeId=BudgetRecordTypeId,
                CurrencyIsoCode=projectData.get('currency')
            );
        }
        project.addChild(budget);
        system.debug('Added Budget: '+budget.name+' to project '+project.name);
        if(isChangeOrder){
            system.debug('This was a change order.');
        }


        for(Map<String,String> row : servicesSheet){
            List<String> serviceLineNameParts = new List<String>{customer.name+' ',projectData.get('project code')+' ', row.get('service line').trim()};
            //String serviceLineName = makeName(customer.name+' '+projectData.get('project code')+' '+row.get('service line').trim());
            String serviceLineName = row.get('service line').trim();
            //String serviceLineName = makeName(serviceLineNameParts,3,'middle','...');
            String serviceLineProjectName = makeName(new List<String>{customer.name+' ',projectData.get('project code')+' ',serviceLineName},3,'middle','...');
            System.debug('Looking for Service Line: '+serviceLineName);
            if(nameToServiceLineWrapperMap.get(serviceLineProjectName) == null ) {
                ProjectHierarchy serviceLine = new ProjectHierarchy();
                serviceLine.name = serviceLineProjectName;
                serviceLine.Id = String.valueOf(fakeId);
                fakeId++;
                serviceLine.status = 'new';
                serviceLine.recordType = 'RDS Service Line';
                serviceLine.objectType = 'Project';
                nameToServiceLineWrapperMap.put(serviceLineProjectName,serviceLine);
                if(createSObjects){
                    String serviceRefName = row.get('service line');
                    String countryCodeWithMostHours;
                    Decimal mostHours = 0.0;
                    //Get region for chosen country code
                    Map<String,Decimal> countryCodeToHoursMap = serviceLineToCountryHoursMap.get(serviceLineProjectName);
                    for(String countryCode : countryCodeToHoursMap.keySet()){
                        Decimal hoursForThisCode = countryCodeToHoursMap.get(countryCode);
                        if(hoursForThisCode != null && hoursForThisCode > mostHours){
                            mostHours = hoursForThisCode;
                            countryCodeWithMostHours = countryCode;
                        }
                    }
                    pse__Region__c serviceLineRegion = (countryCodeWithMostHours != null && countryCodeToRegionMap.get(countryCodeWithMostHours) != null)
                                                         ? countryCodeToRegionMap.get(countryCodeWithMostHours) : projectRegion;
                    Id serviceLineGroupId = (nameToServiceLineMap.get(serviceRefName).Group__c != null) ? nameToServiceLineMap.get(serviceRefName).Group__c : dssrGroup.Id;
                    serviceLine.obj = new pse__Proj__c(
                        Name=serviceLine.name,
                        pse__Account__c=customer.Id,
                        pse__Opportunity__c=opportunityId,
                        Service_Line__c=nameToServiceLineMap.get(serviceRefName).Id,
                        pse__Region__c=serviceLineRegion.Id,
                        pse__Group__c=serviceLineGroupId,
                        pse__Start_Date__c=serviceLineToStartDateMap.get(row.get('service line')),
                        pse__End_Date__c=serviceLineToEndDateMap.get(row.get('service line')),
                        Go_Live_Date__c=Date.valueOf(projectData.get('go-live date')),
                        Close_Out_Date__c=Date.valueOf(projectData.get('close-out date')),
                        pse__Is_Active__c=true,
                        pse__Stage__c=(opportunityStage > maxPlannedStage) ? 'Start-up' : 'Planned',
                        pse__Is_Billable__c=true,
                        RecordTypeId=ServiceLineRecordTypeId,
                        CurrencyIsoCode=projectData.get('currency'),
                        Training_Required__c=true
                    );
                }
                project.addChild(serviceLine);
                system.debug('Added Service Line Project: '+serviceLine.name+' to project '+project.name);
            }
            ProjectHierarchy currentServiceLine = nameToServiceLineWrapperMap.get(serviceLineProjectName);
            ProjectHierarchy serviceMilestone = new ProjectHierarchy();
            serviceMilestone.name = makeName(row.get('service').trim());
            serviceMilestone.id = String.valueOf(fakeId);
            fakeId++;
            serviceMilestone.status = 'new';
            serviceMilestone.objectType = 'Milestone';
            serviceMilestone.recordType = 'RDS Service';
            serviceMilestone.details.put('Budgeted Quantity',String.valueOf(Decimal.valueOf(row.get('quantity')).round()));
            if(createSObjects){
                //Service code comes from table unless it's a MISX
                //MISX
                String serviceRefName = row.get('service line');
                serviceMilestone.obj = new pse__Milestone__c(
                    Name=serviceMilestone.name,
                    Service__c=serviceCodeToServiceMap.get(row.get('service code')).Id,
                    Service_Line__c=nameToServiceLineMap.get(serviceRefName).Id,
                    Include_Tasks_on_Deliverables__c=serviceCodeToServiceMap.get(row.get('service code')).Include_Tasks_on_Deliverables__c,
                    Client_Grid_Name__c=row.get('client grid name'),
                    Client_Grid_Code__c=row.get('client grid code'),
                    pse__Status__c='Draft',
                    Start_Date__c=Date.valueOf(row.get('start date')),
                    End_Date__c=Date.valueOf(row.get('end date')),
                    pse__Target_Date__c=Date.valueOf(row.get('end date')),
                    Unit_of_Measure__c=row.get('unit of measure'),
                    Billing_Type__c=row.get('billing type'),
                    Budget_Quantity__c=Decimal.valueOf(row.get('quantity')).round(),
                    Countries__c=countryCodeMappingMap.get(row.get('country')).Country_Code_2_Char__c,
                    Unit_Price__c=Decimal.valueOf(row.get('unit price')),
                    Budget_Amount__c=Decimal.valueOf(row.get('amount')),
                    Budget_Hours__c=Decimal.valueOf(row.get('budgeted hours')),
                    RecordTypeId=MilestoneRecordTypeId,
                    CurrencyIsoCode=projectData.get('currency')
                );
            }
            currentServiceLine.addChild(serviceMilestone);
            system.debug('Added Service Milestone: '+serviceMilestone.name+' to service line '+currentServiceLine.name);
        }
        // We have tracked the hours for services and aggregated them by country and service line. Now for each service line, we pick the country with the most hours and get the region and set it on service line

        if(createSObjects){
            for(Map<String,String> row : tasksSheet){
                ProjectHierarchy hierarchyTask = new ProjectHierarchy();
                hierarchyTask.hidden = true;
                hierarchyTask.id = String.valueOf(fakeId);
                fakeId++;
                hierarchyTask.name = makeName(row.get('task name').trim());
                hierarchyTask.status = 'new';
                hierarchyTask.recordType = '';
                hierarchyTask.objectType = 'Pricing Task';
                Service__c taskPrimaryService = serviceCodeToServiceMap.get(row.get('primary service code'));
                Service__c taskService = serviceCodeToServiceMap.get(row.get('service code'));
                hierarchyTask.obj = new Pricing_Task__c(
                    Name=hierarchyTask.name,
                    Primary_Service__c=(taskPrimaryService != null) ? taskPrimaryService.Id : null,
                    Service__c=(taskService != null) ? taskService.Id : null,
                    Task_Id__c=projectData.get('project code')+'-'+row.get('task id'),
                    Budget_Hours__c=Decimal.valueOf(row.get('budget hours')),
                    Country__c=countryCodeMappingMap.get(row.get('country')).Country_Code_2_Char__c,
                    CurrencyIsoCode=projectData.get('currency')
                );
                //Project needs to get set when this is inserted
                project.addChild(hierarchyTask);
                system.debug('Added task: '+hierarchyTask.name+' to project '+project.name);
            }

            //Resource request creation init tasks
            Id genericResourceId = (Id)PSA_RDS_Settings__c.getInstance().Resource_Demand_Contact_ID__c;
            if(genericResourceId == null){
                throw new EXT_PSA_OpportunityProjectCreation_Exception(MISSING_GENERIC_RESOURCE);
            }

            for(Map<String,String> row : requestsSheet){
                //String serviceLineName = customer.name+' '+projectData.get('project code')+' '+row.get('service line');
                String serviceLineName = row.get('service line').trim();
                String serviceLineProjectName = makeName(new List<String>{customer.name+' ',projectData.get('project code')+' ',serviceLineName},3,'middle','...');
                ProjectHierarchy serviceLine = nameToServiceLineWrapperMap.get(serviceLineProjectName);
                if(serviceLine == null){
                    throw new EXT_PSA_OpportunityProjectCreation_Exception('Cannot find service line "' + row.get('service line') + '" for request '+row.get('resource request name'));
                }
                Id requestRegionId = (countryCodeToRegionMap.get(row.get('country')) != null)
                                                        ? countryCodeToRegionMap.get(row.get('country')).Id : ((pse__Proj__c)serviceLine.obj).pse__Region__c;

                system.debug('Resource Service Line - '+serviceLineName+' '+serviceLine);
                ProjectHierarchy hierarchyRequest = new ProjectHierarchy();
                hierarchyRequest.hidden = true;
                hierarchyRequest.id = String.valueOf(fakeId);
                fakeId++;

                //FTE-Related calculations
                Decimal FTE = (row.get('fte') != null && row.get('fte') != '') ? Decimal.valueOf(row.get('fte')) : 1.0; 
                Integer numberOfRequestRows = (FTE != null && FTE > 1.0) ? FTE.round(System.RoundingMode.CEILING).intValue() : 1;
                Decimal totalHours = Decimal.valueOf(row.get('hours'));
                Decimal hoursPerRequest = totalHours / numberOfRequestRows;
                Decimal requestedFTE = FTE / numberOfRequestRows;
                Decimal hoursPerFTE = totalHours / FTE;

                hierarchyRequest.name = (row.get('resource request name') != null) ? makeName(row.get('resource request name')) : makeName(row.get('psa resource request name'));
                hierarchyRequest.status = 'new';
                hierarchyRequest.recordType = 'RDS Request';
                hierarchyRequest.objectType = 'Resource Request';
                pse__Resource_Request__c requestObj = new pse__Resource_Request__c(
                    pse__Resource_Request_Name__c=hierarchyRequest.name,
                    pse__Opportunity__c=opportunityId,
                    pse__Region__c=requestRegionId,
                    pse__Group__c=((pse__Proj__c)serviceLine.obj).pse__Group__c,
                    Country__c=countryCodeMappingMap.get(row.get('country')).Country_Code_2_Char__c,
                    pse__Staffer_Resource__c=genericResourceId,
                    Requested_FTE__c=requestedFTE,
                    Hours_per_FTE__c=hoursPerFTE,
                    pse__SOW_Hours__c=hoursPerRequest,
                    pse__Resource_Held__c=true,
                    pse__Resource_Role__c=row.get('role'),
                    Job_Grade__c=row.get('iqvia job grade'),
                    pse__Start_Date__c=Date.valueOf(row.get('start date')),
                    pse__End_Date__c=Date.valueOf(row.get('end date')),
                    pse__Requested_Bill_Rate__c=Decimal.valueOf(row.get('bill rate')),
                    RecordTypeId=ResourceRequestRecordTypeId,
                    CurrencyIsoCode=projectData.get('currency')
                );
                hierarchyRequest.obj = requestObj;
                //Service line project needs to get set when this is inserted
                serviceLine.addChild(hierarchyRequest);
                system.debug('Added resource request: '+hierarchyRequest.name+' to service line '+serviceLine.name);
                system.debug('Values: '+hierarchyRequest.obj);
                
                //If it's a FTE > 1 request, we clone and increment names
                if( numberOfRequestRows > 1 ){
                    //Calculate hours etc
                    system.debug('RR: Building '+numberOfRequestRows+' resource requests.');
                    for(Integer i = 2; i <= numberOfRequestRows; i++){
                        ProjectHierarchy requestCopy = new ProjectHierarchy();
                        requestCopy.copy(hierarchyRequest, true, true);
                        requestCopy.name = makeName(requestCopy.name+' '+i);
                        requestCopy.obj.put('pse__Resource_Request_Name__c',requestCopy.name);
                        serviceLine.addChild(requestCopy);
                        system.debug('Added resource request: '+requestCopy.name+' to service line '+serviceLine.name);
                        system.debug('Values: '+requestCopy.obj);
                    }
                    hierarchyRequest.name = makeName(hierarchyRequest.name+' '+1);
                    hierarchyRequest.obj.put('pse__Resource_Request_Name__c',hierarchyRequest.name);
                }

                //Do RR Validations
                Integer numberOfWorkDays = UTL_OWF.findNoOfDays_exclude_weekend(requestObj.pse__Start_Date__c, requestObj.pse__End_Date__c, 0);
                Decimal hoursPerDay = (numberOfWorkDays == 0) ? 0 : requestObj.pse__SOW_Hours__c / numberOfWorkDays;

                if(hoursPerDay > 24.0) {
                    throw new EXT_PSA_OpportunityProjectCreation_Exception('Impossible to schedule resource "'+requestObj.pse__Resource_Request_Name__c+'" for '+hoursPerDay.setScale(2)+' hours in one day.');
                }
            }
        }

        System.debug('Finished creating new hierarhcy.');
        program.log();
        program.truncated = new List<String>(nameLengthWarnings);
        return program;
    }

    /**
     * Takes an old hierarchy and a new hierarchy and merges together, indicating add/remove/update status for items
     * This method requires you to set submit the old and new hierarchies with SObjects enabled, even if you don't want to return SObjects in the merged result
     */
    private static ProjectHierarchy mergeProjectHierarchies(ProjectHierarchy oldHierarchy, ProjectHierarchy newHierarchy, Boolean isChangeOrder) {
        if(oldHierarchy == null || oldHierarchy.getChildren().size() == 0){
            return newHierarchy;
        }

        if(oldHierarchy.obj == null || newHierarchy.obj == null){
            throw new EXT_PSA_OpportunityProjectCreation_Exception(HIERARCHY_MERGE_MISSING_SOBJECTS);
        }

        //Create a blank "Merged" hierarchy to return
        ProjectHierarchy mergedHierarchy = new ProjectHierarchy();

        //Map all items in new and old hierarchies using their unique keys
        Map<String,ProjectHierarchy> keyToNewHierarchyMap = new Map<String,ProjectHierarchy>();
        Map<String,ProjectHierarchy> keyToOldHierarchyMap = new Map<String,ProjectHierarchy>();

        //For error checking purposes, we gather any milestones we plan to delete
        Set<ProjectHierarchy> milestonesToCheckBeforeDelete = new Set<ProjectHierarchy>();

        //Fill the map from the new hierarchy
        System.debug('Collecting new hierarchy keys: ');
        for(ProjectHierarchy project : newHierarchy.getChildren()){
            if(project.obj == null){
                throw new EXT_PSA_OpportunityProjectCreation_Exception(HIERARCHY_MERGE_MISSING_SOBJECTS);
            }

            keyToNewHierarchyMap.put(project.key, project);

            for(ProjectHierarchy projectChild : project.getChildren()){
                if(projectChild.obj == null){
                    throw new EXT_PSA_OpportunityProjectCreation_Exception(HIERARCHY_MERGE_MISSING_SOBJECTS);
                }

                keyToNewHierarchyMap.put(projectChild.key, projectChild);

                for(ProjectHierarchy projectGrandChild : projectChild.getChildren()){
                    if(projectGrandChild.obj == null){
                        throw new EXT_PSA_OpportunityProjectCreation_Exception(HIERARCHY_MERGE_MISSING_SOBJECTS);
                    }

                    System.debug('*** '+projectGrandChild.key);
                    keyToNewHierarchyMap.put(projectGrandChild.key, projectGrandChild);

                }
            }
        }

        //Compare the sObjects for the programs
        Map<String,Object> programFieldsToValue = newHierarchy.obj.getPopulatedFieldsAsMap();
        if(objectHasChanged( newHierarchy.obj, oldHierarchy.obj, programFieldsToValue.keySet() )){
            newHierarchy.status = 'modified';
            System.debug('MERGE: Found difference between program '+newHierarchy.name+' and program '+oldHierarchy.name+'.');
        }

        //Copy over the program to the new hierarchy
        mergedHierarchy.copy(newHierarchy);
        System.debug('MERGE: Copied program ');

        //Go through the old hierarchy and copy it to the merged hierarchy one object at a time, marking any modified objects and copying the updated values in for them
        for(ProjectHierarchy oldProject : oldHierarchy.getChildren()){

            ProjectHierarchy mergedProject = new ProjectHierarchy();

            //Get corresponding project from new hierarchy, if it exists
            ProjectHierarchy newProject = keyToNewHierarchyMap.get(oldProject.key);

            System.debug('* '+oldProject.key);

            if(newProject == null){
                //If the old project doesn't match a new one, we deep copy the old project into the merged hierarchy
                mergedProject.copy(oldProject,true);
                mergedHierarchy.addChild(mergedProject);
                keyToOldHierarchyMap.put(mergedProject.key, mergedProject);
                System.debug('MERGE: Copied project tree for project '+mergedProject.name);
                continue;
            } else {

                if(newProject.obj.get('pse__Opportunity__c') != oldProject.obj.get('pse__Opportunity__c')){
                    //Opportunities must also match
                    throw new EXT_PSA_OpportunityProjectCreation_Exception(OPPORTUNITY_MISMATCH+oldProject.obj.get('Project_Code__c'));
                }

                //If projects match, determine if there are differences
                newProject.status = 'existing';
                Map<String,Object> projectFieldsToValue = newProject.obj.getPopulatedFieldsAsMap();
                if(objectHasChanged( newProject.obj, oldProject.obj, projectFieldsToValue.keySet() )){
                    newProject.status = 'modified';
                    newProject.id = oldProject.id;
                    System.debug('MERGE: Found difference between project '+newProject.name+' and project '+oldProject.name+'.');
                }

                //Copy over project (including differences, if found)
                if(newProject.status == 'modified'){
                    System.debug('MERGE: copying modified new project');
                    mergedProject.copy(newProject);
                    pse__Proj__c proj = (pse__Proj__c)oldProject.obj;
                    pse__Proj__c mProj = (pse__Proj__c)mergedProject.obj;
                    mProj.Id = proj.Id;
                    mProj.Program__c = proj.Program__c;
                    
                    //if change order, preserve stage
                    if(isChangeOrder){
                        mProj.pse__Stage__c = (String) oldProject.obj.get('pse__Stage__c');
                }
                } else {
                    System.debug('MERGE: copying unchanged old project');
                    mergedProject.copy(oldProject);
                }
            }

            System.debug('MERGE: merging copied project '+mergedProject.name+' into tree');
            mergedHierarchy.addChild(mergedProject);
            keyToOldHierarchyMap.put(mergedProject.key, mergedProject);

            //Check all the children of the existing project as well
            for(ProjectHierarchy oldProjectChild : oldProject.getChildren()){

                ProjectHierarchy mergedProjectChild = new ProjectHierarchy();
                ProjectHierarchy newProjectChild = keyToNewHierarchyMap.get(oldProjectChild.key);

                if(newProjectChild == null){
                    //Old objects that are not in the new project will be deleted (except for change orders)
                    mergedProjectChild.copy(oldProjectChild);
                    if(!isChangeOrder){
                        mergedProjectChild.status = 'deleted';
                        system.debug('MERGE: '+mergedProjectChild.objectType+' not found in new project. MARK FOR DELETE '+mergedProjectChild.name);
                    }

                } else {
                    //If they exist, we check to see if they are modified before copying them over
                    newProjectChild.status = 'existing';
                    Map<String,Object> budgetFieldsToValue = oldProjectChild.obj.getPopulatedFieldsAsMap();
                    if(objectHasChanged( newProjectChild.obj, oldProjectChild.obj, budgetFieldsToValue.keySet()) ){
                        newProjectChild.status = 'modified';
                        newProjectChild.id = oldProjectChild.id;
                        System.debug('MERGE: Found difference between '+newProjectChild.objectType+' '+newProjectChild.name+' and '+newProjectChild.objectType+' '+oldProjectChild.name+'.');
                    }

                    if(newProjectChild.status == 'modified'){
                        //Modified objects get updated from new hierarchy, then get some additional type-specific updates
                        System.debug('MERGE: Copying modified new '+oldProjectChild.objectType);
                        mergedProjectChild.copy(newProjectChild);

                        //A few actions and checks are object type specific
                        if(oldProjectChild.objectType == 'Budget'){
                            pse__Budget__c budg = (pse__Budget__c)oldProjectChild.obj;
                            pse__Budget__c mBudg = (pse__Budget__c)mergedProjectChild.obj;
                            mBudg.Id = budg.Id;
                            mBudg.pse__Project__c = budg.pse__Project__c;

                            if(newProjectChild.obj.get('pse__Opportunity__c') != oldProjectChild.obj.get('pse__Opportunity__c')){
                                //Opportunities must also match
                                throw new EXT_PSA_OpportunityProjectCreation_Exception(OPPORTUNITY_MISMATCH+oldProject.obj.get('Project_Code__c'));
                            }
                        }
                        else if(oldProjectChild.objectType == 'Pricing Task'){
                            Pricing_Task__c pTask = (Pricing_Task__c)oldProjectChild.obj;
                            Pricing_Task__c mPTask = (Pricing_Task__c)mergedProjectChild.obj;
                            mPTask.Id = pTask.Id;
                            mPTask.Project__c = pTask.Project__c;
                        }
                        else if(oldProjectChild.objectType  == 'Project'){
                            pse__Proj__c proj = (pse__Proj__c)oldProjectChild.obj;
                            pse__Proj__c mProj = (pse__Proj__c)mergedProjectChild.obj;
                            mProj.Id = proj.Id;
                            mProj.Program__c = proj.Program__c;
                            mProj.pse__Parent_Project__c = proj.pse__Parent_Project__c;

                            if(newProjectChild.obj.get('pse__Opportunity__c') != oldProjectChild.obj.get('pse__Opportunity__c')){
                                throw new EXT_PSA_OpportunityProjectCreation_Exception(OPPORTUNITY_MISMATCH+oldProject.obj.get('Project_Code__c'));
                            }
                            
                            //if change order, preserve stage
                    		if(isChangeOrder){
                        		mProj.pse__Stage__c = (String) oldProject.obj.get('pse__Stage__c');
                			}
                        }

                    } else {
                        //Unmodified objects get copied straight over from old hierarchy
                        System.debug('MERGE: Copying unchanged old '+oldProjectChild.objectType);
                        mergedProjectChild.copy(oldProjectChild);
                    }
                }

                System.debug('MERGE: merging project child '+mergedProjectChild.name+' into tree');
                mergedProject.addChild(mergedProjectChild);
                keyToOldHierarchyMap.put(mergedProjectChild.key, mergedProjectChild);

                //Perform the same process for the lowest level in the tree
                for(ProjectHierarchy oldProjectGrandChild : oldProjectChild.getChildren()){

                    ProjectHierarchy mergedProjectGrandChild = new ProjectHierarchy();
                    ProjectHierarchy newProjectGrandChild = keyToNewHierarchyMap.get(oldProjectGrandChild.key);

                    //NOTE: try not to be confused-- read this next block carefully
                    if(mergedProjectChild.status == 'deleted' || newProjectGrandChild == null){
                        //If the parent of the object was marked for deletion after performing the merge, we will copy that status down from the mergedProjectChild to the mergedProjectGrandChild
                        //We also copy down nodes that don't exist in the new project
                        mergedProjectGrandChild.copy(oldProjectGrandChild);

                        if(!isChangeOrder || newProjectGrandChild != null){
                            //Children of deleted nodes get deleted, as do missing nodes (provided we are NOT on a change order)
                            mergedProjectGrandChild.status = 'deleted';
                            system.debug('MERGE: child of deleted object of type '+mergedProjectGrandChild.objectType+'. MARK FOR DELETE '+mergedProjectGrandChild);

                            //Milestones need to be checked later, because they can't be deleted if they have deliverables on them already 
                            if(oldProjectGrandChild.objectType == 'Milestone'){
                                milestonesToCheckBeforeDelete.add(oldProjectGrandChild);
                            }
                        }

                    } else {

                        newProjectGrandChild.status = 'existing';
                        Map<String,Object> projectGrandChildFieldsToValue = newProjectGrandChild.obj.getPopulatedFieldsAsMap();
                        if(objectHasChanged( newProjectGrandChild.obj, oldProjectGrandChild.obj, projectGrandChildFieldsToValue.keySet()) ){
                            newProjectGrandChild.status = 'modified';
                            newProjectGrandChild.id = oldProjectGrandChild.id;
                            System.debug('MERGE: Found difference between '+newProjectGrandChild.objectType+' '+newProjectGrandChild.name+' and '+newProjectGrandChild.objectType+' '+oldProjectGrandChild.name+'.');
                        }

                        if(newProjectGrandChild.status == 'modified'){
                            System.debug('MERGE: Copying modified new '+newProjectGrandChild.objectType);
                            mergedProjectGrandChild.copy(newProjectGrandChild);

                            if(oldProjectGrandChild.objectType == 'Milestone'){
                                pse__Milestone__c mProj = (pse__Milestone__c)mergedProjectGrandChild.obj;
                                pse__Milestone__c proj = (pse__Milestone__c)oldProjectGrandChild.obj;
                                mProj.Id = proj.Id;
                                mProj.pse__Project__c = proj.pse__Project__c;
                            }

                            if(oldProjectGrandChild.objectType == 'Resource Request'){
                                pse__Resource_Request__c req = (pse__Resource_Request__c)oldProjectGrandChild.obj;
                                pse__Resource_Request__c mReq = (pse__Resource_Request__c)mergedProjectGrandChild.obj;
                                mReq.Id = req.Id;
                                mReq.pse__Project__c = req.pse__Project__c;
                            }

                        } else {
                            System.debug('MERGE: Copying unchanged old '+newProjectGrandChild.objectType);
                            mergedProjectGrandChild.copy(oldProjectGrandChild);
                        }

                    }

                    System.debug('MERGE: merging project grand child '+mergedProjectGrandChild.name+' into tree');
                    mergedProjectChild.addChild(mergedProjectGrandChild);
                }
            }
        }
        //Find any objects in the new hierarchy that are not in the old hierarchy at all and place in appropriate slot in merged hierarchy
        System.debug('MERGE: Searching for new items to merge into tree');
        for(ProjectHierarchy project : newHierarchy.getChildren()){
            if(project.status == 'new'){
                ProjectHierarchy newProject = new ProjectHierarchy();
                newProject.copy(project,true);
                mergedHierarchy.addChild(newProject);
                System.debug('MERGE: Merged new project and children: '+newProject.name);
                continue;
            }

            ProjectHierarchy mergedParent = keyToOldHierarchyMap.get(project.key);
            if(mergedParent == null){
                System.debug('MERGE: Could not find merged copy of '+project.name+' with id '+project.id);
                System.debug('MERGE: '+project);
                continue;
            }
            System.debug('MERGE: Got parent for merged items: '+mergedParent.name);

            for(ProjectHierarchy projectChild : project.getChildren()){
                System.debug('MERGE: Finding home for child: '+projectChild.name+'...');
                //System.debug('MERGE: Project listing - '+nameToOldServiceLineMap.keySet());
                if(projectChild.status == 'new'){
                    ProjectHierarchy newProjectChild = new ProjectHierarchy();
                    newProjectChild.copy(projectChild,true);
                    mergedParent.addChild(newProjectChild);
                    System.debug('MERGE: merged new child '+newProjectChild.name+' into parent '+mergedParent.name);
                    continue;
                }

                //Anything not new or not a project we can ignore
                if(projectChild.objectType == 'Project'){

                    ProjectHierarchy mergedChild = keyToOldHierarchyMap.get(projectChild.key);
                    if(mergedChild == null){
                        System.debug('MERGE: Could not find merged copy of '+projectChild.name);
                        System.debug('MERGE: '+projectChild);
                        continue;
                    }
                    System.debug('MERGE: Got parent for merged items: '+mergedChild);

                    for(ProjectHierarchy projectGrandChild : projectChild.getChildren()){
                        system.debug('MERGE: Grand Child: '+projectGrandChild.name);
                        if(projectGrandChild.status == 'new'){
                            ProjectHierarchy newProjectGrandChild = new ProjectHierarchy();
                            newProjectGrandChild.copy(projectGrandChild,true);
                            mergedChild.addChild(newProjectGrandChild);
                            System.debug('MERGE: merged new grandchild '+newProjectGrandChild.name+' into parent '+mergedChild.name);
                            continue;
                        }
                    }
                }

            }
        }

        //Check any milestones marked for delete to make sure they have no deliverables on them
        if(milestonesToCheckBeforeDelete.size() > 0){
            System.debug('Checking '+milestonesToCheckBeforeDelete.size()+' milestones for attached deliverables before deleting');
            Set<String> errorReportingFields = new Set<String>{'Id', 'Program__r.Name','Service_Line__r.Name', 'Service__r.Name',  'Name' };
            Set<String> milestoneIds = new Set<String>();
            for(ProjectHierarchy milestone : milestonesToCheckBeforeDelete){
                milestoneIds.add(milestone.id);
            }
            List<pse__Project_Task__c> deliverablesOnDeletedMilestones = new SLT_Project_Task().getDeliverableByServiceMilestone(milestoneIds, errorReportingFields);
            if(deliverablesOnDeletedMilestones.size() > 0){
                String badServices = '';
                for(pse__Project_Task__c task : deliverablesOnDeletedMilestones){
                    if(badServices != ''){
                        badServices += ', ';
                    }
                    badServices += task.Service_Line__r.Name+'/'+task.Service__r.Name;
                }
                System.debug('Found '+deliverablesOnDeletedMilestones.size()+' deliverables that prevent milestone deletion.');
                throw new EXT_PSA_OpportunityProjectCreation.EXT_PSA_OpportunityProjectCreation_Exception('Cannot delete services that have deliverables on them. Please remove deliverables from the following services: '+badServices);
            }
        }

        System.debug('Finished merging hierarchies.');
        mergedHierarchy.log();
        return mergedHierarchy;
    }

    static void validateReportFormat(Map<String,List<Map<String,String>>> psaReport){
        if(psaReport == null){
            throw new EXT_PSA_OpportunityProjectCreation.EXT_PSA_OpportunityProjectCreation_Exception('Attempted to validate a null PSA Report.');
        }
        Set<String> projectHeaders = (psaReport.get('project').size() > 0) ? psaReport.get('project').get(0).keySet() : null;
        Set<String> servicesHeaders = (psaReport.get('services').size() > 0) ? psaReport.get('services').get(0).keySet() : null;
        Set<String> requestsHeaders = (psaReport.get('resources').size() > 0) ? psaReport.get('resources').get(0).keySet() : null;
        Set<String> tasksHeaders = (psaReport.get('tasks').size() > 0) ? psaReport.get('tasks').get(0).keySet() : null;

        Set<String> projectUnused = new Set<String>{'customer name', 'project name', 'lead country'};
        Set<String> projectRequired = new Set<String>{'budget type', 'contract type', 'contract start date', 'contract end date', 'go-live date', 'close-out date',	'project code',	'project category', 'is change order',	'change order number', 'change order description', 'currency', 'qip template name', 'pricing tool version',	'version date',	'region' };
        Set<String> servicesUnused = new Set<String>{'business unit'};
        Set<String> servicesRequired = new Set<String>{'service code', 'service line', 'service', 'country', 'start date', 'end date', 'unit of measure', 'billing type', 'quantity', 'unit price', 'amount', 'budgeted hours', 'client grid code', 'client grid name'};
        Set<String> requestsUnused = new Set<String>{'business unit', 'job grade'};
        Set<String> requestsRequired = new Set<String>{'resource request name', 'service line', 'country',  'role', 'iqvia job grade', 'start date', 'end date', 'hours', 'bill rate'};
        Set<String> tasksUnused = new Set<String>{'service name', 'hourly price table rate', 'adjusted hourly price table rate', 'include in tasks'};
        Set<String> tasksRequired = new Set<String>{'task id', 'country', 'service code', 'primary service code', 'task name', 'budget hours'};
        
        for(String header : projectHeaders){
           System.debug(LoggingLevel.INFO, ' **** projectHeaders ' + header);
        }

        if(projectHeaders == null){
            throw new EXT_PSA_OpportunityProjectCreation.EXT_PSA_OpportunityProjectCreation_Exception('Report must contain project information on the Project tab.');
        }
        for(String header : projectRequired){
            if(!projectHeaders.contains(header)){
                System.debug(LoggingLevel.INFO, ' **** header ' + header);
                throw new EXT_PSA_OpportunityProjectCreation.EXT_PSA_OpportunityProjectCreation_Exception('Report must contain a column called '+header+' on the Project tab.');
            }
        }
        if(servicesHeaders == null){
            throw new EXT_PSA_OpportunityProjectCreation.EXT_PSA_OpportunityProjectCreation_Exception('Report must contain services sold on the Services tab.');
        }
        for(String header : servicesRequired){
            if(!servicesHeaders.contains(header)){
                throw new EXT_PSA_OpportunityProjectCreation.EXT_PSA_OpportunityProjectCreation_Exception('Report must contain a column called '+header+' on the Services tab.');
            }
        }
        if(tasksHeaders != null){
            for(String header : tasksRequired){
                if(!tasksHeaders.contains(header)){
                    throw new EXT_PSA_OpportunityProjectCreation.EXT_PSA_OpportunityProjectCreation_Exception('Report must contain a column called '+header+' on the Tasks tab.');
                }
            }
        }
        if(requestsHeaders != null){
            for(String header : requestsRequired){
                if(!requestsHeaders.contains(header)){
                    throw new EXT_PSA_OpportunityProjectCreation.EXT_PSA_OpportunityProjectCreation_Exception('Report must contain a column called '+header+' on the Requests tab.');
                }
            }
        }
    }

    private static Set<String> excludedChangeFields = new Set<String>{'Id', 'Program__c', 'pse__Project__c', 'pse__Parent_Project__c', 'Project__c', 'Service_Line_Project__c'};
    private static Boolean objectHasChanged(sObject obj1, sObject obj2, Set<String> fieldNames){
        for(String fieldName : fieldNames){
            String value1, value2;

            if((obj1.get(fieldName) instanceof Decimal) || (obj2.get(fieldName) instanceof Decimal)){
                value1 = ((Decimal)obj1.get(fieldName)).format();
                value2 = ((Decimal)obj2.get(fieldName)).format();
            } else {
                value1 = (obj1.get(fieldName) == null) ? '' : String.valueOf(obj1.get(fieldName));
                value2 = (obj2.get(fieldName) == null) ? '' : String.valueOf(obj2.get(fieldName));
            }

            
            if( !excludedChangeFields.contains(fieldName) && 
                value1 != value2){
                system.debug('"'+fieldName+'" changed! ['+value1+'] vs ['+value2+']');
                return true;
            }
        }
        return false;
    }

    public class ProjectHierarchy {
        public String    id;
        public Boolean  hidden = false;
        public Boolean  changeOrder = false;
        public String    objectType {
            get;
            set {
                this.objectType = value;
                switch on this.objectType {
                    when 'Program' {
                        this.iconName = 'custom68';
                    }
                    when 'Project' {
                        this.iconName = 'custom44';
                    }
                    when 'Milestone' {
                        this.iconName = 'custom79';
                    }
                    when 'Budget' {
                        this.iconName = 'custom41';
                    }
                    when else {
                        this.iconName = 'custom8';
                    }
                }
            }
        }

        //A key is a unique identifier for this object, based on the project, service line, service, etc.
        public String    key {
            get {
                if(this.obj == null){
                    throw new EXT_PSA_OpportunityProjectCreation.EXT_PSA_OpportunityProjectCreation_Exception('Tried to read key of ProjectHierarchy when object data had not been loaded.');
                }
                switch on this.objectType {
                    when 'Program' {
                        return this.name;
                    }
                    when 'Project' {
                        pse__Proj__c projObject = (pse__Proj__c)this.obj;
                        return (this.recordType == 'RDS Project') ? this.parentKey+':'+projObject.Project_Code__c : this.parentKey+':'+projObject.Service_Line__c;
                    }
                    when 'Milestone' {
                        pse__Milestone__c msObject = (pse__Milestone__c)this.obj;
                        if(msObject.Unit_Price__c == null){
                            throw new EXT_PSA_OpportunityProjectCreation_Exception('Milestone '+this.parentName+' / '+msObject.Name+' is missing required field Unit Price.');
                        }
                        system.debug('Parent Key:: '+this.parentKey);
                        return this.parentKey+':'+msObject.Service__c+msObject.Name+':'+msObject.Countries__c;
                    }
                    when 'Budget' {
                        return this.parentKey+':'+this.name;
                    }
                    when 'Pricing Task' {
                        Pricing_Task__c taskObject = (Pricing_Task__c)this.obj;
                        return this.parentKey+':'+taskObject.Task_Id__c;
                    }
                    when 'Resource Request' {
                        pse__Resource_Request__c reqObject = (pse__Resource_Request__c)this.obj;
                        return this.parentKey+':'+this.name+':'+reqObject.Job_Grade__c+':'+reqObject.Country__c;
                    }
                    when else {
                        return this.parentKey+':'+this.name;
                    }
                }
            }
        }
        public String    recordType;
        public String    name;
        public String    iconName;
        public String    status;
        private String   parentKey;
        private String   parentName;
        private String   rootKey;
        private Map<String,ProjectHierarchy> index;
        public List<ProjectHierarchy> children {get; private set;}
        public Map<String,String> details;
        public SObject   obj;
        public List<String> truncated;

        public ProjectHierarchy() {
            this.children = new List<ProjectHierarchy>();
            this.details = new Map<String,String>();
            this.truncated = new List<String>();
            this.parentKey = '';
            this.parentName = '';
        }

        public void addChild(ProjectHierarchy child){
            //Eventually, set root key, for index
            child.parentKey = (this.obj == null) ? this.name : this.key;
            child.parentName = this.name;
            this.children.add(child);
        }

        public List<ProjectHierarchy> getChildren(){
            return this.children.clone();
        }

        /*
         Search this hierarchy by key and return the node that has a matching key
         This could be optimized if needed by building a map of keys as children get added
         */
         public ProjectHierarchy findByKey(String key){
             if(this.key == key){
                 return this;
             }
             for(ProjectHierarchy child : this.children){
                ProjectHierarchy childWithMatchingKey = child.findByKey(key);
                if(childWithMatchingKey != null){
                    return childWithMatchingKey;
                }
             }
             return null;
         }

        /*
         * Applies the values from the supplied Project Hierarchy
         */
        public void copy(ProjectHierarchy toCopy){
            this.copy(toCopy, false);
        }

        public void copy(ProjectHierarchy toCopy, Boolean copyChildren){
            this.copy(toCopy, copyChildren, false);
        }
        public void copy(ProjectHierarchy toCopy, Boolean copyChildren, Boolean newInstance){
            this.id = toCopy.id;
            this.hidden = toCopy.hidden;
            this.objectType = toCopy.objectType;
            this.recordType = toCopy.recordType;
            this.name = toCopy.name;
            this.iconName = toCopy.iconName;
            this.status = toCopy.status;
            this.truncated = toCopy.truncated;
            for(String detail : toCopy.details.keySet()){
                if(this.details.get(detail) != null){
                    this.details.put(detail+' (old)', toCopy.details.get(detail));
                }
                this.details.put(detail, toCopy.details.get(detail));
            }

            if(toCopy.obj != null){
                this.obj = (newInstance) ? toCopy.obj.clone(false,true,false,false) : toCopy.obj.clone(true,false,true,true);
            }

            if(copyChildren){
                //Note: this will REPLACE this object's children with copies of the source's children
                this.children.clear();
                for(ProjectHierarchy child : toCopy.children){
                    ProjectHierarchy newChild = new ProjectHierarchy();
                    this.addChild(newChild);
                    newChild.copy(child,copyChildren,newInstance);
                }
            }
        }

        public void log(){
            this.log(0);
        }

        public void log(Integer currentDepth){
            if(currentDepth == 0){
                system.debug('Project Hierarchy: ');
            }
            String indent = '';
            for(Integer i=0;i<currentDepth;i++){
                indent+='=';
            }
            String name = (this.obj == null) ? this.name : this.key;
            system.debug(indent+this.objectType+' ('+this.status+') - '+name);
            for(ProjectHierarchy child : this.children){
                child.log(currentDepth+1);
            }
        }
    }

    private static Date makeDate(String excelDate){
        return makeDate(excelDate, MISSING_PROJECT_DATE);
    }
    private static Date makeDate(String excelDate, String errorMessage){
        if( excelDate == null || excelDate == '' ) {
                throw new EXT_PSA_OpportunityProjectCreation_Exception(errorMessage);
        }
        Integer year = Integer.valueOf(excelDate.subString(0,4));
        Integer month = Integer.valueOf(excelDate.subString(5,7));
        Integer day = Integer.valueOf(excelDate.subString(8,10));
        return Date.newInstance(year,month,day);
    }

    /**
     * Name creation respects limits of name field
     * A single string or a series of strings to concatenate can be submitted
     * It can be customized to truncate in different styles:
     * 'start', 'middle', 'end'
     * And the substitution character can be specified as well
     */
    private static Set<String> nameLengthWarnings = new Set<String>();
    private static String makeName(String input) {
        return makeName(new List<String>{input},1,'end','...');
    }
    private static String makeName(List<String> parts, Integer partToTruncate, String style, String substitution){
        Integer partIndex = partToTruncate-1;
        String name = String.join(parts,'');
        if(name.length() > NAME_MAX_LENGTH) {
            nameLengthWarnings.add(name);
            String toTruncate = parts.get(partIndex);
            Integer numCharToRemove = name.length()+substitution.length()-NAME_MAX_LENGTH;
            if(style == 'start'){
                parts[partIndex] = substitution+toTruncate.substring(numCharToRemove);
            } else if(style == 'end'){
                parts[partIndex] = toTruncate.substring(0,name.length()-numCharToRemove).trim()+substitution;
            } else if(style == 'middle'){
                Integer part1Length = (toTruncate.length() - numCharToRemove)/2; 
                String part1 = toTruncate.substring(0,part1Length);
                String part2 = toTruncate.substring(part1Length+numCharToRemove);
                parts[partIndex] = part1+substitution+part2;
            }
            return String.join(parts,'');
        }
        return name;
    }

    /**
     * Exception class for EXT_PSA_OpportunityProjectCreation
     */
    public class EXT_PSA_OpportunityProjectCreation_Exception extends Exception {}
} 
