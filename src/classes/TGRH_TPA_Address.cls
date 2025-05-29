public class TGRH_TPA_Address { 
    /**
     * This method is used to update TPA Vendor account checklist feilds.
     * @params  newList List<Account>
     * @params  oldMap Map<Id, Account>
     * @return  void
     */
    public static void setTpaVendorChecklist(List<Address__c> newList, Map<Id, Address__c> oldMap) {
        List<Address__c> tpaVendorAccountList = new List<Address__c>();
        for(Address__c acc : newList) {
            if(acc.Is_TPA_Account__c) {
                tpaVendorAccountList.add(acc); 
            }
        }
        if(tpaVendorAccountList.size() > 0) {
            Set<Id> idSet = new Set<Id>{UserInfo.getUserId()};
            List<User> usrList = new SLT_User().selectById(idSet);
            for(Address__c acc: tpaVendorAccountList) {
                if(Trigger.isInsert) {
                    acc.Vendor_Check_List_Reason__c = 'New Vendor Record'; 
                    acc.Vendor_Check_List_Updated_Date__c = DateTime.now();
                    if(usrList[0] != null) {
                        acc.Vendor_CheckList_Updated_By__c = usrList[0].Id;
                    }
                    acc.New_Vendor_Checklist__c = true;
                }
                else if(Trigger.isUpdate) {
                    if(acc.Is_TPA_Account__c != oldMap.get(acc.id).Is_TPA_Account__c) {
                        acc.New_Vendor_Checklist__c = true;
                        acc.Vendor_Check_List_Reason__c = 'New Vendor Record';
                    }
                    
                    if(acc.Vendor_Tier__c != oldMap.get(acc.id).Vendor_Tier__c && oldMap.get(acc.id).Is_TPA_Account__c) {
                        if(usrList[0] != null) {
                            if(usrList[0].name != 'tpa Site Guest User') {
                                acc.Vendor_Check_List_Reason__c = 'Manual Update';
                            }
                            acc.Vendor_Check_List_Updated_Date__c = DateTime.now();
                            acc.Vendor_CheckList_Updated_By__c = usrList[0].Id;
                        }
                        acc.New_Vendor_Checklist__c = false;
                    }
                }
            }
            createTpaMastExtensionRec(tpaVendorAccountList);
        }
    }
    
    public static void createTpaMastExtensionRec(List<Address__c> lstTpaVendAddress) {
        if(UTL_Validate.isEmptyOrNull(lstTpaVendAddress)) {
            system.debug('lstTpaVendAddress is null');
            return;
        }
        Map<Id, Address__c> mapTPAVendAdd = new Map<ID, Address__c>([Select Id, Commercial_Reason__c, (Select Id from TPA_Master_Extension_Informations__r limit 1) From Address__c where Id in: lstTpaVendAddress]);
        if(mapTPAVendAdd != null && mapTPAVendAdd.size() > 0) {
            List<TPA_Master_Extension_Information__c> lstTpMastExtInformation = new List<TPA_Master_Extension_Information__c>();
            for(Address__c objAdd : mapTPAVendAdd.values()) {
                if(objAdd.TPA_Master_Extension_Informations__r == null || objAdd.TPA_Master_Extension_Informations__r.size() == 0) {
                    lstTpMastExtInformation.Add(new TPA_Master_Extension_Information__c(Commercial_Reason__c = false, TPA_Accounts_Address__c = objAdd.Id));
                }
            }
            if(lstTpMastExtInformation.size() > 0) {
                insert lstTpMastExtInformation;
            }
        }
    }

    
    public static void updateDynamicOffNotificationRules(Map<Id, Id> oldParenttoNewParentMap) {
        List<id> lstAddress = new List<id>();
        Map<String,Id> useOffUniqueKeyWithRuleId = new Map<String,Id> ();
        String key = '';
        String keyWithOldAdd = '';
        String keyWithNewAdd = '';
        Id newVendorAddId = null;
        Set<id> lstOffNotMappingId = new Set<id>();
        Map<Id,Integer> ruleWithChildRcrdCount = new Map<Id,Integer> ();
        Map<id,TPA_Off_Notification_Account_Mapping__c> MapIdwithRcrd = new Map<id,TPA_Off_Notification_Account_Mapping__c>();

        List<TPA_Off_Notification_Account_Mapping__c> lstOffNotAccMappingtoDelete = new List<TPA_Off_Notification_Account_Mapping__c>();
        List<TPA_Off_Notification_Account_Mapping__c> lstOffNotAccMappingtoupdate = new List<TPA_Off_Notification_Account_Mapping__c>();
        List<TPA_Offering_Notification_Mapping__c> lstOffNotMappingtoDelete = new List<TPA_Offering_Notification_Mapping__c>();
        
        String priOffId = '';  String secOffId =  ''; String vendorAccId = ''; String useId = ''; String country = ''; String ProExeMode = '';
        Integer count = 0;
        List<TPA_Off_Notification_Account_Mapping__c> lstOffNotAccMapping = [Select id, TPA_Offering_Notification_Mapping_Rule__c, TPA_Offering_Notification_Mapping_Rule__r.id, TPA_Offering_Notification_Mapping_Rule__r.IsActive__c, 
                                                                            TPA_Offering_Notification_Mapping_Rule__r.IMS_Primary_Data_Asset__c,TPA_Offering_Notification_Mapping_Rule__r.IMS_Primary_Data_Asset__r.id,
                                                                            TPA_Offering_Notification_Mapping_Rule__r.IMS_Secondary_Data_Asset__c,TPA_Offering_Notification_Mapping_Rule__r.IMS_Secondary_Data_Asset__r.id,
                                                                            TPA_Offering_Notification_Mapping_Rule__r.IMS_TPA_Purpose__c,TPA_Offering_Notification_Mapping_Rule__r.IMS_TPA_Purpose__r.id,
                                                                            TPA_Offering_Notification_Mapping_Rule__r.Country__c,
                                                                            TPA_Offering_Notification_Mapping_Rule__r.Process_Execution_Mode__c,
                                                                            Vendor_Account_Address__c, Vendor_Account_Address__r.id
                                                                            from TPA_Off_Notification_Account_Mapping__c
                                                                            where (Vendor_Account_Address__c in : oldParenttoNewParentMap.keySet()
                                                                            OR Vendor_Account_Address__c In : oldParenttoNewParentMap.values()) and TPA_Offering_Notification_Mapping_Rule__c != null];
        if(lstOffNotAccMapping != null && lstOffNotAccMapping.size() > 0)   {
            for(TPA_Off_Notification_Account_Mapping__c Obj : lstOffNotAccMapping){
                priOffId = ''; secOffId =  ''; vendorAccId = ''; useId = ''; ProExeMode = ''; country = '';

                if(Obj.TPA_Offering_Notification_Mapping_Rule__r.IMS_Primary_Data_Asset__c != null) {
                    priOffId = Obj.TPA_Offering_Notification_Mapping_Rule__r.IMS_Primary_Data_Asset__r.id + '' ;
                }
                if(Obj.TPA_Offering_Notification_Mapping_Rule__r.IMS_Secondary_Data_Asset__c != null) {
                    secOffId = Obj.TPA_Offering_Notification_Mapping_Rule__r.IMS_Secondary_Data_Asset__r.id + '';
                }
                if(Obj.TPA_Offering_Notification_Mapping_Rule__r.IMS_TPA_Purpose__c != null) {
                    useId = Obj.TPA_Offering_Notification_Mapping_Rule__r.IMS_TPA_Purpose__r.id + '';
                }
                if(Obj.TPA_Offering_Notification_Mapping_Rule__r.Country__c != null) {
                    country = Obj.TPA_Offering_Notification_Mapping_Rule__r.Country__c ;
                }
                if(Obj.TPA_Offering_Notification_Mapping_Rule__r.Process_Execution_Mode__c != null) {
                    ProExeMode = Obj.TPA_Offering_Notification_Mapping_Rule__r.Process_Execution_Mode__c ;
                }
                if(Obj.Vendor_Account_Address__c != null) {
                    vendorAccId = Obj.Vendor_Account_Address__r.id + '';
                }

                key =  country+ ':' + vendorAccId + ':' + useId + ':'+ priOffId + ':' + secOffId + ':' + ProExeMode;
                
                if(!useOffUniqueKeyWithRuleId.containsKey(key)) {
                    useOffUniqueKeyWithRuleId.put(key, Obj.Id);
                }
                lstOffNotMappingId.add(Obj.TPA_Offering_Notification_Mapping_Rule__r.id);
            }

            for(TPA_Offering_Notification_Mapping__c Obj: [SELECT Id, (select id  from TPA_Off_Notification_Account_Mapping__r)
                        FROM TPA_Offering_Notification_Mapping__c where id in : lstOffNotMappingId]){
                if(Obj.TPA_Off_Notification_Account_Mapping__r.size() > 0 ) {
                    count = Obj.TPA_Off_Notification_Account_Mapping__r.size();
                    ruleWithChildRcrdCount.put(Obj.id, count );
                }
            }

            for(TPA_Off_Notification_Account_Mapping__c Obj : lstOffNotAccMapping){
                if(oldParenttoNewParentMap.get(obj.Vendor_Account_Address__r.id) != null) {
                    priOffId = ''; secOffId =  ''; vendorAccId = ''; useId = ''; ProExeMode = '';

                    if(Obj.TPA_Offering_Notification_Mapping_Rule__r.IMS_Primary_Data_Asset__c != null) {
                        priOffId = Obj.TPA_Offering_Notification_Mapping_Rule__r.IMS_Primary_Data_Asset__r.id + '' ;
                    }
                    if(Obj.TPA_Offering_Notification_Mapping_Rule__r.IMS_Secondary_Data_Asset__c != null) {
                        secOffId = Obj.TPA_Offering_Notification_Mapping_Rule__r.IMS_Secondary_Data_Asset__r.id + '';
                    }
                    if(Obj.TPA_Offering_Notification_Mapping_Rule__r.IMS_TPA_Purpose__c != null) {
                        useId = Obj.TPA_Offering_Notification_Mapping_Rule__r.IMS_TPA_Purpose__r.id + '';
                    }
                    if(Obj.TPA_Offering_Notification_Mapping_Rule__r.Country__c != null) {
                        country = Obj.TPA_Offering_Notification_Mapping_Rule__r.Country__c ;
                    }
                    if(Obj.TPA_Offering_Notification_Mapping_Rule__r.Process_Execution_Mode__c != null) {
                        ProExeMode = Obj.TPA_Offering_Notification_Mapping_Rule__r.Process_Execution_Mode__c ;
                    }

                    
                    keyWithOldAdd =  country+ ':' + Obj.Vendor_Account_Address__r.id + ':' + useId + ':'+ priOffId + ':' + secOffId + ':' + ProExeMode;
                    keyWithNewAdd =  country+ ':' + oldParenttoNewParentMap.get(obj.Vendor_Account_Address__r.id) + ':' + useId + ':'+ priOffId + ':' + secOffId + ':' + ProExeMode;

                    
                    if(useOffUniqueKeyWithRuleId.containsKey(keyWithOldAdd) && useOffUniqueKeyWithRuleId.containsKey(keyWithNewAdd)) {
                        lstOffNotAccMappingtoDelete.add(Obj);
                        if(ruleWithChildRcrdCount.get(obj.TPA_Offering_Notification_Mapping_Rule__r.id) == 1 ) {
                            lstOffNotMappingtoDelete.add(new TPA_Offering_Notification_Mapping__c(id = obj.TPA_Offering_Notification_Mapping_Rule__r.id)); 
                        }
                    }
                    else if (useOffUniqueKeyWithRuleId.containsKey(keyWithOldAdd) ){
                        obj.Vendor_Account_Address__c = oldParenttoNewParentMap.get(obj.Vendor_Account_Address__r.id);
                        lstOffNotAccMappingtoupdate.add(obj);
                    }
                    
                }
            }
            
            if(lstOffNotAccMappingtoDelete != null && lstOffNotAccMappingtoDelete.size() > 0)   {
                delete lstOffNotAccMappingtoDelete;
            }
            if(lstOffNotMappingtoDelete != null && lstOffNotMappingtoDelete.size() > 0)   {
                delete lstOffNotMappingtoDelete;
            }
            if(lstOffNotAccMappingtoupdate != null && lstOffNotAccMappingtoupdate.size() > 0)   {
                update lstOffNotAccMappingtoupdate;
            }
        }    
        

    }

    public static void updateDDNPendingRequestDetail(Map<Id, Id> oldParenttoNewParentMap) {
        Map <Id, List<Watch_List_History__c>> addressToWatchListHistory = new Map<Id, List<Watch_List_History__c>>();
        List<Watch_List_History__c> ListToBeUpdated = new List<Watch_List_History__c>();
        for(Watch_List_History__c  watchObj: [Select Id, 
                                              Pending_TPA_Request__c, 
                                              Vendor_on_Hold__c 
                                              from Watch_List_History__c 
                                              where (Vendor_on_Hold__c In :oldParenttoNewParentMap.keySet())]) {
                                                  if(!addressToWatchListHistory.containsKey(watchObj.Vendor_on_Hold__c)) {
                                                      addressToWatchListHistory.put(watchObj.Vendor_on_Hold__c, new list<Watch_List_History__c>{watchObj});
                                                  }
                                                  else {
                                                      addressToWatchListHistory.get(watchObj.Vendor_on_Hold__c).add(watchObj);
                                                  }                                    
                                                  
                                              }
        for(Id oldAddressId: oldParenttoNewParentMap.keySet()) {
            List<Watch_List_History__c> oldWatchListHistory = addressToWatchListHistory.get(oldAddressId);
            if(oldWatchListHistory != null && oldWatchListHistory.size() > 0) {
                for(Watch_List_History__c obj: oldWatchListHistory) {
                    obj.Vendor_on_Hold__c = oldParenttoNewParentMap.get(oldAddressId);
                    ListToBeUpdated.add(obj);
                }
            }
            
        }
        
        if(ListToBeUpdated.size() > 0) {
            update ListToBeUpdated;
        }
        
        Map <Id, TPA_Master_Extension_Information__c> addressToExtension = new Map<Id, TPA_Master_Extension_Information__c>();
        List<TPA_Master_Extension_Information__c> ListOfExtToBeUpdated = new List<TPA_Master_Extension_Information__c>();
        for(TPA_Master_Extension_Information__c  extObj: [Select Id, 
                                                          Return_Destruction_Ack_Outstanding__c, 
                                                          DDN_Ack_Pending_Requests__c,
                                                          On_Hold_TPA_Requests__c,
                                                          TPA_Accounts_Address__c 
                                                          from TPA_Master_Extension_Information__c 
                                                          where (TPA_Accounts_Address__c In :oldParenttoNewParentMap.keySet() 
                                                                 OR TPA_Accounts_Address__c In :oldParenttoNewParentMap.values())]) {
                                                                     if(!addressToExtension.containsKey(extObj.TPA_Accounts_Address__c)) {
                                                                         addressToExtension.put(extObj.TPA_Accounts_Address__c, extObj);
                                                                     }                                   
                                                                     
                                                                 }
        for(Id oldAddressId: oldParenttoNewParentMap.keySet()) {
            TPA_Master_Extension_Information__c oldExtObj = addressToExtension.get(oldAddressId);
            TPA_Master_Extension_Information__c newExtObj = addressToExtension.get(oldParenttoNewParentMap.get(oldAddressId));
            if(oldExtObj != null) {
                if(newExtObj != null) {
                    newExtObj.DDN_Ack_Pending_Requests__c = oldExtObj.DDN_Ack_Pending_Requests__c;
                    newExtObj.On_Hold_TPA_Requests__c = oldExtObj.On_Hold_TPA_Requests__c;
                    newExtObj.Return_Destruction_Ack_Outstanding__c = oldExtObj.Return_Destruction_Ack_Outstanding__c;
                    ListOfExtToBeUpdated.add(newExtObj);
                }
                else{
                    ListOfExtToBeUpdated.add(new TPA_Master_Extension_Information__c(
                        Return_Destruction_Ack_Outstanding__c =  oldExtObj.Return_Destruction_Ack_Outstanding__c, 
                        DDN_Ack_Pending_Requests__c = oldExtObj.DDN_Ack_Pending_Requests__c,
                        On_Hold_TPA_Requests__c = oldExtObj.On_Hold_TPA_Requests__c,
                        TPA_Accounts_Address__c = oldParenttoNewParentMap.get(oldAddressId)));
                }
                oldExtObj.DDN_Ack_Pending_Requests__c = '';
                oldExtObj.On_Hold_TPA_Requests__c = '';
                oldExtObj.Return_Destruction_Ack_Outstanding__c = false;
                ListOfExtToBeUpdated.add(oldExtObj);
                
            }
            
        }
        
        if(ListOfExtToBeUpdated.size() > 0) {
            upsert ListOfExtToBeUpdated;
        }
    }

    public static void updateManualApprovalRules(Map<Id, Id> oldParenttoNewParentMap) {
        List<Watch_List__c> watchListToUpdate = new List<Watch_List__c>();
        Map<Id, Map<String, Watch_List__c>> addressToWatchListMap = new Map<Id, Map<String, Watch_List__c>>();
        for(Watch_List__c watchObj: [Select Id, 
                                            Always_Approved__c, 
                                            Data_Asset_Category__c, 
                                            Offering__c, 
                                            Use__c, Vendor_Address__c
                                    from Watch_List__c 
                                    where (Vendor_Address__c In :oldParenttoNewParentMap.keySet() 
                                            OR Vendor_Address__c In :oldParenttoNewParentMap.values())]) {
            Map<String, Watch_List__c> useOfferingsWatchMap = new Map<String, Watch_List__c>();
            
            if(addressToWatchListMap.containsKey(watchObj.Vendor_Address__c)) {
                useOfferingsWatchMap = addressToWatchListMap.get(watchObj.Vendor_Address__c);
            }
            //tempAddressList.add(watchObj);
            String use = ( watchObj.Use__c != null ? watchObj.Use__c : '' );
            String offering = ( watchObj.Offering__c != null ? watchObj.Offering__c : '' );
            
            // Create unique key of use and offering, put into map
            String uniqueKey = use+offering;
            useOfferingsWatchMap.put( uniqueKey, watchObj );
            addressToWatchListMap.put(watchObj.Vendor_Address__c, useOfferingsWatchMap);
        }

        for(Id oldAddressId: oldParenttoNewParentMap.keySet()) {
            Map<String, Watch_List__c> oldWatchListMap = addressToWatchListMap.get(oldAddressId);
            Map<String, Watch_List__c> newWatchListMap = addressToWatchListMap.get(oldParenttoNewParentMap.get(oldAddressId));
            if(oldWatchListMap != null && oldWatchListMap.size() > 0) {
                for(String uniqueKey: oldWatchListMap.keySet()) {
                    Watch_List__c watchObj;
                    if(oldWatchListMap.get(uniqueKey).Always_Approved__c) {
                        if(newWatchListMap != null && newWatchListMap.containsKey(uniqueKey) && !newWatchListMap.get(uniqueKey).Always_Approved__c) {
                            watchObj = newWatchListMap.get(uniqueKey);
                            watchObj.Always_Approved__c = true;
                            watchListToUpdate.add(watchObj);
                        } else {
                            watchObj = oldWatchListMap.get(uniqueKey);
                            watchObj.Vendor_Address__c = oldParenttoNewParentMap.get(oldAddressId);
                            watchListToUpdate.add(watchObj);
                        }
                    }                         
                }
            }
        }
        if(watchListToUpdate.size() > 0) {
            update watchListToUpdate;
        }
        
    }
    
    public static void updateNewParentMapping(List<Address__c> newList, Map<Id, Address__c> oldMap) {
        List<String> accountIdList = new List<String>();
        List<Address__c> newParentAddressList = new List<Address__c>();
        List<Address__c> addressToUpdateList = new List<Address__c>();
        Map<Id, Id> oldParenttoNewParentMap = new Map<Id, Id>();
        User currentUser = UTL_TPA.getCurrentUserDetails();

        for(Address__c address: newList) {
            if(address.Is_TPA_Account__c 
               && (oldMap == null || (oldMap!= null && address.Primary_Vendor_Address__c != oldMap.get(address.Id).Primary_Vendor_Address__c))) {
                if(address.Primary_Vendor_Address__c) {
                    accountIdList.add(address.Account__c);
                    newParentAddressList.add(address);
                } else if(oldMap!= null 
                    && address.Primary_Vendor_Address__c != oldMap.get(address.Id).Primary_Vendor_Address__c
                    && !address.Primary_Vendor_Address__c 
                    && !UTL_TPA.allowParentAddressChange
                    && !currentUser.Profile.Name.toUpperCase().contains('SYSTEM ADMINISTRATOR')){
                    address.addError('You cannot uncheck the Primary vendor Address flag.');
                }
                
            } 

            
        }
            

        if(newParentAddressList.size() > 0) {
            Map<Id, List<Address__c>> accontToAddressMapping = new Map<Id, List<Address__c>>();
            for(Address__c address : [SELECT Id, Name, Account__c, Primary_Vendor_Address__c, Parent_Vendor_Name__c FROM Address__c WHERE Account__c =: accountIdList]) {
                List<Address__c> tempAddressList = new List<Address__c>();
                if(accontToAddressMapping.containsKey(address.Account__c)) {
                    tempAddressList = accontToAddressMapping.get(address.Account__c);
                }
                tempAddressList.add(address);
                accontToAddressMapping.put(address.Account__c, tempAddressList);
            }

            for(Address__c address: newParentAddressList) {
                for(Address__c relatedAddress: accontToAddressMapping.get(address.Account__c)) {
                    if(relatedAddress.Id != address.Id) {
                        if(relatedAddress.Primary_Vendor_Address__c) {
                            relatedAddress.Primary_Vendor_Address__c = false;
                            UTL_TPA.allowParentAddressChange = true;
                            if(!oldParenttoNewParentMap.containsKey(relatedAddress.ID)) {
                                oldParenttoNewParentMap.put(relatedAddress.ID, address.id);
                            } 
                        } 
                        relatedAddress.Parent_Vendor_Name__c = address.id;                        
                    } else {
                        relatedAddress.Parent_Vendor_Name__c = null;
                    }
                    addressToUpdateList.add(relatedAddress);
                }
            }

            if(addressToUpdateList.size() > 0) {
                update addressToUpdateList;
            }
            if(oldParenttoNewParentMap != null && oldParenttoNewParentMap.size() > 0)   {
                updateDynamicOffNotificationRules(oldParenttoNewParentMap);
                updateManualApprovalRules(oldParenttoNewParentMap);
                updateDDNPendingRequestDetail(oldParenttoNewParentMap);
            }
        }
    }
}