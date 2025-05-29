public class DAO_Case extends fflib_SObjectDomain {
    public static boolean isTimeSheet = false;
    /**
     * Constructor of this class
     * @params sObjectList List<Case>
     */
    public DAO_Case(List<Case> sObjectList) {
        super(sObjectList);
    }
    
    /**
     * Constructor Class for construct new Instance of This Class
     */
    public class Constructor implements fflib_SObjectDomain.IConstructable {
        public fflib_SObjectDomain construct(List<SObject> sObjectList) {
            return new DAO_Case(sObjectList);
        }
    }
    
    /**
     * This method is used for before insert of the case trigger.
     * @return void
     */
    public override void onBeforeInsert() {
        if(!isTimeSheet){
            Profile profile = null;
            boolean userType = UserInfo.getUserType().contains(CON_CSM.S_CUSTOMER_SUCCCESS);
            /** escape all method for creating the Case from Live Chat */
            if(CON_CSM.U_AUTOPROCESS_ID != UserInfo.getUserId()){
                DAOH_Case.setCRCAlertCaseDetails((List<Case>)Records);
                /** CSM-88 moved  setContactTitle method to first for Techno Case Assignment */
                DAOH_Case.setContactTitle((List<Case>)Records);
                boolean isWeb2Case = DAOH_Case.web2caseCreation((List<Case>)Records);
                if(UserInfo.getProfileId() != null){
                    profile = DAOH_Case.getCSMProfile(UserInfo.getProfileId());
                }
                if(profile != null && profile.Name != null && profile.Name != 'IQVIA Salesforce Platform Support' && !profile.Name.containsIgnoreCase(CON_CSM.S_P_SYS_ADMIN)){
                    DAOH_Case.ValidationForAllPillar((List<Case>)Records,null);
                }
                DAOH_Case.createChildCaseAllPillar((List<Case>)Records, null);
                
                if(userType){
                    DAOH_Case.createDataPillar((List<Case>)Records);
                }else if(UserInfo.getUserType().contains('Partner')){
                    
                }else if(!isWeb2Case && !userType){
                    DAOH_Case.AP_Case((List<Case>)Records, new Set<Id>());
                }
                DAOH_Case.checkBouncedEmailFlagForRnDPillar((List<Case>)Records);
                DAOH_Case.preventCaseCreationFromOOOE2C((List<Case>)Records);
                DAOH_Case.checkAFUOpenChildCase((List<Case>)Records,null,profile);
                Map<Id,Account> accMap = DAOH_Case.checkSpecialHandlingClient((List<Case>)Records,null);
                DAOH_Case.EntitlemebtAccAPCase01((List<Case>)Records,null,accMap);
                DAOH_Case.createCaseRelationfields((List<Case>)Records,null);
                DAOH_Case.tickStoppedCheckboxToPauseEntitlement((List<Case>)Records,accMap);
                DAOH_Case.checkFCRWhenCaseIsCreatedAsClosed((List<Case>)Records,null); 
                DAOH_Case.customEmailAddressesValidation((List<Case>)Records);
                DAOH_Case.setFieldForData((List<Case>)Records);
                /** DAOH_Case.populateLOSForRnDPillar((List<Case>)Records);*/
                if( !userType && UserInfo.getName() != 'System' && profile != null && profile.Name != null && profile.Name != 'Automated Process' && profile.Name != 'IQVIA Salesforce Platform Support' && !profile.Name.containsIgnoreCase(CON_CSM.S_P_SYS_ADMIN)) {
                    DAOH_Case.checkCaseTypeForDataCase((List<Case>)Records,null);
                }
                DAOH_Case.populateLocationForRAndD((List<Case>)Records, null);
                DAOH_Case.updateContactAlreadyInProcess((List<Case>)Records);
                DAOH_Case.setIsStudyAttachedFirstTimeForRND((List<Case>)Records, null);
                DAOH_Case.updateMilestoneAction((List<Case>)Records, null);
                DAOH_Case.updateCaseDefaultBusinessHour((List<Case>)Records, null);
                DAOH_Case.updateMileStoneStatusAndValue((List<Case>)Records);
                DAOH_Case.updateSubStatusOnQuickAction((List<Case>)Records, null);
                DAOH_Case.stopCaseCreationLoopOnAutoReply((List<Case>)Records);
                DAOH_Case.checkForCRCAlertCaseProtocol((List<Case>)Records);
                DAOH_Case.UpdateOnBehalfOfRef((List<Case>)Records, null);
                DAOH_Case.ElapsedtimeAge((List<Case>) Records);
                DAOH_Case.setCreatedDateInPreferredLanguage((List<Case>)Records);
                DAOH_Case.updateAssetBeforeInsert((List<Case>)Records);
                /** This should be the last method to call from before insert */
            }
        }
    }
    
    /**
     * This method is used for after insert of the case trigger.
     * @return void
     */
    public override void onAfterInsert() {
        if(!isTimeSheet){
            /** escape all method for creating the Case from Live Chat */
            if(CON_CSM.U_AUTOPROCESS_ID != UserInfo.getUserId()){
                DAOH_Case.cloneEmailMessagefromParentforRDCase((List<Case>)Records);
                DAOH_Case.saveAuditLogAfterInsertCase((List<Case>)Records);
                DAOH_Case.sendCaseCCEmails((List<Case>)Records); 
                DAOH_Case.sendEmailtoOwnerDataPillar((List<Case>)Records);
                DAOH_Case.SetCalendarEvent((List<Case>)Records,null);
                DAOH_Case.addDescriptionAsCaseComment((List<Case>)Records);
                DAOH_Case.checkIfCaseIsAvaiableInOneKey((List<Case>)Records, null);
                DAOH_Case.createActivitesbyRnDTemplate((List<Case>)Records,null);
                DAOH_Case.saveOLACase((List<Case>)Records,null);
                DAOH_CASE.restrictQueueForDispatch((List<Case>)Records,null);
                if(UserInfo.getName() != CON_CSM.S_SYSTEM) {
                    DAOH_CASE.insertCaseinInternalServiceNow((List<Case>)Records,null);
                }
                DAOH_Case.sendSMSNotificationtoMIR3((List<Case>)Records,null);
                /** DAOH_CASE.sendEmailForRecommendedArticles((List<Case>)Records); */
                DAOH_Case.cloneForms((List<Case>)Records);
                DAOH_Case.cloneAttachments((List<Case>)Records);
                 
            }
            DAOH_Case.sendNotificationForDispatch((List<Case>)Records, null);
            DAOH_Case.checkAccountBasedOnContact((List<Case>)Records,null);
        }
    }
    /**
     * This method is used for after update of the case trigger.
     * @params  existingRecords Map<Id,SObject>
     * @return  void
     */
    public override void  onAfterUpdate(Map<Id,SObject> existingRecords) {
        if(!isTimeSheet){
            /** escape all method for creating the Case from Live Chat */
            if(CON_CSM.U_AUTOPROCESS_ID != UserInfo.getUserId()){
                DAOH_Case.completeRDCaseMilestone((List<Case>) Records,(Map<Id,Case>)existingRecords);
                DAOH_Case.completeCaseMilestone((List<Case>) Records,(Map<Id,Case>)existingRecords);
                List<FieldDefinition> fields = new EXT_CSM_FieldDefination().getFieldDetails(CON_CSM.s_case);
                if(fields != null){
                    DAOH_Case.saveAuditLogAfterUpdateCaseFields((List<Case>)Records,(Map<Id,Case>)existingRecords,fields);
                }
                DAOH_CASE.restrictQueueForDispatch((List<Case>)Records,(Map<Id,Case>)existingRecords);
                DAOH_Case.sendNotificationForDispatch((List<Case>)Records, (Map<Id,Case>)existingRecords);
                DAOH_Case.saveQueueCaseHistory((List<Case>)Records,(Map<Id,Case>)existingRecords);
                DAOH_Case.updateCaseTaskQuickAction((List<Case>)Records,(Map<Id,Case>)existingRecords);
                DAOH_Case.sendCaseCCEmails((List<Case>)Records);
                DAOH_Case.createActivitesbyRnDTemplate((List<Case>)Records,(Map<Id,Case>)existingRecords);
                DAOH_Case.checkIfCaseIsAvaiableInOneKey((List<Case>)Records, (Map<Id,Case>)existingRecords);
                DAOH_Case.saveOLACase((List<Case>)Records,(Map<Id,Case>)existingRecords);
                DAOH_Case.UpdateTicketCSM2BISM((List<Case>)Records,(Map<Id,Case>)existingRecords);
                DAOH_Case.unfollowClosedCases((List<Case>)Records, (Map<Id,Case>)existingRecords);
                DAOH_Case.updateCaseMilestoneForClosedCase((List<Case>)Records, (Map<Id, Case>)existingRecords);
                DAOH_Case.sendMailAfterCaseUpdateForWatchList((List<Case>)Records, (Map<Id, Case>)existingRecords);
                //DAOH_Case.updateCaseEscalationField((List<Case>)Records, (Map<Id, Case>)existingRecords);
                if(UserInfo.getName() != CON_CSM.S_SYSTEM) {
                    DAOH_CASE.insertCaseinInternalServiceNow((List<Case>)Records,(Map<Id, Case>)existingRecords);
                }
                DAOH_CASE.sendEmailAlertSLA((List<Case>)Records,(Map<Id, Case>)existingRecords);
                DAOH_CASE.getCaseTechAutoTimer((List<Case>)Records,(Map<Id, Case>)existingRecords);
                DAOH_CASE.CloseChildCases((List<Case>)Records,(Map<Id, Case>)existingRecords);
            }
            DAOH_Case.sendEmailToLiquidPlanner((List<Case>)Records,(Map<Id,Case>)existingRecords);
        }
    }
    
    /**
     * This method is used for before update of the case trigger.
     * @params  existingRecords Map<Id,SObject>
     * @return  void
     */
    public override void onBeforeUpdate(Map<Id,SObject> existingRecords) {
        if(!isTimeSheet){
            /** escape all method for creating the Case from Live Chat */
            if(CON_CSM.U_AUTOPROCESS_ID != UserInfo.getUserId() && DAOH_Case.checkMilestoneOrFieldUpdate((List<Case>) Records,(Map<Id,Case>)existingRecords,'Before')){
                boolean userType = UserInfo.getUserType().contains(CON_CSM.S_CUSTOMER_SUCCCESS);
                Profile profile = DAOH_Case.getCSMProfile(UserInfo.getProfileId());
                DAOH_Case.CheckTechWithDifferentTypeChildBeforeClosing((List<Case>)Records,(Map<Id, Case>)existingRecords);
                DAOH_Case.CheckForAssetsForChildsHavingDifferentAccountIDThanParent((List<Case>)Records,(Map<Id, Case>)existingRecords);
                if(profile != null && profile.Name != null && profile.Name != 'IQVIA Salesforce Platform Support' && !profile.Name.containsIgnoreCase(CON_CSM.S_P_SYS_ADMIN)){
                    DAOH_Case.ValidationForAllPillar((List<Case>)Records,(Map<Id,Case>)existingRecords);
                    if(profile.Name != 'API Only User')
                        DAOH_Case.updateCaseValidationForAllPillar((List<Case>)Records,(Map<Id,Case>)existingRecords);
                    //DAOH_Case.insertRCACaseDocument((List<Case>)Records, (Map<Id, Case>)existingRecords);
                }
                DAOH_Case.updateCaseDetailsFromServiceNowValues((List<Case>) Records);
                DAOH_Case.createCaseRelationfields((List<Case>)Records,(Map<Id,Case>)existingRecords);
                DAOH_Case.checkAFUOpenChildCase((List<Case>)Records,(Map<Id,Case>)existingRecords,profile);
                DAOH_Case.sendAutomatedFollowUp((List<Case>)Records);
                DAOH_Case.checkAFUNextCloseDate((List<Case>)Records, (Map<Id,Case>)existingRecords);
                //DAOH_Case.uncheckTechAFUOnStatus((List<Case>)Records);
                DAOH_Case.validQuickAction((List<Case>)Records, (Map<Id,Case>)existingRecords);
                DAOH_Case.AP_Case01((List<Case>)Records,(Map<Id,Case>)existingRecords, (profile!= null && (userType || UserInfo.getUserType().contains('Partner'))) ? new Set<Id>{profile.Id} : new Set<Id>());
                Map<Id,Account> accMap = DAOH_Case.checkSpecialHandlingClient((List<Case>)Records,(Map<Id,Case>)existingRecords);
                DAOH_Case.EntitlemebtAccAPCase01((List<Case>)Records,(Map<Id,Case>)existingRecords,accMap);
                DAOH_Case.updateCaseWithMilestone((List<Case>)Records);
                DAOH_Case.restrictClosedCaseModification((List<Case>)Records, profile);
                DAOH_Case.automateCaseEscalation((List<Case>)Records, (Map<Id, Case>)existingRecords);
                DAOH_Case.SetCalendarEvent((List<Case>)Records, (Map<Id, Case>)existingRecords);
                DAOH_Case.tickStoppedCheckboxToPauseEntitlement((List<Case>)Records,accMap);
                DAOH_Case.setFieldForData((List<Case>)Records);
                DAOH_Case.reOpenedClosedCase((List<Case>)Records,(Map<Id,Case>)existingRecords);
                DAOH_Case.checkFCRWhenCaseIsClosedWithInOneHour((List<Case>)Records);
                DAOH_Case.unCheckFCRWhenCaseIsReopened((List<Case>)Records);
                DAOH_Case.checkFCRWhenCaseIsCreatedAsClosed((List<Case>)Records,(Map<Id,Case>)existingRecords);
                DAOH_Case.customEmailAddressesValidation((List<Case>)Records);
                //DAOH_Case.sendRandDAutomatedFollowUpEmail((List<Case>)Records);
                DAOH_Case.updateOnekeyIdToDeleted((List<Case>)Records);
                if(!userType && UserInfo.getName() != 'System' && profile != null && profile.Name != null && profile.Name != 'Automated Process' && profile.Name != 'IQVIA Salesforce Platform Support' && !profile.Name.containsIgnoreCase(CON_CSM.S_P_SYS_ADMIN)) {
                    DAOH_Case.checkCaseTypeForDataCase((List<Case>)Records, (Map<Id,Case>)existingRecords);
                }
                DAOH_Case.populateLocationForRAndD((List<Case>)Records, (Map<Id,Case>)existingRecords);
                DAOH_Case.checkActivityStatusForOpen((List<Case>)Records);
                //DAOH_Case.updateFirstResponseEmailTimeOnCase((List<Case>)Records, (Map<Id, Case>)existingRecords);
                DAOH_Case.updatePreviousQueue((List<Case>)Records,(Map<Id,Case>)existingRecords);
                DAOH_Case.updateSubStatusOnQuickAction((List<Case>)Records,(Map<Id,Case>)existingRecords);
                DAOH_Case.setIsStudyAttachedFirstTimeForRND((List<Case>)Records, (Map<Id,Case>)existingRecords);
                DAOH_Case.saveBusinessElapsedTime((List<Case>)Records,(Map<Id,Case>)existingRecords);
                DAOH_Case.updateMilestoneAction((List<Case>)Records, (Map<Id,Case>)existingRecords);
                DAOH_Case.updateCaseDefaultBusinessHour((List<Case>)Records,(Map<Id,Case>)existingRecords);
                DAOH_Case.updateMileStoneStatusAndValue((List<Case>)Records);
                DAOH_Case.checkAccountBasedOnContact((List<Case>)Records,(Map<Id,Case>)existingRecords);
                DAOH_Case.updateServiceNowGroupCSM2BISM((List<Case>)Records,(Map<Id,Case>)existingRecords);
                DAOH_Case.deliverRnDAutomatedFollowUpMail((List<Case>)Records);
                DAOH_Case.caseRecordReadOnlyforQueueUsers((List<Case>)Records,(Map<Id,Case>)existingRecords);
                DAOH_Case.updateCaseCategorization((List<Case>)Records,(Map<Id,Case>)existingRecords);
                DAOH_Case.updateCaseDetailsformEmailMessageOutgoing((List<Case>) Records,(Map<Id,Case>)existingRecords);
                DAOH_Case.UpdateOnBehalfOfRef((List<Case>)Records, (Map<Id, Case>)existingRecords);
                DAOH_Case.ElapsedtimeAge((List<Case>) Records);
                DAOH_Case.createChildCaseAllPillar((List<Case>)Records, (Map<Id, Case>)existingRecords);
                DAOH_Case.sendEmailToPartnerQueueOOO((List<Case>)Records,(Map<Id, Case>)existingRecords);
            }else if(CON_CSM.U_AUTOPROCESS_ID == UserInfo.getUserId()){
                DAOH_Case.setRecordtypetoIQVIALiveChat((List<Case>)Records);
                DAOH_Case.EntitlemebtAccAPCase01((List<Case>)Records,(Map<Id,Case>)existingRecords,null);
            }
        }
    }
}