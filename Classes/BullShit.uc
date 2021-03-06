///////////////////////////////////////////////////////////////////////////////
// filename:    BullShit.uc
// version:     115
// author:      Michiel 'El Muerte' Hendriks <elmuerte@drunksnipers.com>
// perpose:
///////////////////////////////////////////////////////////////////////////////

class BullShit extends Mutator config;

const VERSION = "400";

// settings
var config float fKillFrequency;
var config bool bKillMessages;
var config float fChatFrequency;
var config bool bChatMessages;
var config float fEndFrequency;
var config bool bEndMessages;
var config float fScoreFrequency;
var config bool bScoreMessages;

var config bool bUseDelay;
var config float fMinDelay;
var config float fMaxDelay;

var config int iGreetDelay;

var config bool bChitChat;
var config float fChitChat;
var config int iChitChat;

var BullShitSpectator spec;

const DeltaTime = 0.1;

function PreBeginPlay()
{
    log("[~] Starting BullShit version: "$VERSION);
    log("[~] Michiel 'El Muerte' Hendriks - elmuerte@drunksnipers.com");
    log("[~] The Drunk Snipers - http://www.drunksnipers.com");
    if (spec == none)
    {
        spec = Spawn(class'BullShitSpectator');
	    spec.config = self;
        spec.SetTimer(iChitChat, true);
        if (bUseDelay) setTimer(DeltaTime, true);
        // check lines
        if (bKillMessages)
        {
            bKillMessages=(spec.msgGotKilled.length+spec.msgKilled.length+spec.msgSuicide.length+spec.msgTeamKill.length+spec.msgMadeTeamKill.length)>0;
            if (bKillMessages)
            {
                if (spec.msgGotKilled.length==0) spec.msgGotKilled.Insert(1,1);
                if (spec.msgKilled.length==0) spec.msgKilled.Insert(1,1);
                if (spec.msgSuicide.length==0) spec.msgSuicide.Insert(1,1);
                if (spec.msgTeamKill.length==0) spec.msgTeamKill.Insert(1,1);
                if (spec.msgMadeTeamKill.length==0) spec.msgMadeTeamKill.Insert(1,1);
            }
        }
        if (bChatMessages)
        {
            bChatMessages=(spec.msgHelloTrigger.length+spec.msgByeTrigger.length+spec.msgXtra1Trigger.length+spec.msgXtra2Trigger.length+spec.msgXtra3Trigger.length)>0;
            if (bChatMessages)
            {
                if (spec.msgHello.length==0) spec.msgHello.Insert(0,1);
                if (spec.msgBye.length==0) spec.msgBye.Insert(0,1);
                if (spec.msgXtra1.length==0) spec.msgXtra1.Insert(0,1);
                if (spec.msgXtra2.length==0) spec.msgXtra2.Insert(0,1);
                if (spec.msgXtra3.length==0) spec.msgXtra3.Insert(0,1);
                if (spec.msgXtra4.length==0) spec.msgXtra4.Insert(0,1);
                if (spec.msgXtra5.length==0) spec.msgXtra5.Insert(0,1);
            }
        }
        if (bEndMessages)
        {
            bEndMessages=(spec.msgEndGameWon.length+spec.msgEndGameLost.length)>0;
            if (bEndMessages)
            {
                if (spec.msgEndGameWon.length==0) spec.msgEndGameWon.Insert(0,1);
                if (spec.msgEndGameLost.length==0) spec.msgEndGameLost.Insert(0,1);
            }
        }
        if (bScoreMessages)
        {
            bScoreMessages=(spec.msgScoreWe.length+spec.msgScoreThey.length)>0;
            if (bScoreMessages)
            {
                if (spec.msgScoreWe.length==0) spec.msgScoreWe.Insert(0,1);
                if (spec.msgScoreThey.length==0) spec.msgScoreThey.Insert(0,1);
            }
        }
        if (bChitChat)
        {
            bChitChat=(spec.msgChitChat.length)>0;
        }
    }
}

event Timer()
{
    local int i;
    for (i = 0; i < spec.messages.length; i++)
    {
        spec.messages[i].delay = spec.messages[i].delay-DeltaTime;
        if (spec.messages[i].delay <= 0)
        {
            if (spec.messages[i].Speaker != none) Level.Game.Broadcast(spec.messages[i].Speaker, spec.messages[i].message, 'Say');
            spec.messages.remove(i, 1);
        }
    }
    spec.AddSquadAI();
}

defaultproperties
{
    FriendlyName="BullShit"
    GroupName="BullShit"
    Description="Bots will speak on certain activities. Note: servers should install this mod as a ServerActor and NOT as a mutator."

    fKillFrequency=0.33
    bKillMessages=true
    fChatFrequency=0.5
    bChatMessages=true
    fEndFrequency=0.75
    bEndMessages=true
    fScoreFrequency=0.5
    bScoreMessages=true
    bUseDelay=true
    fMinDelay=0.5
    fMaxDelay=2.5
    iGreetDelay=5
    bChitChat=false
    fChitChat=0.2
    iChitChat=60
}
