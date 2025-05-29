/*
 * Version       : 1.0
 * Description   : This Apex class is selector layer for Audit Logs
 */
public with sharing class SLT_Audit_Log extends fflib_SObjectSelector {

    /**
     * constructor to initialize CRUD and FLS
     */
    public SLT_Audit_Log() {
        super(false, false, false);
    }

     /**
     * This method used to set up type of sobject
     * @return  Schema.SObjectType
     */
    public Schema.SObjectType getSObjectType() {
        return Audit_Log__c.sObjectType;
    }

    /**
     * This method used to get field list of sobject
     * @return  List<Schema.SObjectField>
     */
    public List<Schema.SObjectField> getSObjectFieldList() {
        Schema.DescribeSObjectResult describeResult = getSObjectType().getDescribe();
        Map<String,Schema.SObjectField> fieldsMap = describeResult.fields.getMap();
        return fieldsMap.values();
    }

    public List<Audit_Log__c> selectAuditLogsByRecordId(Set<Id> idSet, Set<String> requestedFields) {
        return selectAuditLogsByRecordId(idSet, requestedFields, null);
    }
    /**
     * This method returns a list of Audit Logs by record id with desire fields
     */
    public List<Audit_Log__c> selectAuditLogsByRecordId(Set<Id> idSet, Set<String> requestedFields, Integer limitCount) {
        fflib_QueryFactory qf = newQueryFactory(false).selectFields(requestedFields).setCondition('Record_ID__c IN :idSet');
        if (limitCount != null && limitCount > 0) {
            qf.setLimit(limitCount);
        }
        qf.addOrdering('Time__c', fflib_QueryFactory.SortOrder.DESCENDING);

        return ((List<Audit_Log__c>) Database.query(qf.toSOQL()));
    }
    /**
     * Return a Map of replay id to audit logs for  specific replay ids
     */
    public Map<String, Audit_Log__c[]> selectAuditLogsByReplayId(Set<String> replayIds, Set<String> fieldNames) {
        Map<String, Audit_Log__c[]> results = new Map<String, Audit_Log__c[]>();
        fieldNames.add('Replay_Id__c'); // ensure this field is added to soql!
        Audit_Log__c[] alogs = Database.query(newQueryFactory(false).selectFields(fieldNames).setCondition('Replay_Id__c IN :replayIds').toSOQL());
        if (alogs.isEmpty() == false) {
            for (Audit_Log__c alog: alogs) {
                Audit_Log__c[] alist = results.get(alog.Replay_Id__c);
                alist = alist != null  ? alist : new Audit_Log__c[]{};
                alist.add(alog);
                results.put(alog.Replay_Id__c, alist);
            }
        }
        return results;
    }
}