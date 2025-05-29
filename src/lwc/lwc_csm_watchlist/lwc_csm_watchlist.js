import { LightningElement, api, track, wire } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import USER_ID from '@salesforce/user/Id';
import NAME_FIELD from '@salesforce/schema/User.Name';
import PROFILE_NAME_FIELD from '@salesforce/schema/User.Profile.Name';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getCase from '@salesforce/apex/CNT_CSM_CaseWathcList.getCase';
import findRecords from '@salesforce/apex/CNT_CSM_CaseWathcList.searchUserGroup';
import watchUserList from '@salesforce/apex/CNT_CSM_CaseWathcList.watchUserList';
import saveRecord from '@salesforce/apex/CNT_CSM_CaseWathcList.updateWatchListUser';


export default class Lwc_csm_watchlist extends LightningElement {
    @track records;
    @track userList;
    @track error;
    @track selectedRecord;
    @api index;
    @api relationshipfield;
    @api iconname = "standard:user";
    searchType = 'user';
    searchPlaceholder = 'Search User to Add in Case Watch List';
    @api recordId;
    @track error;
    @api searchfield = 'Name';
    @track caseRecord;
    @api username = '';
    showSpinner;
    @track showremove = false;
    currentUser;
    showEditButton = false;

    @wire(getRecord, {
        recordId: USER_ID,
        fields: [NAME_FIELD, PROFILE_NAME_FIELD]
    }) wireuser({
        error,
        data
    }) {
        if (error) {
            this.error = error;
            this.showToast();
        } else if (data) {
            var currentUser = { userName: '', userProfile: '' };
            currentUser.userName = data.fields.Name.value;
            currentUser.userProfile = data.fields.Profile.value.fields.Name.value;
            this.currentUser = currentUser;
        }
    }


    connectedCallback() {
        this.getCase();
    }

    getCase() {
        getCase({ caseId: this.recordId })
            .then(result => {
                this.caseRecord = result;
                this.getWatchUserList();
                this.error = undefined;
            })
            .catch(error => {
                this.error = error;
                this.showToast();
            });
    }

    getWatchUserList() {
        this.userList = undefined;
        this.showSpinner = true;
        watchUserList({ usersId: this.caseRecord.Watch_List_User__c })
            .then(result => {
                this.userList = result;
                for (let i = 0; i < this.userList.length; i++) {
                    const rec = this.userList[i];
                    this.userList[i].Name = rec[this.searchfield];
                }
                this.error = undefined;
                this.showSpinner = false;
                this.showEditButton = true;
            })
            .catch(error => {
                this.error = error;
                this.showToast();
                this.showSpinner = false;
            });
    }

    handleOnchange(event) {
        this.username = event.target.value;
        const searchKey = this.username;
        /* eslint-disable no-console */
        if (searchKey == undefined || searchKey == '' || searchKey.length < 2) {
            this.records = undefined;
        } else {
            /* Call the Salesforce Apex class method to find the Records */
            this.showSpinner = true;
            findRecords({
                searchKey: searchKey,
                type: this.searchType
            })
                .then(result => {
                    this.records = result;
                    for (let i = 0; i < this.records.length; i++) {
                        const rec = this.records[i];
                        this.records[i].Name = rec[this.searchfield];
                    }
                    this.error = undefined;
                    this.showSpinner = false;
                    this.showremove = false;
                    //console.log(' records ', this.records);
                })
                .catch(error => {
                    this.error = error;
                    this.records = undefined;
                    this.username = undefined;
                    this.showSpinner = false;
                    this.showToast();
                });
        }
    }



    get typeOptions() {
        return [
            { label: 'User', value: 'user' },
            { label: 'Queue', value: 'group' },
        ];
    }

    handleChangeSearchType(event) {
        this.selectedRecord = undefined;
        this.searchType = event.detail.value;
        if (this.searchType === 'user') {
            this.searchPlaceholder = 'Search User to Add in Case Watch List';
            this.iconname = "standard:user";
        } else {
            this.searchPlaceholder = 'Search Queue to Add in Case Watch List';
            this.iconname = "standard:queue"
        }
    }

