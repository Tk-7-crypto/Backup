public class TGRH_Account_Compliance {
    
    List<Task> tasktoInsert;

    public void onBeforeInsert(List<Account_Compliance__c> newRecordsToInsert) {
        checkUniqueAccount(newRecordsToInsert);
        //populateAccountComplianceToAddress(newRecordsToInsert);
		newRecordsToInsert = updateDateFieldOfHold(newRecordsToInsert);
	}
    
    public List<Account_Compliance__c> updateDateFieldOfHold(List<Account_Compliance__c> records){
        taskToinsert = new List<Task>();
        for(Account_Compliance__c accComp : records){
            if(accComp.Client_TPA_Compliance_Hold__c){
                accComp.Client_TPA_Compliance_Hold_Date__c = Date.today();
            }
            if(accComp.Vendor_TPA_Compliance_Hold__c){
                accComp.Vendor_TPA_Compliance_Hold_Date__c = Date.today();
            }
            if(!accComp.Client_TPA_Compliance_Hold__c){
                if(accComp.Client_TPA_Compliance_Hold_Date__c != null)
                    taskToInsert.add(taskUpdate(accComp, 'onRemoval', 'Client'));
                accComp.Client_TPA_Compliance_Hold_Date__c = null; 
            }
            if(!accComp.Vendor_TPA_Compliance_Hold__c){
                if(accComp.Vendor_TPA_Compliance_Hold_Date__c != null)
                    taskToInsert.add(taskUpdate(accComp, 'onRemoval', 'Vendor'));
                accComp.Vendor_TPA_Compliance_Hold_Date__c = null;
            }
        }
        insert taskToInsert;
        return records;
    }
    
    public void onAfterInsert(List<Account_Compliance__c> newRecords){
        updateAccountWithAccountCompliance(newRecords,'add');
        List<Id> acctsRequestsToPutOnHold = new List<Id>();
        for(Account_Compliance__c accComp : newRecords){
            if(accComp.Client_TPA_Compliance_Hold__c || accComp.Vendor_TPA_Compliance_Hold__c){
                acctsRequestsToPutOnHold.add(accComp.Account__c);
                if(accComp.Account__r.ParentId == null){
                    List<Account> childAccounts = [Select Id  from Account where ParentId =: accComp.Account__c];
                    if(childAccounts != null && childAccounts.size() > 0){
                        for(Account acc: childAccounts){
                            acctsRequestsToPutOnHold.add(acc.Id);
                        }
                    }
                }
            }
        }

        BCH_TPA_Compliance_Hold bchObj = new BCH_TPA_Compliance_Hold();
        if(acctsRequestsToPutOnHold.size()>0){
            bchObj.type = 'PutOnHold';
            bchObj.accountsOnHold = acctsRequestsToPutOnHold;
            if(!Test.isRunningTest())
                Database.executeBatch(bchObj,1);        }
	}
    
    public void onAfterUpdate(List<Account_Compliance__c> newRecords, List<Account_Compliance__c> oldRecords, Map<Id, Account_Compliance__c> newMap, Map<Id, Account_Compliance__c> oldMap) {
    	//checkUniqueAccount(newRecords);
        List<Id> acctsRequestsToPutOnHold = new List<Id>();
        List<Id> acctsRequestsToRemoveFromHold = new List<Id>();
        for(Account_Compliance__c accComp : newRecords){
            System.debug(accComp.Vendor_TPA_Compliance_Hold__c + '-->'+ oldMap.get(accComp.Id).Vendor_TPA_Compliance_Hold__c);
            if((accComp.Client_TPA_Compliance_Hold__c == true && !oldMap.get(accComp.Id).Client_TPA_Compliance_Hold__c) || (accComp.Vendor_TPA_Compliance_Hold__c == true && !oldMap.get(accComp.Id).Vendor_TPA_Compliance_Hold__c)){
                acctsRequestsToPutOnHold.add(accComp.Account__c);
                if(accComp.Vendor_TPA_Compliance_Hold__c == true && accComp.Account__r.ParentId == null){
                    List<Account> childAccounts = [Select Id  from Account where ParentId =: accComp.Account__c];
                    if(childAccounts != null && childAccounts.size() > 0){
                        for(Account acc: childAccounts){
                            acctsRequestsToPutOnHold.add(acc.Id);
                        }
                    }
                }
            }

            if((accComp.Client_TPA_Compliance_Hold__c == false && oldMap.get(accComp.Id).Client_TPA_Compliance_Hold__c) || (accComp.Vendor_TPA_Compliance_Hold__c == false && oldMap.get(accComp.Id).Vendor_TPA_Compliance_Hold__c)){
                acctsRequestsToRemoveFromHold.add(accComp.Account__c);
                if(accComp.Vendor_TPA_Compliance_Hold__c == false && accComp.Account__r.ParentId == null){
                    List<Account> childAccounts = [Select Id  from Account where ParentId =: accComp.Account__c];
                    if(childAccounts != null && childAccounts.size() > 0){
                        for(Account acc: childAccounts){
                            acctsRequestsToRemoveFromHold.add(acc.Id);
                        }
                    }
                }
            }
        }
        BCH_TPA_Compliance_Hold bchObj = new BCH_TPA_Compliance_Hold();
        if(acctsRequestsToPutOnHold.size()>0){
            bchObj.type = 'PutOnHold';
            bchObj.accountsOnHold = acctsRequestsToPutOnHold;
            if(!Test.isRunningTest())
                Database.executeBatch(bchObj,1);
        }
        if(acctsRequestsToRemoveFromHold.size() > 0){
            bchObj.type = 'RemoveFromHold';
            bchObj.accountsOnHold = acctsRequestsToRemoveFromHold;
            if(!Test.isRunningTest())
                Database.executeBatch(bchObj,1);
        }
    }

    public void onBeforeUpdate(List<Account_Compliance__c> newRecords, List<Account_Compliance__c> oldRecords, Map<Id, Account_Compliance__c> newMap, Map<Id, Account_Compliance__c> oldMap) {
        newRecords = updateDateFieldOfHold(newRecords);
        List<Account_Compliance__c> accCompsAccountChangedNew = new List<Account_Compliance__c>();
        List<Account_Compliance__c> accCompsAccountChangedOld = new List<Account_Compliance__c>();
        for(Account_Compliance__c accComp: newRecords){
		System.debug(accComp.Vendor_TPA_Compliance_Hold__c + '-->'+ oldMap.get(accComp.Id).Vendor_TPA_Compliance_Hold__c);
            if(accComp.Client_TPA_Compliance_Hold__c == false && oldMap.get(accComp.Id).Client_TPA_Compliance_Hold__c)
                accComp.Client_TPA_Compliance_Hold_Removed_Date__c = date.today();
            if(accComp.Vendor_TPA_Compliance_Hold__c == false && oldMap.get(accComp.Id).Vendor_TPA_Compliance_Hold__c)
                accComp.Vendor_TPA_Compliance_Hold_Removed_Date__c = date.today();
				
            if(accComp.Account__c != oldMap.get(accComp.Id).Account__c){
                accCompsAccountChangedNew.add(accComp);
                accCompsAccountChangedOld.add(oldMap.get(accComp.Id));
            }
        }
        checkUniqueAccount(accCompsAccountChangedNew);
        if(accCompsAccountChangedNew.size() > 0){
            updateAccountWithAccountCompliance(accCompsAccountChangedOld, 'rem');
            updateAccountWithAccountCompliance(accCompsAccountChangedNew, 'add');
        }
        
    }


    
    public void updateAccountWithAccountCompliance(List<Account_Compliance__c> newRecords,String type){
        Map<Id,Id> acctwithAccCompIds = new Map<Id,Id>();
        for(Account_Compliance__c accComp : newRecords){
            acctwithAccCompIds.put(accComp.Account__c,accComp.Id);
        }
        List<Account> accts = [Select Id,Client_Account_Compliance__c,Vendor_Account_Compliance__c,Parent.Vendor_Account_Compliance__c	From Account Where Id in: acctwithAccCompIds.keySet()];
        
        for(Account acct : accts){
            acct.Client_Account_Compliance__c = type == 'add' ? acctwithAccCompIds.get(acct.Id) : null;
            acct.Vendor_Account_Compliance__c = type == 'add' ? acctwithAccCompIds.get(acct.Id) : null;
        }
        
        update accts;
    }
    
    public Task taskUpdate(Account_Compliance__c complianceRecord, String complianceType, String entity){
        Task task = new Task();
        task.WhatId = complianceRecord.id;
        task.ActivityDate = system.today();
        task.Status = 'Completed';
        String taskSubject = entity;
        task.Subject = taskSubject;
        task.Description = '';
        String holdRemovalDate = '';
        Integer holdDuration = 0;
        String holdDate = '';
        if(complianceRecord.Client_TPA_Compliance_Hold_Date__c != null || complianceRecord.Vendor_TPA_Compliance_Hold_Date__c != null )
            holdDate = (entity == 'Client' ? dateFormatter(complianceRecord.Client_TPA_Compliance_Hold_Date__c) : dateFormatter(complianceRecord.Vendor_TPA_Compliance_Hold_Date__c));
        task.Description += entity + ' TPA Compliance Hold Date: ' + holdDate + '\n';
        if(complianceType == 'onRemoval'){
            if(complianceRecord.Client_TPA_Compliance_Hold_Removed_Date__c != null || complianceRecord.Vendor_TPA_Compliance_Hold_Removed_Date__c != null)
                holdRemovalDate = dateFormatter(Date.today());
            task.Description += entity + ' TPA Compliance Hold Removed Date : ' + holdRemovalDate + '\n';
            if((complianceRecord.Client_TPA_Compliance_Hold_Date__c != null && complianceRecord.Client_TPA_Compliance_Hold_Removed_Date__c != null) || (complianceRecord.Vendor_TPA_Compliance_Hold_Date__c != null && complianceRecord.Vendor_TPA_Compliance_Hold_Removed_Date__c != null))
                holdDuration = (entity == 'Client' ? complianceRecord.Client_TPA_Compliance_Hold_Date__c.daysBetween(Date.today()) : complianceRecord.Vendor_TPA_Compliance_Hold_Date__c.daysBetween(Date.today()));
            task.Description += 'Hold Interval: ' + holdDuration + ' Day(s)\n';
        }
        if(complianceRecord.Vendor_TPA_Compliance_Hold_Reason__c != null || complianceRecord.Client_TPA_Compliance_Hold_Reason__c != null){
            task.Description += entity + ' TPA Compliance hold Reason: ' + (entity == 'Client' ? complianceRecord.Client_TPA_Compliance_Hold_Reason__c : complianceRecord.Vendor_TPA_Compliance_Hold_Reason__c);
        }
        task.Subject += complianceType == 'onHold' ? (' is placed on Compliance hold on ' + holdDate) : (' was on Hold for ' + holdDuration + ' days from ' + holdDate + ' to ' + holdRemovalDate);
        
        return task;
    }
    
    public String dateFormatter(Date dateValue){
        return DateTime.newInstance(dateValue, Time.newInstance(0,0,0,0)).format('MM/dd/yyyy');
    }
    
    public void checkUniqueAccount(List<Account_Compliance__c> newRecords){
    	List<String> accountIds = new List<String>();
        for(Account_Compliance__c accComp: newRecords){
            if(accComp.Account__c != null)
            	accountIds.add(accComp.Account__c);
        }
		List<Account_Compliance__c> existingRecords = new List<Account_Compliance__c>();
        existingRecords = [Select Id,Name,Account__c FROM Account_Compliance__c WHERE Account__c in: accountIds];
        
        if(existingRecords.size() > 0){
			newRecords[0].addError('This Account Already have Account Compliance Record');
        }
    }

}