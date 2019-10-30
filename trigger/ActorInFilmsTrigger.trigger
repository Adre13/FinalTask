/**
 * Created by mdenisik on 10/21/2019.
 */

trigger ActorInFilmsTrigger on ActorInFilms__c (before delete, after insert) {

    if (Trigger.isBefore) {
        if (Trigger.isDelete) {
            ActorInFilmsTriggerHandler.changeFilmsQuantity(Trigger.old);
        }
    }
    if (Trigger.isAfter) {
        if (Trigger.isInsert) {
            ActorInFilmsTriggerHandler.changeFilmsQuantity(Trigger.new);
        }
    }

}