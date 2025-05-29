/**
 * Trigger for the ra request change event
 *
 * ----------------------------------------------------------------------------
 * Date Modified             Modified By             Description of the update
 * ----------------------------------------------------------------------------
 * 28 May 2020               CLD                 		 Initial Version
 */
trigger TGR_RA_Request_ChangeEvent on RA_Request__ChangeEvent (after insert) {
  UTL_EventDomainHelper.triggerPlatformEventHandler(DAO_RA_Request_ChangeEvent.class);
}