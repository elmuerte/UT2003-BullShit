///////////////////////////////////////////////////////////////////////////////
// filename:    BullShitSpectator.uc
// version:     101
// author:      Michiel 'El Muerte' Hendriks <elmuerte@drunksnipers.com>
// perpose:     
///////////////////////////////////////////////////////////////////////////////

class BullShitSpectator extends MessagingSpectator config(BullShit);

var BullShit config;

// kill related
var config array<string> msgGotKilled; // say when the bot got killed
var config array<string> msgKilled; // say when the bot killed
var config array<string> msgSuicide; 
var config array<string> msgTeamKill; 
var config array<string> msgMadeTeamKill; 

// message related 
var config array<string> msgHello; 
var config array<string> msgHelloTrigger; 
var config array<string> msgBye; 
var config array<string> msgByeTrigger; 

// game end related
var config array<string> msgEndGameWon; 
var config array<string> msgEndGameLost; 

struct DelayedMessage
{
  var float delay;
  var string message;
  var Controller Speaker;
};
var array<DelayedMessage> Messages;

const DeltaTime = 0.1;

// return true when the bot needs to speak
function bool speak(float frequency)
{
  return (frand()<=frequency);
}

function string formatMessage(coerce string message, PlayerReplicationInfo Killer, PlayerReplicationInfo Killed)
{
  if (Killer != none)
  {
    ReplaceText(message, "%killer%", Killer.PlayerName);
    ReplaceText(message, "%winner%", Killer.PlayerName);
    ReplaceText(message, "%speaker%", Killer.PlayerName);
  }
  if (Killed != none)
  {
    ReplaceText(message, "%victim%", Killed.PlayerName);
    ReplaceText(message, "%player%", Killed.PlayerName);
  }
  return message;
}

function DoSpeak(Controller Speaker, string message)
{
  if (message == "") return;
  if (Speaker != none)
  {
    //log(Speaker.PlayerReplicationInfo.PlayerName$":"@message);
    if (!config.bUseDelay) Level.Game.Broadcast(Speaker, message, 'Say');
    else {
      // delayed message
      Messages.Length = Messages.Length+1;
      Messages[Messages.Length-1].delay = RandRange(config.fMinDelay, config.fMaxDelay);
      Messages[Messages.Length-1].message = message;
      Messages[Messages.Length-1].Speaker = Speaker;
      log("Added delayed message:"@Messages[Messages.Length-1].delay@Messages[Messages.Length-1].message);
    }
  }
}

function bool isTeamKill(PlayerReplicationInfo Killer, PlayerReplicationInfo Killed)
{
  if (Killer.Team == none) return false;
  return (Killer.Team == Killed.Team);
}

function string sayGotKilled(PlayerReplicationInfo Killer, PlayerReplicationInfo Killed)
{
  if (Killed == Killer) // suicide
  {
    return formatMessage(msgSuicide[Rand(msgSuicide.length)], Killer, Killed);
  }
  else if (isTeamKill(Killer, Killed))
  {
    return formatMessage(msgTeamKill[Rand(msgTeamKill.length)], Killer, Killed);
  }
  else {
    return formatMessage(msgGotKilled[Rand(msgGotKilled.length)], Killer, Killed);
  }
}

function string sayKilled(PlayerReplicationInfo Killer, PlayerReplicationInfo Killed)
{
  if (isTeamKill(Killer, Killed))
  {
    return formatMessage(msgMadeTeamKill[Rand(msgMadeTeamKill.length)], Killer, Killed);
  }
  else {
    return formatMessage(msgKilled[Rand(msgKilled.length)], Killer, Killed);
   }
}

function NotifyKilled(Controller Killer, Controller Killed, pawn Other)
{
	super.NotifyKilled(Killer, Killed, Other);
  if (!config.bKillMessages) return;
  if (killer == none) killer = killed;
  if (killer == none || killed == none) return;
  if ((Killer.PlayerReplicationInfo != none) && (Killed.PlayerReplicationInfo != none))
  {
    if (Killer.PlayerReplicationInfo.bBot)
    {
      if (speak(config.fKillFrequency)) DoSpeak(Killer, sayKilled(killer.PlayerReplicationInfo, killed.PlayerReplicationInfo));
    }
    if (Killed.PlayerReplicationInfo.bBot)
    {
      if (speak(config.fKillFrequency)) DoSpeak(Killed, sayGotKilled(killer.PlayerReplicationInfo, killed.PlayerReplicationInfo));
    }
  }
}

/* 
  The following MaskedCompare routines are taken from the wUtils package 
  http://wiki.beyondunreal.com/wiki/El_Muerte_TDS/WUtils
                                                                        */
