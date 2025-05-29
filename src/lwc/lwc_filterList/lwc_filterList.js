import { LightningElement, track, api } from 'lwc';

export default class Lwc_filterList extends LightningElement {
    /* Options should be an array of items in lightning-checkbox-group format: [{label: <labelname>, value: <valuename>}] */
    @api optionsList = [];
    @api defaultSelections = [];
    @api searchKeyName = 'Name';
    @api searchKeyNamePlural = 'Names';
    @track viewFilter = false;
    @track selectedOptions = [];
    selectedOldOptions = [];
    @track searchBoxQuery = '';
    searchBoxOldQuery = '';

    connectedCallback(){
        if(this.defaultSelections.length > 0){
            this.selectedOptions = this.defaultSelections;
        } else {
            let initialSelections = [];
            for(let option of this.optionsList){
                initialSelections.push(option.value);
            }
            this.selectedOptions = initialSelections;
        } 
    }

    // COMPUTED PROPERTIES
    get filteredOptionsList(){
        if(this.searchBoxQuery.length > 0) {
           return this.optionsList.filter(item => item.label.toLowerCase().includes(this.searchBoxQuery.toLowerCase()));
        }
        return this.optionsList;
    }

    get optionsListDisplay(){
        let labelArray = [];
        //Find out if selected items include the value of each item in filtered items
        this.filteredOptionsList.reduce((accumulator, currentValue) => {
            if(this.selectedOptions.includes(currentValue.value)){
                accumulator.push(currentValue.label);
            }
            return accumulator;
        }, labelArray);
        let optionsDisplay = labelArray.join(', ');
        if(optionsDisplay === ''){
            return 'None';
        }
        return optionsDisplay;
    }

    get filterLabel(){
        return 'Displayed '+this.searchKeyNamePlural+': ';
    }

    get searchLabel(){
        return 'Filter by '+this.searchKeyName;
    }
    // HANDLERS
    handleClick(event){
        const buttonName = event.target.name;
        if(buttonName === 'FILTER_LIST'){
            event.preventDefault();
            this.searchBoxOldQuery = this.searchBoxQuery;
            this.selectedOldOptions = this.selectedOptions;
            this.viewFilter = true;
        }
        else if(buttonName === 'FILTER_SELECT_ALL'){
            event.preventDefault();
            let newSelection = [];
            for(let option of this.filteredOptionsList){
                newSelection.push(option.value);
            }
            this.selectedOptions = newSelection;
        }
        else if(buttonName === 'FILTER_SELECT_NONE'){
            event.preventDefault();
            this.selectedOptions = [];
        }
        else if(buttonName === 'FILTER_CANCEL'){
            this.viewFilter = false;
            this.searchBoxQuery = this.searchBoxOldQuery;
            this.selectedOptions = this.selectedOldOptions;
        }
        else if(buttonName === 'FILTER_APPLY'){
            //We want to set selected options to the union of selected options and filtered options
            let filteredOptionValues = [];
            for(let option of this.filteredOptionsList){
                filteredOptionValues.push(option.value);
            }
            let filteredSelection = [];
            for(let option of this.selectedOptions){
                if(filteredOptionValues.includes(option)){
                    filteredSelection.push(option);
                }
            }
            this.selectedOptions = filteredSelection;
            this.viewFilter = false;

            //Notify parent that filter has been changed
            this.dispatchEvent(new CustomEvent('filterapplied', {detail: filteredSelection.slice()}));
        }
    }

    filterChanged(event){
        if(event.target.name === 'FILTER_OPTIONS') {
            this.selectedOptions = event.detail.value;
        }

        const searchInput = this.template.querySelector('lightning-input.filter-search');
        let newQuery = searchInput.value
        if(this.searchBoxQuery !== newQuery){
            this.searchBoxQuery = newQuery;
        }
    }
}