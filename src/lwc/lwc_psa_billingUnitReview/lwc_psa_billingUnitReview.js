/*
https://iqvia--devxgalen.lightning.force.com/lightning/n/BillingReview?c__project=aAce00000004DZm&c__parentProject=aAce00000004DZm
*/
class MilestoneJS {
  constructor(MilestoneWrapper) {
    // set all MilestoneWrapper fields on this object
    Object.keys(MilestoneWrapper).forEach(k => {
      this[k] = MilestoneWrapper[k]
    })
  }
}

class DeliverablesJS {
  constructor(DeliverableWrapper) {
    // set all DeliverableWrapper fields on this object
    Object.keys(DeliverableWrapper).forEach(k => {
      this[k] = DeliverableWrapper[k]
    })
  }
}

// convenient function to sum array object properties
// sumUp(someArray, 'someArrayProp')
const sumUp = ((objs, prop) => {
  return objs.reduce((a,b) => a + b[prop], 0)
})

import { LightningElement, track, wire } from "lwc";
import { loadStyle } from "lightning/platformResourceLoader";
import { getUrlVars } from 'c/urlVars'

import globalFlexipageStyles from "@salesforce/resourceUrl/PSAGlobalFlexipageStyles";

import getServiceLineList from "@salesforce/apex/CNT_PSA_LWCBillingUnitReview.getServiceLineList";
import getAllMilestones from "@salesforce/apex/CNT_PSA_LWCBillingUnitReview.getAllMilestones";
import getAllMilestonesNoFilters from "@salesforce/apex/CNT_PSA_LWCBillingUnitReview.getAllMilestonesNoFilters";
import makeHold from "@salesforce/apex/CNT_PSA_LWCBillingUnitReview.makeHold";
import removeHold from "@salesforce/apex/CNT_PSA_LWCBillingUnitReview.removeHold";
import excludeDeliverable from "@salesforce/apex/CNT_PSA_LWCBillingUnitReview.excludeDeliverable";
import approveForBilling from "@salesforce/apex/CNT_PSA_LWCBillingUnitReview.approveForBilling";
import createBillingMilestone from "@salesforce/apex/CNT_PSA_LWCBillingUnitReview.createBillingMilestone";
import applyBillingMilestone from "@salesforce/apex/CNT_PSA_LWCBillingUnitReview.applyBillingMilestone";
import removeBillingMilestone from "@salesforce/apex/CNT_PSA_LWCBillingUnitReview.removeBillingMilestone";

/*
Final Columns should be:
Budget (Rename),
Billed (Rename),
Remaining (New Column),
Eligible for Billing (No Change),
Approved for Billing (Rename)
*/
const columns = [
  { type: 'button-icon', initialWidth: '35',
    typeAttributes: {
      name: 'clear',
      iconName: 'utility:clear',
      iconClass: { fieldName: 'clearIconClass' },
      variant: 'bare',
      // variant: 'border-filled',
      title: 'Clear'
    },
  },
  { type: 'button-icon', initialWidth: '35',
    typeAttributes: {
      name: 'addUnits',
      iconName: 'utility:add',
      iconClass: 'fill-brand',
      variant: 'bare',
      // variant: 'border-filled',
      title: 'Add Units'
    }
  },
  { label: 'Milestone', fieldName: 'milestoneUrl', initialWidth: 200, type: 'url', sortable: 'true', typeAttributes: {label: { fieldName: 'name' } }, cellAttributes: { alignment: 'left' } },
  { label: 'Service Line', fieldName: 'serviceLineUrl', initialWidth: 200, type: 'url', sortable: 'true', typeAttributes: { label: { fieldName: 'serviceLineName' } }, cellAttributes: { alignment: 'left' } },
  { label: "Service", fieldName: "serviceUrl", initialWidth: 200, type: "url", sortable: "true", typeAttributes: { label: { fieldName: 'serviceName' } }, cellAttributes: { alignment: "left" } },
  { label: "Budget", fieldName: "budgetQuantity", type: "number", sortable: "true", cellAttributes: { alignment: "left" } },
  { label: "Billed", fieldName: "billedQuantity", type: "number", sortable: "true", cellAttributes: { alignment: "left" } },
  { label: "Remaining", fieldName: "remainingQuantity", type: "number", sortable: "true", cellAttributes: { alignment: "left" } },
  { label: "Eligible For Billing", fieldName: "eligibleForBilling", type: "number", sortable: "true", cellAttributes: { alignment: "left" } },
  { label: "Approved For Billing", fieldName: "newUnits", type: "number", sortable: true, cellAttributes: { alignment: "left", class: { fieldName: 'newUnitBackground' }, iconName: { fieldName: 'newUnitIconName' }, iconPosition: 'right', iconClass:'slds-p-left_medium' } }
]

