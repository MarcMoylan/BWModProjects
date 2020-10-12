//=============================================================================
// DTGRS1PistolHead.
//
// Damage type for GRS1 Pistol headshots
//
// by Nolan "Dark Carnivour" Richert.
// Copyright(c) 2007 RuneStorm. All Rights Reserved.
//=============================================================================
class DTGRS1PistolHead extends DT_BWBullet;

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
     DeathStrings(0)="%k sprayed T9CN bullets into %o's skull."
     DeathStrings(1)="%k ended %o's rap with a bullet to the head."
     DeathStrings(2)="%o got %vh dome blown off by %k's T9CN."
     DeathStrings(3)="%k ruined %o's grill with %kh T9CN."
     WeaponClass=Class'BWBP_SKC_Fix.T9CNMachinePistol'
     DeathString="%k sprayed T9CN bullets into %o's skull."
     FemaleSuicide="%o shot herself in da FACE."
     MaleSuicide="%o shot himself in da FACE."
     bAlwaysSevers=True
     bSpecial=True
     PawnDamageSounds(0)=SoundGroup'BallisticSounds2.BulletImpacts.Headshot'
}
