/**
* @Updated by: Vikram Singh Fartyal on 02Jan2017
* Trigger: TPA_Trigger_DSStatus
* Purpose: This is a helper class for above trigger.
*/
public class TGRH_TPADocusignStatus {
    /*************
    * Properties
    *************/
    public static List<dsfs__DocuSign_Status__c> newDocusignStatus;
    //public TPA_Request__c objAgg;
    //private List<dsfs__DocuSign_Status__c> listDocusignToBeVoid = new List<dsfs__DocuSign_Status__c>();
    Id cntId;
    public final String DS_VOIDED = 'Voided';
    public final String DS_SENT = 'Sent';
    public final String DS_DECLINED = 'Declined';
    public final String AGG_AwaitVendSign = 'Awaiting Vendor Signature';
    public final String AGG_InRevByIMS = Label.TPA_In_Review_By_IQVIA_Status; 
    public final String AGG_InEffect = 'In Effect';

    /*************
    * Constructor
    *************/
    public TGRH_TPADocusignStatus() {
        cntId = UTL_TPA.emailTargetContactId;
    }


    /****************
    * Public Methods
    ****************/
    public void onAfterUpdate(dsfs__DocuSign_Status__c[] listDSStatus)
    {
        try {
            if(listDSStatus.size() > 0) {
                this.updateAgreementStatusOnDSEnvelopVoided(listDSStatus);
                this.updateAgreementStatusOnDSEnvelopDeclined(listDSStatus);
            }

            Set<Id> reqIds = new Set<Id>();
            for(dsfs__DocuSign_Status__c dsStatus : listDSStatus){
                reqIds.add(dsStatus.TPA_Request__c);
            }
            Map<Id,TPA_Request__c> IdWithReqStatus = new Map<Id,TPA_Request__c>([Select Id,Request_Status__c,After_in_Effect_Changes__c From TPA_Request__c where Id in: reqIds]);
            for(dsfs__DocuSign_Status__c dsStatus : listDSStatus) {
                if(IdWithReqStatus != null && IdWithReqStatus.containsKey(dsStatus.TPA_Request__c) && (IdWithReqStatus.get(dsStatus.TPA_Request__c).Request_Status__c == 'Expired' || (IdWithReqStatus.get(dsStatus.TPA_Request__c).Request_Status__c == 'In Effect' && !IdWithReqStatus.get(dsStatus.TPA_Request__c).After_in_Effect_Changes__c ))){
                    continue;
                }
                if(dsStatus.dsfs__Envelope_Status__c == 'Completed') {
                    SRV_TPA_DocusignEnvelope.updateAgreement(dsStatus.TPA_Request__c, date.today(), dsStatus.dsfs__DocuSign_Envelope_ID__c, dsStatus.id);
                }
            }
        }
        catch(Exception ex) {
            UTL_LogFactory.getLogLst().Add(UTL_LogFactory.generateAndCommitLog(FALSE, FALSE, UTL_LogFactory.GUID, ex.getMessage(), 'TPA', 'Exception', 'ERROR', 'Line#' + ex.getLineNumber() + ':::TGRH_TPADocusignStatus.onAfterUpdate', ''));
            UTL_LogFactory.saveLogs(UTL_LogFactory.getLogLst(), TRUE);
            system.debug('####TPA_TriggerHelper_DSStatus.onAfterUpdate Error: '+ex.getMessage()+', Line: '+ex.getLineNumber()+', Cause: '+ex.getCause());
        }
    }

    public void onBeforeInsert(Map<String, dsfs__DocuSign_Status__c> newStatusMap, Set<String> tpaIds)
    {
        try {
            if(tpaIds != null && tpaIds.size() > 0) {
                this.updateAgreementDetailInDSStatus(newStatusMap, tpaIds);
            }
        }
        catch(Exception ex)
        {
            UTL_LogFactory.generateAndCommitLog(TRUE, FALSE, UTL_LogFactory.GUID, ex.getMessage(), 'TPA', 'Exception', 'ERROR', 'Line#' + ex.getLineNumber() + ':::TGRH_TPADocusignStatus.onBeforeInsert', '');
            system.debug(ex.getMessage());
        }
    }

    public void onAfterInsert(dsfs__DocuSign_Status__c[] listDSStatus)
    {

    }

