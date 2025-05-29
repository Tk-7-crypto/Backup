public without sharing class CNT_OWF_CollectionTools {
    
    @AuraEnabled(cacheable = true)
    public static List<CollectionToolWrapper> fetchCollectionTool(String recordId, Bid_History__c bidHistoryRecord, Decimal numberOfScenarios, String recordTypeId) {
        Set<String> fieldSet =  (new Set<String>{'Id', 'Number_of_Enrolled_Patients__c', 'Number_of_Sites__c', 'Scenario_Number__c', 'Bid_History__c',
            'Description_if_not_within_library__c', 'Specific_Device_Strategy__c', 'COA_Library_Assessment__c', 
            'Select_Device_Type__c', 'Bid_History__r.Number_of_Scenarios__c', 'Countries__c',
            'DBL_Date__c','FPI_Date__c','LPI_Date__c','LPO_Date__c','COA_Type__c','Screened_Patients__c'});
        String condition = 'AND Type__c = \''+ recordTypeId +'\'AND RecordTypeId = \'' + CON_OWF.OWF_COLLECTIONTOOL_IQVIA_TECHNOLOGIES_RECORD_TYPE_ID + '\'';
        List<CollectionTool__c> collectionToolrecords = new List<CollectionTool__c>();
        List<CollectionToolWrapper> collectionToolRecordsWrapper = new List<CollectionToolWrapper>();
        Map<Integer, List<CollectionTool__c>> mapRecords = new  Map<Integer ,List<CollectionTool__c>>();
        
        collectionToolrecords = new SLT_CollectionTool(false, false).getCollectionToolsByCondition(recordId, fieldSet, condition);
        if(collectionToolrecords.size() == 0 && bidHistoryRecord.bid_number__c!=null && bidHistoryRecord.bid_number__c != 1){
            Integer bidNumber = (Integer) bidHistoryRecord.bid_number__c-1;
            condition = 'Bid_History__r.Bid_Number__c ='+ bidNumber + ' AND Bid_History__r.Bid_History_Related_Opportunity__c= \'' + bidHistoryRecord.Bid_History_Related_Opportunity__c + '\' AND Bid_History__r.RecordTypeId = \'' + CON_OWF.OWF_CSS_BID_BID_HISTORY_RECORD_TYPE_ID + '\' AND Type__c = \''+ recordTypeId +'\' AND RecordTypeId = \'' + CON_OWF.OWF_COLLECTIONTOOL_IQVIA_TECHNOLOGIES_RECORD_TYPE_ID + '\'';
            collectionToolrecords = new SLT_CollectionTool(false, false).getCollectionToolRecordsbycondition(condition,fieldSet);
        }
        
        if(numberOfScenarios > 0){
            for(CollectionTool__c record : collectionToolrecords){
                Integer mapKey = (Integer)record.Scenario_Number__c;
                if(!mapRecords.containskey(mapKey)){
                    mapRecords.put(mapKey, new List<CollectionTool__c>{record});
                }
                else {
                    mapRecords.get(mapKey).add(record);
                }
            }
            for(Integer key = 1; key <= numberOfScenarios; key++){
                if(!mapRecords.containskey(key)){
                    mapRecords.put(key, new List<CollectionTool__c>{});
                }
            }
            for(Integer key = 1; key <= numberOfScenarios; key++){
                CollectionToolWrapper wrapperInstance = new CollectionToolWrapper();
                wrapperInstance.key = key;
                Integer sumOfEnrolledPatients = 0 ;
                Integer sumOfScreenedPatients = 0 ;
                Integer sumOfSites = 0;
                Integer noOfCountries = 0; 
                wrapperInstance.collectionToolRecords = mapRecords.get(key);
                if(key == 1) {
                    wrapperInstance.hideCopyFromPreviousTableButton = true;
                } else {
                    wrapperInstance.hideCopyFromPreviousTableButton = false;
                }
                for(CollectionTool__c record : wrapperInstance.collectionToolRecords) {
                    if(record.Countries__c != null){
                        noOfCountries += 1;
                    }
                    if(record.Number_of_Enrolled_Patients__c != null){
                        sumOfEnrolledPatients += (Integer)record.Number_of_Enrolled_Patients__c;
                    }
                    if(record.Screened_Patients__c != null){
                        sumOfScreenedPatients += (Integer)record.Screened_Patients__c;
                    }
                    if(record.Number_of_Sites__c != null){
                        sumOfSites += (Integer)record.Number_of_Sites__c;
                    }
                    
                }
                Boolean getDatesFromBidHistory = true;
                if(wrapperInstance.collectionToolRecords.size() > 0){
                    for(CollectionTool__c record : wrapperInstance.collectionToolRecords){
                        if(record.FPI_Date__c == null && record.LPO_Date__c == null && record.LPI_Date__c == null && record.DBL_Date__c == null){
                            continue; 
                        } else {
                            wrapperInstance.FPI = wrapperInstance.FPI != null ? wrapperInstance.FPI : record.FPI_Date__c;
                            wrapperInstance.LPO = wrapperInstance.LPO != null ? wrapperInstance.LPO : record.LPO_Date__c;
                            wrapperInstance.LPI = wrapperInstance.LPI != null ? wrapperInstance.LPI : record.LPI_Date__c;
                            wrapperInstance.DBL = wrapperInstance.DBL != null ? wrapperInstance.DBL : record.DBL_Date__c;
                            getDatesFromBidHistory = false;
                            if(wrapperInstance.FPI != null && wrapperInstance.LPO != null && wrapperInstance.LPI != null && wrapperInstance.DBL != null) {
                                // if we get all date values from ECOA Collection Tool records, then exit from loop
                                break;
                            }
                        }
                    }
                }
                if(bidHistoryRecord != null && getDatesFromBidHistory) {
                    wrapperInstance.FPI = bidHistoryRecord.FPI_Date__c;
                    wrapperInstance.LPO = bidHistoryRecord.LPO_Date__c;
                    wrapperInstance.LPI = bidHistoryRecord.LPI_Date__c;
                    wrapperInstance.DBL = bidHistoryRecord.DBL_Date__c;
                }
                wrapperInstance.noOfCountries = noOfCountries;
                wrapperInstance.sumOfEnrolledPatients = sumOfEnrolledPatients;
                wrapperInstance.sumOfScreenedPatients = sumOfScreenedPatients;
                wrapperInstance.sumOfSites = sumOfSites;
                collectionToolRecordsWrapper.add(wrapperInstance);
            }
        }
        return collectionToolRecordsWrapper;

    }
    
    @AuraEnabled(cacheable = true)
    public static Bid_History__c fetchBidHistory(String recordId) {
        Set<Id> bidHistoryIdSet= new Set<Id> {recordId};
            Set<String> fieldSet = (new Set<String>{'Id','Number_of_Scenarios__c','Complete_Consent__c','IRT__c','Connected_Devices__c',
                'eCOA__c','DBL_Date__c','FPI_Date__c','LPI_Date__c','LPO_Date__c','Bid_Number__c','Bid_History_Related_Opportunity__c'});
        List<Bid_History__c> bidHistory = new SLT_Bid_History(false,false).getBidHistoryFieldsById(bidHistoryIdSet,fieldSet);
        return bidHistory[0];
    }

    @AuraEnabled
    public static void upsertCollectionTools(List<CollectionToolWrapper> existingRecordsMap, List<CollectionTool__c> updatedRecords, List<String> deletedRecordsIdList, String bidHistoryId){
        List<CollectionTool__c> existingRecordsList = new List<CollectionTool__c>();
        Set<Id> existingRecordsId = new Set<Id>();
        List<CollectionTool__c> updateRecordsList = new List<CollectionTool__c>();
        List<CollectionTool__c> newRecordsList = new List<CollectionTool__c>();
        List<CollectionTool__c> deletedRecordsList = new List<CollectionTool__c>();
        for(CollectionToolWrapper record : existingRecordsMap){
            existingRecordsList.addAll(record.collectionToolRecords);
        }
        for( CollectionTool__c record : existingRecordsList){
            existingRecordsId.add(record.Id);
        }
        for(CollectionTool__c record : existingRecordsList){
            if(deletedRecordsIdList.contains(record.Id)){
                deletedRecordsList.add(record);
            }
        }
        for(CollectionTool__c record : updatedRecords){
            if(!deletedRecordsIdList.contains(record.Id)){
                if(!existingRecordsId.contains(record.Id)){
                    CollectionTool__c newRecord = new CollectionTool__c();
                    newRecord.Countries__c = record.Countries__c;
                    newRecord.Number_of_Sites__c = record.Number_of_Sites__c;
                    newRecord.Number_of_Enrolled_Patients__c = record.Number_of_Enrolled_Patients__c;
                    newRecord.Scenario_Number__c = record.Scenario_Number__c;
                    newRecord.Select_Device_Type__c = record.Select_Device_Type__c;
                    newRecord.COA_Library_Assessment__c = record.COA_Library_Assessment__c;
                    newRecord.COA_Type__c = record.COA_Type__c;
                    newRecord.Screened_Patients__c = record.Screened_Patients__c;
                    newRecord.Description_if_not_within_library__c = record.Description_if_not_within_library__c;
                    newRecord.Specific_Device_Strategy__c = record.Specific_Device_Strategy__c;
                    newRecord.RecordTypeId = record.RecordTypeId;
                    newRecord.Bid_History__c = bidHistoryId;
                    newRecord.FPI_Date__c = record.FPI_Date__c;
                    newRecord.DBL_Date__c = record.DBL_Date__c;
                    newRecord.LPI_Date__c = record.LPI_Date__c;
                    newRecord.LPO_Date__c = record.LPO_Date__c;
                    newRecord.Type__c = record.Type__c;
                    newRecordsList.add(newRecord);
                } else {
                    updateRecordsList.add(record);
                }
            }
        }
        if(updateRecordsList.size() > 0){
            try{
                update updateRecordsList;
            }catch(Exception e){                
                throw new AuraHandledException(e.getDmlMessage(0) == null ? e.getMessage() : e.getDmlMessage(0));
            }
        }
        if(newRecordsList.size() > 0){
            try{
                insert newRecordsList;
            }catch(Exception e){           
                throw new AuraHandledException(e.getDmlMessage(0) == null ? e.getMessage() : e.getDmlMessage(0));
            }
        }
        if(deletedRecordsList.size() > 0){
            delete deletedRecordsList;
        }
    }
    
    public class CollectionToolWrapper {
        @AuraEnabled
        public List<CollectionTool__c> collectionToolRecords{get;set;}
        @AuraEnabled
        public Integer key{get;set;}
        @AuraEnabled
        public Boolean hideCopyFromPreviousTableButton{get;set;}
        @AuraEnabled
        public Date FPI{get;set;}
        @AuraEnabled
        public Date LPI{get;set;}
        @AuraEnabled
        public Date LPO{get;set;}
        @AuraEnabled
        public Date DBL{get;set;}
        @AuraEnabled
        public Integer noOfCountries{get;set;}
        @AuraEnabled
        public Integer sumOfSites{get;set;}
        @AuraEnabled
        public Integer sumOfEnrolledPatients{get;set;}
        @AuraEnabled
        public Integer sumOfScreenedPatients{get;set;}
    }
}
