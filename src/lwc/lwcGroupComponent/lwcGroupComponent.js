import { LightningElement, api } from 'lwc';
import retriveGroupMemberByGroup from '@salesforce/apex/CNT_lwcSearchComponent.retriveGroupMemberByGroup';
import deleteGroupMemberByGroupIdAndUserId from '@salesforce/apex/CNT_lwcSearchComponent.deleteGroupMemberByGroupIdAndUserId';
import showButtons from '@salesforce/apex/CNT_lwcGroupComponent.showButtons';

const columns = [{
        label: 'Name',
        fieldName: 'UserName',
        type: 'url',
        typeAttributes: { label: { fieldName: 'Name' }, target: '_blank' }
    },
    {
        label: 'Action',
        type: "button",
        typeAttributes: {
            label: 'Delete',
            name: 'Delete',
            title: 'Delete',
            disabled: false,
            value: 'delete',
            iconPosition: 'left'
        }
    },
];

const singleColumn = [{
    label: 'Name',
    fieldName: 'UserName',
    type: 'url',
    typeAttributes: { label: { fieldName: 'Name' }, target: '_blank' }
}, ];
/**
 * Js controller for lwcGroupComponent. 
 */
export default class LwcGroupComponent extends LightningElement {

    @api group;
    groupMemberData;
    columns = columns;
    deleteCheck = false;
    showButton = false;
    reload = false;
    deleteResult = false;

    /**
     * Method which is called when the component renders.
     */
    connectedCallback() {
        this.fetchGroupMember();
    }

    /**
     * Method to fetch group members of a particular group
     */
    @api fetchGroupMember() {
        retriveGroupMemberByGroup({ groupRecord: this.group })
            .then(result => {
                result.forEach((record) => {
                    record.UserName = '/' + record.Id;
                });
                this.groupMemberData = result;
            })
            .catch(error => {
                this.groupMemberData = undefined;
                window.console.log('error =====> ' + JSON.stringify(error));
            })

        showButtons()
            .then(result => {
                this.showButton = result;
                if (this.showButton == false) {
                    this.columns = singleColumn;
                } else {
                    this.columns = columns;
                }
            })
            .catch(error => {
                window.console.log('error =====> ' + JSON.stringify(error));
            })
    }

    /**
     * Method to handle action which are shown for every users of a group.
     * @param {*} event 
     */
    callRowAction(event) {
        const userRecordId = event.detail.row.Id;
        const actionName = event.detail.action.name;
        if (actionName === 'Delete') {
            deleteGroupMemberByGroupIdAndUserId({ groupId: this.group.Id, userId: userRecordId })
                .then(result => {
                    this.deleteCheck = true;
                    this.deleteResult = result;
                    this.fetchGroupMember();
                    if (this.deleteCheck == true) {
                        if (this.reload == true) {
                            this.reload = false;
                        } else {
                            this.reload = true;
                        }
                    }
                    if (this.deleteResult == true) {
                        const selectedEvent = new CustomEvent("deletevaluechange", {
                            detail: this.deleteResult
                        });
                        this.dispatchEvent(selectedEvent);
                    }
                })
                .catch(error => {
                    window.console.log('error =====> ' + JSON.stringify(error));
                })
        }
    }
}