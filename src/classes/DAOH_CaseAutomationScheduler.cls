public class DAOH_CaseAutomationScheduler {

    public static void setPrimaryAndSecondaryCurrentQueue(List<CSM_QI_CaseAutomationScheduler__c> newList){
        Map<Id, CSM_QI_CaseAutomationScheduler__c> primaryOwnerIdMap = new Map<Id, CSM_QI_CaseAutomationScheduler__c>();
        Map<Id, CSM_QI_CaseAutomationScheduler__c> secondaryOwnerIdMap = new Map<Id, CSM_QI_CaseAutomationScheduler__c>();
        for(CSM_QI_CaseAutomationScheduler__c autoRecord : newList){
            if(autoRecord.Primary_Owner__c != null && autoRecord.Primary_Owner_Current_Queue__c == null){
                primaryOwnerIdMap.put(autoRecord.Primary_Owner__c, autoRecord);
            }else if(autoRecord.Primary_Queue_Type__c == 'User' && autoRecord.Primary_Owner_Current_Queue__c != null){
                primaryOwnerIdMap.put(autoRecord.Primary_Owner__c, autoRecord);
            }
            if(autoRecord.Secondary_Owner__c != null && autoRecord.Secondary_Owner_Current_Queue__c == null){
                secondaryOwnerIdMap.put(autoRecord.Secondary_Owner__c, autoRecord);
            }else if(autoRecord.Secondary_Queue_Type__c == 'User' && autoRecord.Secondary_Owner_Current_Queue__c != null){
                secondaryOwnerIdMap.put(autoRecord.Secondary_Owner__c, autoRecord);
            }
        }
        if(primaryOwnerIdMap != null && !primaryOwnerIdMap.isEmpty()){
            List<Queue_User_Relationship__c> primaryQueueList = new SLT_QueueUserRelationshipC().selectByUserGrop(primaryOwnerIdMap.keySet());
            if(primaryQueueList != null && !primaryQueueList.isEmpty()){
                for(Queue_User_Relationship__c queueRecord : primaryQueueList){
                    if(queueRecord.Name.startsWithIgnoreCase('Tech')){
                        if(primaryOwnerIdMap.get(queueRecord.User__c).Primary_Owner_Current_Queue__c != null && primaryOwnerIdMap.get(queueRecord.User__c).Primary_Owner_Current_Queue__c == queueRecord.Id){
                            primaryOwnerIdMap.get(queueRecord.User__c).Primary_Owner_Current_Queue__c = queueRecord.TECH_QueueUser__c;
                            break;
                        }else if(primaryOwnerIdMap.get(queueRecord.User__c).Primary_Owner_Current_Queue__c == null){
                            primaryOwnerIdMap.get(queueRecord.User__c).Primary_Owner_Current_Queue__c = queueRecord.TECH_QueueUser__c;
                            break;
                        }
                        
                    }
                }
                for(Id primaryOwnerId : primaryOwnerIdMap.keySet()){
                    CSM_QI_CaseAutomationScheduler__c caseAutoRecord = primaryOwnerIdMap.get(primaryOwnerId);
                    if(caseAutoRecord.Primary_Owner_Current_Queue__c == null){
                        caseAutoRecord.Primary_Owner_Current_Queue__c = primaryQueueList[0].TECH_QueueUser__c;
                    }
                }
            }
        }
        if(secondaryOwnerIdMap != null && !secondaryOwnerIdMap.isEmpty()){
            List<Queue_User_Relationship__c> secondaryQueueList = new SLT_QueueUserRelationshipC().selectByUserGrop(secondaryOwnerIdMap.keySet());
            if(secondaryQueueList != null && !secondaryQueueList.isEmpty()){
                for(Queue_User_Relationship__c queueRecord : secondaryQueueList){
                    if(queueRecord.Name.startsWithIgnoreCase('Tech')){
                        if(secondaryOwnerIdMap.get(queueRecord.User__c).Secondary_Owner_Current_Queue__c != null && secondaryOwnerIdMap.get(queueRecord.User__c).Secondary_Owner_Current_Queue__c == queueRecord.Id){
                            secondaryOwnerIdMap.get(queueRecord.User__c).Secondary_Owner_Current_Queue__c = queueRecord.TECH_QueueUser__c;
                            break;
                        }else if(secondaryOwnerIdMap.get(queueRecord.User__c).Secondary_Owner_Current_Queue__c == null){
                            secondaryOwnerIdMap.get(queueRecord.User__c).Secondary_Owner_Current_Queue__c = queueRecord.TECH_QueueUser__c;
                            break;
                        }
                    }
                }
                for(Id secondaryOwnerId : secondaryOwnerIdMap.keySet()){
                    CSM_QI_CaseAutomationScheduler__c caseAutoRecord = secondaryOwnerIdMap.get(secondaryOwnerId);
                    if(caseAutoRecord.Secondary_Owner_Current_Queue__c == null){
                        caseAutoRecord.Secondary_Owner_Current_Queue__c = secondaryQueueList[0].TECH_QueueUser__c;
                    }
                }
            }
        }
    }
    
    public static void setNextRunDateOnRecord(List<CSM_QI_CaseAutomationScheduler__c> newList, Map<Id, CSM_QI_CaseAutomationScheduler__c> oldMap){
        List<CSM_QI_CaseAutomationScheduler__c> caseAutoList = new List<CSM_QI_CaseAutomationScheduler__c>();
        Set<Id> autoCaseIdSet = new Set<Id>();
        Set<Id> frequencyIdSet = new Set<Id>();
        for(CSM_QI_CaseAutomationScheduler__c caseAutoRecord : newList){
            if(oldMap != null && ((oldMap.get(caseAutoRecord.Id).Active__c != caseAutoRecord.Active__c) || (oldMap.get(caseAutoRecord.Id).Start_Date__c != caseAutoRecord.Start_Date__c))){
                if(caseAutoRecord.Active__c && caseAutoRecord.Frequency__c == CON_CSM.S_FREQUENCY_DAILY){
                    caseAutoList.add(caseAutoRecord);
                }
                if(caseAutoRecord.Active__c && (caseAutoRecord.Next_Run_Date__c == null || caseAutoRecord.Next_Run_Date__c <= Date.today())){
                    autoCaseIdSet.add(caseAutoRecord.Id);
                    frequencyIdSet.add(caseAutoRecord.FrequencyId__c);
                }
            }
        }
        if(caseAutoList != null && !caseAutoList.isEmpty()){
            calculateNextDateOnActive(caseAutoList);
        }
        if((autoCaseIdSet != null && !autoCaseIdSet.isEmpty()) && (frequencyIdSet != null && !frequencyIdSet.isEmpty())){
            List<CSM_QI_CaseAutomationScheduler__c> caseList = new SLT_CaseAutomationScheduler().selectById(autoCaseIdSet);
            List<CSM_QI_Frequency__c> freqList = new SLT_Frequency().selectById(frequencyIdSet);
            if((caseList != null && !caseList.isEmpty()) && (freqList != null && !freqList.isEmpty())){
                Map<Id, CSM_QI_CaseAutomationScheduler__c> freqIdMap = new Map<ID, CSM_QI_CaseAutomationScheduler__c>();
                for(CSM_QI_CaseAutomationScheduler__c caseRecord : caseList){
                    freqIdMap.put(caseRecord.FrequencyId__c, caseRecord);
                }
                if(freqIdMap != null && !freqIdMap.isEmpty()){
                    Map<Id, CSM_QI_CaseAutomationScheduler__c> newAutoMap = new Map<Id, CSM_QI_CaseAutomationScheduler__c>();
                    for(CSM_QI_Frequency__c freqRecord : freqList){
                        CSM_QI_CaseAutomationScheduler__c newRecord = freqIdMap.get(freqRecord.Id);
                        newRecord = CNT_CSM_Frequency.calculateNextDate(freqIdMap.get(freqRecord.Id), freqRecord, CON_CSM.S_BATCH_EXECUTED);
                        newAutoMap.put(freqRecord.Id, newRecord);
                    }
                    for(CSM_QI_CaseAutomationScheduler__c newAutoRecord : newList){
                        if(newAutoMap.containsKey(newAutoRecord.FrequencyId__c)){
                            newAutoRecord.Next_Run_Date__c = newAutoMap.get(newAutoRecord.FrequencyId__c).Next_Run_Date__c;
                        }
                    }
                }
            }
        }
    }
    
    private static void calculateNextDateOnActive(List<CSM_QI_CaseAutomationScheduler__c> caseAutoList){
        Datetime currentDate = Date.today();
        for(CSM_QI_CaseAutomationScheduler__c caseRecord : caseAutoList){
            Date nextDate;
            Datetime startDate = caseRecord.Start_Date__c;
            if(startDate > currentDate){
                Datetime tempStartDate;
                if(startDate.format('EEEE') == 'Saturday'){
                    tempStartDate = startDate + 2;
                }
                else if(startDate.format('EEEE') == 'Sunday'){
                    tempStartDate = startDate + 1;
                }
                else{
                    tempStartDate = startDate;
                }
                nextDate = tempStartDate.date();
                caseRecord.Next_Run_Date__c = nextDate;
            }
            else if(startDate == currentDate){
                Datetime tempStartDate;
                if(startDate.format('EEEE') == 'Friday'){
                    tempStartDate = startDate + 3;
                }
                else if(startDate.format('EEEE') == 'Saturday'){
                    tempStartDate = startDate + 2;
                }
                else{
                    tempStartDate = startDate + 1;
                }
                nextDate = tempStartDate.date();
                caseRecord.Next_Run_Date__c = nextDate;
            }
            else if(startDate < currentDate){
                Datetime tempStartDate;
                if(currentDate.format('EEEE') == 'Friday'){
                    tempStartDate = currentDate + 3;
                }
                else if(currentDate.format('EEEE') == 'Saturday'){
                    tempStartDate = currentDate + 2;
                }
                else{
                    tempStartDate = currentDate + 1;
                }
                nextDate = tempStartDate.date();
                caseRecord.Next_Run_Date__c = nextDate;
            }
        }
    }
}