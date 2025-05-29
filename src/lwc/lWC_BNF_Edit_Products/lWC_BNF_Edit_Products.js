import { LightningElement, wire, api,track } from 'lwc';
import getIsAboveThreshold from '@salesforce/apex/CNT_CRM_Edit_products.getIsAboveThreshold';
import fetchAllDetailsOnLoad from '@salesforce/apex/CNT_CRM_Edit_products.fetchAllDetailsOnLoad';
import { CurrentPageReference,NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
export default class LWC_BNF_Edit_Products extends LightningElement {
    Contract_Start_Date__c = new Date();
    Contract_End_Date__c = new Date();
    recId ='';
    @api allFetchData = {};
    oliList;
    @api isNewBnf = false;
    productSelected;
    bnfRecord;
    isBNFIntegratedRecord = false;
    isBNFManualRecord = false;
    isMiBNFRecord = false;
    glossaryDocumentUrl = '/servlet/servlet.FileDownload?file=';
    @wire(CurrentPageReference) currentPageReference;

    fetchAllDetailsOnLoadJS(){
        fetchAllDetailsOnLoad({recsId : this.recId})
        .then(result => {
            console.log(result);
            console.log(result.opptyLineItem2);
            if (result) {
                if(result.glossaryDocumentId != null && result.glossaryDocumentId != undefined)
                    this.glossaryDocumentUrl = this.glossaryDocumentUrl + result.glossaryDocumentId;
                if(result.objectType == 'BNF2__c'){
                    if(result.RecordType == 'SAP SD Integrated'){
                        this.isBNFIntegratedRecord = true;
                    }else{
                        this.isBNFManualRecord = true;
                    }
                }else{
                    this.isMiBNFRecord = true;
                }
                this.productSelected = result.opptyLineItem2;
                this.bnfRecord = result.bnfRecord;
                this.allFetchData.profitCenterOptions = result.profitCenterOptions;
                this.allFetchData.LocalekeyFormat = result.LocalekeyFormat;
                this.allFetchData.isNewBnf = result.isNewBnf;
                this.allFetchData.CurrentUser = result.CurrentUser;
                this.allFetchData.oliIdToTherapyAreaOptionsMap = result.oliIdToTherapyAreaOptionsMap;
                this.allFetchData.DeliveryMedia_Map = result.DeliveryMedia_Map;
                this.allFetchData.DeliveryFrequency_Map = result.DeliveryFrequency_Map;
                this.allFetchData.HasZrepZlicProduct = result.HasZrepZlicProduct;
                this.allFetchData.isProfitCenterReadOnlyList = result.isProfitCenterReadOnlyList;
            }
        })
        .catch(error => {
            console.log(error.body.message);
            this.error = error.body.message;
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: this.error,
                    variant: 'error',
                }),
            );
            this.showSpinner = false;
        });
    }
    connectedCallback() {
        this.recIdFromState();
        getIsAboveThreshold({recsId : this.recId})
        .then(result => {
            if(result){
                this.fetchAllDetailsOnLoadJS();
            }else{
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: 'Opportunity Number is less then Threshold please Use Desktop Version',
                        variant: 'error',
                    }),
                );
                setTimeout(() => {
                    window.location.href = '/'+this.recId;
                }, 3000);
            }
        })
        .catch(error => {
            console.log(error);
            this.error = error.body.message;
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: this.error,
                    variant: 'error',
                }),
            );
        })
    }

    recIdFromState() {
        this.recId = this.currentPageReference.state.c__recordId;        
    }
    
    get recordURL(){
        return '/'+this.recId;
    }

}