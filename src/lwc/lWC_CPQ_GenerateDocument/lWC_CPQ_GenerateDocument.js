import { LightningElement, api, track, wire } from 'lwc';
import generateDocument from '@salesforce/apex/CNT_CPQ_GenerateDocument.generateDocument';
import getAvailableTemplate from '@salesforce/apex/CNT_CPQ_GenerateDocument.getAvailableTemplate';
import getPricingTools from '@salesforce/apex/CNT_CPQ_GenerateDocument.getPricingTools';
import updateContentDocuments from '@salesforce/apex/CNT_CPQ_GenerateDocument.updateContentDocuments';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
const typeFormats = [
    {label : 'DOC', value : 'DOC'},
    {label : 'DOCX', value : 'DOCX'},
    {label : 'PDF', value : 'PDF'},
    {label : 'RTF', value : 'RTF'}
];
export default class LWC_CPQ_GenerateDocument extends LightningElement {
    @api recordId;
    @api objectApiName;
    formats = typeFormats;
    selectedFormat;
    documentToGenerate;
    formatSelection = "Select Output Format";
    availableTemplates = [];
    onLoadResponse;
    recId;
    objApiName;
    Documents = [];
    quoteRecord;
    generatedDocumentIds = [];
    seletedDocuments;
    loaded = true;

    connectedCallback() {
        this.loaded = false;
        let urlIndex = window.location.href.split('/');
        this.recordId = urlIndex[urlIndex.length - 2];
        this.objectApiName = urlIndex[urlIndex.length - 3];
        getPricingTools({recordId: this.recordId})
        .then(result => {
           if (result) {
                this.quoteRecord = result;
                var pricingTools = result.Pricing_Tools__c;
                getAvailableTemplate({recordId: this.recordId, objectAPIName : this.objectApiName, pricingTools : pricingTools})
                .then(result => {
                    if (result != 'Failed') {
                        this.onLoadResponse = result;
                        this.selectedFormat = '';
                        this.recId = this.recordId;
                        this.objApiName = this.objectApiName;
                        result.split(',').forEach(element => {
                            this.Documents.push({label : element, value : element});
                        })
                        this.selectedFormat = this.formats[0].value;
                    } else {
                        this.closeModal();
                        this.toast('Error', 'There is no document available.', 'error');
                    }
                    this.loaded = true;
                }).catch(error => {
                    this.loaded = true;
                });
            }
        }).catch(error => {
            console.log(error);
        });
    }
    getFormat(event) {
        this.selectedFormat = event.detail.value;
    }
    getDocument(event) {
        this.seletedDocuments = event.detail.value;
    }

    successMsgs = [];
    errorMsgs = [];
    generateDocument(){
        if (this.seletedDocuments != undefined && this.seletedDocuments.length > 0) {
            this.loaded = false;
            this.generateDoc(this.seletedDocuments, 0);
        } else {
            this.toast('Error', ' Please select at least one document.', 'error');
        }
    }

    generateDoc(templateList, index) {
        this.loaded = false;
        generateDocument({templateName: templateList[index], recordId: this.recordId, objectAPIName: this.objectApiName, format: this.selectedFormat})
        .then(result => {
            if (result !== null || result !== '' || result !== undefined) {
                this.generatedDocumentIds.push(result);
                this.successMsgs.push(templateList[index]);
            } else {
                this.errorMsgs.push(templateList[index]);
            }
            index++;
            if ( templateList.length > index) {
               this.generateDoc(templateList, index);
            } else {
                if(this.successMsgs.length > 0) {
                    if (this.quoteRecord.Approval_Stage__c === 'In-Progress') {
                        this.updateContentDocuments(this.generatedDocumentIds);
                    }
                    this.toast('Success', 'The selected document(s) have been generated successfully.', 'success');
                    location.reload();
                } else if (this.errorMsgs.length > 0) {
                    this.toast('Error', this.errorMsgs.join(',') + ' document generation failed.', 'error');
                }
                this.loaded != this.loaded;
                this.closeModal();
            }
        }).catch(error => {
            console.log(error);
            this.loaded != this.loaded;
            this.closeModal();
            index++;
            if (typeof templateList[index] !== 'undefined') {
                this.generateDoc(templateList, index);
            }
        });
    }

    updateContentDocuments(generatedDocumentIds) {
        updateContentDocuments({generatedDocuments: generatedDocumentIds})
        .then(result => {
            
        }).catch(error => {
            this.toast('Error', error.body ? error.body.message : error, 'error');
        });
    }
    
    toast(title, msg, variant, mode){
        const toastEvent = new ShowToastEvent({
            title: title,
            message: msg,
            variant: variant,
            mode: mode ? mode : 'dismissable'
        })
        this.dispatchEvent(toastEvent)
    }

    closeModal() {
        this.formatSelection = true;
        this.formats = [];
        this.Documents = [];
        this.seletedDocuments = '';
        this.dispatchEvent(new CustomEvent("closeaction"));
    }
}