import { LightningElement, wire, api , track} from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import {deleteRecord } from 'lightning/uiRecordApi';
import getAgreementClause from '@salesforce/apex/CNT_CLM_IQVIARelatedList.getAgreementClause';
import hasEditAccess from '@salesforce/apex/CNT_CLM_IQVIARelatedList.hasEditAccess';
import hasDeleteAccess from '@salesforce/apex/CNT_CLM_IQVIARelatedList.hasDeleteAccess';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';
export default class Lwc_clm_iqviaRelatedList extends NavigationMixin(LightningElement) {
    @api recordId;
    @api relatioshipName;
    @api parentObjName;
    @api childObjName;
    @track count = 0;
    @track maxRecordsToDisplay = 6;
    @track isViewAll = true;
    @track columns = [];
    @track clauses;
    @track tempData = [];
    @track isEdit = false;
    @track isDelete = false;
    isLoading;
    result;
    parentrecordId;
    rowId;
    isDeleteModalOpen = false;

    @wire(getAgreementClause, {recordId: '$recordId'})
        wiredAgreementClause(result) {
            const { data, error } = result;
            this.result = result;
            if(error) {
                console.error(error);
            } 
            else if(data) {
                this.checkPermission()
                    .then(()=> this.buildColumns());
                if(data.length > this.maxRecordsToDisplay) {
                    this.isViewAll = false;
                    this.count = this.maxRecordsToDisplay + '+';
                } else {
                    this.count = data.length;
                }              
                if(data.length > 0) {
                    this.parentrecordId = data[0].Apttus__Agreement__c;
                    this.tempData = data.map(record => 
                    ({...record, nameUrl: 'lightning/r/Apttus__Agreement_Clause__c/'+record.Id+'/view'}));
                }
                if(!this.isViewAll) {
                    this.clauses = this.tempData.slice(0, this.maxRecordsToDisplay);
                } else {
                    this.clauses = this.tempData;
                }
            }
        }

        checkPermission() {
            return new Promise((resolve, reject) => {
                hasEditAccess({objectAPIName : this.childObjName})
                .then(editResult => {
                    this.isEdit = editResult;
                    return hasDeleteAccess({objectAPIName : this.childObjName});
                })
                .then(deleteResult => {
                    this.isDelete = deleteResult;
                    resolve();
                })
                .catch(error => {
                    reject(error);
                });
            });
        }

        buildColumns() {
            const actions = [];           
            if(this.isEdit) {                
                actions.push({
                    'label': 'Edit',
                    'name': 'edit',
                });
            }
            if(this.isDelete){
                actions.push({
                    'label':  'Delete',
                    'name' : 'delete'
                });
            }
            if(!this.isEdit && !this.isDelete){
                actions.push({
                    'label':  'No actions available',
                    'name' : 'no actions available',
                    'disabled' : true
                });
            }
            this.columns = [
                {label: 'Number', fieldName: 'nameUrl', type: 'url', typeAttributes: { label: {fieldName: 'Name'}, target: '_self'}, initialWidth: 110},
                {label: 'Action', fieldName: 'Apttus__Action__c', type: 'text', initialWidth: 130},
                {label: 'Clause', fieldName: 'Apttus__Clause__c', type: 'text', wrapText: true},
                {label: 'Category', fieldName: 'Apttus__Category__c', type: 'text', initialWidth: 165},
                {type: 'action', typeAttributes: { rowActions: actions}},
            ];
        }

        onRowActionHandler(event) {
            const action = event.detail.action;
            const rows = event.detail.row;
            switch (action.name) {
                case 'edit':
                    this.handleEditButton(rows);
                    break;
                case 'delete':
                    this.handleDeleteButton(rows);
                    break;
            }
        }

        handleViewAll() {
            this[NavigationMixin.Navigate]({
                type: 'standard__recordRelationshipPage',
                attributes: {
                    recordId: this.parentrecordId,
                    objectApiName: this.parentObjName,
                    relationshipApiName: this.relatioshipName,
                    actionName: 'view'
                },
            });
        }

        handleNewButton(){
            this[NavigationMixin.Navigate]({
                type: 'standard__objectPage',
                attributes: {
                    objectApiName: this.childObjName,
                    actionName: 'new'
                },
                state : {
                    nooverride: '1',
                    navigationLocation: 'RELATED_LIST'
                }
            });
        }

        handleRefresh() {
            this.isLoading = true;
            refreshApex(this.result)
            .then(() => this.isLoading = false)
            .catch(() => this.isLoading = false);
        }
    
        handleEditButton(rows) {
            this[NavigationMixin.Navigate]({
                type: "standard__recordPage",
                attributes: {
                    recordId: rows.Id,
                    actionName: "edit"
                },
            });
        }
    
        closeModal() {
            this.isDeleteModalOpen = false;
        }

        handleDeleteButton(rows) {
            this.isDeleteModalOpen = true;
            this.rowId = rows.Id;
        }

        confirmDelete(){
            this.isDeleteModalOpen = false;
            deleteRecord(this.rowId)
            .then(() => {
                this.handleRefresh();
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Agreement Clause Deleted Successfully.',
                        variant: 'success'
                    })
                );
            })
            .catch((error) => {
                this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error deleting record',
                            message: reduceErrors(error).join(', '),
                            variant: 'error'
                        })
                );
            });
        }
}