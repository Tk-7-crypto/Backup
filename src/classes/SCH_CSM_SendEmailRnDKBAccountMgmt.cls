global class SCH_CSM_SendEmailRnDKBAccountMgmt  implements Schedulable {
    global void execute(SchedulableContext SC) {
        BCH_CSM_SendEmailRnDKBAccountMgmt batch = new BCH_CSM_SendEmailRnDKBAccountMgmt();
        database.executeBatch(batch, 200);
    }

}