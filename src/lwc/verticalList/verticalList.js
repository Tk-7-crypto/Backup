/* eslint-disable vars-on-top */
/* eslint-disable no-console */
/* eslint-disable no-alert */
import { LightningElement, api} from 'lwc';

export default class VerticalList extends LightningElement {
    @api productList;
    @api listType;
    @api currentLayer;

    getSelectedProductRecord(event) {
      var productIndex = 0 ;
      var hierarchyChain = '';
      const productId = event.detail.name;
      var productName = '';
      for(productIndex in this.productList) {
          if(this.productList[productIndex].Id === productId) {
              hierarchyChain = this.productList[productIndex].Hierarchy_Chain__c;
              productName = this.productList[productIndex].Name;
              break;
          }
      }
      this.dispatchEvent(new CustomEvent('productselected', { detail: { 'hierarchyChain' : hierarchyChain, 'currentLayer' : this.currentLayer, 'productId' : productId, 'productName' : productName}}));
    }
}