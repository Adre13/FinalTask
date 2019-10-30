/**
 * Created by mdenisik on 10/29/2019.
 */

@IsTest
private class ActorInFilmsTriggerHandler_Test {
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
    static void testTriggerHandlerInsert() {

        Integer actorsWith3Films = [
                SELECT  COUNT()
                FROM    Actor__c
                WHERE   CountFilms__c = 3
        ];

        System.assertEquals(10, actorsWith3Films);
    }

    @IsTest
    static void testTriggerHandlerDelete() {

        Actor__c actor = [
                SELECT  Name
                FROM    Actor__c
                WHERE   Name = 'testActor0'
        ];

        List<ActorInFilms__c> actorInFilms = [
                SELECT  Name
                FROM    ActorInFilms__c
                WHERE   Actor__c = :actor.Id
        ];

        delete actorInFilms;

        Integer actorsWith0Films = [
                SELECT  COUNT()
                FROM    Actor__c
                WHERE   CountFilms__c = 0
        ];

        System.assertEquals(1, actorsWith0Films);
    }
}