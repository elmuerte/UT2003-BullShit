///////////////////////////////////////////////////////////////////////////////
// filename:    BullShitSpectator.uc
// version:     108
// author:      Michiel 'El Muerte' Hendriks <elmuerte@drunksnipers.com>
// perpose:
///////////////////////////////////////////////////////////////////////////////

class BullShitSpectator extends MessagingSpectator config(BullShit);

var BullShit config;

var config string msg_no_weapon;

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

// score events
var config array<string> msgScoreWe;
var config array<string> msgScoreThey;

// extra triggers
var config array<string> msgXtra1;
var config array<string> msgXtra1Trigger;
var config array<string> msgXtra2;
var config array<string> msgXtra2Trigger;
var config array<string> msgXtra3;
var config array<string> msgXtra3Trigger;

struct DelayedMessage
{
  var float delay;
  var string message;
  var Controller Speaker;
};
var array<DelayedMessage> Messages;

// return true when the bot needs to speak
function bool speak(float frequency)
{
  return (frand()<=frequency);
}

function string formatMessage(coerce string message, PlayerReplicationInfo Killer, PlayerReplicationInfo Killed,
                              optional string kweapon, optional string vweapon)
{
  if (Killer != none)
  {
    ReplaceText(message, "%killer%", Killer.PlayerName);
    ReplaceText(message, "%winner%", Killer.PlayerName);
    ReplaceText(message, "%speaker%", Killer.PlayerName);
    ReplaceText(message, "%kscore%", string(round(Killer.Score)));
    ReplaceText(message, "%kdeaths%", string(round(Killer.Deaths)));
    if (kweapon != "") ReplaceText(message, "%kweapon%", kweapon);
      else ReplaceText(message, "%kweapon%", msg_no_weapon);
  }
  if (Killed != none)
  {
    ReplaceText(message, "%victim%", Killed.PlayerName);
    ReplaceText(message, "%player%", Killed.PlayerName);
    ReplaceText(message, "%scorer%", Killed.PlayerName);
    ReplaceText(message, "%vscore%", string(round(Killed.Score)));
    ReplaceText(message, "%vdeaths%", string(round(Killed.Deaths)));
    if (vweapon != "") ReplaceText(message, "%vweapon%", vweapon);
      else ReplaceText(message, "%vweapon%", msg_no_weapon);
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
      //log(Messages[Messages.Length-1].delay@Speaker.PlayerReplicationInfo.PlayerName@message);
    }
  }
}

function bool isTeamKill(PlayerReplicationInfo Killer, PlayerReplicationInfo Killed)
{
  if (Killer.Team == none) return false;
  return (Killer.Team == Killed.Team);
}

function string sayGotKilled(Controller Killer, Controller Killed)
{
  local string kweapon, vweapon;
  if (Killer.Pawn != none) 
  {
    if (Killer.Pawn.Weapon != none) kweapon = Killer.Pawn.Weapon.ItemName;
  }
  if (Killed.LastPawnWeapon != none) vweapon = Killed.LastPawnWeapon.default.ItemName;
  if (Killed == Killer) // suicide
  {
    return formatMessage(msgSuicide[Rand(msgSuicide.length)], Killer.PlayerReplicationInfo, Killed.PlayerReplicationInfo, kweapon, vweapon);
  }
  else if (isTeamKill(Killer.PlayerReplicationInfo, Killed.PlayerReplicationInfo))
  {
    return formatMessage(msgTeamKill[Rand(msgTeamKill.length)], Killer.PlayerReplicationInfo, Killed.PlayerReplicationInfo, kweapon, vweapon);
  }
  else {
    return formatMessage(msgGotKilled[Rand(msgGotKilled.length)], Killer.PlayerReplicationInfo, Killed.PlayerReplicationInfo, kweapon, vweapon);
  }
}