const eligiblecolumns = [
  { label: "Deliverable", fieldName: 'linkName', type: 'url', sortable: "true", cellAttributes: { alignment: "left" }, typeAttributes: { label: {fieldName: "serviceName" }, target: '_blank'} },
  { label: "Quantity", fieldName: "quantity", type: "number", cellAttributes: { alignment: "left" } },
  { label: "Actual Date", fieldName: "dateActual", type: "date", cellAttributes: { alignment: "left" } },
  { label: "Target", fieldName: "targetName", type: "text", cellAttributes: { alignment: "left" } },
  { label: "Drug", fieldName: "drugName", type: "text", cellAttributes: { alignment: "left" } },
  { label: "Resource", fieldName: "resource", type: "text", cellAttributes: { alignment: "left" } },
  { label: "Tracking Number", fieldName: "trackingNumber", type: "text", cellAttributes: { alignment: "left" } }
];

const onholdcolumns = [
  { label: "Deliverable", fieldName: "serviceName", type: "text", cellAttributes: { alignment: "left" } },
  { label: "Quantity", fieldName: "quantity", type: "number", cellAttributes: { alignment: "left" } },
  { label: "Actual Date", fieldName: "dateActual", type: "date", cellAttributes: { alignment: "left" } },
  { label: "Target", fieldName: "targetName", type: "text", cellAttributes: { alignment: "left" } },
  { label: "Drug", fieldName: "drugName", type: "text", cellAttributes: { alignment: "left" } },
  { label: "Resource", fieldName: "resource", type: "text", cellAttributes: { alignment: "left" } },
  { label: "Not Billed Reason", fieldName: "notBilledReason", type: "text", cellAttributes: { alignment: "left" } }
];

const UNIT_BATCH_SIZE = 50;

export default class Lwc_psa_billingUnitReview extends LightningElement {
  @track clickedButtonLabel;
  @track columns = columns;
  @track eligiblecolumns = eligiblecolumns;
  @track onholdcolumns = onholdcolumns;
  @track data;
  @track milestones = [];
  @track onEligibleDeliverablesdata = [];
  @track onholdDeliverablesdata = [];
  projectID = getUrlVars().c__project;
  parentProjectID = getUrlVars().c__parentProject;
  billingProjectID =
    this.projectID !== this.parentProjectID
      ? this.projectID
      : this.parentProjectID;
  returnToProject = "Return To Project";
  @track projectUrl = `/lightning/r/${this.projectID}/view`
  @track options = [];
  @track servicelineNamesList = [];
  @track value;
  @track endDate;
  @track startDate;
  selectedservice = "";
  selectedservicecode = "";
  selectedmilestoneid = "";
  @track selectedserviceline = [];
  @track sumofeligibleunits = 0;
  @track sumofholdunits = 0;
  @track milestoneId = undefined;
  @track numOfUnits = 0;
  @track eligibleForBilling = 0;
  @track today = new Date();
  today =
    this.today.getFullYear() +
    "-" +
    (this.today.getMonth() + 1) +
    "-" +
    this.today.getDate();
  @track actualDate = this.today;
  @track totalBilledAmount = 0;
  @track activeSections = ["A", "B", "C"];
  @track activeSectionsMessage = "";
  @track selectedCheckboxValue = true;
  @track viewFilters = true;
  // ---
  @track showAddUnits = false // for rendering modal
  @track showAddUnitSpinner = false // true when rendering spinner in addUnit popop
  @track psaMilestoneSortingBy = null // support milestone sorting
  @track psaMilestoneSortingDirection = 'asc' // support milestone sorting
  @track disableBillNewUnitsButton = false;
  /* retrieves the underlying lwc helper */
  get lwcHelper() {
    return this.template.querySelector('c-lwc_helper')
  }

  connectedCallback() {
    Promise.all([
      loadStyle(this, globalFlexipageStyles + "/PSAGlobalFlexipageStyles.css")
    ])
  }

