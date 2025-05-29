/*
*   This class is used for fetching record of the Docusign_Status. 
*/
public class SLT_Docusign_Status extends fflib_SObjectSelector {
    
    /**
     * constructor to initialise CRUD and FLS.
     */
    public SLT_Docusign_Status() {
        super(false, false, false);
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
        return dsfs__DocuSign_Status__c.sObjectType;
    }

    /**
     * This method used to get dsfs__DocuSign_Status__c by Id
     * @return  List<dsfs__DocuSign_Status__c>
     */
    public List<dsfs__DocuSign_Status__c> selectById(Set<ID> idSet) {
        return (List<dsfs__DocuSign_Status__c>) selectSObjectsById(idSet);
    }

    /**
    * This method used to get lists of dsfs__DocuSign_Status__c
    * @return  list
    */
    public List<dsfs__DocuSign_Status__c> getDocuSignStatus(Set<String> fields, String condition) {
        fflib_QueryFactory factory = newQueryFactory(true);
        factory.selectFields(fields);

        if(!String.isBlank(condition)) {
            factory.setCondition(condition).setOrdering('CreatedDate', fflib_QueryFactory.SortOrder.DESCENDING, true);
        }
        return Database.query(factory.toSOQL());
    }

    /**
    * This method used to get lists of dsfs__DocuSign_Status__c
    * @return  list
    */
    public List<dsfs__DocuSign_Status__c> getDocuSignStatus(Set<String> fields, String condition, Set<Id> agreementIdSet) {
        fflib_QueryFactory factory = newQueryFactory(true);
        factory.selectFields(fields);

        if(!String.isBlank(condition)) {
            if(!agreementIdSet.isEmpty()) {
                condition += 'AND Agreement__c IN :agreementIdSet';
            }
            factory.setCondition(condition).setOrdering('CreatedDate', fflib_QueryFactory.SortOrder.DESCENDING, true);
        } else if(!agreementIdSet.isEmpty()) {
            factory.setCondition('Agreement__c IN :agreementIdSet');
        }
        return Database.query(factory.toSOQL());
    }

    /*
    * This method is use to query DocuSign_Status__c with related items on the basis of id and condition given
    * @return Map<Id, dsfs__DocuSign_Status__c>
    * @param Set<Id> agrIdSet
    * @param Set<String> fieldSetForDocusignStatus
    * @param String conditions
    */
    public Map<Id, dsfs__DocuSign_Status__c> getDocusignStatusByAGRIdWithDocusignRecipientStatusFromLastEnvelope(Set<Id> agrIdSet, 
        Set<String> fieldSetForDocusignStatus, String conditions) {
            fflib_QueryFactory queryFactory = newQueryFactory();
            new SLT_DocusignRecipientStatus().addQueryFactorySubselect(queryFactory, 'dsfs__R00NS0000000WUO2MAO__r');
            String queryConditions = 'Agreement__c in :agrIdSet';
            if(conditions != null && !conditions.equals('')) {
                queryConditions += ' And ' + conditions;
            }
            String queryString = queryFactory.selectFields(fieldSetForDocusignStatus).setCondition(queryConditions)
                .setOrdering('CreatedDate', fflib_QueryFactory.SortOrder.DESCENDING, true).toSOQL();
            List<dsfs__DocuSign_Status__c> DocusignStatusList = Database.query(queryString);
            Map<Id, dsfs__DocuSign_Status__c> agrIdWithDocusignStatusMap = new Map<Id, dsfs__DocuSign_Status__c>();
            for(dsfs__DocuSign_Status__c DocusignStatus : DocusignStatusList) {
                if(!agrIdWithDocusignStatusMap.containsKey(DocusignStatus.Agreement__c)) {
                    agrIdWithDocusignStatusMap.put(DocusignStatus.Agreement__c, DocusignStatus);
                }
            }
            return agrIdWithDocusignStatusMap;
    }
}