// Internal function used for MaskedCompare
static private final function bool _match(out string mask, out string target)
{
  local string m;
  if (mask == "") return true; 
  m = Left(mask,1);
  if (m == "*") 
  { 
    mask = Mid(mask, 1);
    return _matchstar(m, mask, target);
  }
  if (Len(target) > 0 && (m == "?" || m == Left(target,1)) ) 
  {
    mask = Mid(mask, 1);
    target = Mid(target, 1);
    return _match(mask, target);
  }
  return false;
}

// Internal function used for MaskedCompare
// this will process a *
static private final function bool _matchstar(string m, out string mask, out string target)
{
  local int i, j;
  local string t;

  if (mask == "") return true;

  for (i = 0; (i < Len(target)) && (m == "?" || m == Mid(target, i, 1)); i++)
  {
    j = i;
    do {
      t = Left(target, j);
      if (_match(mask, t)) return true;
    } until (j-- <= 0)
  }
  return false;
}

// Compare a string with a mask
// Wildcards: * = X chars; ? = 1 char
// Wildcards can appear anywhere in the mask
static final function bool MaskedCompare(coerce string target, string mask, optional bool casesensitive)
{
  if (!casesensitive)
  {
    mask = Caps(mask);
    target = Caps(target);
  }
  if (mask == "*") return true;

  do {
    if ( _match(mask, target)) return true;
    target = Mid(target, 1);
  } until (Len(target) <= 0);
  return false;
}
/*                                                                      */

// TODO: listen on chatter
event ClientMessage( coerce string S, optional Name Type )
{
  // nothing
}

function TeamMessage( PlayerReplicationInfo PRI, coerce string S, name Type)
{
  local int i;
  local Controller C;
  if (!config.bChatMessages) return;
  if (PRI.bBot) return; // don't respond on bots
  for (i = 0; i < msgHelloTrigger.length; i++)
  {
    if (MaskedCompare(S, msgHelloTrigger[i]))
    {
      for ( C=Level.ControllerList; C!=None; C=C.NextController )
      {
        if (C.PlayerReplicationInfo.bBot)
        {
          if (speak(config.fChatFrequency)) DoSpeak(C, formatMessage(msgHello[Rand(msgHello.length)], C.PlayerReplicationInfo, PRI));
        }
      }
    }
  }
  for (i = 0; i < msgByeTrigger.length; i++)
  {
    if (MaskedCompare(S, msgByeTrigger[i]))
    {
      for ( C=Level.ControllerList; C!=None; C=C.NextController )
      {
        if (C.PlayerReplicationInfo.bBot)
        {
          if (speak(config.fChatFrequency)) DoSpeak(C, formatMessage(msgBye[Rand(msgBye.length)], C.PlayerReplicationInfo, PRI));
        }
      }
    }
  }
}

function ClientVoiceMessage(PlayerReplicationInfo Sender, PlayerReplicationInfo Recipient, name messagetype, byte messageID)
{
  // nothing
}

function ReceiveLocalizedMessage( class<LocalMessage> Message, optional int Switch, optional PlayerReplicationInfo RelatedPRI_1, optional PlayerReplicationInfo RelatedPRI_2, optional Object OptionalObject )
{
  // nothing
}

function string sayGameEnd(PlayerReplicationInfo PRI)
{
  if ((PRI.Team == Level.Game.GameReplicationInfo.Winner) && (Level.game.bTeamGame))
  {
    return formatMessage(msgEndGameWon[Rand(msgEndGameWon.length)], PRI, none);
  }
  else if (PRI == Level.Game.GameReplicationInfo.Winner)
  {
    return formatMessage(msgEndGameWon[Rand(msgEndGameWon.length)], PRI, none);
  }
  else {
    return formatMessage(msgEndGameLost[Rand(msgEndGameLost.length)], PRI, none);
  }
}

function ClientGameEnded()
{
	local Controller C;

  if (!config.bEndMessages) return;

  For ( C=Level.ControllerList; C!=None; C=C.NextController )
	{
		if (C.PlayerReplicationInfo.bBot)
    {
      if (speak(config.fEndFrequency)) DoSpeak(C, sayGameEnd(C.PlayerReplicationInfo));
    }
	}
}

function SetTick(bool set)
{
  if (set) setTimer(DeltaTime, true);
}

//event Tick( float DeltaTime )
event Timer()
{
  local int i;
  for (i = 0; i < messages.length; i++)
  {
    messages[i].delay = messages[i].delay-DeltaTime;
    if (messages[i].delay <= 0)
    {
      log("speak"@messages[i].message);
      Level.Game.Broadcast(messages[i].Speaker, messages[i].message, 'Say');
      messages.remove(i, 1);
    }
  }
}