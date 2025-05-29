/*
 * UTL_PSA_AppLog
 *
 * Provides a convenient logging utility wrapper for App Log records
 * (appirio_core__App_Log__c)
 *
 * Revisions    2019-May  cld      Initial version
 */
public class UTL_PSA_AppLog {
	/* Constant for ERROR LEVEL app log records */
	public static final Integer APP_LOG_ERROR_LEVEL = 2;

	/*
	 * Generates and saves an error app log entry for a specific origin and exception.
	 *
	 *  {origin} - String value for where exception occurred
	 *  {error} - Exception to log!
	 *
	 * Example:
	 *     UTL_PSA_AppLog.writeError('Origin', someCaughtException)
	 */
	public static appirio_core__App_Log__c writeError (String origin, Exception error) {
		return writeError(origin, null, error);
	}

	/*
	 * Generates and saves an error app log entry for a specific origin and exception.
	 *
	 *  {origin} - String value for where exception occurred
	 *  {message} - String value for error message
	 *  {error} - Exception to log!
	 *
	 * Example:
	 *     UTL_PSA_AppLog.writeError('Origin', 'optional error message', someCaughtException)
	 */
	public static appirio_core__App_Log__c writeError (String origin, String message, Exception error) {
		return writeError(origin, message, error, null);
	}
	/*
	 * Generates and saves an error app log entry for a specific origin and exception.
	 *
	 *  {origin} - String value for where exception occurred
	 *  {message} - String value for error message
	 *  {error} - Exception to log!
	 *  {data2} - extra data to log to appirio_core__Data2__c field
	 *
	 * Example:
	 *     UTL_PSA_AppLog.writeError('Origin', 'error message', someCaughtException, 'extra data to log!')
	 */
	public static appirio_core__App_Log__c writeError (String origin, String message, Exception error, String data2) {
		String errMsg = error != null ? error.getMessage() : 'undefined';
		try {
			String errData = String.join(new String[] {
					errMsg,
					error.getLineNumber() != null ? String.valueOf(error.getLineNumber()) : '',
					error.getStackTraceString() != null ? error.getStackTraceString() : '',
					error.getCause() != null ? String.valueOf(error.getCause()) : ''
					}, ' - ');

			String logMsg = String.isNotEmpty(message) ? message : errMsg;
			appirio_core__App_Log__c  appLog = writeLog(origin, APP_LOG_ERROR_LEVEL, logMsg.left(255), errData.left(32000), false);
			if (String.isNotEmpty(data2)) {
				appLog.appirio_core__Data2__c = data2.left(32000);
			}
			Database.insert(appLog);
			return appLog;

		} catch(Exception e) {
			throw new UTL_PSA_AppLogException('Error perisisting app log for [' + errMsg + '] ' + e );
		}
	}

	/*
	 * Generates and saves an error app log entry for a specific list of database errors
	 *
	 *  {origin} - String value for where exception occurred
	 *  {errors} - Database.Error[] to log
	 *
	 * Example:
	 *     UTL_PSA_AppLog.writeError('Origin',  listofDatabaseErrors)
	 */
	public static appirio_core__App_Log__c writeError (String origin,  Database.Error[] errors) {
		return writeError(origin, null, errors);
	}

	/*
	 * Generates and saves an error app log entry for a specific list of database errors
	 *
	 *  {origin} - String value for where exception occurred
	 *  {message} - String value for error message
	 *  {errors} - Database.Error[] to log
	 *
	 * Example:
	 *     UTL_PSA_AppLog.writeError('Origin', 'optional error message', listofDatabaseErrors)
	 */
	public static appirio_core__App_Log__c writeError (String origin, String message, Database.Error[] errors) {
		return writeError(origin, message, errors, true);
	}

	/*
	 * Generates and saves an error app log entry for a specific list of database errors
	 *
	 *  {origin} - String value for where exception occurred
	 *  {message} - String value for error message
	 *  {errors} - Database.Error[] to log
	 *  {doInsert} - when true inserts the record when false lets calling program insert record
	 *
	 * Return new appirio_core__App_Log__c instance
	 */
	public static appirio_core__App_Log__c writeError (String origin, String message, Database.Error[] errors, Boolean doInsert) {
		try {
			String[] errData = new String[]{};
			for(Database.Error err : errors) {
				errData.add(err.getStatusCode() + ':' + err.getMessage() + ':' + err.getFields());
			}
			String errDataStr = String.join(errData, ' - ');
			String logMsg = message != null ? message : errDataStr;
			return writeLog(origin, APP_LOG_ERROR_LEVEL, logMsg.left(255), errDataStr.left(32000), doInsert);
		} catch(Exception e) {
			throw new UTL_PSA_AppLogException('Error perisisting app log for [' + errors + '] ' + e );
		}
	}

	/*
	 * Initializes and creates an appirio_core__App_Log__c record at the default APP LOG ERROR LEVEL
	 *
	 *  {origin} - String value for origin (255 max)
	 *  {errorMessageAndData} - String value for error message (trimmed to 255 chars) and error data
	 *
	 * Return new appirio_core__App_Log__c instance
	 */
    public static appirio_core__App_Log__c writeLog (String origin, String errorMessageAndData) {
        return writeLog(origin, APP_LOG_ERROR_LEVEL, errorMessageAndData);
    }

	/*
	 * Initializes and creates an appirio_core__App_Log__c record
	 *
	 *  {origin} - String value for origin (255 max)
	 *  {level} - dobule value for level
	 *  {errorMessageAndData} - String value for error message (trimmed to 255 chars) and error data
	 *
	 * Return new appirio_core__App_Log__c instance
	 */
	public static appirio_core__App_Log__c writeLog (String origin, Double level, String errorMessageAndData) {
		return writeLog(origin, level, errorMessageAndData, errorMessageAndData, true);
	}

	/*
	 * Initializes and creates an appirio_core__App_Log__c record
	 *
	 *  {origin} - String value for origin (255 max)
	 *  {level} - dobule value for level
	 *  {errorMessage} - String value for error message (255 max)
	 *  {errorData} - String value for error data (32000 max)
	 *
	 * Return new appirio_core__App_Log__c instance
	 */
	public static appirio_core__App_Log__c writeLog (String origin, Double level, String errorMessage, String errorData) {
		return writeLog(origin, level, errorMessage, errorData, true);
	}

	/*
	 * Initializes and creates an appirio_core__App_Log__c record
	 *
	 *  {origin} - String value for origin (255 max)
	 *  {level} - dobule value for level
	 *  {errorMessage} - String value for error message (255 max)
	 *  {errorData} - String value for error data (32000 max)
	 *  {doInsert} - when true inserts the record when false lets calling program insert record
	 *
	 * Return new or inserted appirio_core__App_Log__c instance
	 */
	public static appirio_core__App_Log__c writeLog (String origin, Double level, String errorMessage, String errorData, Boolean doInsert) {
		appirio_core__App_Log__c appLog = new appirio_core__App_Log__c(
			appirio_core__Message__c = errorMessage.left(255),
			appirio_core__Level__c = level,
			appirio_core__Data__c = errorData.left(32000),
			appirio_core__Origin__c = origin
		);
		if (doInsert) {
			insert appLog;
		}
		return appLog;
	}

    /* Raised on error */
    public class UTL_PSA_AppLogException extends Exception {}
}
