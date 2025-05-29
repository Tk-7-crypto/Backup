/**
 * Test class for the Event Domain Helper Utility
 *
 * ----------------------------------------------------------------------------
 * Date Modified             Modified By             Description of the update
 * ----------------------------------------------------------------------------
 * 22 May 2020               CLD                 		 Initial Version
 */
@isTest
private class TST_UTL_EventDomainHelper {

  @isTest
  static void tstUtilEventDomainHelper() {
    // initialize CDC!
    Test.enableChangeDataCapture();

    Test.startTest();

    // insert a project task object
    insert UTL_PSA_TestData.createProjectTaskTestSubject();

    // Trigger CDC Event (and event domain helper utility)
    Test.getEventBus().deliver();

    Test.stopTest();
  }


}