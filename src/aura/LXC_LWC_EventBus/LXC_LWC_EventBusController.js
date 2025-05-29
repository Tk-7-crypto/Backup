({
	handleRefreshView: function (component, event, helper) {
		$A.get('e.force:refreshView').fire()

		console.log('FIRED REFRESH VIEW!')
	}
})