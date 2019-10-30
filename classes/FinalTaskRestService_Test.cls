/**
 * Created by mdenisik on 10/22/2019.
 */

@IsTest
private class FinalTaskRestService_Test {
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
    static void testPostService() {

        RestRequest request = new RestRequest();
        request.requestURI = 'https://brave-bear-9lre8u-dev-ed..my.salesforce.com/services/apexrest/Films/';
        request.httpMethod = 'POST';
        String body = '[{\"FilmName\":\"PostServiceTest\",\"Films\":[{\"ActorName\":\"testActor0\"},{\"ActorName\":\"testActor1\"},{\"ActorName\":\"testActor2\"}]}]';
        request.requestBody = Blob.valueOf(body);
        RestContext.request = request;

        Test.startTest();
        String answer = FinalTaskRestService.createOrUpdate();
        Test.stopTest();

        Integer actorsWith4Films = [
                SELECT  COUNT()
                FROM    Actor__c
                WHERE   CountFilms__c = 4
        ];

        System.assertEquals(3, actorsWith4Films);
        System.assertEquals('Were inserted 3 links between actors and films', answer);

    }

    @IsTest
    static void testPostServiceException() {

        RestRequest request = new RestRequest();
        request.requestURI = 'https://brave-bear-9lre8u-dev-ed..my.salesforce.com/services/apexrest/Films/';
        request.httpMethod = 'POST';
        String body = '[{\"FilmName\":\"\",\"Films\":[{\"ActorName\":\"testActor0\"},{\"ActorName\":\"testActor1\"},{\"ActorName\":\"testActor2\"}]}]';
        request.requestBody = Blob.valueOf(body);
        RestContext.request = request;

        Test.startTest();
        String answer = FinalTaskRestService.createOrUpdate();
        Test.stopTest();

        System.assert(answer.contains('Insert failed'));
    }

