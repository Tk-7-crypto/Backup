({
    /*checkIfEmail: function (component, event, helper) {
        var value = component.find('inputField').getElement('value').value
        if (value && value.indexOf('@') === -1) {
            component.set('v.error', true);
            component.set('v.errorMessage', 'Must be a valid email address');
        } else {
            component.set('v.error', false);
            component.set('v.errorMessage', null);
        }
    },*/
    resetValue: function(component, event, helper) {
        var inputEl = component.find('inputField').getElement();
        var value = component.get('v.value');
        if(inputEl.value !== value) {
            component.set('v.value', inputEl.value);
        }
    },

    disableInput: function(component, event, helper) {
        var inputEl = component.find('inputField').getElement();
        
        inputEl.setAttribute('disabled', 'disabled');
    },
    enableInput: function(component, event, helper) {
        var inputEl = component.find('inputField').getElement();
        
        inputEl.removeAttribute('disabled');
    },
    setAddonsAllowed: function(component, event, helper) {
        var type = component.get('v.type');
        
        if (type === 'toggle' || type === 'radio' || type === 'checkbox' || type === 'search' || type === 'range') {
            component.set('v.addonsAllowed', false);
        } else {
            component.set('v.addonsAllowed', true);
        }

    }
})