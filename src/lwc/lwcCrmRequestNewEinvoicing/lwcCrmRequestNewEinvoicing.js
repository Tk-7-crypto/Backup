import { LightningElement, api, wire } from 'lwc';
import fetchBaseData from '@salesforce/apex/CNT_CRM_RequestNewEinvoicing.fetchBaseData';
import submitEinvoicingViaAPI from '@salesforce/apex/CNT_CRM_RequestNewEinvoicing.submitEinvoicingViaAPI';
import { CloseActionScreenEvent } from 'lightning/actions';

import ERROR_MSG_DUPLICATE_REQUEST from '@salesforce/label/c.CRM_CL0048_E_Invoicing_Error_Duplicate_Request';
import ERROR_MSG_MAIL_CONTACT_REQUIRED from '@salesforce/label/c.CRM_CL0049_E_Invoicing_Error_Mail_Contact_Required';
import ERROR_MSG__RECORD_EXIST from '@salesforce/label/c.CRM_CL0050_E_Invoicing_Error_Sales_org_already_has_3_Mail_Contact';
import SUCCESS_MSG from '@salesforce/label/c.CRM_CL0051_E_Invoicing_Success_Message';

export default class LwcCrmRequestNewEinvoicing extends LightningElement {

    @api recordId;
    showSpinner = true;
    requestSubmitted = false;
    disableSubmitButton = false;
    successMsg = SUCCESS_MSG;
    showError = false;
    errorMsg = new Set();
    address = new Object();
    salesOrgOptions = [{ label: '---None---', value: '' }];
    sapContactOptions = [{ label: '---None---', value: '' }];
    salesOrgToInvoiceMap = new Map();
    invoiceRec = new Object();

    @wire(fetchBaseData, { recordId: '$recordId' })
    fetchAllDetails({ data, error }) {
        if (data) {
            this.address = data.address;
            this.sapContactOptions = data.sapContactOptions;
            this.salesOrgOptions = data.salesOrgOptions;
            this.salesOrgToInvoiceMap = data.salesOrgToInvoiceMap;
            this.setInvoiceRecValues('', '', '');
            this.showSpinner = false;
        } else if (error) {
            this.handleError(error, 'error while fatching details');
        }
    }

    setInvoiceRecValues(m1, m2, m3) {
        this.invoiceRec.mailContact1 = m1 ? m1 : '';
        this.invoiceRec.mailContact2 = m2 ? m2 : '';
        this.invoiceRec.mailContact3 = m3 ? m3 : '';
        this.invoiceRec.disable1 = m1 ? true : false;
        this.invoiceRec.disable2 = m2 ? true : false;
        this.invoiceRec.disable3 = m3 ? true : false;
        if (m1 && m2 && m3) {
            this.disableSubmitButton = true;
        } else {
            this.disableSubmitButton = false;
        }
    }

    handleChange(event) {
        this.showSpinner = true;
        let fieldName = event.currentTarget.dataset.id;
        let salesOrg = event.target.value;
        salesOrg = salesOrg.substring(salesOrg.indexOf('[') + 1, salesOrg.indexOf(']'))
        if (fieldName === 'Sales_Org__c') {
            if (this.salesOrgToInvoiceMap && this.salesOrgToInvoiceMap.hasOwnProperty(salesOrg)) {
                let mit = this.salesOrgToInvoiceMap[salesOrg];
                this.setInvoiceRecValues(mit.SAP_Contact_1__c, mit.SAP_Contact_2__c, mit.SAP_Contact_3__c);
            } else {
                this.setInvoiceRecValues('', '', '');
            }
        }
        this.showSpinner = false;
    }

