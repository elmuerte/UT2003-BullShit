///////////////////////////////////////////////////////////////////////////////
// filename:    BullShit.uc
// version:     100
// author:      Michiel 'El Muerte' Hendriks <elmuerte@drunksnipers.com>
// perpose:     
///////////////////////////////////////////////////////////////////////////////

class BullShit extends Info;

const VERSION = "100";

function PreBeginPlay()
{
  log("[~] Starting BullShit version: "$VERSION);
  log("[~] Michiel 'El Muerte' Hendriks - elmuerte@drunksnipers.com");
  log("[~] The Drunk Snipers - http://www.drunksnipers.com");
  Spawn(class'BullShitSpectator');
}
