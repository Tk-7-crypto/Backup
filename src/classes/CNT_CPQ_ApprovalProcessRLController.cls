public class CNT_CPQ_ApprovalProcessRLController {
    @AuraEnabled(cacheable=true)
    public static List<WPR_CPQ_Step> getApprovalSteps(Id recordId) {
        List<WPR_CPQ_Step> stepList = new List<WPR_CPQ_Step>();
        Map<Id, ProcessNode> processNodeMap = new Map<Id, ProcessNode>([SELECT Id, Name FROM ProcessNode WHERE ProcessDefinition.DeveloperName = 'Dynamic_Approval']);
        List<ProcessInstanceNode> currentStep = [SELECT ProcessNodeName FROM ProcessInstanceNode WHERE ProcessInstance.TargetObjectId =:recordId  ORDER BY ProcessNodeName DESC LIMIT 1];
        
        List<ProcessInstanceWorkitem> processInstanceWorkItem = [SELECT Id, OriginalActorId, OriginalActor.Name, ActorId, Actor.Name, CreatedDate, ProcessInstance.Status FROM ProcessInstanceWorkitem WHERE ProcessInstance.TargetObjectId =:recordId ORDER BY CreatedDate];
        
        for (ProcessInstanceWorkitem processWorkItem : processInstanceWorkItem) {
            stepList.add(new WPR_CPQ_Step(processWorkItem, currentStep.size() > 0 ? currentStep[0].ProcessNodeName : ''));
        }
        List<ProcessInstancestep> processInstanceList = [SELECT Id, StepStatus, OriginalActorId, OriginalActor.Name, ActorId, Actor.Name, Comments, 
            StepNodeId, CreatedDate FROM ProcessInstancestep WHERE  ProcessInstance.TargetObjectId =:recordId ORDER BY CreatedDate DESC LIMIT 7];
        
        for (ProcessInstancestep step : processInstanceList) {
            stepList.add(new WPR_CPQ_Step(step, processNodeMap.containsKey(step.StepNodeId) ? processNodeMap.get(step.StepNodeId).Name : 'Approval Request Submitted'));
        }
        return stepList;
    }
    @AuraEnabled(cacheable=true)
    public static WPR_CPQ_Details getAllApprovalSteps(Id recordId, String objectApiName) {
        WPR_CPQ_Details detailsObj = new WPR_CPQ_Details();
        List<WPR_CPQ_Step> stepList = new List<WPR_CPQ_Step>();
        Map<Id, ProcessNode> processNodeMap = new Map<Id, ProcessNode>([SELECT Id, Name FROM ProcessNode WHERE ProcessDefinition.DeveloperName = 'Dynamic_Approval']);
        List<ProcessInstanceNode> currentStep = [SELECT ProcessNodeName FROM ProcessInstanceNode WHERE ProcessInstance.TargetObjectId =:recordId  ORDER BY ProcessNodeName DESC LIMIT 1];
        
        List<ProcessInstanceWorkitem> processInstanceWorkItem = [SELECT Id, OriginalActorId, OriginalActor.Name, ActorId, Actor.Name, CreatedDate, ProcessInstance.Status FROM ProcessInstanceWorkitem WHERE ProcessInstance.TargetObjectId =:recordId ORDER BY CreatedDate];
        
        for (ProcessInstanceWorkitem processWorkItem : processInstanceWorkItem) {
            stepList.add(new WPR_CPQ_Step(processWorkItem, currentStep.size() > 0 ? currentStep[0].ProcessNodeName : ''));
        }
        List<ProcessInstancestep> processInstanceList = [SELECT Id, StepStatus, OriginalActorId, OriginalActor.Name, ActorId, Actor.Name, Comments, 
            StepNodeId, CreatedDate FROM ProcessInstancestep WHERE  ProcessInstance.TargetObjectId =:recordId ORDER BY CreatedDate DESC];
        
        for (ProcessInstancestep step : processInstanceList) {
            stepList.add(new WPR_CPQ_Step(step, processNodeMap.containsKey(step.StepNodeId) ? processNodeMap.get(step.StepNodeId).Name : 'Approval Request Submitted'));
        }
        detailsObj.approvalSteps = stepList;
        sObject sObj = Database.query('SELECT Id, Name FROM ' + objectApiName + ' WHERE Id =: recordId');
        if (sObj != null) {
            detailsObj.recordName = (String)sObj.get('Name'); 
        }
        detailsObj.objectLabel = getObjectLabel(objectApiName);
        return detailsObj;
    }
        
    public static String getObjectLabel(String objectApiName) {
        if (objectApiName != null) {
            Schema.SObjectType describeResult = Schema.getGlobalDescribe().get(objectApiName);
            if (describeResult != null) {
                return describeResult.getDescribe().getLabel();
            }
        }
        return null;
    }
        
    public class WPR_CPQ_Step {
        @AuraEnabled
        public Id recordId {get; set;}
        @AuraEnabled
        public String name {get; set;}
        @AuraEnabled
        public DateTime aprDate {get; set;}
        @AuraEnabled
        public String aprDateStr {get; set;}
        @AuraEnabled
        public String status {get; set;}
        @AuraEnabled
        public String assignedToName {get; set;}
        @AuraEnabled
        public String actualApproverName {get; set;}
        @AuraEnabled
        public Id assignedToId {get; set;}
        @AuraEnabled
        public Id actualApproverId {get; set;}
        @AuraEnabled
        public String comment {get; set;}
        public WPR_CPQ_Step(ProcessInstancestep step, String name) {
            this.recordId = step.Id; 
            this.name = name;
            this.status = (step.StepStatus == 'Started' ? 'Submitted' : step.StepStatus);
            this.assignedToId = step.OriginalActorId;
            this.assignedToName = step.OriginalActor.Name;
            this.actualApproverId = step.ActorId;
            this.actualApproverName = step.Actor.Name;
            this.comment = step.Comments;
            this.aprDate = step.CreatedDate;
            this.aprDateStr = step.CreatedDate.format();
        }
        public WPR_CPQ_Step(ProcessInstanceWorkitem processWorkItem, String name) {
            this.recordId = processWorkItem.Id;
            this.name = name;
            this.status = processWorkItem.ProcessInstance.Status;
            this.assignedToId = processWorkItem.OriginalActorId;
            this.assignedToName = processWorkItem.OriginalActor.Name;
            this.actualApproverId = processWorkItem.ActorId;
            this.actualApproverName = processWorkItem.Actor.Name;
            this.aprDate = processWorkItem.CreatedDate;
            this.aprDateStr = processWorkItem.CreatedDate.format();
        }
    }
    public class WPR_CPQ_Details {
        @AuraEnabled
        public String recordName {get; set;}
        @AuraEnabled
        public String objectLabel {get; set;}
        @AuraEnabled
        public List<WPR_CPQ_Step> approvalSteps {get; set;}
    }
}