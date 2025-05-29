/*
 * Version       : 1.0
 * Description   : This Apex class is selector layer for Assignment
 */
public class SLT_Assignment extends fflib_SObjectSelector {
    
    /**
     * constructor to initialize CRUD and FLS
     */
    public SLT_Assignment() {
        super(false, true, true);
    }
    
    /**
     * constructor to initialise CRUD and FLS with a parameter for FLS.
     */
    public SLT_Assignment(Boolean enforceFLS) {
        super(false, true, enforceFLS);
    }
    
    
    public SLT_Assignment(Boolean enforceFLS,Boolean enforceCRUD) {
        super(false, enforceFLS, enforceCRUD);
    }
    
    /**
     * This method used to get field list of sobject
     * @return  List<Schema.SObjectField>
     */
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>();
    }
    /**
    * This method used to get pse__Assignment__c by Id
    * @return  List<pse__Assignment__c>
    */
    public List<pse__Assignment__c> selectById(Set<Id> idSet){

        return (List<pse__Assignment__c>) selectSObjectsById(idSet);
    }
    /**
     * This method used to set up type of sobject
     * @return  Schema.SObjectType
     */
    public Schema.SObjectType getSObjectType() {
        return pse__Assignment__c.sObjectType;
    }
    
    /**
     * This method used to get Resource requests with Assigments
     * @params  Set<ID> resourceRequestIdset
     * @params  Set<String> assignmentFieldSet
     * @return  Map<Id, pse__Assignment__c>
     */
    public Map<Id, pse__Assignment__c> selectAssignmentsByIdSet(Set<ID> sObjectIdset, String condition, Set<String> assignmentFieldSet) {
        fflib_QueryFactory assignmentQueryFactory = newQueryFactory(true);
        String queryString = assignmentQueryFactory.selectFields(assignmentFieldSet).setCondition(condition).toSOQL();
        return new Map<Id, pse__Assignment__c>((List<pse__Assignment__c>) Database.query(queryString));
    }
    /**
     * This method used to get Resource requests with Assigments
     * @params  Set<ID> resourceRequestIdset
     * @params  Set<String> assignmentFieldSet
     * @return  Map<Id, pse__Assignment__c>
     */
    public Map<Id, pse__Assignment__c> selectAssignmentsByFilter(Set<ID> sObjectIdset, 
                                                                 String condition, 
                                                                 Set<String> clientNameStringList, 
                                                                 Set<String> projectCodeSet, 
                                                                 Set<String> assignmentFieldSet) {
        fflib_QueryFactory assignmentQueryFactory = newQueryFactory(true);
        String queryString = assignmentQueryFactory.selectFields(assignmentFieldSet).setCondition(condition).toSOQL();
        return new Map<Id, pse__Assignment__c>((List<pse__Assignment__c>) Database.query(queryString));
    }
    
    /**
     * This method used to get Assignemnt of Resource Request
     * @params  Set<Id> resourceRequestIdset
     * @params  Set<String> assignmentFieldSet
     * @return  Map<Id, pse__Assignment__c>
     */
    public Map<Id, pse__Assignment__c> getAssignmentResourceRequest(Set<ID> resourceRequestIdset, Set<String> assignmentFieldSet) {
        fflib_QueryFactory assignmentQueryFactory = newQueryFactory(true);
        String queryString = assignmentQueryFactory.selectFields(assignmentFieldSet).setCondition('pse__Resource_Request__c in :resourceRequestIdset').toSOQL();
        return new Map<Id, pse__Assignment__c>((List<pse__Assignment__c>) Database.query(queryString));
    }
    
    /**
     * This method used to get Assignemnt of Resource
     * @params  Set<Id> sObjectIdset
     * @params  String assignmentCondition
     * @params  Set<String> assignmentFieldSet
     * @return  List<pse__Assignment__c>
     */
    public List<pse__Assignment__c> getAssignmentByResource(Set<Id> sObjectIdset, String assignmentCondition, Set<String> assignmentFieldSet) {
        fflib_QueryFactory assignmentQueryFactory = newQueryFactory(true);
        String queryString = assignmentQueryFactory.selectFields(assignmentFieldSet).setCondition(assignmentCondition).toSOQL();
        return ((List<pse__Assignment__c>) Database.query(queryString));
    }
    
    /**
     * This method used to get Assignemnt of Resource
     * @params  Set<Id> resourceIdSet
     * @params  Set<Id> projectIdSet
     * @params  Set<String> assignmentFieldSet
     * @return  List<pse__Assignment__c>
     */
    public List<pse__Assignment__c> getAssignmentByResourceAndProject(Set<Id> resourceIdSet, Set<Id> projectIdSet, Set<String> assignmentFieldSet) {
        fflib_QueryFactory assignmentQueryFactory = newQueryFactory(true);
        String queryString = assignmentQueryFactory.selectFields(assignmentFieldSet).setCondition('pse__Resource__c IN :resourceIdSet AND pse__Project__c IN :projectIdSet').toSOQL();
        return ((List<pse__Assignment__c>) Database.query(queryString));
    }

    /**
     * This method used to get Assignemnt of Resource
     * @params  Set<Id> sObjectIdset
     * @params  Date currentDate
     * @params  String assignmentCondition
     * @params  Set<String> assignmentFieldSet
     * @return  List<pse__Assignment__c>
     */
    public List<pse__Assignment__c> getAssignmentByResourceAndCondition(Set<Id> sObjectIdset,Date currentDate, String assignmentCondition, Set<String> assignmentFieldSet) {
        fflib_QueryFactory assignmentQueryFactory = newQueryFactory(true);
        String queryString = assignmentQueryFactory.selectFields(assignmentFieldSet).setCondition(assignmentCondition).toSOQL();
        return ((List<pse__Assignment__c>) Database.query(queryString));
    }
    
    /**
     * This method used to get Assignemnt of Resource
     * @params  Set<Id> agrIdset
     * @params  String assignmentCondition
     * @params  Set<String> assignmentFieldSet
     * @return  List<pse__Assignment__c>

    public List<pse__Assignment__c> getAssignmentByAgrAndCondition(Set<Id> agrIdset, String assignmentCondition, Set<String> assignmentFieldSet) {
        fflib_QueryFactory assignmentQueryFactory = newQueryFactory(true);
        String queryString = assignmentQueryFactory.selectFields(assignmentFieldSet).setCondition('Agreement__c in: agrIdset '+assignmentCondition).toSOQL();
        return ((List<pse__Assignment__c>) Database.query(queryString));
    }
     */
    /**
     * This method used to get Assignemnt of Resource
     * @params  Set<Id> agrIdset
     * @params  String assignmentCondition
     * @params  Set<String> assignmentFieldSet
     * @return  List<pse__Assignment__c>
     */
    public List<pse__Assignment__c> getAssignmentByBhrAndCondition(Set<Id> agrIdset, String assignmentCondition, Set<String> assignmentFieldSet) {
        fflib_QueryFactory assignmentQueryFactory = newQueryFactory(true);
        String queryString = assignmentQueryFactory.selectFields(assignmentFieldSet).setCondition('Bid_History__c in: agrIdset '+assignmentCondition).toSOQL();
        return ((List<pse__Assignment__c>) Database.query(queryString));
    }
    
    /**
     * This method retrieves assignments associated with a program
     */
    public List<pse__Assignment__c> getAssignmentsByProgram(Set<Id> programIdSet, Set<String> assignmentFieldSet){
        fflib_QueryFactory assignmentQueryFactory = newQueryFactory(true);
        String queryString = assignmentQueryFactory.selectFields(assignmentFieldSet).setCondition('pse__Project__r.Program__c in :programIdSet').toSOQL();
        return (List<pse__Assignment__c>) Database.query(queryString);
    }

    /**
     * This method retrieves assignments associated with a projects or it's child project
     */
    public List<pse__Assignment__c> getAssignmentsByProject(Set<Id> projectIdSet, Set<String> assignmentFieldSet){
        fflib_QueryFactory assignmentQueryFactory = newQueryFactory(true);
        String queryString = assignmentQueryFactory.selectFields(assignmentFieldSet).setCondition('pse__Project__c in :projectIdSet').toSOQL();
        return (List<pse__Assignment__c>) Database.query(queryString);
    }
    
    /**
     * This method used to get assignment by Agreement Id
     * @return  List<Apttus__APTS_Agreement__c>

    public List<pse__Assignment__c> selectAssignmentByAgreementId(Id agreementId, String resourceSubGroup) {
        return Database.query('SELECT Id, Name, Resource_Sub_Group__c, pse__Resource__r.Salesforce_User__r.Full_User_Name__c, pse__Resource_Request__r.Is_Created_Automatically__c FROM pse__Assignment__c WHERE pse__Resource_Request__r.SubGroup__c = \'' +
            resourceSubGroup + '\' AND Agreement__c = \'' + agreementId + '\'');            
    }
     */
    /**
     * This method used to get assignment by Clinical Bid Id
     * @return  List<Apttus__APTS_Agreement__c>
     */
    public List<pse__Assignment__c> selectAssignmentByClinicalBidId(Id clinicalBidID, String resourceSubGroup) {
        return Database.query('SELECT Id, Name, Resource_Sub_Group__c, pse__Resource__r.Salesforce_User__r.Full_User_Name__c, pse__Resource_Request__r.Is_Created_Automatically__c, Bid_History__c FROM pse__Assignment__c WHERE pse__Resource_Request__r.SubGroup__c = \'' +
            resourceSubGroup + '\' AND Bid_History__c = \'' + clinicalBidID + '\'');            
    }
    /*
     public List<pse__Assignment__c> getAssignmentListFromAgreement(Set<Id> agreementIdSet, Set<String> fieldSet){
         fflib_QueryFactory resourceRequestQueryFactory = newQueryFactory(true);
         String queryString = resourceRequestQueryFactory.selectFields(fieldSet).setCondition('Agreement__c in :agreementIdSet ').toSOQL();
         return (List<pse__Assignment__c>)Database.query(queryString);
     }
     */
    /*
    public List<pse__Assignment__c> getAssignmentByAgrAndConditionOrderByAgreementOwner(Set<Id> agrIdset, String assignmentCondition, Set<String> assignmentFieldSet) {
        fflib_QueryFactory assignmentQueryFactory = newQueryFactory(true);
        String queryString = assignmentQueryFactory.selectFields(assignmentFieldSet).setCondition('Agreement__c in: agrIdset '+assignmentCondition).setOrdering('pse__Resource_Request__r.Is_Created_Automatically__c', fflib_QueryFactory.SortOrder.DESCENDING, true).toSOQL();
        return ((List<pse__Assignment__c>) Database.query(queryString));
    }
     */
    public List<pse__Assignment__c> getAssignmentByBhrAndConditionOrderByBhrOwner(Set<Id> agrIdset, String assignmentCondition, Set<String> assignmentFieldSet){
        fflib_QueryFactory assignmentQueryFactory = newQueryFactory(true);
        String queryString = assignmentQueryFactory.selectFields(assignmentFieldSet).setCondition('Bid_History__c in: agrIdset '+assignmentCondition).setOrdering('pse__Resource_Request__r.Is_Created_Automatically__c', fflib_QueryFactory.SortOrder.DESCENDING, true).toSOQL();
        return ((List<pse__Assignment__c>) Database.query(queryString));
    }
    
    /**
     * This method used to get Assignemnt of Resource
     * @params  Set<Id> resourceIdSet
     * @params  Set<Id> projectIdSet
     * @params  Set<String> assignmentFieldSet
     * @return  List<pse__Assignment__c>

    public List<pse__Assignment__c> getAssignmentByDSBSubgroupAndAgreementId(Set<Id> agreementIdSet, String subGroup, Set<String> assignmentFieldSet) {
        fflib_QueryFactory assignmentQueryFactory = newQueryFactory(true);
        String queryString = assignmentQueryFactory.selectFields(assignmentFieldSet).setCondition('Agreement__c IN :agreementIdSet AND Subgroup_Name__c Like \''+subGroup+'\'').toSOQL();
        return ((List<pse__Assignment__c>) Database.query(queryString));
    }
     */
    /**
    * This method used to get Latest AssignmentID ,Resource and Status order by Is_Created_Automatically__c desc
    * @return  pse__Assignment__c
    */
    public List<pse__Assignment__c> getAssignmentByAgreementRecordTypeAndStatus(Set<Id> clinicalBidId, String status, String recordTypeName, Set<String> rrRoles) {
        return Database.query('SELECT Id, Name, Pse__Resource__r.Name, Bid_History__c, Pse__Resource_Request__r.Name, Pse__Resource__r.Pse__Salesforce_User__c, Pse__Resource_Request__r.Is_Created_Automatically__c, Pse__Resource_Request__r.SubGroup__c, Pse__Status__c, Sub_role__c, Subgroup_Name__c, RecordType.Name FROM pse__Assignment__c WHERE Bid_History__c IN: clinicalBidId AND Pse__Resource__c != \'\' AND Pse__Status__c =: status AND '+
            'recordType.Name =: recordTypeName AND pse__Resource_Request__r.SubGroup__c IN : rrRoles order by pse__Resource_Request__r.Is_Created_Automatically__c desc,  pse__Resource_Request__r.SubGroup__c DESC, LastModifiedDate DESC');
    }
    
     /**
    * This method used to get Latest AssignmentID ,Resource and Status order by Is_Created_Automatically__c desc
    * @return  pse__Assignment__c

    public List<pse__Assignment__c> getAssignmentByAgreementRecordTypeAndStatusAndAutomatic(Set<Id> agreementId, String status, String recordTypeName) {
        return Database.query('Select Id, Name, pse__Resource__r.Name, Agreement__c, pse__Resource_Request__r.Name, pse__Resource__r.pse__Salesforce_User__c, pse__Resource_Request__r.Is_Created_Automatically__c, pse__Resource_Request__r.SubGroup__c , pse__Status__c, Sub_role__c, Subgroup_Name__c, recordType.Name from pse__Assignment__c where Agreement__c IN: agreementId AND pse__Resource__c != \'\' AND pse__Status__c =: status AND '+
            'recordType.Name =: recordTypeName AND pse__Resource_Request__r.Is_Created_Automatically__c = true order by pse__Resource_Request__r.Is_Created_Automatically__c DESC, pse__Resource_Request__r.SubGroup__c DESC, LastModifiedDate DESC');
    }
    */
    /**
    * This method used to get Automatic Latest AssignmentID ,Resource and Status order by Is_Created_Automatically__c, SubGroup__c, LastModifieddate desc
    * @return  pse__Assignment__c

    public List<pse__Assignment__c> getAssignmentByAgreementRecordTypeAndStatusAndAutomaticBySubGroup(Set<Id> agreementId, String status, String recordTypeName, List<String> subGroupList) {
        return Database.query('Select Id, Name, pse__Resource__r.Name, Agreement__c, pse__Resource_Request__r.Name, pse__Resource__r.pse__Salesforce_User__c, pse__Resource_Request__r.Is_Created_Automatically__c, pse__Resource_Request__r.SubGroup__c, pse__Status__c,Sub_role__c, Subgroup_Name__c,recordType.Name from pse__Assignment__c where Agreement__c IN: agreementId AND pse__Resource__c != \'\' AND pse__Status__c =: status AND '+
            'recordType.Name =: recordTypeName AND pse__Resource_Request__r.Is_Created_Automatically__c = true  AND Subgroup_Name__c IN: subGroupList order by pse__Resource_Request__r.Is_Created_Automatically__c DESC,  pse__Resource_Request__r.SubGroup__c DESC, LastModifiedDate DESC');
    }
    */
    /**
    * This method used to get Manual Latest AssignmentID ,Resource and Status order by Is_Created_Automatically__c, SubGroup__c, LastModifieddate desc
    * @return  pse__Assignment__c

    public List<pse__Assignment__c> getAssignmentByAgreementRecordTypeAndStatusAndManualBySubGroup(Set<Id> agreementId, String status, String recordTypeName, List<String> subGroupList) {
        return Database.query('Select Id, Name, pse__Resource__r.Name, Agreement__c, pse__Resource_Request__r.Name, pse__Resource__r.pse__Salesforce_User__c, pse__Resource_Request__r.Is_Created_Automatically__c, pse__Resource_Request__r.SubGroup__c , pse__Status__c, Sub_role__c, Subgroup_Name__c, recordType.Name from pse__Assignment__c where Agreement__c IN: agreementId AND pse__Resource__c != \'\' AND pse__Status__c =: status AND '+
            'recordType.Name =: recordTypeName AND pse__Resource_Request__r.Is_Created_Automatically__c = false  AND Subgroup_Name__c IN: subGroupList order by pse__Resource_Request__r.Is_Created_Automatically__c DESC,  pse__Resource_Request__r.SubGroup__c DESC, LastModifiedDate DESC');
    }
    */
    /**
    * This method used to get records by Latest AssignmentID and Salesforce User
    * @return  pse__Assignment__c
    */
    public List<pse__Assignment__c> getAssignmentClinicalBidAndUser(List<Id> clinicalBidId, List<Id> userIds) {
        return Database.query('SELECT Id, pse__Resource__r.pse__Salesforce_User__c, Bid_History__c, pse__Resource_Request__r.SubGroup__c, Subgroup_Name__c ' + 
            'FROM pse__Assignment__c WHERE Bid_History__c IN: clinicalBidId AND pse__Resource__r.pse__Salesforce_User__c IN: userIds');
    }
    
    /* This method used to get Latest AssignmentID ,Resource, Status and SubGrouporder by Is_Created_Automatically__c desc
    * @return  pse__Assignment__c

    public List<pse__Assignment__c> getAssignmentByAgreementRecordTypeStatusAndSubGroup(Set<Id> agreementId, String status, String recordTypeName,  List<String> subGroupList) {
        return Database.query('Select Id, Name, pse__Resource__r.Name,Agreement__c, pse__Resource_Request__r.Name, pse__Resource__r.pse__Salesforce_User__c, pse__Resource_Request__r.Is_Created_Automatically__c, pse__Resource_Request__r.SubGroup__c , pse__Status__c,Sub_role__c, Subgroup_Name__c, recordType.Name from pse__Assignment__c where Agreement__c IN: agreementId AND pse__Resource__c != \'\' AND pse__Status__c =: status AND '+
            'recordType.Name =: recordTypeName AND Subgroup_Name__c IN: subGroupList order by pse__Resource_Request__r.Is_Created_Automatically__c desc, pse__Resource_Request__r.SubGroup__c DESC, LastModifiedDate DESC ');
    }
    */
    
    /**
     * This method used to get rltd Assignments' list by Project Id
     * @return  Map<Id, pse__Assignment__c> key: 
     */
    public Map<Id, List<pse__Assignment__c>> selectAssignmentsByProjId(Set<String> idSet,Set<String> fieldSet) {
        Map<Id, List<pse__Assignment__c>> returnMap = new Map<Id, List<pse__Assignment__c>>();

        //Id rdsProjTaskRecordTypeId = Schema.SObjectType.pse__Project_Task__c.getRecordTypeInfosByDeveloperName().get('RDS_Project_Task').getRecordTypeId();
        for (pse__Assignment__c pt : (List<pse__Assignment__c>) Database.query(newQueryFactory(true).selectFields(fieldSet).setCondition('pse__Project__c in :idSet').toSOQL())) {
            
            List<pse__Assignment__c> tempList = returnMap.get(pt.pse__Project__c);
            
            if (tempList != null) {
                tempList.add(pt);
                returnMap.put(pt.pse__Project__c, tempList);
            } else {
                returnMap.put(pt.pse__Project__c, new List<pse__Assignment__c>{pt});
            }
        }

        return returnMap;
    }
    
    /**
     * This method retrieves active assignments associated with a projects or it's child project
     */
    public List<pse__Assignment__c> getActiveAssignmentsByProject(Set<Id> projectIdSet, Set<String> assignmentFieldSet){
        fflib_QueryFactory assignmentQueryFactory = newQueryFactory(true);
        String queryString = assignmentQueryFactory.selectFields(assignmentFieldSet).setCondition('Active__c = true AND pse__Project__c in :projectIdSet AND RecordType.DeveloperName = \'RDS_Assignment\'').toSOQL();
        return (List<pse__Assignment__c>) Database.query(queryString);
    }
    
    /**
     * This method retrieves active service line lead assignments associated with a PVS project and with RDS Project in the set
     */

    
    public List<pse__Assignment__c> getActiveAssignmentsByProjectLitratureANDPvSolution(Set<Id> parentProjectIdSet, String whereClause, Set<String> assignmentFieldSet){
        fflib_QueryFactory assignmentQueryFactory = newQueryFactory(true);
        String queryString = assignmentQueryFactory.selectFields(assignmentFieldSet).setCondition(whereClause).toSOQL();
        return (List<pse__Assignment__c>) Database.query(queryString);
    }
	
	/**
	 * This method is used to get Assignment by userId and Bid Id.
	 */
    public List<pse__Assignment__c> getAssignmentBySubgroupAndbidIdAnduserId(Set<Id> bidIdSet, Set<String> subGroup, Set<String> assignmentFieldSet,Set<Id> userIds, String assignmentCondition) {
        fflib_QueryFactory assignmentQueryFactory = newQueryFactory(true);
        String queryString = assignmentQueryFactory.selectFields(assignmentFieldSet).setCondition(assignmentCondition).toSOQL();
		return ((List<pse__Assignment__c>) Database.query(queryString));
    }
		
    public List<pse__Assignment__c> getAssignmentByBhrAndConditionOrderByRRCreatedDate(Set<Id> oppIdSet, String assignmentCondition, Set<String> assignmentFieldSet) {
        fflib_QueryFactory assignmentQueryFactory = newQueryFactory(true);
        String queryString = assignmentQueryFactory.selectFields(assignmentFieldSet).setCondition('Bid_History__r.Bid_History_Related_Opportunity__c in: oppIdSet '+assignmentCondition).setOrdering('pse__Resource_Request__r.CreatedDate', fflib_QueryFactory.SortOrder.DESCENDING, true).toSOQL();
        return ((List<pse__Assignment__c>) Database.query(queryString));
    }
}
