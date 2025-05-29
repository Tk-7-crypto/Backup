/* eslint-disable @lwc/lwc/no-async-operation */
/* eslint-disable no-console */
/* eslint-disable no-unused-vars */
/* eslint-disable @lwc/lwc/no-document-query */
/* eslint-disable no-undef */
import { LightningElement,api,track } from 'lwc';

export default class SelectBoxLookUp extends LightningElement {
    @api deliveryCounties = [];
    @api itemIndex; 
    @track countryResultsToShow = [];
    @track isNoResultFound = false;
    @track parentDivDefaultClass = 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click';
    @track parentDivClassToShow = '';
    @api inputCountryValue ='--None--';
    inputCurrentCountryValue = '--None--';
    @api errorStyle =''; 
    connectedCallback(){ 
        if(this.inputCountryValue === undefined){
            this.inputCountryValue = '--None--';
        }
		this.inputCurrentCountryValue = this.inputCountryValue;
        this.countryResultsToShow = this.deliveryCounties;
        this.parentDivClassToShow = this.parentDivDefaultClass;
    }
    fetchList(event){
        var searhcedResultArray = [];
        var i=0;
        var countryVal = '';
        var nametoSearch ='';
        this.inputCountryValue = event.target.value;
        nametoSearch = (this.inputCountryValue).toLowerCase();
        for(i=0;i<this.deliveryCounties.length;i++){
            countryVal = (this.deliveryCounties[i]).toLowerCase();
            if(countryVal.includes(nametoSearch)){
                searhcedResultArray.push(this.deliveryCounties[i]);
            }
        } 
        if(searhcedResultArray.length > 0){
            this.countryResultsToShow = searhcedResultArray;
            this.isNoResultFound = false;
        }else{ 
            this.countryResultsToShow = [];
            this.isNoResultFound = true;
        }
        this.parentDivClassToShow = this.parentDivDefaultClass + ' slds-is-open';
    }
    showCountryList(event){
        this.countryResultsToShow = this.deliveryCounties;
        this.parentDivClassToShow = this.parentDivDefaultClass + ' slds-is-open';
    }
    setCountryValue(event){
        event.preventDefault();
        if(this.inputCurrentCountryValue !== event.currentTarget.dataset.country) {
            this.inputCurrentCountryValue = event.currentTarget.dataset.country;
            this.inputCountryValue = event.currentTarget.dataset.country;
            this.dispatchEvent(new CustomEvent('change', {detail : this.inputCountryValue}));
        }
        this.hideDropDownList();
    }
    hideDropDownList(){
        this.parentDivClassToShow = this.parentDivDefaultClass;
    } 
    scrollDiv(event){
        event.preventDefault();
    }
}