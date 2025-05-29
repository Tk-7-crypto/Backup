/*
 * Version       : 1.0
 * Description   : This Apex class is selector layer for Resource Request
 */
public class SLT_Resource_Request extends fflib_SObjectSelector {
    
    /**
     * constructor to initialize CRUD and FLS
     */
    public SLT_Resource_Request() {
        super(false, true, true);
    }
    
    /**
     * constructor to initialise CRUD and FLS with a parameter for FLS.
     */
    public SLT_Resource_Request(Boolean enforceFLS) {
        super(false, true, enforceFLS);
    }
    public SLT_Resource_Request(Boolean enforceFLS,Boolean enforceCRUD) {
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
        return pse__Resource_Request__c.sObjectType;
    }
    
    /**
     * This method used to get Resource Request by with Project
     * @params  Set<Id> projectIdset
     * @params  Set<String> resourceRequestFieldSet
     * @return  Map<Id, pse__Resource_Request__c>
     */
    public Map<Id, pse__Resource_Request__c> getResourceRequestByProjectID(Set<ID> projectIdset, Set<String> resourceRequestFieldSet) {
        fflib_QueryFactory resourceRequestQueryFactory = newQueryFactory(true);
        String queryString = resourceRequestQueryFactory.selectFields(resourceRequestFieldSet).setCondition('pse__Project__c in :projectIdset').toSOQL();
        return new Map<Id, pse__Resource_Request__c>((List<pse__Resource_Request__c>) Database.query(queryString));
    }

    /**
     * This method used to get Resource Request by with Project
     * @params  Set<Id> projectIdset
     * @params  Set<String> resourceRequestFieldSet
     * @return  Map<Id, List<pse__Resource_Request__c>>
     */
   public Map<Id, List<pse__Resource_Request__c>> getResourceRequestListByProjectID(Set<ID> projectIdset, Set<String> resourceRequestFieldSet) {     
        Map<Id, List<pse__Resource_Request__c>> projectToResourceRRMap = new Map<Id, List<pse__Resource_Request__c>>();   
        List<pse__Resource_Request__c> rrList =  (List<pse__Resource_Request__c>) Database.query(newQueryFactory(true).selectFields(resourceRequestFieldSet).setCondition('pse__Project__c = :projectIdset').toSOQL());
        for (pse__Resource_Request__c rr : rrList) {
            List<pse__Resource_Request__c> tempRRList = projectToResourceRRMap.get(rr.pse__Project__c);

            if (tempRRList != null) {
                tempRRList.add(rr);
                projectToResourceRRMap.put(rr.pse__Project__c,tempRRList);
            } else {
                projectToResourceRRMap.put(rr.pse__Project__c, new List<pse__Resource_Request__c>{rr});
            }
        }
        return projectToResourceRRMap;
    }
    
    /**
    * This method used to get Resource_Requests by with Resource Requests Ids
    * @params  Set<Id> idSet
    * @params  Set<String> fieldSet
    * @return  Map<Id, pse__Resource_Request__c>
    */
    public Map<Id, pse__Resource_Request__c> selectResReqsById(Set<ID> idSet, Set<String> fieldSet) {
        return new Map<Id, pse__Resource_Request__c>((List<pse__Resource_Request__c>) Database.query(newQueryFactory(true).selectFields(fieldSet).setCondition('Id in :idSet').toSOQL()));
    }
    
    /**
     * This method used to get Resource_Requests by with Resource Requests Ids
     * @params  Set<Id> resRequestIdset
     * @params  Set<String> resRequestFieldSet
     * @params  Set<String> resSkillRequestFieldSet
     * @return  Map<Id, pse__Resource_Request__c>
     */
    public Map<Id, pse__Resource_Request__c> selectByIdWithResReqsAndRSRs(Set<ID> sObjectIdSet, String resReqCondition, Set<String> resRequestFieldSet, Set<String> resSkillRequestFieldSet, String resSkillReqCondition) {
        fflib_QueryFactory resourceRequestQueryFactory = newQueryFactory(true);
        new SLT_Resource_Skill_Request(false,false).addQueryFactorySubselect(resourceRequestQueryFactory, CON_OWF.RR_RESOURCE_SKILL_REQUESTS, true).selectFields(resSkillRequestFieldSet).setCondition(resSkillReqCondition);
        String queryString = resourceRequestQueryFactory.selectFields(resRequestFieldSet).setCondition(resReqCondition).toSOQL();
        return new Map<Id, pse__Resource_Request__c>((List<pse__Resource_Request__c>) Database.query(queryString));
    }
    
