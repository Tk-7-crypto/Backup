import { LightningElement, api, track } from 'lwc';
import retriveUsersByName from '@salesforce/apex/CNT_lwcSearchComponent.retriveUsersByName';
import retriveGroups from '@salesforce/apex/CNT_lwcGroupComponent.retriveGroups';
import addUserToGroup from '@salesforce/apex/CNT_lwcSearchComponent.addUserToGroup';
import showButtons from '@salesforce/apex/CNT_lwcGroupComponent.showButtons';

const columns = [{
        label: 'Name',
        fieldName: 'UserName',
        type: 'url',
        typeAttributes: { label: { fieldName: 'Name' }, target: '_blank' }
    },
    {
        label: 'Username',
        fieldName: 'Username',
    },
    {
        label: 'Email',
        fieldName: 'Email',
    },
    {
        label: 'Phone',
        fieldName: 'Phone',
    },
];
/**
 * Js controller for the lwcSearchComponent
 */
export default class LwcSearchComponent extends LightningElement {
    searchData;
    availableGroupData;
    columns = columns;
    errorMsg = '';
    searchUserName = '';
    openModal;
    @api selectedUserIds;
    @api selectedGroupIds = [];
    @api saveCheck = false;
    showButton = false;
    buttonTrue = true;

    /**
     * method to close the opened template of searched data.
     */
    closePopUp() {
        this.openModal = false;
    }

    /**
     * method to handle the Add user to group.
     */
    handleSaveAction() {
        addUserToGroup({ usersIdsList: this.selectedUserIds, groupIdsList: this.selectedGroupIds })
            .then(result => {
                this.saveCheck = true;
                const selectedEvent = new CustomEvent("savevaluechange", {
                    detail: this.saveCheck
                });
                this.dispatchEvent(selectedEvent);
                this.selectedGroupIds = [];
            })
            .catch(error => {})
        this.closePopUp();
        this.buttonTrue = true
    }

    @api fetchAddUserSection() {
        if (this.selectedUserIds != undefined && this.selectedGroupIds != undefined) {
            if (this.selectedUserIds.length != 0 && this.selectedGroupIds.length != 0) {
                this.buttonTrue = false;
            } else {
                this.buttonTrue = true;
            }
        } else {
            this.buttonTrue = true;
        }
    }

    /**
     * Method to handle the checkboxes of groups data shown on component.
     * @param {*} event 
     */
    handleRadioButtonChange(event) {
        this.radioButtonFieldValue = event.target.value;
        this.selectedGroupIds.push(this.radioButtonFieldValue);
        this.fetchAddUserSection();
    }

    /**
     * Method to handle the searched userName in search box. 
     * @param {*} event 
     */
    handleUserName(event) {
        this.searchUserName = event.detail.value;
    }
    @api clearUserName(){
        this.searchUserName = '';
    }
    /**
     * Method to handle the search of users and available groups data.
     */
    handleSearch() {
        if (!this.searchUserName) {
            this.errorMsg = 'Please enter User name to search.';
            this.searchData = undefined;
            this.availableGroupData = undefined;
            return;
        }

        retriveUsersByName({ userName: this.searchUserName })
            .then(result => {
                result.forEach((record) => {
                    record.UserName = '/' + record.Id;
                });
                this.errorMsg = undefined;
                this.searchData = result;
                this.openModal = true;
            })
            .catch(error => {
                this.searchData = undefined;
                if (error) {
                    this.errorMsg = error.body.message;
                    this.openModal = false;
                }
            })

        retriveGroups()
            .then(result => {
                result.forEach((record) => {
                    record.GroupName = '/' + record.Id;
                });
                this.errorMsg = undefined;
                this.availableGroupData = result;
                this.availableGroupData.forEach(function(item) {
                    item.Url = '/' + item.Id;
                });
            })
            .catch(error => {
                this.availableGroupData = undefined;
                if (error) {
                    this.errorMsg = error.body.message;
                }
            })

        showButtons()
            .then(result => {
                this.showButton = result;
            })
            .catch(error => {})
    }

    /**
     * Method to handle the checkboxes of users data shown on component.
     * @param {*} event 
     */
    handleAddUser(event) {
        const selectedRows = event.detail.selectedRows;
        this.selectedUserIds = [];
        for (let index = 0; index < selectedRows.length; index++) {
            this.selectedUserIds.push(selectedRows[index].Id);
        }
        this.fetchAddUserSection();
    }

}