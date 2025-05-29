import { LightningElement, track, wire, api } from "lwc"
import getProgramTree from "@salesforce/apex/CNT_PSA_ProjectHierarchy.getProgramTree"

export default class LWC_psa_projectHierarchy extends LightningElement {
  @api recordId
  @api objectApiName
  @track projectHierarchy
  @track error
  @track showClosedForEntry = false;

  // wire up get program tree call to grab the tree items
  @wire(getProgramTree, {recordId: '$recordId', objectApiName: '$objectApiName' } )
  wireProgramTreeData({ error, data }) {
    if (data) {
      this.projectHierarchy = data
    } else if (error) {
      this.error = error && error.body ? error.body.message : error
    }
  }

  // returns true when project hierarchy has items, false otherwise
  // used to show/hide the menu for collapsing / expanding all items
  get hasProjectHierarchy() {
    return this.projectHierarchy && this.projectHierarchy.length && this.projectHierarchy.length > 0
  }

  // get the tree item component
  get treeItem() {
    return this.template.querySelector('c-lwc_psa_tree-item')
  }

  // collapses all tree item nodes
  collapseAll() {
    this.treeItem.collapse(true)
  }
  // expands all tree item nodes
  expandAll() {
    this.treeItem.expand(true)
  }
  
  showClosed() {
    this.showClosedForEntry = true;
    this.treeItem.showClosed();
  }

  hideClosed(){
    this.showClosedForEntry = false;
    this.treeItem.hideClosed();
  }

}