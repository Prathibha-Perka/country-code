trigger HighRiskCaseCreationTrigger on AccessPro__HighRiskAccountEvent__e (after insert) {
    if (Trigger.isAfter && Trigger.isInsert) {
        new CaseEventProcessor().handleHighRiskEvents(Trigger.new);
    }
}