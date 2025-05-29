global class BCH_CSM_StudySiteMerge implements Database.Batchable<AggregateResult> {
    global Iterable<AggregateResult> start(Database.BatchableContext bc) {
        String query = 'SELECT SiteNumber__c, Study__c, COUNT(Id) DuplicateCount FROM StudySiteContactRelationship__c WHERE SiteNumber__c != null AND Study__c != null GROUP BY Study__c, SiteNumber__c HAVING COUNT(Id) > 1 LIMIT 2000';
        return new AggregateResultIterable(query);
    } 
    
    global void execute(Database.BatchableContext bc, List<sObject> scope) { 
        String studyId;
        String siteNumber;
        Decimal duplicateCount;
        for(sObject sObj : scope) {
            AggregateResult result = (AggregateResult)sObj;
            duplicateCount = (Decimal)result.get('DuplicateCount');
            studyId = (String)result.get('Study__c');
            siteNumber = (String)result.get('SiteNumber__c');
        }
        
        List<StudySiteContactRelationship__c> duplicateStudySiteList = [SELECT Id, Name, SiteNumber__c, Study__c, Is_Survivor__c FROM StudySiteContactRelationship__c WHERE Study__c =: studyId AND SiteNumber__c =: siteNumber];
        StudySiteContactRelationship__c survivorRecord;
        Map<Id, StudySiteContactRelationship__c> studySitesToMerge = new Map<Id, StudySiteContactRelationship__c>();
        List<Case> casesToUpdate;
        Decimal survivorRecordCount = 0;
        for(StudySiteContactRelationship__c studySiteRecord : duplicateStudySiteList) {
            if(studySiteRecord.Is_Survivor__c) {
                survivorRecord = studySiteRecord;
                survivorRecordCount++;
            } 
            else {
                studySitesToMerge.put(studySiteRecord.Id, studySiteRecord);
            }
        }
        if(survivorRecord == null && survivorRecordCount == 0) {
            System.debug('No Survivor record found for '+ duplicateCount + ' duplicates with SiteNumber = '+ siteNumber +' and Study = '+ studyId); 
            throw new CustomException('No Survivor record found for '+ duplicateCount + ' duplicates with SiteNumber = '+ siteNumber +' and Study = '+ studyId);
        } 
        else if(survivorRecordCount > 1) {
            System.debug(survivorRecordCount + ' Survivor records found for the duplicates with SiteNumber = '+ siteNumber +' and Study = '+ studyId); 
            throw new CustomException(survivorRecordCount + ' Survivor records found for the duplicates with SiteNumber = '+ siteNumber +' and Study = '+ studyId);            
        }
        else {
            if(studySitesToMerge != null && !studySitesToMerge.isEmpty()) {
                casesToUpdate = [SELECT Id, Site_Related_to_the_Study__c FROM Case WHERE Site_Related_to_the_Study__c IN : studySitesToMerge.keySet()];
                for(Case caseRecord : casesToUpdate) {
                    caseRecord.Site_Related_to_the_Study__c = survivorRecord.Id;
                }
                try{
                    if(casesToUpdate != null && casesToUpdate.size() > 0) {
                        update casesToUpdate;
                    }
                    delete studySitesToMerge.values();
                } catch(Exception ex) {
                    System.debug('BCH_CSM_StudySiteMerge Error Message = '+ ex.getMessage());
                    throw new CustomException('BCH_CSM_StudySiteMerge Error Message = '+ ex.getMessage());
                }
            }
        }
    }

    global void finish(Database.BatchableContext bc) {
    
    }
    
    global class AggregateResultIterable implements Iterable<AggregateResult> {
        private String query;
        
        global AggregateResultIterable(String soql) {
            query = soql;
        }
        
        global Iterator<AggregateResult> Iterator() {
            return new AggregateResultIterator(query);
        }
    }
    
    global class AggregateResultIterator implements Iterator<AggregateResult> {
        AggregateResult [] results { get; set; }
        Integer index { get; set; } 
        
        global AggregateResultIterator(String query) {
            index = 0;
            results = Database.query(query); 
        } 
        
        global boolean hasNext(){ 
            return results != null && !results.isEmpty() && index < results.size(); 
        }    
        
        global AggregateResult next() {        
            return results[index++];            
        }       
    }   
    
    public class CustomException extends Exception {}
}