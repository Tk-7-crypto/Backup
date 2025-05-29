/*
* Version : 1.0
* Description: Apex Controller for BatchException Event.
*/
public class TGRH_CRM_BatchApexErrorEvent {
    
    private static String  FIELD_EMAIL_RECIPIENT= 'Email_Recipient_';
    private static String  FIELD_CUSTOM_POSTFIX= '__c';
    private static String  TRACK_DEFAULT= 'Default';
    private static Map<String, List<String>> trackToEmailsMap = new Map<String, List<String>>();
    static {
        List<BatchEmailRecipient__mdt> batchErrorRecipientList = BatchEmailRecipient__mdt.getAll().values() ;
        for (BatchEmailRecipient__mdt recipient : batchErrorRecipientList) {
            String track = recipient.Track__c;
            if (!trackToEmailsMap.containsKey(track)) {
                trackToEmailsMap.put(track, new List<String>());
            }
            trackToEmailsMap.get(track).add(recipient.User_s_Email__c);
        }
	}
    
    /**
     * Logs batch exceptions by receiving a list of BatchApexErrorEvent
     * and inserting corresponding BatchException__c records.
     * 
     * @param errorEvents List of BatchApexErrorEvent to process.
     */
    public static void logBatchExceptions(List<BatchApexErrorEvent> errorEvents) {
																
        List<BatchException__c> batchExceptions = getBatchExceptionInstances(errorEvents);
										   
								 
        if(batchExceptions.size() > 0){
                fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork( new Schema.SObjectType[]{ BatchException__c.SobjectType });
                uow.registerNew(batchExceptions);
                uow.commitWork();
           }
    }
    
    /**
     * Retrieves a map of AsyncApexJob records keyed by their IDs.
     * 
     * @param errorEvents List of BatchApexErrorEvent containing AsyncApexJobIds.
     * @return Map of AsyncApexJob records keyed by their IDs.
     */
    private static Map<Id, AsyncApexJob> getAsyncApexJobMap(List<BatchApexErrorEvent> errorEvents) {
        Set<Id> jobIds = new Set<Id>();
        for (BatchApexErrorEvent event : errorEvents) {
            jobIds.add(event.AsyncApexJobId);
        }
        
        
        // Query AsyncApexJob records and return as a map
        return new SLT_AsyncApexJobs().Asyncdata(jobIds,New Set<String>{'Id','ApexClassId','ApexClass.Name'});
        
    } 
    
    /**
     * Returns a list of BatchException__c instances from the given BatchApexErrorEvent records.
     * 
     * @param errorEvents List of BatchApexErrorEvent to process.
     * @return List of BatchException__c instances.
     */
    private static List<BatchException__c> getBatchExceptionInstances(List<BatchApexErrorEvent> errorEvents) {
        List<BatchException__c> batchExceptionList = new List<BatchException__c>();
        
        // Get AsyncApexJob records related to the error events
        Map<Id, AsyncApexJob> jobs = getAsyncApexJobMap(errorEvents);
        
        // Create BatchException__c records based on the error events and job information
        for (BatchApexErrorEvent errorEvent : errorEvents) {
            BatchException__c bchExp = new BatchException__c();
            bchExp.AsyncApexJobId__c = errorEvent.AsyncApexJobId;
            bchExp.BatchClassName__c = jobs.get(errorEvent.AsyncApexJobId).ApexClass?.Name;
            bchExp.Exception_Message__c = errorEvent.Message;
            bchExp.ExceptionType__c = errorEvent.ExceptionType;
            bchExp.JobScope__c = errorEvent.JobScope;
            bchExp.Phase__c = errorEvent.Phase;
            bchExp.StackTrace__c = errorEvent.StackTrace;
            Integer counter = 1;
            for(String tack : trackToEmailsMap.keySet()) {
                if(bchExp.BatchClassName__c?.toUpperCase().contains(tack.toUpperCase())) {
                    for(String emailAddress : trackToEmailsMap.get(tack)) {
                        bchExp.put(FIELD_EMAIL_RECIPIENT + counter + FIELD_CUSTOM_POSTFIX, emailAddress);
                        counter++;
                    }
                }if(tack.equals(TRACK_DEFAULT)){
                    for(String emailAddress : trackToEmailsMap.get(tack)) {
                        bchExp.put(FIELD_EMAIL_RECIPIENT + counter + FIELD_CUSTOM_POSTFIX, emailAddress);
                        counter++;
                    } 
                }
            }
            
            batchExceptionList.add(bchExp); 
        }
        return batchExceptionList; 
    }
}