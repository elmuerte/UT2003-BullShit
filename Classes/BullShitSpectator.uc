///////////////////////////////////////////////////////////////////////////////
// filename:    BullShitSpectator.uc
// version:     112
// author:      Michiel 'El Muerte' Hendriks <elmuerte@drunksnipers.com>
// perpose:
///////////////////////////////////////////////////////////////////////////////

class BullShitSpectator extends MessagingSpectator config(BullShit);

var BullShit config;
var bool bHasSquadAI;

var config string msg_no_weapon;

// kill related
var config array<string> msgGotKilled; // say when the bot got killed
var config int liGotKilled;
var config array<string> msgKilled; // say when the bot killed
var config int liKilled;
var config array<string> msgSuicide;
var config int liSuicide;
var config array<string> msgTeamKill;
var config int liTeamKill;
var config array<string> msgMadeTeamKill;
var config int liMadeTeamKill;

// message related
var int LastHello;
var config array<string> msgHello;
var config int liHello;
var config array<string> msgHelloTrigger;
var int LastBye;
var config array<string> msgBye;
var config int liBye;
var config array<string> msgByeTrigger;

// game end related
var config array<string> msgEndGameWon;
var config int liEndGameWon;
var config array<string> msgEndGameLost;
var config int liEndGameLost;

// score events
var config array<string> msgScoreWe;
var config int liScoreWe;
var config array<string> msgScoreThey;
var config int liScoreThey;

// extra triggers
var config array<string> msgXtra1;
var config int liXtra1;
var config array<string> msgXtra1Trigger;
var config array<string> msgXtra2;
var config int liXtra2;
var config array<string> msgXtra2Trigger;
var config array<string> msgXtra3;
var config int liXtra3;
var config array<string> msgXtra3Trigger;
var config array<string> msgXtra4;
var config int liXtra4;
var config array<string> msgXtra4Trigger;
var config array<string> msgXtra5;
var config int liXtra5;
var config array<string> msgXtra5Trigger;

struct DelayedMessage
{
  var float delay;
  var string message;
  var Controller Speaker;
};
var array<DelayedMessage> Messages;

/** return true when the bot needs to speak */
function bool speak(float frequency)
{
  return (frand()<=frequency);
}

