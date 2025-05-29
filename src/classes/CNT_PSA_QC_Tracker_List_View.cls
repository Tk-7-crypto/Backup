public class CNT_PSA_QC_Tracker_List_View {

    @AuraEnabled(cacheable=true)
    public static List<QC_Tracker_Result__c> getQCTrackerResultData(String recordId){
	  List<QC_Tracker_Result__c> activeQCTrackerList = new List<QC_Tracker_Result__c>();
        Set<String> qcTrackerFieldSet = new Set<String>{'Id', 'Name', 'REP_QC_ID__c','REP_QC_Form_Type__c','REP_Author__c','REP_Date_QC_Completed__c','Date_Deleted__c','REP_QC_Completed_By__c','REP_Error_Free__c','REP_QC_URL__c'};
        String whereClause = 'Aggregate_Report__c =:rltdAggRepId AND Date_Deleted__c = null';
        String orderByField = 'REP_Date_QC_Completed__c';
        if(recordId != null){
		activeQCTrackerList = new SLT_QC_Tracker().getActiveQCTrackerRecords(recordId, qcTrackerFieldSet, 5, whereClause, orderByField);
	  }
	  return activeQCTrackerList;
    }
    
    @AuraEnabled(cacheable=false)
    public static  String  getAllActiveQCRecordsForListView(Id  recordId, Integer pageSize, Integer pageNumber,Integer totalRecords, String sortBy, String sortDirection){
        System.debug('sorting '+sortBy+ ' and '+sortDirection);
        if(sortBy == 'SaraReportURL'){
            sortBy = 'Name';
        }
        List<QC_Tracker_Result__c> qcTrackerList = new List<QC_Tracker_Result__c>();
        List<QC_Tracker_Result__c> activeQcTrackerList = new List<QC_Tracker_Result__c>();
        Set<String> qcFieldSet = new Set<String>();
        QCTrackerItemWrapper qctObj =  new QCTrackerItemWrapper();
        String jsonObjItm = '';
        Set<Id> qcTrackerIdSet = new Set<Id>();
        Integer count = 0;
        qcFieldSet = new Set<String>{'Id', 'Name', 'REP_QC_ID__c','REP_QC_Form_Type__c','REP_Author__c','REP_Date_QC_Completed__c','Date_Deleted__c','REP_QC_Completed_By__c','REP_Error_Free__c','REP_QC_URL__c'};
        String whereClause = 'Aggregate_Report__c =:rltdAggRepId AND Date_Deleted__c = null';
        String orderByField = 'REP_Date_QC_Completed__c';
        qcTrackerList = new SLT_QC_Tracker().getActiveQCTrackerRecordsGenView(recordId, qcFieldSet, whereClause, orderByField);
        if(qcTrackerList != null && qcTrackerList.size() > 0){
            for(QC_Tracker_Result__c qcTracker : qcTrackerList){
                qcTrackerIdSet.add(qcTracker.id);
            }
        }
        Integer offset = (pageNumber - 1) * pageSize;
        Integer recordEnd = pageSize * pageNumber;
        if(qcTrackerIdSet != null && qcTrackerIdSet.size() > 0){
            if(totalRecords == 0){
                totalRecords = new SLT_QC_Tracker().getTotalNumberOfRecords(qcTrackerIdSet);
            } 
            qctObj.pageNumber = pageNumber;
            qctObj.pageSize = pageSize;        
            qctObj.recordStart = offset + 1;
            qctObj.recordEnd = totalRecords > recordEnd ? recordEnd : totalRecords;
            qctObj.totalRecords = totalRecords;
            String queryStr = 'SELECT Id, Name, REP_QC_ID__c,REP_QC_Form_Type__c,REP_Author__c,REP_Date_QC_Completed__c,Date_Deleted__c,REP_QC_Completed_By__c,REP_Error_Free__c,REP_QC_URL__c FROM QC_Tracker_Result__c where Id IN : qcTrackerIdSet AND Date_Deleted__c = null ORDER BY '+sortBy+' '+sortDirection+' LIMIT 50000';                                                   
            for(QC_Tracker_Result__c qct : Database.query(queryStr)){
                if(count >= offset && count < qctObj.recordEnd){              
                    activeQcTrackerList.add(qct);
                }
                count++;
            }
            if(activeQcTrackerList.size() > 0){
                qctObj.qcTrackerList = activeQcTrackerList;
            }
            
            jsonObjItm = JSON.serialize(qctObj);
            return jsonObjItm;
        }
        return jsonObjItm;
    }

    public class QCTrackerItemWrapper {       
        public Integer recordStart {get;set;}
        public Integer pageNumber {get;set;}
        public Integer totalRecords {get;set;}
        public Integer recordEnd {get;set;}
        public Integer pageSize {get;set;}       
        public List<QC_Tracker_Result__c> qcTrackerList {get;set;}
    }
}