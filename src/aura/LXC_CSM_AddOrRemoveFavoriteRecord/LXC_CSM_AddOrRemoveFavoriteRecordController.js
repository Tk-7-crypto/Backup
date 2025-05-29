({
    init: function (component, event, helper) {
        helper.getIsFavorite(component);
    },

    toggleFavorite: function (component, event, helper) {
        helper.addOrRemoveFavorite(component);
    }
})