    public void updateAgreementFields(Map <Id, TPA_Request__c> tpaRequestUpdateMap, Set<Id> tparequestIds)
    {
        System.debug('####In the updateAgreementField Method####');
        if (tpaRequestUpdateMap!= null && tpaRequestUpdateMap.size() > 0) {
            update tpaRequestUpdateMap.values();
        }
        /*this.objAgg.Company_Signed_By_Unlisted__c = objAgg.Vendor_First_Name__c + ' ' + objAgg.Vendor_Contact_Last_Name__c;

        List<User> sentByUser = getSentForSignByUser();

        if(sentByUser.size()> 0)
        {
            User usr = sentByUser[0];
            this.objAgg.Sent_for_Signatures_on__c = Date.today();
        }
        this.objAgg.Request_Status__c =  'Awaiting Vendor Signature';
        this.objAgg.Sent_for_Signature__c = Datetime.now();*/

        try
        {
            //update this.objAgg;
            List<TPA_RequestDocument__c> lstRequestDocuments = new List<TPA_RequestDocument__c>();
            lstRequestDocuments = [select Document_Id__c, TPA_Request_Id__c from TPA_RequestDocument__c where TPA_Request_Id__c in: tparequestIds];
            Set<Id> stDocumentId = new Set<Id>();
            Map<Id, Id> mapDocumentRequestIds = new Map<Id, Id>();
            for(TPA_RequestDocument__c objRequestDocument : lstRequestDocuments) {
                stDocumentId.add(objRequestDocument.Document_Id__c);
                mapDocumentRequestIds.put(objRequestDocument.Document_Id__c, objRequestDocument.TPA_Request_Id__c);
            }
            List<Document> docs = new List<Document>();
            docs = [select id,name,body from Document where id in: stDocumentId];
            List<Attachment> lstOtherDocInsert = new List<Attachment>();
            if(docs.size() > 0)
            {
                for(integer docCounter = 0 ; docCounter < docs.size() ; docCounter++)
                {
                    /*if(!this.objAgg.Is_Restricted_Data_Asset__c && docs.get(docCounter).name.indexOf('Restricted Data Security Requirement') > -1)
                        continue;*/
                    Attachment attach = new Attachment();

                    if(docs.get(docCounter).name.toLowerCase().indexOf(('STANDARD TERMS AND CONDITIONS').toLowerCase()) != -1)
                        attach.name = 'STANDARD TERMS AND CONDITIONS.pdf';
                    if(docs.get(docCounter).name.toLowerCase().indexOf(('Compliance Program').toLowerCase()) != -1)
                        attach.name = 'Compliance Program.pdf';
                    if(docs.get(docCounter).name.toLowerCase().indexOf(('STANDARD TERMS AND CONDITIONS Japanese').toLowerCase()) != -1)
                        attach.name = 'STANDARD TERMS AND CONDITIONS Japanese.pdf';
                    if(docs.get(docCounter).name.toLowerCase().indexOf(('Compliance Program Japanese').toLowerCase()) != -1)
                        attach.name = 'Compliance Program Japanese.pdf';

                    attach.body = docs.get(docCounter).body;
                    attach.ParentId = mapDocumentRequestIds.get(docs.get(docCounter).Id);
                    lstOtherDocInsert.add(attach);
                }
                if(lstOtherDocInsert.size() > 0)
                    insert lstOtherDocInsert;
            }
            //todo TPAQueryHelper.logRef().logToInsert().Log_Type__c = 'Success';
            //todo TPAQueryHelper.setLogObject(this.objAgg.Id, 'Success:Status Updated to Awaiting Vendor Signature  ','');
            //todo TPAQueryHelper.logRef().generateLog();
        }
        catch(Exception exp)
        {
            //todo TPAQueryHelper.logRef().logToInsert().Log_Type__c = 'Exception';
            //todo TPAQueryHelper.setLogObject(this.objAgg.Id, 'Exception:Status Failed to Update to Awaiting Vendor Signature  ',exp.getMessage()+'*'+exp.getLineNumber());
            //todo TPAQueryHelper.logRef().generateLog();
            throw exp;
        }
        SRV_TPA_TPARequest.updateActivityHistoryForBulk(tparequestIds, 'Awaiting Vendor Signature', true);
        //SRV_TPA_TPARequest.updateActivityHistory(this.objAgg.Id, 'Awaiting Vendor Signature', true);
    }


