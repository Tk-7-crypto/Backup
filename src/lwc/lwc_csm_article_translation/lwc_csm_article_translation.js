import { LightningElement, api, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getRecord } from 'lightning/uiRecordApi';
import checkTranslations from '@salesforce/apex/CNT_CSM_ArticleTranslation.checkTranslations';
import translateArticles from '@salesforce/apex/CNT_CSM_ArticleTranslation.translateArticles';
import updateTranslations from '@salesforce/apex/CNT_CSM_ArticleTranslation.updateTranslations';

export default class Lwc_csm_article_translation extends LightningElement {
    isModalOpen = false;
    showSpinner = true;
    showComponent = false;
    @api recordId;
    @track articleTranslation;

    @wire(getRecord, {
        recordId: '$recordId',
        fields: ['Knowledge__kav.PublishStatus']
    }) wirearticle({
        error,
        data
    }) {
        if (error) {
            console.log('ERROR in lwc_Csm_article_translation = ', error);
            this.error = error ; 
            this.showToast();
            this.showSpinner = false;
        } else if (data) {
            this.showSpinner = true;
            this.init();            
        }
    }
     
    init() {
        checkTranslations({articleId: this.recordId})
        .then(result => {
            this.articleTranslation = result;
            this.showComponent = result.showTranslationComponent;
            this.showSpinner = false;
        })
        .catch(error => {
            console.log('ERROR in lwc_Csm_article_translation = ', error);
            this.error = error;
            this.showToast();
            this.showSpinner = false;
        });
    }

    openTranslationModal() {
        this.openModal();
    }

    translateArticle() {
        this.closeModal();
        this.showSpinner = true;
        translateArticles({articleId : this.recordId, languagesForTranslationList: this.articleTranslation.languagesForTranslation})
            .then(result => {
                this.showSpinner = false;
                this.init();
                var message = 'Translation Completed';
                var toastEvent = new ShowToastEvent({
                    title: 'Success',
                    message: message,
                    variant: 'success'
                });
                this.dispatchEvent(toastEvent);
            })
            .catch(error => {
                console.log('ERROR in lwc_Csm_article_translation = ', error);
                this.showSpinner = false;
                this.error = error;
                this.showToast();
                this.showSpinner = false;
            });
    }

    updateTranslationsRecords() {
        this.closeModal();
        this.showSpinner = true;
        updateTranslations({articleId : this.recordId})
            .then(result => {
                this.showSpinner = false;
                this.init();
                var message = 'Translation updated';
                var toastEvent = new ShowToastEvent({
                    title: 'Success',
                    message: message,
                    variant: 'success'
                });
                this.dispatchEvent(toastEvent);
            })
            .catch(error => {
                console.log('ERROR in lwc_Csm_article_translation = ', error);
                this.showSpinner = false;
                this.error = error;
                this.showToast();
                this.showSpinner = false;
            });
    }
	
    openModal() {
        this.isModalOpen = true;
    }

    closeModal() {
        this.isModalOpen = false;
    }

    showToast() {
        var error = this.error;
        if(error != undefined && error != null && error != '' && error.body != undefined && error.body != null && error.body != '') {
            var errorMessage = error.body.message;
            var toastEvent = new ShowToastEvent({
                title: 'Error',
                message: errorMessage,
                variant: 'error'
            });
            this.dispatchEvent(toastEvent);
        }
    }	
}