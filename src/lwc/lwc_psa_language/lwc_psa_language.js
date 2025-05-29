import { LightningElement, wire, track,api} from 'lwc';
import getPicklistValues from '@salesforce/apex/CNT_PSA_LanguageCapability.getLanguageOptions';
import saveOptions from '@salesforce/apex/CNT_PSA_LanguageCapability.saveOptions';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CloseActionScreenEvent } from 'lightning/actions';
export default class Lwc_psa_language extends LightningElement {
    selectedValue = '';
    picklistOptions = [];
    @api recordId;
    langaugeSkills ='';
    isLoaded = true;
    resourceLanguageList = [];
    allResourceLanguageList = [];
    @wire(getPicklistValues, {assignmentId: '$recordId'})
    wiredPicklistValues({error, data}) {
      if(data) {
        this.langaugeSkills = data.resourceSkillSet;
        if(data.skillSets){
            this.resourceLanguageList = data.skillSets;
        }
        if(data.allSkillSets){
            this.allResourceLanguageList = data.allSkillSets;
        }
        if(data.options){
            this.picklistOptions = data.options.map((option) => {
                return {
                  label: option,
                  value: option,
                };
              });
        }
        if(data.selectedOptions){
            this.selectedValue = data.selectedOptions;
        }
      }else if (error) {
        console.error(error);
      }
      this.isLoaded = false;
    }
  
    handleValueChange(event) {
        if(event.detail.value && event.detail.value != 'None'){
            let inputCmp = this.template.querySelector(".selectOptions");
            if(event.detail.value.length <= 8){
                inputCmp.setCustomValidity('');
                this.selectedValue = event.detail.value;
            }else{
                inputCmp.setCustomValidity('You can select maximum 8 values.');
            }
            inputCmp.reportValidity();
        }
    }

    handleDismiss(){
        this.dispatchEvent(new CloseActionScreenEvent());
    }

    handleSave(){
        const allValid =[...this.template.querySelectorAll("lightning-dual-listbox")
        ].reduce((validSoFar,inputCmp)=>{
            inputCmp.reportValidity();
            return validSoFar && inputCmp.reportValidity();
        },true);
        if(allValid){
            this.isLoaded = true;
            if(this.selectedValue){
                saveOptions({ assignmentId : this.recordId, selectedValues : this.selectedValue, skillSetList : this.allResourceLanguageList}).then(result=>{
                    if(result === 'Success'){
                        window.open("/"+this.recordId,'_self');
                        this.showToast( 'Successfully Updated',JSON.stringify(result),'success' );
                        this.isLoaded = false;
                    }else{
                        console.log('error '+JSON.stringify(result))
                        this.showToast( 'Error Occured!',JSON.stringify(result),'error' );
                        this.isLoaded = false;
                    }
                }).catch(error=>{
                    console.log('error '+JSON.stringify(result))
                    this.showToast( 'Error Occured!',JSON.stringify(error),'error' );
                    this.isLoaded = false;
                })
            }else{
                this.showToast( 'Please Select Language',error,'error' );
                this.isLoaded = false;
            }
        }
    }
    
    showToast(title, msg, variant) {
        const event = new ShowToastEvent({
            title: title,
            message: msg,
            variant: variant
        });
        this.dispatchEvent(event);
    }
}