    /*****************
    * Private Methods
    *****************/
    private void updateAgreementDetailInDSStatus(Map<String, dsfs__DocuSign_Status__c> newStatusMap, Set<String> tpaIds)
    {
        System.debug('####In the updateAgreementDetailInDSStatus Method####');
        //string mailSubject = '';
        TPA_Request__c request ;
        boolean updateStatus = false;
        //integer partsLength = 0;
        List < TPA_Request__c > tpaRequestList = new List < TPA_Request__c >();
        Map < String, TPA_Request__c > tpaRequestMapWithTPAId = new Map < String, TPA_Request__c > ();
        Set<Id> tparequestIds = new Set<Id>();
        Map <Id, TPA_Request__c> tpaRequestUpdateMap = new Map <Id, TPA_Request__c>();
        set<string> setLanguages = new set<string>();
        /*for(dsfs__DocuSign_Status__c Status: listStatus)
        {
            if(Status.dsfs__Subject__c != null)
            {
                mailSubject = Status.dsfs__Subject__c;
                List<String> parts = mailSubject.split('\\,');
                List<String> lstByColon = new List<String>();
                if(parts.size() > 0)
                {
                    lstByColon = parts[0].split(':');
                    partsLength = lstByColon.size()- 1;
                }
                mailSubject = lstByColon[partsLength];
                system.debug(mailSubject);

                if(mailSubject != null)
                    request = [SELECT Id FROM TPA_Request__c where name =: mailSubject.trim()];
                if(request != null)
                {
                    //todo TPAQueryHelper.logRef().logToInsert().Log_Type__c = 'Success';
                    //todo TPAQueryHelper.setLogObject(request.id, 'Success: Envelope came in SFDC', mailSubject);
                    //todo TPAQueryHelper.logRef().generateLog();
                }
                objAgg = [select id, Vendor_Contact_Title__c, Vendor_First_Name__c, Vendor_Contact_Last_Name__c, 
                          Company_Signed_By_Unlisted__c, Sent_for_Signatures_on__c, Request_Status__c, 
                          Sent_for_Signature__c, After_in_Effect_Changes__c, Is_Restricted_Data_Asset__c, Vendor_Language__c
                          from TPA_Request__c where Id = : request.id];
                Status.TPA_Request__c = objAgg.Id;
                updateStatus = true;
                if(!objAgg.After_in_Effect_Changes__c ){
                    setVoidToDocusignEnvelope();
                    updateAgreementFields();
                }
            }
        }*/
        String query = 'select id, Name, Vendor_Contact_Title__c, Vendor_First_Name__c, Vendor_Contact_Last_Name__c, Company_Signed_By_Unlisted__c, Sent_for_Signatures_on__c, Request_Status__c, Sent_for_Signature__c, After_in_Effect_Changes__c, Is_Restricted_Data_Asset__c, Vendor_Language__c from TPA_Request__c where Name IN: tpaIds';
        tpaRequestList = Database.query(query);
        for (TPA_Request__c tpaRequest: tpaRequestList) {
            tpaRequestMapWithTPAId.put((String)tpaRequest.get('Name'), tpaRequest);
        }
        if (newStatusMap!= null && newStatusMap.size() > 0) {
            for(String cdaReqNo: newStatusMap.keySet()){
                request = tpaRequestMapWithTPAId.get(cdaReqNo);
                newStatusMap.get(cdaReqNo).TPA_Request__c = request.Id;
                updateStatus = true;
                if(!request.After_in_Effect_Changes__c ){
                    request.Company_Signed_By_Unlisted__c = request.Vendor_First_Name__c + ' ' + request.Vendor_Contact_Last_Name__c;
                    request.Sent_for_Signatures_on__c = Date.today();
                    request.Request_Status__c =  'Awaiting Vendor Signature';
                    request.Sent_for_Signature__c = Datetime.now();
                    tparequestIds.add(request.Id);
                    tpaRequestUpdateMap.put(request.Id, request);
                    setLanguages.add(request.Vendor_Language__c+ '_Translation__c');
                }
            }
        }
        if(tparequestIds != null && tparequestIds.size() > 0){
            setVoidToDocusignEnvelope(tparequestIds, setLanguages);
            updateAgreementFields(tpaRequestUpdateMap, tparequestIds);
        }
    }

