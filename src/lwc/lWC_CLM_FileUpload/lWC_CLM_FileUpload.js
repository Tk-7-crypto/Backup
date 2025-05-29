import { LightningElement, api, track } from "lwc";
import { FlowAttributeChangeEvent } from "lightning/flowSupport";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import deleteFile from "@salesforce/apex/CNT_CLM_CommonController.deleteFile";

export default class LWC_CLM_FileUpload extends LightningElement {
    @api recordId;
    @track filesData = [];
    showSpinner = false;
    @api fileDt;
    @api records;
    @api label;
    @api isMultiple;
    @api isMandatory;
    @api titles;
    @api fData;
    @api title;
    @api wrapperList;
    isDisabled;
    
    @api
    get disabled() {
        return this.isDisabled;
    }
    
    set disabled(value) {
        this.isDisabled = value;
        if(this.filesData.length == 1) {
            deleteFile({
                conDocId: this.filesData[0].id
            })
            .catch((error) => {
                let errorMessage = "";
                if(error.body.message) {
                    errorMessage = error.body.message;
                }
                this.showToast(errorMessage);
            });
            this.dispatchEvent(new FlowAttributeChangeEvent("fData", ''));    
            this.dispatchEvent(new FlowAttributeChangeEvent("title", ''));
            this.filesData = [];
        }
    }    

    connectedCallback() {
        if(this.fData) {
            this.filesData = JSON.parse(this.fData);
        }
    }
    
    handleFileUploaded(event) {
        this.title = null;
        if(this.filesData.length == 1 && !this.isMultiple) {
            deleteFile({
                conDocId: event.detail.files[0].documentId,
            })
            .then(() => {
                this.showToast("Error!", "error", "Only 1 file could be uploaded.");
            })
            .catch((error) => {
                let errorMessage = "";
                if(error.body.message) {
                    errorMessage = error.body.message;
                }
                this.showToast(errorMessage);
            });
        } 
        else if(event.detail.files.length > 0) {
            for(var i = 0; i < event.detail.files.length; i++) {
                let fileName = event.detail.files[i].name;
                this.filesData.push({
                    title: fileName,
                    id: event.detail.files[i].documentId,
                    conVerId: event.detail.files[i].contentVersionId,
                });
            }
            this.filesData.forEach(file=> {
                this.title = (this.title != null) ? (this.title + ', ' + file.title) : file.title;    
            });
            this.dispatchEvent(new FlowAttributeChangeEvent("fData", JSON.stringify(this.filesData)));
            this.dispatchEvent(new FlowAttributeChangeEvent("title", this.title));
            this.dispatchEvent(new FlowAttributeChangeEvent("wrapperList", this.filesData));
        }
    }

    handleFileDelete(event) {
        this.title = '';
        var index = event.target.dataset.id;
        this.filesData.splice(index, 1);
        deleteFile({
            conDocId: event.target.getAttribute("data-index"),
        })
        .catch((error) => {
            let errorMessage = "";
            if(error.body.message) {
                errorMessage = error.body.message;
            }
            this.showToast(errorMessage);
        });
        this.filesData.forEach(file => {
            this.title += file.title + ', ';
        });
        if(this.title) {
            this.title = this.title.substring(0, this.title.length - 2);
        }
        this.dispatchEvent(new FlowAttributeChangeEvent("title", this.title));
        this.dispatchEvent(new FlowAttributeChangeEvent("fData", JSON.stringify(this.filesData)));
        this.dispatchEvent(new FlowAttributeChangeEvent("wrapperList", this.filesData));
    }

    @api
    validate() {
        if((this.isMandatory && this.filesData.length > 0) || !this.isMandatory) {
            return { isValid: true };
        } 
        else if(this.isMandatory && this.filesData.length == 0) {
            return {
                isValid: false,
                errorMessage: "Please upload a file.",
            };
        }
    }

    showToast(title, variant, message) {
        this.dispatchEvent(
            new ShowToastEvent({
                title: title,
                variant: variant,
                message: message,
            })
        );
    }
}