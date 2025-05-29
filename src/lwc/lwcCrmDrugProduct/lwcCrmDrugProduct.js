import { LightningElement, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import saveDrugProductRecords from "@salesforce/apex/CNT_CRM_DrugProduct.saveDrugProductRecords";
import getOldDrugProductValue from "@salesforce/apex/CNT_CRM_DrugProduct.getOldDrugProductValue";
import findRecords from "@salesforce/apex/CNT_CRM_AutoCompleteSearch.findRecords";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

const COLUMNS = [
    { label: 'International Drug Name', fieldName: 'International_Drug_Name__c', type: 'text', sortable: true, initialWidth: 200 },
    { label: 'Local Drug Name', fieldName: 'Local_Drug_Name__c', type: 'text', sortable: true, initialWidth: 200 },
    { label: 'Molecule Name', fieldName: 'Molecule_Name__c', type: 'text', sortable: true, wrapText: true }
];
export default class LwcCrmDrugProduct extends NavigationMixin(LightningElement) {

    objectApiName = 'Drug_Product__c';
    filterField = 'Name, Local_Drug_Name__c, International_Drug_Name__c';
    fieldSet = 'Name, Local_Drug_Name__c, Molecule_Name__c, International_Drug_Name__c';
    recordLimit = '100';
    columns = COLUMNS;
    helpText = 'Drug/product is required. If OPP is related to therapeutic area select Asset Agnostic+ DISEASE. If not related to therapeutic area, select Asset Agnostic (OTHERS). If related to medical devices or consumer health products select MedTech or Consumer Health.';

    @api recordId;
    @api searchedData;
    @api showSpinner = false;
    products = [];
    oldDrugProductValue = '';

    getOldDrugProductValue() {
        getOldDrugProductValue({ opportunityId: this.recordId })
            .then((result) => {
                this.oldDrugProductValue = result;
            })
            .catch((error) => {
                this.handleError(error, 'getOldDrugProductValue');
            });
    }

    // To get Opportunity Id From URL and load default Data
    connectedCallback() {
        this.showSpinner = true;
        /* Remove this comments if using new Button to Override
        const params = new Proxy(new URLSearchParams(window.location.search), {
            get: (searchParams, prop) => searchParams.get(prop)
        });
        let inContextOfRef = params.inContextOfRef;
        if (inContextOfRef.startsWith("1\.")) { inContextOfRef = inContextOfRef.substring(2); }
        var addressableContext = JSON.parse(window.atob(inContextOfRef));
        this.recordId = addressableContext.attributes.recordId;
        */
        this.loadDefaultData();
    }

    disconnectedCallback() {
        this.recordId = null;
    }

    // Helper Method to Load default data on Component initialization
    loadDefaultData() {
        findRecords({ searchKey: '', objectName: this.objectApiName, filterField: '', fieldSet: this.fieldSet, recordLimit: this.recordLimit })
            .then((result) => {
                this.getOldDrugProductValue();
                this.handleTableRecords(result);
                this.showSpinner = false;
            })
            .catch((error) => {
                this.showSpinner = false;
                this.handleError(error, 'loadDefaultData');
            });
    }

    // To update datatable based on newly quired records
    handlelistdatachange(event) {
        let selectedRecordId = event.detail.selectedRecordId;
        this.handleTableRecords(event.detail.recordsListFull);
        this.template.querySelector('c-lwc-crm-datatable').showSearchRecordList();
    }

    // Helper method to set default(URL) fields for master data to show in dataTable
    handleTableRecords(data) {
        var tempData = JSON.parse(JSON.stringify(data)); // as cached object is not modifiable, create new object
        this.products = tempData;
        if (this.products && this.products.length > 0) {
            this.products.forEach(function (products) {
                try {
                    products['recordURL'] = '/' + products.Id;
                    let displayName = products.Local_Drug_Name__c
                    if (products.Molecule_Name_Long__c != undefined && products.Molecule_Name_Long__c != null && products.Molecule_Name_Long__c != products.Local_Drug_Name__c) {
                        displayName += ' (' + (products.Molecule_Name_Long__c).toLowerCase() + ')';
                    }
                    products['displayName'] = displayName;
                } catch (error) {
                    this.handleError(error, 'handleTableRecords');
                }
            });
            this.searchedData = this.products;
        } else {
            this.searchedData = [];
        }
    }

    // To handle Save Event from lwcCrmDatatable
    handleSave(event) {
        this.showSpinner = true;
        var productIds = event.detail.selectedRecordIds;
        saveDrugProductRecords({ productIds: productIds, parentId: this.recordId })
            .then(result => {
                this.showSpinner = false;
                if (result == true) {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Success',
                            message: 'Drug products added successfully',
                            variant: 'success'
                        })
                    );
                    this.handleCancel();
                }
            })
            .catch((error) => {
                this.handleError(error, 'handleSave');
                this.showSpinner = false;
            });
    }

    // To handle cancel event from lwcCrmDatatable
    handleCancel(event) {
        eval("$A.get('e.force:refreshView').fire();");
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.recordId,
                objectApiName: 'Opportunity',
                actionName: 'view'
            },
        });
    }

    handleError(error, methodName) {
        console.log(methodName + ' : ' + JSON.stringify(error));
        console.log(error);
        var errorMsg = new Array();

        var err = error.body ? (error.body.message ? JSON.stringify(error.body.message) : JSON.stringify(error.body)) : JSON.stringify(error);
        var errorCode = (error.body && error.body.errorCode) ? error.body.errorCode : error.status ? error.status : '';

        if (Object.keys(JSON.parse(err).fieldErrors).length > 0) {
            let fieldError = JSON.parse(err).fieldErrors;
            for (let [key, value] of Object.entries(fieldError)) {
                errorMsg.push(key + ': ' + value[0].message);
                errorCode = value[0].statusCode;
            }
        } else if (Object.keys(JSON.parse(err).pageErrors).length > 0) {
            let pageErrors = JSON.parse(err).pageErrors;
            for (let [key, value] of Object.entries(pageErrors)) {
                errorMsg.push(value.message);
                errorCode = value.statusCode;
            }
        } else {
            errorMsg.push(err == "{}" ? 'Unexpected error !!!' : err);
        }
        if (errorCode === 'DUPLICATE_VALUE') {
            errorMsg[0] = 'Drug Name is already Selected';
        }
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Error ' + errorCode,
                message: errorMsg[0],
                variant: 'error',
                mode: 'pester'
            })
        );
        this.showSpinner = false;
    }
}