///////////////////////////////////////////////////////////////////////////////
// filename:    BullShit.uc
// version:     101
// author:      Michiel 'El Muerte' Hendriks <elmuerte@drunksnipers.com>
// perpose:     
///////////////////////////////////////////////////////////////////////////////

class BullShit extends Info config;

const VERSION = "101";

// settings
var config float fKillFrequency;
var config bool bKillMessages;
var config float fChatFrequency;
var config bool bChatMessages;
var config float fEndFrequency;
var config bool bEndMessages;

var BullShitSpectator spec;

function PreBeginPlay()
{
  log("[~] Starting BullShit version: "$VERSION);
  log("[~] Michiel 'El Muerte' Hendriks - elmuerte@drunksnipers.com");
  log("[~] The Drunk Snipers - http://www.drunksnipers.com");
  if (spec == none) 
  {
    spec = Spawn(class'BullShitSpectator');
    spec.config = self;
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
      bChatMessages=(spec.msgHello.length+spec.msgHelloTrigger.length+spec.msgBye.length+spec.msgByeTrigger.length)>0;
      if (bChatMessages)
      {
        if (spec.msgHello.length==0) spec.msgHello.Insert(1,1);
        if (spec.msgHelloTrigger.length==0) spec.msgHelloTrigger.Insert(1,1);
        if (spec.msgBye.length==0) spec.msgBye.Insert(1,1);
        if (spec.msgByeTrigger.length==0) spec.msgByeTrigger.Insert(1,1);
      }
    }
    if (bEndMessages)
    {
      bEndMessages=(spec.msgEndGameWon.length+spec.msgEndGameLost.length)>0;
      if (bEndMessages)
      {
        if (spec.msgEndGameWon.length==0) spec.msgEndGameWon.Insert(1,1);
        if (spec.msgEndGameLost.length==0) spec.msgEndGameLost.Insert(1,1);
      }
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
}