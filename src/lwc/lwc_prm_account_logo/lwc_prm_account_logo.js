import { LightningElement, api, wire } from 'lwc';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import { getFieldValue, getRecord } from 'lightning/uiRecordApi';
import { NavigationMixin } from 'lightning/navigation';

import appendFileName from  '@salesforce/apex/CNT_PEP_AccountLogo.appendFileName';
import isLogoAvailable from '@salesforce/apex/CNT_PEP_AccountLogo.isLogoAvailable';
import getLogoContentVersionId from '@salesforce/apex/CNT_PEP_AccountLogo.getLogoContentVersionId';
import deleteLogoById from '@salesforce/apex/CNT_PEP_AccountLogo.deleteLogoById';

import PARENT_ID from '@salesforce/schema/Account.ParentId';

const FIELDS = [
    PARENT_ID
];

const imagePath = '/sfc/servlet.shepherd/version/download/';

export default class Lwc_prm_account_logo extends NavigationMixin(LightningElement) {
    account;

    contentDocumentId;
    logoContentVersionId;

    showReplaceLogoButton;
    showLogo;
    showUploadLogo = true;
    showCloseButton;

    @api recordId;

    @wire(getRecord, { recordId: '$recordId', fields: FIELDS })
    getRecordData({data, error}){
        if(data){
            this.account = data;
            console.log('Record id - ' + this.recordId + ' - ' + this.parentId);
            isLogoAvailable({recordId: this.recordId})
            .then(documentId => {
                if(documentId){
                    this.showReplaceLogoButton = true;
                    this.getLogoId(documentId);
                }else{
                    this.showReplaceLogoButton = false;
                    if(this.parentId)
                        this.checkIfLogoAvailable(this.parentId);
                }
            })
            .catch(error => {
                this.handleError(error);
            });
        }else if(error){
            this.handleError(error);
        }
    };

    get parentId(){
        return getFieldValue(this.account, PARENT_ID);
    }

    get imageLink(){
        return imagePath + this.logoContentVersionId;
    }

    get acceptedFormats() {
        return ['.png'];
    }

    checkIfLogoAvailable(Id){
        isLogoAvailable({recordId: Id})
        .then(documentId => {
            if(documentId)
                this.getLogoId(documentId);
        })
        .catch(error => {
            this.handleError(error);
        });
    }

    getLogoId(docId){
        getLogoContentVersionId({documentId: docId})
        .then(logoId => {
            if(logoId){
                this.showLogo = true;
                this.showUploadLogo = false;
                this.contentDocumentId = docId;
                this.logoContentVersionId = logoId;
            }
        })
        .catch(error => {
            this.handleError(error);
        });
    }

    downloadImage(){
        console.log('Download button clicked');
        this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: {
                url: this.imageLink
            }
        }, false);
    }

    replaceLogo(){
        this.showLogo = false;
        this.showUploadLogo = true;
        this.showCloseButton = true;
    }

    closeUpload(){
        this.showLogo = true;
        this.showUploadLogo = false;
        this.showCloseButton = false;
    }

    changeDocumentName(documentId, append){
        appendFileName({contentDocumentId: documentId, appendString: append})
        .then(result => {
            this.showNotification(
                'Account logo uploaded succesfully.',
                'success'
            );
        })
        .catch(error => {
            this.handleError(error);
        });
    }

    handleUploadFinished(event) {
        this.showReplaceLogoButton = true;
        this.showLogo = true;
        this.showUploadLogo = false;
        this.showCloseButton = false;

        const uploadedFiles = event.detail.files;
        this.logoContentVersionId = uploadedFiles[0].contentVersionId;

        if(this.contentDocumentId){
            deleteLogoById({docId: this.contentDocumentId})
            .then(() => {})
            .catch(error => {
                this.handleError(error);
            });
        }else{
            this.contentDocumentId = uploadedFiles[0].documentId;
        }

        this.changeDocumentName(uploadedFiles[0].documentId, '_LOGO');
    }

    handleError(error){
        this.error = 'Unknown error';
        if (Array.isArray(error.body)) {
            this.error = error.body.map(e => e.message).join(', ');
        } else if (typeof error.body.message === 'string') {
            this.error = error.body.message;
        }

        this.showNotification(this.error, 'error');
    }

    showNotification(message, variant) {
        const evt = new ShowToastEvent({
            'message': message,
            'variant': variant
        });
        this.dispatchEvent(evt);
    }
}