/*
 * Version       : 1.0
 * Description   : This Apex class is selector layer for Contract Life Cycle
 */
public class SLT_ContractLifeCycle extends fflib_SObjectSelector {
    
    /**
     * constructor to initialize CRUD and FLS
     */
    public SLT_ContractLifeCycle() {
        super(false, true, true);
    }
    
    /**
     * Method to override OrderBy
     */
    public override String getOrderBy() {
        return 'CreatedDate DESC';
    }  
    
    /**
     * This method used to get field list of sobject
     * @return  List<Schema.SObjectField>
     */
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{
                Contract_Lifecycle__c.Id,
                Contract_Lifecycle__c.Account__c,
                Contract_Lifecycle__c.Budget_Minimum_Entry_Date__c,
                Contract_Lifecycle__c.Contract__c,
                Contract_Lifecycle__c.Executed_Minimum_Entry_Date__c,
                Contract_Lifecycle__c.Most_Recent_Actual_Contract_Value__c,
                Contract_Lifecycle__c.Most_Recent_Execution_Plan_Start_Date__c,
                Contract_Lifecycle__c.Most_Recent_Planned_Execution_Date__c,
                Contract_Lifecycle__c.Most_Recent_Project_Expenses_Value__c,
                Contract_Lifecycle__c.Most_Recent_Stage_Entry__c,
                Contract_Lifecycle__c.Total_Times_in_Stage__c,
                Contract_Lifecycle__c.Role_of_Status__c,
                Contract_Lifecycle__c.Status__c,
                Contract_Lifecycle__c.Total_Business_Days_in_Stage__c
                };
    }
    
    /**
     * This method used to set up type of sobject
     * @return  Schema.SObjectType
     */
    public Schema.SObjectType getSObjectType() {
        return Contract_Lifecycle__c.sObjectType;
    }
    
    /**
     * This method used to get LifeCycle record by Contract Ids
     * @return List<Contract_Lifecycle__c>
     */
    public List<Contract_Lifecycle__c> selectByContractId(Set<Id> contractIdSet) {
        return (List<Contract_Lifecycle__c>)Database.query(newQueryFactory(true).setCondition('Contract__c IN :contractIdSet').toSOQL());
    }
}