import { LightningElement, wire, track,api } from 'lwc';
import getPermssionsetRecord from '@salesforce/apex/CNT_CPQ_AdminScreenController.getPermissionsetRecords';
const columns = [
    { label: 'CPQ Feature', fieldName: 'cpqFeature' },
    { label: 'Feature Link', fieldName: 'urlPath', type: 'url', typeAttributes: {label: { fieldName: 'lwcComponentData' }, target: '_self'} }
];
export default class LWC_CPQ_AdminScreen extends LightningElement {
   @track lstTabs =[];
   columns = columns;
   connectedCallback(){
       getPermssionsetRecord() 
       .then(result => {
            var tempOppList = [];  
            for (var i = 0; i < result.length; i++) {  
                let tempRecord = Object.assign({}, result[i]); //cloning object  
                tempRecord.urlPath =  window.location.origin+'/lightning/n/' + tempRecord.lwcComponentData;  
                tempOppList.push(tempRecord);  
            } 
            this.lstTabs = tempOppList; 
            this.error = undefined;
       })
       .catch(error => {
            this.error = error;
            this.contacts = undefined;
       });
 }
}