  /* renders error.body.message as an error variant toast message
   */
  handleError(error) {
    let errorMessage = (error && error.body && error.body.message) ? error.body.message : 'Error Occurred'
    this.lwcHelper.toastError(errorMessage)
  }

  // wireServiceLinesResult // local variable to maintain our wire service line result
  @wire(getServiceLineList, {
    projectID: "$projectID",
    parentProjectID: "$parentProjectID"
  })
  wireServiceLines(result) {
    this.wireServiceLinesResult = result;
    if (result.data) {
      this.options = result.data;
      let tempServicelines = [];
      for (let i = 0; i < this.options.length; i++) {
        if (
          this.options[i].serviceLineName !== null ||
          this.options[i].serviceLineName !== "" ||
          this.options[i].serviceLineName !== undefined
        ) {
          tempServicelines.push({
            label: this.options[i].serviceLineName,
            value: this.options[i].serviceLineName
          });
        }
      }
      this.servicelineNamesList = tempServicelines;
    } else if (result.error) {
      this.handleError(result.error)
      this.options = undefined;
    }
  }

  wiremilestonesdata // local variable to hold our wired get all milestones not filters!
  @wire(getAllMilestonesNoFilters, {
    projectID: "$projectID",
    parentProjectID: "$parentProjectID"
  })
  wiremilestones(result) {
    this.wiremilestonesdata = result;

    if (result.data) {
      if (this.milestones.length === 0) {
        this.milestones = [];
        let tempServiceLines = [];

        for (let i = 0; i < result.data.length; i++) {
          let m = new MilestoneJS(result.data[i]);
          tempServiceLines.push(m.serviceLineName);
          if (m.eligibleForBilling !== 0) {
            // this.milestones.push({...m});
            this.milestones.push(JSON.parse(JSON.stringify(m)));
          }
        }
        this.selectedserviceline = tempServiceLines;
      }
    } else if (result.error) {
      this.handleError(result.error)
      this.milestones = undefined;
    }
  }

  handleSectionToggle(event) {
    const openSections = event.detail.openSections;
    if (openSections.length === 0) {
      this.activeSectionsMessage = "All sections are closed";
    } else {
      this.activeSectionsMessage = "Open sections: " + openSections.join(", ");
    }
  }

  handlestartDateChange(event) {
    const select = event.detail.value;
    this.startDate = select;
    //refreshApex(this.wiremilestonesdata);
    this.loadMilestones();
  }

  handleendDateChange(event) {
    const select = event.detail.value;
    this.endDate = select;
    // refreshApex(this.wiremilestonesdata)
    this.loadMilestones();
  }

  handleActualDateChange(event) {
    const select = event.detail.value;
    this.actualDate = select;
  }

  handleChange(event) {
    const select = event.detail.value;
    this.selectedserviceline = select;
    // refreshApex(this.wiremilestonesdata);
    this.loadMilestones();
  }

  handleCheckboxChange(event) {
    this.selectedCheckboxValue = event.target.checked;
    this.loadMilestones();
    this.selectedservice = "";
  }
  handleFiltersToggle() {
    this.viewFilters = !this.viewFilters;
  }

  serviceLineFilterApplied(event) {
    this.selectedserviceline = event.detail;
    this.loadMilestones();
    this.selectedservice = "";
  }

  @track milestoneTableLoadingState = false

  // retrieves getAllMilestones
  loadMilestones() {
    // define our load milestone action
    let loadMilestoneAction = () => {
      this.milestoneTableLoadingState = true
      this.milestones = undefined
      getAllMilestones({
        serviceline: this.selectedserviceline,
        startDate: this.startDate,
        endDate: this.endDate,
        projectId: this.parentProjectID
      }).then(result => {
        this.handleGetAllMilestones(result)
        this.milestoneTableLoadingState = false
      }).catch(error => {
        this.handleError(error)
        this.milestones = undefined;
      })
    }
    // When pending changes exist, prompt user before loading
    if (this.hasPendingUnits) {
      let confirmObj = { heading: 'Pending Updates', message: 'Are you sure you would like to refresh the list and clear the pending updates?' }
      this.lwcHelper.confirm(confirmObj).then(
        ok => {
          if (typeof ok !== 'undefined') {
            loadMilestoneAction() // execute load milestone action on ok
          }
        },
        // eslint-disable-next-line
        cacnel => {
          // Handle when cancel is clicked
          // // console.log('cancel', cacnel)
        }
      )
    } else {
      loadMilestoneAction() // execute load milestone action right away when no pending units
    }
  }

