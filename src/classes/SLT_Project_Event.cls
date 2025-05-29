public class SLT_Project_Event extends fflib_SObjectSelector {

    /**
     * constructor to initialize CRUD and FLS
     */
    public SLT_Project_Event() {
        super(false, false, false);
    }

    /**
     * constructor to initialise CRUD and FLS with a parameter for FLS.
     */
    public SLT_Project_Event (Boolean enforceFLS) {
        super(false, false, enforceFLS);
    }
    public SLT_Project_Event(Boolean enforceFLS,Boolean enforceCRUD) {
        super(false, enforceFLS, enforceCRUD);
    }

    /**
     * This method used to get field list of sobject
     * @return  List<Schema.SObjectField>
     */
    public List<Schema.SObjectField> getSObjectFieldList () {
        Schema.DescribeSObjectResult describeResult = getSObjectType().getDescribe(); 
        Map<String,Schema.SObjectField> fieldsMap = describeResult.fields.getMap();   
        System.debug('Fields: '+fieldsMap.values());
        return fieldsMap.values();
    }

    /**
     * This method used to set up type of sobject
     * @return  Schema.SObjectType
     */
    public Schema.SObjectType getSObjectType () {
        return Project_Event__c.sObjectType;
    }

    /**
     * Method to look up project events using a set of report ids
     * @params Set<Id> reportIdSet
     * @params Set<String> fieldNameSet
     * @return List<Project_Event__c>
     */
    public List<Project_Event__c> getProjectEventsByReport(Set<Id> reportIdSet, Set<String> fieldNameSet){
        fflib_QueryFactory queryFactory = newQueryFactory(false);
        queryFactory.selectFields(fieldNameSet);
        queryFactory.setCondition('Report__c IN :reportIdSet');
        String queryString = queryFactory.toSOQL();
        System.debug(queryString);
        return (List<Project_Event__c>) Database.query(queryString);
    }
    
    /**
     * Method to look up project events using a set of report ids and WhereClause
     * @params Set<Id> reportIdSet
     * @params Set<String> fieldNameSet
     * @return List<Project_Event__c>
     */
    public List<Project_Event__c> getProjectEventsByAggregateReport(Set<Id> reportIdSet, String whereClause, Set<String> fieldNameSet){
        fflib_QueryFactory assignmentQueryFactory = newQueryFactory(true);
        String queryString = assignmentQueryFactory.selectFields(fieldNameSet).setCondition(whereClause).toSOQL();
        return (List<Project_Event__c>) Database.query(queryString);
    }
    /**
     * Method to look up project events using in Calendar
     * @params Integer month
     * @params Set<String> fieldNameSet
     * @return List<Project_Event__c>
     */
    public List<Project_Event__c> getProjectEventsForCalendar(Integer month, Set<String> fieldNameSet){
        fflib_QueryFactory queryFactory = newQueryFactory(false);
        queryFactory.selectFields(fieldNameSet);
        queryFactory.setCondition('CALENDAR_MONTH(Event_Due_Date__c) =: month AND LR_Project_Overview__c != null AND Event_Due_Date__c != null');
        String queryString = queryFactory.toSOQL();
        System.debug(queryString);
        return (List<Project_Event__c>) Database.query(queryString);
    }

    /**
     * Method to look up project events using a set of signal ids
     * @params Set<Id> signalIdSet
     * @params Set<String> fieldNameSet
     * @return List<Project_Event__c>
     */
    public List<Project_Event__c> getProjectEventsBySignal(Set<Id> signalIdSet, Set<String> fieldNameSet){
        fflib_QueryFactory queryFactory = newQueryFactory(false);
        queryFactory.selectFields(fieldNameSet);
        queryFactory.setCondition('Signal__c IN :signalIdSet');
        String queryString = queryFactory.toSOQL();
        System.debug(queryString);
        return (List<Project_Event__c>) Database.query(queryString);
    }
    
    /**
     * Method to look up project events using a set of pssf ids
     * @params Set<Id> pssfIdSet
     * @params Set<String> fieldNameSet
     * @return List<Project_Event__c>
     */
    public List<Project_Event__c> getProjectEventsByPSSF(Set<Id> pssfIdSet, Set<String> fieldNameSet){
        fflib_QueryFactory queryFactory = newQueryFactory(false);
        queryFactory.selectFields(fieldNameSet);
        queryFactory.setCondition('PSSF__c IN :pssfIdSet');
        String queryString = queryFactory.toSOQL();
        System.debug(queryString);
        return (List<Project_Event__c>) Database.query(queryString);
    }
    
    /**
     * Method to look up project events using a set of pssf ids
     * @params Set<Id> pssfIdSet
     * @params Set<String> fieldNameSet
     * @return List<Project_Event__c>
     */
    public List<Project_Event__c> getProjectEventsBysdRun(Set<Id> sdRunIdSet, Set<String> fieldNameSet){
        fflib_QueryFactory queryFactory = newQueryFactory(false);
        queryFactory.selectFields(fieldNameSet);
        queryFactory.setCondition('SD_Runs__c IN :sdRunIdSet');
        String queryString = queryFactory.toSOQL();
        System.debug(queryString);
        return (List<Project_Event__c>) Database.query(queryString);
    }
    
    /**
     * Method to look up project events using a set of report ids
     * @params Set<Id> reportIdSet
     * @params Set<String> fieldNameSet
     * @return List<Project_Event__c>
     */
    public List<Project_Event__c> getProjectEventsByLR(Set<Id> lrIdSet, Set<String> fieldNameSet){
        fflib_QueryFactory queryFactory = newQueryFactory(false);
        queryFactory.selectFields(fieldNameSet);
        queryFactory.setCondition('LR_Project_Overview__c IN :lrIdSet');
        String queryString = queryFactory.toSOQL();
        return (List<Project_Event__c>) Database.query(queryString);
    }
    
    /**
     * Method to look up project events using a set of report ids
     * @params Set<Id> reportIdSet
     * @params Set<String> fieldNameSet
     * @return List<Project_Event__c>
     */
    public List<Project_Event__c> getProjectEventsBySS(Set<Id> lrIdSet, Set<String> fieldNameSet){
        fflib_QueryFactory queryFactory = newQueryFactory(false);
        queryFactory.selectFields(fieldNameSet);
        queryFactory.setCondition('Search_Strategy__c IN :lrIdSet');
        String queryString = queryFactory.toSOQL();
        System.debug(queryString);
        return (List<Project_Event__c>) Database.query(queryString);
    }
    
    /**
     * Method to get default fields for use in queries
     * @return Set<String>
     */
    public Set<String> getDefaultFields(){
        return new Set<String>{
            'Id', 
            'PSA_Event__c', 
            'Report__c', 
            'Project__c', 
            'Event_Actual_Date__c',
            'Event_Due_Date__c',
            'Notification_Date__c',
            'Stakeholder_ID__c',
            'Primary_Resource__c', 
            'Secondary_Resource__c', 
            'Other_Resource__c',
            'Signal__c',
            'SD_Runs__c',
            'PSSF__c',
            'LR_Project_Overview__c',
            'Search_Strategy__c'    
           };
    }
} 
