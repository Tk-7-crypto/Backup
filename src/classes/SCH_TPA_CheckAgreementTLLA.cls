global class SCH_TPA_CheckAgreementTLLA implements Schedulable {
    global void execute(SchedulableContext SC) {
        TPA_Settings__c objSetting = TPA_Settings__c.getInstance();
        List<AsyncApexJob> lstApexJob = new List<AsyncApexJob>();
        lstApexJob = [select id, ApexClassID, Status FROM AsyncApexJob WHERE JobType='BatchApex' and ApexClassID =:objSetting.TLLA_Batch_Class_Id__c and status in ('Processing', 'Holding', 'Queued', 'Preparing')];
        if(lstApexJob.size() == 0){
            Database.executebatch(new BCH_TPA_CheckAgreementTLLA(), 1);  
        }
        if(!Test.isRunningTest())
            SCH_TPA_CheckAgreementTLLA.start();
        System.abortJob( SC.getTriggerId() );
    }

    public static void start() {
        TPA_Settings__c objTPASetting = TPA_Settings__c.getInstance();
        // start keepalive again in 10 mins
        Datetime sysTime = System.now().addSeconds( Integer.valueOf(objTPASetting.TLLA_Batch_Execution_Time__c) );      
        String chronExpression = '' + sysTime.second() + ' ' + sysTime.minute() + ' ' + sysTime.hour() + ' ' + sysTime.day() + ' ' + sysTime.month() + ' ? ' + sysTime.year();
        System.schedule( 'SCH_TPA_CheckAgreementTLLA Job in 10 mins' + sysTime, chronExpression, new SCH_TPA_CheckAgreementTLLA() );
    }
}