    private void setVoidToDocusignEnvelope(Set<Id> tparequestIds, set<string> setLanguages)
    {
        List<Attachment> lstOtherDocDelete = new List<Attachment>();
        List<dsfs__DocuSign_Status__c> listDocusignToBeVoid = new List<dsfs__DocuSign_Status__c>();
        Map<String, List<TPA_Language_Cross_Walk__c>> multilanguageUtilityMap = new Map<String, List<TPA_Language_Cross_Walk__c>>();
        lstOtherDocDelete = [select id from Attachment where parentId in: tparequestIds and (name like 'Compliance Program%' or name like 'STANDARD TERMS AND CONDITIONS%' or name like 'Restricted Data Security Requirement%')];
        if(lstOtherDocDelete != null && lstOtherDocDelete.size() >0){
            delete lstOtherDocDelete;
        }
        if(setLanguages != null && setLanguages.size() > 0){
            multilanguageUtilityMap = UTL_TPA_Multilingual.getTranslatedValueMap(setLanguages);
        }
        //String voidReason = multilanguageUtilityMap == null ? 'Envelope is Corrected' : (String)multilanguageUtilityMap.get(this.objAgg.Vendor_Language__c + '_Translation__c~TPA_Request__c~Record~VoidReason')[0].get(this.objAgg.Vendor_Language__c + '_Translation__c');
        listDocusignToBeVoid = [SELECT  TPA_Request__c, TPA_Request__r.Vendor_Language__c, dsfs__DocuSign_Envelope_ID__c,  dsfs__Envelope_Status__c FROM dsfs__DocuSign_Status__c
                                where  dsfs__Envelope_Status__c != 'Completed' AND dsfs__Envelope_Status__c != 'Voided'
                                AND TPA_Request__c in: tparequestIds];

        if (listDocusignToBeVoid != null && listDocusignToBeVoid.size() > 0)
        {
            for(dsfs__DocuSign_Status__c objDSStatus  : listDocusignToBeVoid )
            {
                String voidReason = multilanguageUtilityMap == null ? 'Envelope is Corrected' : (String)multilanguageUtilityMap.get(objDSStatus.TPA_Request__r.Vendor_Language__c + '_Translation__c~TPA_Request__c~Record~VoidReason')[0].get(objDSStatus.TPA_Request__r.Vendor_Language__c + '_Translation__c');
                system.debug(' - - Before voidEnvelope -- ');
                SRV_TPA_DocusignEnvelope.voidEnvelope(objDSStatus.dsfs__DocuSign_Envelope_ID__c, voidReason);
            }
        }
    }

    private List<User> getSentForSignByUser()
    {
        return [SELECT Id,Name,title FROM User where Id =: UserInfo.getUserId()  Limit 1];
    }

