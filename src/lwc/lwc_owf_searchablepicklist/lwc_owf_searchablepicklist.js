import {  api, LightningElement, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class Lwc_owf_searchablepicklist extends LightningElement {
    @api options;
    _selectedValue;
    _selectedValues;
    @api label;
    @api minChar = 2;
    @api disabled = false;
    @api multiSelect = false;
    value;
    @track values = [];
    optionData;
    searchString;
    message;
    showDropdown = false;
    @api validateSelectedValue ;
    @api maxSelectedValue ;
    @track totalSelectedValues = 0;
    @api
    get selectedValue() {
        return this._selectedValue;
    }
    set selectedValue(value){
        this._selectedValue= value;
        this.initialize();
    }
    
    @api
    get selectedValues() {
        return this._selectedValues;
    }
    set selectedValues(value){
        this._selectedValues= value;
        this.initialize();
    }

    showToast(title,message,variant,mode) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
            mode: mode
        });
        this.dispatchEvent(event);
    }

    initialize() {
        this.showDropdown = false;
        var values = [];
        var optionData = this.options ? (JSON.parse(JSON.stringify(this.options))) : null;
        var value = this.selectedValue ? (JSON.parse(JSON.stringify(this.selectedValue))) : null;
        values = this.selectedValues ? this.selectedValues.split(";") : [];
		if(value || values) {
          var searchString;
        	var count = 0;
            
            for(var i = 0; i < optionData.length; i++) {
                if(this.multiSelect) {
                    if(values.includes(optionData[i].value)) {
                        optionData[i].selected = true;
                        count++;
                    }  
                } else {
                    if(optionData[i].value == value) {
                        searchString = optionData[i].label;
                    }
                }
            }
            if(this.multiSelect){
                this.searchString = count + ' Option(s) Selected';
                this.totalSelectedValues = count;            
            } 
            else
                this.searchString = searchString;
        }
        this.value = value;
        this.values = values;
        this.optionData = optionData;
    }

    filterOptions(event) {
        this.searchString = event.target.value;
        if( this.searchString && this.searchString.length > 0 ) {
            this.message = '';
            if(this.searchString.length >= this.minChar) {
                var flag = true;
                for(var i = 0; i < this.optionData.length; i++) {
                    if(this.optionData[i].label.toLowerCase().trim().includes(this.searchString.toLowerCase().trim())) {
                        this.optionData[i].isVisible = true;
                        flag = false;
                    } else {
                        this.optionData[i].isVisible = false;
                    }
                }
                if(flag) {
                    this.message = "No results found for '" + this.searchString + "'";
                }
            }
            this.showDropdown = true;
        } else {
            this.showDropdown = false;
        }
	}

    selectItem(event) {
        var selectedVal = event.currentTarget.dataset.id;
        if(this.validateSelectedValue && this.totalSelectedValues >= this.maxSelectedValue && this.multiSelect) {
            if(selectedVal) {
                var count = 0;
                var options = JSON.parse(JSON.stringify(this.optionData));
                for(var i = 0; i < options.length; i++) {
                    if(options[i].value === selectedVal) {
                        if(this.values.includes(options[i].value)) {
                            this.values.splice(this.values.indexOf(options[i].value), 1);
                            options[i].selected = false;
                            this.totalSelectedValues = this.totalSelectedValues-1;
                            
                        }                        
                    }            
                    if(options[i].selected) {
                        count++;
                       
                    }
                }
                if(this.totalSelectedValues >= this.maxSelectedValue) {
                    this.showToast('Error', 'Selected value cannot be more than ' + this.maxSelectedValue, 'Error', 'dismissable');
                }
                this.optionData = options;
                if(this.multiSelect)
                    this.searchString = count + ' Option(s) Selected';
                if(this.multiSelect)
                    event.preventDefault();
                else
                    this.showDropdown = false;
            }
        }
        else{        
            if(selectedVal) {
                var count = 0;
                var options = JSON.parse(JSON.stringify(this.optionData));
                for(var i = 0; i < options.length; i++) {                  
                    if(options[i].value === selectedVal) {
                        if(this.multiSelect) {
                            if(this.values.includes(options[i].value)) {
                                this.values.splice(this.values.indexOf(options[i].value), 1);
                                this.totalSelectedValues--;
                            } else {
                                this.values.push(options[i].value);
                                this.totalSelectedValues++;
                            }
                            options[i].selected = options[i].selected ? false : true;   
                        } else {
                            this.value = options[i].value;
                            this.searchString = options[i].label;
                        }
    
                    }
                    if(options[i].selected ) {
                        count++;
                    }
                }    
                this.optionData = options ;
                if(this.multiSelect)
                    this.searchString = count + ' Option(s) Selected';
                if(this.multiSelect)
                    event.preventDefault();
                else
                    this.showDropdown = false;
                
            }
        }        
    }

    showOptions() {
        if(this.disabled == false && this.options) {
            this.message = '';
            this.searchString = '';
            var options = JSON.parse(JSON.stringify(this.optionData));
            for(var i = 0; i < options.length; i++) {
                options[i].isVisible = true;
            }
            if(options.length > 0) {
                this.showDropdown = true;
            }
            this.optionData = options;
        }
	  }

    blurEvent() {
        var previousLabel;
        var count = 0;
        for(var i = 0; i < this.optionData.length; i++) {
            if(this.optionData[i].value === this.value) {
                previousLabel = this.optionData[i].label;
            }
            if(this.optionData[i].selected) {
                count++;
            }
        }
        if(this.multiSelect)
        	this.searchString = count + ' Option(s) Selected';
        else
        	this.searchString = previousLabel;
        
        this.showDropdown = false;
        this.dispatchEvent(new CustomEvent('selectionofpicklist',{
            detail: {
             'value' : this.value,
            'values' : this.values
             }
        }));
    }
    get selectedTooltipValue() {
        if (this.multiSelect && this.validateSelectedValue) {
            return this.values.length > 0 ? this.values.join(', ') : 'No option selected';
        } else {
            return this.searchString ? this.searchString : 'No option selected';
        }
    }
}
