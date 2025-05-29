import { LightningElement, api, track, wire } from "lwc";
import getRecords from "@salesforce/apex/CNT_CLM_CommonController.getRecords";

export default class CustomLookup extends LightningElement {
    @api recordId;
    @api label;
    @api selectedRecord;
    @track initialResults = [];
    @track results = [];
    @api hasError = false;
    toggle = false;
    clicked = false;
    @api inputClass = "slds-combobox__form-element";

    @wire(getRecords, { recordId: "$recordId" })
    wiredResult({ data, error }) {
        if(data) {
            this.initialResults = data;
            this.results = data.slice(0, 3);
        } 
        else if(error) {
            console.error(error);
        }
    }

    handleToggle() {
        this.toggle = true;
    }

    handleSearch(event) {
        const searchTerm = event.target.value.toUpperCase();
        if(!searchTerm) {
            this.results = this.initialResults ? this.initialResults.slice(0, 3) : [];
            this.toggle = true;
        } 
        else if(this.initialResults && searchTerm) {
            this.results = this.initialResults.filter((e) => {
                return e.Name.toUpperCase().includes(searchTerm);
            });
        }
        if(this.results.length === 0) {
            this.toggle = false;
        }
    }

    handleSelect(event) {
        let recId = event.currentTarget.getAttribute("data-index");
        this.selectedRecord = this.initialResults ? this.initialResults.find((record) => record.Id === recId) : "";
    }

    handleClose(event) {
        this.hasError = false;
        this.inputClass = "slds-combobox__form-element";
        event.preventDefault();
        this.selectedRecord = "";
        this.results = this.initialResults ? this.initialResults.slice(0, 3) : [];
        this.toggle = true;
        setTimeout(() => {
            const inputElement = this.template.querySelector('[data-id="myInput"]');
            if(inputElement) {
                inputElement.focus();
            }
        }, 0);
    }

    handleBlur() {
        setTimeout(() => {
            this.toggle = false;
        }, 0);
    }
}