  // handles promised result from call to getAllMilestones
  handleGetAllMilestones (result) {
    this.selectedmilestoneid = "";
    this.milestones = [];
    for (let i = 0; i < result.length; i++) {
      let m = new MilestoneJS(result[i]);
      // sum up quantity of eligible for billing items
      // m.eligibleForBilling = m.eligibleDeliverables.reduce((a, b) => a + b.quantity, 0)
      m.eligibleForBilling = sumUp(m.eligibleDeliverables, 'quantity')

      if (this.selectedCheckboxValue === true) {
        if (m.eligibleForBilling > 0) {
          this.milestones.push(m);
        }
      } else if (this.selectedCheckboxValue === false) {
        this.milestones.push(m);
      }
    }
  }

  /*
   * Makes billing milestones for selected units using a scalable batch process
  */
  billSelectedUnits(){
	this.disableBillNewUnitsButton = true;
    const datatable = this.template.querySelector(".milestonetable");
    const selectedRows = datatable.getSelectedRows();
    const lwcHelper = this.lwcHelper

    // Require rows to be selected
    if (typeof selectedRows === 'undefined' || selectedRows === null || selectedRows.length <= 0) {
      lwcHelper.toastError('Please select the items to process and try again.')
      return
    }

    // show page spinner
    lwcHelper.showModalSpinner();

    console.log('Found '+selectedRows.length+' services to bill. Creating billing milestones...');

    //Create the billing milestones
    let billingMilestones = [];
    this.batchBillMilestones(selectedRows)
    .then(() => {
      // once approved, grab all the milestones again
      return getAllMilestones({ serviceline: this.selectedserviceline, startDate: this.startDate, endDate: this.endDate, projectId: this.parentProjectID })
    })
    .then(milestoneResults => {
      // handle all milestones
      this.handleGetAllMilestones(milestoneResults)
      lwcHelper.hideModalSpinner()
      lwcHelper.toastSuccess('Billing Milestone Was Created with Updated Deliverables')
    })
    .catch(error => {
      lwcHelper.toastError((error && error.body && error.body.message) ? error.body.message : error, 'sticky')
      lwcHelper.hideModalSpinner()
    })
  }

  /*
   * This async function allows us to await the results of the batch and catch any errors that crop up
   */
  async batchBillMilestones(milestoneWrappers){
    const lwcHelper = this.lwcHelper
    let success = true;

    for(let i = 0; i < milestoneWrappers.length; i++){
      let milestoneWrapper = milestoneWrappers[i];
      let billingMilestone = await createBillingMilestone({milestoneWrapper: milestoneWrapper });
      console.log('Created billing milestone: '+billingMilestone.Name,billingMilestone);

      //Need to put an await here, but still handle the error
      let error = await this.batchApplyMilestones(billingMilestone.Id, milestoneWrapper.deliverables)
      .then(() => {
        console.log('Finished with billing milestone: '+billingMilestone.Name);
        return null;
      }, error => error);

      if(error) {
        //lwcHelper.toastError((error && error.body && error.body.message) ? error.body.message : error, 'sticky')
        removeBillingMilestone({milestoneId: billingMilestone.Id})
        throw error;
      }
    }

    console.log('Finished billing all milestones.');
    return 'Success';
  }

  /*
   * This async function allows us to awaits all the batches when applying milestones to tasks - preventing CPU limits from getting hit
   */
  async batchApplyMilestones(billingMilestoneId, deliverables){
    console.log('Preparing batches for billing milestone '+billingMilestoneId);
    let batches = this.makeArrayBatchable(deliverables, UNIT_BATCH_SIZE);
    console.log('Made '+batches.length+' batches.');
    for(let i = 0; i < batches.length; i++){
      console.log('Sending batch '+i+'...');
      await applyBillingMilestone({milestoneId: billingMilestoneId, deliverables: batches[i]});
      console.log('Batch done.');
    }
    console.log('Done applying milestone '+billingMilestoneId+' to deliverables.');
    return 'Success';
  }

