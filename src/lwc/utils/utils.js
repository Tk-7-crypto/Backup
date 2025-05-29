// ---------------------------------------------------------------------------
// -- Convenient utility  javascript functions
// ---------------------------------------------------------------------------

/**
 * Convenient sort data
 * @param {data[]} data to sort
 * @param {string} fieldName value representing the field to sort
 * @param {string} sortDirection value representing the sorting direction ('asc' or 'desc')
 * @return {data[]} sorted data
 *
 * @example:
 *    import { sortData } from 'c/utils'
 *    data = sortData(data, 'fieldToSort', 'asc')
 */
export const sortData = (data, fieldName, sortDirection) => {
  let order = sortDirection === 'asc' ? 1 : -1
  data = data.slice().sort((a, b) => {
    a = a[fieldName] || ''
    b = b[fieldName] || ''
    return (a === b ? 0 : a > b ? 1 : -1) * order
  })
  return data
}

/**
 * Sum array of objects by field name e.g. sumByField([{n:1},{n:2}], 'n')
 *
 * @param {[{}]} array
 * @param {string} fieldName
 * @return {number}
 */
export const sumByField = (array, fieldName) => {
  return array.length === 0 ? 0 : array.reduce((accumulator, currentValue) => {
    return accumulator + (currentValue[fieldName] || 0)
  }, 0)
}

/**
 * Group array of objects by a field name
 *
 * @param {[{}]} array
 * @param {string} fieldName
 * @return {{fieldName:[{}]}} - maps of distinct field name to array of items
 */
export const groupByField = (array, fieldName) => {
  return array.reduce((acc, obj) => {
    let accKey = obj[fieldName]
    acc[accKey] = acc[accKey] || []
    acc[accKey].push(obj)
    return acc
  }, {})
}

/**
 * Generates a unique id string (for use as keys in iterations)
 * @return {String} uniq id
 *
 * @example:
 *    import { generateUniqueId } from 'c/utils'
 *    let key = generateUniqueId()
 */
export const generateUniqueId = () => {
  return 'j' + ([1e7] + -1e3 + -4e3 + -8e3 + -1e11).replace(/[018]/g, c =>
    (c ^ crypto.getRandomValues(new Uint8Array(1))[0] & 15 >> c / 4).toString(16)
  )
}

/**
 * Reduces one or more LDS errors into a joined error message string
 * @param {FetchResponse|FetchResponse[]} errors
 * @return {string} representing the joined error messages
 *
 * @example:
 *    import { buildErrorMessage } from 'c/utils'
 *    let errorMessage = buildErrorMessage(exception)
 */
export const buildErrorMessage = (errors) => {
  if (!Array.isArray(errors)) {
    errors = [errors];
  }
  return (
    errors
      // Remove null/undefined items
      .filter(error => !!error).map(error => {
        // UI API read errors
        if (Array.isArray(error.body)) {
          return error.body.map(e => e.message);
        }
        // UI API DML, Apex and network errors
        else if (error.body && typeof error.body.message === 'string') {
          return error.body.message;
        }
        // JS errors
        else if (typeof error.message === 'string') {
          return error.message;
        }
        // Unknown error shape so try HTTP status text
        return error.statusText;
      })
      .reduce((prev, curr) => prev.concat(curr), [])
      // Remove empty strings
      .filter(message => !!message)
      // join multiple messages
      .join(' ')
  )
}

// ----------------------------------------------------------------------------
// ---- ShowToast
// ----------------------------------------------------------------------------
import { ShowToastEvent } from 'lightning/platformShowToastEvent'
export const ShowToast = {
  /**
   * Show a toast message for a specific instance and option
   * @param {*} self - instance from calling function to show toast message in
   * @param {{}} options - show toast event options
   *
   * @example
   * ShowToast.message(this, {variant: 'warning', message:'warning!', mode:'dismissable'})
   */
  message(instance, options) {
    instance.dispatchEvent(new ShowToastEvent(options))
  },
  /**
   * @example
   *  ShowToast.error(this, 'BOOM!')
   */
  error(instance, message, mode) {
    instance.dispatchEvent(new ShowToastEvent({ variant: 'error', message: message, mode: mode || 'sticky' }))
  },
  /**
   * @example
   *  ShowToast.success(this, 'Hoopla!')
   */
  success(instance, message, mode) {
    instance.dispatchEvent(new ShowToastEvent({ variant: 'success', message: message, mode: mode || 'dismissable' }))
  }
}

