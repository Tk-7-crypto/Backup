import { LightningElement, wire, track, api } from 'lwc';
import callSNOWGenAIChatGPT from '@salesforce/apex/CNT_CSM_SNOWChatGPT.callSNOWGenAIChatGPT';
import callGetSNOWGenAIChatGPT from '@salesforce/apex/CNT_CSM_SNOWChatGPT.callGetSNOWGenAIChatGPT';
//import IMAGE from '@salesforce/resourceUrl/ChatBot';
export default class Lwc_csm_SNOWChatGPT extends LightningElement {
  @track searchResults = [];
  @track searchTerm = '';
  //@api imageUrl = IMAGE;
  @track lengthValue;
  @track showSpace = true ;
  @track showSpinner = false;
  @track showAITypeing = false;
  @track responseData;
  @track sys_id;
  @api prop1;
  timeSpan = 10000;
  event1;
    handleKeyDown(event) {
    
        if (event.keyCode === 13) {
          // Perform search when the Enter key is pressed
          this.searchTerm = event.target.value;
          //this.showSpinner = true;
          this.showAITypeing = true;
          console.log('this.searchResults :'+this.searchResults);
          if(this.searchResults != undefined){
            this.lengthValue = this.searchResults.length+3;
            this.searchResults.push({id:this.searchResults.length+2, isUser : true, Order__c : this.searchResults.length+2, Content__c : this.searchTerm + '<br>'});
            setTimeout(() => {
              this.scrollToBottom2();
          }, 500);
          }
          console.log('this.searchTerm : '+this.searchTerm);
          this.template.querySelector('[data-id="chat-id"]').value = '';
          callSNOWGenAIChatGPT({searchString:this.searchTerm , sys_id:this.sys_id})
           .then(result => {
             console.log('result : ' + JSON.stringify(result));
             if (result.error) {
                  console.info('result: '+result);
                  //this.responseData = result.error.message;
              } else if (result.length) {
                      console.log('result.length : ' + result.length);
                      for (let i = 0; i < result.length; i++) {
                        if(result[i].Role__c == 'User'){
                          result[i].isUser = true;
                        }else{
                          result[i].isUser = false;
                        }
                          //this.responseData += result[i].Content__c + '<br>';
                          this.sys_id = result[i].sys_Id__c;
                      }
                      if(result.length > 0 ){
                        this.showSpace =false;
                      }
                      this.event1 = setInterval(() => {
                    callGetSNOWGenAIChatGPT({sys_id:this.sys_id})
                        .then(result => {
                        console.log('result : ' + JSON.stringify(result));
                      if (result.error) {
                          console.info('result: '+result);
                          //this.responseData = result.error.message;
                      } else if (result.length) {
                         console.log('result.length : ' + result.length);
                         for (let i = 0; i < result.length; i++) {
                          if(result[i].Role__c == 'User'){
                            result[i].isUser = true;
                          }else{
                            result[i].isUser = false;
                          }
                          //this.responseData += result[i].Content__c + '<br>';
                            this.sys_id = result[i].sys_Id__c;
                            if (result.length%2 == 0){
                              clearInterval(this.event1);
                              this.showAITypeing = false;
                              setTimeout(() => {
                                this.scrollToBottom();
                            }, 500);
                            }
                            //this.showSpinner = false;
                            
                         }
                         //result.sort(function(a, b){return a.Order__c - b.Order__c});
                         this.searchResults = result;
                         if(this.searchResults.length > 0 ){
                          this.showSpace =false;
                        }
                      
                      }
                  })
                  .catch(error=>{
                    clearInterval(this.event1);
                     this.showSpinner = false;
                     this.showAITypeing = false;
                    console.log('error is '+JSON.stringify(error));
                  })

                }, this.timeSpan);    
              
              }
           })
           .catch(error=>{
             this.showSpinner = false;
             this.showAITypeing = false;
             console.log('error is '+JSON.stringify(error));
           })
                
        }
      
    }

    scrollToBottom2() {
      const treeEl = this.template.querySelector('[data-id="chatTree"]');
        if (treeEl) {
          const lent = this.searchResults.length+2;
          console.log('lent : '+lent);
            const selectedItemEl = treeEl.querySelector('[data-chat = "'+lent+'"]');
            console.log('selectedItemEl : '+selectedItemEl);
            if (selectedItemEl) {
              console.log('inside  : '+selectedItemEl);
                selectedItemEl.scrollIntoView({ behavior: "smooth", block: "end", inline: "center" });
            }
        }
  }

  scrollToBottom() {
    const treeEl = this.template.querySelector('[data-id="chatTree"]');
      if (treeEl) {
        const lent = this.searchResults.length+1;
          const selectedItemEl = treeEl.querySelector('[data-chat = "'+lent+'"]');
          if (selectedItemEl) {
              selectedItemEl.scrollIntoView({ behavior: "smooth", block: "end", inline: "center" });
          }
      }
}

}