    /**
     * This method used to get Resource Request by Agreement Id
     * @params  Set<Id> agrIdset
     * @params  Set<String> resourceRequestFieldSet
     * @return  Map<Id, pse__Resource_Request__c>

    public Map<Id, pse__Resource_Request__c> getResourceRequestByAgrID(Set<ID> agrIdset, Set<String> resourceRequestFieldSet) {
        fflib_QueryFactory resourceRequestQueryFactory = newQueryFactory(true);
        String queryString = resourceRequestQueryFactory.selectFields(resourceRequestFieldSet).setCondition('Agreement__c in :agrIdset').toSOQL();
        return new Map<Id, pse__Resource_Request__c>((List<pse__Resource_Request__c>) Database.query(queryString));
    }
     */
    /**
     * This method used to get Resource Request by Bid History Id
     * @params  Set<Id> agrIdset
     * @params  Set<String> resourceRequestFieldSet
     * @return  Map<Id, pse__Resource_Request__c>
     */
    public Map<Id, pse__Resource_Request__c> getResourceRequestByBhrID(Set<ID> agrIdset, Set<String> resourceRequestFieldSet) {
        fflib_QueryFactory resourceRequestQueryFactory = newQueryFactory(true);
        String queryString = resourceRequestQueryFactory.selectFields(resourceRequestFieldSet).setCondition('Bid_History__c in :agrIdset').toSOQL();
        return new Map<Id, pse__Resource_Request__c>((List<pse__Resource_Request__c>) Database.query(queryString));
    }
    
    /**
     * This method used to get Resource Request by Assignment Id
     * @params  Set<Id> assignmentIdset
     * @params  Set<String> resourceRequestFieldSet
     * @return  Map<Id, pse__Resource_Request__c>
     */
    public Map<Id, pse__Resource_Request__c> getResourceRequestByAssignmentID(Set<ID> assignmentIdset, Set<String> resourceRequestFieldSet) {
        fflib_QueryFactory resourceRequestQueryFactory = newQueryFactory(true);
        String queryString = resourceRequestQueryFactory.selectFields(resourceRequestFieldSet).setCondition('pse__Assignment__c in :assignmentIdset').toSOQL();
        return new Map<Id, pse__Resource_Request__c>((List<pse__Resource_Request__c>) Database.query(queryString));
    }
    /**
     * This method is used to get the List of Resource Request using Agreement Id set
     * @params Set<ID> agreementIdSet
     * @params Set<String> ResourceRequestFieldSet 
     * @param String Condition
     * @return List<pse__Resource_Request__c>

     public List<pse__Resource_Request__c> getResourceRequestListFromAgreement(Set<Id> agreementIdSet, Set<String> ResourceRequestFieldSet, String Condition)
     {
         fflib_QueryFactory resourceRequestQueryFactory = newQueryFactory(true);
         String queryString = resourceRequestQueryFactory.selectFields(resourceRequestFieldSet).setCondition('Agreement__c in :agreementIdSet ' + condition).toSOQL();
         return (List<pse__Resource_Request__c>)Database.query(queryString);
     }
     */
    /**
     * This method is used to get the List of Resource Request using Agreement Id set
     * @params Set<ID> agreementIdSet
     * @params Set<String> ResourceRequestFieldSet 
     * @param String Condition
     * @return List<pse__Resource_Request__c>
     **/
     public List<pse__Resource_Request__c> getResourceRequestListFromBidHistory(Set<Id> agreementIdSet, Set<String> ResourceRequestFieldSet, String Condition)
     {
         fflib_QueryFactory resourceRequestQueryFactory = newQueryFactory(true);
         String queryString = resourceRequestQueryFactory.selectFields(resourceRequestFieldSet).setCondition('Bid_History__c in :agreementIdSet ' + condition).toSOQL();
         return (List<pse__Resource_Request__c>)Database.query(queryString);
     }
	 
