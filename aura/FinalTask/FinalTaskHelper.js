/**
 * Created by mdenisik on 10/24/2019.
 */
({
    prepareTable: function (component, helper) {

        var currentPage = component.get("v.currentPage");
        var paginationSize = component.get("v.paginationSize");
        var selectedActor = component.get("v.selectedActor");
        var searchValueField = component.get("v.searchValue");
        var searchValue = selectedActor + searchValueField;

        var films = component.get("c.getFilms");
        films.setParams({
            "searchValue" : searchValue,
            "currentPage" : currentPage,
            "paginationSize" : paginationSize
        });
        films.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = JSON.parse(response.getReturnValue());
                var totalPages = +result["totalPagesNumber"][0];
                component.set("v.totalPages", totalPages );
                delete result["totalPagesNumber"];
                component.set("v.films", result);
                var keySet = Object.keys(result).reverse();
                component.set("v.filmsKey", keySet);
            }
        });
        $A.enqueueAction(films);
    }
})