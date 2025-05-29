global class BCH_TPA_ManageTPARequestSharing implements Database.Batchable<sObject>,Database.Stateful {
    global Map<Id, List<Id>> addressIdContactIdListMap = new Map<Id, List<Id>>();
    //map<String, TPA_Request__Share> oldShareRecordsMap = new map<String, TPA_Request__Share>();

    global list<id> TPProcessorSuperUserIDs = new list<id>();
    global Map<id, User> contactIdUserMap = new Map<id, User>();
    global Database.QueryLocator start(Database.BatchableContext BC) {
        set<Id> idSet = addressIdContactIdListMap.keySet();
        string query = 'select Name, TPA_Processor_Account_Address__c, Client_Company_Name_Address__c, Request_Status__c, OwnerId, TPA_Processor_Contact__c From TPA_Request__c where Is_Submitted__c = true and Request_Status__c != \'Client Draft\' and (TPA_Processor_Account_Address__c IN : idSet or Client_Company_Name_Address__c IN :idSet)'; 
            
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<sObject> objList) {
        list<TPA_Request__c> requestList = (list<TPA_Request__c>)objList;
    
        //Key : UserOrGroupId + ParentId
        //Value : TPA_Request__Share
        map<String, TPA_Request__Share> oldShareRecordsMap = new map<String, TPA_Request__Share>();
        for(TPA_Request__Share oldShareRecord : [SELECT Id, UserOrGroupId, ParentId 
                                                    FROM TPA_Request__Share 
                                                    WHERE UserOrGroupId IN : TPProcessorSuperUserIDs
                                                    AND ParentId IN :requestList
                                                    AND (RowCause = :Schema.TPA_Request__Share.rowCause.TP_Processor__c  
                                                        OR RowCause = :Schema.TPA_Request__Share.rowCause.Super_User__c)
                                                    ORDER BY lastmodifiedDate DESC]) {
            if(oldShareRecordsMap.size() >= 49000) {
                break;
            } 
            oldShareRecordsMap.put('' + oldShareRecord.UserOrGroupId + oldShareRecord.ParentId, oldShareRecord);
        }
        
        system.debug('oldShareRecordsMap.size() = ' + oldShareRecordsMap.size());
        
        List<TPA_Request__Share> sharingRecords = new List<TPA_Request__Share>();
        //Integer counter = 0;
        
        for(TPA_Request__c request : requestList) {
            if(sharingRecords.size() >= 9000) {
                break;
            }
            system.debug('request.Name = ' + request.Name);
            system.debug('request.TPA_Processor_Account_Address__c = ' + request.TPA_Processor_Account_Address__c);
            system.debug('request.Client_Company_Name_Address__c = ' + request.Client_Company_Name_Address__c);
            //system.debug('request.Request_Status__c = ' + request.Request_Status__c);
            system.debug('request.OwnerId = ' + request.OwnerId);
            
            List<Id> tpProcessorContactIdList = addressIdContactIdListMap.get(request.TPA_Processor_Account_Address__c);
            system.debug('tpProcessorContactIdList = ' + tpProcessorContactIdList);
            if(tpProcessorContactIdList != null) {
                for(Id contactid: tpProcessorContactIdList) {
                    User tpProcessor = contactIdUserMap.get(contactid);
                    //system.debug('tpProcessor = ' + tpProcessor);
                    system.debug('tpProcessor.ContactId = ' + tpProcessor.ContactId);
                    system.debug('tpProcessor.id = ' + tpProcessor.id);
                    system.debug('tpProcessor.Profile.Name = ' + tpProcessor.Profile.Name);
                    system.debug('New Sharing Record for ' + request.Name + 'and ' + tpProcessor.name + tpProcessor.id);
                    
                    if(tpProcessor.Id != request.OwnerId 
                        && contactid == request.TPA_Processor_Contact__c
                        && (tpProcessor.Profile.Name == 'TPA Processor Profile CCP' || tpProcessor.Profile.Name == 'US TP Processor Profile CCP')) {
                        if(oldShareRecordsMap.get('' + tpProcessor.Id + request.Id) == null) {
                            system.debug('In TP Processor check --> Share ' + request.Name + 'with ' + tpProcessor.name + tpProcessor.id);
                            if(sharingRecords.size() < 9000) {
                                TPA_Request__Share requestShare = new TPA_Request__Share();
                                requestShare.ParentId = request.Id;
                                requestShare.UserOrGroupId = tpProcessor.Id; 
                                requestShare.AccessLevel = 'Edit';
                                requestShare.RowCause = Schema.TPA_Request__Share.RowCause.TP_Processor__c; 
                                sharingRecords.add(requestShare);
                            } else {
                                break;
                            }                              
                        } else {
                            system.debug('In TP Processor check --> Remove Share ' + request.Name + 'with ' + tpProcessor.name + tpProcessor.id);
                            
                            oldShareRecordsMap.remove('' + tpProcessor.Id + request.Id);
                        }
                    }
                }
            }
            
            List<Id> superUserContactIdList = addressIdContactIdListMap.get(request.Client_Company_Name_Address__c);
            system.debug('superUserContactIdList = ' + superUserContactIdList);
            
            if(superUserContactIdList != null) {
                for(Id contactid: superUserContactIdList) {
                    User superUser = contactIdUserMap.get(contactid);
                    system.debug('superUser = ' + superUser);
                    system.debug('superUser.ContactId = ' + superUser.ContactId);
                    system.debug('superUser.id = ' + superUser.id);
                    system.debug('superUser.Profile.Name = ' + superUser.Profile.Name);
                    system.debug('New Sharing Record for ' + request.Name + 'and ' + superUser.name + superUser.id);
                    if(superUser.Id != request.OwnerId 
                        && superUser.Profile.Name == 'Super User Profile CCP') {
                        if(oldShareRecordsMap.get('' + superUser.Id + request.Id) == null) {
                            if(sharingRecords.size() < 9000) {
                                TPA_Request__Share requestShare = new TPA_Request__Share();
                                requestShare.ParentId = request.Id;
                                requestShare.UserOrGroupId = superUser.Id; 
                                requestShare.AccessLevel = 'Edit';
                                requestShare.RowCause = Schema.TPA_Request__Share.RowCause.Super_User__c;   
                                sharingRecords.add(requestShare);
                            } else {
                                break;
                            }
                        } else {
                            oldShareRecordsMap.remove('' + superUser.Id + request.Id);
                        }
                    }
                }
            }
            
        }       
    
        system.debug('sharingRecords = ' + sharingRecords);
        system.debug('oldShareRecordsMap.size() After = ' + oldShareRecordsMap.size());
    
        if(oldShareRecordsMap != null && oldShareRecordsMap.size() > 0) {
            list<TPA_Request__Share> oldShareRecordDelete = new list<TPA_Request__Share>();
            for(TPA_Request__Share oldReq : oldShareRecordsMap.values()){
                oldShareRecordDelete.add(oldReq);
            }
            if(oldShareRecordDelete.size() > 0){
                delete oldShareRecordDelete;
            }
            system.debug('Old sharing Records deleted successfully.');
        }
    
        if(sharingRecords != null && sharingRecords.size() > 0) {
            Database.SaveResult[] results = Database.insert(sharingRecords, false);
            // Create counter
            Integer i=0;
            
            for(Database.SaveResult result : results) {
                if(!result.isSuccess()) {
                    // Get the first save result error
                    Database.Error err = result.getErrors()[0];
                    system.debug('Exception :  ' + err.getMessage() + ' for TPA Request Id ' + sharingRecords[i].ParentId);
                }i++;
            }
        }   
        System.Debug('In TPA_Trigger_On_User : Trigger.IsAfter End');
    }

    global void finish(Database.BatchableContext BC) {}
}