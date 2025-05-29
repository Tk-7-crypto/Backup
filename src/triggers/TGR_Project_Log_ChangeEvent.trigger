/**
 * Trigger for the project log change event
 *
 * ----------------------------------------------------------------------------
 * Date Modified             Modified By             Description of the update
 * ----------------------------------------------------------------------------
 * 26 May 2020               CLD                 		 Initial Version
 */
trigger TGR_Project_Log_ChangeEvent on Project_Log__ChangeEvent (after insert) {
  UTL_EventDomainHelper.triggerPlatformEventHandler(DAO_Project_Log_ChangeEvent.class);
}