    @IsTest
    static void testPostServiceBulkTest() {

        RestRequest request = new RestRequest();
        request.requestURI = 'https://brave-bear-9lre8u-dev-ed..my.salesforce.com/services/apexrest/Films/';
        request.httpMethod = 'POST';
        String body = '[{\"FilmName\":\"Film1\",\"Films\":[{\"ActorName\":\"Actor1\"},{\"ActorName\":\"Actor2\"},' +
                '{\"ActorName\":\"Actor3\"}]},{\"FilmName\":\"Film2\",\"Films\":[{\"ActorName\":\"Actor1\"},' +
                '{\"ActorName\":\"Actor2\"},{\"ActorName\":\"Actor3\"}]},{\"FilmName\":\"Film3\",\"Films\":' +
                '[{\"ActorName\":\"Actor1\"},{\"ActorName\":\"Actor2\"},{\"ActorName\":\"Actor3\"}]},' +
                '{\"FilmName\":\"Film4\",\"Films\":[{\"ActorName\":\"Actor1\"},{\"ActorName\":\"Actor2\"},' +
                '{\"ActorName\":\"Actor3\"}]},{\"FilmName\":\"Film5\",\"Films\":[{\"ActorName\":\"Actor1\"},' +
                '{\"ActorName\":\"Actor2\"},{\"ActorName\":\"Actor3\"}]},{\"FilmName\":\"Film6\",\"Films\":' +
                '[{\"ActorName\":\"Actor1\"},{\"ActorName\":\"Actor2\"},{\"ActorName\":\"Actor3\"}]},' +
                '{\"FilmName\":\"Film7\",\"Films\":[{\"ActorName\":\"Actor1\"},{\"ActorName\":\"Actor2\"},' +
                '{\"ActorName\":\"Actor3\"}]},{\"FilmName\":\"Film8\",\"Films\":[{\"ActorName\":\"Actor1\"},' +
                '{\"ActorName\":\"Actor2\"},{\"ActorName\":\"Actor3\"}]},{\"FilmName\":\"Film9\",\"Films\":' +
                '[{\"ActorName\":\"Actor1\"},{\"ActorName\":\"Actor2\"},{\"ActorName\":\"Actor3\"}]},' +
                '{\"FilmName\":\"Film10\",\"Films\":[{\"ActorName\":\"Actor1\"},{\"ActorName\":\"Actor2\"},' +
                '{\"ActorName\":\"Actor3\"}]},{\"FilmName\":\"Film11\",\"Films\":[{\"ActorName\":\"Actor1\"},' +
                '{\"ActorName\":\"Actor2\"},{\"ActorName\":\"Actor3\"}]},{\"FilmName\":\"Film12\",\"Films\":' +
                '[{\"ActorName\":\"Actor1\"},{\"ActorName\":\"Actor2\"},{\"ActorName\":\"Actor3\"}]},' +
                '{\"FilmName\":\"Film13\",\"Films\":[{\"ActorName\":\"Actor1\"},{\"ActorName\":\"Actor2\"},' +
                '{\"ActorName\":\"Actor3\"}]},{\"FilmName\":\"Film14\",\"Films\":[{\"ActorName\":\"Actor1\"},' +
                '{\"ActorName\":\"Actor2\"},{\"ActorName\":\"Actor3\"}]},{\"FilmName\":\"Film15\",\"Films\":' +
                '[{\"ActorName\":\"Actor1\"},{\"ActorName\":\"Actor2\"},{\"ActorName\":\"Actor3\"}]},' +
                '{\"FilmName\":\"Film16\",\"Films\":[{\"ActorName\":\"Actor1\"},{\"ActorName\":\"Actor2\"},' +
                '{\"ActorName\":\"Actor3\"}]},{\"FilmName\":\"Film17\",\"Films\":[{\"ActorName\":\"Actor1\"},' +
                '{\"ActorName\":\"Actor2\"},{\"ActorName\":\"Actor3\"}]},{\"FilmName\":\"Film18\",\"Films\":' +
                '[{\"ActorName\":\"Actor1\"},{\"ActorName\":\"Actor2\"},{\"ActorName\":\"Actor3\"}]},' +
                '{\"FilmName\":\"Film19\",\"Films\":[{\"ActorName\":\"Actor1\"},{\"ActorName\":\"Actor2\"},' +
                '{\"ActorName\":\"Actor3\"}]},{\"FilmName\":\"Film20\",\"Films\":[{\"ActorName\":\"Actor1\"},' +
                '{\"ActorName\":\"Actor2\"},{\"ActorName\":\"Actor3\"}]},{\"FilmName\":\"Film21\",\"Films\":' +
                '[{\"ActorName\":\"Actor1\"},{\"ActorName\":\"Actor2\"},{\"ActorName\":\"Actor3\"}]},' +
                '{\"FilmName\":\"Film22\",\"Films\":[{\"ActorName\":\"Actor1\"},{\"ActorName\":\"Actor2\"},' +
                '{\"ActorName\":\"Actor3\"}]},{\"FilmName\":\"Film23\",\"Films\":[{\"ActorName\":\"Actor1\"},' +
                '{\"ActorName\":\"Actor2\"},{\"ActorName\":\"Actor3\"}]},{\"FilmName\":\"Film24\",\"Films\":' +
                '[{\"ActorName\":\"Actor1\"},{\"ActorName\":\"Actor2\"},{\"ActorName\":\"Actor3\"}]}]';
        request.requestBody = Blob.valueOf(body);
        RestContext.request = request;

        Test.startTest();
        FinalTaskRestService.createOrUpdate();
        Test.stopTest();

        Integer bulkActors = [
                SELECT  COUNT()
                FROM    Actor__c
                WHERE   CountFilms__c = 24
        ];

        System.assertEquals(3, bulkActors);
    }

    @IsTest
    static void testPutService() {

        RestRequest request = new RestRequest();
        request.requestURI = 'https://brave-bear-9lre8u-dev-ed..my.salesforce.com/services/apexrest/Films/';
        request.httpMethod = 'PUT';
        String body = '[{\"FilmName\":\"testFilm0\",\"Films\":[{\"ActorName\":\"testActor0\"},{\"ActorName\":\"testActor1\"}]},' +
                '{\"FilmName\":\"testFilm5\",\"Films\":[{\"ActorName\":\"testActor0\"}]},' +
                '{\"FilmName\":\"testFilm10\",\"Films\":[{\"ActorName\":\"testActor0\"},' +
                '{\"ActorName\":\"testActor5\"},{\"ActorName\":\"testActor10\"}]}]';
        request.requestBody = Blob.valueOf(body);
        RestContext.request = request;

        Test.startTest();
        String answer = FinalTaskRestService.deleteActors();
        Test.stopTest();

        Integer actorWith0Films = [
                SELECT  COUNT()
                FROM    Actor__c
                WHERE   CountFilms__c = 0
        ];

        System.assertEquals(1, actorWith0Films);
        System.assertEquals('Were deleted 4 actors from films', answer);
    }
}