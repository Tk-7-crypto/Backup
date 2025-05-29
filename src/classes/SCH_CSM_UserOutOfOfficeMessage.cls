global class SCH_CSM_UserOutOfOfficeMessage implements Schedulable{
    global void execute(SchedulableContext SC) {
        Integer numberOfRunningBatch = [SELECT Count() FROM AsyncApexJob Where Status = 'Processing' And JobType = 'BatchApex'];
        if(numberOfRunningBatch < 5) {
            BCH_CSM_UserOutOfOfficeMessage userOutOfOfficeBatch = new BCH_CSM_UserOutOfOfficeMessage();
            DataBase.executeBatch(userOutOfOfficeBatch, 1);  
        } 
    }
}