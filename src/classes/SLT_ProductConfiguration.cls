/*
 * Version       : 1.0
 * Description   : This Apex class is selector layer for Product Configuration
 */
public class SLT_ProductConfiguration extends fflib_SObjectSelector {

    /**
     * This method used to get field list of sobject
     * @return  List<Schema.SObjectField>
     */
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField> {
            Apttus_Config2__ProductConfiguration__c.Id,
            Apttus_Config2__ProductConfiguration__c.Name,
            Apttus_Config2__ProductConfiguration__c.Apttus_CMConfig__AgreementId__c
        };
    }

    /**
     * This method used to set up type of sobject
     * @return  Schema.SObjectType
     */
    public Schema.SObjectType getSObjectType() {
        return Apttus_Config2__ProductConfiguration__c.SObjectType;
    }

    /**
    * This method used to get Product Configuration by Id
    * @return  List<Apttus_Config2__ProductConfiguration__c>
    */
    public List<Apttus_Config2__ProductConfiguration__c> selectById(Set<Id> idSet) {
        return (List<Apttus_Config2__ProductConfiguration__c>) selectSObjectsById(idSet);
    }

    /**
     * This method used to get Product Configuration field set by Id
     * @return List<Apttus_Config2__ProductConfiguration__c>
     */
    public List<Apttus_Config2__ProductConfiguration__c> selectFieldSetById(Set<Id> prodConfigIdSet, Set<String> fieldSet) {
        return (List<Apttus_Config2__ProductConfiguration__c>) Database.query(
            newQueryFactory(true)
            .selectFields(fieldSet)
            .setCondition('Id in:prodConfigIdSet')
            .toSOQL());
    }
    
    public List<Apttus_Config2__ProductConfiguration__c> getProductConfigByProposalIdAndStatus(Set<Id> proposalIds, 
        String status, Set<String> fieldSet) {
        return (List<Apttus_Config2__ProductConfiguration__c>) Database.query(newQueryFactory(true)
            .selectFields(fieldSet).setCondition('Apttus_QPConfig__Proposald__c IN :proposalIds ' + 
            'AND Apttus_Config2__Status__c =:status').toSOQL());
    }

    public List<Apttus_Config2__ProductConfiguration__c> getProductConfigByQuoteId(Set<Id> quoteIds, Set<String> fieldSet, String condition) {
        return (List<Apttus_Config2__ProductConfiguration__c>) Database.query(newQueryFactory(true)
            .selectFields(fieldSet).setCondition(condition).toSOQL());
    }
    
    public Map<Id, Apttus_Config2__ProductConfiguration__c> selectProposalConfigsWithLineItemsForRecordType(
        Set<Id> prodConfigIdSet, Set<Id> recordTypeIds, Set<String> fieldSet, Set<String> lineItemFields) {

        fflib_QueryFactory qf = new fflib_QueryFactory(Apttus_Config2__ProductConfiguration__c.SObjectType)
            .selectFields(fieldSet)
            .setCondition(
                'Id IN :prodConfigIdSet ' +
                'AND Apttus_QPConfig__Proposald__c != null ' +
                'AND Apttus_QPConfig__Proposald__r.RecordTypeId in :recordTypeIds '
            );     
        qf.subselectQuery('Apttus_Config2__LineItems__r').selectFields(lineItemFields);
        return new Map<Id, Apttus_Config2__ProductConfiguration__c>((List<Apttus_Config2__ProductConfiguration__c>) Database.query(qf.toSOQL()));
    }

    public List<Apttus_Config2__ProductConfiguration__c> getProductConfigByCondition(Set<Id> configId, String condition, Set<String> fieldSet) {
        return (List<Apttus_Config2__ProductConfiguration__c>) Database.query(newQueryFactory(true)
            .selectFields(fieldSet).setCondition(condition).toSOQL());
    }
}