    private void updateAgreementStatusOnDSEnvelopVoided(dsfs__DocuSign_Status__c[] listStatus){
        Map<Id,Id> aggDSEnvIds = new Map<Id,Id>();
        List<TPA_Request__c> lstAggToBeSaved = new List<TPA_Request__c>();
        Map<Id, TPA_Request__c> mapDsEnvIdAndAggObj = new Map<Id, TPA_Request__c>();
        List<TPA_Request__c> relatedReq = new List<TPA_Request__c>();

        //fetch ids of agreements those ds envelope status is voided
        for(dsfs__DocuSign_Status__c dsStatus : listStatus){
            if(dsStatus.dsfs__Envelope_Status__c == DS_VOIDED){
                aggDSEnvIds.put(dsStatus.TPA_Request__c, dsStatus.id);
            }
        }
        system.debug('####TPA_TriggerHelper_DSStatus.updateAgreementStatusOnDSEnvelopVoided aggDSEnvIds: '+aggDSEnvIds);

        //fetch the agreement details of above ids
        List<TPA_Request__c> lstAggDetails = [SELECT Request_Status__c, TP_Processor_Email__c,
                                                         Id, Void_Envelope_Type__c,Pending_Acknowledgements__c, TPA_Assigned_TP_Processor__c, TPA_Assigned_TP_Processor__r.Initials__c, TPA_Assigned_TP_Processor__r.Is_Active__c, Co_Assigned_Global_TP_Processor__c, Co_Assigned_Global_TP_Processor__r.Is_Active__c,  Co_Assigned_Global_TP_Processor__r.Initials__c,
                                                         (SELECT dsfs__Envelope_Status__c,dsfs__Voided_Reason__c FROM DocuSign_Status__r order by dsfs__Sent_Date_Time__c DESC)
                                                         FROM TPA_Request__c
                                                         WHERE Id IN :aggDSEnvIds.keySet()];
        system.debug('####TPA_TriggerHelper_DSStatus.updateAgreementStatusOnDSEnvelopVoided lstAggDetails: '+lstAggDetails);

        if(lstAggDetails != null){
            for(TPA_Request__c dsAgg : lstAggDetails){
                if(dsAgg.DocuSign_Status__r != null){
                    system.debug('####TPA_TriggerHelper_DSStatus.updateAgreementStatusOnDSEnvelopVoided agreement DocuSign_Status__r: '+dsAgg.DocuSign_Status__r);
                    boolean isNonVoidStatusExist = false;
                    boolean voidManually = false;
                    for(dsfs__DocuSign_Status__c aggDsfsStatus : dsAgg.DocuSign_Status__r){
                        if(aggDsfsStatus.dsfs__Envelope_Status__c == DS_SENT){
                            isNonVoidStatusExist = true;
                            break;
                        }
                    }
                    if(dsAgg.DocuSign_Status__r.size() > 0 && dsAgg.DocuSign_Status__r[0].dsfs__Envelope_Status__c == DS_VOIDED && dsAgg.Void_Envelope_Type__c != 'ineffect' && (dsAgg.Void_Envelope_Type__c == 'manuallyVoided' || dsAgg.Void_Envelope_Type__c == 'resend')){
                        voidManually = true;
                    }
                    system.debug('####TPA_TriggerHelper_DSStatus.updateAgreementStatusOnDSEnvelopVoided isNonVoidStatusExist: '+isNonVoidStatusExist);
                    if(!isNonVoidStatusExist && dsAgg.request_status__c == AGG_AwaitVendSign){
                        dsAgg.request_status__c = AGG_InRevByIMS;
                        if(voidManually){
                            dsAgg.request_status__c = 'Pending IQVIA Review of Voided Envelope';
                            dsAgg.In_Pending_IQVIA_Review_of_Voided_Env__c = Date.today();
                        }
                        if(dsAgg.Void_Envelope_Type__c == 'ineffect'){
                            dsAgg.request_status__c = AGG_InEffect;

                            dsAgg.Void_Envelope_Type__c = null;
                            relatedReq.add(dsAgg);
                        }
                        lstAggToBeSaved.add(dsAgg);

                        mapDsEnvIdAndAggObj.put(aggDSEnvIds.get(dsAgg.id), dsAgg);
                    }
                }
            }
        }
        system.debug('####TPA_TriggerHelper_DSStatus.updateAgreementStatusOnDSEnvelopVoided relatedReq: '+relatedReq);
        system.debug('####TPA_TriggerHelper_DSStatus.updateAgreementStatusOnDSEnvelopVoided lstAggToBeSaved: '+lstAggToBeSaved);
        try{
            if(relatedReq != null){
                upsert relatedReq;
            }
            if(lstAggToBeSaved != null){
                upsert lstAggToBeSaved;
            }
            
            Set<Id> agrSet = new Set<Id>();
            Set<Id> agrSetForDblEmails = new Set<Id>();
            TGRH_TPARequest triggerHelperInstance = new TGRH_TPARequest();
            for(TPA_Request__c agrObj: lstAggToBeSaved) {
                agrSet.add(agrObj.Id);
            }
            if(!agrSet.isEmpty()) {
                List<Attachment> listAmaAttachment = [select Id, Name, Body, ParentId from Attachment where ParentId IN :agrSet and (Name like 'AMA_%TPA%.pdf_Completed')];
                for(Attachment attObj: listAmaAttachment) {
                    if(!agrSetForDblEmails.contains(attObj.ParentId)) {
                        agrSetForDblEmails.add(attObj.ParentId);
                    }
                }
                for(Id agrId: agrSetForDblEmails) {
                    triggerHelperInstance.sendMailToDblForExecutedAmaAgreement(agrId);
                }
            }
            if(mapDsEnvIdAndAggObj != null){
                Id templateId = UTL_TPA_Multilingual.multiLingualTemplateSettingsMap.get('Email DS Envelope Voided'+'English').Translated_Template_Id__c;
                sendDSEnvelopeStatusNotification(mapDsEnvIdAndAggObj, templateId, DS_VOIDED);
            }

        }catch(Exception e){
            UTL_LogFactory.getLogLst().Add(UTL_LogFactory.generateAndCommitLog(FALSE, FALSE, UTL_LogFactory.GUID, e.getMessage(), 'TPA', 'Exception', 'ERROR', 'Line#' + e.getLineNumber() + ':::TGRH_TPADocusignStatus.updateAgreementStatusOnDSEnvelopVoided', ''));
            UTL_LogFactory.saveLogs(UTL_LogFactory.getLogLst(), TRUE);
            System.debug('####TPA_TriggerHelper_DSStatus.updateAgreementStatusOnDSEnvelopVoided An exception occurred: ' + e.getMessage()+', Line: '+e.getLineNumber()+', Cause: '+e.getCause());
        }
    }
    private void updateAgreementStatusOnDSEnvelopDeclined(dsfs__DocuSign_Status__c[] listStatus){
        Map<Id,Id> aggDSEnvIds = new Map<Id,Id>();
        List<TPA_Request__c> lstAggToBeSaved = new List<TPA_Request__c>();
        Map<Id, TPA_Request__c> mapDsEnvIdAndAggObj = new Map<Id, TPA_Request__c>();

        for(dsfs__DocuSign_Status__c dsStatus : listStatus){
            if(dsStatus.dsfs__Envelope_Status__c == DS_DECLINED){
                aggDSEnvIds.put(dsStatus.TPA_Request__c, dsStatus.id);
            }
        }
        system.debug('####TPA_TriggerHelper_DSStatus.updateAgreementStatusOnDSEnvelopDeclined aggDSEnvIds: '+aggDSEnvIds);

        List<TPA_Request__c> lstDeclinedAggDetails = [SELECT id, Request_Status__c, TP_Processor_Email__c, TPA_Assigned_TP_Processor__c, TPA_Assigned_TP_Processor__r.Initials__c, TPA_Assigned_TP_Processor__r.Is_Active__c, Co_Assigned_Global_TP_Processor__c, Co_Assigned_Global_TP_Processor__r.Is_Active__c,  Co_Assigned_Global_TP_Processor__r.Initials__c,
                                                                 (SELECT dsfs__Envelope_Status__c FROM DocuSign_Status__r)
                                                                 FROM TPA_Request__c
                                                                 WHERE Id IN :aggDSEnvIds.keySet()];
        system.debug('####TPA_TriggerHelper_DSStatus.updateAgreementStatusOnDSEnvelopDeclined lstDeclinedAggDetails: '+lstDeclinedAggDetails);

        for(TPA_Request__c dsAgg : lstDeclinedAggDetails){
            if(dsAgg.request_status__c == AGG_AwaitVendSign){
                dsAgg.request_status__c = AGG_InRevByIMS;

                lstAggToBeSaved.add(dsAgg);

                mapDsEnvIdAndAggObj.put(aggDSEnvIds.get(dsAgg.id), dsAgg);
            }
        }
        system.debug('####TPA_TriggerHelper_DSStatus.updateAgreementStatusOnDSEnvelopDeclined lstAggToBeSaved: '+lstAggToBeSaved);
        try{
            //update the agreement
            if(lstAggToBeSaved != null){
                upsert lstAggToBeSaved;
            }

            //send email notification to the tp-processors
            if(mapDsEnvIdAndAggObj != null){
                //fetch respective template id for email notification
                Id templateId = UTL_TPA_Multilingual.multiLingualTemplateSettingsMap.get('Email DS Envelope Declined'+'English').Translated_Template_Id__c;
                sendDSEnvelopeStatusNotification(mapDsEnvIdAndAggObj, templateId, DS_DECLINED);
            }

        }catch(Exception e){
            System.debug('####TPA_TriggerHelper_DSStatus.updateAgreementStatusOnDSEnvelopVoided An exception occurred: ' + e.getMessage()+', Line: '+e.getLineNumber()+', Cause: '+e.getCause());
        }
    }

