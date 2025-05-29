/*
 * Version       : 1.0
 * Description   : This Apex class is selector layer for Competitor.
 */
public class SLT_Competitor extends fflib_SObjectSelector {
    
    /**
     * This method used to get field list of sobject
     * @return  List<Schema.SObjectField>
     */
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField> {
            Competitor__c.Id,
        	Competitor__c.Name,
            Competitor__c.SalesSpot_Enabled__c
        };
    }

    /**
     * This method used to set up type of sobject
     * @return  Schema.SObjectType
     */
    public Schema.SObjectType getSObjectType() {
        return Competitor__c.sObjectType;
    }
    
    /**
     * This method used to get Competitor__c by Id
     * @return  Map<Id, Competitor__c>
     */
    public Map<Id, Competitor__c> selectSalesSpotCompetitorById(Set<ID> idSet, Set<String> fieldSet) {
        return new Map<Id, Competitor__c>((List<Competitor__c>) Database.query(newQueryFactory(true).selectFields(fieldSet).setCondition('SalesSpot_Enabled__c = true AND Id in :idSet').toSOQL()));
    }

}