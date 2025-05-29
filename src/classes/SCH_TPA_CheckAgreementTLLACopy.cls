global class SCH_TPA_CheckAgreementTLLACopy implements Schedulable {
    global void execute(SchedulableContext SC) {
        TPA_Settings__c objSetting = TPA_Settings__c.getInstance();
        List<AsyncApexJob> lstApexJob = new List<AsyncApexJob>();
        lstApexJob = [select id, ApexClassID, Status FROM AsyncApexJob WHERE JobType='BatchApex' and ApexClassID =:objSetting.TLLA_Batch_Class_Id__c and status in ('Processing', 'Holding', 'Queued', 'Preparing')];
        if(lstApexJob.size() == 0){
            Database.executebatch(new BCH_TPA_CheckAgreementTLLA(), 1);  
        }
    }
}