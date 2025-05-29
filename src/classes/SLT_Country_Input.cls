/**
 * Version       : 1.0
 * Description   : This Apex class is selector layer for AgreementLineItems
 */
public class SLT_Country_Input extends fflib_SObjectSelector {
    
    /**
     * constructor to initialise CRUD and FLS
     */
    public SLT_Country_Input() {
        super(false, true, false);
    }
    
    /**
     * constructor to initialise CRUD and FLS with a parameter for FLS.
     */
    public SLT_Country_Input(Boolean enforceFLS) {
        super(false, true, enforceFLS);
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
        return Country_Input__c.sObjectType;
    }
    
    /**
     * This method used to get AgreementLineItem Records by agreement Id
     * @return  List<OpportunityLineItem>
     */
    public List<Country_Input__c> selectByAgreementIds(Set<Id> parentIdsSet, Set<String> fieldSet, String condition) {
        return (List<Country_Input__c>) Database.query(newQueryFactory(true).selectFields(fieldSet).setCondition(condition).toSOQL());
    }
}