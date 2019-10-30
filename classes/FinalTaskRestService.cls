/**
 * Created by mdenisik on 10/21/2019.
 */

@RestResource(UrlMapping = '/Films/*')
global with sharing class FinalTaskRestService {

    private class FilmAndActorsWrapper {
        String FilmName { get; set; }
        List<Actor> Films { get; set; }
    }

    private class Actor {
        String ActorName { get; set; }
    }

    private static Set<String> allIncomingFilms = new Set<String>();
    private static Set<String> allIncomingActors = new Set<String>();
    private static Map<String, Set<String>> incomingFilmsWithActors = new Map<String, Set<String>>();
    private static Map<String, Set<String>> actualFilmsWithActors = new Map<String, Set<String>>();

    @HttpPost
    global static String createOrUpdate() {

        RestRequest request = RestContext.request;
        List<FilmAndActorsWrapper> incomingRecords = (List<FilmAndActorsWrapper>) JSON.deserialize(request.requestBody.toString(), List<FilmAndActorsWrapper>.class);

        Map<String, Film__c> insertedFilms = new Map<String, Film__c>();
        Map<String, Actor__c> insertedActors = new Map<String, Actor__c>();
        List<ActorInFilms__c> actorInFilmsForInsert = new List<ActorInFilms__c>();

        unwrapWrapper(incomingRecords);

        try {
            insertedFilms = checkFilms();
            insertedActors = checkActors();
        } catch (DmlException ex) {
            return ex.getMessage();
        }

        actualFilmsWithActors = getFilmsWIthActors();

        for (String filmName : incomingFilmsWithActors.keySet()) {
            Set<String> actorForInsert = incomingFilmsWithActors.get(filmName);
            actorForInsert.removeAll(actualFilmsWithActors.get(filmName));

            if (actorForInsert.size() > 0) {
                Id filmId = insertedFilms.get(filmName).Id;

                for (String newActor : actorForInsert) {
                    Id actorId = insertedActors.get(newActor).Id;
                    actorInFilmsForInsert.add(new ActorInFilms__c(
                            Film__c = filmId,
                            Actor__c = actorId
                    ));
                }
            }
        }

        if (actorInFilmsForInsert.size() > 0) {
            try {
                insert actorInFilmsForInsert;
            } catch (DmlException ex) {
                return ex.getMessage();
            }
        }

        return ('Were inserted ' + actorInFilmsForInsert.size() + ' links between actors and films');
    }

    @HttpPut
    global static String deleteActors() {

        RestRequest request = RestContext.request;
        List<FilmAndActorsWrapper> incomingRecords = (List<FilmAndActorsWrapper>) JSON.deserialize(request.requestBody.toString(), List<FilmAndActorsWrapper>.class);

        List<ActorInFilms__c> forDelete = new List<ActorInFilms__c>();
        Map<String, List<ActorInFilms__c>> filmsWithActorInFilms = new Map<String, List<ActorInFilms__c>>();

        unwrapWrapper(incomingRecords);

        List<Film__c> actualFilms = [
                SELECT  Name, (
                        SELECT  Actor__r.Name
                        FROM    ActorInFilms__r
                        WHERE   Actor__r.Name IN :allIncomingActors
                )
                FROM    Film__c
                WHERE   Name IN :allIncomingFilms
        ];

        for (Film__c film : actualFilms) {
            filmsWithActorInFilms.put(film.Name, film.ActorInFilms__r);
        }

        for (String filmName : filmsWithActorInFilms.keySet()) {
            for (ActorInFilms__c actorInFilms : filmsWithActorInFilms.get(filmName)) {
                Set<String> actorsSet = incomingFilmsWithActors.get(filmName);
                if (actorsSet.contains(actorInFilms.Actor__r.Name)) {
                    forDelete.add(actorInFilms);
                }
            }
        }

        if (forDelete.size() > 0) {
            try {
                delete forDelete;
            } catch (DmlException ex) {
                return ex.getMessage();
            }
        }

        return ('Were deleted ' + forDelete.size() + ' actors from films');
    }

    private static Map<String, Film__c> checkFilms() {

        Map<String, Film__c> result = new Map<String, Film__c>();

        List<Film__c> actualFilms = [
                SELECT  Name
                FROM    Film__c
                WHERE   Name IN :allIncomingFilms
        ];

        if (actualFilms.size() != allIncomingFilms.size()) {

            List<Film__c> filmsForInsert = new List<Film__c>();
            Set<String> tempAllFilms = allIncomingFilms.clone();

            for (Film__c tempFilm : actualFilms) {
                if (tempAllFilms.contains(tempFilm.Name)) {
                    tempAllFilms.remove(tempFilm.Name);
                }
            }

            for (String newFilm : tempAllFilms) {
                filmsForInsert.add(new Film__c(Name = newFilm));
            }

            insert filmsForInsert;

            actualFilms.addAll(filmsForInsert);

        }

        for (Film__c tempFilm : actualFilms) {
            result.put(tempFilm.Name, tempFilm);
        }

        return result;

    }

    private static Map<String, Actor__c> checkActors() {

        Map<String, Actor__c> result = new Map<String, Actor__c>();

        List<Actor__c> actualActors = [
                SELECT  Name
                FROM    Actor__c
                WHERE   Name IN :allIncomingActors
        ];

        if (actualActors.size() != allIncomingActors.size()) {
            List<Actor__c> actorsForInsert = new List<Actor__c>();
            Set<String> tempAllActors = allIncomingActors.clone();

            for (Actor__c tempActor : actualActors) {
                if (tempAllActors.contains(tempActor.Name)) {
                    tempAllActors.remove(tempActor.Name);
                }
            }

            for (String newActor : tempAllActors) {
                Actor__c tempActor = new Actor__c(
                        Name = newActor
                );
                actorsForInsert.add(tempActor);
            }

            insert actorsForInsert;

            actualActors.addAll(actorsForInsert);
        }

        for (Actor__c tempActor : actualActors) {
            result.put(tempActor.Name, tempActor);
        }

        return result;
    }

    private static void unwrapWrapper(List<FilmAndActorsWrapper> incomingRecords) {

        for (FilmAndActorsWrapper tempRecord : incomingRecords) {
            allIncomingFilms.add(tempRecord.FilmName);
            if (!incomingFilmsWithActors.containsKey(tempRecord.FilmName)) {
                incomingFilmsWithActors.put(tempRecord.FilmName, new Set<String>());
            }
            for (Actor tempActor : tempRecord.Films) {
                allIncomingActors.add(tempActor.ActorName);
                incomingFilmsWithActors.get(tempRecord.FilmName).add(tempActor.ActorName);
            }
        }
    }

    private static Map<String, Set<String>> getFilmsWIthActors() {

        Map<String, Set<String>> result = new Map<String, Set<String>>();

        List<Film__c> films = [
                SELECT  Name, (
                        SELECT Actor__r.Name
                        FROM ActorInFilms__r
                )
                FROM    Film__c
                WHERE   Name IN :allIncomingFilms
        ];

        for (Film__c film : films) {
            result.put(film.Name, new Set<String>());
            for (ActorInFilms__c actorInFilm : film.ActorInFilms__r) {
                result.get(film.Name).add(actorInFilm.Actor__r.Name);
            }
        }

        return result;
    }
}

/* test data for insert
[
	{
		"FilmName":"Film1",
		"Films":[
			{"ActorName":"Actor1"},
			{"ActorName":"Actor2"},
			{"ActorName":"Actor3"},
			{"ActorName":"Actor4"}
		]},
	{
		"FilmName":"Film2",
		"Films":[
			{"ActorName":"Actor1"},
			{"ActorName":"Actor4"},
			{"ActorName":"Actor6"}
		]},
	{
		"FilmName":"Film3",
		"Films":[
			{"ActorName":"Actor3"},
			{"ActorName":"Actor2"},
			{"ActorName":"Actor3"},
			{"ActorName":"Actor4"}
		]},
		{
		"FilmName":"Film1",
		"Films":[
			{"ActorName":"Actor1"},
			{"ActorName":"Actor2"},
			{"ActorName":"Actor3"},
			{"ActorName":"Actor4"}
		]}
]
*/
/* test data for delete
[
	{
		"FilmName":"Film1",
		"Films":[
			{"ActorName":"Actor1"}
		]},
	{
		"FilmName":"Film1",
		"Films":[
			{"ActorName":"Actor1"},
			{"ActorName":"Actor2"},
			{"ActorName":"Actor3"}
		]}
]
 */