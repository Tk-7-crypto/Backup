/*
 *  c-lwc_psa_tree-item
 *
 * Provides extended tree-view logic supporting icons and popovers
 *
 * Same params as original lightning-tree
 *  label
 *  href
 *  expanded
 *  items
 *  (see lighting-tree for full list)
 *
 * Additional params
 *   icon
 *   recordId
 *   objectApiName
 */
import { LightningElement, api, track } from 'lwc'
import { NavigationMixin } from 'lightning/navigation'

/* unique id to use for tree-item keys
  needs to start with a character for use as a html class name */
const generateUniqueId = () => {
  return 'j' + ([1e7] + -1e3 + -4e3 + -8e3 + -1e11).replace(/[018]/g, c =>
    (c ^ crypto.getRandomValues(new Uint8Array(1))[0] & 15 >> c / 4).toString(16)
  )
}

export default class Lwc_psa_treeItem extends NavigationMixin(LightningElement) {
  @track state = { items: [] }
  @api level = 0
  @api currentRecordId // pass in to trigger styling 'current' item

  @api
  get items () {
    return this.state.items
  }
  set items(values) {
    if (typeof values !== 'undefined') {
      let currentRecordId = typeof this.currentRecordId !== 'undefined' ? this.currentRecordId : null
      this.state.items = values.map(item => {
        let currentClassName = (currentRecordId !== null && currentRecordId === item.recordId) ? 'slds-theme_shade is-active-item' : 'slds-theme_default'
        // CUSTOM* percent complete on milestone
        let hasPercentComplete = typeof item.percentComplete !== 'undefined' && item.percentComplete > -1
        let percentCompleteFill = '#1589ee' // let percentCompleteFill = '#54698d'
        let percentCompleteWidth = hasPercentComplete && item.percentComplete < 100 ? item.percentComplete : 100 // max bar/rect width to 100
        let percentCompleteTextX = hasPercentComplete ? (item.percentComplete > 105 ? 105 : item.percentComplete) + 5 : 0 // calc where to put text
        return {
          key: generateUniqueId(),
          label: item.label,
          items: item.items,
          metatext: item.metatext,
          name: item.name,
          href: item.href,
          expanded: item.expanded || false,
          disabled: item.disabled || false,
          closedForEntry: item.closedForUnitEntry,
          invisible: item.closedForUnitEntry,
          icon: item.icon,                    // NEW*
          recordId: item.recordId,            // NEW* for popover lookup
          objectApiName: item.objectApiName,  // NEW* for popover lookup
          showPopover: false,
          currentClassName: currentClassName,  // for rendering current item

          // CUSTOM* percent complete on milestone
          percentComplete: item.percentComplete,
          hasPercentComplete: hasPercentComplete,
          percentCompleteTextX: percentCompleteTextX,
          percentCompleteFill: percentCompleteFill,
          percentCompleteWidth: percentCompleteWidth

        }
      })
    }
  }

  /*
   * expands items
   * {expandAll} - when true expands child elements
   */
  @api expand (expandAll) {
    this.expandTreeItem(true, expandAll)
  }

  /*
   * collapse items
   * {collapseAll} - when true collapses child elements
   */
  @api collapse (collapseAll) {
    this.expandTreeItem(false, collapseAll)
  }

  /* return item margin style for tree! */
  get itemLevelMarginClass () {
    return `item-level-margin-left-${this.level}`
  }

  @api showClosed (){
    this.displayClosedTreeItem(true, true);
  }

  @api hideClosed (){
    this.displayClosedTreeItem(false, true);
  }

  /* next tree level */
  get nextLevel() {
    return this.level + 1
  }

  /* parent is at level 0 */
  get isChild () {
    return this.level > 0
  }

  /* when the tree item anchor / label is clicked
   * use navigation mixin when record id is supplied
   * otherwise fall back to supporting underlying href
   */
  handleClick(event) {
    let recordId = event.currentTarget.dataset.recordId
    if (recordId) {
      event.preventDefault()
      event.stopPropagation()
      this[NavigationMixin.Navigate]({
        type: 'standard__recordPage',
        attributes: {
          recordId: recordId,
          actionName: 'view'
        }
      })
    }
  }

  /*
  * handle mouse over;
  *   Finds the current item and sets the showPopover attribute to true, if its not already,
  *   and trigger loading popover lookup data!
  */
  handleMouseOver(event) {
    let stateItems = this.state.items
    let recordId = event.currentTarget.dataset.recordId
    let mItem = stateItems.find(f => { return f.recordId === recordId})
    if (typeof mItem !== 'undefined' && mItem.showPopover === false) {
      mItem.showPopover = true
      this.state = { items: stateItems } // manually update to get tracked reactive data to re-render!
    }
  }

  /*
   * when component rendered
   * hide / show tree items based on underlying expanded value
   */
  renderedCallback () {
    let items = this.state.items
    // show or hide the item element based on the item expanded attribute
    if (items && items.length && items.length > 0) {
      items.forEach(item => {
        let elem = this.template.querySelector(`.${item.key}`)
        if (elem && elem !== null) {
          elem.classList[item.expanded ? 'remove' : 'add']('slds-hide')
        }
      })
    }
  }

  /* action to collapse / expand single tree items */
  toggleItem (event) {
    // key for item is in data-value attribute
    let treeItemKey = event.currentTarget.dataset.value
    let treeItem = this.state.items.find(f => { return f.key === treeItemKey })
    if (typeof treeItem !== 'undefined' && treeItem !== null) {
      treeItem.expanded = !treeItem.expanded
    }
  }

  /*
   * Handles toggling (expands/collapse) items and toggling children components
   *
   * {expanded} - when true expands items when false collapses items
   * {cascadeToggleAllItems} - optional boolean to expands / collapses child items when true calls child methods
   */
  expandTreeItem (expanded, cascadeToggleAllItems) {
    if (this.state && this.state.items && this.state.items.length > 0) {
      // set expaned attribute on current elements
      this.state.items.forEach( stateItem => {
        stateItem.expanded = expanded
      })
      // now cascade down to child items when specified
      if (typeof cascadeToggleAllItems !== 'undefined' && cascadeToggleAllItems === true) {
        const treeItems = this.template.querySelectorAll('c-lwc_psa_tree-item')
        if (treeItems && treeItems.length) {
          for (let ti=0; ti < treeItems.length; ti++) {
            treeItems[ti][expanded ? 'expand' : 'collapse'](cascadeToggleAllItems)
          }
        }
      }
    }
  }

  /*
   * Handles toggling (display/hide) closed-for-entry items and toggling children components
   *
   * {displayCLosed} - when true displays closed items when false hides items
   * {cascadeToggleAllItems} - optional boolean to display / hide child items when true calls child methods
   */
  displayClosedTreeItem (displayClosed, cascadeToggleAllItems) {
    if (this.state && this.state.items && this.state.items.length > 0) {
      // set invisible attribute on current elements
      this.state.items.forEach( stateItem => {
        stateItem.invisible = (!displayClosed && stateItem.closedForEntry)
      })
      // now cascade down to child items when specified
      if (typeof cascadeToggleAllItems !== 'undefined' && cascadeToggleAllItems === true) {
        const treeItems = this.template.querySelectorAll('c-lwc_psa_tree-item')
        if (treeItems && treeItems.length) {
          for (let ti=0; ti < treeItems.length; ti++) {
            treeItems[ti][displayClosed ? 'showClosed' : 'hideClosed']()
          }
        }
      }
    }
  }
}