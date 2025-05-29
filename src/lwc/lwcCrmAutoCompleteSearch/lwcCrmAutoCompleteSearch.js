import { LightningElement, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { encodeDefaultFieldValues } from "lightning/pageReferenceUtils";
import findRecords from "@salesforce/apex/CNT_CRM_AutoCompleteSearch.findRecords";

export default class LwcCrmAutoCompleteSearch extends NavigationMixin(LightningElement) {
    recordsList;
    recordsListFull;
    searchKey = "";
    message;
    selectedRecordList = [];
    @api showCreateNewButton = false;
    @api selectedRecordId = null;
    @api objectApiName;
    @api filterField;
    @api fieldSet
    @api iconName;
    @api lookupLabel;
    @api name;
    @api recordLimit = '100';
    @api helpText = '';

    onLeave(event) {
        setTimeout(() => {
            // this.searchKey = "";
            this.recordsList = null;
        }, 300);
    }

    // To handle search 
    handleKeyChange(event) {
        this.searchKey = event.target.value;
        this.getLookupResult(event, '');
    }

    //Helper Method to query record based on new Search Key
    getLookupResult(event, call) {
        findRecords({ searchKey: this.searchKey, objectName: this.objectApiName, filterField: this.filterField, fieldSet: this.fieldSet, recordLimit: this.recordLimit })
            .then((result) => {
                if (result.length === 0) {
                    this.recordsList = [];
                    this.recordsListFull = [];
                    this.message = "0 results are found.";
                } else {
                    //this.recordsList = (result.length > 10) ? result.slice(0, 10) : result;
                    this.recordsListFull = result;
                    this.message = "";
                }
                this.error = undefined;

                this.recordsList = null;
                const selectedEvent = new CustomEvent("listdatachange", {
                    detail: { recordsListFull: this.recordsListFull, selectedRecordId: this.selectedRecordId }
                });
                this.dispatchEvent(selectedEvent);
            })
            .catch((error) => {
                console.log('error key : ' + JSON.stringify(error));
                this.error = error;
                this.recordsList = undefined;
                this.recordsListFull = undefined;
            });
    }

    /*
    // used if showing Seach result in the lookup search result
    onRecordSelection(event) {
        this.selectedRecordId = event.target.dataset.key;
        this.recordsList.forEach(element => {
            if (element.Id == event.target.dataset.key) {
                this.selectedRecordList = element;
            }
        });

        this.searchKey = event.target.dataset.name;
        this.getLookupResult(event, 'rec');
    }

    removeRecordOnLookup(event) {
        this.searchKey = "";
        this.selectedRecordId = null;
        this.recordsList = null;
    }

    // used if showing createNewRecord
    createNewRecord(event) {
        const defaultValues = encodeDefaultFieldValues({
            Name: this.searchKey,
        });

        this[NavigationMixin.Navigate]({
            type: "standard__objectPage",
            attributes: {
                objectApiName: this.objectApiName,
                actionName: "new",
            },
            state: {
                defaultFieldValues: defaultValues,
            },
        });
    }
    */
}