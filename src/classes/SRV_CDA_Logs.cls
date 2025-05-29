/*
*   @author    : Ajinkya
*   This class used for maintaing the logs for application. (created under ER-3556 on 30/05/2017)
*/
public class SRV_CDA_Logs implements LogBase.ICustomLogBase {

	private IMS_Logs__c logToInsertPrvt{get;set;}
	public IMS_Logs__c logToInsert() {
        if(logToInsertPrvt == null) {
			logToInsertPrvt = new IMS_Logs__c();
		}
        return logToInsertPrvt;
    }

    /**
     * Function to create new Log.
     * @param tpa log object that will be inserted in log custom object
     * @return
     */
    public void generateLog() {
		if(logToInsertPrvt != null && UTL_CDAUtility.isTraceCdaLogs) {
			insert logToInsertPrvt;
		}
		logToInsertPrvt = new IMS_Logs__c();
    }
}