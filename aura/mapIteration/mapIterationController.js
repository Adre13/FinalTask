/**
 * Created by mdenisik on 10/24/2019.
 */
({
    doInit: function (component, event, helper) {
        var key = component.get("v.filmName");
        var filmsMap = component.get("v.filmsMap");
        var actorList = filmsMap[key].sort();
        component.set("v.actorsList", actorList);
    }
})