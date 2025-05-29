public class BCH_GBL_Sharing_Daily_Correction implements Database.Batchable<Sobject>,Database.Stateful{
    private SObject_Sharing_Settings__c sharingSetting = SObject_Sharing_Settings__c.getInstance();
    private Map<String, Schema.SObjectType> globalDescribeMap = Schema.getGlobalDescribe();
    private Map<String,String> objectToQueryMap = new Map<String,String>();
    private Map<String,Set<Id>> objectToLookUpIdSetMap = new Map<String,Set<Id>>();
    private DateTime lastSharingCalculationTimeStamp;
    private List<SObject> socsList = new List<SObject>();
    private String objectName;
    
    public BCH_GBL_Sharing_Daily_Correction() { 
    }
    
    public BCH_GBL_Sharing_Daily_Correction(Map<String,String> objectToQueryMap, Map<String,Set<Id>> objectToLookUpIdSetMap, DateTime lastSharingCalculationTimeStamp) {
        this.objectToQueryMap = objectToQueryMap;
        this.objectToLookUpIdSetMap = objectToLookUpIdSetMap;
        this.lastSharingCalculationTimeStamp = lastSharingCalculationTimeStamp;
    }
    
    //Currently it is not picking Team Sharing Record
    public Database.QueryLocator start(Database.BatchableContext context) {
        String batchName = sharingSetting.Sharing_Maintenance_Job_Batch_Name__c;
        List<ApexClass> apexClassList = [SELECT Id FROM ApexClass where Name = :batchName];
        Set<String> statusSet = new Set<String>{'Aborted','Completed','Failed'};
        List<AsyncApexJob> batchJobsList = [SELECT ApexClassId FROM AsyncApexJob WHERE JobType = 'BatchApex' AND Status NOT IN :statusSet and ApexClassId = :apexClassList[0].Id];      
        if (batchJobsList.size() > 0) {
            System.abortJob(context.getJobId());
        }
        DateTime lastExecutionDate = sharingSetting.Last_Sharing_Calculation_Timestamp__c;
        String query = '';
        Set<Id> recordIdSet = new Set<Id>();
        if (objectToQueryMap.size() == 0) {
            lastSharingCalculationTimeStamp = System.Now().addMinutes(-1);
            List<SObject_Sharing__c> socsList = [select Id, Child_Sobject__c, Maintenance_Job_Status__c, Parent_Sobject__c, Lookup_Name__c, Child_Sobject_Share__c, Parent_Sobject_Share__c, Enable_Sharing_Calculation__c, Account_Country_Api_Name__c, Record_Type_Api_Name__c, Business_Unit_Api_Name__c, Parent_Customer_Code_Api_Name__c, Sharing_Type__c, Type__c, Sharing_Territory_Label__c, Sharing_Team_Label__c, Sharing_Owner_Label__c, Team_Sharing_Lookup_Field__c,Parent_Sharing_Team_Label__c, Parent_Sharing_Territory_Label__c from SObject_Sharing__c WHERE Enable_Sharing_Calculation__c = true ORDER BY Sharing_Type__c desc];
            System.debug(socsList);
            if (socsList.size() > 0) {
                String sObjName;
                Set<String> objectNameSet = new Set<String>();
                List<SObject> sObjRecordList = new List<SObject>();
                Map<String,Set<String>> parentToChildMap = new Map<String,Set<String>>();
                Map<String,String> parentToChildLookupMap = new Map<String,String>();
                for (SObject_Sharing__c socs :socsList) {
                    if (socs.Sharing_Type__c == 'Manual') {
                        if (!parentToChildMap.containsKey(socs.Parent_Sobject__c)) {
                            parentToChildMap.put(socs.Parent_Sobject__c, new Set<String>());
                        }
                    }
                    if (parentToChildMap.containsKey(socs.Parent_Sobject__c) && socs.Child_Sobject__c != null) {
                        parentToChildMap.get(socs.Parent_Sobject__c).add(socs.Child_Sobject__c);
                        String key = socs.Parent_Sobject__c + '::' + socs.Child_Sobject__c;
                        parentToChildLookupMap.put(key,socs.Lookup_Name__c);
                    }
                }
                system.debug(parentToChildLookupMap);
                Set<String> childObjectNameSet = new Set<String>();
                String parentOrChild = '';
                String fieldSetName = '';
                Boolean isAccount = false;
                for (SObject_Sharing__c socs :socsList) {
                    recordIdSet = new Set<Id>();
                    if (socs.Sharing_Type__c == 'Manual' && socs.Type__c == 'Child') {
                        isAccount = true;
                        sObjName = socs.Parent_Sobject__c;
                        parentOrChild = 'Parent';
                    } else if (socs.Child_Sobject__c != null) {
                        sObjName = socs.Child_Sobject__c;
                        fieldSetName = sharingSetting.Child_Sharing_FieldSet_Name__c;
                        parentOrChild = 'Child';
                    } else {
                        sObjName = socs.Parent_Sobject__c;
                        fieldSetName = sharingSetting.Parent_Sharing_FieldSet_Name__c;
                        parentOrChild = 'Parent';
                    }
                    String objNameAndType = sObjName + '::' + parentOrChild;
                    System.debug(isAccount);
                    List<Schema.FieldSetMember> sharingFieldSetMemberList;
                    if (!objectNameSet.contains(objNameAndType) && !childObjectNameSet.contains(objNameAndType)) {
                        objectNameSet.add(objNameAndType);
                        if (!isAccount) {
                            String fields = '';
                            sharingFieldSetMemberList = UTL_Sharing.getFieldSetValues(sObjName, fieldSetName);
                            for(Schema.FieldSetMember sf : sharingFieldSetMemberList) {
                                fields += sf.getFieldPath() + ',';
                            }
                            fields = fields.removeEnd(',');
                            query = 'SELECT Id,' + fields + ' FROM ' + sObjName + ' where Last_Sharing_Calculation_Timestamp__c > :lastExecutionDate Or CreatedDate > :lastExecutionDate';
                            objectToQueryMap.put(objNameAndType,query);
                        } else {
                            query = 'SELECT Id FROM ' + sObjName + ' where Last_Sharing_Calculation_Timestamp__c > :lastExecutionDate Or CreatedDate > :lastExecutionDate';
                        }
                        if(socs.Sharing_Type__c == 'Manual') { 
                            List<Sobject> recordList = DataBase.query(query);
                            for (Sobject obj : recordList) {
                                recordIdSet.add((Id)obj.get('Id'));
                            }  
                        }
                        if (recordIdSet.size() > 0) {
                            for (String childObjName :parentToChildMap.get(socs.Parent_Sobject__c)) {
                                if (isAccount) {
                                    sharingFieldSetMemberList = UTL_Sharing.getFieldSetValues(childObjName, sharingSetting.Parent_Sharing_FieldSet_Name__c);
                                    parentOrChild = 'Parent';
                                } else {
                                    sharingFieldSetMemberList = UTL_Sharing.getFieldSetValues(childObjName, sharingSetting.Child_Sharing_FieldSet_Name__c);
                                    parentOrChild = 'Child';
                                }
                                String fields = '';
                                for(Schema.FieldSetMember sf : sharingFieldSetMemberList) {
                                    fields += sf.getFieldPath() + ',';
                                }
                                fields = fields.removeEnd(','); 
                                String lookupName = parentToChildLookupMap.get(sObjName + '::' + childObjName);
                                query = 'SELECT Id,' + fields + ' FROM ' + childObjName + ' where ' + lookupName + ' In :recordIdSet Or Last_Sharing_Calculation_Timestamp__c > :lastExecutionDate Or CreatedDate > :lastExecutionDate';
                                System.debug(query);
                                objNameAndType = childObjName + '::' + parentOrChild;
                                objectToQueryMap.put(objNameAndType,query);
                                objectToLookUpIdSetMap.put(objNameAndType,recordIdSet);
                                childObjectNameSet.add(objNameAndType);  
                            }
                        }
                    }
                    isAccount = false;
                }    
            }
        }
        if (objectToQueryMap.size() > 0) {
            for(String objectNameAndType : objectToQueryMap.keySet()) {
                objectName = objectNameAndType;
                if (objectToLookUpIdSetMap.containsKey(objectNameAndType)) {
                    recordIdSet = objectToLookUpIdSetMap.get(objectNameAndType);
                }
                query = objectToQueryMap.get(objectNameAndType);
                break;
            }
        } else {
            System.abortJob(context.getJobId());
        }
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext context, List<SObject> recordsList) {
        UTL_Sharing.isFuture = false;
        List<String> sObjList = objectName.split('::');
        if (sObjList[1] == 'Child') {
            UTL_Sharing.setSharingRuleForChild(recordsList, null, sObjList[0]);  
        } else { 
            UTL_Sharing.setSharing(recordsList, null, sObjList[0]);
        }
    }
    
    public void finish(Database.BatchableContext bc){
        objectToQueryMap.remove(objectName);
        objectToLookUpIdSetMap.remove(objectName);
        if (objectToQueryMap.size() > 0) {
            BCH_GBL_Sharing_Daily_Correction bch = new BCH_GBL_Sharing_Daily_Correction(objectToQueryMap,objectToLookUpIdSetMap,lastSharingCalculationTimeStamp);
            DataBase.executeBatch(bch);    
        } else {
            sharingSetting.Last_Sharing_Calculation_Timestamp__c = lastSharingCalculationTimeStamp;
            upsert sharingSetting;   
        }
    }
    
}