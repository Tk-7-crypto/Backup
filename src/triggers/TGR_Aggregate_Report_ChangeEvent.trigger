/**
 * Trigger for the project log change event
 *
 * ----------------------------------------------------------------------------
 * Date Modified             Modified By             Description of the update
 * ----------------------------------------------------------------------------
 * 28 May 2020               CLD                 		 Initial Version
 */
trigger TGR_Aggregate_Report_ChangeEvent on Aggregate_Report__ChangeEvent (after insert) {
  UTL_EventDomainHelper.triggerPlatformEventHandler(DAO_Aggregate_Report_ChangeEvent.class);
}