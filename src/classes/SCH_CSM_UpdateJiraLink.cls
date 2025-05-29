global class SCH_CSM_UpdateJiraLink  implements Schedulable {
    global void execute(SchedulableContext ctx) {
        BCH_CSM_UpdateJiraLink batch = new BCH_CSM_UpdateJiraLink();
        database.executeBatch(batch,1);
 	}
}