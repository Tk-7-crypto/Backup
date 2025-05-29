/**
 * Trigger for subscribing to batch apex error
 *
 * ----------------------------------------------------------------------------
 * Date Modified             Modified By             Description of the update
 * ----------------------------------------------------------------------------
 * 23 May 2020               CLD                 		 Initial Version
 */
trigger TGR_BatchApexErrorEvent on BatchApexErrorEvent (after insert) {
  UTL_EventDomainHelper.triggerPlatformEventHandler(DAO_BatchApexErrorEvent.class);
}