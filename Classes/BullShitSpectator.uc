///////////////////////////////////////////////////////////////////////////////
// filename:    BullShitSpectator.uc
// version:     100
// author:      Michiel 'El Muerte' Hendriks <elmuerte@drunksnipers.com>
// perpose:     
///////////////////////////////////////////////////////////////////////////////

class BullShitSpectator extends MessagingSpectator config(BullShit);

// settings
var globalconfig float frequency;
var globalconfig bool bKillMessages;
var globalconfig bool bChatMessages;
var globalconfig bool bEndMessages;

// kill related
var config array<string> msgGotKilled; // say when the bot got killed
var config array<string> msgKilled; // say when the bot killed
var config array<string> msgSuicide; 
var config array<string> msgTeamKill; 
var config array<string> msgMadeTeamKill; 

// message related 
var config array<string> msgHello; 
var config array<string> msgHelloTriggers; 
var config array<string> msgBye; 
var config array<string> msgByeTriggers; 

// game end related
var config array<string> msgEndGameWon; 
var config array<string> msgEndGameLost; 

// return true when the bot needs to speak
function bool speak()
{
  return (frand()<=frequency);
}

function string formatMessage(coerce string message, PlayerReplicationInfo Killer, PlayerReplicationInfo Killed)
{
  if (Killer != none)
  {
    ReplaceText(message, "%killer%", Killer.PlayerName);
    ReplaceText(message, "%winner%", Killer.PlayerName);
  }
  if (Killed != none)
  {
    ReplaceText(message, "%victim%", Killed.PlayerName);
  }
  return message;
}

function DoSpeak(Controller Speaker, string message)
{
  if (message == "") return;
  if (Speaker != none)
  {
    Level.Game.Broadcast(Speaker, message, 'Say');
    log(Speaker.PlayerReplicationInfo.PlayerName$":"@message);
  }
  else log("==> speaker is none");
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
  if (!bKillMessages) return;
  if ((Killer.PlayerReplicationInfo != none) && (Killed.PlayerReplicationInfo != none))
  {
    if (Killer.PlayerReplicationInfo.bBot)
    {
      if (speak()) DoSpeak(Killer, sayKilled(killer.PlayerReplicationInfo, killed.PlayerReplicationInfo));
    }
    if (Killed.PlayerReplicationInfo.bBot)
    {
      if (speak()) DoSpeak(Killed, sayGotKilled(killer.PlayerReplicationInfo, killed.PlayerReplicationInfo));
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
  if (!bChatMessages) return;
}

function TeamMessage( PlayerReplicationInfo PRI, coerce string S, name Type)
{
  // nothing
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

  if (!bEndMessages) return;

  For ( C=Level.ControllerList; C!=None; C=C.NextController )
	{
		if (C.PlayerReplicationInfo.bBot)
    {
      if (speak()) DoSpeak(C, sayGameEnd(C.PlayerReplicationInfo));
    }
	}
}

defaultproperties 
{
  frequency=1.0
  bKillMessages=true
  bChatMessages=true
  bEndMessages=true

  msgGotKilled(0)="Damn it!"
  msgGotKilled(1)="Didn't see you there %killer%"
  msgGotKilled(2)="Nice shot %killer%"
  msgGotKilled(3)="%killer%: next time give me a warning"

  msgKilled(0)="Mwuahahaha"
  msgKilled(1)="You suck %victim%"
  msgKilled(2)="Who's yo dadday now %victim%"

  msgSuicide(0)="AAAAAAAaaaaaaaaarrrggggggh"
  msgSuicide(1)="Oops ;)"

  msgTeamKill(0)="%killer% you asshole"
  msgTeamKill(1)="Hello!, same team dude"

  msgMadeTeamKill(0)="Sorry %victim%, didn't have my glasses on"
  msgMadeTeamKill(1)="Oh shit, sorry %victim%"

  msgHello(0)="Hello %player%"
  msgHello(1)="Welcome to the server %player%"

  msgHelloTriggers(0)="Hi*"
  msgHelloTriggers(1)="Hello*"

  msgBye(0)="See you next time %player%"
  msgBye(1)="L8r dude"

  msgByeTriggers(0)="bye*"
  msgByeTriggers(1)="got to go*"

  msgEndGameWon(0)="GG :)"
  msgEndGameWon(1)="Yeehaaa"

  msgEndGameLost(0)="GG :("
  msgEndGameLost(1)="Damn, better luck next time"
}