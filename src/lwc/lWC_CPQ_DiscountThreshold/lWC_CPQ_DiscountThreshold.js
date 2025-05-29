import { LightningElement, track, wire } from 'lwc';
import getDiscountThresholdRecords from '@salesforce/apex/CNT_CPQ_DiscountThreshold.getDiscountThresholdRecords';
import updateDiscountThresholdRecords from '@salesforce/apex/CNT_CPQ_DiscountThreshold.updateDiscountThresholdRecords'
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';
var columns = [
    
    {label:'Min Amount', fieldName: 'Min_Amount__c',editable: true},
    {label:'Max Amount', fieldName: 'Max_Amount__c',editable: true},
    {label:'Discount Amount', fieldName: 'Min_Discount_Amount__c',editable: true},
    {label:'Discount Percent %', fieldName: 'Min_Discount_Percent__c',editable: true}
]
export default class LWC_CPQ_DiscountThreshold extends LightningElement {
    @track data ;
    @track column = columns;
    @track discountMatrixObj
    @track showSpinner = true;
    saveDraftValues = [];

    @wire (getDiscountThresholdRecords) mywiredData(result){
        this.discountMatrixObj = result;
        if(result.data){
            this.data = result.data;
            this.showSpinner = false;
        }
        else if(result.error){
            this.showToast("Error", "error", error.body.message);
            this.showSpinner = false;
        }
    }
    handleSave(event){
       this.saveDraftValues = JSON.parse(JSON.stringify(event.detail.draftValues)); 
       var myUpdatedRecord = [];
       
       this.saveDraftValues.forEach(element1 => {
        var myFlg = false;
        var myObj = {};
        myObj['Id'] = element1.Id;
           this.data.forEach(element2 =>{
                if(element1.Id === element2.Id){
                    if(element1.hasOwnProperty('Min_Amount__c')) {
                        if(element1.Min_Amount__c != element2.Min_Amount__c){
                            myFlg = true;
                            myObj['Min_Amount__c'] = element1.Min_Amount__c;
                        }
                    }
                    if(element1.hasOwnProperty('Max_Amount__c')) {
                        if(element1.Max_Amount__c != element2.Max_Amount__c){
                            myFlg = true;
                            myObj['Max_Amount__c'] = element1.Max_Amount__c;
                        }
                    }
                    if(element1.hasOwnProperty('Min_Discount_Percent__c')) {
                        if(element1.Min_Discount_Percent__c != element2.Min_Discount_Percent__c){
                            myFlg = true;
                            myObj['Min_Discount_Percent__c'] = element1.Min_Discount_Percent__c;
                        }
                    }
                    if(element1.hasOwnProperty('Min_Discount_Amount__c')) {
                        if(element1.Min_Discount_Amount__c != element2.Min_Discount_Amount__c){
                            myFlg = true;
                            myObj['Min_Discount_Amount__c'] = element1.Min_Discount_Amount__c;
                        }
                    }
                }
           });

           if(myFlg === true){
                myUpdatedRecord.push(myObj);   
            }
       });
       updateDiscountThresholdRecords({myRecords: myUpdatedRecord})
       .then(result => {
           if(result == 'Update'){
            this.showToast("Success", "success", "Discount Threshold updated successfully");
            this.saveDraftValues = [];
           }
       })
       .catch(error => {
            this.showToast("Error", "error", error.body.message);
       });
       refreshApex(this.discountMatrixObj)
       .then(() => this.showSpinner = false)
       .catch(() => this.showSpinner = false);
    }
    showToast(title, variant, message) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        });
        this.dispatchEvent(event);
    }
}