import { LightningElement, api, track, wire } from 'lwc';
import getContentDocumentLinks from '@salesforce/apex/CNT_CSM_RelatedList.getContentDocumentLinks';
import getEmailMessages from '@salesforce/apex/CNT_CSM_RelatedList.getEmailMessages';
import getCaseArticles from '@salesforce/apex/CNT_CSM_RelatedList.getCaseArticles';
import deleteContentDocumentById from '@salesforce/apex/CNT_CSM_RelatedList.deleteContentDocumentById';
import TITLE_LABEL from '@salesforce/label/c.Title';
import TYPE_LABEL from '@salesforce/label/c.Type';
import LAST_MODIFIED_LABEL from '@salesforce/label/c.Last_Modified';

export default class Lwc_prm_related_list extends LightningElement {
    @api objectName;
    @api type;
    @api iconName;
    @api title;
    @api recordId;
    @track data = [];
    @track columns;
    @track isLoading;
    connectedCallback() {
        this.doInit();
    }

    doInit() {
        if (this.type === 'CombinedAttachments') {
            this.columns = [
                {
                    label: TITLE_LABEL, fieldName: 'downloadUrl', type: 'url',
                    typeAttributes: { label: { fieldName: 'title' }, target: '_blank' }
                },
                { label: TYPE_LABEL, fieldName: 'fileType', type: 'text' },
                { label: LAST_MODIFIED_LABEL, fieldName: 'lastModified', type: 'date' }];
        } else if (this.type === 'EmailMessages') {
            this.columns = [
                {
                    label: 'Subject',
                    fieldName: 'UrlName',
                    type: 'url',
                    typeAttributes: { label: { fieldName: 'Subject' }, target: '_blank' }
                },
                { label: 'From Address', fieldName: 'FromAddress', type: 'email' },
                { label: 'To Address', fieldName: 'ToAddress', type: 'email' },
                { label: 'Date', fieldName: 'LastModifiedDate', type: 'date' }
            ];
        } else if (this.type === 'CaseArticles') {
            this.columns = [
                {
                    label: 'Title',
                    fieldName: 'UrlName',
                    type: 'url',
                    typeAttributes: { label: { fieldName: 'Title' }, target: '_blank' }
                },
                {
                    label: 'Number',
                    fieldName: 'UrlName',
                    type: 'url',
                    typeAttributes: { label: { fieldName: 'ArticleNumber' }, target: '_blank' }
                },
                { label: 'Last Modified', fieldName: 'LastModifiedDate', type: 'date' }
            ];

            if (this.objectName === 'Case') {
                this.columns.push({
                    label: 'Delete',
                    type: 'button-icon',
                    typeAttributes: { disabled: false, name: 'delete', title: 'Click to Delete', iconName: 'utility:delete' }
                });
            }
        }

        this.getDatas();
    }

    processData(data) {
        return data.map(item => {
            return {
                ...item,
                downloadUrl: item.latestPublishedVersionId
                    ? `/partner/sfc/servlet.shepherd/version/download/${item.latestPublishedVersionId}`
                    : `/partner/servlet/servlet.FileDownload?file=${item.id}`
            };
        });
    }

    getDatas() {
        if (this.type === 'CombinedAttachments') {
            this.getContentDocumentLinks();
        } else if (this.type === 'EmailMessages') {
            this.getEmailMessages();
        } else if (this.type === 'CaseArticles') {
            this.getCaseArticles();
        }
    }

    getContentDocumentLinks() {
        this.isLoading = true;
        getContentDocumentLinks({ recordId: this.recordId })
            .then(data => {
                this.data = this.processData(data);
            })
            .catch(error => {
                console.error('Error fetching data:', error);
            })
            .finally(() => {
                this.isLoading = false;
            });
    }

    getEmailMessages() {
        this.isLoading = true;
        getEmailMessages({ recordId: this.recordId })
            .then(data => {
                this.data = data;
                this.isLoading = true;
            })
            .catch(error => {
                console.error('Error fetching data:', error);
            })
            .finally(() => {
                this.isLoading = false;
            });
    }

    getCaseArticles() {
        this.isLoading = true;
        getCaseArticles({ recordId: this.recordId })
            .then(data => {
                this.data = data;
            })
            .catch(error => {
                console.error('Error fetching data:', error);
            })
            .finally(() => {
                this.isLoading = false;
            });
    }

    handleRowAction(event) {
        const action = event.detail.action;
        const row = event.detail.row;

        switch (action.name) {
            case 'view':
                this.previewDocument(row);
                break;
            case 'delete':
                if (row.parentType === 'email') {
                    // Handle delete logic for email attachments
                } else {
                    const confirmed = window.confirm('Are you sure you want to delete this file?');
                    if (confirmed) {
                        this.deleteContentDocumentById(row.id);
                    }
                }
                break;
            default:
                break;
        }
    }

    previewDocument(row) {
        this.dispatchEvent(new CustomEvent('previewdocument', { detail: { contentDocumentId: row.id } }));
    }

    deleteContentDocumentById(contentDocumentId) {
        deleteContentDocumentById({ contentDocumentId, recordId: this.recordId })
            .then(() => {
                this.getDatas();
            })
            .catch(error => {
                console.error('Error deleting content document:', error);
            });
    }
}