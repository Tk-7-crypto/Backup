import { LightningElement, wire, track, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';
import { updateRecord, deleteRecord } from 'lightning/uiRecordApi';
import getUploadedFiles from '@salesforce/apex/CNT_CLM_EnhancedFileRelatedList.getUploadedFiles';
import deleteContentDocument from '@salesforce/apex/CNT_CLM_EnhancedFileRelatedList.deleteContentDocument';
import updateContentDocument from '@salesforce/apex/CNT_CLM_EnhancedFileRelatedList.updateContentDocument';
import activationErrorMsg from '@salesforce/label/c.CLM_CL001_Validation_File_IQ_AGR';
import isEditDeleteAllowed from '@salesforce/apex/CNT_CLM_EnhancedFileRelatedList.isEditDeleteAllowed';

const ACTIONS = [
    { label: 'Edit', name: 'edit' },
    { label: 'Delete', name: 'delete' }
];

const COLUMNS = [
    {label: 'Title', fieldName: 'Title', type: 'button', typeAttributes: { label: { fieldName: 'Title'}, variant: 'base', title: {fieldName: 'FullTitle'}}, initialWidth: 250, cellAttributes: { iconName: {fieldName: 'IconName'}, iconPosition: 'left', class: 'icon-size_big'}, hideDefaultActions: true},
    {label: 'Description', fieldName: 'Description', type: 'text'},
    {label: 'Last Modified', fieldName: 'LastModifiedDate', type: 'date'},
    {label: 'Owner', fieldName: 'Owner', type: 'url', typeAttributes: { label: {fieldName: 'OwnerName'}, tooltip: {fieldName: 'OwnerName'}, target: '_self'}},
    {label: 'Size', fieldName: 'Size', type: 'text'},
    {type: 'action', typeAttributes: { rowActions: ACTIONS}},
];

export default class Lwc_clm_fileRelatedList extends NavigationMixin(LightningElement) {
    @api recordId;
    @api isFullView = false;
    @track showModal = false;
    @track description = '';
    @track uploadedFiles;
    @track wiredUploadedFiles;
    @track maxRecordsToDisplay = 6;
    @track isViewAll = false;
    @track count = 0;
    @track editRecordId;
    @track deleteRecordId;
    @track fileTitle = '';
    @track oldFileTitle = '';
    @track fileCreatedDate;
    @track fileLastModifiedDate;
    @track isActionAllowed;
    columns = COLUMNS;
    result;
    isUploadDisabled = true;
    byte = 1024;
    refinedData;
    stringSize;
    isEditModalOpen = false;
    isDeleteModalOpen = false;

    get descriptionOptions() {
        return [
            {label: 'Agreement Draft', value:'Agreement Draft'}, 
            {label: 'Pricing Document', value: 'Pricing Document'},
            {label: 'Approval', value: 'Approval'},
            {label: 'Other Document', value: 'Other Document'},
            {label: 'Document for Feedback', value: 'Document for Feedback'}
        ];
    }

    handleDescription(event) {
        this.description = event.detail.value;
        this.isUploadDisabled = !this.description;
    }

    handleDescriptionUpdate(event){
        this.description = event.detail.value;
    }

    handleTitleUpdate(event) {
        this.fileTitle = event.detail.value;
    }

    @wire(getUploadedFiles, {recordId: '$recordId'})
        wiredUploadedFiles(result) {
            const {data, error} = result;
            this.result = result;
            if(data) {
                if(data.length > this.maxRecordsToDisplay) {
                    this.isViewAll = true;
                    this.count = this.maxRecordsToDisplay + '+';
                } else {
                    this.count = data.length;
                }
                
                var tempData = JSON.parse(JSON.stringify(data));
                if(tempData.length > 0) {
                    tempData.forEach(record => {
                        if(record.Size !== null && record.Size !== undefined) {
                            record['Size'] = this.fileSizeToString(record.Size);
                        }
                        if(record.Title !== null && record.Title !== undefined) {
                            record['Title'] = this.truncateFileTitle(record.Title);
                        }
                        if(record.IconName !== null && record.IconName !== undefined) {
                            record['IconName'] = this.iconHandler(record.IconName);
                        }
                        if(record.OwnerId !== null && record.OwnerId !== undefined) {
                            record['Owner'] = `/lightning/r/User/${record.OwnerId}/view`;
                        }
                    }); 
                }
                this.refinedData = JSON.parse(JSON.stringify(tempData));

                if(!this.isFullView) {
                    this.uploadedFiles = this.refinedData.slice(0, this.maxRecordsToDisplay);
                } else if (this.isFullView) {
                    this.isViewAll = false;
                    this.uploadedFiles = this.refinedData;
                }    
            } else if(error) {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: error.body.message,
                        variant: 'error'
                    })
                );
            }
        }

        onRowActionHandler(event) {
            const action = event.detail.action;
            const rows = event.detail.row;

            switch (action.name) {
                case 'edit':
                    this.editRecord(rows);
                    break;
                case 'delete':
                    this.deleteRecord(rows);
                    break;
                default:
                    this.previewHandler(rows);
                    break;
            }
        }

        editRecord(row) {
            this.editRecordId = row.Id;
            const contentDocumentId = this.editRecordId;
            isEditDeleteAllowed({ contentDocumentId })
            .then(result => {
                this.isActionAllowed = result;
            })
            .then(() => {
                if(this.isActionAllowed) {
                    this.isEditModalOpen = true;
                    this.oldFileTitle = row.FullTitle;
                    this.fileTitle = row.FullTitle;
                    this.description = row.Description;
                    this.fileCreatedDate = this.formatDateTime(row.CreatedDate);
                    this.fileLastModifiedDate = this.formatDateTime(row.LastModifiedDate);
                } else {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error',
                            message: activationErrorMsg,
                            variant: 'error'
                        })
                    );
                }
            })
            .catch(error => {
                var errMsg = error.body.message;
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: errMsg,
                        variant: 'error'
                    })
                ); 
            })
        }

        deleteRecord(row) {
            this.deleteRecordId = row.Id;
            const contentDocumentId = this.deleteRecordId;
            isEditDeleteAllowed({ contentDocumentId })
            .then(result => {
                this.isActionAllowed = result;
            })
            .then(() => {
                if(this.isActionAllowed) {
                    this.isDeleteModalOpen = true;
                } else {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error',
                            message: activationErrorMsg,
                            variant: 'error'
                        })
                    );
                }
            })
            .catch(error => {
                var errMsg = error.body.message;
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: errMsg,
                        variant: 'error'
                    })
                );
            })
        }

        handleSave(){

            const contentDocumentId = this.editRecordId;
            const description = this.description;
            const title = this.fileTitle;
            updateContentDocument({contentDocumentId, description, title})
                .then(() => {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Success',
                            message: 'File has been updated succesfully.',
                            variant: 'success'
                        })
                    );
                })
                .then(() => {
                    this.isEditModalOpen = false;
                    return refreshApex(this.result);
                })
                .catch(error => {
                    this.closeEditModal();
                    var errMsg = null;
                    if(error.body.message.includes(activationErrorMsg)) {
                        errMsg = activationErrorMsg;
                    } else {
                        errMsg = error.body.message;
                    }
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error',
                            message: errMsg,
                            variant: 'error'
                        })
                    );
                });
        }

        confirmDelete(){
            const contentDocumentId = this.deleteRecordId;
            deleteContentDocument({contentDocumentId})
                .then(() => {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Success',
                            message: 'File has been deleted succesfully.',
                            variant: 'success'
                        })
                    );
                })
                .then(() => {
                    this.isDeleteModalOpen = false;
                    return refreshApex(this.result);
                })
                .catch(error => {
                    this.closeDeleteModal();
                    var errMsg = null;
                    if(error.body.message.includes(activationErrorMsg)) {
                        errMsg = activationErrorMsg;
                    } else {
                        errMsg = error.body.message;
                    }
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error',
                            message: errMsg,
                            variant: 'error'
                        })
                    );
                });
        }

        handleEditSuccess(){
            this.closeEditModal();
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: 'File has been updated succesfully.',
                    variant: 'success'
                })
            );
            return refreshApex(this.result);
        }

        previewHandler(rows) {
            this[NavigationMixin.Navigate]({
                type: 'standard__namedPage',
                attributes: {
                    pageName: 'filePreview'
                },
                state: {
                    selectedRecordId: rows.Id
                }
            });
        }

        handleUploadFinished(event) {
            const uploadedFiles = event.detail.files;
            if(uploadedFiles.length === 1) {

                const file = uploadedFiles[0];
                const contentDocumentId = file.documentId;
                const description = this.description;
                const title = null;
                
            updateContentDocument({contentDocumentId, description, title})
                .then( ()=> {
                    this.isFullView = false;
                    return refreshApex(this.result);
                })
                .then( ()=> {
                    this.showModal = false;
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Success',
                            message: 'Files have been added succesfully.',
                            variant: 'success'
                        })
                    );
                })
                .catch(error => {
                    var errMsg = null;
                    if(error.body.message.includes(activationErrorMsg)) {
                        errMsg = activationErrorMsg;
                    } else {
                        errMsg = error.body.message;
                    }
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error',
                            message: errMsg,
                            variant: 'error'
                        })
                    );
                });
            }
        }

        handleViewAll(event) {
            this.isFullView = true;
            let cmpDef = {
                componentDef: "c:lwc_clm_fileRelatedList",
                attributes: {
                    recordId: this.recordId,
                    isFullView: this.isFullView
                }
            };
        
            let encodedDef = btoa(JSON.stringify(cmpDef));
            this[NavigationMixin.Navigate]({
                type: "standard__webPage",
                attributes: {
                    url: "/one/one.app#" + encodedDef
                }
            });
        }

        openModal() {
            this.description = '';
            this.isUploadDisabled = true;
            this.showModal = true;
        }
    
        closeModal() {
            this.showModal = false;
        }

        closeEditModal() {
            this.isEditModalOpen = false;
        }

        closeDeleteModal() {
            this.isDeleteModalOpen = false;
        }
        
        fileSizeToString(size) {
            if(size < this.byte) {
                return (size.valueOf() + ' Byte');
            } else if(size >= this.byte && size < (this.byte*this.byte)) {
                return ((Math.round((size/this.byte)*100)/100).toFixed(1)+' KB');
            } else if(size >= (this.byte * this.byte) && size < (this.byte * this.byte * this.byte)) {
                return ((Math.round((size/(this.byte * this.byte)*100))/100).toFixed(1)+ ' MB');
            } else {
                return ((Math.round((size/(this.byte * this.byte * this.byte)*100))/100).toFixed(1)+ ' GB');
            }
        }

        truncateFileTitle(fileName) {
            var maxCharLength = 25;
            if(fileName.length > maxCharLength) {
                return (fileName.substring(0, maxCharLength-3) + '...');
            } else {
                return fileName;
            }
        }

        iconHandler(fileExtension) {
            if(fileExtension.toLowerCase() === 'docx' || fileExtension.toLowerCase() === 'doc') {
                return 'doctype:word';
            } else if(fileExtension.toLowerCase() === 'pdf') {
                return 'doctype:pdf';
            } else if(fileExtension.toLowerCase() === 'xls' || fileExtension.toLowerCase() === 'xlsx') {
                return 'doctype:excel';
            } else if(fileExtension.toLowerCase() === 'ppt' || fileExtension.toLowerCase() === 'pptx') {
                return 'doctype:ppt';
            } else if(fileExtension.toLowerCase() === 'zip') {
                return 'doctype:zip';
            } else if(fileExtension.toLowerCase() === 'xml') {
                return 'doctype:xml';
            } else if(fileExtension.toLowerCase() === 'txt') {
                return 'doctype:txt';
            } else if(fileExtension.toLowerCase() === 'png' || fileExtension.toLowerCase() === 'jpg' || fileExtension.toLowerCase() === 'jpeg') {
                return 'doctype:image';
            } else {
                return 'doctype:attachment';
            }
        }

        formatDateTime(dateTime) {
            const dateOptions = {
                year: 'numeric', 
                month: '2-digit', 
                day: '2-digit'
            }
            const dateTimeOptions = {
                ...dateOptions, 
                hour: '2-digit', 
                minute: '2-digit', 
                second: '2-digit', 
                hour12: true,
            };

            const hasTime = dateTime.includes('T');
            const options = hasTime ? dateTimeOptions : dateOptions;

            let formattedDate = new Intl.DateTimeFormat('en-US', options).format(new Date(dateTime));
            if(hasTime) {
                const parts = formattedDate.split(', ');
                const timePart = parts[1].toUpperCase();
                formattedDate = `${parts[0]} ${timePart}`;
            }
            return formattedDate;

        }
}