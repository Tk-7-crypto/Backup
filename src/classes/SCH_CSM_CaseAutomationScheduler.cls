global class SCH_CSM_CaseAutomationScheduler implements Schedulable{

    global void execute(SchedulableContext SC){
        Integer runningBatches = [SELECT Count() FROM AsyncApexJob WHERE Status = 'Processing' And JobType = 'BatchApex'];
        if(runningBatches < 5) {
            BCH_CSM_CaseAutomationScheduler caseAutomationBatch = new BCH_CSM_CaseAutomationScheduler();
            if(!Test.isRunningTest()){
                Database.executeBatch(caseAutomationBatch, 1);
            }else{
                Database.executeBatch(caseAutomationBatch, 200);
            }
            
        }
    }
}