/**
 * @Author  : CLD Partners
 * @Purpose : Upsert resource requests for a newly created or modified PSA project
 */
public class QUE_PSA_AddResourceRequestsToProject implements Queueable{
    private static Integer BATCH_SIZE = 20;
    private List<pse__Resource_Request__c> requestList = new List<pse__Resource_Request__c>();

    public QUE_PSA_AddResourceRequestsToProject(List<pse__Resource_Request__c> resourceRequests) {
        system.debug('QUE_PSA_AddResourceRequestsToProject initializing with '+resourceRequests.size()+' requests.');
        this.requestList = resourceRequests;
    }

    public void execute(QueueableContext context) {
        Map<String,pse__Schedule__c> requestToNewScheduleMap = new Map<String,pse__Schedule__c>();
        List<pse__Schedule__c> existingScheduleList = new List<pse__Schedule__c>();

        List<pse__Resource_Request__c> thisBatch = new List<pse__Resource_Request__c>();
        List<pse__Resource_Request__c> nextBatch = new List<pse__Resource_Request__c>();
        for(Integer i = 0; i < this.requestList.size(); i++) {
            pse__Resource_Request__c request = this.requestList.get(i);
            if(i >= BATCH_SIZE){
                nextBatch.add(request);
                continue;
            } else {
                thisBatch.add(request);
            }

            String key = makeRequestKey(request);
            Integer numberOfWorkDays = UTL_OWF.findNoOfDays_exclude_weekend(request.pse__Start_Date__c, request.pse__End_Date__c, 0);
            Decimal hoursPerDay = (numberOfWorkDays == 0) ? 0 : request.pse__SOW_Hours__c / numberOfWorkDays;
            System.debug('Scheduling '+request.pse__SOW_Hours__c+' hours over '+numberOfWorkDays+' work days at '+hoursPerDay+' hours per day.');

            pse__Schedule__c sched = new pse__Schedule__c(
                pse__Start_Date__c=request.pse__Start_Date__c,
                pse__End_Date__c=request.pse__End_Date__c,
                pse__Scheduled_Hours__c=request.pse__SOW_Hours__c,
                pse__Scheduled_Days__c=numberOfWorkDays,
                pse__Monday_Hours__c=hoursPerDay,
                pse__Tuesday_Hours__c=hoursPerDay,
                pse__Wednesday_Hours__c=hoursPerDay,
                pse__Thursday_Hours__c=hoursPerDay,
                pse__Friday_Hours__c=hoursPerDay,
                pse__Sunday_Hours__c=0,
                pse__Saturday_Hours__c=0
            );
            if(request.pse__Preferred_Schedule__c != null){
                sched.Id = request.pse__Preferred_Schedule__c;
                existingScheduleList.add(sched);
            } else {
                requestToNewScheduleMap.put(key,sched);
            }
        }

        //Create user setting to disable utilization temporarily 
        pse__Utilization__c tempSetting = new pse__Utilization__c();
        tempSetting.Name ='Utilization (User)';
        tempSetting.pse__Use_Utilization_Engine__c = false;
        tempSetting.SetupOwnerId = UserInfo.getUserId();
        insert tempSetting;

        if(requestToNewScheduleMap.size() > 0){
            try {
                insert requestToNewScheduleMap.values(); 
            } catch(Exception e){
                delete tempSetting;
                throw new QUE_PSA_AddResourceRequestsToProject_Exception(e);
            }
        }

        if(existingScheduleList.size() > 0){
            try {
                update existingScheduleList;
            } catch(Exception e) {
                delete tempSetting;
                throw new QUE_PSA_AddResourceRequestsToProject_Exception(e);
            }
        }

        for(pse__Resource_Request__c request : thisBatch){
            String key = makeRequestKey(request);
            pse__Schedule__c sched = requestToNewScheduleMap.get(key);
            if(sched != null){
                request.pse__Preferred_Schedule__c = sched.Id;
            }
        }

        try {
            upsert thisBatch;
        } catch(Exception e) {
            delete tempSetting;
            throw new QUE_PSA_AddResourceRequestsToProject_Exception(e);
        }

        delete tempSetting;

        if(nextBatch.size() > 0){
            System.enqueueJob(new QUE_PSA_AddResourceRequestsToProject(nextBatch));
        } 
    }

    private String makeRequestKey(pse__Resource_Request__c request){
        return request.pse__Project__c+':'+request.pse__Resource_Request_Name__c+':'+request.Job_Grade__c+':'+request.Country__c;
    }

    public class QUE_PSA_AddResourceRequestsToProject_Exception extends Exception {}
}