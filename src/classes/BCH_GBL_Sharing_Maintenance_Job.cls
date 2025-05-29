public class BCH_GBL_Sharing_Maintenance_Job implements Database.Batchable<Sobject>,Database.Stateful{
    private SObject_Sharing_Settings__c sharingSetting = SObject_Sharing_Settings__c.getInstance();
    private Map<String, Schema.SObjectType> globalDescribeMap = Schema.getGlobalDescribe();
    private List<SObject> socsList = new List<SObject>();
    private List<SObject> territoryList = new List<SObject>();
    private String sObjectName;
    private Map<String,Set<String>> objectNameToAccountCountryMap = new Map<String,Set<String>>();
    private Map<String,Set<String>> objectNameToRecordTypeMap = new Map<String,Set<String>>();
    private Map<String,Set<String>> objectNameToBusinessUnitMap = new Map<String,Set<String>>();
    private Map<String,Set<String>> objectNameToParentCustomerCodeMap = new Map<String,Set<String>>();
    
    public BCH_GBL_Sharing_Maintenance_Job(List<SObject> sObjectList) {
        if (sObjectList.size() > 0) {
            Id recordId = sObjectList[0].Id;
            String sObjName = recordId.getSObjectType().getDescribe().getName();
            if (sObjName == 'SObject_Sharing__c') {
                socsList = sObjectList;
            } else if (sObjName == 'Territory_Sharing__c'){
                territoryList = sObjectList;
            }
        }
    }
    
    public BCH_GBL_Sharing_Maintenance_Job(List<SObject> sObjectList, Map<String,Set<String>> objectNameToAccountCountryMap, Map<String,Set<String>> objectNameToRecordTypeMap, Map<String,Set<String>> objectNameToBusinessUnitMap, Map<String,Set<String>> objectNameToParentCustomerCodeMap) {
        if (sObjectList.size() > 0) {
            socsList = sObjectList;
            this.objectNameToAccountCountryMap = objectNameToAccountCountryMap;
            this.objectNameToRecordTypeMap = objectNameToRecordTypeMap;
            this.objectNameToBusinessUnitMap = objectNameToBusinessUnitMap;
            this.objectNameToParentCustomerCodeMap = objectNameToParentCustomerCodeMap;
        }
    }
    
    public Database.QueryLocator start(Database.BatchableContext context) {
        Set<String> batchNameSet = new Set<String>();
        batchNameSet.add(sharingSetting.Sharing_Failure_Correction_Batch_Name__c);
        batchNameSet.add(sharingSetting.Sharing_Daily_Correction_Batch_Name__c);
        List<ApexClass> apexClassList = [SELECT Id FROM ApexClass where Name IN :batchNameSet];
        Set<String> statusSet = new Set<String>{'Aborted','Completed','Failed'};
        Set<Id> batchIdSet = new Set<Id>();
        String fields = '';
        String fieldSetName = '';
        batchIdSet.add(apexClassList[0].Id);
        batchIdSet.add(apexClassList[1].Id);
        List<AsyncApexJob> batchJobsList = [SELECT ApexClassId FROM AsyncApexJob WHERE JobType = 'BatchApex' AND Status NOT IN :statusSet and ApexClassId IN :batchIdSet];      
        if (batchJobsList.size() > 0) {
            System.abortJob(context.getJobId());
        }
        if (socsList.size() > 0 && territoryList.size() == 0) {
            if (!(socsList[0].get('Sharing_Type__c') == 'Manual' && socsList[0].get('Type__c') == 'Child')) {
                socsList[0].put('Maintenance_Job_Status__c', 'In Processing');
                update socsList[0];
                if (socsList[0].get('Child_Sobject__c') != null) {
                    sObjectName = (String)socsList[0].get('Child_Sobject__c');
                    fieldSetName = sharingSetting.Child_Sharing_FieldSet_Name__c;
                } else {
                    sObjectName = (String)socsList[0].get('Parent_Sobject__c');
                    fieldSetName = sharingSetting.Parent_Sharing_FieldSet_Name__c; 
                }
            }
        } else if (territoryList.size() > 0) {
            Set<String> sobjectNameSet = new Set<String>();
            for (Sobject sobj : territoryList) {
                if (sobj.get('isActive__c') == true) {
                    sobjectNameSet.add((String)sobj.get('Parent_Sobject_Name__c'));
                    if (objectNameToAccountCountryMap.containsKey((String)sobj.get('Parent_Sobject_Name__c'))) {
                        objectNameToAccountCountryMap.get((String)sobj.get('Parent_Sobject_Name__c')).add((String)sobj.get('Account_Country__c'));
                        objectNameToRecordTypeMap.get((String)sobj.get('Parent_Sobject_Name__c')).add((String)sobj.get('Record_Type__c'));
                        objectNameToBusinessUnitMap.get((String)sobj.get('Parent_Sobject_Name__c')).add((String)sobj.get('Business_Unit__c'));
                        objectNameToParentCustomerCodeMap.get((String)sobj.get('Parent_Sobject_Name__c')).add((String)sobj.get('Parent_Customer_Code__c'));
                    } else {
                        objectNameToAccountCountryMap.put((String)sobj.get('Parent_Sobject_Name__c'),new Set<String>{(String)sobj.get('Account_Country__c')});
                        objectNameToRecordTypeMap.put((String)sobj.get('Parent_Sobject_Name__c'), new Set<String>{(String)sobj.get('Record_Type__c')});
                        objectNameToBusinessUnitMap.put((String)sobj.get('Parent_Sobject_Name__c'), new Set<String>{(String)sobj.get('Business_Unit__c')});
                        objectNameToParentCustomerCodeMap.put((String)sobj.get('Parent_Sobject_Name__c'), new Set<String>{(String)sobj.get('Parent_Customer_Code__c')});    
                    }
                }
            }
            socsList = [select Id, Child_Sobject__c, Maintenance_Job_Status__c, Parent_Sobject__c, Lookup_Name__c, Child_Sobject_Share__c, Parent_Sobject_Share__c, Enable_Sharing_Calculation__c, Account_Country_Api_Name__c, Record_Type_Api_Name__c, Business_Unit_Api_Name__c, Parent_Customer_Code_Api_Name__c, Sharing_Type__c, Type__c, Sharing_Territory_Label__c, Sharing_Team_Label__c, Sharing_Owner_Label__c, Team_Sharing_Lookup_Field__c,Parent_Sharing_Team_Label__c, Parent_Sharing_Territory_Label__c from SObject_Sharing__c WHERE Enable_Sharing_Calculation__c = true and Parent_Sobject__c In :sobjectNameSet and Sharing_Type__c = 'Derived' and Sharing_Territory_Label__c != null and Type__c = 'Parent'];
            if (socsList.size() > 0) {
                fieldSetName = sharingSetting.Parent_Sharing_FieldSet_Name__c;
                sObjectName = (String)socsList[0].get('Parent_Sobject__c');
                socsList[0].put('Maintenance_Job_Status__c', 'In Processing');
                update socsList[0];
            } else {
                System.abortJob(context.getJobId()); 
            }
        }
        List<Schema.FieldSetMember> sharingFieldSetMemberList;
        sharingFieldSetMemberList = UTL_Sharing.getFieldSetValues(sObjectName, fieldSetName);
        for(Schema.FieldSetMember sf : sharingFieldSetMemberList) {
            fields += sf.getFieldPath() + ',';
        }
        fields = fields.removeEnd(','); 
        String query = 'SELECT Id,' + fields + ' FROM ' + sObjectName;    
        if (objectNameToAccountCountryMap.size() > 0) {
            if (socsList[0].get('Account_Country_Api_Name__c') != null && objectNameToAccountCountryMap.containsKey(sObjectName)) {
                Set<String> accountCountryNameSet = objectNameToAccountCountryMap.get(sObjectName);
                query += ' WHERE ' + socsList[0].get('Account_Country_Api_Name__c') + ' In :accountCountryNameSet';
            }
            if (socsList[0].get('Record_Type_Api_Name__c') != null && objectNameToRecordTypeMap.containsKey(sObjectName)) {
                Set<String> recordTypeSet = objectNameToRecordTypeMap.get(sObjectName);
                query += ' OR ' + socsList[0].get('Record_Type_Api_Name__c') + ' In :recordTypeSet';
            }
            if (socsList[0].get('Business_Unit_Api_Name__c') != null && objectNameToBusinessUnitMap.containsKey(sObjectName)) {
                Set<String> businessUnitSet = objectNameToBusinessUnitMap.get(sObjectName);
                query += ' OR ' + socsList[0].get('Business_Unit_Api_Name__c') + ' In :businessUnitSet';
            }
            if (socsList[0].get('Parent_Customer_Code_Api_Name__c') != null && objectNameToParentCustomerCodeMap.containsKey(sObjectName)) {
                Set<String> parentCustomerCodeSet = objectNameToBusinessUnitMap.get(sObjectName);
                query += ' OR ' + socsList[0].get('Parent_Customer_Code_Api_Name__c') + ' In :parentCustomerCodeSet';
            }      
        }
        if (Test.isRunningTest()) {
            query += ' LIMIT 1';
        }
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext context, List<Sobject> recordList) {
        UTL_Sharing.isFuture = false;
        UTL_Sharing.isMaintenanceBatch = true;
        if (socsList[0].get('Child_Sobject__c') != null) {
            UTL_Sharing.setSharingRuleForChild(recordList, null, sObjectName);
        } else { 
            system.debug(recordList);
            UTL_Sharing.setSharing(recordList, null, sObjectName);
        }           
    }
    
    public void finish(Database.BatchableContext bc){
        socsList[0].put('Maintenance_Job_Status__c', 'Completed');
        update socsList[0];
        socsList.remove(0);
        if (socsList.size() > 0) {
            if (objectNameToAccountCountryMap.size() == 0) {
                BCH_GBL_Sharing_Maintenance_Job bch = new BCH_GBL_Sharing_Maintenance_Job(socsList);
                DataBase.executeBatch(bch);    
            } else {
                BCH_GBL_Sharing_Maintenance_Job bch = new BCH_GBL_Sharing_Maintenance_Job(socsList, objectNameToAccountCountryMap, objectNameToRecordTypeMap, objectNameToBusinessUnitMap, objectNameToParentCustomerCodeMap);
                DataBase.executeBatch(bch);   
            } 
        }
    } 
}