  /*
   * executes approve for billing apex logic on the selected milestones
   * Deprecated in favor of new batch method
   */
  approveForBilling() {
    const datatable = this.template.querySelector(".milestonetable");
    const selectedRows = datatable.getSelectedRows();
    const lwcHelper = this.lwcHelper

    // Require rows to be selected
    if (typeof selectedRows === 'undefined' || selectedRows === null || selectedRows.length <= 0) {
      lwcHelper.toastError('Please select the items to process and try again.')
      return
    }

    // show page spinner
    lwcHelper.showModalSpinner()

    approveForBilling({ milestoneWrappers: selectedRows }).then(() => {
      // once approved, grab all the milestones again
      return getAllMilestones({ serviceline: this.selectedserviceline, startDate: this.startDate, endDate: this.endDate, projectId: this.parentProjectID })
    }).then(milestoneResults => {
      // handle all milestones
      this.handleGetAllMilestones(milestoneResults)
      lwcHelper.hideModalSpinner()
      lwcHelper.toastSuccess('Billing Milestone Was Created with Updated Deliverables')
    }).catch(error => {
      // lwcHelper.toastError((error && error.body && error.body.message) ? error.body.message : error, 'sticky') // 'sticky' to persist message
      lwcHelper.toastError((error && error.body && error.body.message) ? error.body.message : error)
      lwcHelper.hideModalSpinner()
    })
  }

  get hasPendingUnits () {
    let rtn = false
    if (typeof this.milestones !== 'undefined' && this.milestones.length > 0) {
      let withNewUnits = this.milestones.find(m => {
        return typeof m.newUnits !== 'undefined' && m.newUnits > 0
      })
      rtn = typeof withNewUnits !== 'undefined' && withNewUnits !== null ? true : false
    }
    return rtn
  }

  /*
   * action for adding selected
   */
  addSelected() {
    //get selected eligible deliverables
    const datatable = this.template.querySelector(".eligibletable");
    const selectedRows = datatable.getSelectedRows();

    // Require rows to be selected
    if (typeof selectedRows === 'undefined' || selectedRows === null || selectedRows.length <= 0) {
      this.lwcHelper.toastError('Please select the items to add and try again.')
      return
    }

    let milestones = [...this.milestones]
    let selectedMilestoneRow = this.selectedAddUnitRow

    // Move item from eligibleDeliverables to deliverables
    let milestone = milestones.find(f => { return f.id === selectedMilestoneRow.id })
    milestone.deliverables = typeof milestone.deliverables !== 'undefined' ? milestone.deliverables : []
    selectedRows.forEach(row => {
      let eligIndex = milestone.eligibleDeliverables.findIndex(f => f.id === row.id)
      let deliverableItem = milestone.eligibleDeliverables.find(f => { return f.id === row.id })
      // pop-from milestones eligibleDeliverables
      if (eligIndex > -1) {
        milestone.eligibleDeliverables.splice(eligIndex, 1) // remove from eligibleDeliverables
      }
      // sumup current eligible for deliverables
      milestone.eligibleForBilling = sumUp(milestone.eligibleDeliverables, 'quantity')
      // add to the milestone deliverables
      milestone.deliverables.push(deliverableItem) // add to deliverables

      // update milestone new units / total-bilable amounts!
      if (typeof row.quantity !== 'undefined' && row.quantity !== '' && row.quantity !== 0) {
        milestone.newUnitBackground = 'slds-theme_shade'
        milestone.newUnitIconName = 'utility:check'
        milestone.clearIconClass = 'fill-destructive'

        milestone.newUnits = (milestone.newUnits || 0) + row.quantity
        milestone.totalBillableAmount = (milestone.totalBillableAmount || 0) + row.totalBillableAmount
      }
    })

     // make sure the current milestone row is checked!
    this.checkMilestoneRow(selectedMilestoneRow.id, true)

    // refresh milestones!
    this.milestones = milestones

    // close the modal window!
    this.closeAddUnits()
	
	this.disableBillNewUnitsButton = false;
  }

  /*
   * convenient method to check / uncheck a specific datatable row
   * used when adding / clearing row
   */
  checkMilestoneRow (rowId, addValue) {
    const mstonetable = this.template.querySelector('.milestonetable')
    const selectedStones = mstonetable.getSelectedRows()
    // row ids to check; starting with the current selected row (when addValue is true)
    let selectedIds = addValue ? [rowId]  : []
    // and the rest of the selected ids
    selectedStones.forEach(stone => {
      if (stone.id !== rowId) {
        selectedIds.push(stone.id)
      }
    })
    mstonetable.selectedRows = selectedIds
  }

