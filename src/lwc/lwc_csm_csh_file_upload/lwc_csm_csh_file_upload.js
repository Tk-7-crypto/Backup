import { LightningElement, api, track } from 'lwc';
import deleteContentDocument from '@salesforce/apex/CNT_CSM_PortalCreateCase.deleteContentDocument';
import UPLOAD_FILES_LABEL from '@salesforce/label/c.Upload_files';
import ATTACH_FILES_LABEL from '@salesforce/label/c.Attach_files';

export default class Lwc_csm_csh_file_upload extends LightningElement {
    @api required = false;
    @track loading = false;
    @track uploadedFiles = [];
    @track labels = {
        Upload_files: UPLOAD_FILES_LABEL,
        Attach_files: ATTACH_FILES_LABEL
    };

    handleUploadFinished(event) {
        const uploadedFiles = event.detail.files;
        this.uploadedFiles = [...this.uploadedFiles, ...uploadedFiles];
        const contentDocumentIds = uploadedFiles.map(file => file.documentId);
        const contentDocumentNames = uploadedFiles.map(file => file.name);
        const selectedEvent = new CustomEvent('contentdocumentadded', { detail: { data: contentDocumentIds, names: contentDocumentNames } });
        this.dispatchEvent(selectedEvent);
    }

    handleDelete(event) {
        const documentIdToDelete = event.target.value;
        const documentName = event.target.dataset.documentname;
        this.loading = true;
        deleteContentDocument({ contentDocumentId: documentIdToDelete })
            .then(result => {
                console.log('ContentDocument deleted successfully:', result);
                this.uploadedFiles = this.uploadedFiles.filter(file => file.documentId !== documentIdToDelete);
                const deletedEvent = new CustomEvent('contentdocumentdeleted', { detail: { data: documentIdToDelete, documentName: documentName } });
                this.dispatchEvent(deletedEvent);
            })
            .catch(error => {
                console.error('Error deleting ContentDocument:', error);
            })
            .finally(() => {
                this.loading = false;
            });
    }
}
