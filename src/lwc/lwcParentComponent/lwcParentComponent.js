import { LightningElement, api } from 'lwc';
import retriveGroups from '@salesforce/apex/CNT_lwcGroupComponent.retriveGroups';
import showAddUserCompoent from '@salesforce/apex/CNT_lwcGroupComponent.showAddUserCompoent';

/**
 * Js Controller of lwcParentComponent.
 */
export default class LwcParentComponent extends LightningElement {

    groups;
    saveCheck = false;
    deleteCheck = false;
    reloadComponent = false;
    showLwcSearchComponent = false;

    /**
     * Methos which automatically called when component renders.
     */
    connectedCallback() {
        this.fetchGroups();
    }

    /**
     * Method to fetch groups records.
     */
    @api fetchGroups() {
        retriveGroups()
            .then(result => {
                this.groups = result;
            })
            .catch(error => {
                this.groups = undefined;
            })

        this.fetchAddUserComponent();
    }

    @api fetchAddUserComponent() {
        showAddUserCompoent()
            .then(result => {
                this.showLwcSearchComponent = result;
            })
            .catch(error => {
                this.showLwcSearchComponent = undefined;
            })
    }


    /**
     * Method to handle the dispatched event by lwcSearchComponent.
     * @param {*} event 
     */
    handleSaveValueChange(event) {
        this.saveCheck = event.detail;
        if (this.saveCheck == true) {
            if (this.reloadComponent == true) {
                this.reloadComponent = false;
            } else {
                this.reloadComponent = true;
            }
            this.template.querySelector('c-lwc-search-component').clearUserName();
        }
    }

    /**
     * Method to handle the dispatched event by lwcGroupComponent.
     * @param {*} event 
     */
    handleDeleteValueChange(event) {
        this.deleteCheck = event.detail;
        if (this.deleteCheck == true) {
            if (this.reloadComponent == true) {
                this.reloadComponent = false;
            } else {
                this.reloadComponent = true;
            }
        }

        this.fetchAddUserComponent();
    }
}