  /* action to clear current row
   */
  clearSelectedDeliverable(row) {
    // const id = row.id;
    // let tempmilestones = [];

    // move the deliverables to eligibleDeliverables for the milestone!
    let milestones = [...this.milestones]
    let milestone = milestones.find(f => { return f.id === row.id })
    if (typeof milestone !== 'undefined' && milestone !== null) {
      milestone.deliverables.forEach(d => {
        if (d.eligibleForBilling === 'Yes') {
          milestone.eligibleDeliverables.push({...d})
        }
      })
      milestone.eligibleForBilling = sumUp(milestone.eligibleDeliverables, 'quantity')
      milestone.newUnitBackground = ''
      milestone.newUnitIconName = undefined
      milestone.clearIconClass = ''
      milestone.newUnits = 0
      milestone.deliverables  = []
    }
    // uncheck the current milestone row!
    this.checkMilestoneRow(row.id, false)

    // refresh milestones!
    this.milestones = milestones
  }

  // ------- not billed reason!
  @track notBilledReason
  @track showHoldNotBilledReason = false
  @track showExcludeNotBilledReason = false

  get hasNotBilledReason () {
    return typeof this.notBilledReason === 'undefined' || this.notBilledReason === '' || this.notBilledReason.length <= 0
  }

  // on notBilledReason change - maintain bindings between selected tracked value and the lighting text area
  onNotBilleReasonChange(event) {
    let val = event.detail ? event.detail.value : event.currentTarget.value
    this.notBilledReason = val
  }

  makeSelectedHold () {
    // 1st...prompt for not billed reason!
    this.notBilledReason = ''
    this.showHoldNotBilledReason = true
  }

  cancelMakeSelectedHold () {
    this.notBilledReason = ''
    this.showHoldNotBilledReason = false
  }

  doMakeSelectedHold() {
    // this.activeSections = ["A", "B", "C"];
    const datatable = this.template.querySelector(".eligibletable");
    const selectedRows = datatable.getSelectedRows();

    // transpose into selected rows to update
    let updateSelectedRecords = selectedRows.length > 0 ? selectedRows.map(selectedRow => {
      return { Id: selectedRow.id }
    }) : []

     // render showAddUnit modal spinner
    this.showAddUnitSpinner = true

    // call apex
    makeHold({ updateSelectedRecords: updateSelectedRecords, notBilledReason: this.notBilledReason }).then(result => {
      if (result === "Success") {
        // move rows from eligible to hold!
        // grab current data
        let onEligibleDeliverablesdata = [...this.onEligibleDeliverablesdata]
        let onholdDeliverablesdata = [...this.onholdDeliverablesdata]

        selectedRows.forEach((srow) => {
          // find the selected eligible index, remove from list, add element to onhold!
          let eligIndex = onEligibleDeliverablesdata.findIndex(f => f.id === srow.id)
          if (eligIndex > -1) {
            let elem = onEligibleDeliverablesdata.find(f => f.id === srow.id)
            elem.billingHold = true // set as billing hold!
            elem.notBilledReason = this.notBilledReason
            onEligibleDeliverablesdata.splice(eligIndex, 1) // remove from eligible
            onholdDeliverablesdata.push(elem) // add to hold
          }
        })

        // write back to milestone!
        let milestones = [...this.milestones]
        let selectedRow = this.selectedAddUnitRow
        let milestone = milestones.find(f => { return f.id === selectedRow.id })

        milestone.eligibleDeliverables = onEligibleDeliverablesdata
        milestone.holdDeliverables = onholdDeliverablesdata
        milestone.eligibleForBilling = sumUp(milestone.eligibleDeliverables, 'quantity')

        // clear underlying to attempt to refresh
        this.onholdDeliverablesdata = onholdDeliverablesdata
        this.onEligibleDeliverablesdata = onEligibleDeliverablesdata
        this.milestones = milestones

        this.showHoldNotBilledReason = false
        this.showAddUnitSpinner = false
      }
    }).catch(error => {
      this.showAddUnitSpinner = false
      this.lwcHelper.toastError((error && error.body && error.body.message) ? error.body.message : error)
    })
  }

