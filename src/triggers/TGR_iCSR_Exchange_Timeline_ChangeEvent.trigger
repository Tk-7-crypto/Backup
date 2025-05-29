/**
 * Trigger for the iCSR Exchange Timeline change event
 *
 * ----------------------------------------------------------------------------
 * Date Modified             Modified By             Description of the update
 * ----------------------------------------------------------------------------
 * 29 May 2020               CLD                 		 Initial Version
 */
trigger TGR_iCSR_Exchange_Timeline_ChangeEvent on iCSR_Exchange_Timeline__ChangeEvent (after insert) {
  UTL_EventDomainHelper.triggerPlatformEventHandler(DAO_iCSR_Exchange_Timeline_ChangeEvent.class);
}