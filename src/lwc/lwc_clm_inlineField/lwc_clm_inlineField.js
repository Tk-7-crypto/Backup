import { LightningElement, wire, track, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { getRecord } from 'lightning/uiRecordApi';

export default class Lwc_clm_inlineField extends NavigationMixin(LightningElement) {
    @api recordId;
    @api objectApiName;
    @api flowName;
    @api targetField;
    @api queryFields;
    @api left;
    @api compactFields;
    @api objectName;
    @api labelName;
    fields = [];
    isFlowOpen;
    isModalOpen;
    displayName;
    id;

    connectedCallback() {
        if (this.queryFields) {
            this.fields = this.queryFields.split(';');
        }
    }

    @wire(getRecord, { recordId: "$recordId", fields: "$fields" })
    wiredData({ data, error }) {
        if(data && this.flowName) {
            if(this.flowName == 'CLM_IQVIA_Account_Update_ScreenFlow') {
                if(data['fields'] && data['fields']['Subtype__c'] && data['fields']['Subtype__c']['value']) {
                    let subtype = data['fields']['Subtype__c']['value'];
                    if(subtype == 'Vendor Contract') {
                        this.labelName = 'Vendor Account';
                    }
                    else if(subtype == 'Sub Investigator Contract') {
                        this.labelName = 'Sub Investigator Account';
                    }
                    else if(subtype == 'Clinic Contract') {
                        this.labelName = 'Clinic Site';
                    }
                    else if(subtype == 'Investigator Contract') {
                        this.labelName = 'PI';
                    }
                }
            }
            if(data['fields'] && data['fields'][this.targetField] && data['fields'][this.targetField]['value']) {
                this.id = data['fields'][this.targetField]['value']['id'];
            }
            if(data['fields'] && data['fields'][this.targetField] && data['fields'][this.targetField]['displayValue']) {
                this.displayName = data['fields'][this.targetField]['displayValue'];
            }

        }
        else if(error) {
            console.error(error);
        }
    }

    openModal() {
        this.isFlowOpen = true;
    }

    closeModal() {
        this.isFlowOpen = false;
        window.location = "/lightning/r/" + this.objectApiName + "/" + this.recordId + "/view";
    }

    get inputVariables() {
        return [
            {
                name: "recordId",
                type: "String",
                value: this.recordId,
            },
        ];
    }

    handleMouseLeave(event) {
        this.isModalOpen = false;
    }

    handleMouseEnter(event) {
        let rect = event.target.getBoundingClientRect();
        this.left = rect.right;
        this.isModalOpen = true;
    }

    handleOnClick(event) {
        var id = event.target.dataset.id;
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: id,
                actionName: 'view'
            },
        });
    }
}