  /*
   * calls apex removeHold
   */
  removeSelectedHold() {
    const datatable = this.template.querySelector(".holdtable");
    const selectedRows = datatable.getSelectedRows();

    // transpose into selected rows to update
    let updateSelectedRecords = selectedRows.length > 0 ? selectedRows.map(selectedRow => {
      return { Id: selectedRow.id }
    }) : []

    // render showAddUnit modal spinner
    this.showAddUnitSpinner = true

    // apex to update the data...!
    removeHold({ updateSelectedRecords: updateSelectedRecords }).then(() => {
      // !! move from hold to eligible!
      let onEligibleDeliverablesdata = [...this.onEligibleDeliverablesdata]
      let onholdDeliverablesdata = [...this.onholdDeliverablesdata]
      selectedRows.forEach((srow) => {
        // find the selected eligible index, remove from list, add element to onhold!
        let eligIndex = onholdDeliverablesdata.findIndex(f => f.id === srow.id)

        if (eligIndex > -1) {
          let elem = onholdDeliverablesdata.find(f => f.id === srow.id)
          elem.billingHold = false // unset billing hold!

          onholdDeliverablesdata.splice(eligIndex, 1) // remove from hold eligible
          onEligibleDeliverablesdata.push(elem) // add to eligible
        }
      })

      // write back to milestone!
      let milestones = [...this.milestones]
      let selectedRow = this.selectedAddUnitRow
      let milestone = milestones.find(f => { return f.id === selectedRow.id })

      milestone.eligibleDeliverables = onEligibleDeliverablesdata
      milestone.holdDeliverables = onholdDeliverablesdata
      milestone.eligibleForBilling = sumUp(milestone.eligibleDeliverables, 'quantity')

      // clear underlying to attempt to refresh
      this.onholdDeliverablesdata = onholdDeliverablesdata
      this.onEligibleDeliverablesdata = onEligibleDeliverablesdata
      this.milestones = milestones

      this.showAddUnitSpinner = false

    }).catch(error => {
      this.showAddUnitSpinner = false
      this.lwcHelper.toastError((error && error.body && error.body.message) ? error.body.message : error)
    })
  }

  excludeDeliverable() {
    // 1st...prompt for not billed reason!
    this.notBilledReason = ''
    this.showExcludeNotBilledReason = true
  }

  cancelExcludeDeliverable() {
    this.notBilledReason = ''
    this.showExcludeNotBilledReason = false
  }

  /*
   * calls apex excludeDeliverable
   */
  doExcludeDeliverable() {
    const datatable = this.template.querySelector(".eligibletable");
    const selectedRows = datatable.getSelectedRows();

    // transpose into selected rows to update
    let updateSelectedRecords = selectedRows.length > 0 ? selectedRows.map(selectedRow => {
      return { Id: selectedRow.id }
    }) : []


    // render showAddUnit modal spinner
    this.showAddUnitSpinner = true

    excludeDeliverable({ updateSelectedRecords: updateSelectedRecords, notBilledReason: this.notBilledReason }).then(result => {
      if (result === "Success") {
        // grab current eligible deliverables and milestones
        let onEligibleDeliverablesdata = [...this.onEligibleDeliverablesdata]
        let milestones = [...this.milestones]
        let selectedRow = this.selectedAddUnitRow

        selectedRows.forEach((srow) => {
          // find the selected eligible index, remove from list
          let eligIndex = onEligibleDeliverablesdata.findIndex(f => f.id === srow.id)
          if (eligIndex > -1) {
            onEligibleDeliverablesdata.splice(eligIndex, 1) // remove from eligible data
          }
        })

        // find the selected row in the milestones list!
        let milestone = milestones.find(f => { return f.id === selectedRow.id })
        milestone.eligibleDeliverables = onEligibleDeliverablesdata
        milestone.eligibleForBilling = sumUp(this.selectedAddUnitRow.eligibleDeliverables, 'quantity')

        this.milestones = milestones
        this.onEligibleDeliverablesdata = onEligibleDeliverablesdata

        this.showAddUnitSpinner = false // hide spinner when data is re-loaded
        this.showExcludeNotBilledReason = false
        this.lwcHelper.toastSuccess('Selected Deliverable is excluded from Billing')
      }
    }).catch(error => {
      this.showAddUnitSpinner = false // hide spinner on error
      this.lwcHelper.toastError(error.message.body)
    })
  }

