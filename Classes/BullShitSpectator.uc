///////////////////////////////////////////////////////////////////////////////
// filename:    BullShitSpectator.uc
// version:     100
// author:      Michiel 'El Muerte' Hendriks <elmuerte@drunksnipers.com>
// perpose:     
///////////////////////////////////////////////////////////////////////////////

class BullShitSpectator extends MessagingSpectator config(BullShit);

// settings
var globalconfig float frequency;

// kill related
var config array<string> msgGotKilled; // say when the bot got killed
var config array<string> msgKilled; // say when the bot killed
var config array<string> msgSuicide; 
var config array<string> msgTeamKill; 
var config array<string> msgMadeTeamKill; 

// message related 
var config array<string> msgHello; 

// return true when the bot needs to speak
function bool speak()
{
  return true;
}

function string formatMessage(coerce string message, PlayerReplicationInfo Killer, PlayerReplicationInfo Killed)
{
  ReplaceText(message, "%killer%", Killer.PlayerName);
  ReplaceText(message, "%victim%", Killed.PlayerName);
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
  return false;
}

function string sayGotKilled(PlayerReplicationInfo Killer, PlayerReplicationInfo Killed)
{
  if (Killed == Killer) // suicide
  {
    return formatMessage(msgSuicide[Rand(msgSuicide.length-1)], Killer, Killed);
  }
  else if (isTeamKill(Killer, Killed))
  {
    return formatMessage(msgTeamKill[Rand(msgTeamKill.length-1)], Killer, Killed);
  }
  else {
    return formatMessage(msgGotKilled[Rand(msgGotKilled.length-1)], Killer, Killed);
  }
}

function string sayKilled(PlayerReplicationInfo Killer, PlayerReplicationInfo Killed)
{
  if (isTeamKill(Killer, Killed))
  {
    return formatMessage(msgMadeTeamKill[Rand(msgMadeTeamKill.length-1)], Killer, Killed);
  }
  else {
    return formatMessage(msgKilled[Rand(msgKilled.length-1)], Killer, Killed);
   }
}

function NotifyKilled(Controller Killer, Controller Killed, pawn Other)
{
	super.NotifyKilled(Killer, Killed, Other);
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

event ClientMessage( coerce string S, optional Name Type )
{
  // nothing
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

defaultproperties 
{
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

  msgHello(0)="Hello %player%"
  msgHello(1)="Welcome to the server %player%"
}