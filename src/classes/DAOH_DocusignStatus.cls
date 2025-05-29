/**
* This is dsfs__DocuSign_Status__c trigger handler class.
* version : 1.0
*/
public class DAOH_DocusignStatus {
    
    //private Variable
    //static Map < id, CDA_Request__c > cdaRequestUpdateMap = new Map < id, CDA_Request__c > ();
    //static Map < String, String > statusWithCDAId = new Map < String, String > ();
    //static Set < String > cdaIds = new Set < String > ();
    //static List < CDA_Request__c > cdaRequestList = new List < CDA_Request__c > ();
    //static Map < String, CDA_Request__c > cdaRequestMapWithCDAId = new Map < String, CDA_Request__c > ();
    //static List<dsfs__DocuSign_Status__c> tpaDsStatusList = new List<dsfs__DocuSign_Status__c>();
    static TGRH_TPADocusignStatus statusHelper = new TGRH_TPADocusignStatus();
    //static Map<String, dsfs__DocuSign_Status__c> cdaReqToDocusignStatusMap = new Map<String, dsfs__DocuSign_Status__c>();
    
    /**
    * This method is called prior to execution of a BEFORE trigger. Use this to cache
    * any data required into maps prior execution of the trigger.
    * @params List<dsfs__DocuSign_Status__c> newList
    * @return void
    */
    /*public static void bulkBefore(List<dsfs__DocuSign_Status__c> newList) {
        String str;
        tpaDsStatusList = new List<dsfs__DocuSign_Status__c>();
        for (dsfs__DocuSign_Status__c docusignStatus: newList) {
            if (docusignStatus.dsfs__Subject__c != null && docusignStatus.dsfs__Subject__c.contains('CDA-') && !UTL_CDAUtility.isSkipCDATriggers) {
                str = 'CDA-' + docusignStatus.dsfs__Subject__c.split('-')[1];
                cdaIds.add(str);
                statusWithCDAId.put(docusignStatus.id, str);
                if(!cdaReqToDocusignStatusMap.containsKey(str)){
                    cdaReqToDocusignStatusMap.put(str, docusignStatus);
                }
            }
            else if(docusignStatus.dsfs__Subject__c != null && docusignStatus.dsfs__Subject__c.contains('TPA-') && !UTL_TPA.tpaSetting.Is_Skip_TPA_Triggers__c) {
                tpaDsStatusList.add(docusignStatus);
            }
        }
        if(!UTL_CDAUtility.isSkipCDATriggers && cdaIds != null && cdaIds.size() > 0) {
            TGRH_CDADocusignStatus.bulkBefore(cdaIds);
        }
    }*/
    
    /**
    * This method is called  for list of new record to be inserted during a BEFORE trigger
    * @params List<dsfs__DocuSign_Status__c> newList
    * @return void.
    */
    public static void handleDocusignStatusBeforeInsert(List<dsfs__DocuSign_Status__c> newList) {
        //List<dsfs__DocuSign_Status__c> tpaDsStatusList = new List<dsfs__DocuSign_Status__c>();
        Map<String, dsfs__DocuSign_Status__c> cdaReqToDocusignStatusMap = new Map<String, dsfs__DocuSign_Status__c>();
        Map<String, dsfs__DocuSign_Status__c> tpaReqToDocusignStatusMap = new Map<String, dsfs__DocuSign_Status__c>();
        Set < String > cdaIds = new Set < String > ();
        Set < String > tpaIds = new Set < String > ();
        String str;
        for (dsfs__DocuSign_Status__c docusignStatus: newList) {
            if (docusignStatus.dsfs__Subject__c != null && docusignStatus.dsfs__Subject__c.contains('CDA-') && !UTL_CDAUtility.isSkipCDATriggers) {
                str = 'CDA-' + docusignStatus.dsfs__Subject__c.split('-')[1];
                cdaIds.add(str);
                if(!cdaReqToDocusignStatusMap.containsKey(str)){
                    cdaReqToDocusignStatusMap.put(str, docusignStatus);
                }
            }
            else if(docusignStatus.dsfs__Subject__c != null && docusignStatus.dsfs__Subject__c.contains('TPA-') && !UTL_TPA.tpaSetting.Is_Skip_TPA_Triggers__c) {
                string mailSubject = docusignStatus.dsfs__Subject__c.split(',')[0];
                string tpa = '';
                if(mailSubject != null && mailSubject != ''){
                    tpa = mailSubject.split(':')[1];
                }
                if(tpa != null && tpa != ''){
                    tpaIds.add(tpa.trim());
                    if(!tpaReqToDocusignStatusMap.containsKey(tpa.trim())){
                        tpaReqToDocusignStatusMap.put(tpa.trim(), docusignStatus);
                    }
                }
                //tpaDsStatusList.add(docusignStatus);
            }
        }
        if(!UTL_CDAUtility.isSkipCDATriggers && cdaIds != null && cdaIds.size() > 0) {
            TGRH_CDADocusignStatus.handleDocusignStatusBeforeInsert(cdaReqToDocusignStatusMap,cdaIds);
        }
        if(!UTL_TPA.tpaSetting.Is_Skip_TPA_Triggers__c && tpaIds != null && tpaIds.size() > 0) {
            statusHelper.onBeforeInsert(tpaReqToDocusignStatusMap,tpaIds);
        }
    }
    
