//=============================================================================
// DTGRSXXPistolHead.
//
// Damage type for GRSXX Pistol headshots
//
// by Nolan "Dark Carnivour" Richert.
// Copyright(c) 2007 RuneStorm. All Rights Reserved.
//=============================================================================
class DTGRSXXPistolHead extends DT_BWBullet;

// HeadShot stuff from old sniper damage ------------------
static function IncrementKills(Controller Killer)
{
	local xPlayerReplicationInfo xPRI;

	if ( PlayerController(Killer) == None )
		return;

	PlayerController(Killer).ReceiveLocalizedMessage( Class'XGame.SpecialKillMessage', 0, Killer.PlayerReplicationInfo, None, None );
	xPRI = xPlayerReplicationInfo(Killer.PlayerReplicationInfo);
	if ( xPRI != None )
	{
		xPRI.headcount++;
		if ( (xPRI.headcount == 15) && (UnrealPlayer(Killer) != None) )
			UnrealPlayer(Killer).ClientDelayedAnnouncementNamed('HeadHunter',15);
	}
}
// --------------------------------------------------------

defaultproperties
{
     bHeaddie=True
     DeathStrings(0)="%o's brain was replaced by %k's GRSXX bullet."
     DeathStrings(1)="%k's GRSXX demonstrated magnetic acceleration on %o's head."
     DeathStrings(2)="%o looked at the platinum in %k's GRSXX barrel."
     DeathStrings(3)="%k gave %o's head some nice new GRSXX bullets."
     WeaponClass=Class'BWBP_SKC_Fix.GRSXXPistol'
     DeathString="%o's brain was replaced by %k's GRSXX bullet."
     FemaleSuicide="%o blew her brains out in style."
     MaleSuicide="%o blew his brains out in style."
     bAlwaysSevers=True
     bSpecial=True
     PawnDamageSounds(0)=SoundGroup'BallisticSounds2.BulletImpacts.Headshot'
}
