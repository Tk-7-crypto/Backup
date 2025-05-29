import { LightningElement, wire, track } from 'lwc';
import {CurrentPageReference } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getConfig from '@salesforce/apex/CNT_OWF_GenericCollectionTool.getConfig';

export default class LwcOwfGenericCollectionToolWrapper extends LightningElement {
    @track collectionData;
    configList;
    isLoading;
    _bidHistoryId;
    get bidHistoryId() {
        return this._bidHistoryId;
    }
    set bidHistoryId(value) {
        this.isLoading = true;
        this._bidHistoryId = value;
        this.getConfigList();
    } 

    @wire(CurrentPageReference)
        getStateParameters(currentPageReference) {
        if (currentPageReference) {
            const urlValue = currentPageReference.state.c__Bid_History;      
            if (urlValue) {
                this.bidHistoryId = urlValue;
            } else {
                this.showToast('Error', 'Invalid Parameters, please try again.', 'Error', 'dismissable');
            }
        }
    }


    getConfigList() { 
        getConfig({ bidHistoryId: this.bidHistoryId })
        .then(result => {
           this.configList = result;
            this.isLoading = false;
        }).catch(error => {          
            console.log(JSON.stringify(error));  
            this.showToast('Error', error.body?.message, 'Error', 'dismissable');
            this.isLoading = false;
        }).finally(() => {
        });
    }
    
    showToast(title,message,variant,mode) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
            mode: mode
        });
        this.dispatchEvent(event);
    }

}