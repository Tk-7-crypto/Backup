public with sharing class CNT_PSA_ImportJournalMainCtlg {
    
    public static map<String,String> countryMapping = new map<String,String>();
    
    @AuraEnabled
    public static void saveFile(String base64Data){
        CNT_PSA_ImportJournalMainCtlg.countryApiNametoValueMapping();
        String data = JSON.deserializeUntyped(base64Data).toString();
        Set<String> detectDuplicateSet = new Set<String>();
        Boolean checkDuplicates = false;
        Boolean containsColNames = false;
        List<String> lstCSVLines = data.split('\n');
        List<Journals_Main_Catalogue__c> lstCCToInsert = new List<Journals_Main_Catalogue__c>();
        List<Journals_Main_Catalogue__c> duplicateJMCErrList = new List<Journals_Main_Catalogue__c>();
        List<Journals_Main_Catalogue__c> additionalJMCErrList = new List<Journals_Main_Catalogue__c>();
        
        for(Integer i = 0; i < lstCSVLines.size(); i++){
            if(i == 0){
                String csvLine = lstCSVLines[i];
                List<String> colName = csvLine.split(',');
                List<String> colList = new List<String>();
                for(String s : colName){
                    colList.add((s.trim()).toLowerCase());
                }
                if(colList.size() == 9){
                    containsColNames = colList[0].equalsIgnoreCase('Unique ID'.toLowerCase())
                        && colList[1].equalsIgnoreCase('Country'.toLowerCase())
                        && colList[2].equalsIgnoreCase('Journal name'.toLowerCase()) 
                        && colList[3].equalsIgnoreCase('URL'.toLowerCase())
                        && colList[4].equalsIgnoreCase('Periodicity'.toLowerCase())
                        && colList[5].equalsIgnoreCase('Regulatory Requirement'.toLowerCase())
                        && colList[6].equalsIgnoreCase('Subscription'.toLowerCase())
                        && colList[7].equalsIgnoreCase('Paper journal'.toLowerCase())
                        && colList[8].equalsIgnoreCase('Therapeutic area'.toLowerCase()); 
                }
                if(colList.size() != 9 || !containsColNames){
                    throw new AuraHandledException('CSV file column not in sequence, Please set the column in sequence and upload the file again');
                }
            }else{
                Journals_Main_Catalogue__c jmc = new Journals_Main_Catalogue__c();
                String csvLine = lstCSVLines[i]; 
                Integer startIndex;
                Integer endIndex;               
                while(csvLine.indexOf('"') > -1){                   
                    if(startIndex == null){
                        startIndex = csvLine.indexOf('"');
                        csvLine = csvLine.substring(0, startIndex) + ':quotes:' + csvLine.substring(startIndex+1, csvLine.length());
                    }else{
                        if(endIndex == null){
                            endIndex = csvLine.indexOf('"');
                            csvLine = csvLine.substring(0, endIndex) + ':quotes:' + csvLine.substring(endIndex+1, csvLine.length());
                        }
                    }                    
                    if(startIndex != null && endIndex != null){
                        String sub = csvLine.substring(startIndex, endIndex);
                        sub = sub.replaceAll(',', ':comma:');
                        csvLine = csvLine.substring(0, startIndex) + sub + csvLine.substring(endIndex, csvLine.length());
                        startIndex = null;
                        endIndex = null;
                    }
                }               
                List<String> csvRowData = new List<String>();                
                for(String column : csvLine.split(',')){
                    column = column.replaceAll(':quotes:', '').replaceAll(':comma:', ',');
                    csvRowData.add(column);
                }                
               try{
                    jmc.Name = (csvRowData[0] != null ? csvRowData[0].trim() : null);               
                    jmc.Country__c = countryMapping.get(csvRowData[1] != null ? csvRowData[1].trim().toLowerCase() : null); // change into country code             
                    jmc.Journal_Name__c = (csvRowData[2] != null ? csvRowData[2].trim() : null);
                    jmc.URL__c = (csvRowData[3] != null ? csvRowData[3].trim() : null);
                    jmc.Periodicity__c = (csvRowData[4] != null ? csvRowData[4].trim() : null);                
                    jmc.Regulatory_requirement__c = (csvRowData[5] != null ? csvRowData[5].trim() : null);
                    jmc.Subscription__c = (csvRowData[6] != null ? csvRowData[6].trim() : null);
                    jmc.Paper_Journal__c = (csvRowData[7] != null ? csvRowData[7].trim() : null);
                    jmc.Therapeutic_Area__c = (csvRowData[8] != null ? csvRowData[8].trim() : null);
                }catch(Exception ex){
                    additionalJMCErrList.add(jmc);
                }
                if(lstCCToInsert.size() >= 1){
                    checkDuplicates = detectDuplicateSet.add(jmc.Name);
                    if(!checkDuplicates){
                        duplicateJMCErrList.add(jmc);
                    }
                    lstCCToInsert.add(jmc);
                    detectDuplicateSet.add(jmc.Name);
                }else{
                    lstCCToInsert.add(jmc);
                    detectDuplicateSet.add(jmc.Name);
                }
                
            }           
        }
        if(duplicateJMCErrList != null && duplicateJMCErrList.size() > 0){
            handleInvalidAndDulplicateEntries(duplicateJMCErrList, true);
        }
        if(additionalJMCErrList != null && additionalJMCErrList.size() > 0){
            handleInvalidAndDulplicateEntries(additionalJMCErrList, false);
        }
        CNT_PSA_ImportJournalMainCtlg.validateAndInsert(lstCCToInsert);
    }
    
    @AuraEnabled
    public static void saveXlsFile(List<Journals_Main_Catalogue__c> data){
        CNT_PSA_ImportJournalMainCtlg.countryApiNametoValueMapping();
        List<Journals_Main_Catalogue__c> lstJMCToInsert = new List<Journals_Main_Catalogue__c>();
        Set<String> detectDuplicateSet = new Set<String>();
        List<Journals_Main_Catalogue__c> duplicateJMCErrList = new List<Journals_Main_Catalogue__c>();
        Boolean checkDuplicates = false;
        List<Journals_Main_Catalogue__c> additionalJMCErrList = new List<Journals_Main_Catalogue__c>();
        
        for(Journals_Main_Catalogue__c jmc: data){
            try{
                Journals_Main_Catalogue__c jmcRecord = new Journals_Main_Catalogue__c();
                jmcRecord.Name = String.valueOf(jmc.Name);               
                jmcRecord.Country__c = countryMapping.get(jmc.Country__c != null ? jmc.Country__c.trim().toLowerCase() : null); // change into country code
                jmcRecord.Journal_Name__c = (jmc.Journal_Name__c != null ? jmc.Journal_Name__c.trim() : null);
                jmcRecord.URL__c = (jmc.URL__c != null ? jmc.URL__c.trim() : null);
                jmcRecord.Periodicity__c = (jmc.Periodicity__c != null ? jmc.Periodicity__c.trim() : null);                
                jmcRecord.Regulatory_requirement__c = (jmc.Regulatory_requirement__c != null ? jmc.Regulatory_requirement__c.trim() : null);
                jmcRecord.Subscription__c = (jmc.Subscription__c != null ? jmc.Subscription__c.trim() : null);
                jmcRecord.Paper_Journal__c = (jmc.Paper_Journal__c != null ? jmc.Paper_Journal__c.trim() : null);
                jmcRecord.Therapeutic_Area__c = (jmc.Therapeutic_Area__c != null ? jmc.Therapeutic_Area__c.trim() : null);
                
                //detect duplicate and then add to list
                if(lstJMCToInsert.size() >= 1){
                    checkDuplicates = detectDuplicateSet.add(String.valueOf(jmc.Name));
                    if(!checkDuplicates){
                        duplicateJMCErrList.add(jmcRecord);
                    }
                    lstJMCToInsert.add(jmcRecord);
                    detectDuplicateSet.add(String.valueOf(jmc.Name));
                }else{
                    lstJMCToInsert.add(jmcRecord);
                    detectDuplicateSet.add(String.valueOf(jmc.Name));
                }
            }catch(Exception ex){
                additionalJMCErrList.add(jmc);
            }
        }
        //5649
        if(duplicateJMCErrList != null && duplicateJMCErrList.size() > 0){
            handleInvalidAndDulplicateEntries(duplicateJMCErrList, true);
        }
        if(additionalJMCErrList != null && additionalJMCErrList.size() > 0){
            handleInvalidAndDulplicateEntries(additionalJMCErrList, false);
        }
        CNT_PSA_ImportJournalMainCtlg.validateAndInsert(lstJMCToInsert);
    }
    
/*
* This method validate the records from uploaded file and perform action accordingly.
* Insert: When no record with same Record Id there in database
* Update: When record with same Record Id there in database
*/
    public static void validateAndInsert(List<Journals_Main_Catalogue__c> lstJMCData){
        Set<String> setOfNewRecordIdToInsert = new Set<String>();
        List<Journals_Main_Catalogue__c> failedRecList = new List<Journals_Main_Catalogue__c>();
        List<Journals_Main_Catalogue__c> successRecList = new List<Journals_Main_Catalogue__c>();
        Map<string, Journals_Main_Catalogue__c> mapOfRecords = new Map<string, Journals_Main_Catalogue__c>();
        List<Journals_Main_Catalogue__c> jMCToUpdateList = new List<Journals_Main_Catalogue__c>();
        List<Journals_Main_Catalogue__c> jMCToInsertList = new List<Journals_Main_Catalogue__c>();
        Map<Id,Journals_Main_Catalogue__c> journalMainCataIdToJournalRecordMap = new Map<Id,Journals_Main_Catalogue__c>();
        //creating set of record id from new JMC data
        for(Journals_Main_Catalogue__c rec : lstJMCData){
            setOfNewRecordIdToInsert.add(rec.Name);
        }
        
        //fetching data having same record id (if any)
        List<Journals_Main_Catalogue__c> journalsMainCatalogueList = new SLT_Journals_Main_Catalogue().getJournalsMainCatalogueFromIds(setOfNewRecordIdToInsert, new Set<String>{'Id','Name','Country__c', 'Journal_Name__c','URL__c' ,'Periodicity__c','Regulatory_requirement__c',
            'Subscription__c','Paper_Journal__c','Therapeutic_Area__c'} );
        for(Journals_Main_Catalogue__c Record : journalsMainCatalogueList){
            mapOfRecords.put(Record.Name, Record);
        }
        
        //seperating list of data for insert and update
        for(Integer iterator = 0; iterator < setOfNewRecordIdToInsert.size(); iterator++){
            if(mapOfRecords.containsKey(lstJMCData[iterator].Name)){
                Journals_Main_Catalogue__c newJmc = mapOfRecords.get(lstJMCData[iterator].Name);
                newJmc.Name = lstJMCData[iterator].Name;
                newJmc.Country__c =  lstJMCData[iterator].Country__c;
                newJmc.Journal_Name__c = lstJMCData[iterator].Journal_Name__c;
                newJmc.URL__c = lstJMCData[iterator].URL__c;
                newJmc.Periodicity__c = lstJMCData[iterator].Periodicity__c;
                newJmc.Regulatory_requirement__c = lstJMCData[iterator].Regulatory_requirement__c;
                newJmc.Subscription__c = lstJMCData[iterator].Subscription__c;
                newJmc.Paper_Journal__c = lstJMCData[iterator].Paper_Journal__c;
                newJmc.Therapeutic_Area__c = lstJMCData[iterator].Therapeutic_Area__c;
                jMCToUpdateList.add(newJmc);
            }
            else{
                jMCToInsertList.add(lstJMCData[iterator]);
            }
        }
        if(jMCToUpdateList.size()>0){
            Database.SaveResult[] results = Database.update(jMCToUpdateList, false);
            if(results.size() > 0){
               for(Integer i=0; i< results.size(); i++){
                   if(!results[i].isSuccess()){
                      failedRecList.add(jMCToUpdateList[i]);
                    }else{
                       journalMainCataIdToJournalRecordMap.put(jMCToUpdateList[i].Id,jMCToUpdateList[i]);
                   }
                }
            }
        }        
        if(jMCToInsertList.size()>0){
            UTL_ExecutionControl.stopAuditTriggerExecution = true;
            Database.SaveResult[] results = Database.insert(jMCToInsertList, false);
            if(results.size() > 0){
                for(Integer i=0; i< results.size(); i++){
                    if(!results[i].isSuccess()){
                        failedRecList.add(jMCToInsertList[i]);
                    }else{
                        successRecList.add(jMCToInsertList[i]);
                    }
                    
                }
            }
        }
        if(successRecList.size() > 0 && failedRecList.size() == 0){
            if(journalMainCataIdToJournalRecordMap.size() > 0){
              SRV_PSA_AuditLog.setAuditOnInsertUpdate(successRecList,journalMainCataIdToJournalRecordMap);  
            }else{
               SRV_PSA_AuditLog.setAuditOnInsertUpdate(successRecList,null);   
            }
        }
        if(failedRecList != null && failedRecList.size() > 0){
            handleInvalidAndDulplicateEntries(failedRecList, false);
        }
        UTL_ExecutionControl.stopAuditTriggerExecution = false;
    }
    
    public static void countryApiNametoValueMapping(){
        List<Schema.PicklistEntry> entries=new List<Schema.PicklistEntry>();
        Schema.DescribeFieldResult fieldDescription = Journals_Main_Catalogue__c.Country__c.getDescribe();
        entries = fieldDescription.getPicklistValues();
        for (Schema.PicklistEntry entry : entries) {
            countryMapping.put(entry.getLabel().toLowerCase() ,entry.getValue());
        }       
    }
    
    private static void handleInvalidAndDulplicateEntries(List<Journals_Main_Catalogue__c> invalidEntriesList, boolean isForDuplicateValue){
        WPR_PSA_JMCErrFileWrapper jmcErrWpr;
        String customError = '';
        Set<String> picklistValuesList = new Set<String>{'Yes','No'};
        List<WPR_PSA_JMCErrFileWrapper> jmcErrWprList = new List<WPR_PSA_JMCErrFileWrapper>();
        for(Journals_Main_Catalogue__c jmc: invalidEntriesList) {
            jmcErrWpr = new WPR_PSA_JMCErrFileWrapper();
            jmcErrWpr.name = jmc.Name;               
            jmcErrWpr.country = jmc.Country__c; // change into country code             
            jmcErrWpr.journalName = jmc.Journal_Name__c;
            jmcErrWpr.url = jmc.URL__c;
            jmcErrWpr.periodicity = jmc.Periodicity__c; 
            if(!picklistValuesList.contains(jmc.Regulatory_requirement__c)){
                customError ='Regulatory Requirement, ';
            }
            if(!picklistValuesList.contains(jmc.Subscription__c)){
                customError +='Subscription, ';
            }
            if(!picklistValuesList.contains(jmc.Paper_Journal__c)){
                customError +='Paper Journal ';
            }
            
            if(customError != ''){
                customError += 'must have values in YES or NO Only';
            }
            if(jmc.Name == null || jmc.Country__c == null || jmc.Journal_Name__c == null || jmc.URL__c == null
              || jmc.Periodicity__c == null || jmc.Regulatory_requirement__c == null || jmc.Subscription__c == null
               || jmc.Paper_Journal__c == null || jmc.Therapeutic_Area__c == null ){
                   if(customError == ''){
                      customError += 'All column must have all the required values'; 
                   }else{
                      customError += ' and all column must have all the required values';  
                   }
               }
            jmcErrWpr.regulatoryRequirement = jmc.Regulatory_requirement__c;
            jmcErrWpr.subscription = jmc.Subscription__c;
            jmcErrWpr.paperJournal = jmc.Paper_Journal__c;
            jmcErrWpr.therapeuticArea = jmc.Therapeutic_Area__c;
            if(isForDuplicateValue){
                jmcErrWpr.error = 'Duplicate value';
            }else{
                if(customError != ''){
                   jmcErrWpr.error = customError;
                }else{
                   jmcErrWpr.error = 'Please check this record.';  
                }
            }
            jmcErrWprList.add(jmcErrWpr);
        }
        if(jmcErrWprList != null && jmcErrWprList.size() > 0){
            throw new AuraHandledException(JSON.serialize(jmcErrWprList));
        }
    }
  
    public class WPR_PSA_JMCErrFileWrapper {
        public String error {get; set;}
        public String name {get; set;}
        public String country {get; set;}
        public String journalName {get; set;}
        public String url {get; set;}
        public String periodicity {get; set;}
        public String regulatoryRequirement {get; set;}
        public String subscription {get; set;}
        public String paperJournal {get; set;}
        public String therapeuticArea {get; set;}
    }
}