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
  Team = TeamGame(Level.Game).Teams[0];
  spec = spect;
  SquadLeader = spawn(class'Controller'); // bogus controller
  size = MaxSquadSize;
}

function NotifyKilled(Controller Killer, Controller Killed, pawn KilledPawn)
{
  if (spec != none) spec.NotifyKilled(Killer, Killed, KilledPawn);
}

function int GetSize()
{
	return MaxSquadSize;
}

function AddBot(Bot B)
{
  if (NextSquad != none) AddBot(B);
  return;
}

function SetLeader(Controller C)
{
  return;
}