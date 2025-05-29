public without sharing class SLT_Campaign extends fflib_SObjectSelector {
    /**
     * constructor to initialise CRUD and FLS
     */
    public SLT_Campaign() {
        super(false, false, false);
    }

    /**
     * This method used to get field list of sobject
     * @return  List<Schema.SObjectField>
     */
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField> {
            Campaign.Id,
            Campaign.Name,
            Campaign.ParentId,
            Campaign.Parents_Hierarchy__c,
            Campaign.NoOfMQLs__c,
            Campaign.MQLS_in_Hierarchy__c,
            Campaign.CreatedDate
        };
    }
    
    /**
     * This method used to set up type of sobject
     * @return  Schema.SObjectType
     */
    public Schema.SObjectType getSObjectType() {
        return Campaign.sObjectType;
    }
    
    /**
     * This method used to get Campaign by Id
     * @params Set<ID> idSet campaign Id set
     * @return  List<Task>
     */
    public Map<Id, Campaign> selectById(Set<ID> idSet) {
        return new Map<Id, Campaign> ((List<Campaign>) selectSObjectsById(idSet));
    }
    
     /**
     * This method used to get Campaign by Parents_Hierarchy__c
     * @params Set<String> parentHierarchySet parent hierarchy combination set.
     * @return  List<Task>
     */
    public Map<Id, Campaign> getchildCampaignsByparentHierarchy(Set<String> parentHierarchySet){
        return new Map<Id, Campaign> ((List<Campaign>) Database.query(newQueryFactory().setCondition('Parents_Hierarchy__c Like :parentHierarchySet').toSOQL()));
        
    }
    
    /**
    * This method used to get Campaigns
    * @return  Map
    */
    public Map<String, Id> getCampaignListByName(Set<String> campNameSet , String OrderBy) {
        Map<String, Id> campNameToCampIdMap = new Map<String, Id>();
        fflib_QueryFactory factory = newQueryFactory(true);
        factory.setCondition('Name IN :campNameSet');
        if(!String.isBlank(OrderBy)) {
            factory.addOrdering(OrderBy, fflib_QueryFactory.SortOrder.ASCENDING);
        }
        List<Campaign> campaignList =  (List<Campaign>)  Database.query(factory.toSOQL());
        for(Campaign camp : campaignList) {
            campNameToCampIdMap.put(camp.Name,camp.Id);
        }
        return campNameToCampIdMap;
    }
}