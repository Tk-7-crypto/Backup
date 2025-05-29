import { LightningElement, api } from 'lwc';
import hasNonZpubProducts from '@salesforce/apex/CNT_CPQ_QuoteWorkflow.checkNonZPubProducts';
import { subscribe, unsubscribe, onError } from 'lightning/empApi';

export default class LWC_CPQ_Warning_For_Non_ZPUB_Product extends LightningElement {
    @api recordId;
    isValidated = false;
    channelName = '/event/QuoteLineItemEvent__e'; 
    subscription = null;
    @api bannerMessage;
    @api typeOfWarning;

    get divClass() {
        return  `slds-notify slds-notify_toast slds-m-bottom_small slds-theme_${this.typeOfWarning || 'warning'}`;
    }

    get iconName() {
         return  `utility:${this.typeOfWarning || 'warning'}`;
    }

    connectedCallback() {
        this.fetchNonZpubProducts();
        this.subscribeToPlatformEvent();
    }

    fetchNonZpubProducts() {
        hasNonZpubProducts({ quoteId: this.recordId })
            .then(data => {
                this.isValidated = data;
            })
            .catch(this.handleError);
    }

    subscribeToPlatformEvent() {
        subscribe(this.channelName, -1, this.handleEvent)
            .then(response => {
                this.subscription = response;
            })
            .catch(this.handleError);

        onError(this.handleError);
    }

    handleEvent = (response) => {
        this.fetchNonZpubProducts();
    };

    handleError(error) {
        console.error('Error: ', error);
    }

    disconnectedCallback() {
        if (this.subscription) {
            unsubscribe(this.subscription);
        }
    }
}