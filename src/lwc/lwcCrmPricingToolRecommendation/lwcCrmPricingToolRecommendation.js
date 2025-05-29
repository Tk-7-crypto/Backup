import { LightningElement, api, wire } from 'lwc';
import getPricingTool from '@salesforce/apex/CNT_CRM_Pricing_Tool_Recommendation.getPricingTool';
import setPricingTool from '@salesforce/apex/CNT_CRM_Pricing_Tool_Recommendation.setPricingTool';
import { getRecord, updateRecord } from 'lightning/uiRecordApi';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';


export default class LwcCrmPricingToolRecommendation extends NavigationMixin(LightningElement) {

    @api recordId;
    RecommenedPricingTool;
    OtherPricingTool = [];
    errorMsg;
    openPopup = false;
    error = false;
    showSpinner = false;
    pricingToolSelected;
    showReasonDetailSection = false;

    connectedCallback() {
        this.showSpinner = true;
        if (this.recordId) {
            this.refreshPricingTool();
        }
    }

    @wire(getRecord, { recordId: '$recordId', fields: ['LastModifiedDate'] })
    getCurrentRecord({ data, error }) {
        if (data) {
            this.showSpinner = true;
            this.refreshPricingTool();
        } else if (error) {
            console.log('gcr.error : ', error);
            this.showSpinner = false;
        }
    }

    refreshPricingTool() {
        getPricingTool({ recordId: this.recordId })
            .then(result => {
                if (result != undefined && result != null && result != '') {
                    this.RecommenedPricingTool = result.RecommenedPricingTool;
                    this.OtherPricingTool = result.OtherPricingTool;
                    this.error = false;
                }
            })
            .catch(error => {
                console.log('rpt.error : ', error);
                this.error = true;
                var err = error.body ? (error.body.message ? JSON.stringify(error.body.message) : JSON.stringify(error.body)) : JSON.stringify(error);
                this.errorMsg = err == "{}" ? 'Unexpected error !!!' : err;
            })
            .finally(() => {
                this.showSpinner = false;
            });
    }
    
    handleOnLoad(event) {        
        var record = event.detail.records;
        var fields = record[this.recordId].fields;
        const reasonPricingTool = fields.Reason_for_choosing_Other_Pricing_Tool__c.value;
        if(reasonPricingTool == 'Other') {
            this.showReasonDetailSection = true;
        }
    }

    //popup functions
    openPopupfun() {
        this.openPopup = true;
        document.body.style.overflow = "hidden";
        document.body.style.height = "100%";
    }

    closePopup(event) {
        document.body.style.overflow = "auto";
        document.body.style.height = "auto";
        this.showReasonDetailSection = false;
        this.openPopup = false;
        this.showSpinner = false;
    }

    handleSubmit(event) {
        this.showSpinner = true;
        event.preventDefault();
        const fields = event.detail.fields;
        if(fields.Reason_for_choosing_Other_Pricing_Tool__c != 'Other')
            fields.Other_Pricing_Tool_Details__c = '';
        this.template.querySelector('lightning-record-edit-form').submit(fields);
    }

    handleError(event) {
        this.showSpinner = false;
    }

    handleSuccess(event) {
        this.closePopup();
        this.navigateToPricingTool();

    }

    handlePricingToolChange(event) {
        this.showReasonDetailSection = false;
        if(event.target.value == 'Other') {
            this.showReasonDetailSection = true;
        }
    }

    //on Select/click any Pricing Tool
    openPricingTool(event) {
        this.pricingToolSelected = event.target.name;
        var labelName = event.currentTarget.dataset.id;
        if (labelName == 'recommened') {
            this.navigateToPricingTool();
        } else if (labelName == 'other') {
            this.openPopupfun();
        }

    }

    skipReason(event) {
        this.closePopup();
        this.navigateToPricingTool();
    }

    navigateToPricingTool() {
        this.showSpinner = true;
        setPricingTool({ recordId: this.recordId, pricingToolSelected: this.pricingToolSelected })
        .then(result => {
        if(this.pricingToolSelected == 'Pricing Assistant') {
            updateRecord({ fields: { Id: this.recordId } });
            this[NavigationMixin.GenerateUrl]({
                type: 'standard__recordRelationshipPage',
                attributes: {
                    recordId: this.recordId,
                    objectApiName: 'PC_Pricing_Calculator__x',
                    relationshipApiName: 'Pricing_Assistants__r',
                    actionName: 'view'
                }
            }).then(url => {
            window.open(url, "_blank");
            });
        } else if (result != undefined && result != null && result != '') {
            // update details Section with new values
            updateRecord({ fields: { Id: this.recordId } });
            // Navigation to web page 
            this[NavigationMixin.Navigate]({
                "type": "standard__webPage",
                "attributes": {
                    "url": result
                }
            });
            //window.open(result);
        } else {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error!',
                    message: 'Somthing went wrong or the tool you select does not exiest !!!',
                    variant: 'error',
                }),
            );
            }
        })
        .catch(error => {
            console.log('npt.error : ', error);
            this.error = true;
            var err = error.body ? (error.body.message ? JSON.stringify(error.body.message) : error.body.pageErrors ? (error.body.pageErrors[0].message) : JSON.stringify(error.body)) : JSON.stringify(error);
            this.errorMsg = err == "{}" ? 'Unexpected error !!!' : err;
        })
        .finally(() => {
            this.closePopup();
        });
    }
}