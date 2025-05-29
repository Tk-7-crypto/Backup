public class CNT_PSA_Project_Metric_Actual {
    
    @AuraEnabled(cacheable=true)
    public static List<Project_Metric_Actual__c> getProjectMetricActualData(String recordId){
        List<Project_Metric_Actual__c> projectMetricActualList = new List<Project_Metric_Actual__c>();
        Set<String> PMAFieldSet = new Set<String>();
        PMAFieldSet = new Set<String>{'id','name','PSA_Metric__c.Name','Project_Metric__c.Name','Date__c','Quantity__c','Comments__c'};
        projectMetricActualList = new SLT_Project_Metric_Actual().getProjectMetricRecordsFromProjectIdForListView(recordId, PMAFieldSet);
        return projectMetricActualList;
    }
    
    @AuraEnabled(cacheable=false)
    public static  String  getAllRecordsForListView(String  recordId, Integer pageSize, Integer pageNumber,Integer totalRecords){
        List<Project_Metric_Actual__c> projectMetricActualList = new List<Project_Metric_Actual__c>();
        Set<String> PMAFieldSet = new Set<String>();
        ProjectMetricItemWrapper PMAObj =  new ProjectMetricItemWrapper();
        String jsonObjItm = '';
        Set<Id> ProjectMetricIdSet = new Set<Id>();
        PMAFieldSet = new Set<String>{'id','name','PSA_Metric__c.Name','Project_Metric__c.Name','Date__c','Quantity__c','Comments__c'};
        projectMetricActualList = new SLT_Project_Metric_Actual().getAllProjectMetricRecordsFromProjectId(recordId, PMAFieldSet);
        if(projectMetricActualList != null && projectMetricActualList.size() > 0){
            for(Project_Metric_Actual__c projectMetric : projectMetricActualList){
                ProjectMetricIdSet.add(projectMetric.id);
            }
        }
        Integer offset = (pageNumber - 1) * pageSize;
        Integer recordEnd = pageSize * pageNumber;
        if(ProjectMetricIdSet != null && ProjectMetricIdSet.size() > 0){
            if(totalRecords == 0){
                totalRecords = new SLT_Project_Metric_Actual().getTotalNumberOfRecords(ProjectMetricIdSet);
            } 
            PMAObj.pageNumber = pageNumber;
            PMAObj.pageSize = pageSize;        
            PMAObj.recordStart = offset + 1;
            PMAObj.recordEnd = totalRecords >= recordEnd ? recordEnd : totalRecords;
            PMAObj.totalRecords = totalRecords;
            PMAObj.projectMetric = new SLT_Project_Metric_Actual().getProjectMetricByIdsForPagination(ProjectMetricIdSet, PMAFieldSet,pageSize,offset);
            jsonObjItm = JSON.serialize(PMAObj);
            return jsonObjItm;
        }
        return jsonObjItm;
    }
    public class ProjectMetricItemWrapper {       
        public Integer recordStart {get;set;}
        public Integer pageNumber {get;set;}
        public Integer totalRecords {get;set;}
        public Integer recordEnd {get;set;}
        public Integer pageSize {get;set;}       
        public List<Project_Metric_Actual__c> projectMetric {get;set;}
    }
    
    @AuraEnabled(cacheable=false)
    public static List<Project_Metric_Actual__c> delMetricRecords(List<String> selecRecords, String recordId){
        List<Project_Metric_Actual__c> returnlist=new List<Project_Metric_Actual__c>();
        Set<String> PMAFieldSet = new Set<String>();
        PMAFieldSet = new Set<String>{'id','name','PSA_Metric__c.Name','Project_Metric__c.Name','Date__c','Quantity__c','Comments__c'};
        List<Project_Metric_Actual__c> ProjectMetricRecordsDeletionList = new List<Project_Metric_Actual__c>();
        ProjectMetricRecordsDeletionList = new SLT_Project_Metric_Actual().getSelectedRecordsForDeletion(selecRecords,PMAFieldSet);
        if(ProjectMetricRecordsDeletionList != null && ProjectMetricRecordsDeletionList.size() > 0){
            for(Project_Metric_Actual__c rec:ProjectMetricRecordsDeletionList){
                returnlist.add(rec);
            }
        }
        if(returnlist != null && returnlist.size()>0){
            try{
                delete returnlist;
            }
            catch(Exception e){
                throw new AuraHandledException(e.getMessage());
            }
        } 
        return getProjectMetricActualData(recordId);
    }
}