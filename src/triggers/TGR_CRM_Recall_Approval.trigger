trigger TGR_CRM_Recall_Approval on Recall_Approval__e (after insert) {
    for(Recall_Approval__e recallApproval : Trigger.new){
        List<ProcessInstanceWorkitem> piwi = [SELECT Id, ProcessInstanceId, ProcessInstance.TargetObjectId FROM ProcessInstanceWorkitem WHERE ProcessInstance.TargetObjectId =: recallApproval.recordId__c];
        Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest();
        req.setAction('Removed');
        if(String.isNotBlank(recallApproval.Comment__c)){
            req.setComments(recallApproval.Comment__c + '\n Recalled by '+ recallApproval.Recall_User_Name__c);
        }else {
            req.setComments('Recalled by '+ recallApproval.Recall_User_Name__c);
        }
        req.setWorkitemId(piwi.get(0).Id);
        Approval.ProcessResult result = Approval.process(req,true);
    }
}