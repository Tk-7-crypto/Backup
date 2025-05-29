/**
 * @Author  : Babita Dadarwal
 * @Name    : SCH_CDA_New_CDA_Account_Report
 * @Purpose : This class is used to send weekly new CDA accounts report.
 */
global class SCH_CDA_New_CDA_Account_Report implements Schedulable {
	global void execute(SchedulableContext sc) {
		CNT_CDA_New_CDA_Accounts_Report contObj = new CNT_CDA_New_CDA_Accounts_Report();
        contObj.sendWeeklyNewCdaAccountsReport();
	}
}