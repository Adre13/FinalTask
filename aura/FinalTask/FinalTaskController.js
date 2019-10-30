/**
 * Created by mdenisik on 10/23/2019.
 */
({
    init: function (component, event, helper) {

        var actorsList = component.get("c.getActorsName");
        actorsList.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.actors", response.getReturnValue());
            }
        });
        $A.enqueueAction(actorsList);
        helper.prepareTable(component, helper);
    },

    selectSearchActors: function (component, event, helper) {

        var searchValue = component.get("v.searchValue");
        var searchValueList = component.get("v.actors");
        component.set("v.currentPage", 0);
        var newSearchValue = [];

        if (searchValue.length !== 0) {
            for (var i = 0; i < searchValueList.length; i++) {
                if (searchValueList[i].startsWith(searchValue)) {
                    newSearchValue.push(searchValueList[i]);
                }
            }
        }

        component.set("v.searchList", newSearchValue);
        component.set("v.selectedActor", "");
        helper.prepareTable(component, helper);
    },

    passTableInfo: function (component, event, helper) {

        component.set("v.searchValue", "");
        component.set("v.currentPage", 0);
        helper.prepareTable(component, helper);
    },
    next: function (component, event, helper) {

        var currentPage = 1 + component.get("v.currentPage");
        component.set("v.currentPage", currentPage);
        helper.prepareTable(component, helper);
    },

    previous: function (component, event, helper) {

        var currentPage = component.get("v.currentPage") - 1;
        component.set("v.currentPage", currentPage);
        helper.prepareTable(component, helper);
    }
})