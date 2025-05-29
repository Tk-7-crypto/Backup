/**
* This trigger is used for BatchApexErrorEvent object.
* version : 1.0
*/
trigger TGR_CRM_BatchApexErrorEvent on BatchApexErrorEvent (after insert) {
	TGRH_CRM_BatchApexErrorEvent.logBatchExceptions(Trigger.new);
}