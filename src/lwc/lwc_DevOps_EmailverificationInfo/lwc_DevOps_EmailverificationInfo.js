import { LightningElement, wire } from 'lwc';
import isEmailVerified  from '@salesforce/apex/CNT_DevOps_EmailVerificationInfo.isEmailVerified';
import sendVerificationMailToUser from '@salesforce/apex/CNT_DevOps_EmailVerificationInfo.sendVerificationMail';
import { NavigationMixin } from 'lightning/navigation';
import Id from '@salesforce/user/Id'; 
import NAME_FIELD from '@salesforce/schema/User.Name';
import EMAIL_FIELD from '@salesforce/schema/User.Email';
import { getRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class Lwc_DevOps_EmailverificationInfo extends NavigationMixin(LightningElement)  {

    userName;
    email;
    showPopup = false;   
    userId = Id;
    @wire(getRecord, {
        recordId: Id,
        fields: [NAME_FIELD, EMAIL_FIELD]
    }) wireuser({ error, data }) {
        if (error) {
           this.error = error ; 
        } else if (data) {
            this.userName = data.fields.Name.value;
            this.email = data.fields.Email.value;
        }
    }


    @wire(isEmailVerified)
    wiredResult({ error, data }) {
        if (data !== undefined) {
            this.showPopup = data;            
            console.log('show '+this.showPopup);            
            // if(this.showPopup == true){
            //     this.closePopup = true;
            // }
            // else{
            //    this.closePopup = false; 
            // }
            
        } else if (error) {     
             //this.closePopup = false;       
            console.log('error retrivien email verification status:',error);
        }    }
   

        sendEmailToUser(){
            let elementUserEmail= this.template.querySelector(".UserEmail");
            console.log('elementUserEmail--'+elementUserEmail.value);
            let valueelementUserEmail = elementUserEmail.value;
            if (valueelementUserEmail == '' || valueelementUserEmail == null) {
                elementUserEmail.reportValidity();
                this.message = undefined;
                    this.dispatchEvent(
                    new ShowToastEvent({
                            title: 'Error Sending Email',
                            message: 'Please fill the User email to send the verification Email.',
                            variant: 'error',
                    }),
                );
                return;               
                
            }
            else{
                sendVerificationMailToUser({ userEmail:elementUserEmail.value})
                        .then(result => {
                        console.log('result--', result);
                    if (result.success) {
                            this.message = undefined;
                            this.dispatchEvent(
                                new ShowToastEvent({
                                    title: 'success',
                                    message: '' + result.success + '',
                                    variant: 'success',
                                }),
                            )
                        }
                         this.showPopup = false;
                        //this.closePopup = false;              
                    })
                    .catch(error => {
                    console.log('-------error-------------' + error);                    
                    this.message = undefined;
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error Sending Verification Email'+'',
                            message: '' + error.message + '',
                            variant: 'error',
                        }),
                    );
                });
            }
        }
        
        connectedCallback() {
        //code
        // this.closePopup = false; 
        }

        handleClose(){
        this.showPopup =false;
        //this.closePopup = false;        
        }
}