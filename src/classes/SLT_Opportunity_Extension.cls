/**
* Created by Ronak Mehta on 19-Jun-2023
* Description : Selector Class for MDM_Invoicing_Transaction__c
*/
public class SLT_Opportunity_Extension extends fflib_SObjectSelector{
    
    /************constructor************/
    public SLT_Opportunity_Extension(){
        super(true, true, true);
    }
    
    /************param constructor************/
    public SLT_Opportunity_Extension(Boolean enforceCRUD,Boolean enforceFLS) {
        super(true, enforceCRUD, enforceFLS);
    }
    
    /************Method used to get field list of sobject************/
    public List<Schema.SObjectField> getSObjectFieldList(){
        return new List<Schema.SObjectField> { Opportunity_Extension__c.Id, Opportunity_Extension__c.Opportunity__c, Opportunity_Extension__c.BNF_Count__c};
            }
    
    /************Method used to set up type of sobject************/
    public Schema.SObjectType getSObjectType(){
        return Opportunity_Extension__c.sObjectType;
    }
    
    /**
     * This Method Used to get Opportunity_Extension__c by Opportunity Id
     * @params Set<Id> oppIdSet
     * @return List<Opportunity_Extension__c>
     */
    public List<Opportunity_Extension__c> getOpportunityExtensionByOppId(Set<Id> oppIdSet){
        return (List<Opportunity_Extension__c>) Database.query(newQueryFactory(true).setCondition('Opportunity__c IN :oppIdSet').toSOQL());
    }
}