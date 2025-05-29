/*
 * To use add the containing aura component 'LXC_LWC_EventBus' to the page.
 *
 *  # Automatically triggers refresh on all components when CurrentPageReference is updated
 *  #
 *  # Supports window.dispatchEvent(new CustomEvent('force:refreshView')) from any other component and triggers refresh
 */
import { LightningElement, wire } from 'lwc'
import { CurrentPageReference } from 'lightning/navigation'
import { ShowToastEvent } from 'lightning/platformShowToastEvent'

// refresh view event name dispatched up to parent
const REFRESH_VIEW_EVENT = 'refreshview'

// supported window events
const REFRESH_EVENT_LISTENER = 'force:refreshView' //  handles (window.dispatchEvent('force:refreshView'))

export default class Lwc_eventBus extends LightningElement {
  isStale = false // local indicator for stale page needing refreshed
  /*
   * wire up the current page reference and auto refresh when page is stale
   */
  @wire(CurrentPageReference)
  wiredCurrentPageReference(value) {
    let { state, error } = value;
    // eslint-disable-next-line
    console.log('wiredCurrentPageReference', state, this.isStale)
    if (state) {
      if (this.isStale) {
        this.isStale = false
        this.dispatchEvent(new CustomEvent(REFRESH_VIEW_EVENT, { detail: {} }))
      } else {
        this.isStale = true
      }
    } else if (error) {
      let errorMessage = (error && error.body && error.body.message) ? error.body.message : 'LWC Event Bus Error Occurred'
      this.dispatchEvent(new ShowToastEvent({ variant: 'error', message: errorMessage }))
    }
  }
  /*
   * define the refresh action for the supported window refresh event
   * triggers parent (aura component) to reload all data for the view by issuing: $A.get('e.force:refreshView').fire()
   */
  handleRefreshEvent = () => {
    this.dispatchEvent(new CustomEvent(REFRESH_VIEW_EVENT, { detail: {} }))
  }
  /* Add event listeners when component is realized!
   */
  connectedCallback () {
    window.addEventListener(REFRESH_EVENT_LISTENER, this.handleRefreshEvent, false)
  }
  /* Remove event listeners when component is destroyed!
   */
  disconnectedCallback () {
    window.removeEventListener(REFRESH_EVENT_LISTENER, this.handleRefreshEvent, false)
  }
  
}