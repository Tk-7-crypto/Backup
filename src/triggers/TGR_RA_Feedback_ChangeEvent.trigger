/**
 * Trigger for the ra feedback change event
 *
 * ----------------------------------------------------------------------------
 * Date Modified             Modified By             Description of the update
 * ----------------------------------------------------------------------------
 * 28 May 2020               CLD                 		 Initial Version
 */
trigger TGR_RA_Feedback_ChangeEvent on RA_Feedback__ChangeEvent (after insert) {
  UTL_EventDomainHelper.triggerPlatformEventHandler(DAO_RA_Feedback_ChangeEvent.class);
}