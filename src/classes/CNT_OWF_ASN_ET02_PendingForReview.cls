public class CNT_OWF_ASN_ET02_PendingForReview {
    public Id recordId;
    public AssignmentWrapper assignmentWrapper{get; set;}
    public String unityLink{get; set;}
    public String assignmentLink{get; set;}
    public Set<Id> recordIdsSet{get; set;}
    public Id getRecordId()
    {
        return recordId;
    }
    public void setRecordId(Id incomingId)
    {
        if(incomingId!=null)
        {
            recordId = incomingId;
            fetchfieldsAndInitializeObject(recordId);   
        }        
    }
    
    public CNT_OWF_ASN_ET02_PendingForReview(){
        recordIdsSet = new Set<Id>();
    }
    
    public void fetchfieldsAndInitializeObject(Id recordId){
        If(recordId != null) {
        recordIdsSet.add(recordId);
        Set<String> assignmentFieldSet = new Set<String>{'Owner.Name','Opportunity_Number__c','Opportunity_Name__c','Account_Name__c',
            'Budget_Deliverable__c','Resource_Request_Type__c','Therapy_Area__c','Indication__c','Base_URL__c','Agreement_Record_Id__c',
            'Suggested_FTE__c','RFP_Ranking__c','pse__Start_Date__c','pse__End_Date__c','Bid_History__r.Unity_Living_Proposal__c', 'Bid_History__r.Bid_Due_Date__c', 'pse__Resource__r.Name', 'pse__Resource_Request__r.pse__Notes__c',
            'Bid_History__r.Requested_Agreement_Type__c','Bid_History__r.Name','Bid_History__r.Legacy_Quintiles_Opportunity_Number__c','Lookup_Opportunity_Name__c','Bid_History__r.Date_Tracking_Started__c','Bid_History__r.Description_Of_Request__c',
            'Bid_History__r.Project_Manager_Name__c','Bid_History__r.Project_Leader_Region__c','Bid_History__r.IQVIA_Project_Lead_Name__c','Bid_History__r.IQVIA_Project_Leader_Region__c','Lookup_Opportunity_Name__c',
            'Bid_History__r.Bid_History_Related_Opportunity__r.AccountId','Bid_History__c'};
        String assignmentCondition = 'Id = \''+recordId+'\'';
        pse__Assignment__c assignment = new SLT_Assignment(false,false).selectAssignmentsByIdSet(recordIdsSet, assignmentCondition, assignmentFieldSet).values()[0];
        assignmentWrapper = new AssignmentWrapper(assignment);
        if(assignment.Bid_History__r.Unity_Living_Proposal__c != null){
            unityLink = assignment.Bid_History__r.Unity_Living_Proposal__c;
        } else {
            unityLink = 'No Unity Link Available';
        }
        assignmentLink = URL.getOrgDomainUrl().toExternalForm()+'/'+assignment.Id;
        }
    }
    
    public class AssignmentWrapper{
        public String ownerName{get; set;}
        public String oppNumber{get; set;}
        public String oppName{get; set;}
        public String accountName{get; set;}
        public String budgetDeliverable{get; set;}
        public String resourceRequestType{get; set;}
        public String therapyArea{get; set;}
        public String indication{get; set;}
        public String baseUrl{get; set;}
        public String oppId{get; set;}
        public String agreementRecordId{get; set;}
        public Double suggestedFTE{get; set;}
        public String rfpRanking{get; set;}
        public Date startDate{get; set;}
        public Date endDate{get; set;}
        public String notes{get; set;}
        public String resourceName{get; set;}
        public Date bidDueDate{get; set;}
        public String requestedAgreementType{get; set;}
        public String bidName{get; set;}
        public String legacyQuantilesOppNumber{get;set;}
        public Date dateTrackingStarted{get; set;}
        public String descriptionOFRequest{get; set;}
        public String pLName{get;set;}
        public String pLRegion{get;set;}
        public String accountId{get;set;}
        public String bidId{get;set;}
        
        public AssignmentWrapper(pse__Assignment__c assignment){
            ownerName = assignment.Owner.Name;
            oppNumber =assignment.Opportunity_Number__c;
            oppName=assignment.Opportunity_Name__c;
            accountName=assignment.Account_Name__c;
            budgetDeliverable=assignment.Budget_Deliverable__c;
            resourceRequestType=assignment.Resource_Request_Type__c;
            therapyArea=assignment.Therapy_Area__c;
            indication=assignment.Indication__c;
            baseUrl=assignment.Base_URL__c;
            agreementRecordId=assignment.Agreement_Record_Id__c;
            suggestedFTE=assignment.Suggested_FTE__c;
            rfpRanking=assignment.RFP_Ranking__c;
            startDate=assignment.pse__Start_Date__c;
            endDate=assignment.pse__End_Date__c;
            notes=assignment.pse__Resource_Request__r.pse__Notes__c;
            resourceName = assignment.pse__Resource__r.Name;
            bidDueDate = assignment.Bid_History__r.Bid_Due_Date__c;
            requestedAgreementType = assignment.Bid_History__r.Requested_Agreement_Type__c;
            bidName = assignment.Bid_History__r.Name;
            oppId = assignment.Lookup_Opportunity_Name__c;
            legacyQuantilesOppNumber = assignment.Bid_History__r.Legacy_Quintiles_Opportunity_Number__c;
            dateTrackingStarted = assignment.Bid_History__r.Date_Tracking_Started__c;
            descriptionOFRequest = assignment.Bid_History__r.Description_Of_Request__c;
            accountId = assignment.Bid_History__r.Bid_History_Related_Opportunity__r.AccountId;
            bidId = assignment.Bid_History__c;
            if(assignment.Bid_History__r.Project_Manager_Name__c != Null && assignment.Bid_History__r.Project_Leader_Region__c != Null){
                pLName = assignment.Bid_History__r.Project_Manager_Name__c;
                pLRegion = assignment.Bid_History__r.Project_Leader_Region__c;
            }
            else{
                 pLName = assignment.Bid_History__r.IQVIA_Project_Lead_Name__c;
                 pLRegion = assignment.Bid_History__r.IQVIA_Project_Leader_Region__c;
            }
        }
    }
}