/*
 * Version       : 1.0
 * Description   : This Apex class is selector layer for Project
 */
public class SLT_Project extends fflib_SObjectSelector {
    
    /**
     * constructor to initialize CRUD and FLS
     */
    public SLT_Project() {
        super(false, true, true);
    }
    
    /**
     * constructor to initialise CRUD and FLS with a parameter for FLS.
     */
    public SLT_Project(Boolean enforceFLS) {
        super(false, true, enforceFLS);
    }
    public SLT_Project(Boolean enforceFLS,Boolean enforceCRUD) {
        super(false, enforceCRUD, enforceFLS);
    }
    /**
     * This method used to get field list of sobject
     * @return  List<Schema.SObjectField>
     */
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>();
    }
    
    /**
     * This method used to set up type of sobject
     * @return  Schema.SObjectType
     */
    public Schema.SObjectType getSObjectType() {
        return pse__Proj__c.sObjectType;
    }

    /**
     * This method used to get Project by Id
     * @return  Map<Id, pse__Proj__c>
     */
    public Map<Id, pse__Proj__c> getProjectById(Set<ID> idSet, Set<String> fieldSet) {
        return new Map<Id, pse__Proj__c>((List<pse__Proj__c>) Database.query(newQueryFactory(true).selectFields(fieldSet).setCondition('Id in :idSet').toSOQL()));
    }
    
    /**
     * This method used to get Project by Id and condition
     * @return  Map<Id, pse__Proj__c>
     */
    public Map<Id, pse__Proj__c> getProjectByIdAndCondition(Set<ID> idSet, Set<String> fieldSet, String projectCondition) {
        String idSetCondition = (projectCondition.length() == 0) ? ' Id IN: idSet' : ' AND Id IN: idSet';
        return new Map<Id, pse__Proj__c>((List<pse__Proj__c>) Database.query(newQueryFactory(true).selectFields(fieldSet).setCondition(projectCondition+idSetCondition).toSOQL()));
    }
    
     /**
     * This method used to get Project by with Agreement
     * @params  Set<Id> agreementIdset
     * @params  Set<String> projectFieldSet
     * @return  Map<Id, pse__Proj__c>

    public Map<Id, pse__Proj__c> getProjectByAgreementID(Set<ID> agreementIdset, Set<String> projectFieldSet) {
        fflib_QueryFactory projectQueryFactory = newQueryFactory(true);
        String queryString = projectQueryFactory.selectFields(projectFieldSet).setCondition('Agreement__c in :agreementIdset').toSOQL();
        return new Map<Id, pse__Proj__c>((List<pse__Proj__c>) Database.query(queryString));
    }
     */
      /**
     * This method used to get Project by with Agreement
     * @params  Set<Id> agreementIdset
     * @params  Set<String> projectFieldSet
     * @return  Map<Id, pse__Proj__c>
     */
    public Map<Id, pse__Proj__c> getProjectByBidHistoryID(Set<ID> agreementIdset, Set<String> projectFieldSet) {
        fflib_QueryFactory projectQueryFactory = newQueryFactory(true);
        String queryString = projectQueryFactory.selectFields(projectFieldSet).setCondition('Bid_History__c in :agreementIdset').toSOQL();
        return new Map<Id, pse__Proj__c>((List<pse__Proj__c>) Database.query(queryString));
    }

    /**
     * This method selects projects by Project Code (Project_Code__c).
     * @return  List<pse__Proj__c>
     */
    public List<pse__Proj__c> selectByProjectCode(Set<String> projectCodeSet, Set<String> fieldSet) {
        return ((List<pse__Proj__c>) Database.query(newQueryFactory(true).selectFields(fieldSet).setCondition('Project_Code__c in :projectCodeSet').toSOQL()));
    }

    /**
     * This method used to get ProjectList by Id matching to the Program ID.
     * @return  List<pse__Proj__c>
     */
    public List<pse__Proj__c> selectByProgramId(Set<ID> idSet,Set<String> fieldSet) {
        String rdsProjectRecordTypeID = '';
        rdsProjectRecordTypeID = Schema.SObjectType.pse__Proj__c.getRecordTypeInfosByName().get('RDS Project').getRecordTypeId();
        return ((List<pse__Proj__c>) Database.query(newQueryFactory(true).selectFields(fieldSet).setCondition('Program__r.Id in :idSet and RecordTypeId =:rdsProjectRecordTypeID').toSOQL()));
    }

    
    /**This Method used to get Project by Id set and Condition**/
    public List<pse__Proj__c> getProjectByIdSetandCondition(Set<ID> sObjectIdset,String projectCondition,Set<String> projectFieldSet)
    {
     fflib_QueryFactory projectQueryFactory = newQueryFactory(true);
     String queryString = projectQueryFactory.selectFields(projectFieldSet).setCondition(projectCondition).toSOQL();
     return ((List<pse__Proj__c>) Database.query(queryString));
        
    }

    /**
     * This method used to get ProjectList by Id matching to the Parent Project ID.
     * @return  List<pse__Proj__c>
     */
    public List<pse__Proj__c> selectByParentProjectId(Set<ID> idSet,Set<String> fieldSet) {
        String rdsServiceLineRecordTypeID = '';
        rdsServiceLineRecordTypeID = Schema.SObjectType.pse__Proj__c.getRecordTypeInfosByName().get('RDS Service Line').getRecordTypeId();
        return ((List<pse__Proj__c>) Database.query(newQueryFactory(true).selectFields(fieldSet).setCondition('pse__Parent_Project__r.Id in :idSet and RecordTypeId  =:rdsServiceLineRecordTypeID').toSOQL()));
    }

    /**
     * This method used to get Project Map by Id matching to the Parent Project ID.
     * @return  Map<Id, List<pse__Proj__c>>
     */
    public Map<Id, List<pse__Proj__c>> selectMapByParentProjectId(Set<Id> projectIdset, Set<String> projFieldSet) {     
        Map<Id, List<pse__Proj__c>> parentToSubprojectMap = new Map<Id, List<pse__Proj__c>>();   
        List<pse__Proj__c> subProjList =  (List<pse__Proj__c>) Database.query(newQueryFactory(true).selectFields(projFieldSet).setCondition('pse__Parent_Project__c in :projectIdset').toSOQL());
        
        for (pse__Proj__c subProj : subProjList) {
            List<pse__Proj__c> tempSubProjList = parentToSubprojectMap.get(subProj.pse__Parent_Project__c);

            if (tempSubProjList != null) {
                tempSubProjList.add(subProj);
                parentToSubprojectMap.put(subProj.pse__Parent_Project__c,tempSubProjList);
            } else {
                parentToSubprojectMap.put(subProj.pse__Parent_Project__c, new List<pse__Proj__c>{subProj});
            }
        }
        return parentToSubprojectMap;
    }

    /**
     * This method used to get Signal Management Project by Id 
     * @return  pse__Proj__c
     */
    public list<pse__Proj__c> selectSignalManagementProjectById(Set<ID> idSet,Set<String> fieldSet) {
        return ((list<pse__Proj__c>) Database.query(newQueryFactory(true).selectFields(fieldSet).setCondition('Id in :idSet and Service_Line__r.name = ' +'\'' + 'Signal Management'+'\'').toSOQL()));
    }
    
    /**
     * This method used to get Project by Id 
     * @return  pse__Proj__c
     */
    public pse__Proj__c selectByProjectId(Set<ID> idSet,Set<String> fieldSet) {
        return ((pse__Proj__c) Database.query(newQueryFactory(true).selectFields(fieldSet).setCondition('Id in :idSet').toSOQL()));
    }
    

    /**
     * This method used to get ServiceLine by Id matching to the Parent Project ID.
     * @return  List<pse__Proj__c>
     */
    public List<pse__Proj__c> selectServiceLineByParentProject(Set<ID> idSet,Set<String> fieldSet) {
          return ((List<pse__Proj__c>) Database.query(newQueryFactory(true).selectFields(fieldSet).setCondition('pse__Parent_Project__r.Id in :idSet').toSOQL()));
    }

     /**
     * This method used to get ServiceLine by Id matching to the  Project ID.
     * @return  List<pse__Proj__c>
     */
    public List<pse__Proj__c> selectServiceLineByProject(Set<ID> idSet,Set<String> fieldSet) {
          return ((List<pse__Proj__c>) Database.query(newQueryFactory(true).selectFields(fieldSet).setCondition('Id in :idSet').toSOQL()));
    }

    /**
     * This method used to get ProjectList by Id matching to the Program ID.
     * @return  List<pse__Proj__c>
     */
    public List<pse__Proj__c> selectChildsByProgramId(Set<ID> idSet,Set<String> fieldSet) {
        String rdsProjectRecordTypeID = '';
        rdsProjectRecordTypeID = Schema.SObjectType.pse__Proj__c.getRecordTypeInfosByName().get('RDS Service Line').getRecordTypeId();
        return ((List<pse__Proj__c>) Database.query(newQueryFactory(true).selectFields(fieldSet).setCondition('Program__r.Id in :idSet and RecordTypeId =:rdsProjectRecordTypeID').toSOQL()));
    }

    /**
     * This method gets the PV Solutions project for a given service line project. This will be a sibling of the current project, under the same parent project
     */
    public Map<Id,pse__Proj__c> lookUpPVSolutionsProjects(Set<Id> serviceLineProjectIds, Set<String> fieldSet){
        String rdsProjectRecordTypeID = '';
        rdsProjectRecordTypeID = Schema.SObjectType.pse__Proj__c.getRecordTypeInfosByName().get('RDS Service Line').getRecordTypeId();
        Map<Id,pse__Proj__c> serviceLineProjectToPVProjectMap = new Map<Id,pse__Proj__c>();

        //Get Service Line Id for 'PVS'
        List<Service_Line__c> pvServiceLineList = new SLT_Service_Line().selectByName(new Set<String>{'PV Solutions'}, new Set<String>{'Id'});
        if( pvServiceLineList.size() == 0 ){
            return serviceLineProjectToPVProjectMap;
        }

        List<pse__Proj__c> serviceLineProjects = new SLT_Project().getProjectById(serviceLineProjectIds, new Set<String>{'Id','pse__Parent_Project__c'}).values();
        if( serviceLineProjects.size() == 0 ){
            return serviceLineProjectToPVProjectMap;
        }
        Set<Id> parentProjectIdSet = new Set<Id>();
        for(pse__Proj__c proj : serviceLineProjects){
            parentProjectIdSet.add(proj.pse__Parent_Project__c);
        }

        Set<String> combinedFields = new Set<String>{'pse__Parent_Project__c'};
        combinedFields.addAll(fieldSet);

        List<pse__Proj__c> pvsProjects = (List<pse__Proj__c>) Database.query(newQueryFactory(true).selectFields(combinedFields).setCondition('RecordTypeId = :rdsProjectRecordTypeID AND Service_Line__c IN :pvServiceLineList AND pse__Parent_Project__c IN :parentProjectIdSet').toSOQL());
        
        //First map by parent, the better to line up the service line projects with the right PVS projects
        Map<Id, pse__Proj__c> pvsProjectsByParent = new Map<Id, pse__Proj__c>();
        for( pse__Proj__c proj : pvsProjects ) {
            pvsProjectsByParent.put(proj.pse__Parent_Project__c, proj);
        }

        //Then build our final map by matching on parent id
        for( pse__Proj__c proj : serviceLineProjects ) {
            serviceLineProjectToPVProjectMap.put(proj.Id, pvsProjectsByParent.get(proj.pse__Parent_Project__c));
        }
        return serviceLineProjectToPVProjectMap;
    }
    
    public List<pse__Proj__c> selectByProjectRecordId(Set<ID> idSet,Set<String> fieldSet) {
        return ((List<pse__Proj__c>) Database.query(newQueryFactory(true).selectFields(fieldSet).setCondition('Id in :idSet').toSOQL()));
    }
 
}