    /**
    * This method is called  for list of new record to be updated during a BEFORE trigger
    * @params List<dsfs__DocuSign_Status__c> newList, Map<Id, dsfs__DocuSign_Status__c> oldMap
    * @return void
    */
    public static void handleDocusignStatusBeforeUpdate(List<dsfs__DocuSign_Status__c> newList, Map<Id, dsfs__DocuSign_Status__c> oldMap) {
        Map < String, String > statusWithCDAId = new Map < String, String > ();
        Set < String > cdaIds = new Set < String > ();
        String str;
        for (dsfs__DocuSign_Status__c docusignStatus: newList) {
            if (docusignStatus.dsfs__Subject__c != null && docusignStatus.dsfs__Subject__c.contains('CDA-') && !UTL_CDAUtility.isSkipCDATriggers) {
                str = 'CDA-' + docusignStatus.dsfs__Subject__c.split('-')[1];
                cdaIds.add(str);
                statusWithCDAId.put(docusignStatus.id, str);
            }
        }
        system.debug('####inside DAOH_DocusignStatus.BeforeUpdate cdaIds: '+cdaIds);
        if(!UTL_CDAUtility.isSkipCDATriggers && cdaIds != null && cdaIds.size() > 0) {
            TGRH_CDADocusignStatus.handleDocusignStatusBeforeUpdate(newList, statusWithCDAId, cdaIds, oldMap);
        }
    }
    
    public static void onAfterUpdate(List<dsfs__DocuSign_Status__c> newRecords) {
        List<dsfs__DocuSign_Status__c> tpaDsStatusList = new List<dsfs__DocuSign_Status__c>();
        for (dsfs__DocuSign_Status__c docusignStatus: newRecords) {
            if(docusignStatus.TPA_Request__c != null && !UTL_TPA.tpaSetting.Is_Skip_TPA_Triggers__c) {
                tpaDsStatusList.add(docusignStatus);
            }
        }
        if(tpaDsStatusList.size() > 0 && !UTL_TPA.tpaSetting.Is_Skip_TPA_Triggers__c) {
            statusHelper.onAfterUpdate(tpaDsStatusList);
        }
    }
    /**
    * This method is called for list of expired envelope record during a AFTER trigger
    * @params Map<Id, dsfs__DocuSign_Status__c> oldMap
    * @return void
    */
    /*public static void cancelRequestsHavingExpiredEnvelope(List<dsfs__DocuSign_Status__c> newList, Map<Id, dsfs__DocuSign_Status__c> oldMap) {
        fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(
            new Schema.SObjectType[] {
                CDA_request__c.SobjectType
                    }
        );
        Boolean toCommit = false;
        system.debug('####inside DAOH_DocusignStatus.AfterUpdate cdaIds: '+cdaIds);
        if(!UTL_CDAUtility.isSkipCDATriggers && cdaIds != null && cdaIds.size() > 0) {
            TGRH_CDADocusignStatus.cancelRequestsHavingExpiredEnvelope(newList, toCommit, uow, statusWithCDAId, oldMap);
        }
    }*/

    
    public static void updateDocuSign_SignedStatusRecords(List<dsfs__DocuSign_Status__c> statusList )
    {
        map<String,String> envelopMap = new map<String,String>();
        for(dsfs__DocuSign_Status__c ds: statusList){
            envelopMap.put(ds.dsfs__DocuSign_Envelope_ID__c, ds.Id);
        }
        
        if(!envelopMap.isEmpty()){
            List<Contract> listToUpdate = new List<Contract>();
            for(Contract c : getListOfContract(envelopMap.keySet())){
                c.DocusignStatusId__c = envelopMap.get(c.DocuSign_Envelope_Id__c);
                listToUpdate.add(c);
            }
            updateListOfContract(listToUpdate);
        } 
    }
    
    @testVisible 
    private static void updateListOfContract( List<Contract> listToUpdate)
    {
        if(!useMock) {
            update listToUpdate;
        }
    }
    
    @testVisible 
    private static List<Contract> getListOfContract(Set<String> envelopKeySet) {
        List<Contract> cnt = new List<Contract>();
        if(!useMock) {
            
            cnt=[Select Id, DocuSign_Envelope_Id__c, DocusignStatusId__c
                 From Contract Where DocuSign_Envelope_Id__c IN : envelopKeySet];
        }
        else{
            cnt=testContractList;
        }
        return cnt;
    }
    @testvisible static List<Contract> testContractList;
    @testVisible static Boolean useMock = false;
}
