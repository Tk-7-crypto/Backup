/*****************************************************
Author:  Rajendra Prakash Gupta
Purpose: Schedulaer to send a Renewal mail to vendor
ER No.:  Issue-12287
*****************************************************/
global class SCH_TPA_Send_AMA_Renew_Notice_Annu implements Schedulable {
    global void execute(SchedulableContext SC) {
    	Database.executeBatch(new BCH_TPA_Send_AMA_Renewal_Mail_Annua(), 1);
    }
}