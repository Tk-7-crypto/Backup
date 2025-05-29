/**
 * Trigger for the project contact change event
 *
 * ----------------------------------------------------------------------------
 * Date Modified             Modified By             Description of the update
 * ----------------------------------------------------------------------------
 * 29 May 2020               CLD                 		 Initial Version
 */
trigger TGR_Project_Contact_ChangeEvent on Project_Contact__ChangeEvent (after insert) {
  UTL_EventDomainHelper.triggerPlatformEventHandler(DAO_Project_Contact_ChangeEvent.class);
}