public class SLT_SalesProgram extends fflib_SObjectSelector {
    
    /**
     * constructor to initialize CRUD and FLS
     */
    public SLT_SalesProgram() {
        super(false, false, false);
    }
    
   /**
    * constructor to initialize CRUD and FLS
    */
   public SLT_SalesProgram(Boolean enforceCRUD, Boolean enforceFLS) {
       super(false, enforceCRUD, enforceFLS);
   }
    
    /**
     * This method used to get field list of sobject
     */
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{Sales_Program__c.Id, Sales_Program__c.Name, Sales_Program__c.Total_Potential__c, Sales_Program__c.Total_Won__c, Sales_Program__c.Total_Lost__c, Sales_Program__c.TPAP__c};
    }
    
    /**
     * This method used to set up type of sobject
     * @return  Schema.SObjectType
     */
    public Schema.SObjectType getSObjectType() {
        return Sales_Program__c.sObjectType;
    }
    
    /**
     * This method used to get Sales_Program__c by Id
     * @return  Map<Id, Sales_Program__c>
     */
    public Map<Id, Sales_Program__c> getSalesProgramById(Set<ID> idSet) {
        return new Map<Id, Sales_Program__c>((List<Sales_Program__c>) Database.query(newQueryFactory(true).selectFields(getSObjectFieldList()).setCondition('Id in :idSet').toSOQL()));
    }
    
     /**
     * This method used to get Sales_Program__c by Id
     * @return  Map<Id, Sales_Program__c>
     */
    public Map<Id, Sales_Program__c> getSalesProgramById(Set<ID> idSet, Set<String> fieldSet) {
        return new Map<Id, Sales_Program__c>((List<Sales_Program__c>) Database.query(newQueryFactory(true).selectFields(fieldSet).setCondition('Id in :idSet').toSOQL()));
    }
    
    /**********************************************************************************************
    * @Author: Barkha Pandey
    * @Date: 17/10/2021
    * @Description: This method is responsible for returning the list of Sales Program wrt to the 
                    passed search String
    * @Revision(s): [Date] - [Change Reference] - [Changed By] - [Description]
    ***********************************************************************************************/
    public List<Sales_Program__c> selectBySearchString(String searchString, Set<ID> actIdSet, Set<String> fieldSet) {
        return (List<Sales_Program__c>)Database.query(newQueryFactory(true).selectFields(fieldSet).setCondition('Name LIKE '+searchString+' AND Account_Name__c IN : actIdSet').toSOQL());
    }
}