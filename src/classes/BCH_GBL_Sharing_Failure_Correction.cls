public class BCH_GBL_Sharing_Failure_Correction implements Database.Batchable<Sobject>,Database.Stateful {
    private SObject_Sharing_Settings__c sharingSetting = SObject_Sharing_Settings__c.getInstance();
    private Map<String, Schema.SObjectType> globalDescribeMap = Schema.getGlobalDescribe(); 
    private Map<String, String> objectToFieldsMap = new Map<String, String>();
    private Set<Id> parentIdSet = new Set<Id>();
    
    public Database.QueryLocator start(Database.BatchableContext context) {
        String batchName = sharingSetting.Sharing_Maintenance_Job_Batch_Name__c;
        List<ApexClass> apexClassList = [SELECT Id FROM ApexClass where Name = :batchName];
        Set<String> statusSet = new Set<String>{'Aborted','Completed','Failed'};
        List<AsyncApexJob> batchJobsList = [SELECT ApexClassId FROM AsyncApexJob WHERE JobType = 'BatchApex' AND Status NOT IN :statusSet and ApexClassId = :apexClassList[0].Id];      
        if (batchJobsList.size() > 0) {
            System.abortJob(context.getJobId());
        }
        String query = 'Select Id, Fail_Record_Id__c, Parent_Record_Id__c, Reason__c from Fail_Sharing_Log__c order by Fail_Record_Id__c';
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext context, List<Fail_Sharing_Log__c> records) {
        Map<String,Set<Id>> objectToRecordIdSetMap = new Map<String,Set<Id>>();
        Id recordId;
        String parentOrChild = '';
        String fieldSetName = '';
        UTL_Sharing.isFuture = false;
        Set<Id> failRecordsToDeleteSet = new Set<Id>();
        List<Fail_Sharing_Log__c> failRecordDeleteList = new List<Fail_Sharing_Log__c>();
        for (Fail_Sharing_Log__c failLog : records) {
            if (failLog.Fail_Record_Id__c != null) {
                recordId = failLog.Fail_Record_Id__c;
                fieldSetName = sharingSetting.Parent_Sharing_FieldSet_Name__c; 
                parentOrChild = 'Parent';
            }
            if (failLog.Parent_Record_Id__c != null){
                fieldSetName = sharingSetting.Child_Sharing_FieldSet_Name__c;
                parentOrChild = 'Child';
            }
            if (!parentIdSet.contains(recordId)) {
                parentIdSet.add(recordId);
                String sObjName = recordId.getSObjectType().getDescribe().getName();
                String fields = '';
                if(!objectToFieldsMap.containsKey(sObjName)) {
                    List<Schema.FieldSetMember> sharingFieldSetMemberList;
                    sharingFieldSetMemberList = UTL_Sharing.getFieldSetValues(sObjName, fieldSetName);
                    for(Schema.FieldSetMember sf : sharingFieldSetMemberList) {
                        fields += sf.getFieldPath() + ',';
                    }
                    fields = fields.removeEnd(',');
                    objectToFieldsMap.put(sObjName,fields);
                }
                String objNameAndType = sObjName + '::' + parentOrChild;
                if (objectToRecordIdSetMap.containsKey(objNameAndType)) {
                    objectToRecordIdSetMap.get(objNameAndType).add(recordId);
                } else {
                    Set<Id> idSet = new Set<Id>();
                    idSet.add(recordId);
                    objectToRecordIdSetMap.put(objNameAndType,idSet);
                }
            }
        }
        for (String sobjAndType : objectToRecordIdSetMap.keySet()) {
            List<String> sObjList = sobjAndType.split('::');
            Set<Id> recordIdSet = objectToRecordIdSetMap.get(sobjAndType);
            String fields = objectToFieldsMap.get(sObjList[0]);
            String query = 'SELECT Id,' + fields + ' FROM ' + sObjList[0] + ' WHERE Id IN :recordIdSet';
            List<SObject> sobjectList = DataBase.query(query);
            for (SObject sobj : sobjectList) {
                recordIdSet.remove((Id)sobj.get('Id'));
            }
            failRecordsToDeleteSet.addAll(recordIdSet);
            System.debug(sobjectList);
            if (sobjectList.size() > 0) {
                if (sObjList[1] == 'Child') {
                    UTL_Sharing.setSharingRuleForChild(sobjectList, null, sObjList[0]);   
                } else { 
                    System.debug(sobjectList);
                    UTL_Sharing.setSharing(sobjectList, null, sObjList[0]);
                }             
            }
        }
        for (Fail_Sharing_Log__c failLog : records) {
            if (failRecordsToDeleteSet.contains(failLog.Fail_Record_Id__c)) {
                failRecordDeleteList.add(failLog);
            }
        }
        if (failRecordDeleteList.size() > 0) {
            delete failRecordDeleteList;
        }
    }
    
    public void finish(Database.BatchableContext bc){
    }
    
}