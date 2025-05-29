/*
 * Version       : 1.0
 * Description   : Apex Controller for custom Project Metrics page
 * test class : TST_CNT_PSA_ProjectMetric
 */
public with sharing class CNT_PSA_ProjectMetric {
    public static final String MONTHLY = 'Monthly';
    public static  final String QUARTERLY = 'Quarterly';
    public static final String SEMI_ANNUALLY = 'Semi_Annual';
    public static List<String> SHOW_PERCENTAGE = new List<String>{'Percent', 'Inverse Percent'};
    /*
     * Retrieves Project Metrics for a specific project
     * {projectId} - String value for the project id
     * returns ActionResult records of ProjectMetricWrappers
     * throws AuraHandledException on error
     */
    @AuraEnabled(cacheable=true) 
    public static ActionResult getMetrics (String projectId, String protocolName, String frequency, String serviceLineId, String retired, String clientFacing,String all, String category, String nonStandard) {
        ActionResult actionResult = new ActionResult();
        String andConditions = '';
        try {
            andConditions = 'Project__c = \'' + projectId + '\' ';
            // by protocol name
            if(String.isNotEmpty(protocolName)) {
                andConditions += ' AND Protocol_Name__c = \'' + protocolName + '\' ';
            }
            if(String.isNotEmpty(frequency)) {
                andConditions += ' AND Frequency__c = \'' + frequency + '\' ';
            }
            if(String.isNotEmpty(serviceLineId)) {
                andConditions += ' AND PSA_Metric__r.Service_Line__c = \'' + serviceLineId + '\' ';
            }
            
            
            if(String.isNotEmpty(category)) {
                andConditions += ' AND PSA_Metric__r.Category__c = \'' + category + '\' ';
            }
            if(String.isNotEmpty(all)) {
                if( all.equalsIgnoreCase('true')){
                    andConditions+= '';
                }else{
                    if(String.isNotEmpty(retired)) {
                        andConditions += ' AND Retired__c = ' + retired ;
                    } 
                                
                    if(String.isNotEmpty(clientFacing)) {
                        andConditions += ' AND Client_Facing__c = ' + clientFacing ;
                    }
                    
                    if(String.isNotEmpty(nonStandard)) {
                        andConditions += ' AND Non_Standard__c = ' + nonStandard ;
                    }
                }
            }else{
                if(String.isNotEmpty(retired)) {
                    andConditions += ' AND Retired__c = ' + retired ;
                } 
                            
                if(String.isNotEmpty(clientFacing)) {
                    andConditions += ' AND Client_Facing__c = ' + clientFacing ;
                }
                if(String.isNotEmpty(nonStandard)) {
                    andConditions += ' AND Non_Standard__c = ' + nonStandard ;
                }   
            }
            actionResult.records = findProjectMetricWrappersBy(andConditions);
        } catch (Exception e) {
            raise(e);
        }
        return actionResult;
    }

    /*
     * Retrieves Active PSA Metrics to add to the project
     * returns ActionResult records of PsaMetricWrappers
     */
    @AuraEnabled(cacheable=true)
    public static ActionResult getActivePsaMetrics () {
        ActionResult actionResult = new ActionResult();
        SLT_PSA_Metric psaMetricService = new SLT_PSA_Metric(false);
        try {
            // specify the psa metric fields to retrieve
            Set<String> fields = psaMetricService.getSObjectFieldSet();
            fields.add('Service_Line__r.Name');
            fields.add('Account__r.Name');
            fields.add('Non_Standard__c');
            fields.add('Effective_Date__c');
            fields.add('Denominator_Ignored_on_Entry__c');
            // fetch, wrap, and return data
            PSA_Metric__c[] activeMetrics = psaMetricService.findBy(fields, 'Active__c = TRUE');
            if (activeMetrics != null && activeMetrics.size() > 0) {
                for (PSA_Metric__c psaMetric : activeMetrics) {
                    actionResult.records.add(new PsaMetricWrapper(psaMetric));
                }
            }
        } catch (Exception e) {
            raise(e);
        }
        return actionResult;
    }

    /*
     * Obtains the filtered manual metrics for the filtered data
     *
     * {projectId} - String value for the metrics project id,
     * {freqnecy} - String value for the metric frequency to filter
     * {serviceLineId} - String value for the service line id to filter
     * {location} - String value for the location to filter
     * {rangeStart} - Date value for the starting date range to filter
     * {rangeEnd} - Date value for the ending date range to filter
     *
     * returns ActionResult records of manual metrics and items of frequency columns
     * throws AuraHandledException on error
     */
    @AuraEnabled(cacheable=true)
    public static ActionResult getManualMetrics (String projectId, String frequency, String serviceLineId, String location, Date rangeStart, Date rangeEnd, String protocolName, String lastReviewedMonth) {
        ActionResult actionResult = new ActionResult();
        String lastReviewQueryString = '';
        if(lastReviewedMonth == 'Yes'){
            lastReviewQueryString = ' AND Last_reviewed_Month__c != null';
        }else if(lastReviewedMonth == 'No'){
            lastReviewQueryString = 'AND Last_reviewed_Month__c = null';
        }
        rangeStart = rangeStart != null ? rangeStart.toStartOfMonth() : Date.today().toStartOfMonth();
        rangeEnd = rangeEnd != null ? rangeEnd: rangeStart.addMonths(12);
        if (rangeStart == null || (rangeEnd != null && rangeStart > rangeEnd)) {
            // invalid date!
            return actionResult;
        }
        Boolean isQuarterly = frequency != null && frequency == QUARTERLY;
        Boolean isSemiAnnually = frequency != null && frequency == SEMI_ANNUALLY;

        try {
            // build conditions for retrieving filtered not retired project manaul metrics
            String[] conditions = new String[]{
                'Project__c = \'' + projectId + '\'',
                'Automated__c = FALSE',
                'Frequency__c = \'' + frequency + '\'',
                'Retired__c = FALSE '+lastReviewQueryString
            };
            // by service line id when available
            if (String.isNotEmpty(serviceLineId)) {
                conditions.add(' PSA_Metric__r.Service_Line__c = \'' + serviceLineId + '\' ');
            }
            // by location when available
            if (String.isNotEmpty(location)) {
                conditions.add(' Location__c = \'' + location + '\' ');
            }
            // by protocol name
            if(String.isNotEmpty(protocolName)) {
                conditions.add(' Protocol_Name__c = \'' + protocolName + '\' ');
            }
            String projMetricConditions = String.join(conditions, ' AND ');

            // load the non-automated / manual project metrics
            ProjectMetricWrapper[] projectMetrics = findProjectMetricWrappersBy(projMetricConditions);
            Map<Id, ProjectMetricWrapper> metricWrappers = new Map<Id, ProjectMetricWrapper>();

            // now gather project metric ids for retrieving actuals and inject into wrapper
            if (projectMetrics != null && projectMetrics.size() > 0) {
                for (ProjectMetricWrapper pmw : projectMetrics) {
                    pmw.metricActuals = new ProjectMetricActualWrapper[]{}; // initialize!
                    metricWrappers.put(pmw.id, pmw);
                }

                // load actuals by project metric ids and range!
                if (metricWrappers != null && metricWrappers.size() > 0) {
                    if (isQuarterly) {
                        // when frequency is quarterly, use the current quarter starting date as the beginning range
                        rangeStart = toStartOfQuarter(rangeStart); // quarterly range start
                    } else if (isSemiAnnually) {
                        rangeStart = toStartOfSemiAnnual(rangeStart); // semi-anual range start
                    }

                    SLT_Project_Metric_Actual projMetricActualService = new SLT_Project_Metric_Actual(false);
                    projMetricActualService.selectFields.add('PSA_Metric__r.Output_Data_Type__c');
                    projMetricActualService.selectFields.add('PSA_Metric__r.Calculation_Required__c');
                    projMetricActualService.selectFields.add('PSA_Metric__r.Denominator_Ignored_on_Entry__c');
                    projMetricActualService.selectFields.add('PSA_Metric__r.Numerator__c');
                    projMetricActualService.selectFields.add('PSA_Metric__r.Denominator__c');
                    projMetricActualService.selectFields.add('PSA_Metric__r.Frequency__c');

                    Project_Metric_Actual__c[] pmactuals = projMetricActualService.findByProjectMetricIdsAndRange(metricWrappers.keySet(), rangeStart, rangeEnd);

                    // transform and inject actuals into wrappers!
                    if (pmactuals != null && pmactuals.size() > 0) {
                        for (Project_Metric_Actual__c actual : pmactuals) {
                            ProjectMetricWrapper wrapper = metricWrappers.get(actual.Project_Metric__c);
                            if (wrapper != null) {
                                wrapper.metricActuals = wrapper.metricActuals != null ? wrapper.metricActuals : new ProjectMetricActualWrapper[]{};
                                wrapper.metricActuals.add(new ProjectMetricActualWrapper(actual));
                            }
                        }
                    }
                }
            }
            actionResult.records = metricWrappers.values();

            // build months / quarters for our columns and add to result
            if (actionResult.records != null && actionResult.records.size() > 0) {
                Date loopStart = rangeStart;
                Date loopEnd = rangeEnd;

                if (isQuarterly) {
                    // handle Quarterly!
                    MonthlyColumn[] monthlyColumns = new MonthlyColumn[]{};
                    while (loopStart <= rangeEnd) {
                        String fieldName = DateTime.newInstance(loopStart.year(),loopStart.month(),loopStart.day()).format('yyyy-MM-dd');
                        String label = buildQuarterlyLabel(loopStart) + '-' + DateTime.newInstance(loopStart.year(),loopStart.month(),loopStart.day()).format('yy');
                        monthlyColumns.add(new MonthlyColumn(fieldName, label));
                        loopStart = loopStart.addMonths(3);
                    }
                    actionResult.items.put('monthlyColumns', monthlyColumns);
                } else if (isSemiAnnually) {
                    // handle semi-annual!\
                    MonthlyColumn[] monthlyColumns = new MonthlyColumn[]{};
                    while (loopStart <= rangeEnd) {
                        String fieldName = DateTime.newInstance(loopStart.year(),loopStart.month(),loopStart.day()).format('yyyy-MM-dd');
                        String label = buildQuarterlyLabel(loopStart) + '-' + DateTime.newInstance(loopStart.year(),loopStart.month(),loopStart.day()).format('yy');
                        monthlyColumns.add(new MonthlyColumn(fieldName, label));
                        loopStart = loopStart.addMonths(6);
                    }
                    actionResult.items.put('monthlyColumns', monthlyColumns);
                } else {
                    // handle monthly
                    MonthlyColumn[] monthlyColumns = new MonthlyColumn[]{};
                    while (loopStart <= loopEnd) {
                        String fieldName = DateTime.newInstance(loopStart.year(),loopStart.month(),loopStart.day()).format('yyyy-MM-dd');
                        String label = DateTime.newInstance(loopStart.year(),loopStart.month(),loopStart.day()).format('MMM-yy');
                        monthlyColumns.add(new MonthlyColumn(fieldName, label));
                        loopStart = loopStart.addMonths(1);
                    }
                    actionResult.items.put('monthlyColumns', monthlyColumns);
                }
            }
        } catch (Exception e) {
            raise(e);
        }
        return actionResult;
    }

    /*
     * Obtains manual Metrics Frequency picklist values used in the specific projects manual metrics
     * {projectId} - String value for the specific project id
     * returns ActionResult items of project frequency options
     * throws AuraHandledException on error
     */
    @AuraEnabled(cacheable=true)
    public static ActionResult getProjectFrequencyOptions (String projectId) {
        ActionResult actionResults = new ActionResult();
        try {
            // specify project metric service fields and conditions
            SLT_Project_Metric projMetricService = new SLT_Project_Metric(false);
            Set<String> fields = new Set<String>{'Id', 'Project__c', 'PSA_Metric__c', 'PSA_Metric__r.Frequency__c'};
            String conditions = 'Project__c = \'' + projectId + '\' AND Automated__c = FALSE';

            // fetch, collect, then return data
            Set<String> psaMetricFreqs = new Set<String>();
            Project_Metric__c[] projMetrics = projMetricService.findBy(fields, conditions);
            if (projMetrics != null && projMetrics.size() > 0) {
                for (Project_Metric__c projMetric : projMetrics) {
                    psaMetricFreqs.add(projMetric.PSA_Metric__r.Frequency__c);
                }
            }
            actionResults.items.put('projectFrequencyOptions', psaMetricFreqs);
            // actionResults.records = new List<String>(psaMetricFreqs);
        } catch (Exception error) {
            raise(error);
        }
        return actionResults;
    }

    /*
     * Obtains manual metric history records
     *
     * {projectId} - String value for the metrics project id,
     * {freqnecy} - String value for the metric frequency to filter
     * {serviceLineId} - String value for the service line id to filter
     * {location} - String value for the location to filter
     * {rangeStart} - Date value for the starting date range to filter
     * {rangeEnd} - Date value for the ending date range to filter
     *
     * returns ActionResult records of history records
     * throws AuraHandledException on error
     */
    @AuraEnabled(cacheable=true)
    public static ActionResult getManualMetricsHistory (String projectId, String frequency, String serviceLineId, String location, Date rangeStart, Date rangeEnd) {
        ActionResult actionResult = new ActionResult();
        try {
            SLT_Project_Metric_Actual_History historyService = new SLT_Project_Metric_Actual_History(false);
            Project_Metric_Actual__History[] histories = historyService.findByProjectIdAndRange(projectId, frequency, serviceLineId, rangeStart, rangeEnd);
            if (histories != null && histories.size() > 0) {
                for (Project_Metric_Actual__History history : histories) {
                    actionResult.records.add(new ProjectMetricActualHistoryWrapper(history));
                }
            }
        } catch (Exception e) {
            raise(e);
        }
        return actionResult;
    }

    /*
     * Updates or inserts project metric actual records
     * {wrapper} - a ProjectMetricActualWrapper instance to save or update
     * returns ActionResult items of saved record ids on success
     * throws AuraHandledException on error
     */
    @AuraEnabled(cacheable=false)
    public static ActionResult saveMetricActual (ProjectMetricActualWrapper wrapper) {
        ActionResult actionResult = new ActionResult();

        if (wrapper != null) {
            try {
                Project_Metric_Actual__c toStore = new Project_Metric_Actual__c();
                if (wrapper.id != null) {
                    toStore.Id = wrapper.id;
                } else {
                    toStore.Project__c        = wrapper.projectId;
                    toStore.Project_Metric__c = wrapper.projectMetricId;
                    toStore.PSA_Metric__c     = wrapper.psaMetricId;
                }
                toStore.Quantity__c    = wrapper.quantity;
                toStore.Comments__c    = wrapper.comments;
                toStore.Numerator__c   = wrapper.numerator;
                toStore.Denominator__c = wrapper.denominator;

                // parse date
                toStore.Date__c = Date.valueOf(wrapper.recordDateKey);

                // now save it!
                fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(new List<SObjectType> { Project_Metric_Actual__c.SObjectType });
                if (toStore.id != null) {
                    uow.registerDirty(toStore);
                } else {
                    uow.registerNew(toStore);
                }
                uow.commitWork();

                // return new or updated id
                actionResult.items.put('recordId', toStore.id);
                actionResult.isSuccess = true;

            } catch (Exception e) {
                raise(e);
            }
        }
        return actionResult;
    }

    /*
     * retrieves current assignments with resources for specific project
     * {projectId} - String value for the specific project id
     * returns ActionResult records of resource assignments
     * throws AuraHandledException on error
     */
    @AuraEnabled(cacheable=true)
    public static ActionResult getCurrentAssignedResources (String projectId) {
        ActionResult actionResult = new ActionResult();
        try {
            // need to grab assignments from child projects.......
            Set<String> svcFields = new Set<String> {'Id','Name', 'pse__Parent_Project__c'};
            List<pse__Proj__c> childProjects = new SLT_Project(false, false).selectByParentProjectId(new Set<Id>{projectId},svcFields);

            // collect current and child projects for grabbing assignments
            Set<String> projectIds = new Set<String>();
            projectIds.add(projectId);
            if (childProjects != null && childProjects.size() > 0) {
                for (pse__Proj__c childProj : childProjects) {
                    projectIds.add(childProj.id);
                }
            }
            // build conditions and grab project assignments
            List<String> projIdList = new List<String>(projectIds);
            String projInCondition = 'pse__Project__c in (\'' + String.join(projIdList, '\', \'') + '\')';
            pse__Assignment__c[] assignments = new SLT_Assignment(false, false).getAssignmentByResource(
                null,
                projInCondition,
                new Set<String>{
                    'Id',
                    'Name',
                    'Oversight_Dashboard_Role__c',
                    'Active__c',
                    'pse__Resource__c',
                    'pse__Resource__r.Name',
                    'pse__Resource__r.Location_Code_text__c'
                }
            );
            if (assignments != null && assignments.size() > 0) {
                for (pse__Assignment__c a: assignments) {
                    actionResult.records.add(new AssignedResourceWrapper(a));
                }
            }
        } catch (Exception e) {
            raise(e);
        }
        return actionResult;
    }

    /*
     * Handles action to hide selected metrics
     * {selectedMetricsToHide} - list of ProjectMetricWrappers to hide
     * returns action result with success / failure
     * throws AuraHandledException on error
     */
    @AuraEnabled(cacheable=false)
    public static ActionResult hideSelectedMetrics (ProjectMetricWrapper[] selectedMetricsToHide) {
        ActionResult actionResult = new ActionResult();
        if (selectedMetricsToHide == null || selectedMetricsToHide.size() <= 0) {
            throw new AuraHandledException('Action to hide metrics is missing the specifc records to hide!');
        }
        try {
            // Transform wrappers into collection of Project Metric sobjects to hide!
            Map<Id, Project_Metric__c> metricsToHide = new Map<Id, Project_Metric__c>();
            for (ProjectMetricWrapper wrapper: selectedMetricsToHide) {
                if (wrapper != null && wrapper.id != null && wrapper.psaMetricClientFacing == true) {
                    Project_Metric__c sobj = new Project_Metric__c();
                    sobj.Id = wrapper.id;
                    sobj.Client_Facing__c = !wrapper.clientFacing;
                    metricsToHide.put(sobj.id, sobj);
                }
            }
            if (metricsToHide != null && metricsToHide.size() > 0) {
                fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(new List<SObjectType> { Project_Metric__c.SObjectType });
                for (Project_Metric__c sobj : metricsToHide.values()) {
                    uow.registerDirty(sobj);
                }
                uow.commitWork();

                // indicate success and add hidden record ids to result items
                actionResult.isSuccess = true;
                actionResult.items.put('hiddenIds', metricsToHide.keySet());
            }
        } catch (Exception e) {
            raise(e);
        }
        return actionResult;
    }

    /*
     * Handles action to add selected psa metrics to the project!
     * {projectId} - String value for project id to create metrics on
     * {selectedPsaMetrics} - list of selected psa metrics to create on project
     * returns action result with success / failure
     * throws AuraHandledException on error
     */
    @AuraEnabled(cacheable=false)
    public static ActionResult addSelectedMetrics (String projectId, PsaMetricWrapper[] selectedPSAMetrics) {
        ActionResult actionResult = new ActionResult();

        if (projectId == null || selectedPSAMetrics == null || selectedPSAMetrics.size() <= 0) {
            throw new AuraHandledException('Action to add selected metrics missing specifc records!');
        }
        Set<Id> projectIdSet = new Set<Id>();
        projectIdSet.add(projectId);
        Set<String> fieldSet = new Set<String>{'Id', 'Name', 'Service_Line__r.Name'};
        List<pse__Proj__c> serviceLinePseProjectList = new SLT_Project().selectByParentProjectId(projectIdSet, fieldSet);
        List<String> serviceLineProjectsOnProject = new List<String>();
        if(serviceLinePseProjectList.size() > 0){
            for(pse__Proj__c proj: serviceLinePseProjectList){
                serviceLineProjectsOnProject.add(proj.Service_Line__r.Name);                
            }            
        }
        serviceLineProjectsOnProject.add('');
        Set<String> serviceLineError = new Set<String>();
        for (PsaMetricWrapper source: selectedPSAMetrics) {
            if(!(serviceLineProjectsOnProject.contains(source.serviceLineName))){
                serviceLineError.add(source.serviceLineName);
            }
        }
        if(serviceLineError.size() > 0){
            String errorMsg = '';
            for(String error : serviceLineError){
                errorMsg += error + ', ';
            }
            errorMsg = errorMsg +'Service line project does not exist on the project(s).';
            throw new AuraHandledException(errorMsg);
        }
        try {
            // Build new project metric records from selected psa metric records
            Project_Metric__c[] metricsToCreate = new Project_Metric__c[]{};
            for (PsaMetricWrapper source: selectedPSAMetrics) {
                Boolean sourceClientFacing = source.clientFacing;
                metricsToCreate.add(new Project_Metric__c(
                    Project__c = projectId,
                    PSA_Metric__c = source.Id,
                    Metric_Name__c = source.Name,
                    Amber_Threshold__c = source.amberThreshold,
                    Green_Threshold__c = source.greenThreshold,
                    Red_Threshold__c = source.redThreshold,
                    GRA_Requirements__c = source.graRequirement,
                    CurrencyIsoCode = source.currencyIsoCode,
                    Location__c = source.location,
                    Client_Facing__c = sourceClientFacing,
                    Source_System__c = source.sourceSystem,
                    Effective_Date__c = source.effectiveDate,
                    Automated__c = source.automated,
                    Tower__c = source.tower,
                    Retired_Date__c=source.retiredDate,
                    Last_reviewed_Month__c=source.lastReviewedMonth
                ));
            }
            if (metricsToCreate != null && metricsToCreate.size() > 0) {
                // Database.insert(metricsToCreate);
                fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(new List<SObjectType> { Project_Metric__c.SObjectType });
                for (Project_Metric__c sobj : metricsToCreate) {
                    uow.registerNew(sobj);
                }
                uow.commitWork();

                actionResult.isSuccess = true;
                actionResult.items.put('metricsCreated', metricsToCreate.size());
            }
        } catch (Exception e) {
            raise(e);
        }

        return actionResult;
    }

    /*
     * Handles action to set retired date on multiple metrics at once
     * {retireDate} - date to set on metrics
     * {metricsToRetire} - list of active metrics to apply the date to
     * returns action result with success / failure
     * throws AuraHandledException on error
     */
     @AuraEnabled(cacheable=false)
     public static ActionResult retireMetrics(Date retireDate, ProjectMetricWrapper[] metricsToRetire) {
        ActionResult actionResult = new ActionResult();
        if(retireDate == null || metricsToRetire == null || metricsToRetire.size() <= 0){
            throw new AuraHandledException('Cannot retire metrics without specifying a date and selecting some metrics!');
        }
        try {
            Project_Metric__c[] metricsToUpdate = new Project_Metric__c[]{};
            for (ProjectMetricWrapper source: metricsToRetire){
                metricsToUpdate.add(new Project_Metric__c(
                    Id=source.Id,
                    Retired_Date__c=retireDate
                ));
            }
            if(metricsToUpdate != null && metricsToUpdate.size() > 0){
                fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(new List<SObjectType> { Project_Metric__c.SObjectType });
                uow.registerDirty(metricsToUpdate);
                uow.commitWork();

                actionResult.isSuccess = true;
                actionResult.items.put('metricsUpdated', metricsToUpdate.size());
            }
        } catch (Exception e) {
            raise(e);
        }

        return actionResult;
     }

    /*
     *  Clones a project metric record
     *
     * {projectMetricId} - id of the project metric record to clone
     * {fieldValues} - list of fieldName and values to apply to cloned record
     *
     * returns action result with success / failure
     * throws AuraHandledException on error
     */
    @AuraEnabled(cacheable=false)
    public static ActionResult cloneProjectMetric(String projectMetricId, List<Map<String, Object>> fieldValues) {
        ActionResult actionResult = new ActionResult();
        try {
            // load the project metric record to clone!
            SLT_Project_Metric projMetricService = new SLT_Project_Metric(false);
            Set<String> fields = projMetricService.getSObjectFieldSet();
            String conditions = 'Id = \'' + projectMetricId + '\'';
            Project_Metric__c[] projMetrics = projMetricService.findBy(fields, conditions);

            if (projMetrics == null || projMetrics.size() <= 0) {
                throw new AuraHandledException('Undefined project metric record to clone.');
            }

            // clone the record
            Project_Metric__c clonedMetric = projMetrics[0].clone();

            // apply specified field values to cloned record
            if (fieldValues != null && fieldValues.size() > 0) {
                sObject clonedSobj = (Sobject) clonedMetric;
                Set<String> clonedDateFields = new Set<String>{'Effective_Date__c', 'Retired_Date__c'};

                for (Map<String, Object> fldVal : fieldValues) {
                    String fieldName = String.valueOf(fldVal.get('fieldName'));
                    Object fieldVal = fldVal.get('fieldValue');

                    // handle case when field is type date, need to grab the value of (YYYY-MM-DD)
                    if (clonedDateFields.contains(fieldName)) {
                        fieldVal = fieldVal != null ? Date.valueOf(String.valueOf(fieldVal)) : null;
                    }

                    // set the value if it exists on the clone
                    if (fieldName != null && sobjContainsField(clonedSobj, fieldName)) {
                        clonedSobj.put(fieldName, fieldVal);
                    }
                }
            }

            // save the cloned record
            fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(new List<SObjectType> { Project_Metric__c.SObjectType });
            uow.registerNew(clonedMetric);
            uow.commitWork();

            // return new id
            actionResult.items.put('recordId', clonedMetric.id);
            actionResult.isSuccess = true;
        } catch (Exception e) {
            raise(e);
        }
        return actionResult;
    }

    /*
     * returns true when specified object contains specified field name, returns false otherwise!
     */
    @TestVisible private static Boolean sobjContainsField (Sobject sobj, String fieldName) {
        boolean contains = true;
        try {
            sobj.get(fieldName);
        } catch (Exception e) {
            contains = false;
        }
        return contains;
    }

    /*
     * return quarterly label for specific date
     */
    @TestVisible private static String buildQuarterlyLabel(Date inputDate) {
        // build quarterly label!
        String qlabel = 'Q';
        if (inputDate.month() < 4) {
            qlabel += '1';
        } else if (inputDate.month() < 7) {
            qlabel += '2';
        } else if (inputDate.month() < 10) {
            qlabel += '3';
        } else {
            qlabel += '4';
        }
        return qlabel;
    }
    /*
     * retuns starting date of quarter for specific input date
     */
    @TestVisible private static Date toStartOfQuarter (Date input) {
        // quarterly month start
        Date result = null;
        if (input.month() < 4) {
            result = Date.newInstance(input.year(), 1, 1);
        } else if (input.month() < 7) {
            result = Date.newInstance(input.year(), 4, 1);
        } else if (input.month() < 10) {
            result = Date.newInstance(input.year(), 7, 1);
        } else {
            result =  Date.newInstance(input.year(), 10, 1);
        }
        return result;
    }
    /*
     * retuns starting date of semi-anual for specific input date
     * from 16-Jan
     */
    @TestVisible private static Date toStartOfSemiAnnual (Date input) {
        Date result = Date.newInstance(input.year(), 1, 16); // quarterly month start
        while (result > input) {
            result = result.addMonths(-6);
        }
        return result;
    }

    /*
     * common logic to retrieve project metrics and build the wrapper
     */
    private static ProjectMetricWrapper[] findProjectMetricWrappersBy (String conditions) {
        ProjectMetricWrapper[] wrappers = new ProjectMetricWrapper[]{};
        SLT_Project_Metric projMetricService = new SLT_Project_Metric(false);
        // specify project metric service fields to retrieve, including related items
        Set<String> fields = projMetricService.getSObjectFieldSet();
        fields.addAll(new Set<String>{
            'PSA_Metric__r.Service_Line__c',
            'PSA_Metric__r.Service_Line__r.Name',
            'PSA_Metric__r.Category__c',
            'PSA_Metric__r.Output_Data_Type__c',
            'PSA_Metric__r.Calculation_Required__c',
            'PSA_Metric__r.Denominator_Ignored_on_Entry__c',
            'PSA_Metric__r.Numerator__c',
            'PSA_Metric__r.Denominator__c',
            'PSA_Metric__r.Frequency__c',
            'Service__r.Name',
            'PSA_Metric__r.Non_Standard__c'
        });
// TODO...
        // fetch, wrap, and return data
        Project_Metric__c[] projMetrics = projMetricService.findBy(fields, conditions);
        if (projMetrics != null && projMetrics.size() > 0) {
            for (Project_Metric__c projMetric : projMetrics) {
                wrappers.add(new ProjectMetricWrapper(projMetric));
            }
        }
        return wrappers;
    }
    
    /* 
     * populate protocol picklist filter
     **/
    @AuraEnabled(cacheable=true)
    public static List<String> populateProtocolName(String rdsProjId){
        SLT_Project_Metric projMetricService = new SLT_Project_Metric(false);
        Set<String> protocolNameSet = new Set<String>();
        List<Project_Metric__c> protocolList = projMetricService.findProtocolNamesForProject(rdsProjId);
        if(protocolList.size()>0){
           for(Project_Metric__c protocol : protocolList){
            protocolNameSet.add(protocol.Protocol_Name__c);
            } 
        }
        List<String> protocolNameList = new List<String>(protocolNameSet);
        return protocolNameList;
    }
    
    // check whether the user has RDS Admin permission set
    @AuraEnabled
    public static boolean hasRDSPermission(){
        boolean hasPermission = false;
        SLT_Project_Metric projMetricService = new SLT_Project_Metric(false);
        List<PermissionSetAssignment> permissionSetList = new list<PermissionSetAssignment>();
        permissionSetList = projMetricService.hasRDSAdminPermmission();
        for(PermissionSetAssignment perRec: permissionSetList){
            if(perRec.PermissionSet.Name == 'RDS_ADMIN'){
                hasPermission = true;
                break;
            }
        }
        if(hasPermission){
            return true;  
        }
        else{
            return false;
        }  
    }

    /* sets up AuraHandledException and throws it!
     * (includes logic to setMessage() to see the exception message in logs instead of 'script thrown error')
     */
    @TestVisible
    private static void raise (Exception e) {
        AuraHandledException ahe = new AuraHandledException(e.getMessage());
        ahe.setMessage(e.getMessage());
        throw ahe;
    }

    /*
     * Represents results returnd from AuraEnabled methods
     */
    public class ActionResult {
        @AuraEnabled public Boolean isSuccess {get; set;}
        @AuraEnabled public Object[] records {get; set;}
        @AuraEnabled public Map<String, Object> items {get; set;}
        public ActionResult () {
            this.records = new Object[]{};
            this.items = new Map<String, Object>();
        }
    }

    /*
     * Wrapper class for Project Metric data
     */
    public class ProjectMetricWrapper {
        @AuraEnabled public Id id {get; set;}
        @AuraEnabled public String currencyIsoCode {get;set;}
        @AuraEnabled public String name {get; set;}
        @AuraEnabled public String metricName {get; set;}
        @AuraEnabled public String metricUrl { get { return '/lightning/r/' + this.id + '/view'; } }
        @AuraEnabled public String projectId {get; set;}
        @AuraEnabled public String location {get; set;}
        @AuraEnabled public String frequency {get; set;}
        @AuraEnabled public String amberThreshold {get; set;}
        @AuraEnabled public String greenThreshold {get; set;}
        @AuraEnabled public String redThreshold {get; set;}
        @AuraEnabled public String graRequirement {get; set;}
        @AuraEnabled public Boolean automated {get; set;}
        @AuraEnabled public Boolean clientFacing {get; set;}
        @AuraEnabled public String clientFacingIconName {get; set;}
        @AuraEnabled public Boolean clientFacingDisabled {get; set;}
        @AuraEnabled public Boolean psaMetricClientFacing {get; set;}
        @AuraEnabled public String psaMetricId {get; set;}
        @AuraEnabled public String serviceLineId {get; set;}
        @AuraEnabled public String serviceLineUrl { get { return this.serviceLineId != null ? '/lightning/r/' + this.serviceLineId + '/view' : ''; } }
        @AuraEnabled public String serviceLineName {get; set;}
        @AuraEnabled public String category {get; set;}
        @AuraEnabled public Date effectiveDate {get; set;}
        @AuraEnabled public Date retiredDate {get; set;}
        @AuraEnabled public Date lastReviewedMonth {get; set;}
        @AuraEnabled public ProjectMetricActualWrapper[] metricActuals {get; set;} // has many project metric actuals
        @AuraEnabled public String serviceId {get; set;}
        @AuraEnabled public String serviceName {get; set;}
        @AuraEnabled public String serviceUrl { get { return this.serviceId != null ? '/lightning/r/' + this.serviceId + '/view' : ''; } }
        @AuraEnabled public String sourceSystem {get; set;}
        @AuraEnabled public Boolean showPercentage {get; set;}
        @AuraEnabled public Boolean showDenominator {get; set;}
        @AuraEnabled public String outputType {get; set;}
        @AuraEnabled public Boolean denominatorIsIgnored {get; set;}
        @AuraEnabled public Boolean calculationRequired {get; set;}
        @AuraEnabled public String numeratorLabel {get; set;}
        @AuraEnabled public String denominatorLabel {get; set;}
        @AuraEnabled public Decimal order {get; set;}
        @AuraEnabled public String protocolName {get; set;}
        @AuraEnabled public Boolean nonStandard {get; set;}

        public ProjectMetricWrapper() {
        }

        public ProjectMetricWrapper(Project_Metric__c projectMetric) {
            this.id = projectMetric.Id;
            this.currencyIsoCode = projectMetric.CurrencyIsoCode;
            this.name = projectMetric.Name;
            this.metricName = projectMetric.Metric_Name__c;
            this.projectId = projectMetric.Project__c;
            this.frequency = projectMetric.Frequency__c;
            this.amberThreshold = projectMetric.Amber_Threshold__c;
            this.greenThreshold = projectMetric.Green_Threshold__c;
            this.redThreshold = projectMetric.Red_Threshold__c;
            this.graRequirement = projectMetric.GRA_Requirements__c;
            this.automated = projectMetric.Automated__c;
            this.clientFacing = projectMetric.Client_Facing__c;
            this.psaMetricClientFacing = projectMetric.PSA_Metric_Client_Facing__c;
            this.psaMetricId = projectMetric.PSA_Metric__c;
            this.location = projectMetric.Location__c;
            this.effectiveDate = projectMetric.Effective_Date__c ;
            this.retiredDate = projectMetric.Retired_Date__c ;
            this.lastReviewedMonth = projectMetric.Last_reviewed_Month__c ;
            this.clientFacingIconName = clientFacing == true ? 'utility:check' : 'utility:close';
            this.clientFacingDisabled = psaMetricClientFacing != true; // disabled unless psa metric is enabled
            this.sourceSystem = projectMetric.Source_System__c;
            this.order = projectMetric.Order__c;
            this.protocolName = projectMetric.Protocol_Name__c;
            // service and name when specified
            if (projectMetric.Service__r != null) {
                this.serviceId = projectMetric.Service__c;
                this.serviceName = projectMetric.Service__r.Name;
            }

            // initialize psa metric data when provided
            if (projectMetric.PSA_Metric__r != null) {
                this.serviceLineId = projectMetric.PSA_Metric__r.Service_Line__c;
                this.serviceLineName = projectMetric.PSA_Metric__r.Service_Line__r.Name;
                this.category = projectMetric.PSA_Metric__r.Category__c;
                this.showPercentage = SHOW_PERCENTAGE.contains(projectMetric.PSA_Metric__r.Output_Data_Type__c);
                this.denominatorIsIgnored = projectMetric.PSA_Metric__r.Denominator_Ignored_on_Entry__c;
                this.calculationRequired = projectMetric.PSA_Metric__r.Calculation_Required__c;
                this.showDenominator = (this.denominatorIsIgnored == false && this.calculationRequired == true);
                this.outputType = projectMetric.PSA_Metric__r.Output_Data_Type__c;
                this.numeratorLabel = (projectMetric.PSA_Metric__r.Numerator__c != null) ? projectMetric.PSA_Metric__r.Numerator__c : 'Numerator';
                this.denominatorLabel = (projectMetric.PSA_Metric__r.Denominator__c != null) ? projectMetric.PSA_Metric__r.Denominator__c : 'Denominator';
                this.nonStandard = projectMetric.PSA_Metric__r.Non_Standard__c;
            }
        }
    }

    /*
     * Wrapper class for PSA Metric data
     */
    public class PsaMetricWrapper {
        @AuraEnabled public Id id {get; set;}
        @AuraEnabled public String currencyIsoCode {get; set;}
        @AuraEnabled public String name {get; set;}
        @AuraEnabled public String psaMetricUrl  { get { return this.id != null ? '/lightning/r/' + this.id + '/view' : ''; } }
        @AuraEnabled public String description {get; set;}
        @AuraEnabled public String graRequirement {get; set;}
        @AuraEnabled public String serviceLineName {get; set;}
        @AuraEnabled public Date lastReviewedMonth {get; set;}
        @AuraEnabled public String serviceLineId {get; set;}
        @AuraEnabled public String serviceLineUrl { get { return this.serviceLineId != null ? '/lightning/r/' + this.serviceLineId + '/view' : ''; } }
        @AuraEnabled public String amberThreshold {get; set;}
        @AuraEnabled public String greenThreshold {get; set;}
        @AuraEnabled public String redThreshold {get; set;}
        @AuraEnabled public String location {get; set;}
        @AuraEnabled public String accountId {get; set;}
        @AuraEnabled public String accountName {get; set;}
        @AuraEnabled public String accountUrl { get { return this.accountId != null ? '/lightning/r/' + this.accountId + '/view' : ''; } }
        @AuraEnabled public Boolean clientFacing {get; set;}
        @AuraEnabled public Boolean nonStandard {get; set;}
        @AuraEnabled public Date effectiveDate {get; set;}
        @AuraEnabled public String sourceSystem {get; set;}
        @AuraEnabled public Boolean automated {get; set;}
        @AuraEnabled public Date retiredDate {get; set;}
        @AuraEnabled public String uniqueID {get; set;}
        @AuraEnabled public String tower {get; set;}
        
        public PsaMetricWrapper() {
        }

        public PsaMetricWrapper(PSA_Metric__c sobj) {
            this.id = sobj.Id;
            this.currencyIsoCode = sobj.CurrencyIsoCode;
            this.name = sobj.name;
            this.amberThreshold = sobj.Amber_Threshold__c;
            this.greenThreshold = sobj.Green_Threshold__c;
            this.redThreshold = sobj.Red_Threshold__c;
            this.location = sobj.Location__c;
            this.description = sobj.Description__c;
            this.graRequirement = sobj.GRA_Requirements__c;
            this.serviceLineId = sobj.Service_Line__c;
            this.serviceLineName = sobj.Service_Line__r != null ? sobj.Service_Line__r.Name : '';
            this.accountId = sobj.Account__c;
            this.accountName = sobj.Account__r != null ? sobj.Account__r.Name : '';
            this.clientFacing = sobj.Client_Facing__c;
            this.nonStandard = sobj.Non_Standard__c;
            this.effectiveDate = sobj.Effective_Date__c;
            this.sourceSystem = sobj.Source_System__c;
            this.automated = sobj.Automated__c;
            this.retiredDate = sobj.Retired_Date__c;
            this.uniqueID = sobj.PSA_Metric_Unique_ID__c;
            this.tower = sobj.Tower__c;
        }
    }

    /*
     * Wrapper class for Project Metric Actual data
     */
    public class ProjectMetricActualWrapper {
        @AuraEnabled public Id id {get; set;}
        @AuraEnabled public String currencyIsoCode {get; set;}
        @AuraEnabled public String name {get; set;}
        @AuraEnabled public String comments {get; set;}
        @AuraEnabled public String legacyId {get; set;}
        @AuraEnabled public Decimal quantity {get; set;}
        @AuraEnabled public Decimal numerator {get; set;}
        @AuraEnabled public Decimal denominator {get; set;}
        @AuraEnabled public Id projectId {get; set;}
        @AuraEnabled public Id projectMetricId {get; set;}
        @AuraEnabled public Id psaMetricId {get; set;}
        @AuraEnabled public Date recordDate {get; set;}
        @AuraEnabled public String recordDateKey {get; set;}
        @AuraEnabled public Boolean showPercentage {get; set;}
        @AuraEnabled public Boolean showDenominator {get; set;}
        @AuraEnabled public String outputType {get; set;}
        @AuraEnabled public Boolean denominatorIsIgnored {get; set;}
        @AuraEnabled public Boolean calculationRequired {get; set;}
        @AuraEnabled public String numeratorLabel {get; set;}
        @AuraEnabled public String denominatorLabel {get; set;}
        
        public ProjectMetricActualWrapper() {
        }

        public ProjectMetricActualWrapper(Project_Metric_Actual__c sobj) {
            this.id = sobj.Id;
            this.currencyIsoCode = sobj.CurrencyIsoCode;
            this.name = sobj.name;
            this.comments = sobj.Comments__c != null ? sobj.Comments__c : ''; // default to empty string
            this.legacyId = sobj.Legacy_Id__c;
            this.quantity = sobj.Quantity__c != null ? sobj.Quantity__c : 0; // default to 0
            this.projectId = sobj.Project__c;
            this.projectMetricId = sobj.Project_Metric__c;
            this.psaMetricId = sobj.PSA_Metric__c;
            this.recordDate = sobj.Date__c;
            this.numerator = sobj.Numerator__c;
            this.denominator = sobj.Denominator__c;

            if (recordDate != null) {
                //Need to check frequency, and do it to the 16th if it's a semi-annual
                Date recordSOM = (sobj.PSA_Metric__r.Frequency__c == SEMI_ANNUALLY) ? recordDate : recordDate.toStartOfMonth();
                this.recordDateKey = DateTime.newInstance(recordSOM.year(),recordSOM.month(),recordSOM.day()).format('yyyy-MM-dd');
            }
            this.showPercentage = (sobj.PSA_Metric__r != null && sobj.PSA_Metric__r.Output_Data_Type__c != null) ? CNT_PSA_ProjectMetric.SHOW_PERCENTAGE.contains(sobj.PSA_Metric__r.Output_Data_Type__c) : false;
            this.denominatorIsIgnored = (sobj.PSA_Metric__r != null && sobj.PSA_Metric__r.Denominator_Ignored_on_Entry__c) ? sobj.PSA_Metric__r.Denominator_Ignored_on_Entry__c : false;
            this.calculationRequired = (sobj.PSA_Metric__r != null && sobj.PSA_Metric__r.Calculation_Required__c);
            this.showDenominator = (this.denominatorIsIgnored == false && this.calculationRequired == true);
            this.outputType = sobj.PSA_Metric__r.Output_Data_Type__c;
            this.numeratorLabel = (sobj.PSA_Metric__r != null && sobj.PSA_Metric__r.Numerator__c != null) ? sobj.PSA_Metric__r.Numerator__c : 'Numerator';
            this.denominatorLabel = (sobj.PSA_Metric__r != null && sobj.PSA_Metric__r.Denominator__c != null) ? sobj.PSA_Metric__r.Denominator__c : 'Denominator';
        }
    }

    /*
     * represents the dynamic monthly columns to render in ui
     */
    public class MonthlyColumn {
        @AuraEnabled public String fieldName {get; set;}
        @AuraEnabled public String label {get; set;}
        public MonthlyColumn (String field, String label) {
            this.fieldName = field;
            this.label = label;
        }
    }

    public class AssignedResourceWrapper {
        @AuraEnabled public Id id {get; set;}
        @AuraEnabled public String name {get; set;}
        @AuraEnabled public String oversightDashboardRole {get; set;}
        @AuraEnabled public Boolean active {get; set;}
        @AuraEnabled public Id resourceId {get; set;}
        @AuraEnabled public String resourceName {get; set;}
        @AuraEnabled public String resourceLocation {get; set;}

        public AssignedResourceWrapper (pse__Assignment__c sobj) {
            this.id = sobj.Id;
            this.name = sobj.Name;
            this.oversightDashboardRole = sobj.Oversight_Dashboard_Role__c;
            this.active = sobj.Active__c;
            this.resourceId = sobj.pse__Resource__c;
            if (sobj.pse__Resource__r != null) {
                this.resourceName = sobj.pse__Resource__r.Name;
                this.resourceLocation = sobj.pse__Resource__r.Location_Code_text__c;
            }
        }
    }

    public class ProjectMetricActualHistoryWrapper {
        @AuraEnabled public Id id {get; set;}
        @AuraEnabled public Id createdById {get; set;}
        @AuraEnabled public String createdByName {get; set;}
        @AuraEnabled public DateTime createdDate {get; set;}
        @AuraEnabled public String field {get; set;}
        @AuraEnabled public String newValue {get; set;}
        @AuraEnabled public String oldValue {get; set;}
        @AuraEnabled public Id parentId {get; set;}
        @AuraEnabled public String parentMetricName {get; set;}
        @AuraEnabled public String parentMetricProject {get; set;}
        @AuraEnabled public Date parentDate {get; set;}

        public ProjectMetricActualHistoryWrapper (Project_Metric_Actual__History sobj) {
            this.createdById = sobj.CreatedById;
            this.createdByName = sobj.CreatedBy.Name;
            this.createdDate = sobj.CreatedDate;
            this.field = sobj.Field;
            this.id = sobj.Id;
            this.newValue = String.valueOf(sobj.NewValue);
            this.oldValue = String.valueOf(sobj.OldValue);
            this.parentId = sobj.ParentId;
            this.parentMetricName = sobj.Parent.Project_Metric__r.Metric_Name__c;
            this.parentMetricProject = sobj.Parent.Project_Metric__r.Project__c;
            this.parentDate = sobj.Parent.Date__c;
        }
    }
}
