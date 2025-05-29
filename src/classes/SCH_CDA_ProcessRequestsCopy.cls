global class SCH_CDA_ProcessRequestsCopy implements Schedulable {

	global void execute(SchedulableContext sc) {
        List<AsyncApexJob> apexJobList = new List<AsyncApexJob>();
        apexJobList = [select id, ApexClassID, Status FROM AsyncApexJob WHERE JobType='BatchApex' and ApexClassID =:UTL_CDAUtility.processRequestBatchClassId and status in ('Processing', 'Holding', 'Queued', 'Preparing')];
        if(apexJobList.size() == 0) {
            BCH_CDA_ProcessRequests agrmntsUpdate= new BCH_CDA_ProcessRequests();
            Database.executebatch(agrmntsUpdate,1);
        }
	}
}