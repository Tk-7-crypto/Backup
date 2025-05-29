import { LightningElement, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from "lightning/navigation";
import { getRecord, getFieldValue } from "lightning/uiRecordApi";
import sendSuggetionEmail from '@salesforce/apex/CNT_PRM_CommunitySuggestionBox.sendSuggetionEmail';
import CONTACT_FIRST_NAME from '@salesforce/schema/User.Contact.FirstName'
import CONTACT_LAST_NAME from '@salesforce/schema/User.Contact.LastName'
import CONTACT_ACCOUNT_NAME from '@salesforce/schema/User.Account.Name'
import USER_ID from '@salesforce/user/Id'

export default class Lwc_prm_CommunitySuggestionBox extends NavigationMixin(
    LightningElement
  ) {
    @wire(getRecord, { recordId: USER_ID, fields: [CONTACT_FIRST_NAME, CONTACT_LAST_NAME, CONTACT_ACCOUNT_NAME] })
    user;

    emailSubject;
    emailBody;

    @track isLoading = false;

    get contactFirstName() {
        return getFieldValue(this.user.data, CONTACT_FIRST_NAME);
    }

    get contactLastName() {
        return getFieldValue(this.user.data, CONTACT_LAST_NAME);
    }

    get contactAccountName() {
        return getFieldValue(this.user.data, CONTACT_ACCOUNT_NAME);
    }
    
    resetForm(){
        this.template.querySelectorAll('lightning-input').forEach(element => {
            element.value = null;     
        });
        this.template.querySelectorAll('lightning-textarea').forEach(element => {
            element.value = null;     
        });
        this.emailSubject = null;
        this.emailBody = null;
    }

    handleEmailSubjectChange(event){
        this.emailSubject = event.target.value;
    }

    handleEmailBodyChange(event){
        this.emailBody = event.target.value;
    }

    sendEmail() {
        if(this.emailBody && this.emailSubject){
            this.isLoading = true;

            let paramSubject = 'Partner Suggestion Feedback: ' + this.emailSubject;
            let paramBody = '<b>Partner Contact First and Last Name:</b> ' + this.contactFirstName + ' ' + this.contactLastName + '<br><br>'
                        + '<b>Partner Account:</b> ' + this.contactAccountName + '<br><br>'
                        + '<b>Suggestion Feedback:</b> <br>' + this.emailBody;

            sendSuggetionEmail({subject: paramSubject, body: paramBody})
            .then(result => {
                this.showToast('Suggestion Sent', 'Thank you for your valuable  feedback.', 'success');
                this.isModalOpen = false;
                this.isLoading = false;
                this.navigateToHomePage();
            })
            .catch(error => {
                this.showToast('Error', error.message, 'error');
                this.isLoading = false;
            });
        }else{
            this.showToast('Fill required fields', 'Please fill the subject and body field.', 'error');
        }
    }

    navigateToHomePage() {
        this[NavigationMixin.Navigate]({
            type: 'standard__namedPage',
            attributes: {
                pageName: 'home'
            },
        });
    }

    showToast(toastTitle, toastMessage, toastVariant) {
        const evt = new ShowToastEvent({
            title: toastTitle,
            message: toastMessage,
            variant: toastVariant,
            mode: 'dismissable'
        });
        this.dispatchEvent(evt);
    }
}