global class SCH_CRM_DeleteTimeTrackingRecords implements Schedulable {
	global void execute(SchedulableContext sc){
         BCH_CRM_DeleteTimeTrackingRecords deleteBatch = new BCH_CRM_DeleteTimeTrackingRecords();
         Database.executebatch(deleteBatch);
	}
}