function string sayKilled(Controller Killer, Controller Killed)
{
  local string kweapon, vweapon;
  if (Killer.Pawn != none) 
  {
    if (Killer.Pawn.Weapon != none) kweapon = Killer.Pawn.Weapon.ItemName;
  }
  if (Killed.LastPawnWeapon != none) vweapon = Killed.LastPawnWeapon.default.ItemName;
  if (isTeamKill(Killer.PlayerReplicationInfo, Killed.PlayerReplicationInfo))
  {
    return formatMessage(msgMadeTeamKill[Rand(msgMadeTeamKill.length)], Killer.PlayerReplicationInfo, Killed.PlayerReplicationInfo, kweapon, vweapon);
  }
  else {
    return formatMessage(msgKilled[Rand(msgKilled.length)], Killer.PlayerReplicationInfo, Killed.PlayerReplicationInfo, kweapon, vweapon);
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
      if (speak(config.fKillFrequency)) DoSpeak(Killer, sayKilled(killer, killed));
    }
    if (Killed.PlayerReplicationInfo.bBot)
    {
      if (speak(config.fKillFrequency)) DoSpeak(Killed, sayGotKilled(killer, killed));
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
  local string m, mp, cp;
  m = Left(mask, 1);
  while ((target != "") && (m != "*"))
  {
    if ((m != Left(target, 1)) && (m != "?")) return false;
    mask = Mid(Mask, 1);
    target = Mid(target, 1);
		m = Left(mask, 1);
  }

  while (target != "") 
  {
		if (m == "*") 
    {
      mask = Mid(Mask, 1);
			if (mask == "") return true; // only "*" mask -> always true
			mp = mask;
			cp = Mid(target, 1);
      m = Left(mask, 1);
		} 
    else if ((m == Left(target, 1)) || (m == "?")) 
    {
			mask = Mid(Mask, 1);
      target = Mid(target, 1);
  		m = Left(mask, 1);
		} 
    else 
    {
			mask = mp;
      m = Left(mask, 1);
			target = cp;
      cp = Mid(cp, 1);
		}
	}

  while (Left(mask, 1) == "*") 
  {
		mask = Mid(Mask, 1);
	}
	return (mask == "");
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

  return _match(mask, target);
}
/*                                                                      */

event ClientMessage( coerce string S, optional Name Type )
{
  // do nothing
}

function TeamMessage( PlayerReplicationInfo PRI, coerce string S, name Type)
{
  local int i;
  local Controller C;
  if (!config.bChatMessages) return;
  if (PRI == none) return;
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
  // xtra 1
  for (i = 0; i < msgXtra1Trigger.length; i++)
  {
    if (MaskedCompare(S, msgXtra1Trigger[i]))
    {
      for ( C=Level.ControllerList; C!=None; C=C.NextController )
      {
        if (C.PlayerReplicationInfo.bBot)
        {
          if (speak(config.fChatFrequency)) DoSpeak(C, formatMessage(msgXtra1[Rand(msgXtra1.length)], C.PlayerReplicationInfo, PRI));
        }
      }
    }
  }
  // xtra 2
  for (i = 0; i < msgXtra2Trigger.length; i++)
  {
    if (MaskedCompare(S, msgXtra2Trigger[i]))
    {
      for ( C=Level.ControllerList; C!=None; C=C.NextController )
      {
        if (C.PlayerReplicationInfo.bBot)
        {
          if (speak(config.fChatFrequency)) DoSpeak(C, formatMessage(msgXtra2[Rand(msgXtra2.length)], C.PlayerReplicationInfo, PRI));
        }
      }
    }
  }
  // xtra 3
  for (i = 0; i < msgXtra3Trigger.length; i++)
  {
    if (MaskedCompare(S, msgXtra3Trigger[i]))
    {
      for ( C=Level.ControllerList; C!=None; C=C.NextController )
      {
        if (C.PlayerReplicationInfo.bBot)
        {
          if (speak(config.fChatFrequency)) DoSpeak(C, formatMessage(msgXtra3[Rand(msgXtra3.length)], C.PlayerReplicationInfo, PRI));
        }
      }
    }
  }
}

function ClientVoiceMessage(PlayerReplicationInfo Sender, PlayerReplicationInfo Recipient, name messagetype, byte messageID)
{
  // nothing
}

simulated function ReceiveLocalizedMessage( class<LocalMessage> Message, optional int Switch, optional PlayerReplicationInfo RelatedPRI_1, optional PlayerReplicationInfo RelatedPRI_2, optional Object OptionalObject )
{
  local bool bFilteredMessage;
  local int WinningTeam;
  local Controller C;

  if ((!Level.Game.bTeamGame) || (!config.bScoreMessages)) return;
  if (Message == none) return;
  if (RelatedPRI_1 == none) return;
  if (RelatedPRI_1.Team == none) return;

  //log(message@switch);

  bFilteredMessage = false;

  if (class<CTFMessage>(Message) != none) // CTF Messages
  {
    switch (switch)
    {
      case 0: // flag capture
      case 1: // flag return
      case 4: // flag taken
              bFilteredMessage = true;
              WinningTeam = RelatedPRI_1.Team.TeamIndex;
              break;
    }
  }
  else if (class<xBombMessage>(Message) != none)
  {
    switch (switch)
    {
      case 6: // got the ball
              bFilteredMessage = true;
              WinningTeam = RelatedPRI_1.Team.TeamIndex;
              break;
    }
  }

  if (bFilteredMessage)
  {
    for ( C=Level.ControllerList; C!=None; C=C.NextController )
    {
      if ((C.PlayerReplicationInfo.bBot) && (C.PlayerReplicationInfo != RelatedPRI_1) && (C.PlayerReplicationInfo.Team != none))
      {
        if (speak(config.fScoreFrequency))
        {
          if (C.PlayerReplicationInfo.Team.TeamIndex == WinningTeam) // our team
            DoSpeak(C, formatMessage(msgScoreWe[Rand(msgScoreWe.length)], C.PlayerReplicationInfo, RelatedPRI_1));
            else DoSpeak(C, formatMessage(msgScoreThey[Rand(msgScoreThey.length)], C.PlayerReplicationInfo, RelatedPRI_1));
        }
      }
    }
  }
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
    if (PlayerReplicationInfo(Level.Game.GameReplicationInfo.Winner) != none)
    {
      return formatMessage(msgEndGameLost[Rand(msgEndGameLost.length)], PlayerReplicationInfo(Level.Game.GameReplicationInfo.Winner), PRI);
    }
    else {
      return formatMessage(msgEndGameLost[Rand(msgEndGameLost.length)], none, PRI);
    }
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

function InitPlayerReplicationInfo()
{
	Super.InitPlayerReplicationInfo();
	PlayerReplicationInfo.PlayerName="BullShit";
}

defaultproperties
{
  msg_no_weapon="no weapon"
}
