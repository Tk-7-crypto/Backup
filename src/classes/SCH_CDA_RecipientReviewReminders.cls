/**
 * @Author  : Babita Dadarwal
 * @Name    : SCH_CDA_RecipientReviewReminders
 * @Purpose : This class is used to send reminders for the CDA requets that are in 'Sent for Recipient Review' Status and Language Review Reminders.
 * Created Under CR-11169
 */
global class SCH_CDA_RecipientReviewReminders implements Schedulable {
	global void execute(SchedulableContext sc){
        Datetime batchExecutionTime = System.now();
        system.debug('batchExecutionTime'+batchExecutionTime);
        if(batchExecutionTime.hour() == 1 || Test.isRunningTest()){
            system.debug('batchExecutionTime-1am: '+batchExecutionTime.hour());
            BCH_CDA_RecipientReviewReminders b = new BCH_CDA_RecipientReviewReminders();
		    database.executebatch(b, 1);//Updated by Babita Dadarwal under Issue-11280 
        }
        if(batchExecutionTime.hour() == 12 || Test.isRunningTest()){
            system.debug('batchExecutionTime-12pm: '+batchExecutionTime.hour());
            BCH_CDA_LanguageReviewReminders b = new BCH_CDA_LanguageReviewReminders();
		    database.executebatch(b, 1);//09/19/2022
        }
	}
}