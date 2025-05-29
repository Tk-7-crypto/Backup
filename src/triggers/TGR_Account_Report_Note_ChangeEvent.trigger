/**
 * Trigger for the account report note change event
 *
 * ----------------------------------------------------------------------------
 * Date Modified             Modified By             Description of the update
 * ----------------------------------------------------------------------------
 * 28 May 2020               CLD                 		 Initial Version
 */
trigger TGR_Account_Report_Note_ChangeEvent on Account_Report_Note__ChangeEvent (after insert) {
  UTL_EventDomainHelper.triggerPlatformEventHandler(DAO_Account_Report_Note_ChangeEvent.class);
}