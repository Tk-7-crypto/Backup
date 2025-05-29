/**
 * @Author  : Vikram Singh Fartyal (Created Under CR-11525 on 05th Jan 2018)
 * @Purpose : This class is used to run the batch that processes CDA requests in 'Submitted for processing' Status.
 */
global class SCH_CDA_ProcessRequests implements Schedulable {

	global void execute(SchedulableContext sc) {
        List<AsyncApexJob> apexJobList = new List<AsyncApexJob>();
        apexJobList = [select id, ApexClassID, Status FROM AsyncApexJob WHERE JobType='BatchApex' and ApexClassID =:UTL_CDAUtility.processRequestBatchClassId and status in ('Processing', 'Holding', 'Queued', 'Preparing')];
        if(apexJobList.size() == 0) {
            BCH_CDA_ProcessRequests agrmntsUpdate= new BCH_CDA_ProcessRequests();
            Database.executebatch(agrmntsUpdate,1);
        }
        SCH_CDA_ProcessRequests.start();
		System.abortJob( SC.getTriggerId() );
	}

	public static void start() {
        // start keepalive again in 15 mins
        Datetime sysTime = System.now().addSeconds( Integer.valueOf(UTL_CDAUtility.processRequestBatchExecutionTime) );
        String chronExpression = '' + sysTime.second() + ' ' + sysTime.minute() + ' ' + sysTime.hour() + ' ' + sysTime.day() + ' ' + sysTime.month() + ' ? ' + sysTime.year();
        if(!Test.isRunningTest()) {
			System.schedule( 'SCH_CDA_ProcessRequests Job in 15 mins' + sysTime, chronExpression, new SCH_CDA_ProcessRequests() );
		}
    }
}