    public List<pse__Resource_Request__c> getResourceRequestListFromOpportunity(Set<Id> oppIdSet, Set<String> ResourceRequestFieldSet, String Condition)
    {
        fflib_QueryFactory resourceRequestQueryFactory = newQueryFactory(true);
        String queryString = resourceRequestQueryFactory.selectFields(resourceRequestFieldSet).setCondition('pse__Opportunity__c in :oppIdSet ' + condition).toSOQL();
        return (List<pse__Resource_Request__c>)Database.query(queryString);
    }
    
    /**
    * his method is used to get the List of Resource Request using Agreement Id 
    * @author Anup Kage  | 5/21/2020 
    * @param agreementId 
    * @return List<pse__Resource_Request__c> 

    public List<pse__Resource_Request__c> getResourceRequestListFromAgreement(String agreementId){
        return (List<pse__Resource_Request__c>)Database.query('SELECT id , SubGroup__c, pse__Staffer_Resource__r.Name, pse__Staffer_Resource__r.Email '+
        ' FROM pse__Resource_Request__c '+
        ' WHERE Agreement__c =: agreementId ');
    }
    */
   	public List<pse__Resource_Request__c> getResourceRequestListFromOpportunityforPostAward(Set<Id> oppIdSet, Set<String> ResourceRequestFieldSet, String Condition)
    {
        fflib_QueryFactory resourceRequestQueryFactory = newQueryFactory(true);
        String queryString = resourceRequestQueryFactory.selectFields(resourceRequestFieldSet).setCondition('pse__Opportunity__c in :oppIdSet ' + condition).setOrdering('CreatedDate', fflib_QueryFactory.SortOrder.ASCENDING, true).toSOQL();
        return (List<pse__Resource_Request__c>)Database.query(queryString);
    }
    
    public List<pse__Resource_Request__c> getResRequestListFromBidHistory(Set<Id> agreementIdSet, Set<String> ResourceRequestFieldSet, String Condition)
    {
        fflib_QueryFactory resourceRequestQueryFactory = newQueryFactory(true);
        String queryString = resourceRequestQueryFactory.selectFields(resourceRequestFieldSet).setCondition('Bid_History__c in :agreementIdSet ' + condition).setOrdering('Name', fflib_QueryFactory.SortOrder.DESCENDING, true).toSOQL();
        return (List<pse__Resource_Request__c>)Database.query(queryString);
    }
    
    public List<pse__Resource_Request__c> getResourceRequestListFromOpportunityOBCreatedDate(Set<Id> oppIdSet, Set<String> ResourceRequestFieldSet, String condition)
    {
        fflib_QueryFactory resourceRequestQueryFactory = newQueryFactory(true);
        String queryString = resourceRequestQueryFactory.selectFields(resourceRequestFieldSet).setCondition('pse__Opportunity__c in :oppIdSet ' + condition).setOrdering('CreatedDate', fflib_QueryFactory.SortOrder.DESCENDING, true).toSOQL();
        return (List<pse__Resource_Request__c>)Database.query(queryString);
    }
    /**
     * This method used to get Resource Requests
     * @params  Set<Id> sObjectIdset
     * @params  Set<String> fieldSet
     * @return  List<pse__Resource_Request__c>
     */
    public List<pse__Resource_Request__c> getResourceRequestByIdSet(Set<Id> sObjectIdset, String condition, Set<String> fieldSet) {
        fflib_QueryFactory assignmentQueryFactory = newQueryFactory(true);
        String queryString = assignmentQueryFactory.selectFields(fieldSet).setCondition(condition).toSOQL();
        return new List<pse__Resource_Request__c> ((List<pse__Resource_Request__c>)Database.query(queryString));
    }
}
