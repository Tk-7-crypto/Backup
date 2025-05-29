import { LightningElement, api, wire } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

// Import from the Case object
import CONTACT_ID_FIELD from '@salesforce/schema/Case.ContactId';
import ACCOUNT_ID_FILED from '@salesforce/schema/Case.AccountId';
import RECORD_TYPE_NAME_FIELD from '@salesforce/schema/Case.RecordTypeName__c';
import STATUS_FIELD from '@salesforce/schema/Case.Status';
import REASON_FOR_LATE_FIELD from '@salesforce/schema/Case.Reason_for_Late_Request_Re_Run__c';
import CURRENT_QUEUE_FIELD from '@salesforce/schema/Case.CurrentQueue__c';
import SERVICENOW_STATUS_FIELD from '@salesforce/schema/Case.ServiceNow_Status__c';
import PARENT_ID_FIELD from '@salesforce/schema/Case.ParentId';
import RECORDTYPE_ID_FIELD from '@salesforce/schema/Case.RecordTypeId';
import CASENUMBER_FIELD from '@salesforce/schema/Case.CaseNumber';

//Import from the Contact
import IS_EMAIL_BOUNCED_FIELD from '@salesforce/schema/Contact.IsEmailBounced';

//Import from the Account Object
import MDM_STATUS from '@salesforce/schema/Account.MDM_Validation_Status__c';
import MDM_ID_FIELDS from '@salesforce/schema/Account.MDMID__c';


//Import from the Queue_User_Relationship__c object
import DISABLE_IQVIA_POPUP_FIELD from '@salesforce/schema/Queue_User_Relationship__c.Disable_IQVIA_Popup__c'

//Import methods
import checkSNStatusForParent from '@salesforce/apex/CNT_CSM_FlashMessage.checkSNStatusForParent';
import getFlashMessage from  '@salesforce/apex/CNT_CSM_FlashMessage.getFlashMessage';
//import checkTimeSheetMessage from '@salesforce/apex/CNT_CSM_FlashMessage.checkTimeSheetMessage'

export default class Lwc_CSM_Notification extends LightningElement {
    @api recordId
    //Case Fields
    contactId
    accountId
    recordType
    status
    caseNumber
    reasonForLate
    queueId
    disableIQVIAPopup
    mdmid
    parentId
    serviceNowStatus
    recordTypeId

    //Contact fields
    isEmailBounced

    //account fields
    mdm_Status

    //flags for error messages
    showNotificationReasonForLate = false
    showNotificationAccountValidation = false
    showNotificationIsEmailBounced = false
    showNotificationConsolidatedAccountWarning = false
    showNotificationServiceNowStatusCancelled = false

    msgReasonForLate ='This Case is Late'
    msgAccountValidation = 'The record was created with an unvalided account.'
    msgIsEmailBounced = 'The Contact on this Case has returned an undeliverable email response, please update the email address on the Contact record.'
    msgConsolidatedAccountWaring = '\nYou have selected the IQVIA account for the creation of a case. Please do not proceed with the case creation for the IQVIA\naccount if the customer impacted by this case can be found in CSM.\nIf you don\'t know the person impacted you can select the No Contact Known checkbox against the affected Account.\nIf the case is internal only, select the real customer and set the field case Source as Internal.'
    msgTitleConsolidatedAccountWaring = 'IQVIA Consolidated Account Warning : \n'
    msgServiceNowStatusCancelled = 'The ServiceNow Ticket: Ticket Number related to this Parent or Child case has been canceled. Please take appropriate action on this case.'
    msgFlashMessage=''
    msgTimeSheet = '\nNo related time sheet record associated to the current update. Please add your time and type in the Time Sheet component before updating the case.'


    // Use getRecord to retrieve the ContactId from the Case object
    @wire(getRecord, { recordId: '$recordId', fields: [CONTACT_ID_FIELD,ACCOUNT_ID_FILED,RECORD_TYPE_NAME_FIELD,STATUS_FIELD,REASON_FOR_LATE_FIELD,CURRENT_QUEUE_FIELD,SERVICENOW_STATUS_FIELD,PARENT_ID_FIELD,RECORDTYPE_ID_FIELD,CASENUMBER_FIELD] })
    wiredCase({ error, data }) {
        if (data) {
            // Access the ContactId from the Case record
            this.contactId = data.fields.ContactId.value;
            this.accountId = data.fields.AccountId.value;
            this.queueId = data.fields.CurrentQueue__c.value;
            this.recordType = data.fields.RecordTypeName__c.value;
            this.status = data.fields.Status.value;
            this.reasonForLate = data.fields.Reason_for_Late_Request_Re_Run__c.value;
            this.parentId = data.fields.ParentId.value;
            this.serviceNowStatus = data.fields.ServiceNow_Status__c.value;
            this.recordTypeId = data.fields.RecordTypeId.value;
            this.caseNumber = data.fields.CaseNumber.value;

            this.checkReasonForLateValidation();
            this.checkForServiceNowStatusCancelled();
            this.checkForFlashMessages();
            //this.checkForTimeSheetMessage();
        } else if (error) {
            console.error('Error fetching contactId: ', error);
        }
    }

