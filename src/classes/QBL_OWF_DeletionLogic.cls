/**
* This class contains Queuable Sub Class 
*/
public class QBL_OWF_DeletionLogic {
    
    /**
     * This queuable sub class delete Agreement
     */
    public class QueueAgreementDeletion implements Queueable {
        public List<Bid_History__c> deletedAgreementList{get;set;}
        public Map<Id, String> agreementIdToErrorMessageMap{get;set;}
        public QueueAgreementDeletion(List<Bid_History__c> recordList){
            deletedAgreementList = recordList;
            agreementIdToErrorMessageMap = new Map<Id, String>();
        }
        /**
     	* This overridden method used to deletion Agreement 
     	*/ 
        public void execute(QueueableContext context) {
            //delete deletedAgreementList;
            Database.DeleteResult[] drList = Database.delete(deletedAgreementList, false);
            if (drList.size() > 0){
                for (Integer i=0; i< drList.size(); i++){
                    if (!drList[i].isSuccess()){
                        agreementIdToErrorMessageMap.put(deletedAgreementList[i].Id, 'Error in Agreement deletion through queuable job: ' + drList[i].getErrors()[0].getMessage());
                    }
                }
            }
            
            if (agreementIdToErrorMessageMap.size() > 0 || Test.isRunningTest()){
                UTL_OWF.createApexErrorLogs('Bid/Agreement (Bid_History__c)', 'Error in Agreement deletion through queuable job: ', agreementIdToErrorMessageMap);
            }
        }
    }
    
    /**
     * This queuable sub class delete Project
     */
    public class QueueProjectDeletion implements Queueable{
        public List<pse__Proj__c> deletedProjectList{get;set;}
        public Map<Id, String> projectIdToErrorMessageMap{get;set;}
        public QueueProjectDeletion(List<pse__Proj__c> recordList){
            deletedProjectList = recordList;
            projectIdToErrorMessageMap = new Map<Id, String>();
        }
        /**
     	* This overridden method used to deletion Project 
     	*/ 
        public void execute(QueueableContext context) {
            //delete deletedProjectList;
            Database.DeleteResult[] drList = Database.delete(deletedProjectList, false);
            if (drList.size() > 0){
                for (Integer i=0; i< drList.size(); i++){
                    if (!drList[i].isSuccess()){
                        projectIdToErrorMessageMap.put(deletedProjectList[i].Id, 'Error in Project deletion through queuable job: ' + drList[i].getErrors()[0].getMessage());
                    }
                }
            }
            
            if (projectIdToErrorMessageMap.size() > 0 || Test.isRunningTest()){
                UTL_OWF.createApexErrorLogs('Project (pse__Proj__c)', 'Error in Project deletion through queuable job: ', projectIdToErrorMessageMap);
            }
        }
    }
    
    /**
     * This queuable sub class delete Resource Request
     */
    public class QueueResourceRequestDeletion implements Queueable{
        public List<pse__Resource_Request__c> deletedResourceRequestList{get;set;}
        public Map<Id, String> resourceRequestIdToErrorMessageMap{get;set;}
        public QueueResourceRequestDeletion (List<pse__Resource_Request__c> recordList){
            deletedResourceRequestList = recordList;
            resourceRequestIdToErrorMessageMap = new Map<Id, String>();
        }
        /**
     	* This overridden method used to deletion Resource Request 
     	*/ 
        public void execute(QueueableContext context) {
            //delete deletedResourceRequestList;
            Database.DeleteResult[] drList = Database.delete(deletedResourceRequestList, false);
            if (drList.size() > 0){
                for (Integer i=0; i< drList.size(); i++){
                    if (!drList[i].isSuccess()){
                        resourceRequestIdToErrorMessageMap.put(deletedResourceRequestList[i].Id, 'Error in Resource Request deletion through queuable job: ' + drList[i].getErrors()[0].getMessage());
                    }
                }
            }
            
            if (resourceRequestIdToErrorMessageMap.size() > 0 || Test.isRunningTest()){
                UTL_OWF.createApexErrorLogs('Resource Request (pse__Resource_Request__c)', 'Error in Resource Request deletion through queuable job: ', resourceRequestIdToErrorMessageMap);
            }
        }
    }
    
    /**
     * This queuable sub class delete Opportunity
     */
    public class QueueOpportunityDeletion implements Queueable{
        public List<Opportunity> deletedOpportunityList{get;set;}
        public Map<Id, String> opportunityIdToErrorMessageMap{get;set;}
        public QueueOpportunityDeletion(List<Opportunity> recordList){
            deletedOpportunityList = recordList;
            opportunityIdToErrorMessageMap = new Map<Id, String>();
        }
        /**
     	* This overridden method used to deletion Opportunity 
     	*/ 
        public void execute(QueueableContext context) {
            //delete  deletedOpportunityList;
            Database.DeleteResult[] drList = Database.delete(deletedOpportunityList, false);
            if (drList.size() > 0){
                for (Integer i=0; i< drList.size(); i++){
                    if (!drList[i].isSuccess()){
                        opportunityIdToErrorMessageMap.put(deletedOpportunityList[i].Id, 'Error in Opportunity deletion through queuable job: ' + drList[i].getErrors()[0].getMessage());
                    }
                }
            }
            
            if (opportunityIdToErrorMessageMap.size() > 0 || Test.isRunningTest()){
                UTL_OWF.createApexErrorLogs('Opportunity (Opportunity)', 'Error in Opportunity deletion through queuable job: ', opportunityIdToErrorMessageMap);UTL_OWF.createApexErrorLogs('Opportunity (Opportunity)', 'Error in Opportunity deletion through queuable job: ', opportunityIdToErrorMessageMap);
            }
        }
    }
    
     /**
     * This queuable sub class delete Assignment
     */
    public class QueueAssignmentDeletion implements Queueable{
        public List<pse__Assignment__c> deletedAssignmentList{get;set;}
         public Map<Id, String> assignmentIdToErrorMessageMap{get;set;}
        public QueueAssignmentDeletion(List<pse__Assignment__c> recordList){
            deletedAssignmentList = recordList;
            assignmentIdToErrorMessageMap = new Map<Id, String>();
        }
        /**
     	* This overridden method used to deletion Assignment 
     	*/ 
        public void execute(QueueableContext context) {
            //delete deletedAssignmentList;
            Database.DeleteResult[] drList = Database.delete(deletedAssignmentList, false);
            if (drList.size() > 0){
                for (Integer i=0; i< drList.size(); i++){
                    if (!drList[i].isSuccess()){
                        assignmentIdToErrorMessageMap.put(deletedAssignmentList[i].Id, 'Error in Assignment deletion through queuable job: ' + drList[i].getErrors()[0].getMessage());
                    }
                }
            }
            
            if (assignmentIdToErrorMessageMap.size() > 0 || Test.isRunningTest()){
                UTL_OWF.createApexErrorLogs('Assignment (pse__Assignment__c)', 'Error in Assignment deletion through queuable job: ', assignmentIdToErrorMessageMap);
            }
            
        }
    }
}