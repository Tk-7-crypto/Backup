public class TGRH_CDADocusignStatus {
    //static List < CDA_Request__c > cdaRequestList = new List < CDA_Request__c >();
    //static Map < String, CDA_Request__c > cdaRequestMapWithCDAId = new Map < String, CDA_Request__c > ();
    //static Map < id, CDA_Request__c > cdaRequestUpdateMap = new Map < id, CDA_Request__c > ();
    
    /*public static void bulkBefore(Set<String> cdaIds) {
        String query = 'SELECT id, Name, CDA_Id__c, RecordTypeId FROM CDA_Request__c WHERE CDA_Id__c IN: cdaIds AND RecordType.Name != \''+UTL_CDAUtility.historicalDataRecordType+'\'';
        system.debug('####inside DAOH_DocusignStatus.bulkBefore query: '+query);
        cdaRequestList = Database.query(query);
        for (CDA_Request__c cdaRequest: cdaRequestList) {
            cdaRequestMapWithCDAId.put((String)cdaRequest.get('CDA_Id__c'), cdaRequest);
        }
    }*/
    
    public static void handleDocusignStatusBeforeInsert(Map<String, dsfs__DocuSign_Status__c> newStatusMap, Set<String> cdaIds) {
        List < CDA_Request__c > cdaRequestList = new List < CDA_Request__c >();
        Map < String, CDA_Request__c > cdaRequestMapWithCDAId = new Map < String, CDA_Request__c > ();
        Map < id, CDA_Request__c > cdaRequestUpdateMap = new Map < id, CDA_Request__c > ();
        fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(
            new Schema.SObjectType[] {
                CDA_request__c.SobjectType
            }
        );
        system.debug('####inside TGRH_CDADocusignStatus.handleDocusignStatusBeforeInsert cdaIds: '+cdaIds);
        Boolean toCommit = false;
        String query = 'SELECT id, Name, CDA_Id__c, RecordTypeId FROM CDA_Request__c WHERE CDA_Id__c IN: cdaIds AND RecordType.Name != \''+UTL_CDAUtility.historicalDataRecordType+'\'';
        system.debug('####inside TGRH_CDADocusignStatus.handleDocusignStatusBeforeInsert query: '+query);
        cdaRequestList = Database.query(query);
        for (CDA_Request__c cdaRequest: cdaRequestList) {
            cdaRequestMapWithCDAId.put((String)cdaRequest.get('CDA_Id__c'), cdaRequest);
        }
        if (newStatusMap!= null && newStatusMap.size() > 0) {
            for(String cdaReqNo: newStatusMap.keySet()){
                newStatusMap.get(cdaReqNo).CDA_Request__c = cdaRequestMapWithCDAId.get(cdaReqNo).Id;
                cdaRequestMapWithCDAId.get(cdaReqNo).Status__c = UTL_CDAUtility.STATUS_SENTFORSIGN;
                cdaRequestMapWithCDAId.get(cdaReqNo).Status_Start_Date__c = System.now(); 
                cdaRequestUpdateMap.put(cdaRequestMapWithCDAId.get(cdaReqNo).Id, cdaRequestMapWithCDAId.get(cdaReqNo));
                toCommit = true;
            }
        }
        if(toCommit) {
            uow.registerDirty(cdaRequestUpdateMap.values());
        }
        system.debug('####inside TGRH_CDADocusignStatus.handleDocusignStatusBeforeInsert uow: '+uow);
        if(toCommit) {
            uow.commitWork();
        }
        SRV_CDA_DocusignStatus.setVoidToDocusignEnvelope(cdaIds);
    }
    
    public static void handleDocusignStatusBeforeUpdate(List<dsfs__DocuSign_Status__c> newList, Map<String, String> statusWithCDAId, Set<String> cdaIds, Map<Id, dsfs__DocuSign_Status__c> oldMap) {
        List < CDA_Request__c > cdaRequestList = new List < CDA_Request__c >();
        Map < String, CDA_Request__c > cdaRequestMapWithCDAId = new Map < String, CDA_Request__c > ();
        Map < id, CDA_Request__c > cdaRequestUpdateMap = new Map < id, CDA_Request__c > ();
        fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(
            new Schema.SObjectType[] {
                CDA_request__c.SobjectType
            }
        );
        Boolean toCommit = false;
        String query = 'SELECT id, Name, CDA_Id__c, RecordTypeId FROM CDA_Request__c WHERE CDA_Id__c IN: cdaIds AND RecordType.Name != \''+UTL_CDAUtility.historicalDataRecordType+'\'';
        system.debug('####inside DAOH_DocusignStatus.bulkBefore query: '+query);
        cdaRequestList = Database.query(query);
        for (CDA_Request__c cdaRequest: cdaRequestList) {
            cdaRequestMapWithCDAId.put((String)cdaRequest.get('CDA_Id__c'), cdaRequest);
        }
        for (dsfs__DocuSign_Status__c docusignStatus: newList) {
            // dsfs__DocuSign_Status__c oldDocusignStatusObj = (dsfs__DocuSign_Status__c)trigger.oldMap.get(docusignStatus.Id);
            dsfs__DocuSign_Status__c oldDocusignStatusObj = oldMap.get(docusignStatus.Id);
            if(docusignStatus.dsfs__Envelope_Status__c == UTL_CDAUtility.DS_DECLINED && oldDocusignStatusObj.dsfs__Envelope_Status__c != UTL_CDAUtility.DS_DECLINED && statusWithCDAId != null && statusWithCDAId.size() > 0 && statusWithCDAId.containsKey(docusignStatus.id) && cdaRequestMapWithCDAId != null && cdaRequestMapWithCDAId.size() > 0 && cdaRequestMapWithCDAId.containsKey(statusWithCDAId.get(docusignStatus.Id)) && cdaRequestMapWithCDAId.get(statusWithCDAId.get(docusignStatus.Id)).RecordTypeId != Schema.SObjectType.CDA_Request__c.getRecordTypeInfosByName().get(UTL_CDAUtility.historicalDataRecordType).getRecordTypeId()) {   //Updated by Vikram Singh under CR-11691
                cdaRequestMapWithCDAId.get(statusWithCDAId.get(docusignStatus.Id)).Status__c = UTL_CDAUtility.STATUS_SIGNATURE_REQUEST_DENIED;
                cdaRequestMapWithCDAId.get(statusWithCDAId.get(docusignStatus.Id)).Negotiator_Assigned_List__c = UTL_CDAUtility.NEGO_NOT_ASSIGN;
                cdaRequestUpdateMap.put(cdaRequestMapWithCDAId.get(statusWithCDAId.get(docusignStatus.Id)).Id, cdaRequestMapWithCDAId.get(statusWithCDAId.get(docusignStatus.Id)));
                toCommit = true;
            }
        }
        if(toCommit) {
            uow.registerDirty(cdaRequestUpdateMap.values());
        }
        system.debug('####inside DAOH_DocusignStatus.BeforeUpdate uow: '+uow);
        if(toCommit) {
            uow.commitWork();
        }
    }

    /*public static void cancelRequestsHavingExpiredEnvelope(List<dsfs__DocuSign_Status__c> newList, Boolean toCommit, fflib_SObjectUnitOfWork uow, Map<String, String> statusWithCDAId, Map<Id, dsfs__DocuSign_Status__c> oldMap) {
        system.debug('####TGRH_CDADocusignStatus.cancelRequestsHavingExpiredEnvelope newList: ' +newList);
        system.debug('####TGRH_CDADocusignStatus.cancelRequestsHavingExpiredEnvelope oldList: ' +oldMap.values());
        for (dsfs__DocuSign_Status__c docusignStatus: newList) {
            dsfs__DocuSign_Status__c oldDocusignStatusObj = oldMap.get(docusignStatus.Id);
            if(docusignStatus.dsfs__Envelope_Status__c == UTL_CDAUtility.DS_VOIDED && oldDocusignStatusObj.dsfs__Envelope_Status__c != UTL_CDAUtility.DS_VOIDED && (docusignStatus.dsfs__Voided_Reason__c == UTL_CDAUtility.DS_ENVELOPE_VOID_REASON_EXPIRED || docusignStatus.dsfs__Voided_Reason_Extended__c == UTL_CDAUtility.DS_ENVELOPE_VOID_REASON_EXPIRED) && statusWithCDAId != null && statusWithCDAId.size() > 0 && statusWithCDAId.containsKey(docusignStatus.id) && cdaRequestMapWithCDAId != null && cdaRequestMapWithCDAId.size() > 0 && cdaRequestMapWithCDAId.containsKey(statusWithCDAId.get(docusignStatus.Id)) && cdaRequestMapWithCDAId.get(statusWithCDAId.get(docusignStatus.Id)).RecordTypeId != Schema.SObjectType.CDA_Request__c.getRecordTypeInfosByName().get(UTL_CDAUtility.historicalDataRecordType).getRecordTypeId()) {   //Updated by Vikram Singh under CR-11691
                cdaRequestMapWithCDAId.get(statusWithCDAId.get(docusignStatus.Id)).Status__c = UTL_CDAUtility.STATUS_CANCELEDBYREQUESTOR;
                cdaRequestUpdateMap.put(cdaRequestMapWithCDAId.get(statusWithCDAId.get(docusignStatus.Id)).Id, cdaRequestMapWithCDAId.get(statusWithCDAId.get(docusignStatus.Id)));
                toCommit = true;
            }
            if(toCommit) {
                uow.registerDirty(cdaRequestUpdateMap.values());
            }
        }
        system.debug('####inside DAOH_DocusignStatus.cancelRequestsHavingExpiredEnvelope uow: '+uow);
        if(toCommit) {
            uow.commitWork();
        }
    }*/
}
