///////////////////////////////////////////////////////////////////////////////
// filename:    BullShitSpectator.uc
// version:     109
// author:      Michiel 'El Muerte' Hendriks <elmuerte@drunksnipers.com>
// perpose:
///////////////////////////////////////////////////////////////////////////////

class TeamBullShit extends SquadAI;

var BullShitSpectator spec;

function init(BullShitSpectator spect)
{
  Team = none;
  spec = spect;
  SquadLeader = spawn(class'BullShitController'); // bogus controller
  size = 0;
}

function NotifyKilled(Controller Killer, Controller Killed, pawn KilledPawn)
{
  if (spec != none) spec.NotifyKilled(Killer, Killed, KilledPawn);
}

function int GetSize()
{
	return 0;
}

function AddBot(Bot B)
{
  if (NextSquad != none)
  {
    AddBot(B);
  }
  return;
}

function SetLeader(Controller C)
{
  return;
}

function float BotSuitability(Bot B)
{
  return 0;
}