/** get a random line from an array preventing the usage of the last line */
function int getLine(array<string> lines, int lastline)
{
  local int nextline;
  if (lines.length == 1) return 0;
  nextline = Rand(lines.length);
  while (nextline == lastline)
  {
    nextline = Rand(lines.length);
  }
  return nextline;
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
  }
  if (kweapon != "") ReplaceText(message, "%kweapon%", kweapon);
    else ReplaceText(message, "%kweapon%", msg_no_weapon);
  if (Killed != none)
  {
    ReplaceText(message, "%victim%", Killed.PlayerName);
    ReplaceText(message, "%player%", Killed.PlayerName);
    ReplaceText(message, "%scorer%", Killed.PlayerName);
    ReplaceText(message, "%vscore%", string(round(Killed.Score)));
    ReplaceText(message, "%vdeaths%", string(round(Killed.Deaths)));    
  }
  if (vweapon != "") ReplaceText(message, "%vweapon%", vweapon);
    else ReplaceText(message, "%vweapon%", msg_no_weapon);
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
    liSuicide = getLine(msgSuicide, liSuicide);
    return formatMessage(msgSuicide[liSuicide], Killer.PlayerReplicationInfo, Killed.PlayerReplicationInfo, kweapon, vweapon);
  }
  else if (isTeamKill(Killer.PlayerReplicationInfo, Killed.PlayerReplicationInfo))
  {
    liTeamKill = getLine(msgTeamKill, liTeamKill);
    return formatMessage(msgTeamKill[liTeamKill], Killer.PlayerReplicationInfo, Killed.PlayerReplicationInfo, kweapon, vweapon);
  }
  else {
    liGotKilled = getLine(msgGotKilled, liGotKilled);
    return formatMessage(msgGotKilled[liGotKilled], Killer.PlayerReplicationInfo, Killed.PlayerReplicationInfo, kweapon, vweapon);
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
    liMadeTeamKill = getLine(msgMadeTeamKill, liMadeTeamKill);
    return formatMessage(msgMadeTeamKill[liMadeTeamKill], Killer.PlayerReplicationInfo, Killed.PlayerReplicationInfo, kweapon, vweapon);
  }
  else {
    liKilled = getLine(msgKilled, liKilled);
    return formatMessage(msgKilled[liKilled], Killer.PlayerReplicationInfo, Killed.PlayerReplicationInfo, kweapon, vweapon);
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
      if (Level.TimeSeconds - LastHello >= config.iGreetDelay)
      {
        for ( C=Level.ControllerList; C!=None; C=C.NextController )
        {
          if ((C.PlayerReplicationInfo != none) && C.PlayerReplicationInfo.bBot)
          {
            if (speak(config.fChatFrequency)) 
            {
              liHello = getLine(msgHello, liHello);
              DoSpeak(C, formatMessage(msgHello[liHello], C.PlayerReplicationInfo, PRI));
            }
          }
        }
      }
      LastHello = Level.TimeSeconds;
    }
  }
  for (i = 0; i < msgByeTrigger.length; i++)
  {
    if (MaskedCompare(S, msgByeTrigger[i]))
    {
      if (Level.TimeSeconds - LastBye >= config.iGreetDelay)
      {
        for ( C=Level.ControllerList; C!=None; C=C.NextController )
        {
          if ((C.PlayerReplicationInfo != none) && C.PlayerReplicationInfo.bBot)
          {
            if (speak(config.fChatFrequency)) 
            {
              liBye = getLine(msgBye, liBye);
              DoSpeak(C, formatMessage(msgBye[liBye], C.PlayerReplicationInfo, PRI));
            }
          }
        }        
      }
      LastBye = Level.TimeSeconds;
    }
  }
  // xtra 1
  for (i = 0; i < msgXtra1Trigger.length; i++)
  {
    if (MaskedCompare(S, msgXtra1Trigger[i]))
    {
      for ( C=Level.ControllerList; C!=None; C=C.NextController )
      {
        if ((C.PlayerReplicationInfo != none) && C.PlayerReplicationInfo.bBot)
        {
          if (speak(config.fChatFrequency)) 
          {
            liXtra1 = getLine(msgXtra1, liXtra1);
            DoSpeak(C, formatMessage(msgXtra1[Rand(msgXtra1.length)], C.PlayerReplicationInfo, PRI));
          }
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
        if ((C.PlayerReplicationInfo != none) && C.PlayerReplicationInfo.bBot)
        {
          if (speak(config.fChatFrequency)) 
          {
            liXtra2 = getLine(msgXtra2, liXtra2);
            DoSpeak(C, formatMessage(msgXtra2[liXtra2], C.PlayerReplicationInfo, PRI));
          }
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
        if ((C.PlayerReplicationInfo != none) && C.PlayerReplicationInfo.bBot)
        {
          if (speak(config.fChatFrequency)) 
          {
            liXtra3 = getLine(msgXtra3, liXtra3);
            DoSpeak(C, formatMessage(msgXtra3[liXtra3], C.PlayerReplicationInfo, PRI));
          }
        }
      }
    }
  }
  // xtra 4
  for (i = 0; i < msgXtra4Trigger.length; i++)
  {
    if (MaskedCompare(S, msgXtra4Trigger[i]))
    {
      for ( C=Level.ControllerList; C!=None; C=C.NextController )
      {
        if ((C.PlayerReplicationInfo != none) && C.PlayerReplicationInfo.bBot)
        {
          if (speak(config.fChatFrequency)) 
          {
            liXtra4 = getLine(msgXtra4, liXtra4);
            DoSpeak(C, formatMessage(msgXtra4[liXtra4], C.PlayerReplicationInfo, PRI));
          }
        }
      }
    }
  }
  // xtra 5
  for (i = 0; i < msgXtra5Trigger.length; i++)
  {
    if (MaskedCompare(S, msgXtra5Trigger[i]))
    {
      for (C=Level.ControllerList; C!=None; C=C.NextController )
      {
        if ((C.PlayerReplicationInfo != none) && C.PlayerReplicationInfo.bBot)
        {
          if (speak(config.fChatFrequency)) 
          {
            liXtra5 = getLine(msgXtra5, liXtra5);
            DoSpeak(C, formatMessage(msgXtra5[liXtra5], C.PlayerReplicationInfo, PRI));
          }
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
      if ((C.PlayerReplicationInfo != none) && (C.PlayerReplicationInfo.bBot) && 
        (C.PlayerReplicationInfo != RelatedPRI_1) && (C.PlayerReplicationInfo.Team != none))
      {
        if (speak(config.fScoreFrequency))
        {
          if (C.PlayerReplicationInfo.Team.TeamIndex == WinningTeam) // our team
          {
            liScoreWe = getLine(msgScoreWe, liScoreWe);
            DoSpeak(C, formatMessage(msgScoreWe[liScoreWe], C.PlayerReplicationInfo, RelatedPRI_1));
          }
          else {
            liScoreThey = getLine(msgScoreThey, liScoreThey);
            DoSpeak(C, formatMessage(msgScoreThey[liScoreThey], C.PlayerReplicationInfo, RelatedPRI_1));
          }
        }
      }
    }
  }
}

function PlayerReplicationInfo GetLowestScoringTeamPlayer(TeamInfo team)
{
  local Controller P;
  local PlayerReplicationInfo other;
  for ( P=Level.ControllerList; P!=None; P=P.nextController )
	{
    if ( (P.PlayerReplicationInfo != None) && (P.PlayerReplicationInfo.Team == team)
				&& ((other == None) || (P.PlayerReplicationInfo.Score < other.Score)) )
		{
				other = P.PlayerReplicationInfo;
		}
  }
  return other;
}

function PlayerReplicationInfo GetHeightsScoringTeamPlayer(TeamInfo team)
{
  local Controller P;
  local PlayerReplicationInfo other;
  for ( P=Level.ControllerList; P!=None; P=P.nextController )
	{
    if ( (P.PlayerReplicationInfo != None) && (P.PlayerReplicationInfo.Team == team)
				&& ((other == None) || (P.PlayerReplicationInfo.Score > other.Score)) )
		{
				other = P.PlayerReplicationInfo;
		}
  }
  return other;
}

function string sayGameEnd(PlayerReplicationInfo PRI)
{
  if (Level.game.bTeamGame)
  {
    if (PRI.Team == Level.Game.GameReplicationInfo.Winner) // my team won
    {
      liEndGameWon = getLine(msgEndGameWon, liEndGameWon);
      return formatMessage(msgEndGameWon[liEndGameWon], PRI, GetLowestScoringTeamPlayer(Level.Game.OtherTeam(PRI.Team)));
    }
    else {
      liEndGameLost = getLine(msgEndGameLost, liEndGameLost);
      return formatMessage(msgEndGameLost[liEndGameLost], GetHeightsScoringTeamPlayer(Level.Game.OtherTeam(PRI.Team)), PRI);
    }
  }
  else {
    if (PRI == Level.Game.GameReplicationInfo.Winner) // player won
    {
      liEndGameWon = getLine(msgEndGameWon, liEndGameWon);
      return formatMessage(msgEndGameWon[liEndGameWon], PRI, PlayerReplicationInfo(Level.Game.GameReplicationInfo.Winner));
    }
    else {
      liEndGameLost = getLine(msgEndGameLost, liEndGameLost);
      return formatMessage(msgEndGameLost[liEndGameLost], PlayerReplicationInfo(Level.Game.GameReplicationInfo.Winner), PRI);
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

function AddSquadAI()
{
  local TeamBullShit sai;
  if (Level.Game.bTeamGame && (!bHasSquadAI)) 
  {
    if (TeamGame(Level.Game).Teams[0] != none)
    {
      bHasSquadAI = true;
      sai = spawn(class'TeamBullShit');
      sai.init(self);
      sai.NextSquad = TeamGame(Level.Game).Teams[0].AI.Squads;
      TeamGame(Level.Game).Teams[0].AI.Squads = sai;
    }
  }
}

defaultproperties
{
  bHasSquadAI=false
  msg_no_weapon="no weapon"
}
