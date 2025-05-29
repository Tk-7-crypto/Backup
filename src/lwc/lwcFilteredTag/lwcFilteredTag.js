import { LightningElement,api,wire,track } from 'lwc';

export default class LwcFilteredTag extends LightningElement {
    @api item;
    @api record;
    @api opprecord;
    @api parentAcctIds;
    get therapyMatch(){
        if(this.record.data != undefined && this.item.Therapy_Area__c != null && this.record.data.Therapy_Area__c != null && 
            this.item.Therapy_Area__c == this.record.data.Therapy_Area__c){
            return true;
        }else{
            return false;
        }
    }
    get account(){
        if(this.record.data != undefined && this.item.Account__c != null && this.record.data.Bid_History_Account__c != null &&
            (this.parentAcctIds.includes(this.item.Account__c) || this.item.Account__c == this.record.data.Bid_History_Account__c)){
            return true;
        }else{
            return false;
        }
    }
    get RegionMatch(){
        if(this.record.data != undefined && this.item.Region__c != undefined && this.item.Region__c != null &&  this.record.data.Bid_History_Related_Opportunity__r.Potential_Regions__c != null){
            var region = this.item.Region__c.split(';');
                var isExist = false;
                for(var i=0; i< region.length; i++){
                    if(this.record.data.Bid_History_Related_Opportunity__r.Potential_Regions__c.includes(region[i])){
                        isExist = true;
                    }
                }
            return isExist;
        }
    }
    get IQVIA(){
        if(this.record.data != undefined && this.item.Is_this_IQVIA_Biotech__c != null && this.record.data.IQVIA_biotech__c != null && 
            this.item.Is_this_IQVIA_Biotech__c == this.record.data.IQVIA_biotech__c){
            return true;
        }else{
            return false;
        }
    }
    get RareDisease(){
        if(this.record.data != undefined && this.item.Rare_Disease__c != null && this.record.data.Bid_History_Related_Opportunity__r.Rare_Disease__c != null && 
            ((this.item.Rare_Disease__c == 'No' && this.record.data.Bid_History_Related_Opportunity__r.Rare_Disease__c== false) || 
            (this.item.Rare_Disease__c == 'Yes' && this.record.data.Bid_History_Related_Opportunity__r.Rare_Disease__c==true))){
            return true;
        }else{
            return false;
        }
    }
    get Indication(){
        if(this.record.data != undefined && this.item.Indication__c != null && this.record.data.Indication__c != null &&
            this.item.Indication__r.Name == this.record.data.Indication__c){
            return true;
        }else{
            return false;
        }
    }
    get InterVention(){
        if(this.record.data != undefined && this.item.Intervention_Type__c != null && (this.record.data.Intervention_Type__c != null || 
            this.record.data.Bid_History_Related_Opportunity__r.InterventionType__c != null) &&(this.item.Intervention_Type__c == this.record.data.Intervention_Type__c  
                || this.item.Intervention_Type__c == this.record.data.Bid_History_Related_Opportunity__r.InterventionType__c)){
            return true;
        }else{
            return false;
        }
    }
    get Country(){
        if(this.record.data != undefined && this.item.Country__c != undefined && this.item.Country__c != null &&  this.record.data.Targeted_Countries__c != null){
            var country = this.item.Country__c.split(';');
                var isExist = false;
                for(var i=0; i< country.length; i++){
                    if(this.record.data.Targeted_Countries__c.includes(country[i])){
                        isExist = true;
                    }
                }
            return isExist;
        }
    }
    get DrugName(){
        if(this.record.data != undefined && this.item.Drug_Classification_Product_Name__c != null && this.record.data.Drug_Name__c != null &&
            this.item.Drug_Classification_Product_Name__c == this.record.data.Drug_Name__c){
            return true;
        }else{
            return false;
        }
    }
    get Level(){
        if(this.record.data != undefined && this.item.Level__c != null && this.record.data.RFP_Ranking__c != null && 
            this.item.Level__c == this.record.data.RFP_Ranking__c){
            return true;
        }else{
            return false;
        }
    }
    get phase(){
        if(this.record.data != undefined && this.item.Phase__c != null && this.record.data.Phase__c != null && 
            this.item.Phase__c == this.record.data.Phase__c){
            return true;
        }else{
            return false;
        }
    }
    get LineOfBusiness(){
        if(this.record.data != undefined && this.item.Line_of_Business__c != null && this.record.data.Line_of_Business__c != null && 
            this.item.Line_of_Business__c == this.record.data.Line_of_Business__c){
            return true;
        }else{
            return false;
        }
    }
    get FullService(){
        if(this.record.data != undefined && this.item.Full_Service__c != null && this.record.data.Full_Service__c != null && 
           this.item.Full_Service__c == this.record.data.Full_Service__c){
            return true;
        }else{
            return false;
        }
    }
    get reBid(){
        if(this.record.data != undefined && this.item.Incl_on_re_bids__c != null && this.record.data.Bid_Number__c != null && 
            (this.item.Incl_on_re_bids__c == "Yes" && this.record.data.Bid_Number__c > 1)||(this.item.Incl_on_re_bids__c == "No" && 
             (this.record.data.Bid_Number__c == 0 || this.record.data.Bid_Number__c == 1))){
            return true;
        }else{
            return false;
        }
    }
    get Virtual(){
        if(this.opprecord.data != undefined && this.item.Is_this_a_virtual_trials_study__c != null && this.opprecord.data.Is_this_a_Virtual_Trials_Study__c != null && 
            this.item.Is_this_a_virtual_trials_study__c == this.opprecord.data.Is_this_a_Virtual_Trials_Study__c ){
            return true;
        }else{
            return false;
        }
    }
    get RequestedService(){
        if(this.record.data != undefined && this.item.Service__c != undefined && this.item.Service__c != null &&  this.record.data.Requested_Services__c != null){
            var service = this.item.Service__c.split(';');
                var isExist = false;
                for(var i=0; i< service.length; i++){
                    if(this.record.data.Requested_Services__c.includes(service[i])){
                        isExist = true;
                    }
                }
            return isExist;
        }
    }
    get FSP(){
        if(this.opprecord.data != undefined && this.item.FSP__c != null && this.opprecord.data.FSP__c != null && 
            this.item.FSP__c == this.opprecord.data.FSP__c){
            return true;
        }else{
            return false;
        }
    }
    get AgeGroup(){
        if(this.opprecord.data != undefined && this.item.Age_Group__c != undefined && this.item.Age_Group__c != null &&  this.opprecord.data.Population_Age_Group__c != null){
            var ageGroup = this.item.Age_Group__c.split(';');
                var isExist = false;
                for(var i=0; i< ageGroup.length; i++){
                    if(this.opprecord.data.Population_Age_Group__c.includes(ageGroup[i])){
                        isExist = true;
                    }
                }
            return isExist;
        }
    }
    get clientRebid(){
        if(this.record.data != undefined && this.item.Is_there_a_Client_Bid_Grid__c != null && this.record.data.Is_there_a_Client_Bid_Grid__c != null && 
            this.item.Is_there_a_Client_Bid_Grid__c == this.record.data.Is_there_a_Client_Bid_Grid__c){
            return true;
        }else{
            return false;
        }
    }
}