/**
 * Trigger for the report country change event
 *
 * ----------------------------------------------------------------------------
 * Date Modified             Modified By             Description of the update
 * ----------------------------------------------------------------------------
 * 28 May 2020               CLD                 		 Initial Version
 */
trigger TGR_Report_Country_ChangeEvent on Report_Country__ChangeEvent (after insert) {
  UTL_EventDomainHelper.triggerPlatformEventHandler(DAO_Report_Country_ChangeEvent.class);
}