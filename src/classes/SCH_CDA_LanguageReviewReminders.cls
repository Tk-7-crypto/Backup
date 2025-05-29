global class SCH_CDA_LanguageReviewReminders implements Schedulable {

	global void execute(SchedulableContext sc) { 
		BCH_CDA_LanguageReviewReminders b = new BCH_CDA_LanguageReviewReminders();
		database.executebatch(b, 1);
	}
}