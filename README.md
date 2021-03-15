# UT2003-BullShit

BullShit is a server actor that will add some more life to the bots in a bot game. BullShit will let the bots speak on certain game events, and respond on chat messages. Bot will no longer stay silent when you frag their ass.

### New in version 101:
- it now actualy works

### New in version 102
- fixed a few accessed none's
- added delayed messages

### New in version 103
- fixed the stray messages when a bot left
- added score events for CTF and Bombing Run (take/capture flag/bomb)

### New in version 104
- fixed the massive accessed none warning

### New in version 105
- added 3 extra chat triggers: msgXtra1 msgXtra1Trigger, msgXtra2 msgXtra2Trigger, msgXtra3 msgXtra3Trigger
- added a couple of new replacements:
   - %kweapon% the weapon of the killer
   - %kdeaths% number of times the killer died
   - %kscore% the score of the killer
   - %vweapon% the weapon of the victim
   - %vdeaths% number of times the victim died
   - %vscore% the score of the victim

### New in version 106
- fixed the end game messages, they should work now
- fixed the wildcards in the triggers

### New in version 107
- realy fixed the wildcards now

### New in version 108
- Added carriage returns to README.TXT
- Fixed Accessed None's in ReceiveLocalizedMessage
- Fixed incorrect winner when player lost
- Fixed victim's weapon

### New in version 110
- Fixed the end game messages

### New in version 111
- fixed possible unreplaced %vweapon% and %kweapon% strings
- fixed TeamGame support

### New in version 112
- new config option iGreetDelay (BullShit.BullShit), this controlls the minimum the time between greets in seconds
- added a check to prevent duplicate lines to be used right after each other
- added extra checks to reduce "accessed none"s
- added two extra triggers: msgXtra4 and msgXtra5

### New in version 113
- TeamGame support fix

### New in version 114
- Added random chit chat. in BullShit.ini:

```
msgChitChat=Did you see that game last night ?
...
in your server config:
bChitChat=true ; turn on/off chit chat usage
fChitChat=0.2 ; chit chat frequency
iChitchat=60 ; number of seconds between possible chit chats
```

- added a new replacement: %rplayer% it will be replaced with a random playername


# Installation
Copy the BullShit.u and BullShit.ini file to the UT2003 System directory. Open up your server configuration (UT2003.ini) and add the following line:

```
  [Engine.GameEngine]
  ServerActors=BullShit.BullShit
```

Now when you start your server you should see the following lines in the log:

```
  [~] Starting BullShit version: 104
  [~] Michiel 'El Muerte' Hendriks
  [~] The Drunk Snipers - http://www.drunksnipers.com
```

You might want to edit the configuration

# Configuration
The configuration of the behavior of BullShit resides in the server configuration file (UT2003.ini). Add the following lines to the file:

```
  [BullShit.BullShit]
  ; Enable/disable speak types
  bKillMessages=True
  bChatMessages=True
  bEndMessages=True
  bScoreMessages=True

  ; This will decide the chance a bot will speak
  ; 1 = always, 0 = never
  fKillFrequency=0.330000
  fChatFrequency=0.500000
  fEndFrequency=0.750000
  fScoreFrequency=0.500000

  ; Delayed message settings
  bUseDelay=true
  fMinDelay=0.5
  fMaxDelay=2.5
```

When bKillMessages is true a bot might speak when it kills or get's killed, bChatMessages controls the bot to respond on certain chat messages, like welcome messages or goodbye messages from other players. With bEndMessages you can enabled/disable the bot to say something at the end of a game. The bScoreMessages messages are played when a team mate take the flag/bom or captures the flag (bombing scores can't be captures)

The fequency settings control the chance a bot will speak. When the value is 1 the bot will always speak, when it's 0 the bot will hardly speak at all, usualy never.

bUseDelay controls if the wait a little while before it will speak. fMinDelay and fMaxDelay control the minimum and maximum delay (in seconds).

To change the lines the bot will say, open up the BullShit.ini file. You can add a vertualy unlimited number of lines. Messages are split up in the following groups:

Kill Messages:

   - msgGotKilled : when a bot gets killed
   - msgKilled : when a bot kills
   - msgSuicide : when a bot commits suicide
   - msgTeamKill : when a bot get's killed by a team member
   - msgMadeTeamKill : when a bot kills a team member 

End Messages:

   - msgEndGameWon : when the bot won the game (or his team)
   - msgEndGameLost : when the bot lost the game (or his team) 

Chat messages:

   - msgHello : when responding on a hello message
   - msgBye : when responding on a goodbye message 

Score Messages:

   - msgScoreWe : our team scores
   - msgScoreThey : other team scored 

Chat messages need extra configuration, you need to define the triggers on which the bot will respon:

   - msgHelloTrigger : this will trigger a hello message
   - msgByeTrigger : this will trigger a goodbye message 

You can use wildcards in the triggers, use a * to match zero or more character and use a ? to match a single character. For example, a trigger "hi*" will match the following lines:

 - Hi
 - Hi everybody
 - hide for the rocket

So take care on how you use the wildcards

In all messages you can use replaceements to make them more lifelike You can use the following replacements:

| pattern | description |
|---|--|
|%killer%  |the player that killed|
|%victim%  |the player that got killed|
|%winner%  |the winner of the game|
|%speaker% |the bot that speaks|
|%player%  |the player who said something|
|%scorer%  |the player that took the flag/bomb|
|%kweapon% |the weapon of the killer|
|%kdeaths% |number of times the killer died|
|%kscore%  |the score of the killer|
|%vweapon% |the weapon of the victim|
|%vdeaths% |number of times the victim died|
|%vscore%  |the score of the victim|

