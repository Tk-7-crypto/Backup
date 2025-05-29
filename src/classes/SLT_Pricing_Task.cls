public class SLT_Pricing_Task extends fflib_SObjectSelector {
    
    /**
     * constructor to initialize CRUD and FLS
     */
    public SLT_Pricing_Task() {
        super(true, false, false);
    }
    /**
     * This method used to get field list of sobject
     * @return  List<Schema.SObjectField>
     */
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{};
    }
    
    /**
     * This method used to set up type of sobject
     * @return  Schema.SObjectType
     */
    public Schema.SObjectType getSObjectType() {
        return Pricing_Task__c.sObjectType;
    }

    /**
     * This method used to get pricing tasks associated with a given project and service code
     * String (key) is Project + '-' + Service Code
     */
    public Map<String, List<Pricing_Task__c>> selectTasksByProjectAndServiceCode(Set<Id>projectIdSet, Set<String>serviceCodeSet ) {
        Map<String, List<Pricing_Task__c>> returnMap = new Map<String, List<Pricing_Task__c>>();
        fflib_QueryFactory ptQueryFactory = newQueryFactory(true);
        Set<String> fieldset = new Set<String>{'Name','Project__c','Service_Code__c','Role__c','Primary_Service__c','Primary_Service_Code__c','Budget_Hours__c','Task_Id__c'};
        String queryString = ptQueryFactory.selectFields(fieldset).setCondition('Project__c in :projectIdSet and Service_Code__c in :serviceCodeSet').toSOQL();
        List<Pricing_Task__c> pricingTaskList = (List<Pricing_Task__c>)Database.query(queryString);

        for (Pricing_Task__c pt : pricingTaskList) {

            string key = pt.Project__c + '-' + pt.Service_Code__c;

            List<Pricing_Task__c> tempPricingTaskList = returnMap.get(key);

            if (tempPricingTaskList != null) {
                tempPricingTaskList.add(pt);
                returnMap.put(key,tempPricingTaskList);
            } else {
                returnMap.put(key, new List<Pricing_Task__c>{pt});
            }
        }
        return returnMap;
    }

    /**
     * This method gets pricing tasks by Project
     * @return List<Pricing_Task__c>
     */
     public List<Pricing_Task__c> selectByProject(Set<Id> projectIdSet, Set<String> fieldSet){
        fflib_QueryFactory taskQueryFactory = newQueryFactory(true);
        String queryString = taskQueryFactory.selectFields(fieldSet).setCondition('Project__c IN :projectIdSet').toSOQL();
        return (List<Pricing_Task__c>) Database.query(queryString);
     }
}