trigger AccountRiskLevelTrigger on Account (after update) {
    if (Trigger.isAfter && Trigger.isUpdate) {
        new AccountRiskEventPublisherHelper().publishHighRiskEvents(Trigger.new, Trigger.oldMap);
    }
}