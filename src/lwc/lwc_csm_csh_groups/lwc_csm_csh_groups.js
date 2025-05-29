import { LightningElement, track, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getGroups from '@salesforce/apex/CNT_CSM_CommunityGroups.getGroupsRelatedToUser';
import GROUPS_LABEL from '@salesforce/label/c.Groups';
import FILTER_BY_PRODUCT_LABEL from '@salesforce/label/c.Filter_by_product';
import FILTER_BY_GROUP_NAME_LABEL from '@salesforce/label/c.Filter_by_Group_Name';
import NO_GROUPS_AVAILABLE_LABEL from '@salesforce/label/c.No_Groups_Available';
import NO_GROUPS_FOR_THIS_PRODUCT_LABEL from '@salesforce/label/c.No_Groups_for_this_product';
import ALL_PRODUCTS_LABEL from '@salesforce/label/c.All_Products';
import JOIN_GROUPS_TO_MEET_AND_COLLABORATE_LABEL from '@salesforce/label/c.Join_groups_to_meet_and_collaborate';

export default class Lwc_csm_csh_groups extends NavigationMixin(LightningElement) {
    @api includeExpired = false;
    @track labels = {
        Groups: GROUPS_LABEL,
        Filter_by_product: FILTER_BY_PRODUCT_LABEL,
        Filter_by_Group_Name: FILTER_BY_GROUP_NAME_LABEL,
        No_Groups_Available: NO_GROUPS_AVAILABLE_LABEL,
        No_Groups_for_this_product: NO_GROUPS_FOR_THIS_PRODUCT_LABEL,
        All_Products: ALL_PRODUCTS_LABEL,
        Join_groups_to_meet_and_collaborate: JOIN_GROUPS_TO_MEET_AND_COLLABORATE_LABEL

    };
    @track groups = [];
    @track searchGroupName = '';
    @track selectedProductName = '';
    @track productOptions = [];
    @track filteredGroups = [];
    @track isLoading = true;
    @track error = false;
    @track errorMsg;

    connectedCallback() {
        let url = new URL(window.location.href);
        if (url.searchParams.has("groupId")) {
            url.searchParams.delete("groupId");
        }
        window.history.replaceState({}, document.title, url.toString());
        this.getGroups();
    }

    getGroups() {
        getGroups()
            .then(result => {
                this.groups = JSON.parse(result);
                this.populateProductOptions();
                this.groups.sort((a, b) => {
                    if (a.productName < b.productName) return -1;
                    if (a.productName > b.productName) return 1;
                    return a.groupOrder - b.groupOrder;
                });
                this.filteredGroups = this.groups;              
                this.handleUrlParams();
                this.isLoading = false;
            })
            .catch(error => {
                console.error('Error', error);
                this.isLoading = false;
            });
    }

    populateProductOptions() {
        const productNames = [...new Set(this.groups.map(group => group.productName))];
        this.productOptions = [{ label: this.labels.All_Products, value: '' }, ...productNames.map(name => ({ label: name, value: name }))];
    }

    get hasProducts() {
        return this.productOptions.length > 1;
    }

    handleProductFilterChange(event) {
        this.selectedProductName = event.detail.value;
        this.filterGroups();
    }

    handleGroupNameFilterChange(event) {
        this.searchGroupName = event.target.value;
        this.filterGroups();
    }

    filterGroups() {
        this.filteredGroups = this.groups.filter(group => {
            const productNameMatch = !this.selectedProductName || group.productName === this.selectedProductName;
            const groupNameMatch = !this.searchGroupName || group.relatedGroup.Name.toLowerCase().includes(this.searchGroupName.toLowerCase());
            return productNameMatch && groupNameMatch;
        });
    }

    handleUrlParams() {
        const url = new URL(window.location.href);
        const productName = url.searchParams.get('p');
        if (productName) {
            this.selectedProductName = productName;
            if (this.productOptions.find(opt => opt.value === productName)) {
                this.handleProductFilterChange({ detail: { value: productName } });
            } else {
                this.showToast(this.labels.No_Groups_for_this_product);
                url.searchParams.delete('p');
                window.history.replaceState({}, document.title, url.toString());
            }

        }
    }

    showToast(message) {
        const toastEvent = new ShowToastEvent({
            message: message,
            variant: 'info'
        });
        this.dispatchEvent(toastEvent);
    }

}
