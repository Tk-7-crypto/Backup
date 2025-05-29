public without sharing class UTL_Sharing {
    private static final String PARENT_ID = 'ParentId';
    private static final String USER_OR_GROUP_ID = 'UserOrGroupId';
    private static final String ACCESS_LEVEL = 'AccessLevel';
    private static final String ROW_CAUSE = 'RowCause';
    private static final String EDIT = 'Edit';
    private static final String ALL = 'All';
    private static final String RECORD_ID = 'Id';
    private static final String PARENT = 'Parent';
    private static final String CHILD = 'Child';
    private static final String COMPLETED = 'Completed';
    private static final String OWNER = 'Owner';
    private static final String DERIVED = 'Derived';
    private static Map<String, Schema.SObjectType> globalDescribeMap = Schema.getGlobalDescribe(); 
    private static Map<String, List<Schema.FieldSetMember>> objectToFieldSetMemberListMap = new Map<String, List<Schema.FieldSetMember>>();
    @testVisible private static List<SObject> shareObjectDeleteList = new List<SObject>();
    @testVisible private static List<SObject> shareObjectInsertList = new List<SObject>();
    private static Map<Id,Id> childToParentIdMap = new Map<Id,Id>();
    //isFuture will set false by batch
    public static Boolean isFuture = true;
    //isMaintenanceBatch will set true by Maintenance Batch
    public static Boolean isMaintenanceBatch = false;
    private static List<SObject_Sharing__c> socsList = new List<SObject_Sharing__c>();
    private static Map<SObject,Id> parentShareObjToIdMap = new Map<SObject,Id>();
    private static Boolean isChildSharing = false;   
    private static Boolean isFromParentTrigger = false;
    private static SObject_Sharing_Settings__c sharingSetting = SObject_Sharing_Settings__c.getInstance();
    private static Set<Id> idSet = new Set<Id>();
    Private static Boolean isParentObjectOpportunity = false;
    
    //Retrieving Field Set Fields for SObject
    public static List<Schema.FieldSetMember> getFieldSetValues(String objectApiName, String fieldSetName) {
        List<Schema.FieldSetMember> sharingFieldSetMemberList;
        Schema.SObjectType SObjectTypeObj = globalDescribeMap.get(objectApiName);
        Schema.DescribeSObjectResult describeSObjectResultObj = SObjectTypeObj.getDescribe();
        //system.debug(describeSObjectResultObj.FieldSets.getMap());
        Schema.FieldSet fieldSetObj = describeSObjectResultObj.FieldSets.getMap().get(fieldSetName);
        //system.debug(objectApiName + ' <--> '+fieldSetObj);
        sharingFieldSetMemberList =  fieldSetObj.getFields();  
        //system.debug('sharingFieldSetMemberList '+ sharingFieldSetMemberList);
        objectToFieldSetMemberListMap.put(objectApiName,sharingFieldSetMemberList);
        return sharingFieldSetMemberList;
    }
    
    // Checking fieldSet changes for parent
    public static Set<Id> checkFieldSetValueChange(List<SObject> newRecordList, Map<Id, SObject> oldRecordsMap, String objectApiName,String fieldSetName) {
        List<Schema.FieldSetMember> sharingFieldSetMemberList;
        Set<Id> recordIdSet = new Set<Id>();
        String fieldAPI = '';
        if(!objectToFieldSetMemberListMap.containsKey(objectApiName)) {
            sharingFieldSetMemberList = getFieldSetValues(objectApiName, fieldSetName);
        } else {
            sharingFieldSetMemberList = objectToFieldSetMemberListMap.get(objectApiName);
        }
        for(SObject obj : newRecordList) { 
            for(Schema.FieldSetMember sf : sharingFieldSetMemberList) {
                fieldAPI = sf.getFieldPath();
                if (obj.get(fieldAPI) != oldRecordsMap.get(obj.Id).get(fieldAPI)) {
                    recordIdSet.add(obj.Id);
                    break;
                }
            }   
        }
        return recordIdSet;
    }
    
    // Check Maintenance job is running or need to start
    @TestVisible private static Boolean checkSharingValidation() {
        //Fetching records from sobject sharing master table
        socsList = [select Id, Child_Sobject__c, Maintenance_Job_Status__c, Parent_Sobject__c, Lookup_Name__c, Child_Sobject_Share__c, Parent_Sobject_Share__c, Enable_Sharing_Calculation__c, Account_Country_Api_Name__c, Record_Type_Api_Name__c, Business_Unit_Api_Name__c, Parent_Customer_Code_Api_Name__c, Sharing_Type__c, Type__c, Sharing_Territory_Label__c, Sharing_Team_Label__c, Sharing_Owner_Label__c, Team_Sharing_Lookup_Field__c,Parent_Sharing_Team_Label__c, Parent_Sharing_Territory_Label__c from SObject_Sharing__c where Enable_Sharing_Calculation__c = true ORDER BY Type__c DESC];
        //system.debug(socsList);
        if (!isFuture && !isMaintenanceBatch) {
            String batchName = sharingSetting.Sharing_Maintenance_Job_Batch_Name__c;
            List<ApexClass> apexClassList = [SELECT Id FROM ApexClass where Name = :batchName];
            Set<String> statusSet = new Set<String>{'Aborted','Completed','Failed'};
            List<AsyncApexJob> batchJobsList = [SELECT ApexClassId FROM AsyncApexJob WHERE JobType = 'BatchApex' AND Status NOT IN :statusSet and ApexClassId = :apexClassList[0].Id];      
            if (batchJobsList.size() > 0) {
                return false;
            }    
        }
        if (!isMaintenanceBatch) {
            for (SObject_Sharing__c obj : socsList) {
                //system.debug(obj.Type__c);
                if (obj.Maintenance_Job_Status__c != COMPLETED) {
                    return false;
                }
            }    
        }
        return true;
    }
    
    //Checking whether sharing to done to parent or to both parent and child
    @TestVisible private static Boolean checkSharing(String objectApiName) {
        Boolean isParentSharing = false;
        List<SObject_Sharing__c> sObjectSharingList = new List<SObject_Sharing__c>();
        //system.debug(socsList);
        for (SObject_Sharing__c socs : socsList) {
            if (socs.Parent_Sobject__c == objectApiName && socs.Sharing_Type__c == DERIVED && (socs.Sharing_Territory_Label__c != null || socs.Sharing_Team_Label__c != null) && socs.Parent_Sobject_Share__c != null) {
                sObjectSharingList.add(socs);
                //system.debug(socs.Type__c);
            }
        }
        //system.debug(sObjectSharingList);
        socsList = sObjectSharingList;
        //system.debug(socsList);
        if (socsList.size() > 0) {
            if (socsList[0].Type__c == PARENT) {
                isParentSharing = true;    
            }
        }
        //system.debug(isParentSharing);
        return isParentSharing;
    }
    
    @TestVisible private static void setChildSharingRecords(Set<Id> parentIdSet) {
        List<SObject_Sharing__c> socsSharingList = new List<SObject_Sharing__c>();
        for(SObject_Sharing__c socs : socsList) { 
            if(socs.Type__c != PARENT) {
                socsSharingList.add(socs);
            }   
        }
        if(socsSharingList.size() > 0) {
            socsList = socsSharingList;
            setSharingForChildRecords(parentIdSet, null);
        }
    }
    
    public static void setSharingRuleForChild(List<SObject> newRecordsList, Map<Id, SObject> oldRecordsMap, String objectApiName) {
        Boolean isInsert = true;
        if (oldRecordsMap != null) {
            isInsert = false;
        }
        if(isFuture) { 
            List<Schema.FieldSetMember> sharingFieldSetMemberList;
            List<SObject> updatedRecordList = new List<SObject>();
            String fieldAPI = '';
            if(!objectToFieldSetMemberListMap.containsKey(objectApiName)) {
                if (sharingSetting.Child_Sharing_FieldSet_Name__c != null) {
                    sharingFieldSetMemberList = getFieldSetValues(objectApiName, sharingSetting.Child_Sharing_FieldSet_Name__c);    
                }
            } else {
                sharingFieldSetMemberList = objectToFieldSetMemberListMap.get(objectApiName);
            }
            for(SObject obj : newRecordsList) { 
                for(Schema.FieldSetMember sf : sharingFieldSetMemberList) {
                    fieldAPI = sf.getFieldPath();
                    if((oldRecordsMap == null && obj.get(fieldAPI) != null) || (oldRecordsMap != null && (obj.get(fieldAPI) != oldRecordsMap.get((Id)obj.get(RECORD_ID)).get(fieldAPI)))) {
                        updatedRecordList.add(obj);
                        break;
                    }
                }   
            }
            if (updatedRecordList.size() > 0) {
                String newRecords = JSON.serialize(updatedRecordList);
                if(!UTL_Validate.isFutureCallAllowed()){
                    setSharingRuleForChildDecide(newRecords, objectApiName, isInsert);
                }else{
                    setSharingRuleForChildFuture(newRecords, objectApiName, isInsert);    
                }
                setSharingRuleForChildFuture(newRecords, objectApiName, isInsert);    
            }
        } else {
            String newRecords = JSON.serialize(newRecordsList);
            setChildSharing(newRecords, objectApiName, false); 
        }  
    }
    
    public static void setSharingRuleForChildDecide(String newRecords, String childObjectName, Boolean isInsert){
        setChildSharing(newRecords, childObjectName, isInsert);
    }
    @future
    @TestVisible
    private static void setSharingRuleForChildFuture(String newRecords, String childObjectName, Boolean isInsert) {
        //system.debug(newRecords);
        setChildSharing(newRecords, childObjectName, isInsert);
    }
    
    // Child Sharing
    // newRecords - List<SObject> in Json String form
    // childObjectName - SObject API Name
    @TestVisible private static void setChildSharing(String newRecords, String childObjectName, Boolean isInsert) {
        List<Sobject> childInsertObjectList = new List<Sobject>();
        List<Sobject> childDeleteObjectList = new List<Sobject>();
        Set<Id> parentIdSet = new Set<Id>();
        Set<Id> childIdSet = new Set<Id>();
        Map<String, String> parentNameToShareNameMap = new Map<String,String>();
        Map<String,Set<String>> parentNameToRowCauseMap = new Map<String,Set<String>>();
        Set<String> childRowCauseSet = new Set<String>();
        Set<String> parentRowCauseSet = new Set<String>();
        Map<Id,Set<String>> childIdToParentIdAndRowCauseMap = new Map<Id,Set<String>>();
        List<Sobject> parentSharingList = new List<Sobject>();
        Map<String, List<SObject>> parentIdAndRowCauseToShareMap = new Map<String, List<SObject>>();
        Map<String,String> parentRowCauseToChildRowCauseMap = new Map<String,String>();
        String childObjectShareName = '';
        Set<String> parentManualSet = new Set<String>();
        List<SObject_Sharing__c> socsChildList = new List<SObject_Sharing__c>();
        List<SObject> childObjectList = (List<SObject>)JSON.deserialize(newRecords, List<SObject>.class);
        if (!checkSharingValidation()) {
            //future call for trigger in insertion of fail record
            List<Fail_Sharing_Log__c> failSharingList = new List<Fail_Sharing_Log__c>();
            List<SObject_Sharing__c> socsSharingList = new List<SObject_Sharing__c>();
            for (SObject_Sharing__c socs : socsList) {
                if(socs.Child_Sobject__c != null && socs.Child_Sobject__c == childObjectName && socs.Parent_Sobject__c != null && socs.Lookup_Name__c != null && socs.Sharing_Type__c == 'Derived' && (socs.Sharing_Territory_Label__c != null || socs.Sharing_Team_Label__c != null || socs.Sharing_Owner_Label__c != null) && socs.Type__c == CHILD) {
                    socsSharingList.add(socs);
                }
            }
            for (SObject_Sharing__c socs :socsSharingList) {
                for (SObject obj : childObjectList) {
                    failSharingList.add(createFailRecord((Id)obj.get(RECORD_ID),(Id)obj.get(socs.Lookup_Name__c)));
                }    
            }
            insert failSharingList;
            return;
        }
        List<SObject_Sharing__c> socsSharingList = new List<SObject_Sharing__c>();
        for (SObject_Sharing__c socs : socsList) {
            if(socs.Parent_Sobject__c != null && socs.Parent_Sobject_Share__c != null && socs.Child_Sobject__c != null && socs.Child_Sobject_Share__c != null && socs.Sharing_Type__c == 'Derived' && (socs.Sharing_Territory_Label__c != null || socs.Sharing_Team_Label__c != null || socs.Sharing_Owner_Label__c != null) && socs.Type__c == CHILD && socs.Child_Sobject__c == childObjectName) {
                if (socs.Parent_Sharing_Team_Label__c == null && socs.Parent_Sharing_Territory_Label__c == null) {
                    parentManualSet.add(socs.Parent_Sobject__c);
                }
                socsSharingList.add(socs);
            }
        }
        //system.debug(socsList);
        if (socsSharingList.size() > 0) {
            // if child object is shared with multiple parents
            for (SObject_Sharing__c socs : socsSharingList) {
                childObjectShareName = socs.Child_Sobject_Share__c;
                if (!parentManualSet.contains(socs.Parent_Sobject__c)) {
                    // updated record list
                    //system.debug(childObjectShareName);
                    for(SObject childObject : childObjectList) {  
                        //system.debug(childObject);
                        // setup childIdToParentIdAndRowCauseMap
                        if(!childIdToParentIdAndRowCauseMap.containsKey((Id)childObject.get(RECORD_ID))) {
                            childIdToParentIdAndRowCauseMap.put((Id)childObject.get(RECORD_ID), new Set<String>());
                        }
                        if(socs.Sharing_Territory_Label__c != null) {
                            String parentRowCause = (Id)childObject.get(socs.Lookup_Name__c) + '::' + socs.Parent_Sharing_Territory_Label__c;
                            //system.debug(parentRowCause);
                            childIdToParentIdAndRowCauseMap.get((Id)childObject.get(RECORD_ID)).add(parentRowCause);
                            parentRowCauseSet.add(socs.Parent_Sharing_Territory_Label__c);
                            childRowCauseSet.add(socs.Sharing_Territory_Label__c);
                            parentRowCauseToChildRowCauseMap.put(socs.Parent_Sharing_Territory_Label__c, socs.Sharing_Territory_Label__c);
                        }
                        if(socs.Sharing_Team_Label__c != null) { 
                            socsChildList.add(socs);
                        }
                        if(socs.Sharing_Owner_Label__c != null) {
                            String parentRowCause = (Id)childObject.get(socs.Lookup_Name__c)  + '::' + OWNER;
                            childIdToParentIdAndRowCauseMap.get((Id)childObject.get(RECORD_ID)).add(parentRowCause);
                            parentRowCauseSet.add(OWNER);
                            childRowCauseSet.add(socs.Sharing_Owner_Label__c);
                            parentRowCauseToChildRowCauseMap.put(OWNER, socs.Sharing_Owner_Label__c);
                        }
                        if (!parentNameToShareNameMap.containsKey(socs.Parent_Sobject__c)) {
                            parentNameToShareNameMap.put(socs.Parent_Sobject__c, socs.Parent_Sobject_Share__c);
                        }
                        childIdSet.add((Id)childObject.get(RECORD_ID));
                        parentIdSet.add((Id)childObject.get(socs.Lookup_Name__c));
                    } 
                } else {
                    //Have to remove from for loop
                    //system.debug('Child Insertion');
                    Set<Id> parentRecordIdSet = new Set<Id>();
                    Set<Id> childRecordIdSet = new Set<Id>();
                    for(SObject childObject : childObjectList) {  
                        parentRecordIdSet.add((Id)childObject.get(socs.Lookup_Name__c));
                        childRecordIdSet.add((Id)childObject.get(RECORD_ID));
                    }
                    if (parentRecordIdSet.size() > 0) {
                        socsList = new List<SObject_Sharing__c>();
                        socsList.add(socs);
                        setSharingForChildRecords(parentRecordIdSet, childRecordIdSet);    
                    }
                }
            }
            //system.debug(childIdSet);
            //system.debug(parentIdSet);
            //system.debug(childIdToParentIdAndRowCauseMap);
            //system.debug(parentNameToShareNameMap);
            //system.debug(parentRowCauseSet);
            //system.debug(childRowCauseSet);
            List<SObject> childObjectShareList;
            if(!isInsert) {
                String query = 'Select Id, ParentId, UserOrGroupId, AccessLevel, RowCause from ' + childObjectShareName + ' where parentid in : childIdSet and RowCause In :childRowCauseSet';
                childObjectShareList = DataBase.query(query);
                if (childObjectShareList.size() > 0) {
                    shareObjectDeleteList.addAll(childObjectShareList);    
                }
            }
            if (parentNameToShareNameMap.size() > 0) {
                for (String parentShareName : parentNameToShareNameMap.values()) {
                    String query = 'Select Id, ParentId, UserOrGroupId, AccessLevel, RowCause from ' + parentShareName + ' where ParentId In :parentIdSet and RowCause In :parentRowCauseSet';   
                    List<SObject> parentSharing  = DataBase.query(query);
                    parentSharingList.addAll(parentSharing);
                }
                //system.debug(parentSharingList);
                // setup parentIdAndRowCauseToShareMap
                for (SObject parentObj : parentSharingList) {
                    String key = (Id)parentObj.get(PARENT_ID) + (String)parentObj.get(ROW_CAUSE);
                    if(parentIdAndRowCauseToShareMap.containsKey(key)) { 
                        parentIdAndRowCauseToShareMap.get(key).add(parentObj);
                    } else {
                        List<SObject> parentShareList = new List<SObject>();
                        parentShareList.add(parentObj);
                        parentIdAndRowCauseToShareMap.put(key,parentShareList);
                    }
                }
                //system.debug(parentIdAndRowCauseToShareMap);
                // setup childInsertObjectList & childDeleteObjectList
                for(Sobject childObj : childObjectList) {
                    if (childIdToParentIdAndRowCauseMap.containsKey((Id)childObj.get(RECORD_ID))) {
                        //system.debug(childIdToParentIdAndRowCauseMap.containsKey((Id)childObj.get(RECORD_ID)));
                        for(String parentRowCause  : childIdToParentIdAndRowCauseMap.get((Id)childObj.get(RECORD_ID))) {
                            List<String> parentRowCauseList = parentRowCause.split('::');
                            //system.debug(parentRowCauseList);
                            if(parentIdAndRowCauseToShareMap.containsKey(parentRowCauseList[0] + parentRowCauseList[1])) {
                                for(Sobject shareObj :parentIdAndRowCauseToShareMap.get(parentRowCauseList[0] + parentRowCauseList[1])) {
                                    Id recordId = (Id)childObj.get(RECORD_ID);
                                    Id userOrGroupId = (Id)shareObj.get(USER_OR_GROUP_ID);
                                    String rowCause = parentRowCauseToChildRowCauseMap.get((String)shareObj.get(ROW_CAUSE));
                                    String accessLevel;
                                    if(shareObj.get(ROW_CAUSE) == OWNER) {
                                        accessLevel = EDIT; 
                                    } else {
                                        accessLevel = (String)shareObj.get(ACCESS_LEVEL);   
                                    }
                                    Boolean isShareObjInsert = true;
                                    if (shareObj.get(ROW_CAUSE) == OWNER) {
                                        List<GroupMember> groupMemberList = checkUser(userOrGroupId);
                                        if (groupMemberList != null) { 
                                            isShareObjInsert = false;
                                            if (groupMemberList.size() > 0 ) {
                                                for (GroupMember grpMember :groupMemberList) {
                                                    userOrGroupId = grpMember.UserOrGroupId;
                                                    Sobject shareObject = shareRecordCreation(childObjectShareName, recordId, userOrGroupId, accessLevel, rowCause);
                                                    shareObjectInsertList.add(shareObject);
                                                    parentShareObjToIdMap.put(shareObject,(Id)shareObj.get(PARENT_ID));
                                                }
                                            }   
                                        }                       
                                    }
                                    if (isShareObjInsert) {
                                        Sobject shareObject = shareRecordCreation(childObjectShareName, recordId, userOrGroupId, accessLevel, rowCause);
                                        shareObjectInsertList.add(shareObject);
                                        parentShareObjToIdMap.put(shareObject,(Id)shareObj.get(PARENT_ID));
                                    }
                                    //system.debug(shareObjectInsertList);
                                } 
                            }
                        }    
                    }
                }
                if (socsChildList.size() > 0) {
                    setChildTeamSharing(childObjectList, childObjectName, socsChildList);
                }
                //system.debug(shareObjectInsertList);
                //system.debug(shareObjectInsertList.size());
                //system.debug(childDeleteObjectList.size());
                //system.debug(childDeleteObjectList);
            }    
        }
        if (shareObjectDeleteList.size() > 0 || shareObjectInsertList.size() > 0) {
            isChildSharing = true;
            insertAndDeleteRecords();    
        }    
    }
    
    // Parent Record sharing 
    // newRecords - List<SObject>
    // existingRecords - Map<Id, SObject>
    // objectApiName - SObject API Name
    public static void setSharing(List<SObject> newRecordsList, Map<Id, SObject> oldRecordsMap, String objectApiName) {
        // Normal Scenarios
        //system.debug('*********Sharing Initial');
        Boolean toExecute = true;
        Boolean isInsert = true;
        Boolean isExecuted = true;
        Set<Id> recordIdSet = new Set<Id>();
        if (newRecordsList.size() == idSet.size()) {
            for (SObject obj : newRecordsList) {
                if(!idSet.contains((Id)obj.get(RECORD_ID))) {
                    isExecuted = false;
                    break;
                }
            }
        } else {
            isExecuted = false;
        }
        if (!isExecuted) {
            idSet = new Set<Id>();
            for (SObject obj : newRecordsList) {
                idSet.add((Id)obj.get(RECORD_ID));
            }
            if(isFuture) {
                //system.debug('***********In future');
                //system.debug('Old map ' + oldRecordsMap );
                if (oldRecordsMap != null) {
                    isInsert = false;
                    if (sharingSetting.Parent_Sharing_FieldSet_Name__c != null) {
                        recordIdSet = checkFieldSetValueChange(newRecordsList, oldRecordsMap, objectApiName, sharingSetting.Parent_Sharing_FieldSet_Name__c);    
                    }
                    if (recordIdSet.size() > 0) {
                        List<SObject> recordList = new List<SObject>();
                        for (SObject obj : newRecordsList) {
                            if (recordIdSet.contains((Id)obj.get(RECORD_ID))) {
                                recordList.add(obj);
                            }
                        }
                        if (recordList.size() > 0) { 
                            newRecordsList = recordList;
                        } else {
                            toExecute = false;
                        }
                    } else {
                        toExecute = false;
                    } 
                }
                if (toExecute) {
                    //system.debug(objectApiName + '-> ' +sharingSetting.Parent_Sharing_FieldSet_Name__c);
                    if (sharingSetting.Parent_Sharing_FieldSet_Name__c != null) { 
                        String newRecords = JSON.serialize(newRecordsList);
                        if(!UTL_Validate.isFutureCallAllowed()){
                            setParentSharingOrder(newRecords, objectApiName, sharingSetting.Parent_Sharing_FieldSet_Name__c, isInsert);
                        }else{
                            setParentSharingFuture(newRecords, objectApiName, sharingSetting.Parent_Sharing_FieldSet_Name__c, isInsert);    
                        }
                    }      
                }   
            }      
            else {
                // When running from Batch
                //system.debug('In Batch');
                if (sharingSetting.Parent_Sharing_FieldSet_Name__c != null) { 
                    String newRecords = JSON.serialize(newRecordsList);
                    setParentSharing(newRecords, objectApiName, sharingSetting.Parent_Sharing_FieldSet_Name__c, false);
                }    
            }
        }
    }
    
    @TestVisible private static void setParentSharingOrder(String newRecords, String objectApiName, String fieldSetName, Boolean isInsert) {
        setParentSharing(newRecords, objectApiName, fieldSetName, isInsert);
    }
    @future
    @TestVisible private static void setParentSharingFuture(String newRecords, String objectApiName, String fieldSetName, Boolean isInsert) {
        setParentSharing(newRecords, objectApiName, fieldSetName, isInsert);
    }
    
    // Assumtion: we got only one parent but can have multiple child entries
    // newRecords - List<SObject> in Json String form
    // objectApiName - SObject API Name
    // fieldSetName - FieldSet API Name
    // isInsert - Boolean Insert Or Update Call
    @TestVisible private static void setParentSharing(String newRecords, String objectApiName, String fieldSetName, Boolean isInsert) {
        List<SObject> newRecordsList = (List<SObject>)JSON.deserialize(newRecords,List<SObject>.class);
        Set<Id> recordIdSet = new Set<Id>();
        if (!checkSharingValidation()) {
            //Could be add in future method also
            List<Fail_Sharing_Log__c> failSharingList = new List<Fail_Sharing_Log__c>();                
            for (SObject obj : newRecordsList) {
                failSharingList.add(createFailRecord((Id)obj.get(RECORD_ID),null));
            }
            //system.debug(failSharingList);
            insert failSharingList;
            return;
        } 
        //Fetching Share Object Records
        Boolean isParentSharing = checkSharing(objectApiName);
        //system.debug(socsList);
        if (socsList.size() > 0) {
            //system.debug(socsList[0].Type__c);
            // Share parent as well its childs
            if (isParentSharing) {
                if (socsList[0].Sharing_Territory_Label__c != null) {
                    setTerritorySharing(newRecordsList, isInsert);
                }
                // execute team sharing
                if (socsList[0].Sharing_Team_Label__c != null) {
                    Set<Id> recIdSet = new Set<Id>();
                    for (SObject obj :newRecordsList) {
                        recIdSet.add((Id)obj.get(RECORD_ID));
                    }
                    isFromParentTrigger = true;
                    setParentTeamSharing(recIdSet, objectApiName);
                }
            } 
            // share child records only, parent got sharing from salesforce native sharing methods
            else if (!isInsert) {
                for (SObject obj :newRecordsList) {
                    recordIdSet.add((Id)obj.get(RECORD_ID));
                }
                if (recordIdSet.size() > 0) {	
                    setChildSharingRecords(recordIdSet);
                }
            }
        }
        //system.debug(shareObjectInsertList);
        //system.debug(shareObjectDeleteList);
        if (shareObjectDeleteList.size() > 0 || shareObjectInsertList.size() > 0) {
            insertAndDeleteRecords();    
        }
    }
    
    
    @TestVisible private static void setTerritorySharing(List<SObject> newRecordsList, Boolean isInsert) {
        Set<Id> childIdSet = new Set<Id>();
        Boolean isRecordFound = true;
        Map<Id,List<Territory_Sharing__c>> recordIdToTerritoryMap = new Map<Id,List<Territory_Sharing__c>>();
        List<SObject> recordShareToInsertList = new List<SObject>();
        List<SObject> childObjectShareToInsertList = new List<SObject>();
        List<Territory_Sharing__c> territorySharingList = new List<Territory_Sharing__c>();
        Set<String> accountCountrySet = new Set<String>();
        Set<String> recordTypeSet = new Set<String>();
        Set<String> parentCustomerCodeSet = new Set<String>();
        Set<String> businessUnitSet = new Set<String>();
        Map<String,String> apiNameMap = new Map<String,String>();
        String parentShareObjectName='';
        String parentObjectName = '';
        Set<Id> recordIdSet = new Set<Id>();
        Set<String> rowCauseSet = new Set<String>();
        if(socsList[0].Account_Country_Api_Name__c != null) {
            apiNameMap.put('AccountCountry', socsList[0].Account_Country_Api_Name__c);
        }
        if(socsList[0].Record_Type_Api_Name__c != null) {
            apiNameMap.put('RecordType', socsList[0].Record_Type_Api_Name__c);
        }
        if(socsList[0].Parent_Customer_Code_Api_Name__c != null) {
            apiNameMap.put('ParentCustomerCode', socsList[0].Parent_Customer_Code_Api_Name__c);
        }
        if(socsList[0].Business_Unit_Api_Name__c != null) {
            apiNameMap.put('BusinessUnit', socsList[0].Business_Unit_Api_Name__c);
        }
        parentShareObjectName = socsList[0].Parent_Sobject_Share__c;
        parentObjectName = socsList[0].Parent_Sobject__c;
        String rowCauseParent = socsList[0].Sharing_Territory_Label__c;
        if(parentShareObjectName == 'OpportunityShare'){
            isParentObjectOpportunity = true;
        }
        accountCountrySet.add('ALL');
        recordTypeSet.add('ALL');
        parentCustomerCodeSet.add('ALL');
        businessUnitSet.add('ALL');
        for(SObject obj :newRecordsList) {
            if(apiNameMap.containsKey('AccountCountry') && obj.get(apiNameMap.get('AccountCountry')) != null) {
                accountCountrySet.add((String)obj.get(apiNameMap.get('AccountCountry')));
            }else{
                accountCountrySet.add('');
            }
            if(apiNameMap.containsKey('RecordType') && obj.get(apiNameMap.get('RecordType')) != null) {
                recordTypeSet.add((String)obj.get(apiNameMap.get('RecordType')));
            }
            if(apiNameMap.containsKey('ParentCustomerCode') && obj.get(apiNameMap.get('ParentCustomerCode')) != null) {
                parentCustomerCodeSet.add((String)obj.get(apiNameMap.get('ParentCustomerCode')));
            }
            if(apiNameMap.containsKey('BusinessUnit') && obj.get(apiNameMap.get('BusinessUnit')) != null) {
                businessUnitSet.add((String)obj.get(apiNameMap.get('BusinessUnit')));
            }
        }
        territorySharingList = [SELECT Access_Level__c, Account_Country__c, Business_Unit__c, Parent_Customer_Code__c, Group_Id__c, Priority__c, Record_Type__c FROM Territory_Sharing__c where isActive__c = true and Parent_Sobject_Name__c = :parentObjectName and Account_Country__c In :accountCountrySet and Record_Type__c In :recordTypeSet and Parent_Customer_Code__c In :parentCustomerCodeSet and Business_Unit__c In :businessUnitSet ORDER BY Priority__c];
        //system.debug(territorySharingList);
        for (SObject obj :newRecordsList) {
            for (Territory_Sharing__c ts : territorySharingList) {
                if(apiNameMap.containsKey('AccountCountry') && obj.get(apiNameMap.get('AccountCountry')) != ts.Account_Country__c && ts.Account_Country__c != 'ALL') {
                    isRecordFound = false;    
                } else if((apiNameMap.containsKey('RecordType') && obj.get(apiNameMap.get('RecordType')) != ts.Record_Type__c) && ts.Record_Type__c != 'ALL') {
                    isRecordFound = false;    
                } else if((apiNameMap.containsKey('ParentCustomerCode') && obj.get(apiNameMap.get('ParentCustomerCode')) != ts.Parent_Customer_Code__c) && ts.Parent_Customer_Code__c != 'ALL') {
                    isRecordFound = false;     
                } else if((apiNameMap.containsKey('BusinessUnit') && obj.get(apiNameMap.get('BusinessUnit')) != ts.Business_Unit__c) && ts.Business_Unit__c != 'ALL') {
                    isRecordFound = false;     
                }
                //system.debug(isRecordFound);
                if(isRecordFound) {
                    if(!recordIdToTerritoryMap.containsKey((Id)obj.get('Id'))) {
                        List<Territory_Sharing__c> territoryList = new List<Territory_Sharing__c>();
                        territoryList.add(ts);
                        recordIdToTerritoryMap.put((Id)obj.get('Id'),territoryList);
                    } else {
                        recordIdToTerritoryMap.get((Id)obj.get('Id')).add(ts);
                    }   
                }
                isRecordFound = true;
            }
            recordIdSet.add((Id)obj.get('Id'));
        }
        //system.debug(recordIdToTerritoryMap.size());
        //system.debug(recordIdToTerritoryMap.values());    
        List<SObject> parentRecordSharingList = new List<SObject>();
        if (!isInsert) {
            if(parentShareObjectName != null) {
                rowCauseSet.add(rowCauseParent);
                rowCauseSet.add(OWNER);
                String query = '';
                if(isParentObjectOpportunity){
                    query = 'Select Id, OpportunityId, UserOrGroupId, OpportunityAccessLevel, RowCause from ' + parentShareObjectName + ' where OpportunityId In :recordIdSet and RowCause In :rowCauseSet';
                }else{
                    query = 'Select Id, ParentId, UserOrGroupId, AccessLevel, RowCause from ' + parentShareObjectName + ' where ParentId In :recordIdSet and RowCause In :rowCauseSet';
                }
                //system.debug('Query---------------------------' + query);
                parentRecordSharingList = DataBase.query(query);
            }
            if (parentRecordSharingList.size() > 0) {
                shareObjectDeleteList.addAll(parentRecordSharingList);    
            }
            //system.debug(parentRecordSharingList);
            //system.debug(shareObjectDeleteList);
            for(SObject obj :parentRecordSharingList) {
                if (obj.get(ROW_CAUSE) == OWNER) {
                    recordShareToInsertList.add(obj);
                }
            }
        }
        for (Id recordId : recordIdToTerritoryMap.keySet()) {
            for(Territory_Sharing__c ts :recordIdToTerritoryMap.get(recordId)) {
                Id userOrGroupId = ts.Group_Id__c;
                String accessLevel = ts.Access_Level__c;
                //system.debug(parentShareObjectName);
                //system.debug(recordId);
                //system.debug(accessLevel);
                //system.debug(userOrGroupId);
                //system.debug(rowCauseParent);
                Sobject obj = shareRecordCreation(parentShareObjectName, recordId, userOrGroupId, accessLevel, rowCauseParent);
                recordShareToInsertList.add(obj);
            }            
        }
        //system.debug(recordShareToInsertList);
        if (!isInsert) {
            for(SObject_Sharing__c socs : socsList) {
                if (socs.Type__c == CHILD && (socs.Sharing_Territory_Label__c != null || socs.Sharing_Owner_Label__c != null)) {
                    if (socs.Child_Sobject__c != null && socs.Lookup_Name__c != null) {
                        String query = 'SELECT Id, ' + socs.Lookup_Name__c + ' FROM ' + socs.Child_Sobject__c + ' WHERE ' + socs.Lookup_Name__c + ' In :recordIdSet'; 
                        //system.debug(socs.Lookup_Name__c);
                        List<SObject> childObjectList = DataBase.query(query);
                        //system.debug(childObjectList);
                        for (Sobject childObj : childObjectList) {
                            //system.debug((Id)childObj.get(RECORD_ID));
                            childIdSet.add((Id)childObj.get(RECORD_ID));  
                            //system.debug(childIdSet);
                            childToParentIdMap.put((Id)childObj.get(RECORD_ID),(Id)childObj.get(socs.Lookup_Name__c));
                        }
                        //system.debug('childobjectList'+ childObjectList);
                        rowCauseSet = new Set<String>();
                        if (socs.Sharing_Territory_Label__c != null) {
                            rowCauseSet.add(socs.Sharing_Territory_Label__c);
                        }
                        if (socs.Sharing_Owner_Label__c != null) {
                            rowCauseSet.add(socs.Sharing_Owner_Label__c);
                        }
                        query = 'select Id, ParentId, UserOrGroupId, AccessLevel, RowCause from ' + socs.Child_Sobject_Share__c + ' where parentid in : childIdSet and RowCause In :rowCauseSet';
                        //system.debug('Query---------------------------' + query);
                        List<SObject> childObjectShareList = DataBase.query(query);
                        if (childObjectShareList.size() > 0) {
                            shareObjectDeleteList.addAll(childObjectShareList);    
                        }
                        for(Sobject childObj : childObjectList) {
                            for (Sobject obj : recordShareToInsertList) {
                                if(childObj.get(socs.Lookup_Name__c) == obj.get(PARENT_ID)) {
                                    Id userOrGroupId = (Id)obj.get(USER_OR_GROUP_ID);
                                    String accessLevel;
                                    String rowCause = null;
                                    if(obj.get(ROW_CAUSE) == OWNER) {
                                        if (socs.Sharing_Owner_Label__c != null) {
                                            rowCause = socs.Sharing_Owner_Label__c;
                                            accessLevel = EDIT;   
                                        }
                                    } else if (socs.Sharing_Territory_Label__c != null) {
                                        rowCause = socs.Sharing_Territory_Label__c;
                                        accessLevel = (String)obj.get(ACCESS_LEVEL);
                                    }
                                    String shareObjectName = socs.Child_Sobject_Share__c;
                                    Id childId = (Id)childObj.get(RECORD_ID);
                                    if (rowCause != null) {
                                        Boolean isShareObjInsert = true;
                                        if (obj.get(ROW_CAUSE) == OWNER) {
                                            List<GroupMember> groupMemberList = checkUser(userOrGroupId);
                                            if (groupMemberList != null) { 
                                                isShareObjInsert = false;
                                                if (groupMemberList.size() > 0 ) {
                                                    for (GroupMember grpMember :groupMemberList) {
                                                        userOrGroupId = grpMember.UserOrGroupId;
                                                        SObject shareObj = shareRecordCreation(shareObjectName, childId, userOrGroupId, accessLevel, rowCause);
                                                        childObjectShareToInsertList.add(shareObj);    
                                                    }
                                                }   
                                            }
                                        }
                                        if (isShareObjInsert) {
                                            SObject shareObj = shareRecordCreation(shareObjectName, childId, userOrGroupId, accessLevel, rowCause);
                                            childObjectShareToInsertList.add(shareObj);                                
                                        }
                                    }
                                }	
                            }
                        } 
                    }
                }    
            }
        }
        if(childObjectShareToInsertList.size() > 0) {
            shareObjectInsertList.addAll(childObjectShareToInsertList);    
        }
        if(recordShareToInsertList.size() > 0) {
            shareObjectInsertList.addAll(recordShareToInsertList);    
        }
    }
    
    public static void setTeamSharing(List<SObject> newRecordsList, Map<Id,SObject> oldRecordsMap, String parentObjectName, String lookUpName) {
        //system.debug('Team Sharing Insertion');
        Set<Id> recordIdSet = new Set<Id>();
        for (SObject obj : newRecordsList) {
            if (Trigger.isUpdate && (obj.get('User__c') != oldRecordsMap.get((Id)obj.get(RECORD_ID)).get('User__c') || obj.get('Team_Role__c') != oldRecordsMap.get((Id)obj.get(RECORD_ID)).get('Team_Role__c'))) {
                recordIdSet.add((Id)obj.get(lookUpName));    
            } else if (!Trigger.isUpdate){
                recordIdSet.add((Id)obj.get(lookUpName)); 
            }
        }
        if (recordIdSet.size() > 0) {
            setTeamSharingFuture(recordIdSet, parentObjectName);        
        }
    } 
    
    @future
    @TestVisible private static void setTeamSharingFuture(Set<Id> recordIdSet, String parentObjectName) {
        setParentTeamSharing(recordIdSet, parentObjectName);
    }   
    
    @TestVisible private static void setParentTeamSharing(Set<Id> recordIdSet, String parentObjectName) { 
        Set<Id> childIdSet = new Set<Id>();
        List<SObject> recordShareToInsertList = new List<SObject>();
        List<SObject> childObjectShareToInsertList = new List<SObject>();
        List<Team_Sharing__c> teamSharingList = new List<Team_Sharing__c>();
        Set<String> teamRoleSet = new Set<String>();
        String teamObjectName = '';
        Map<String,Id> teamRoleToUserIdMap = new Map<String,Id>();
        Map<String,String> objectNameAndRoleToAcessLevelMap = new Map<String,String>();
        Map<String,Set<Id>> teamRoleAndLookupToUserIdMap = new Map<String,Set<Id>>();
        Set<String> rowCauseSet = new Set<String>();
        String parentShareObjectName = '';
        String query = '';
        Boolean isParentSharing;
        if (!isFromParentTrigger && !checkSharingValidation()) {
            List<Fail_Sharing_Log__c> failSharingList = new List<Fail_Sharing_Log__c>();
            for (Id recordId : recordIdSet) {
                failSharingList.add(createFailRecord(recordId,null));
            }
            insert failSharingList;
            return;
        }
        if (isfuture && !isFromParentTrigger) {
            isParentSharing = checkSharing(parentObjectName);
            if (!isParentSharing) {
                //system.debug('Not Parent Sharing');
                setChildSharingRecords(recordIdSet);
                if (shareObjectDeleteList.size() > 0 || shareObjectInsertList.size() > 0) {
                    insertAndDeleteRecords();    
                }
            }
        }
        if (!isfuture || isFromParentTrigger || (socsList.size() > 0 && isParentSharing && socsList[0].Sharing_Team_Label__c != null)) {
            //system.debug('Enter for team sharing');
            String lookUpName = socsList[0].Team_Sharing_Lookup_Field__c;
            parentShareObjectName = socsList[0].Parent_Sobject_Share__c;
            parentObjectName = socsList[0].Parent_Sobject__c;
            String rowCauseParent = socsList[0].Sharing_Team_Label__c;
            teamSharingList = [SELECT Access_Level__c, Parent_Sobject_Name__c, Child_Sobject_Name__c, Team_Role_Name__c, Team_Object_Name__c FROM Team_Sharing__c where isActive__c = true and Parent_Sobject_Name__c = :parentObjectName];
            List<SObject> parentRecordSharingList = new List<SObject>();
            if (teamSharingList.size() > 0) {
                for(Team_Sharing__c ts :teamSharingList) {
                    teamObjectName = ts.Team_Object_Name__c;
                    teamRoleSet.add(ts.Team_Role_Name__c);
                    String key;
                    if(ts.Child_Sobject_Name__c != null) {
                        key = ts.Child_Sobject_Name__c + '::' + ts.Team_Role_Name__c;
                    } else {
                        key = ts.Parent_Sobject_Name__c + '::' + ts.Team_Role_Name__c;
                    }
                    objectNameAndRoleToAcessLevelMap.put(key, ts.Access_Level__c);
                }
                //system.debug(teamSharingList);
                //system.debug(objectNameAndRoleToAcessLevelMap);
                query = 'Select Id, User__c, Team_Role__c, ' + lookUpName  + ' From ' + teamObjectName + ' where Team_Role__c IN :teamRoleSet and ' + lookUpName + ' In :recordIdSet';
                List<Sobject> teamObjectList = DataBase.query(query);
                for (SObject obj : teamObjectList) {
                    String key = (String)obj.get('Team_Role__c') + '::' + (Id)obj.get(lookUpName);
                    if (teamRoleAndLookupToUserIdMap.containsKey(key)) {
                        teamRoleAndLookupToUserIdMap.get(key).add((Id)obj.get('User__c'));
                    } else {
                        Set<Id> userIdSet = new Set<Id>();
                        userIdSet.add((Id)obj.get('User__c'));
                        teamRoleAndLookupToUserIdMap.put(key,userIdSet);
                    }
                }
            }
            //system.debug(teamRoleAndLookupToUserIdMap);
            if(parentShareObjectName != null) {
                rowCauseSet.add(rowCauseParent);
                query = 'Select Id, ParentId, UserOrGroupId, AccessLevel, RowCause from ' + parentShareObjectName + ' where ParentId In :recordIdSet and RowCause IN :rowCauseSet';             
                //system.debug('Query---------------------------' + query);
                parentRecordSharingList = DataBase.query(query);
                if (parentRecordSharingList.size() > 0) {
                    shareObjectDeleteList.addAll(parentRecordSharingList);    
                }
                // insert socs Sobject Share Records
                for (Id recordId : recordIdSet) {
                    //system.debug(recordId);
                    for(String teamRole : teamRoleSet) {
                        //system.debug(teamRole);
                        if(teamRoleAndLookupToUserIdMap.containsKey(teamRole + '::' + recordId)) {
                            //system.debug(teamRoleAndLookupToUserIdMap.get(teamRole + '::' + recordId));
                            for(Id userId : teamRoleAndLookupToUserIdMap.get(teamRole + '::' + recordId)) {
                                //system.debug(parentObjectName);
                                if (objectNameAndRoleToAcessLevelMap.containsKey(parentObjectName + '::' + teamRole)) {
                                    //system.debug('insert for share record');
                                    String accessLevel = objectNameAndRoleToAcessLevelMap.get(parentObjectName + '::' + teamRole);
                                    //system.debug(parentShareObjectName);
                                    //system.debug(recordId);
                                    //system.debug(accessLevel);
                                    //system.debug(userId);
                                    //system.debug(rowCauseParent);
                                    Sobject obj = shareRecordCreation(parentShareObjectName, recordId, userId, accessLevel, rowCauseParent);
                                    recordShareToInsertList.add(obj);    
                                }
                            }
                        }
                    }            
                }
            }
            //system.debug(parentRecordSharingList);    
            Map<Id,Map<String,Set<Id>>> parentIdToChildNameToIdSetMap = new Map<Id,Map<String,Set<Id>>>();
            for(SObject_Sharing__c socs : socsList) {
                if (socs.Type__c == CHILD && socs.Sharing_Team_Label__c != null) {
                    if (socs.Child_Sobject__c != null && socs.Lookup_Name__c != null) {
                        query = 'SELECT Id, ' + socs.Lookup_Name__c + ' FROM ' + socs.Child_Sobject__c + ' WHERE ' + socs.Lookup_Name__c + ' In :recordIdSet'; 
                        //system.debug(socs.Lookup_Name__c);
                        List<SObject> childObjectList = DataBase.query(query);
                        //system.debug(childObjectList);
                        for (Sobject childObj : childObjectList) {
                            //system.debug((Id)childObj.get(RECORD_ID));
                            childIdSet.add((Id)childObj.get(RECORD_ID));  
                            //system.debug(childIdSet);
                            childToParentIdMap.put((Id)childObj.get(RECORD_ID),(Id)childObj.get(socs.Lookup_Name__c));
                        }
                        //system.debug('childobjectList'+ childObjectList);
                        rowCauseSet = new Set<String>();
                        rowCauseSet.add(socs.Sharing_Team_Label__c);
                        query = 'select Id, ParentId, UserOrGroupId, AccessLevel, RowCause from ' + socs.Child_Sobject_Share__c + ' where parentid in : childIdSet and RowCause IN :rowCauseSet';
                        //system.debug('Query---------------------------' + query);
                        List<SObject> childObjectShareList = DataBase.query(query);
                        if (childObjectShareList.size() > 0) {
                            shareObjectDeleteList.addAll(childObjectShareList);    
                        }
                        for (SObject childObject : childObjectList) {
                            String parentId = (Id)childObject.get(socs.Lookup_Name__c);
                            String recordId = (Id)childObject.get(RECORD_ID);
                            for(String teamRole : teamRoleSet) {
                                if(teamRoleAndLookupToUserIdMap.containsKey(teamRole + '::' + parentId)) {
                                    for(Id userId : teamRoleAndLookupToUserIdMap.get(teamRole + '::' + parentId)) {
                                        if (objectNameAndRoleToAcessLevelMap.containsKey(socs.Child_Sobject__c + '::' + teamRole)) {
                                            String accessLevel = objectNameAndRoleToAcessLevelMap.get(socs.Child_Sobject__c + '::' + teamRole);
                                            rowCauseParent = socs.Sharing_Team_Label__c;
                                            parentShareObjectName = socs.Child_Sobject_Share__c;
                                            //system.debug(parentShareObjectName);
                                            //system.debug(recordId);
                                            //system.debug(accessLevel);
                                            //system.debug(userId);
                                            //system.debug(rowCauseParent);
                                            Sobject obj = shareRecordCreation(parentShareObjectName, recordId, userId, accessLevel, rowCauseParent);
                                            recordShareToInsertList.add(obj);    
                                        }
                                    }
                                }
                            }       
                        }
                    }
                }   
            }
            //system.debug(recordShareToInsertList);
        }
        if (recordShareToInsertList.size() > 0) {
            shareObjectInsertList.addAll(recordShareToInsertList);    
        }
        if (isFuture && (shareObjectDeleteList.size() > 0 || shareObjectInsertList.size() > 0)) {
            insertAndDeleteRecords();    
        }
        //system.debug(shareObjectInsertList);
    }
    
    //Set Child Team Sharing
    @TestVisible private static void setChildTeamSharing(List<SObject> childRecordList, String childObjectName, List<SObject_Sharing__c> socsChildList) {
        Set<Id> childIdSet = new Set<Id>();         
        List<SObject> recordShareToInsertList = new List<SObject>();
        List<SObject> childObjectShareToInsertList = new List<SObject>();
        List<Team_Sharing__c> teamSharingList = new List<Team_Sharing__c>();
        Set<String> teamRoleSet = new Set<String>();
        String teamObjectName = '';
        Map<String,Id> teamRoleToUserIdMap = new Map<String,Id>();
        Map<String,String> objectNameAndRoleToAcessLevelMap = new Map<String,String>();
        List<SObject> teamObjectList = new List<SObject>();
        Map<String,Set<Id>> teamRoleAndLookupToUserIdMap = new Map<String,Set<Id>>();
        Set<String> rowCauseSet = new Set<String>();
        String parentShareObjectName = '';
        if (socsChildList.size() > 0) {
            parentShareObjectName = socsList[0].Parent_Sobject_Share__c;
            String rowCauseParent = socsList[0].Sharing_Team_Label__c;
            teamSharingList = [SELECT Access_Level__c, Parent_Sobject_Name__c, Child_Sobject_Name__c, Team_Role_Name__c, Team_Object_Name__c FROM Team_Sharing__c where isActive__c = true and Child_Sobject_Name__c = :childObjectName];
            List<SObject> parentRecordSharingList = new List<SObject>();
            if (teamSharingList.size() > 0) {
                Map<String,Set<Id>> parentNameToIdSetMap = new Map<String,Set<Id>>();
                Map<String,String> parentNameToTeamLookUpNameMap = new Map<String,String>();
                for (SObject_Sharing__c socs : socsChildList) {
                    Set<Id> parentIdSet = new Set<Id>();
                    for (Sobject obj :childRecordList) { 
                        parentIdSet.add((Id)obj.get(socs.LookUp_Name__c));
                    } 
                    parentNameToIdSetMap.put(socs.Parent_Sobject__c,parentIdSet);
                    parentNameToTeamLookUpNameMap.put(socs.Parent_Sobject__c,socs.Team_Sharing_Lookup_Field__c);
                }
                Set<String> parentNameToTeamTableNameSet = new Set<String>();
                for(Team_Sharing__c ts :teamSharingList) {
                    teamRoleSet.add(ts.Team_Role_Name__c);
                    String key = ts.Child_Sobject_Name__c + '::' + ts.Team_Role_Name__c;
                    objectNameAndRoleToAcessLevelMap.put(key, ts.Access_Level__c);
                    parentNameToTeamTableNameSet.add(ts.Parent_Sobject_Name__c + '::' + ts.Team_Object_Name__c);
                }
                for (String parentTeamTable :parentNameToTeamTableNameSet) {
                    List<String> parentTeamTableList = parentTeamTable.split('::');
                    Set<Id> parentIdSet = parentNameToIdSetMap.get(parentTeamTableList[0]);
                    String lookUpName = parentNameToTeamLookUpNameMap.get(parentTeamTableList[0]);
                    String query = 'Select Id, User__c, Team_Role__c, ' + lookUpName  + ' From ' + parentTeamTableList[1] + ' where Team_Role__c IN :teamRoleSet and ' + lookUpName + ' In :parentIdSet';
                    teamObjectList = DataBase.query(query);
                    for (SObject obj : teamObjectList) {
                        String key = (String)obj.get('Team_Role__c') + '::' + (Id)obj.get(lookUpName);
                        if (teamRoleAndLookupToUserIdMap.containsKey(key)) {
                            teamRoleAndLookupToUserIdMap.get(key).add((Id)obj.get('User__c'));
                        } else {
                            Set<Id> userIdSet = new Set<Id>();
                            userIdSet.add((Id)obj.get('User__c'));
                            teamRoleAndLookupToUserIdMap.put(key,userIdSet);
                        }
                    }
                }  
            }
            for(SObject_Sharing__c socs : socsChildList) {
                if (socs.Type__c == CHILD && socs.Sharing_Team_Label__c != null) {
                    if (socs.Child_Sobject__c != null && socs.Lookup_Name__c != null) {
                        for (Sobject childObj : childRecordList) {
                            //system.debug((Id)childObj.get(RECORD_ID));
                            childIdSet.add((Id)childObj.get(RECORD_ID));  
                            //system.debug(childIdSet);
                            childToParentIdMap.put((Id)childObj.get(RECORD_ID),(Id)childObj.get(socs.Lookup_Name__c));
                        }
                        //system.debug('childobjectList'+ childRecordList);
                        rowCauseSet = new Set<String>();
                        rowCauseSet.add(socs.Sharing_Team_Label__c);
                        String query = 'select Id, ParentId, UserOrGroupId, AccessLevel, RowCause from ' + socs.Child_Sobject_Share__c + ' where parentid in : childIdSet and RowCause IN :rowCauseSet';
                        //system.debug('Query---------------------------' + query);
                        List<SObject> childObjectShareList = DataBase.query(query);
                        if (childObjectShareList.size() > 0) {
                            shareObjectDeleteList.addAll(childObjectShareList);    
                        }
                        for (SObject childObject : childRecordList) {
                            String parentId = (Id) childObject.get(socs.Lookup_Name__c);
                            String recordId = (Id)childObject.get(RECORD_ID);
                            for(String teamRole : teamRoleSet) {
                                if(teamRoleAndLookupToUserIdMap.containsKey(teamRole + '::' + parentId)) {
                                    for(Id userId : teamRoleAndLookupToUserIdMap.get(teamRole + '::' + parentId)) {
                                        if (objectNameAndRoleToAcessLevelMap.containsKey(socs.Child_Sobject__c + '::' + teamRole)) {
                                            String accessLevel = objectNameAndRoleToAcessLevelMap.get(socs.Child_Sobject__c + '::' + teamRole);
                                            rowCauseParent = socs.Sharing_Team_Label__c;
                                            parentShareObjectName = socs.Child_Sobject_Share__c;
                                            //system.debug(parentShareObjectName);
                                            //system.debug(recordId);
                                            //system.debug(accessLevel);
                                            //system.debug(userId);
                                            //system.debug(rowCauseParent);
                                            Sobject obj = shareRecordCreation(parentShareObjectName, recordId, userId, accessLevel, rowCauseParent);
                                            //system.debug(obj);
                                            recordShareToInsertList.add(obj);    
                                        }
                                    }
                                }
                            }       
                        }
                    }
                }   
            }
            //system.debug(recordShareToInsertList);
        }
        if (recordShareToInsertList.size() > 0) {
            shareObjectInsertList.addAll(recordShareToInsertList);    
        }
        if (isFuture && (shareObjectDeleteList.size() > 0 || shareObjectInsertList.size() > 0)) {
            insertAndDeleteRecords();    
        }
        //system.debug(shareObjectInsertList);
    }
    
    // Creating share record
    private static SObject shareRecordCreation(String shareObjectName, Id recordId, Id userOrGroupId, String accessLevel, String rowCause) {
        Sobject recordObj = globalDescribeMap.get(shareObjectName).newSObject();
        if(isParentObjectOpportunity){
            recordObj.put('OpportunityId', recordId);
            recordObj.put('OpportunityAccessLevel', accessLevel);
        }else{
            recordObj.put(PARENT_ID, recordId);
            recordObj.put(ACCESS_LEVEL, accessLevel);
        }
        recordObj.put(USER_OR_GROUP_ID, userOrGroupId);
        recordObj.put(ROW_CAUSE, rowCause);
        //system.debug(recordObj);
        return recordObj;
    }
    
    // Creating Fail Record List
    @TestVisible private static void failRecordCreation(Exception exp, Boolean isDeleteFailure) {
        List<SObject> failSharingLogList = new List<Fail_Sharing_Log__c>();
        if (isDeleteFailure) {
            for(SObject obj :shareObjectDeleteList) {
                Fail_Sharing_Log__c failsharing = new Fail_Sharing_Log__c();
                if(isParentObjectOpportunity){
                    failsharing.Fail_Record_Id__c = (Id)obj.get('OpportunityId');
                }else{
                    failsharing.Fail_Record_Id__c = (Id)obj.get(PARENT_ID);
                }
                failsharing.Reason__c = exp.getMessage() + '\n' + exp.getStackTraceString();
                if(!isChildSharing) {
                    if (isParentObjectOpportunity && childToParentIdMap.containsKey((Id)obj.get('OpportunityId'))) {
                        failsharing.Parent_Record_Id__c = childToParentIdMap.get((Id)obj.get('OpportunityId'));
                    }else if(!isParentObjectOpportunity && childToParentIdMap.containsKey((Id)obj.get(PARENT_ID))) {
                        failsharing.Parent_Record_Id__c = childToParentIdMap.get((Id)obj.get(PARENT_ID));
                    }
                } else {
                    if (parentShareObjToIdMap.containsKey(obj)) {
                        failsharing.Parent_Record_Id__c = parentShareObjToIdMap.get(obj);    
                    }
                }
                failSharingLogList.add(failsharing);
            }
        }
        for(SObject obj :shareObjectInsertList) {
            Fail_Sharing_Log__c failsharing = new Fail_Sharing_Log__c();
            if(isParentObjectOpportunity){
                failsharing.Fail_Record_Id__c = (Id)obj.get('OpportunityId');
            }else{
                failsharing.Fail_Record_Id__c = (Id)obj.get(PARENT_ID);
            }
            if(isDeleteFailure) {
                failsharing.Reason__c = 'Insert : Failed due to delete records get Failed';    
            } else {
                failsharing.Reason__c = exp.getMessage() + '\n' + exp.getStackTraceString();    
            }
            if(!isChildSharing) {
                if (isParentObjectOpportunity && childToParentIdMap.containsKey((Id)obj.get('OpportunityId'))) {
                    failsharing.Parent_Record_Id__c = childToParentIdMap.get((Id)obj.get('OpportunityId'));
                }else if(!isParentObjectOpportunity && childToParentIdMap.containsKey((Id)obj.get(PARENT_ID))) {
                    failsharing.Parent_Record_Id__c = childToParentIdMap.get((Id)obj.get(PARENT_ID));
                }
            } else {
                if (parentShareObjToIdMap.containsKey(obj)) {
                    failsharing.Parent_Record_Id__c = parentShareObjToIdMap.get(obj);    
                }
            }
            failSharingLogList.add(failsharing);
        }
        if(failSharingLogList.size() > 0) {
            insert failSharingLogList;                
        }
    }
    
    @TestVisible private static Fail_Sharing_Log__c createFailRecord(Id recordId, Id parentId) {
        Fail_Sharing_Log__c failsharing = new Fail_Sharing_Log__c();
        if (parentId != null) {
            failsharing.Parent_Record_Id__c = parentId;
        }
        failsharing.Fail_Record_Id__c = recordId;
        failsharing.Reason__c = 'Batch is in progress';
        return failsharing;
    }
    
    @TestVisible private static void insertAndDeleteRecords(){
        Set<Sobject> recordInsertSet = new Set<Sobject>();
        Set<Sobject> recordDeleteSet = new Set<Sobject>();
        Set<Id> idSet = new Set<Id>();
        recordInsertSet.addAll(shareObjectInsertList);
        recordDeleteSet.addAll(shareObjectDeleteList);
        Map<String,SObject> shareInsertMap = new Map<String,Sobject>(); 
        for (Sobject insertObj : shareObjectInsertList) {
            if(isParentObjectOpportunity){
                String key = (String)insertObj.get('OpportunityId') + '::' + (String)insertObj.get(USER_OR_GROUP_ID) + '::' + (String)insertObj.get('OpportunityAccessLevel') + '::' + (String)insertObj.get(ROW_CAUSE);
                shareInsertMap.put(key,insertObj);
                idSet.add((Id)insertObj.get('OpportunityId'));
            }else{
                String key = (String)insertObj.get(PARENT_ID) + '::' + (String)insertObj.get(USER_OR_GROUP_ID) + '::' + (String)insertObj.get(ACCESS_LEVEL) + '::' + (String)insertObj.get(ROW_CAUSE);
                shareInsertMap.put(key,insertObj);
                idSet.add((Id)insertObj.get(PARENT_ID));
            }
        }
        for(Sobject deleteObj : shareObjectDeleteList) {
            String key ='';
            if(isParentObjectOpportunity){
                key = (String)deleteObj.get('OpportunityId') + '::' + (String)deleteObj.get(USER_OR_GROUP_ID) + '::' + (String)deleteObj.get('OpportunityAccessLevel') + '::' + (String)deleteObj.get(ROW_CAUSE);
            }else{
                key = (String)deleteObj.get(PARENT_ID) + '::' + (String)deleteObj.get(USER_OR_GROUP_ID) + '::' + (String)deleteObj.get(ACCESS_LEVEL) + '::' + (String)deleteObj.get(ROW_CAUSE);
            }
            if(shareInsertMap.containsKey(key)) {
                recordInsertSet.remove(shareInsertMap.get(key));
                recordDeleteSet.remove(deleteObj);
            }
        }
        //system.debug(recordInsertSet);
        //system.debug(recordDeleteSet);
        //system.debug(idSet);
        List<Fail_Sharing_Log__c> failShareList = [SELECT Id, Fail_Record_Id__c FROM Fail_Sharing_Log__c WHERE Fail_Record_Id__c In :idSet];
        //system.debug(failShareList);
        if(failShareList.size() > 0) {
            delete failShareList;
        }
        if (recordInsertSet.size() != shareObjectInsertList.size()) {
            shareObjectInsertList = new List<SObject>();
            shareObjectInsertList.addAll(recordInsertSet);
        }
        if (recordDeleteSet.size() != shareObjectDeleteList.size()) {
            shareObjectDeleteList = new List<SObject>();
            shareObjectDeleteList.addAll(recordDeleteSet);
        }
        Boolean isInsert = true;
        Savepoint sp = Database.setSavepoint();
        try { 
            if(shareObjectDeleteList.size() > 0) {
                //system.debug(shareObjectDeleteList);
                delete shareObjectDeleteList;
            }
        } catch (Exception ex) {
            Database.rollback(sp);
            failRecordCreation(ex, true);
            isInsert = false;
        }
        if(isInsert) {
            try {
                if(shareObjectInsertList.size() > 0) {
                    //system.debug(shareObjectInsertList);
                    insert shareObjectInsertList;
                }
            } catch (Exception exp) {
                Database.rollback(sp);
                failRecordCreation(exp, false);
            }      
        }
        shareObjectInsertList = new List<SObject>();
        shareObjectDeleteList = new List<SObject>();
    }
    
    @TestVisible private static void setSharingForChildRecords(Set<Id> parentIdSet, Set<Id> childIdSet) {
        String parentObjectShareName = socsList[0].Parent_Sobject_Share__c;
        String query = 'Select Id, ParentId, UserOrGroupId, AccessLevel, RowCause from ' + parentObjectShareName + ' where ParentId In :parentIdSet';             
        //system.debug('Query---------------------------' + query);
        List<SObject> parentRecordSharingList = DataBase.query(query);        
        List<SObject> childObjectList = new List<SObject>();
        for (SObject_Sharing__c socs :socsList) {
            query = 'SELECT Id, ' + socs.Lookup_Name__c + ' FROM ' + socs.Child_Sobject__c + ' WHERE ' + socs.Lookup_Name__c + ' In :parentIdSet'; 
            if (childIdSet != null) {
                query += ' and Id In :childIdSet';
            }
            childObjectList = DataBase.query(query);
            childIdSet = new Set<Id>();
            for (Sobject childObj : childObjectList) {
                //system.debug((Id)childObj.get(RECORD_ID));
                childIdSet.add((Id)childObj.get(RECORD_ID));  
                //system.debug(childIdSet);
                childToParentIdMap.put((Id)childObj.get(RECORD_ID),(Id)childObj.get(socs.Lookup_Name__c));
            }
            //system.debug(socs.Lookup_Name__c);
            //system.debug(childObjectList);
            //system.debug('childobjectList'+ childObjectList);
            String rowCauseChild = socs.Sharing_Team_Label__c;
            query = 'select Id, ParentId, UserOrGroupId, AccessLevel, RowCause from ' + socs.Child_Sobject_Share__c + ' where parentid in : childIdSet and RowCause = :rowCauseChild';
            //system.debug('Query---------------------------' + query);
            List<SObject> childObjectShareList = DataBase.query(query);
            if (childObjectShareList.size() > 0) {
                shareObjectDeleteList.addAll(childObjectShareList);    
            }
            //system.debug(childObjectShareList);
            //system.debug(parentRecordSharingList);
            for (Sobject childObj : childObjectList) {
                for(SObject shareObj :parentRecordSharingList) {
                    if(childObj.get(socs.Lookup_Name__c) == shareObj.get(PARENT_ID)) {
                        String shareObjectName = socs.Child_Sobject_Share__c;
                        Id userOrGroupId = (Id)shareObj.get(USER_OR_GROUP_ID);
                        Id childId = (Id)childObj.get(RECORD_ID);
                        String accessLevel;
                        if (shareObj.get(ACCESS_LEVEL) == ALL) {
                            accessLevel = EDIT;
                        } else {
                            accessLevel = (String)shareObj.get(ACCESS_LEVEL);
                        }
                        String rowCause = socs.Sharing_Owner_Label__c;
                        Boolean isShareObjInsert = true;
                        if (shareObj.get(ROW_CAUSE) == OWNER) {
                            List<GroupMember> groupMemberList = checkUser(userOrGroupId);
                            if (groupMemberList != null) { 
                                isShareObjInsert = false;
                                if (groupMemberList.size() > 0 ) {
                                    for (GroupMember grpMember :groupMemberList) {
                                        userOrGroupId = grpMember.UserOrGroupId;
                                        SObject obj = shareRecordCreation(shareObjectName, childId, userOrGroupId, accessLevel, rowCause);
                                        shareObjectInsertList.add(obj);
                                        parentShareObjToIdMap.put(obj,(Id)shareObj.get(PARENT_ID));   
                                    }
                                }   
                            }                       
                        }
                        if (isShareObjInsert) {
                            SObject obj = shareRecordCreation(shareObjectName, childId, userOrGroupId, accessLevel, rowCause);
                            shareObjectInsertList.add(obj);
                            parentShareObjToIdMap.put(obj,(Id)shareObj.get(PARENT_ID));  
                        }
                    }
                }		    
            }
        }
    }
    
    @TestVisible private static List<GroupMember> checkUser(Id userOrGroupId) {
        List<GroupMember> groupMemberList;
        String ownerId = userOrGroupId;
        ownerId = ownerId.substring(0,3);
        if (ownerId == '00G') { 
            groupMemberList = new List<GroupMember>([SELECT Id, UserOrGroupId FROM GroupMember WHERE GroupId = :userOrGroupId]);
        }
        return groupMemberList;   
    }
    
    public static void setDummyCreatorAccess(List<SObject> newRecordList, String shareObjectName, String rowCause) {
        List<SObject> shareRecordList = new List<SObject>();
        for(SObject obj :newRecordList) {
            if(obj.get('OwnerId') != UserInfo.getUserId()) {
                Sobject shareRecord = shareRecordCreation(shareObjectName, (Id)obj.get(RECORD_ID), UserInfo.getUserId(), EDIT, rowCause);
                shareRecordList.add(shareRecord);
            }
        }
        if (shareRecordList.size() > 0) {
            insert shareRecordList;    
        }
    }
    
}