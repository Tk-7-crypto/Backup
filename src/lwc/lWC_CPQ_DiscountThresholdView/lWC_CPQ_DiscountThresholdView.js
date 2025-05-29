import { LightningElement, track, wire } from 'lwc';
import getDiscountThresholdRecords from '@salesforce/apex/CNT_CPQ_DiscountThreshold.getDiscountThresholdRecords';

export default class LWC_CPQ_DiscountThresholdView extends LightningElement {
    @track data;
    @track dataform = [];
    @wire (getDiscountThresholdRecords) mywiredData({data, error}){
        if (data) {
            this.data = data;
            this.data.forEach(element => {
                if (element.Min_Amount__c == 0) {
                    this.dataform.push({Id:element.Id, Min_Amount__c:element.Min_Amount__c, Max_Amount__c:element.Max_Amount__c/1000+'K', Min_Discount_Percent__c:element.Min_Discount_Percent__c, Min_Discount_Amount__c:element.Min_Discount_Amount__c});
                } else if (element.Max_Amount__c == 0) {
                    this.dataform.push({Id:element.Id, Min_Amount__c:'>'+element.Min_Amount__c/1000+'K', Max_Amount__c:element.Max_Amount__c, Min_Discount_Percent__c:element.Min_Discount_Percent__c, Min_Discount_Amount__c:element.Min_Discount_Amount__c});
                } else {
                    this.dataform.push({Id:element.Id, Min_Amount__c:'>'+element.Min_Amount__c/1000+'K', Max_Amount__c:element.Max_Amount__c/1000+'K', Min_Discount_Percent__c:element.Min_Discount_Percent__c, Min_Discount_Amount__c:element.Min_Discount_Amount__c});
                }
            });
        }
        else {
            console.error(error);
        }
    }
}
