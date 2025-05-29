global class SCH_CSM_CSHUserLoginCheck implements Schedulable {
    global void execute(SchedulableContext SC) {
        BCH_CSM_CSHUserLoginCheck batch = new BCH_CSM_CSHUserLoginCheck();
        if(!Test.isRunningTest()){
            database.executeBatch(batch, 1);
        }else{
            database.executeBatch(batch);
        }
    }

    public static void scheduleJob(String jobName, String cron_exp){
        SCH_CSM_CSHUserLoginCheck scheduler = new SCH_CSM_CSHUserLoginCheck();
        System.schedule(jobName, cron_exp, scheduler);
    }
}