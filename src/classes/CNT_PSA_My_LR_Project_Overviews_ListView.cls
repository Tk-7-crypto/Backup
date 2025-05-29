public with sharing class CNT_PSA_My_LR_Project_Overviews_ListView {
    
    //To get logged in user's LR Project Overviews who have active logged in user's assignment on project of LR Project Overview
    @AuraEnabled(cacheable=true)
    public static String getMyLRProjectOverviews ( Integer pageSize, Integer pageNumber, Integer totalRecords, Boolean toCheckForLoggedInUser ) {
        Set<String> lrFieldSet = new Set<String> {'Id', 'Name', 'Status__c', 'Countries__c', 'Product__c','Product__r.Name', 'Project__c', 'project__r.Name', 'Account__c','Account__r.Name', 'LR_Type__c', 'LR_Review_Period_Frequency__c', 'LR_Review_Period_Start_Date__c', 'LR_Review_Period_stop_Date__c'};
        Set<Id> projectIdsOfAssignments = new Set<Id>();
        Set<String> assignmentFieldSet = new Set<String> {'pse__Project__c'};
        List<pse__Assignment__c> loggedInUserActiveAssignments = new List<pse__Assignment__c>();
        if(toCheckForLoggedInUser){
            loggedInUserActiveAssignments = new SLT_Assignment().getAssignmentByResource(null, 'pse__Resource__r.pse__Salesforce_User__c = \'' + Userinfo.getUserId() + '\' and Active__c = TRUE and pse__Resource__r.RecordType.Name = \'' + CON_PSA.CONTACT_REC_TYPE_IQVIA_USER_CONTACT + '\'', assignmentFieldSet);
        }else{
            loggedInUserActiveAssignments = new SLT_Assignment().getAssignmentByResource(null, 'Active__c = TRUE and pse__Resource__r.RecordType.Name = \'' + CON_PSA.CONTACT_REC_TYPE_IQVIA_USER_CONTACT + '\'', assignmentFieldSet);
        }
        List<LRProjectOverviewsWrapper> lrRecordsFromWrapper = new List<LRProjectOverviewsWrapper>();
        PaginationWithDataWrapper dataObjectWithPageDetails =  new PaginationWithDataWrapper();
        Integer offset;
        Integer recordEnd;
        
        if (loggedInUserActiveAssignments != null && loggedInUserActiveAssignments.size() > 0) {
            for (pse__Assignment__c assignment : loggedInUserActiveAssignments) {
                projectIdsOfAssignments.add(assignment.pse__Project__c);
            }
        }
        if(projectIdsOfAssignments != null  && projectIdsOfAssignments.size() > 0){
            if(pageNumber != null){
                offset = (pageNumber - 1) * pageSize;
                recordEnd = pageSize * pageNumber;
            }
            if( totalRecords == 0 ){
                totalRecords = [SELECT COUNT() from LR_Project_Overview__c where Project__c IN:projectIdsOfAssignments];
            }
            List<LR_Project_Overview__c> lrRecords = new SLT_LR_Project_Overview().getLRProjectOverViewFromProjectIdsForPagination(projectIdsOfAssignments, lrFieldSet, pageSize, offset);
            if (lrRecords != null && lrRecords.size() > 0) {
                for (LR_Project_Overview__c lrRec : lrRecords) {
                    lrRecordsFromWrapper.add(new LRProjectOverviewsWrapper(lrRec));
                }
            }
            //making wrapper of page details and LR records data (LR data is also wrapped by LRProjectOverviewsWrapper)
            dataObjectWithPageDetails.lrRecords = lrRecordsFromWrapper;
            dataObjectWithPageDetails.pageNumber = pageNumber;
            dataObjectWithPageDetails.pageSize = pageSize;        
            dataObjectWithPageDetails.recordStart = offset != null ? offset + 1 : 0;
            dataObjectWithPageDetails.recordEnd = totalRecords >= recordEnd ? recordEnd : totalRecords;
            dataObjectWithPageDetails.totalRecords = totalRecords;
        }
        return JSON.serialize(dataObjectWithPageDetails);
    }
    
    //Wrapper class for LR Project Overview data
    public class LRProjectOverviewsWrapper {
        @AuraEnabled public Id id {get; set;}
        @AuraEnabled public String name {get; set;}
        @AuraEnabled public String status {get; set;}
        @AuraEnabled public String countries {get; set;}
        @AuraEnabled public String productId {get; set;}
        @AuraEnabled public String productName {get; set;}
        @AuraEnabled public String projectId {get; set;}
        @AuraEnabled public String projectName {get; set;}
        @AuraEnabled public String accountId {get; set;}
        @AuraEnabled public String accountName {get; set;}
        @AuraEnabled public String lrType {get; set;}
        @AuraEnabled public String lrReviewPeriodFrequency {get; set;}
        @AuraEnabled public Date lrReviewPeriodStartDate {get; set;}
        @AuraEnabled public Date lrReviewPeriodStopDate {get; set;}
        @AuraEnabled public String lrRecordUrl { get { return this.id != null ? '/lightning/r/' + this.id + '/view' : ''; } }
        @AuraEnabled public String accountUrl { get { return this.accountId != null ? '/lightning/r/' + this.accountId + '/view' : ''; } }
        @AuraEnabled public String productUrl { get { return this.productId != null ? '/lightning/r/' + this.productId + '/view' : ''; } }
        @AuraEnabled public String projectUrl { get { return this.projectId != null ? '/lightning/r/' + this.projectId + '/view' : ''; } }
        
        public LRProjectOverviewsWrapper(LR_Project_Overview__c sObj) {
            this.id = sObj.Id;
            this.name = sObj.Name;
            this.status = sObj.Status__c;
            this.countries = sObj.Countries__c;
            this.productId = sObj.Product__c;
            this.productName = sObj.Product__r != null ? sObj.Product__r.Name : '';
            this.projectId = sObj.Project__c;
            this.projectName = sObj.Project__r != null ? sObj.Project__r.Name : '';
            this.accountId = sObj.Account__c;
            this.accountName = sObj.Account__r != null ? sObj.Account__r.Name : '';
            this.lrType = sObj.LR_Type__c;
            this.lrReviewPeriodFrequency = sObj.LR_Review_Period_Frequency__c;
            this.lrReviewPeriodStartDate = sObj.LR_Review_Period_Start_Date__c;
            this.lrReviewPeriodStopDate = sObj.LR_Review_Period_stop_Date__c;
        }
    }
    
    public class PaginationWithDataWrapper {       
        public Integer recordStart {get;set;}
        public Integer pageNumber {get;set;}
        public Integer totalRecords {get;set;}
        public Integer recordEnd {get;set;}
        public Integer pageSize {get;set;}       
        public List<LRProjectOverviewsWrapper> lrRecords {get;set;}
    }
}
 
