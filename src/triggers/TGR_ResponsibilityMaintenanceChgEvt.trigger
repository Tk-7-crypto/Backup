/**
 * Trigger for the responsibilities and maintenance change event
 *
 * ----------------------------------------------------------------------------
 * Date Modified             Modified By             Description of the update
 * ----------------------------------------------------------------------------
 * 29 May 2020               CLD                 		 Initial Version
 */
trigger TGR_ResponsibilityMaintenanceChgEvt on Responsibilities_and_Maintenance__ChangeEvent (after insert) {
  UTL_EventDomainHelper.triggerPlatformEventHandler(DAO_ResponsibilityMaintenanceChgEvt.class);
}