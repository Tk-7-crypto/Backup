public with Sharing class CNT_PSA_ArchiveSsEjListView {
    
    @AuraEnabled(cacheable = true)
    public static List<Archive_Search_Strategy__c> getArchiveSSData(String recordId){
        List<Archive_Search_Strategy__c> archiveSearchStrategyList = new List<Archive_Search_Strategy__c>();
        Set<String> archiveSearchStrategyFieldSet = new Set<String>();
        archiveSearchStrategyFieldSet = new Set<String>{'Id', 'Name', 'Version_of_Search_Strategy__c', 'Date_Search_Strategy_got_Client_Approval__c','Date_Annual_Search_Strategy_Due__c', 'Comments__c','Inactive__c'};
        archiveSearchStrategyList = new SLT_PSA_ArchiveSearchStrategy().getArchiveSSRecordsFromLRIdForListView(recordId, archiveSearchStrategyFieldSet);
        return archiveSearchStrategyList;
    }
    
    @AuraEnabled(cacheable = true)
    public static List<Archive_Event_Journal__c> getArchiveEJData(String recordId){
        List<Archive_Event_Journal__c> archiveEventJournalList = new List<Archive_Event_Journal__c>();
        Set<String> archiveEventJournalFieldSet = new Set<String>();
        archiveEventJournalFieldSet = new Set<String>{'Id', 'Name', 'Country__c', 'Journal_Name__c', 'URL__c', 'Frequency_of_Journal__c','Date_Initial_Search_Started__c', 'Date_Last_Journal_Search_was_Performed__c', 'Date_Next_Journal_Search_is_Due__c', 'Inactive__c'};    
        archiveEventJournalList = new SLT_PSA_ArchiveEventJournal().getArchiveEJRecordsFromLRIdForListView(recordId, archiveEventJournalFieldSet);
        return archiveEventJournalList;
        
    }
    
    @AuraEnabled(cacheable = false)
    public static String getAllArchiveSSRecordsForListView(Id  recordId, Integer pageSize, Integer pageNumber,Integer totalRecords, String sortBy, String sortDirection){
        if(sortBy == 'ArchiveSearchStrategyURL'){
            sortBy = 'Name';
        }
        List<Archive_Search_Strategy__c> activeArchiveSearchStrategyList = new List<Archive_Search_Strategy__c>();
        List<Archive_Search_Strategy__c> archiveSearchStrategyList = new List<Archive_Search_Strategy__c>();
        Set<String> archiveSearchStrategyFieldSet = new Set<String>();
        Set<ID> lRIdSet = new Set<ID>();
        lRIdSet.add(recordId);
        WPR_PSA_ArchiveSearchStrategyItem archiveSearchStrategyObj =  new WPR_PSA_ArchiveSearchStrategyItem();
        Integer count = 0;
        String jsonObjItm = '';
        Set<Id> archiveSearchStrategyIdSet = new Set<Id>();
        archiveSearchStrategyFieldSet = new Set<String>{'Id', 'Name', 'Version_of_Search_Strategy__c', 'Date_Search_Strategy_got_Client_Approval__c','Date_Annual_Search_Strategy_Due__c', 'Comments__c','Inactive__c'};
        String whereClause = 'LR_Project_Overview__c IN : lrIds AND Inactive__c = false';
        String orderByField = 'CreatedDate';
        archiveSearchStrategyList = new SLT_PSA_ArchiveSearchStrategy().getArchiveSSByLRIDS(lRIdSet, archiveSearchStrategyFieldSet,whereClause, orderByField);
        if(archiveSearchStrategyList != null && archiveSearchStrategyList.size() > 0){
            for(Archive_Search_Strategy__c archiveSearchStrategy : archiveSearchStrategyList){
                archiveSearchStrategyIdSet.add(archiveSearchStrategy.id);
            }
        }
        Integer offset = (pageNumber - 1) * pageSize;
        Integer recordEnd = pageSize * pageNumber;
        if(archiveSearchStrategyIdSet != null && archiveSearchStrategyIdSet.size() > 0){
            if(totalRecords == 0){
                totalRecords = new SLT_PSA_ArchiveSearchStrategy().getTotalNumberOfRecords(archiveSearchStrategyIdSet);
            } 
            archiveSearchStrategyObj.pageNumber = pageNumber;
            archiveSearchStrategyObj.pageSize = pageSize;        
            archiveSearchStrategyObj.recordStart = offset + 1;
            archiveSearchStrategyObj.recordEnd = totalRecords >= recordEnd ? recordEnd : totalRecords;
            archiveSearchStrategyObj.totalRecords = totalRecords;
            String queryStr='Select Id, Name, Version_of_Search_Strategy__c, Date_Search_Strategy_got_Client_Approval__c,Date_Annual_Search_Strategy_Due__c, Comments__c,Inactive__c from Archive_Search_Strategy__c where Id IN : archiveSearchStrategyIdSet AND Inactive__c =false ORDER BY '+sortBy+' '+sortDirection+' LIMIT 50000';
            for(Archive_Search_Strategy__c ArchiveSearchStrategy : Database.query(queryStr)){
                if(count >= offset && count < archiveSearchStrategyObj.recordEnd){              
                    activeArchiveSearchStrategyList.add(ArchiveSearchStrategy);
                }
                count++;
            }
            if(activeArchiveSearchStrategyList.size() > 0){
                archiveSearchStrategyObj.archiveSs = activeArchiveSearchStrategyList;
            }
            jsonObjItm = JSON.serialize(archiveSearchStrategyObj);
            return jsonObjItm;
        }
        return jsonObjItm;
    }
    
    @AuraEnabled(cacheable = false)
    public static String getAllArchiveEJRecordsForListView(Id  recordId, Integer pageSize, Integer pageNumber,Integer totalRecords, String sortBy, String sortDirection){
        if(sortBy == 'ArchiveEventJournalURL'){
            sortBy = 'Name';
        }
        List<Archive_Event_Journal__c> activeArchiveEventJournalList = new List<Archive_Event_Journal__c>();
        List<Archive_Event_Journal__c> archiveEventJournalList = new List<Archive_Event_Journal__c>();
        Set<String> archiveEventJournalFieldSet = new Set<String>();
        Set<ID> lRIdSet = new Set<ID>();
        lRIdSet.add(recordId);
        WPR_PSA_ArchiveEventJournalItem archiveEventJournalObj =  new WPR_PSA_ArchiveEventJournalItem();
        Integer count = 0;
        String jsonObjItm = '';
        Set<Id> archiveEventJournalIdSet = new Set<Id>();
        archiveEventJournalFieldSet = new Set<String>{'Id', 'Name', 'Country__c', 'Journal_Name__c', 'URL__c', 'Frequency_of_Journal__c','Date_Initial_Search_Started__c', 'Date_Last_Journal_Search_was_Performed__c', 'Date_Next_Journal_Search_is_Due__c', 'Inactive__c'};  
        String whereClause = 'LR_Project_Overview__c IN : lrIds AND Inactive__c = false';
        String orderByField = 'CreatedDate';
        
        archiveEventJournalList = new SLT_PSA_ArchiveEventJournal().getArchiveEJByLRIDS(lRIdSet, archiveEventJournalFieldSet,whereClause, orderByField);
        if(archiveEventJournalList != null && archiveEventJournalList.size() > 0){
            for(Archive_Event_Journal__c archiveEventJournal : archiveEventJournalList){
                archiveEventJournalIdSet.add(archiveEventJournal.id);
            }
        }

        Integer offset = (pageNumber - 1) * pageSize;
        Integer recordEnd = pageSize * pageNumber;
        if(archiveEventJournalIdSet != null && archiveEventJournalIdSet.size() > 0){
            if(totalRecords == 0){
                totalRecords = new SLT_PSA_ArchiveEventJournal().getTotalNumberOfRecords(archiveEventJournalIdSet);
            } 
            archiveEventJournalObj.pageNumber = pageNumber;
            archiveEventJournalObj.pageSize = pageSize;        
            archiveEventJournalObj.recordStart = offset + 1;
            archiveEventJournalObj.recordEnd = totalRecords >= recordEnd ? recordEnd : totalRecords;
            archiveEventJournalObj.totalRecords = totalRecords;
            String queryStr='Select Id, Name, Country__c, Journal_Name__c, URL__c, Frequency_of_Journal__c,Date_Initial_Search_Started__c, Date_Last_Journal_Search_was_Performed__c, Date_Next_Journal_Search_is_Due__c, Inactive__c from Archive_Event_Journal__c where Id IN : archiveEventJournalIdSet AND Inactive__c =false ORDER BY '+sortBy+' '+sortDirection+' LIMIT 50000';  
            
            for(Archive_Event_Journal__c ArchiveEventJournal : Database.query(queryStr)){
                if(count >= offset && count < archiveEventJournalObj.recordEnd){              
                    activeArchiveEventJournalList.add(ArchiveEventJournal);
                }
                count++;
            }
            if(activeArchiveEventJournalList.size() > 0){
                archiveEventJournalObj.archiveEj = activeArchiveEventJournalList;
            }
            jsonObjItm = JSON.serialize(archiveEventJournalObj);
            return jsonObjItm;
        }
        return jsonObjItm;
    }
    
    public class WPR_PSA_ArchiveSearchStrategyItem {       
        public Integer recordStart {get;set;}
        public Integer pageNumber {get;set;}
        public Integer totalRecords {get;set;}
        public Integer recordEnd {get;set;}
        public Integer pageSize {get;set;}       
        public List<Archive_Search_Strategy__c> archiveSs {get;set;}
    }
    
    public class WPR_PSA_ArchiveEventJournalItem {       
        public Integer recordStart {get;set;}
        public Integer pageNumber {get;set;}
        public Integer totalRecords {get;set;}
        public Integer recordEnd {get;set;}
        public Integer pageSize {get;set;}       
        public List<Archive_Event_Journal__c> archiveEj {get;set;}
    } 
}