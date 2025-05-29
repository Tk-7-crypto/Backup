/**
 * Trigger for the project task change event
 *
 * ----------------------------------------------------------------------------
 * Date Modified             Modified By             Description of the update
 * ----------------------------------------------------------------------------
 * 21 May 2020               CLD                 		 Initial Version
 */
trigger TGR_Project_Task_ChangeEvent on pse__Project_Task__ChangeEvent (after insert) {
  UTL_EventDomainHelper.triggerPlatformEventHandler(DAO_Project_Task_ChangeEvent.class);
}