  handleSave(event) {
    this.saveDraftValues = event.detail.draftValues;
  }

  handleRowAction(event) {
    const actionName = event.detail.action.name;
    const row = event.detail.row;
    switch (actionName) {
      case "clear":
        this.clearSelectedDeliverable(row);
        break;
      case "addUnits":
        this.openAddUnits(row)
        break
      default:
        break
    }
  }

  // start modal add units popup support----

  selectedAddUnitRow
  /*
   * close action for our add units modal popup
   */
  closeAddUnits () {
    this.showAddUnits = false
    this.selectedAddUnitRow = undefined
  }

  openAddUnits (row) {
    this.selectedserviceline = [] // clear ?
    this.selectedAddUnitRow = row

    // set up for eligible data
    this.selectedservice = row.serviceName
    this.selectedservicecode = row.serviceCode
    this.selectedmilestoneid = row.id
    this.selectedserviceline.push(row.serviceLineName)

    // Build list of eligible and hold deliverables from selected row!
    if (row && row.eligibleDeliverables) {
      this.onEligibleDeliverablesdata = row.eligibleDeliverables.map(r => { return new DeliverablesJS(r) })
      this.eligibleForBilling = 0;  // ????
    }
    if (row && row.holdDeliverables) {
      this.onholdDeliverablesdata = row.holdDeliverables.map(r => { return new DeliverablesJS(r) })
    }

    // clear any previous counts
    this.sumofeligibleunits = 0
    this.sumofholdunits = 0

    // show modal
    this.showAddUnits = true
  }

  get requiresSelectedMilestonetable () {
    return this.getSelectedRowLengthFor('.milestonetable') <= 0 || this.showPageSpinner || this.disableBillNewUnitsButton // require at least 1 selected row!
  }

  // enable / disable buttons when rows are selected / de-selected...and spinner is showing!
  get requiresSelecetdEligibleDeliverables () {
    return this.getSelectedRowLengthFor('.eligibletable') <= 0 || this.showAddUnitSpinner // require at least 1 selected row!
  }
  // enable disable button based on row selections
  get requiresSelectedHoldtable () {
    return this.getSelectedRowLengthFor('.holdtable') <= 0 || this.showAddUnitSpinner
  }
  // returns number of selected rows for datatable by querySelector name
  getSelectedRowLengthFor(templateName) {
    const datatable = this.template.querySelector(templateName)
    return datatable !== null ? datatable.getSelectedRows().length : 0
  }
// ---- end add units modal popup...

  getSelectedEligibleUnits(event) {
    const selectedRows = event.detail.selectedRows;
    this.sumofeligibleunits = 0;

    for (let i = 0; i < selectedRows.length; i++) {
      this.sumofeligibleunits =
        this.sumofeligibleunits + selectedRows[i].quantity;
    }
  }

  getSelectedHoldUnits(event) {
    const selectedRows = event.detail.selectedRows;
    this.sumofholdunits = 0;

    for (let i = 0; i < selectedRows.length; i++) {
      this.sumofholdunits = this.sumofholdunits + selectedRows[i].quantity;
    }
  }
  // support sorting the milestones!
  /* The method onsort event handler for the psa metric data table */
  updatePsaMilestoneSorting(event) {
    this.milestones = this.sortData(this.milestones, event.detail.fieldName, event.detail.sortDirection)
    this.psaMilestoneSortingBy = event.detail.fieldName
    this.psaMilestoneSortingDirection = event.detail.sortDirection
  }
  /* simple sort data
   *
   * {data} - list of data to sort
   * {fieldName} - column / field to sort by
   * {sortDirection} - asc or desc
   */
  sortData(data, fieldName, sortDirection) {
    let order = sortDirection === 'asc' ? 1 : -1
    data = data.slice().sort((a, b) => {
      a = a[fieldName] || ''
      b = b[fieldName] || ''
      return (a === b ? 0 : a > b ? 1 : -1) * order
    })
    return data
  }

  /* Split array into batch chunks
  */
  makeArrayBatchable(sourceArray, batchSize){
    let batchedArray = [];
    for(let i = 0; i < sourceArray.length; i+= batchSize){
      let batch = sourceArray.slice(i, i+batchSize);
      batchedArray.push(batch);
    }
    return batchedArray;
  }
} 
