/**
 * Test class for the Project Task Change Event trigger
 *
 * ----------------------------------------------------------------------------
 * Date Modified             Modified By             Description of the update
 * ----------------------------------------------------------------------------
 * 21 May 2020               CLD                 		 Initial Version
 */
@isTest
private class TST_TGR_Project_Task_ChangeEvent {

  @isTest
  static void tstTgrProjectTaskChangeEvent() {
    Test.enableChangeDataCapture();

    pse__Project_Task__c testSubject = UTL_PSA_TestData.createProjectTaskTestSubject();

    Test.startTest();

    // insert and deliver change
    insert testSubject;
    Test.getEventBus().deliver();

    // update and deliver change
    testSubject.Reason_For_Deletion__c = 'Test Class';
    update testSubject;
    Test.getEventBus().deliver();

    // delete and deliver change
    delete testSubject;
    Test.getEventBus().deliver();

    Test.stopTest();
  }
}