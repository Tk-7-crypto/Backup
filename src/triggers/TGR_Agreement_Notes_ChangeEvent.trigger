/**
 * Trigger for the agreement notes change event
 *
 * ----------------------------------------------------------------------------
 * Date Modified             Modified By             Description of the update
 * ----------------------------------------------------------------------------
 * 29 May 2020               CLD                 		 Initial Version
 */
trigger TGR_Agreement_Notes_ChangeEvent on Agreement_Notes__ChangeEvent (after insert) {
  UTL_EventDomainHelper.triggerPlatformEventHandler(DAO_Agreement_Notes_ChangeEvent.class);
}