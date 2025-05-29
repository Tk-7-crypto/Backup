({
    init: function (component, event, helper) {
        console.log('Date Picker : init ');
        component.set('v.dateDebouncer', helper.debounceCreator(component, 1, helper.processDateValue));
        helper.createLocaleDatePatternMap(component);
        helper.processDateValue(component);
        
        //component.set("v.displayDate", component.get("v.value"));

        component.closeDatepicker = $A.getCallback(function(){
            if (component.isValid()) {
                helper.closeDatepicker(component, event, helper);
            } else {
                window.removeEventListener('click', component.closeDatepicker);
            }
        });

        window.addEventListener('click', $A.getCallback(component.closeDatepicker));
        
        component.set('v.isMobile', $A.get('$Browser.formFactor') === 'DESKTOP' ? false : true);
    },
    valueChanged: function(component, event, helper) {
        var dateDebouncer = component.get('v.dateDebouncer');
        var value = component.get('v.value');
        console.log('datepicker value: ' + value);
        var clickedValue = component.get('v.clickedValue');
        console.log('datepicker: clickedValue' + clickedValue);

        if (value === clickedValue) {
            return;
        }

        component.set('v.clickedValue', null);
        dateDebouncer(component);
    },
    processNewDate: function(component, event, helper) {
        console.log('datepicker: processNewDate');
        var currentValue = component.get('v.value');
        var displayDate = component.get('v.displayDate');
        var datePattern = component.get('v.valueFormat');
        var locale = helper.getLocale();
        var localeDatePattern = helper.getLocaleDatePattern(component, locale);
        var selectedDate = $A.localizationService.parseDateTime(displayDate, localeDatePattern, true);

        if (selectedDate === null) {
            component.set('v.value', null);
            component.set('v.timestamp', null);

            helper.closeDatepicker(component, event, helper);
            return;
        }

        var formattedDisplayDate = $A.localizationService.formatDate(selectedDate.toString(), datePattern);

        if (currentValue === formattedDisplayDate) {
            helper.closeDatepicker(component, event, helper);
            return;
        }
        console.log('formattedDisplayDate: ' + formattedDisplayDate);
        component.set('v.value', formattedDisplayDate);
        helper.closeDatepicker(component, event, helper);
    },
    clickedDateInput: function(component, event, helper) {
        console.log('Date Picker : clickedDateInput ');
        event.preventDefault();
        event.stopPropagation();


        if (event.target.tagName === 'use' || event.target.tagName === 'svg') {
            return;
        }
        
        var notDisabled = !component.get('v.disabled');
        var displayDate = component.get('v.displayDate');
        var dateInput = component.find('date-input');
        var datePickerOpen = component.get('v.datePickerOpen');
        var container = component.find('dp-container').getElement();

        dateInput.focus();
        if(notDisabled && !datePickerOpen) {
            helper.determineReadOnly(component);
            component.set('v.datePickerOpen', true);
            container.addEventListener('focusout', $A.getCallback(function() {
                helper.closeDatepicker(component, event, helper);
            }), { once: true });
        } else if(notDisabled && datePickerOpen) {
            dateInput.focus();
        }
    },
    clickedDateIcon: function (component, event, helper) {
        console.log('Date Picker : clickedDateIcon ');
        event.preventDefault();
        event.stopPropagation();
        var notDisabled = !component.get('v.disabled');

        if(notDisabled){
            component.set('v.datePickerOpen', true);
        }
    },
    selectToday: function (component, event, helper) {
        console.log('Date Picker : selectToday ');
        event.preventDefault();
        event.stopPropagation();
        var currentDate = new Date();
        var datePattern = component.get('v.valueFormat');
        var dontCloseMenu = component.get('v.dontCloseMenu');
        var formattedValueDate = $A.localizationService.formatDate(currentDate.toString(), datePattern);

        console.log(datePattern);
        console.log(currentDate.toString());console.log(currentDate);console.log(formattedValueDate);
        component.set('v.value', formattedValueDate);

        if(dontCloseMenu) {
            component.set('v.dontCloseMenu', false);
        }
        helper.closeDatepicker(component, event, helper);
    },
    setDateValue: function (component, event, helper) {
        console.log('Date Picker : setDateValue: Start ');
        event.preventDefault();
        event.stopPropagation();
        var currentDate = component.get("v.value"); //new Date();
        var datePattern = component.get('v.valueFormat');
        var dontCloseMenu = component.get('v.dontCloseMenu');
        var formattedValueDate = $A.localizationService.formatDate(currentDate.toString(), datePattern);

        component.set('v.value', formattedValueDate);
		console.log('Date Picker : setDateValue: End ');
    },
    clickNext: function (component, event, helper) {
        console.log('Date Picker : clickNext ');
        event.stopPropagation();
        var currentMonth = Number(component.get('v.selectedMonth'));
        var monthLabels = component.get('v.monthLabels');
        var nextMonth;

        if (currentMonth === 11) {
            nextMonth = 0;
            helper.setSelectedYear(component, Number(component.get('v.selectedYear')) + 1);
        } else {
            nextMonth = currentMonth + 1;
        }

        component.set('v.selectedMonth', nextMonth);
        component.set('v.calendarRows', helper.getCalendarRows(component));
        component.set('v.selectedMonthText', monthLabels[nextMonth].fullName);
    },
    clickPrev: function (component, event, helper) {
        console.log('Date Picker : clickPrev ');
        event.stopPropagation();
        var currentMonth = Number(component.get('v.selectedMonth'));
        var monthLabels = component.get('v.monthLabels');
        var prevMonth;

        if (currentMonth === 0) {
            prevMonth = 11;
            helper.setSelectedYear(component, Number(component.get('v.selectedYear')) - 1);
        } else {
            prevMonth = currentMonth - 1;
        }

        component.set('v.selectedMonth', prevMonth);
        component.set('v.calendarRows', helper.getCalendarRows(component));
        component.set('v.selectedMonthText', monthLabels[prevMonth].fullName);
    },
    closeDatepicker: function (component, event, helper) {
        console.log('Date Picker : closeDatepicker ');
        helper.closeDatepicker(component, event, helper);
    },
    yearChanged: function (component, event, helper) {
        console.log('Date Picker : yearChanged ');
        component.set('v.calendarRows', helper.getCalendarRows(component));
    },
    preventBlur: function(component, event, helper){
        console.log('Date Picker : preventBlur ');
        event.preventDefault();
    },
    clickDate: function (component, event, helper) {
        console.log('Date Picker : clickDate ');
        var dontCloseMenu = component.get('v.dontCloseMenu');
        var selectedRowIndex = component.get('v.selectedDateRowIndex');
        var selectedColIndex = component.get('v.selectedDateColIndex');
        var dateRangeErrorMessage = component.get('v.daysRangeErrorMessage');

        if (!$A.util.isEmpty(selectedRowIndex) && !$A.util.isEmpty(selectedRowIndex)) {
            var selectedDayObj = component.get('v.calendarRows')[selectedRowIndex][selectedColIndex];
            selectedDayObj.isSelected = false;
        }

        var clickedRowIndex = parseInt(event.currentTarget.dataset.row_index,10);
        var clickedColIndex = parseInt(event.currentTarget.dataset.col_index,10);
        var calendarRows = component.get('v.calendarRows');
        var clickedDayObj = component.get('v.calendarRows')[clickedRowIndex][clickedColIndex];

        clickedDayObj.isSelected = true;
        console.log('clickedDayObj:::');
		console.log(clickedDayObj);
        component.set('v.selectedDateRowIndex', clickedRowIndex);
        component.set('v.selectedDateColIndex', clickedColIndex);
        component.set('v.calendarRows', calendarRows);

        var selectedDay = parseInt(event.currentTarget.dataset.day,10);
        var selectedMonth = parseInt(event.currentTarget.dataset.month,10);
        var selectedYear = component.get('v.selectedYear');
        var timeStamp = Date.UTC(selectedYear, selectedMonth, selectedDay);

        //var currentDate = new Date(selectedYear, selectedMonth, selectedDay);
        var currentDate = new Date(selectedYear, selectedMonth, selectedDay);
        var datePattern = component.get('v.valueFormat');
        var localeDatePattern = component.get('v.datePatternMap')[helper.getLocale()];
        //var formattedDisplayDate = $A.localizationService.formatDate(currentDate.toString(), localeDatePattern);
        //var value = $A.localizationService.formatDate(currentDate.toString(), datePattern);
        var value = selectedMonth + 1 + '/' + selectedDay + '/' + selectedYear;
		var formattedDisplayDate = selectedMonth + 1 + '/' + selectedDay + '/' + selectedYear;
                
        if(!helper.isValidDate(component, currentDate)) {
            alert(dateRangeErrorMessage);
            return false;
        }
        component.set('v.clickedValue', value);
        component.set('v.value', value);
        component.set('v.displayDate', formattedDisplayDate);
        component.set('v.timestamp', timeStamp);
        component.set('v.currentDate', currentDate);

        if(dontCloseMenu) {
            component.set('v.dontCloseMenu', false);
        }
        helper.closeDatepicker(component, event, helper);
        helper.determineReadOnly(component);
    },
    validateDateRange: function(component, event, helper) {
        var value = component.get('v.value');
        if(value != null) {
            var selectedDate = new Date(value.split('/')[2], value.split('/')[0], value.split('/')[1]);
            if(!helper.isValidDate(component, selectedDate)) {
                return false;
            }
        }
        if(value == null) {
            return false;
        }
        return true;
    },
    preventDatePickerClose: function (component, event, helper) {
        console.log('Date Picker : preventDatePickerClose ');
        var container = component.find('dp-container').getElement();
        event.stopPropagation();
    },
    showError: function(component, event, helper) {
        console.log('Date Picker : showError ');
        var errorMessage = event.getParam('arguments').errorMessage;

        component.set('v.errorMessage', errorMessage);
        component.set('v.error', true);
    },
    hideError: function(component, event, helper) {
        console.log('Date Picker : hideError ');
        component.set('v.errorMessage', null);
        component.set('v.error', false);
    },
    openYear: function(component, event, helper) {
        console.log('Date Picker : openYear ');
        component.set('v.dontCloseMenu', true);
        event.stopPropagation();
    }
})