// ----------------------------------------------------------------------------
// ---- NavHelper
// ----------------------------------------------------------------------------
import { NavigationMixin } from 'lightning/navigation'
export const NavHelper = {
  /**
   * Navigate to the object's Recent or specific list view.
   * @param {*} self - instance from calling function that extends NavigationMixin...
   * @param {string} objectApiName - API name of the standard or custom object
   * @param {string} listViewName - optional target list view to use, defaults  to Recent
   */
  navigateToListView(self, objectApiName, listViewName) {
    let navlistendpoint = {
      type: 'standard__objectPage',
      attributes: {
        objectApiName: objectApiName,
        actionName: 'list'
      }
    }
    if (typeof listViewName !== 'undefined') {
      navlistendpoint.state = {
        // 'filterName' identifies the target list view.
        filterName: listViewName
      }
    }
    self[NavigationMixin.Navigate](navlistendpoint)
  },
  /**
   * Navigate to an object record
   * @param {*} self - instance from calling function that extends NavigationMixin...
   * @param {string} recordId - id for the object
   * @param {string} actionName - optional actionName defaults to 'view'
   */
  navigateToRecord(self, recordId, actionName) {
    self[NavigationMixin.Navigate]({
      type: 'standard__recordPage',
      attributes: {
        recordId: recordId,
        actionName: actionName || 'view'
      }
    });
  }
}

// ----------------------------------------------------------------------------
// ---- DataTableHelper
// ----------------------------------------------------------------------------
export const DataTableHelper = {
  /**
   * Convenient datatable sort
   *
   * @param {[{}]} data list of records to sort
   * @param {DatatableColumns[]} columns list of rendered datatable columns
   * @param {string} sortField string value representing the field to sort
   * @param {string} sortDirection string value representing the direction to sort ('asc' or 'desc')
   *
   * @example
   *  DataTableHelper.sortRecords(data, datatableColumns, sortField, sortDirection)
   */
  sortRecords(data, columns, sortField, sortDirection) {
    const fieldColumn = columns.find(item => item.fieldName === sortField)
    let sortByFld = sortField
    //  if sort field maps to a 'url' type column use the typeAttribute fieldName to sort
    if (typeof fieldColumn !== 'undefined' && fieldColumn !== null) {
      if (fieldColumn.type === 'url') {
        if (fieldColumn.typeAttributes && fieldColumn.typeAttributes.label) {
          sortByFld = fieldColumn.typeAttributes.label.fieldName
        }
      }
    }
    return sortData(data, sortByFld, sortDirection)
  },

  /**
   * Returns filtered data from applied text filter!
   *
   * @param {[{}]} data - list of records to filter
   * @param {DatatableColumns[]} columns list of rendered datatable columns
   * @param {string} filterText -  string value to filter data
   *
   * @example
   *  filteredData = DataTableHelper.quickFilterByText(data, datatableColumns, filterText)
   */
  quickFilterByText(data, columns, filterText) {
    let filteredData = [...data]

    // eval datable columns for quick filter!
    let fieldNameTypes = null
    if (typeof columns !== 'undefined' && columns !== null && columns && columns.length) {
      fieldNameTypes = columns.map(f => {
        let fieldName = f.fieldName
        let fieldType = f.type
        let urlFieldName = ''
        // handle case when url field, use the typeAttributes.label.fieldName instead to filter
        if (fieldType === 'url') {
          if (f.typeAttributes && f.typeAttributes.label) {
            urlFieldName = f.typeAttributes.label.fieldName
          }
        }
        return {
          name: fieldName,
          type: fieldType,
          urlFieldName: urlFieldName
        }
      })
    }
    const isFieldNamesValid = typeof fieldNameTypes !== 'undefined' && fieldNameTypes !== null && fieldNameTypes.length > 0
    const isFieldTextValid = typeof filterText !== 'undefined' && filterText !== null && filterText.length > 0

    // Filter specific fields by text!
    if (isFieldNamesValid && isFieldTextValid) {
      filteredData = data.filter(f => {
        let include = false
        // check if any field contains the filter text value
        for (let i = 0; i < fieldNameTypes.length; i++) {
          const col = fieldNameTypes[i].name
          const colType = fieldNameTypes[i].type
          const urlFieldName = fieldNameTypes[i].urlFieldName
          const val = f[col]
          let strVal = (typeof val !== 'undefined' && val !== null) ? String(val) : ''

          // # inject month-abbrev date year for date-local
          if (colType === 'date-local') {
            try {
              const valDate = new Date(`${strVal}T00:00:00`)
              let dtStr = valDate.toDateString()
              // remove leading 0s from date string value
              for (let i = 1; i < 10; i++) {
                dtStr = dtStr.replace(` 0${i}`, ` ${i}`)
              }
              strVal += ` ${dtStr} `
            } catch (error) {
              console.error('Error filtering date-local', error)
            }
          }

          //  use the urlFieldName to filter by!
          if (colType === 'url' && typeof urlFieldName !== 'undefined' && urlFieldName !== null) {
            // pull value by urlFieldName to compare
            const urlval = f[urlFieldName]
            strVal = (typeof urlval !== 'undefined' && urlval !== null) ? String(urlval) : strVal
          }

          // check if string value of search item contains the filtered text
          if (strVal.toLowerCase().indexOf(filterText.toLowerCase()) > -1) {
            include = true
            break
          }
        }
        return include
      })
    }
    return filteredData
  }

}