import { LightningElement, api, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';
import { getRecord, getFieldValue, updateRecord } from 'lightning/uiRecordApi';
import getContactsByEmail from '@salesforce/apex/SLT_Contact.getContactsByEmail';
import CONTACT_ID_FIELD from '@salesforce/schema/Case.ContactId';
import SUPPLIED_EMAIL_FIELD from '@salesforce/schema/Case.SuppliedEmail';
import NO_CONTACT_KNOWN_FIELD from '@salesforce/schema/Case.NoContactKnown__c';

export default class Lwc_csm_find_contact_from_emailToCase extends LightningElement {
    @api recordId;
    @track showModal = false;
    @track hasCheckedConditions = false;
    @track contacts = [];
    @track selectedContactId;
    @track isLoading = true;
    @track error;
    wiredCaseRecord;

    columns = [
        { label: 'Full Name', fieldName: 'Name', type: 'text' },
        { label: 'Account', fieldName: 'AccountName', type: 'text' },
        { label: 'Job Title', fieldName: 'Title', type: 'text' },
        { label: 'Email', fieldName: 'Email', type: 'text' },
        {
            label: 'Action',
            type: 'button',
            typeAttributes: { label: 'Select this contact', name: 'select', title: 'Select this contact', variant: 'brand' }
        }
    ];


    @wire(getRecord, {
        recordId: '$recordId',
        fields: [CONTACT_ID_FIELD, SUPPLIED_EMAIL_FIELD, NO_CONTACT_KNOWN_FIELD]
    })
    caseRecord(response) {
        this.wiredCaseRecord = response;
        const { data, error } = response;

        if (data && !this.hasCheckedConditions) {
            this.checkConditions(data);
            this.hasCheckedConditions = true;
        } else if (error) {
            this.error = error;
        }
    }

    get hasContacts() {
        return this.contacts.length > 0;
    }

    checkConditions(caseData) {
        const contactId = getFieldValue(caseData, CONTACT_ID_FIELD);
        const suppliedEmail = getFieldValue(caseData, SUPPLIED_EMAIL_FIELD);
        const noContactKnown = getFieldValue(caseData, NO_CONTACT_KNOWN_FIELD);

        if (!contactId && suppliedEmail && !noContactKnown) {
            this.loadContacts(suppliedEmail);
        }
    }

    loadContacts(email) {
        this.contacts = [];
        this.selectedContactId = null;
        this.isLoading = true;

        getContactsByEmail({ email })
            .then((result) => {
                if (Array.isArray(result) && result.length > 0) {
                    this.contacts = result.map((contact) => ({
                        ...contact,
                        AccountName: contact.Account.Name
                    }));
                    this.showModal = true;
                } else {
                    this.showModal = false;
                }
            })
            .catch((error) => {
                console.log(error);
                this.contacts = [];
                this.error = error;
                this.showModal = false;
            })
            .finally(() => {
                this.isLoading = false;
            });
    }


    handleContactSelection(event) {
        const action = event.detail.action;
        const row = event.detail.row;

        if (action.name === 'select') {
            this.isLoading = true;
            this.selectedContactId = row.Id;

            const fields = {};
            fields[CONTACT_ID_FIELD.fieldApiName] = this.selectedContactId;
            const recordInput = {
                fields,
                recordId: this.recordId
            };

            updateRecord(recordInput)
                .then(() => {
                    this.showModal = false;
                    this.showToast('Success', 'Record updated successfully', 'success');
                    return refreshApex(this.wiredCaseRecord);
                })
                .catch((error) => {
                    console.error('Error updating Case record:', error);
                    if (error.body && error.body.output && error.body.output.errors &&
                        error.body.output.errors.length > 0 &&
                        error.body.output.errors[0].errorCode === 'FIELD_CUSTOM_VALIDATION_EXCEPTION') {
                        this.showToast('Error updating Case record', error.body.output.errors[0].message, 'error');
                    } else {
                        this.showToast('Error updating Case record', error.body.message, 'error');
                    }
                })
                .finally(() => {
                    this.isLoading = false;
                });;
        }
    }

    showToast(title, message, variant) {
        const toastEvent = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        });
        this.dispatchEvent(toastEvent);
    }

    closeModal() {
        this.showModal = false;
    }
}
