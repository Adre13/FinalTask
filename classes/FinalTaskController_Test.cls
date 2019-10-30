/**
 * Created by mdenisik on 10/25/2019.
 */

@IsTest
private class FinalTaskController_Test {
    @TestSetup
    static void setup() {

        List<Film__c> films = new List<Film__c>();
        List<Actor__c> actors = new List<Actor__c>();
        List<ActorInFilms__c> actorInFilms = new List<ActorInFilms__c>();

        for (Integer i = 0; i < 20; i++) {
            films.add(new Film__c(Name = 'testFilm' + i));
        }

        for (Integer i = 0; i < 10; i++) {
            actors.add(new Actor__c(Name = 'testActor' + i));
        }

        insert films;
        insert actors;

        for (Integer actor = 0; actor < 10; actor++) {
            actorInFilms.add(new ActorInFilms__c(
                    Film__c = films[actor].Id,
                    Actor__c = actors[actor].Id
            ));
            actorInFilms.add(new ActorInFilms__c(
                    Film__c = films[actor + 5].Id,
                    Actor__c = actors[actor].Id
            ));
            actorInFilms.add(new ActorInFilms__c(
                    Film__c = films[actor + 10].Id,
                    Actor__c = actors[actor].Id
            ));
        }

        insert actorInFilms;
    }

    @IsTest
    static void testListActors() {

        List<String> result = FinalTaskController.getActorsName();
        System.assertEquals(11, result.size());
    }

    @IsTest
    static void testGetFilms() {

        String testActor = 'testActor0';

        Test.startTest();
        String result = FinalTaskController.getFilms(testActor, 0, 3);
        Test.stopTest();

        Map<String, List<String>> filmsWithActors = (Map<String, List<String>>)JSON.deserialize(result, Map<String, List<String>>.class);
        Integer totalPages = Integer.valueOf(filmsWithActors.get('totalPagesNumber')[0]);

        System.assertEquals(0, totalPages);
        System.assertEquals(4, filmsWithActors.size());
    }

}