    handleSubmit() {
        try {
            this.showError = false;
            this.errorMsg = new Set();
            let eInvoice = new Object();
            let existingSapContact = new Set();
            eInvoice.Address__c = this.address.Id;
            this.template.querySelectorAll('lightning-combobox').forEach(item => {
                let fieldAPI = item.dataset.id;
                let value = item.value ? item.value : '';
                let isDisabled = item.disabled;
                if (isDisabled === false) {
                    eInvoice[fieldAPI] = value;
                } else {
                    existingSapContact.add(value);
                    eInvoice[fieldAPI] = '';
                }
                if (fieldAPI === "Sales_Org__c" && value == '') {
                    item.setCustomValidity("Complete this field.");
                    item.reportValidity();
                }
            });
            if (eInvoice) {
                if (eInvoice.Sales_Org__c === '') {
                    this.errorMsg.add('Sales Org is required');
                    this.showError = true;
                }
                if (existingSapContact.size === 3) {
                    this.errorMsg.add(ERROR_MSG__RECORD_EXIST);
                    this.showError = true;
                }
                if (!eInvoice.SAP_Contact_1__c && !eInvoice.SAP_Contact_2__c && !eInvoice.SAP_Contact_3__c) {
                    this.errorMsg.add(ERROR_MSG_MAIL_CONTACT_REQUIRED);
                    this.showError = true;
                }
                if (existingSapContact.has(eInvoice.SAP_Contact_1__c) || existingSapContact.has(eInvoice.SAP_Contact_2__c) || existingSapContact.has(eInvoice.SAP_Contact_3__c)) {
                    this.errorMsg.add(ERROR_MSG_DUPLICATE_REQUEST);
                    this.showError = true;
                }
                if ((eInvoice.SAP_Contact_1__c && eInvoice.SAP_Contact_2__c && eInvoice.SAP_Contact_1__c == eInvoice.SAP_Contact_2__c) ||
                    (eInvoice.SAP_Contact_2__c && eInvoice.SAP_Contact_3__c && eInvoice.SAP_Contact_2__c == eInvoice.SAP_Contact_3__c) ||
                    (eInvoice.SAP_Contact_3__c && eInvoice.SAP_Contact_1__c && eInvoice.SAP_Contact_3__c == eInvoice.SAP_Contact_1__c)) {
                    this.errorMsg.add("Mail Contacts value can't be same");
                    this.showError = true;
                }
                if (this.showError === false) {
                    this.showSpinner = true;
                    setTimeout(() => { this.submitRequest(eInvoice) }, 0);
                }
            }
        } catch (error) {
            this.handleError(error, 'Error while submit');

        }
    }

    submitRequest(eInvoice) {
        submitEinvoicingViaAPI({ invoiceRec: eInvoice, addressRec: this.address })
            .then(result => {
                if (result.success) {
                    this.successMsg = result.success;
                    this.requestSubmitted = true;
                } else if (result.error) {
                    this.handleError(result.error, 'error while saving api Call');
                }
                this.showSpinner = false;
            }).catch(error => {
                this.handleError(error, 'error while saving data');
            });
    }

    closePopup() {
        try {
            this.dispatchEvent(new CloseActionScreenEvent());
        } catch (error) {
            this.handleError(error, 'Error while closing popup');
        }
    }

    handleError(error, methodName) {
        console.log(methodName + ' : ' + JSON.stringify(error));
        console.log(error);
        this.errorMsg = new Set();
        if (typeof (error) === 'string') {
            this.errorMsg.add(error);
        } else {
            var err = error.body ? (error.body.message ? JSON.stringify(error.body.message) : JSON.stringify(error.body)) : JSON.stringify(error);
            if (JSON.parse(err).fieldErrors) {
                let fieldError = JSON.parse(err).fieldErrors;
                for (let [key, value] of Object.entries(fieldError)) {
                    this.errorMsg.add(key + ': ' + value[0].message);
                }
            } else {
                this.errorMsg.add(err == "{}" ? 'Unexpected error !!!' : err);
            }
        }
        this.showError = true;
        this.showSpinner = false;
    }

    get showForm() {
        return (this.address && this.requestSubmitted === false)
    }

    get title() {
        if (this.address) {
            return "Request e-invoicing for Address " + this.address.Name + " (SAP Base Code " + this.address.SAP_Reference__c + " )";
        } else {
            return "Request e-invoicing for Address (SAP Base Code )";
        }
    }

}