    // Once we have the ContactId, wire to get IsEmailBounced from Contact
    @wire(getRecord, { recordId: '$contactId', fields: [IS_EMAIL_BOUNCED_FIELD] })
    wiredContact({ error, data }) {
        if (data) {
            this.isEmailBounced = data.fields.IsEmailBounced.value;
            console.log('this.isEmailBounced '+this.isEmailBounced);
            this.checkIsEmailBounced();
            //this.CheckForFlashMessages();
        } else if (error) {
            console.error('Error fetching IsEmailBounced: ', error);
        }
    }

    @wire(getRecord, { recordId: '$accountId', fields: [MDM_STATUS,MDM_ID_FIELDS] })
    wiredAccount({ error, data }) {
        if (data) {
            this.mdm_Status = data.fields.MDM_Validation_Status__c.value;
            this.mdmid = data.fields.MDMID__c.value;
            console.log('this.mdm_Status ' +this.mdm_Status);
            console.log('this.mdmid ' +this.mdmid);
            this.checkAccountValidation();
        } else if (error) {
            console.error('Error fetching MDM_Validation_Status__c: ', error);
        }
    }

    @wire(getRecord, { recordId: '$queueId', fields: [DISABLE_IQVIA_POPUP_FIELD] })
    wiredQueue({ error, data }  ) {
        if (data) {
            this.disableIQVIAPopup = data.fields.Disable_IQVIA_Popup__c.value;
            console.log('this.queueId ' +this.queueId);
            console.log('this.disableIQVIAPopup ' +this.disableIQVIAPopup);
            this.checkIfConsolidatedAccountWaring();
        } else if (error) {
            console.error('Error fetching Disable_IQVIA_Popup__c: ', error);
        }
    }
    
    checkReasonForLateValidation(){
        if(this.status != 'Closed' && this.recordType == 'DATACreateService' 
            &&this.reasonForLate != null && this.reasonForLate !=''){
            this.showNotificationReasonForLate = true;
        }
    }

    checkForFlashMessages(){
        if(this.recordType == 'TechnologyCase' || this.recordType =='RandDCase' || this.recordType == 'ActivityPlan' || this.recordType == 'VirtualTrialsCase'){
        getFlashMessage({contactId:this.contactId,caseNumber:this.caseNumber,recordTypeId:this.recordTypeId}).
                then(result=>{
                    console.log('result :' + result.length);
                    if(result !=null && result.length > 0 && result !=''){
                        this.msgFlashMessage = '\n'+result;
                        
                        if(this.contactId!= null)
                            this.showFlashMessage('success');
                        else
                            this.showFlashMessage('warning');
                    }   
                })
                .catch(error=>{
                    console.log(error);
                })
        }
    }

    /**checkForTimeSheetMessage(){
        console.log('this.recordType :'+this.recordType)
        if(this.recordType =='DATACreateService'){
            checkTimeSheetMessage({caseId:this.recordId,recordTypeId:this.recordTypeId}).
            then(result=>{
                console.log('result : '+result);
                if(result)
                    this.showTimeSheetMessage();
            })
            .catch(error=>{
                console.log(error)
            })

        }
    }*/
   
    checkForServiceNowStatusCancelled(){
        if((this.status != 'Closed' && this.status != 'Canceled') && (this.recordType=='ActivityPlan' || this.recordType =='RandDCase') && this.serviceNowStatus == 'Cancelled'){
            this.showNotificationServiceNowStatusCancelled = true;
        }
        else if (this.parentId != null){
            console.log('In checkForServiceNowStatusCancelled else if');
            checkSNStatusForParent({parentId:this.parentId}).
                then(result=>{
                    this.showNotificationServiceNowStatusCancelled = result;
                })
                .catch(error=>{
                    console.log(error);
                })
        }
    }
    

    checkAccountValidation(){
        if(this.recordType =='TechnologyCase' && this.mdm_Status!='Validated'){
            this.showNotificationAccountValidation = true;
        }
    }

    checkIsEmailBounced(){
        if(this.recordType =='TechnologyCase' && this.isEmailBounced == true){
            this.showNotificationIsEmailBounced = true;
        }
    }

    checkIfConsolidatedAccountWaring(){
        if(this.recordType =='TechnologyCase' && this.accountId != null && this.mdmid != null
            && this.mdmid == 504051 && this.queueId != null && ! this.disableIQVIAPopup ){
            //this.showNotificationConsolidatedAccountWarning = true;
            this.showToast();
        }
    }

    showToast(){
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'IQVIA Consolidated Account Warning : \n',
                message: this.msgConsolidatedAccountWaring,
                variant: 'warning',
                mode: 'sticky'
            }),
        );
    }

    showFlashMessage(toastType){
        console.log('this.msgFlashMessage : '+this.msgFlashMessage);
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Flash Message : ',
                message: this.msgFlashMessage,
                variant: toastType,
                mode: 'sticky'
            }),
        );
    }

    showTimeSheetMessage(){
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Flash Message : ',
                message: this.msgTimeSheet,
                variant: 'info',
                mode: 'sticky'
            }),
        );
    }

    
    

}