    handleSelect(event) {
        const selectedRecordId = event.detail;
        /* eslint-disable no-console*/
        this.selectedRecord = this.records.find(record => record.Id === selectedRecordId);
        this.records = undefined;
        this.username = undefined;
        /* fire the event with the value of RecordId for the Selected RecordId */
        const selectedRecordEvent = new CustomEvent(
            "selectedrec",
            {
                //detail : selectedRecordId
                detail: { recordId: selectedRecordId, index: this.index, relationshipfield: this.relationshipfield }
            }
        );
        this.dispatchEvent(selectedRecordEvent);
    }

    handleRemove(event) {
        event.preventDefault();
        this.selectedRecord = undefined;
        this.error = undefined;
        /* fire the event with the value of undefined for the Selected RecordId */
        const selectedRecordEvent = new CustomEvent(
            "selectedrec",
            {
                detail: { recordId: undefined, index: this.index, relationshipfield: this.relationshipfield }
            }
        );
        this.dispatchEvent(selectedRecordEvent);
    }

    handleAddUser() {
        let temp = 0;
        const str = this.caseRecord.Watch_List_User__c;
        if (str != undefined) {
            var index = str.indexOf(this.selectedRecord.Id);
            if (index !== -1) {
                temp = 1;
                this.selectedRecord = undefined;
                this.showErrorToast();
            }
            if (str.length > 20) {
                if (str.split(',').length == 50) {
                    temp = 1;
                    this.showErrorToast1();
                }
            }
        }
        if (temp == 0) {
            this.showSpinner = true;
            saveRecord({
                caseId: this.recordId,
                watchIds: this.caseRecord.Watch_List_User__c,
                userId: this.selectedRecord.Id
            })
                .then(result => {
                    this.caseRecord = result;
                    this.getWatchUserList();
                    this.showSuccessToast();
                    this.error = undefined;
                    this.selectedRecord = undefined;
                    this.showSpinner = false;
                })
                .catch(error => {
                    this.error = error;
                    this.selectedRecord = undefined;
                    this.showSpinner = false;
                    this.showToast();
                });
        }
    }

    handleUpdate() {
        this.showremove = true;
    }
    handleCancel() {
        this.showremove = false;
    }

    handleRemoveUser(event) {
        event.preventDefault();
        const selectedRecordId = event.target.value;
        var updatelist = this.caseRecord.Watch_List_User__c;
        var myList = updatelist.split(',');
        myList = myList.filter(value => value !== selectedRecordId);
        myList = myList.toString();
        if (myList.startsWith(',')) {
            myList = myList.subString(1, myList.length);
        }
        this.showSpinner = true;
        saveRecord({
            caseId: this.recordId,
            watchIds: myList,
            userId: null
        })
            .then(result => {
                this.caseRecord = result;
                if (this.caseRecord.Watch_List_User__c == '') {
                    this.userList = undefined;
                } else {
                    this.getWatchUserList();
                }
                this.showRemoveToast();
                this.error = undefined;
                this.showSpinner = false;
            })
            .catch(error => {
                this.error = error;
                this.showSpinner = false;
                this.showToast();
            });
    }

    showSuccessToast() {
        const evt = new ShowToastEvent({
            title: 'Success',
            message: 'User or Queue Added successfully',
            variant: 'success',

        });
        this.dispatchEvent(evt);
    }
    showRemoveToast() {
        const evt = new ShowToastEvent({
            title: 'Success',
            message: 'User or Queue Removed successfully',
            variant: 'success',

        });
        this.dispatchEvent(evt);
    }
    showErrorToast() {
        const event = new ShowToastEvent({
            title: 'Error',
            message: 'User or Queue Already Added in Watch List',
            variant: 'Error',

        });
        this.dispatchEvent(event);
    }
    showErrorToast1() {
        const event = new ShowToastEvent({
            title: 'Error',
            message: 'In Watchlist only 50 User or Queue allow',
            variant: 'Error',

        });
        this.dispatchEvent(event);
    }
    showToast() {
        var error = this.error;
        if (error != undefined && error != null && error != '' && error.body != undefined && error.body != null && error.body != '') {
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