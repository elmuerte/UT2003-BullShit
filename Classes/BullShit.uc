///////////////////////////////////////////////////////////////////////////////
// filename:    BullShit.uc
// version:     110
// author:      Michiel 'El Muerte' Hendriks <elmuerte@drunksnipers.com>
// perpose:     
///////////////////////////////////////////////////////////////////////////////

class BullShit extends Info config;

const VERSION = "110";

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
}

defaultproperties
{
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
}