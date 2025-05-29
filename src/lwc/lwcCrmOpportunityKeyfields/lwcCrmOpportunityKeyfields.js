import { LightningElement, api, wire } from 'lwc';
import getData from '@salesforce/apex/CNT_CRM_CustomLightningPath.getData';
import getKeyFields from '@salesforce/apex/CNT_CRM_CustomLightningPath.getKeyFields';
import getGuidance from '@salesforce/apex/CNT_CRM_CustomLightningPath.getGuidance';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class LwcCrmOpportunityKeyfields extends LightningElement {
    @api recordId;
    @api stageName;
    showSpinner = false;
    openPopup = false;
    @wire(getData) mdt;
    @wire(getKeyFields, { stageName: '$stageName',mdt:'$mdt.data' }) fields;
    @wire(getGuidance, { stageName: '$stageName' ,mdt:'$mdt.data' }) guidance;

    connectedCallback() {
    }

    get hasValuesToShow(){
        return (this.fields.data != null || this.guidance.data != null);
    }

    openPopupfun() {
        this.openPopup = true;
        document.body.style.overflow = "hidden";
        document.body.style.height = "100%";
    }

    closePopup(event) {
        document.body.style.overflow = "auto";
        document.body.style.height = "auto";
        this.openPopup = false;
    }

    handleSubmit(event) {
        this.showSpinner = true;
    }

    handleError(event) {
        this.showSpinner = false;
    }

    handleSuccess(event) {
        this.showSpinner = false;
        this.openPopup = false;
        document.body.style.overflow = "auto";
        document.body.style.height = "auto";
        this.dispatchEvent(
            new ShowToastEvent({
                title: '',
                message: 'Opportunity was saved.',
                variant: 'Success',
            }),
        );
    }
}