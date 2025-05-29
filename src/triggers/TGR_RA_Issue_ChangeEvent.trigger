/**
 * Trigger for the ra issue change event
 *
 * ----------------------------------------------------------------------------
 * Date Modified             Modified By             Description of the update
 * ----------------------------------------------------------------------------
 * 28 May 2020               CLD                 		 Initial Version
 */
trigger TGR_RA_Issue_ChangeEvent on RA_Issue__ChangeEvent (after insert) {
	UTL_EventDomainHelper.triggerPlatformEventHandler(DAO_RA_Issue_ChangeEvent.class);
}