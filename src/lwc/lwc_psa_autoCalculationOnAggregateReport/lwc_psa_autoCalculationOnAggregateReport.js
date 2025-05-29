import { LightningElement,track,api } from 'lwc';
import { CloseActionScreenEvent } from 'lightning/actions';
import autoCalculationDateOnAR from '@salesforce/apex/CNT_PSA_AutoCalculationOnAR.autoCalculationDateOnAR';
import updateAggregateReport from '@salesforce/apex/CNT_PSA_AutoCalculationOnAR.updateAggregateReport';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
export default class Lwc_psa_autoCalculationOnAggregateReport extends LightningElement {
    @track isModalOpen = true;
    @api recordId;
    @track isLoaded =  false;
    @track isError = false;
    @track aggregateReportList = [];
    @track metadataMap = [];
    @track messege = 'Planned fields will get auto calculated. Do you want to proceed?';
    @track errorMessege = '';
    @track isWantToChange = false;
    handleCancel() {
        this.dispatchEvent(new CloseActionScreenEvent());
    }
    handleOkay(){
        this.isLoaded = true;
        this.isError = false;
        autoCalculationDateOnAR({ recordId: this.recordId }).then((result) => {
            if(result.response === 'success'){
                this.showMessege( 'Successfully Aggregate Report Record Update','Success','success' );
                    this.isLoaded = false;
                    window.open("/"+this.recordId,'_self');
                    //this.dispatchEvent(new CloseActionScreenEvent());
                    this.isWantToChange = true;
            }
            if(result.response === 'alert'){
                this.isWantToChange = true;
                this.aggregateReportList = result.aggregateReportToRetrieveList;
                this.metadataMap = result.metaDataMap;
                this.isError = false;
                this.messege = result.validationMessage;
                this.isLoaded = false;
            }else{
                this.isError = true;
                this.errorMessege = JSON.stringify(result.errorMessage);
                setTimeout(() => {
                    this.isLoaded = false;
                }, 1000);
            }
       });
    }
    handleToUpdateRecord(){
        updateAggregateReport({ aggregateReportToRetrieveList: this.aggregateReportList,  KeyToMetaDataListMap : this.metadataMap}).then((result) => {
            if(result === 'success'){
                this.showMessege( 'Successfully Aggregate Report Record Update','Success','success' );
                this.isLoaded = false;
                window.open("/"+this.recordId,'_self');
                //this.dispatchEvent(new CloseActionScreenEvent());

            }else{
                this.isError = true;
                this.errorMessege = JSON.stringify(result);
                
                setTimeout(() => {
                    this.isLoaded = false;
                }, 1000);
            }
       });
    }
    showMessege(msg,title,variantType) {
        const event = new ShowToastEvent({
            title: title,
            message: msg,
            variant: variantType
        });
        this.dispatchEvent(event);
    }
}
