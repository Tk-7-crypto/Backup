/*
 * Version       : 1.0
 * Description   : This Apex class is selector layer for Case
 */
public class SLT_Milestone extends fflib_SObjectSelector {

    /**
     * constructor to initialize CRUD and FLS
     */
    public SLT_Milestone() {
        super(true, false, false);
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
        return pse__Milestone__c.sObjectType;
    }

    /**
     * This method used to get Milestones by Id
     * @return  Map<Id, pse__Milestone__c>
     */
    public Map<Id, pse__Milestone__c> getMilestoneById(Set<ID> idSet, Set<String> fieldSet) {
        return new Map<Id, pse__Milestone__c>((List<pse__Milestone__c>) Database.query(newQueryFactory(true).selectFields(fieldSet).setCondition('Id in :idSet').toSOQL()));
    }

    /**
     * This method used to get list of Milestones by Id matching to the Project Id.
     * @return  List<pse__Milestone__c>
     */
    public List<pse__Milestone__c> selectMilestoneByProjectId(Set<ID> idSet,Set<String> fieldSet) {
        return ((List<pse__Milestone__c>) Database.query(newQueryFactory(true).selectFields(fieldSet).setCondition('pse__Project__c in :idSet').toSOQL()));
    }

    /**
     * This method used to get mao of Milestones by Project Id.
     * @return  List<pse__Milestone__c>
     */
    public Map<Id, List<pse__Milestone__c>> selectMilestoneListByProjectId(Set<ID> idSet,Set<String> fieldSet) {
        Map<Id, List<pse__Milestone__c>> projectToMilestoneMap = new Map<Id, List<pse__Milestone__c>>();

        List<pse__Milestone__c> msList = (List<pse__Milestone__c>) Database.query(newQueryFactory(true).selectFields(fieldSet).setCondition('pse__Project__c in :idSet').toSOQL());

        for (pse__Milestone__c ms : msList) {
            List<pse__Milestone__c> tempMSList = projectToMilestoneMap.get(ms.pse__Project__c);

            if (tempMSList != null) {
                tempMSList.add(ms);
                projectToMilestoneMap.put(ms.pse__Project__c,tempMSList);
            } else {
                projectToMilestoneMap.put(ms.pse__Project__c, new List<pse__Milestone__c>{ms});
            }
        }
        return projectToMilestoneMap;
    }

    /*
     * returns list of RDS Service milestones projects
     */
    public List<pse__Milestone__c> selectMilestoneByRDSServiceProjectId(Set<ID> idSet,Set<String> fieldSet) {
        String rdsServiceRecordTypeID = Schema.SObjectType.pse__Milestone__c.getRecordTypeInfosByName().get('RDS Service').getRecordTypeId();
        return ((List<pse__Milestone__c>) Database.query(
            newQueryFactory(true).
                selectFields(fieldSet).
                setCondition('pse__Project__c in :idSet and RecordTypeId =:rdsServiceRecordTypeID').
                toSOQL()));
    }

    /**
     * This method used to get Milestone by Id .
     * @return  pse__Milestone__c
     */
    public pse__Milestone__c selectByMilestoneId(Set<ID> idSet,Set<String> fieldSet) {
        return ((pse__Milestone__c) Database.query(newQueryFactory(true).selectFields(fieldSet).setCondition('Id in :idSet').toSOQL()));
    }

    /**
     * This method used to get service Milestone by Service and Parent Project.
     * This returns a map with keys made up of serviceId-parentProjectId
     * @return  Map<String, pse__Milestone__c>
     */
    public Map<String, pse__Milestone__c> selectByServiceAndParentProject(Set<Id> serviceIds, Set<Id> parentProjectIds, Set<String> fieldSet) {
        String rdsServiceRecordTypeID = Schema.SObjectType.pse__Milestone__c.getRecordTypeInfosByName().get('RDS Service').getRecordTypeId();
        String status = 'Completed';
        fieldSet.add('Service__c');
        fieldSet.add('pse__Project__r.pse__Parent_Project__c');
        Map <String, pse__Milestone__c> milestoneMap = new Map<String, pse__Milestone__c>();

        List<pse__Milestone__c> milestones = (List<pse__Milestone__c>) Database.query(
            newQueryFactory(true).
            selectFields(fieldSet).
            setCondition('pse__Project__r.pse__Parent_Project__c IN: parentProjectIds and Service__c IN:serviceIds and pse__Status__c != :status and RecordTypeId =:rdsServiceRecordTypeID').
            toSOQL());
        for(pse__Milestone__c ms : milestones){
            milestoneMap.put(ms.Service__c+'-'+ms.pse__Project__r.pse__Parent_Project__c, ms);
        }
        return milestoneMap;
    }

    /**
     * This method used to get all Milestones by Service Line, Start Date and End Date .
     * @return  List of pse__Milestone__c
     */
    public List<pse__Milestone__c> selectAllMilestones(String projectId,String serviceline, Date startDate , Date endDate , Set<String> fieldset) {
        String status = 'Completed';
        return ((List<pse__Milestone__c>) Database.query(newQueryFactory(true).selectFields(fieldSet).setCondition('pse__Project__r.pse__Parent_Project__c =: projectId and Service__r.Service_Line__r.Name =:serviceline and pse__Status__c != :status and Start_Date__c <= :endDate and End_Date__c >= :startDate').toSOQL()));
    }


    /**
     * This method used to get all Milestones by Service Line, Start Date and End Date .
     * @return  List of pse__Milestone__c
     */
    public List<pse__Milestone__c> selectAllMilestonesByServicelines(String projectId,Set<String> serviceline, Date startDate , Date endDate , Set<String> fieldset) {
        String status = 'Completed';
        return ((List<pse__Milestone__c>) Database.query(newQueryFactory(true).selectFields(fieldSet).setCondition('pse__Project__r.pse__Parent_Project__c =: projectId and Service_Line__c != null and Service_Line__r.Name in :serviceline and pse__Status__c != :status and Start_Date__c <= :endDate and End_Date__c >= :startDate').toSOQL()));
    }

    /**
     * This method used to get all Milestones by Parent Project .
     * @return  List of pse__Milestone__c
     */
    public List<pse__Milestone__c> selectAllMilestonesByParentProject(String projectId, Set<String> fieldset) {
        String status = 'Completed';
        return ((List<pse__Milestone__c>) Database.query(newQueryFactory(true).selectFields(fieldSet).setCondition('pse__Project__r.pse__Parent_Project__c =: projectId and pse__Status__c != :status').toSOQL()));
    }

    /**
     * This method used to get all Milestones by Project .
     * @return  List of pse__Milestone__c
     */
    public List<pse__Milestone__c> selectAllMilestonesByProject(String projectId, Set<String> fieldset) {
        String status = 'Completed';
        return ((List<pse__Milestone__c>) Database.query(newQueryFactory(true).selectFields(fieldSet).setCondition('pse__Project__c =: projectId and pse__Status__c != :status').toSOQL()));
    }
    
    /**
     * This method used to get milestones
     * @params  Set<Id> sObjectIdset
     * @params  Set<String> fieldSet
     * @return  List<pse__Milestone__c>
     */
    public List<pse__Milestone__c> getMileStoneByIdSet(Set<Id> sObjectIdset, String condition, Set<String> fieldSet) {
        fflib_QueryFactory assignmentQueryFactory = newQueryFactory(true);
        String queryString = assignmentQueryFactory.selectFields(fieldSet).setCondition(condition).toSOQL();
        return new List<pse__Milestone__c> ((List<pse__Milestone__c>)Database.query(queryString));
    }

}
