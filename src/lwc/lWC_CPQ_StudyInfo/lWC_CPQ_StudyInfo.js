import { LightningElement, wire, track } from 'lwc';
import { CurrentPageReference, NavigationMixin} from 'lightning/navigation';
import { ShowToastEvent } from "lightning/platformShowToastEvent";

import getStudyInformation from '@salesforce/apex/CNT_CPQ_QuoteWorkflow.getStudyInformation';

export default class LWC_CPQ_StudyInfo extends NavigationMixin(LightningElement) {

    isLoading = true;
    isStudyAvailable = false;
    @track studyNumber;
    @track quoteId;

    @wire(CurrentPageReference)
    setCurrentPageReference(currentPageReference) {
        this.studyNumber = currentPageReference.state?.c__Id;
        this.quoteId = currentPageReference.state?.c__QuoteId;
    }

    connectedCallback() {
        this.getStudyInformation(this.studyNumber, this.quoteId);
    }

    getStudyInformation(studyNumber, quoteId) {
        getStudyInformation({studyNumber: studyNumber, quoteId: quoteId})
            .then((data) => {
                this.isLoading = false;
                this.isStudyAvailable = true;
                var recId = data[0].Id;
                this[NavigationMixin.Navigate]({
                    type: 'standard__recordPage',
                    attributes: {
                        recordId: recId,
                        objectApiName: 'Quote_Requisites__c',
                        actionName: 'view'
                    }
                });
            })
            .catch(error => {
                this.isLoading = false;
                this.isStudyAvailable = false;
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: "Error",
                        message: error.body != null ? error.body.message : "Please try accessing the related Study Information from the Cart",
                        variant: "error",
                    }),
                );
            }
        );
    }
}