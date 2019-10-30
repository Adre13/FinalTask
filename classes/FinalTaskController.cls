/**
 * Created by mdenisik on 10/23/2019.
 */

public with sharing class FinalTaskController {

    @AuraEnabled
    public static List<String> getActorsName() {

        List<String> result = new List<String>();

        List<Actor__c> actualActors = [
                SELECT  Name
                FROM    Actor__c
        ];

        for (Actor__c actor : actualActors) {
            result.add(actor.Name);
        }
        result.add('');
        result.sort();

        return result;
    }

    @AuraEnabled
    public static String getFilms(String searchValue, Integer currentPage, Integer paginationSize) {

        List<ActorInFilms__c> actualRecords = new List<ActorInFilms__c>();
        Set<Id> actualFilms = new Set<Id>();
        List<Film__c> filmsForResult = new List<Film__c>();
        Map<String, List<String>> result = new Map<String, List<String>>();
        String soql = 'SELECT Film__c FROM ActorInFilms__c ';
        String safeSearchValue;
        String totalPages;

        if (searchValue != null && searchValue.length() > 0) {
            safeSearchValue = String.escapeSingleQuotes(searchValue);
            soql += 'WHERE Actor__r.Name LIKE \'' + safeSearchValue + '%\'';
        }

        actualRecords = Database.query(soql);

        for (ActorInFilms__c tempRecord : actualRecords) {
            actualFilms.add(tempRecord.Film__c);
        }

        filmsForResult = [
                SELECT  Name, (
                        SELECT Actor__r.Name
                        FROM ActorInFilms__r
                )
                FROM    Film__c
                WHERE   Id IN :actualFilms
                ORDER   BY Name
                LIMIT  :paginationSize
                OFFSET :(currentPage * paginationSize)
        ];

        Integer totalFilmsNumber = [
                SELECT  COUNT()
                FROM    Film__c
                WHERE   Id IN :actualFilms
        ];

        if (totalFilmsNumber == paginationSize) {
            totalPages = '0';
        }else {
            totalPages = String.valueOf(Math.floor((Double)totalFilmsNumber / paginationSize));
        }
        result.put('totalPagesNumber', new List<String>{totalPages});

        for (Film__c tempFilm : filmsForResult) {
            result.put(tempFilm.Name, new List<String>());
            for (ActorInFilms__c actor : tempFilm.ActorInFilms__r) {
                result.get(tempFilm.Name).add(actor.Actor__r.Name);
            }
        }

        return JSON.serialize(result);
    }
}