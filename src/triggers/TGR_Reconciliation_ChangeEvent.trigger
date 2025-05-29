/**
 * Trigger for the Reconciliation change event
 *
 * ----------------------------------------------------------------------------
 * Date Modified             Modified By             Description of the update
 * ----------------------------------------------------------------------------
 * 29 May 2020               CLD                 		 Initial Version
 */
trigger TGR_Reconciliation_ChangeEvent on Reconciliation__ChangeEvent (after insert) {
  UTL_EventDomainHelper.triggerPlatformEventHandler(DAO_Reconciliation_ChangeEvent.class);
}