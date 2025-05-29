/* 
    This input takes a list of options, and allows you to select by clicking or typing
    It also creates a lightning-input-field and can be used in a record-edit-form component
    iconName should be in lightning-icon format, e.g. custom:custom68
*/
import { LightningElement, api, track } from 'lwc';

export default class Lwc_inputSearchableList extends LightningElement {
    @api name = '';
    @api label = '';
    @api placeholder = "Please make a selection...";
    @api options = [];
    @api icon = '';
    @track value = '';

    handleChange(event){
        this.value = event.detail.value;
        this.dispatchEvent(new CustomEvent('itemselected', {detail: this.value}));
    }

    /*
    Search box with placeholder Search <object type>... and search icon at right
    As you type, list is filled out

     */
/*
    @api labelName;
    @api options = [];
    @api fieldName;
    @api iconName = '';
    @api placeholder = 'Search...';
//    @api fieldValue;
    @track listItem = '';
    @track searchString = '';
    searchStringOld = '';
    @track listingIsOpen = false;
    @track selectedItem;

    get filteredListing (){
        let query = this.searchString;
        if(query === ''){
            return this.options;
        }

        return this.options.filter(function(item){
            return item.Name.toLowerCase().indexOf(query.toLowerCase()) > -1;
        });
    }

    get listboxTriggerClass(){
        let baseClass = 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click';
        if(this.listingIsOpen){
            baseClass += ' slds-is-open';
        }
        return baseClass;
    }

    get displayIcon(){
        return (this.iconName !== '');
    }

    clickListing(){
        this.listingIsOpen = true;
    }

    leaveListing(){
        this.listingIsOpen = false;
    }

    keyboardListing(event){
        if(!this.listingIsOpen) {
            if (event.key === 'Enter' || event.key === 'DownArrow') {
                this.clickListing();
            }
        } else {
            if (event.key === 'Escape') {
                this.leaveListing();
            } else if (event.key === 'Enter') { 
                //Make Selection
            } else if (event.key === 'DownArrow') {
                //Scroll through list
            } else if (event.key === 'UpArrow') {
                //Scroll through list
            } else {
                this.updateSearchString(event);
            }
        }

    }

    changeListing(){

    }

    clickItem(event){
        this.selectedItem = event.currentTarget.dataset.item;
        console.log(this.selectedItem);
        for(let option in this.options){
            if(this.options[option].Id === this.selectedItem){
                this.fieldValue = this.options[option].Name;
                this.dispatchEvent(new CustomEvent('itemselected', {detail: this.options[option]}));
                break;
            }
        }
    }
    suppressClick(event){
        event.stopPropagation();
    }

    updateSearchString(event){
        let query = event.currentTarget.value;
        if(typeof query !== 'undefined'){
            this.searchString = query;
        }
    }

    getItemById(id){
        //
    }
*/

}