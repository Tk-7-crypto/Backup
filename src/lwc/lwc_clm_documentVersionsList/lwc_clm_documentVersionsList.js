import { LightningElement, wire, track, api } from 'lwc';
import getAllDocVersions from '@salesforce/apex/CNT_CLM_Document_Versions_Controller.getAllDocVersions';
import updateDocumentTitle from '@salesforce/apex/CNT_CLM_Document_Versions_Controller.updateDocumentTitle';
import deleteDocumentVersions from '@salesforce/apex/CNT_CLM_Document_Versions_Controller.deleteDocumentVersions';
import unlockDocumentVersion from '@salesforce/apex/CNT_CLM_Document_Versions_Controller.unlockDocumentVersion';
import { NavigationMixin } from 'lightning/navigation'
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';

export default class Lwc_clm_documentVersionsList extends NavigationMixin(LightningElement) {
    @api recordId;
    @track dvData = [];
    count;
    isModalOpen;
    @track checkedBoxesIds = [];
    @track checkedBoxes = [];
    title;
    result;
    isLoading;
	isDialogOpen;
    index;

    @wire(getAllDocVersions, { recordId: '$recordId' })
    wiredData(result) {
        const { data, error } = result;
        this.result = result;
        if(error) {
            console.error(error);
        } 
        else if(data) {
            var newData = data.map((item) => Object.assign({}, item, { isActive: false, isEdit: false, titleName: '', contentId: '', reviewLink: '', isModifiable: false, isChecked: false, isLocked: false, lockedBy: '' }));
            for(var i = 0; i < newData.length; i++) {
                newData[i].titleName = String(window.location.origin) + '/lightning/r/' + newData[i].Id + '/view';
                if(newData[i].Apttus__LatestReviewCycleStatus__c !== 'Null') {
                    newData[i].reviewLink = String(window.location.origin) +  '/lightning/cmp/Apttus__ParallelReviewCycleContainer?Apttus__recordId=' + newData[i].Id;
                } else {
                    newData[i].Apttus__LatestReviewCycleStatus__c = '';
                }
                if(newData[i].Apttus__LatestReviewCycleStatus__c == '' || newData[i].Apttus__LatestReviewCycleStatus__c == 'Completed' || newData[i].Apttus__LatestReviewCycleStatus__c == 'Cancelled') {
                    newData[i].isModifiable = true;
                }
                if(newData[i].LastModifiedBy === undefined) {
                    newData[i].LastModifiedBy = {};
                    newData[i].LastModifiedBy.Name = '';
                }
                if(newData[i].Title_Click_to_view__c) {
                    newData[i].Title_Click_to_view__c = (String(window.location.origin) + newData[i].Title_Click_to_view__c.match(/href="([^"]*)/)[1]);
                } else {
                    newData[i].Title_Click_to_view__c = '#'
                }
                if(newData[i].Apttus__CheckoutById__c != null && newData[i].Apttus__CheckoutDate__c != null && newData[i].Apttus__CheckoutVersionDetailId__c != null) {
                    newData[i].isLocked = true;
                    newData[i].lockedBy = 'Locked By: ' +newData[i].Apttus__CheckoutById__r.Name;
                }
                if(newData[i].Apttus__LatestVersionId__c === undefined) {
                    newData[i].Apttus__Document_Version_Details__r = [];
                }      
                newData[i].contentId = (newData[i].Apttus__LatestVersionId__c)  ? newData[i].Apttus__LatestVersionId__r.Apttus__ContentId__c  : '' ;
                if(newData[i].Apttus__Document_Version_Details__r) {
                    var newDetailData = newData[i].Apttus__Document_Version_Details__r.map(item => Object.assign({}, item, { titleName: '#', typeName: '' }));
                    newData[i].Apttus__Document_Version_Details__r = newDetailData;
                    newData[i].Apttus__Document_Version_Details__r = newData[i].Apttus__Document_Version_Details__r.filter(obj => obj.Id != newData[i].Apttus__LatestVersionId__c);
                    for(var j = 0; j < newData[i].Apttus__Document_Version_Details__r.length; j++) {
                        newData[i].Apttus__Document_Version_Details__r[j].typeName = String(window.location.origin) + '/lightning/r/' + newData[i].Apttus__Document_Version_Details__r[j].Id + '/view';
                        if(newData[i].Apttus__Document_Version_Details__r[j].View__c) {
                            newData[i].Apttus__Document_Version_Details__r[j].titleName = String(window.location.origin) + newData[i].Apttus__Document_Version_Details__r[j].View__c.match(/href\="([^"]*)/)[1];
                        }
                        else {
                            newData[i].Apttus__Document_Version_Details__r[j].titleName = '#';
                        }
                    }
                }
            }
            this.dvData = newData;
            this.count = data.length;
        }
    }

    constructor() {
        super();
    }

    handleOnChange(event) {
        var j = event.target.getAttribute('data-index');
        this.dvData.forEach(review => {
            if(review.isActive) {
                review.isActive = false;
            }
            else {
                review.isActive = (review.Id == event.target.getAttribute('data-index'));
            }
        });
    }

    handleOnChangeEdit(event) {
        var j = event.target.getAttribute('data-index');
        this.dvData.forEach(review => {
            if(review.isEdit) {
                review.isEdit = false;
            }
            else {
                review.isEdit = (review.Id == event.target.getAttribute('data-index'));
            }
        });
    }

    previewHandler(event) {
        if(event.target.dataset.id) {
            this[NavigationMixin.Navigate]({
                type: 'standard__namedPage',
                attributes: {
                    pageName: 'filePreview'
                },
                state: {
                    selectedRecordId: event.target.dataset.id
                }
            })
        }
        else {
            var errorMessage = 'No Document Exists';
            this.showToast(errorMessage);
        }
    }

    handleBlankFile(event) {
        if(event.currentTarget.dataset.value == '#') {
            var errorMessage = 'No Document Exists';
            this.showToast(errorMessage);
        }
    }

    openModal(event) {
        this.isModalOpen = true;
    }

    closeModal(event) {
        this.isModalOpen = false;
    }
	
	openDialog (event) {
        this.isDialogOpen = true;
        this.index = event.target.dataset.id;
	}
	
	closeDialog (event) {
		this.isDialogOpen = false;
	}

    handleCheckboxChange(event) {
        this.checkedBoxesIds = [...this.template.querySelectorAll('lightning-input')]
            .filter(element => element.checked)
            .map(element => element.dataset.id);
    }

    inputChange(event) {
        this.title = event.target.value;
    }

    handleSave(event) {
        let g = event.target.dataset.id;
        let titleName = this.dvData[g].Apttus__Title__c;
        let t = titleName;
        if(this.title) {
            titleName = this.title;
            updateDocumentTitle({
                docVerId: this.dvData[g].Id,
                title: titleName
            })
            .catch(error => {
                let errorMessage = '';
                if(error.body.message) {
                    errorMessage = error.body.message;
                }
                this.showToast(errorMessage);
                this.dvData[g].Apttus__Title__c = t;
            });
        }
        this.dvData[g].isEdit = false;
        this.dvData[g].Apttus__Title__c = titleName;
        this.title = '';
    }

    handleDelete(event) {
        this.checkedBoxesIds.sort(function (a, b) { return a - b; });
        for(let i = this.checkedBoxesIds.length - 1; i >= 0; i--) {
            this.checkedBoxes.push(this.dvData[this.checkedBoxesIds[i]].Id);
            this.dvData.splice(this.checkedBoxesIds[i], 1);
        }
        this.isModalOpen = false;
        this.count = this.dvData.length;
        deleteDocumentVersions({
            docVerIds: this.checkedBoxes
        })
        .catch(error => {
            let errorMessage = '';
            if(error.body.message) {
                errorMessage = error.body.message;
            }
            this.showToast(errorMessage);
        });
        this.checkedBoxesIds = [];
        [...this.template.querySelectorAll('lightning-input')]
        .forEach(e => {
            e.checked = false;
        });
    }
	
	handleUnlock(event) {
		let dIndex = this.index;      
		unlockDocumentVersion({
			docVerId: this.dvData[dIndex].Id
		})
		.then(() => {
            this.closeDialog(event);
            refreshApex(this.result);
         })
		.catch(error => {
                let errorMessage = '';
                if(error.body.message) {
                    errorMessage = error.body.message;
                }
                this.showToast(errorMessage);
        });		
	}

    showToast(errorMessage) {
        const event = new ShowToastEvent({
            title: 'Error Occurred !!',
            message: errorMessage,
            variant: 'error',
            mode: 'sticky'
        });
        this.dispatchEvent(event);
    }

    handleRefresh(event) {
        this.isLoading = true;
        refreshApex(this.result)
        .then(() => this.isLoading = false)
        .catch(() => this.isLoading = false);
    }
}