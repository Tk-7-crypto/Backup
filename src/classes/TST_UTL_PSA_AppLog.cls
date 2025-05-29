/*
 * TST_UTL_PSA_AppLog
 *
 * Providing proofs for the UTL_PSA_AppLog implementation
 *
 * Revisions    2019-May  cld      Initial version
 */
@isTest
private with sharing class TST_UTL_PSA_AppLog {
@isTest static void itWritesErrorsToLog() {
	// create an exception to log
	Exception caughtException = null;
	try {
		String nullpointerexc;
		nullpointerexc.left(20);         //  trigger null pointer exception
	} catch (Exception e) {
		caughtException = e;
	}
	system.assertNotEquals(null, caughtException);

	// stub up db errors (attempt to update a new account)
	Database.SaveResult saveResult = Database.update(new Account(), false);
	system.assert (!saveResult.isSuccess());
	Database.Error[] databaseErrors = saveResult.getErrors();
	system.assert (databaseErrors != null && databaseErrors.size() > 0);

	Test.startTest();

	// ensure it raises error with bogus input!
	Boolean errorRaised = false;
	try {
		Exception invalidException = null;
		UTL_PSA_AppLog.writeError('UTL_PSA_AppLogTest,itWritesErrorsToLog', invalidException);
	} catch (UTL_PSA_AppLog.UTL_PSA_AppLogException e) {
		errorRaised = true;
	}
	system.assertEquals(true, errorRaised, 'Expected an error to have been raised which was not');

	errorRaised = false;
	try {
		Database.Error[] invalidErrors = null;
		UTL_PSA_AppLog.writeError('UTL_PSA_AppLogTest,itWritesErrorsToLog', null, invalidErrors);
	} catch (UTL_PSA_AppLog.UTL_PSA_AppLogException e) {
		errorRaised = true;
	}
	system.assertEquals(true, errorRaised, 'Expected an error to have been raised which was not');

	// cover writing the error (on success)
	appirio_core__App_Log__c logItem = UTL_PSA_AppLog.writeError('UTL_PSA_AppLogTest,itWritesErrorsToLog', caughtException);
	appirio_core__App_Log__c logItem2 = UTL_PSA_AppLog.writeError('UTL_PSA_AppLogTest,itWritesErrorsToLog', databaseErrors);
	appirio_core__App_Log__c logItem3 = UTL_PSA_AppLog.writeLog('UTL_PSA_AppLogTest,itWritesErrorsToLog', 'testing logging error message!');

	Test.stopTest();

	// verify log item exists
	appirio_core__App_Log__c loggedItem = [select id, appirio_core__Origin__c from appirio_core__App_Log__c where id =:logItem.id];
	system.assertNotEquals(null, loggedItem);
	system.assertEquals(loggedItem.appirio_core__Origin__c, logItem.appirio_core__Origin__c);
}
}