    private void sendDSEnvelopeStatusNotification(Map<Id, TPA_Request__c> mapEnvIdAgg, Id mailTemplateId, String dsEnvStatus){
        List<Messaging.SingleEmailMessage> dsEnvelopeStatusMsgListToBeSend = new List<Messaging.SingleEmailMessage>();

        try{
            for(Id dsEnvId : mapEnvIdAgg.keySet()){
                List<String> toRecipients = new List<String>();
                //List<String> ccRecipients = new List<String>();

                //fecth to recepient
                toRecipients.add(mapEnvIdAgg.get(dsEnvId).tp_processor_email__c);

                //fetch cc recepients
                /*TPA_Settings__c tpaSetting = TPA_Settings__c.getInstance();
                if(tpaSetting != null && tpaSetting.Shared_Email__c != null){
                    ccRecipients.add(tpaSetting.Shared_Email__c);
                }*/
                /*Messaging.SingleEmailMessage emailNotToSend = new Messaging.SingleEmailMessage();
                emailNotToSend.setTargetObjectId(cntId);
                emailNotToSend.setTreatTargetObjectAsRecipient(false);
                emailNotToSend.setToAddresses(toRecipients);
                emailNotToSend.setWhatId(dsEnvId);
                emailNotToSend.setTemplateId(mailTemplateId);
                emailNotToSend.setSaveAsActivity(false);
                Savepoint sp = Database.setSavepoint();
                try
                {
                    if(UTL_TPA.isSendOutgoingEmails && !Test.isRunningTest()) {
                        Messaging.sendEmail(New Messaging.SingleEmailMessage[] {emailNotToSend});
                    }
                }
                catch(Exception e)
                {
                    System.debug('####TPA_TriggerHelper_DSStatus.sendDSEnvelopeStatusNotification '+dsEnvStatus+' An exception occurred: ' + e.getMessage()+', Line: '+e.getLineNumber()+', Cause: '+e.getCause());
                }
                Database.rollback(sp);

                //Reformat the above email body and resend the mail to the desired to-recipient
                
                //This snippet is to preapare the actual email using the email template and salesforce contact object(salesforce limitation: mandatory use of Contact object )
                
                Messaging.SingleEmailMessage emailToSend = new Messaging.SingleEmailMessage();
                emailToSend.setCharset('UTF-8');
                
                system.debug('####TPA_TriggerHelper_DSStatus.sendDSEnvelopeStatusNotification '+dsEnvStatus+' toRecipients:'+toRecipients+', ccRecipients: '+ccRecipients+ 'dsEnvId :'+dsEnvId);
                emailToSend.setToAddresses(toRecipients);
                if(ccRecipients != null){
                    emailToSend.setCcAddresses(ccRecipients);
                }
                emailToSend.setPlainTextBody(emailNotToSend.getPlainTextBody());
                emailToSend.setHTMLBody(emailNotToSend.getHTMLBody());
                emailToSend.setSubject(emailNotToSend.getSubject());
                emailToSend.setWhatId(dsEnvId);
                emailToSend.setSaveAsActivity(true);
                emailToSend.setTargetObjectId(cntId);
                emailToSend.setTreatTargetObjectAsRecipient(false);

                dsEnvelopeStatusMsgListToBeSend.add(emailToSend);*/

                try{
                    /*SRV_TPA_TPARequest.addTPProcessorInitials = true;
                    if(mapEnvIdAgg.get(dsEnvId).TPA_Assigned_TP_Processor__r.Is_Active__c) {
                    	SRV_TPA_TPARequest.assignedTPProcessorName = mapEnvIdAgg.get(dsEnvId).TPA_Assigned_TP_Processor__r.Initials__c;
                    }*/
                    SRV_TPA_TPARequest.sendEmailThroughWorkflow(toRecipients, null, 'SendEmail', mailTemplateId, dsEnvId, null, '', false, '', TRUE, TRUE, mapEnvIdAgg.get(dsEnvId));
                    //SRV_TPA_TPARequest.addTPProcessorInitials = false;
                    SRV_TPA_TPARequest.updateActivityHistory( mapEnvIdAgg.get(dsEnvId).id, 'DocuSign Envelope '+dsEnvStatus+' Notification Sent to TP-Processor', true);
                }catch(Exception e){
                    System.debug('####TPA_TriggerHelper_DSStatus.sendDSEnvelopeStatusNotification '+dsEnvStatus+' An exception occurred: ' + e.getMessage()+', Line: '+e.getLineNumber()+', Cause: '+e.getCause());
                }
            }
        }
        catch(System.EmailException emlEx){
            System.debug('####TPA_TriggerHelper_DSStatus.sendDSEnvelopeStatusNotification '+dsEnvStatus+' Email Failed: ' + emlEx);
        }catch(Exception e){
            System.debug('####TPA_TriggerHelper_DSStatus.sendDSEnvelopeStatusNotification '+dsEnvStatus+' An exception occurred: ' + e.getMessage()+', Line: '+e.getLineNumber()+', Cause: '+e.getCause());
        }
    }
}
