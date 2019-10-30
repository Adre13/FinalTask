/**
 * Created by mdenisik on 10/21/2019.
 */

public with sharing class ActorInFilmsTriggerHandler {

    public static void changeFilmsQuantity(List<ActorInFilms__c> incomingList) {

        Map<Id, Integer> actorWithFilms = prepareActorAndFilms(incomingList);

        List<Actor__c> actualActors = [
                SELECT  CountFilms__c
                FROM    Actor__c
                WHERE   Id IN :actorWithFilms.keySet()
        ];

        for (Actor__c actor : actualActors) {
            if (Trigger.isInsert) {
                actor.CountFilms__c += actorWithFilms.get(actor.Id);
            } else if (Trigger.isDelete) {
                actor.CountFilms__c -= actorWithFilms.get(actor.Id);
            }
        }

        update actualActors;
    }

    private static Map<Id, Integer> prepareActorAndFilms(List<ActorInFilms__c> incomingList) {

        Map<Id, Integer> result = new Map<Id, Integer>();

        for (ActorInFilms__c tempRecord : incomingList) {
            if (tempRecord.Film__c != null) {
                if (result.containsKey(tempRecord.Actor__c)) {
                    Integer quantity = result.get(tempRecord.Actor__c);
                    quantity++;
                    result.put(tempRecord.Actor__c, quantity);
                } else {
                    result.put(tempRecord.Actor__c, 1);
                }
            }
        }

        return result;
    }
}