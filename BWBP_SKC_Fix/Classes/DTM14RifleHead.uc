//=============================================================================
// DTM14RifleHead.
//
// DamageType for SRS M2 headshots
//
// by Nolan "Dark Carnivour" Richert.
// Copyright(c) 2005 RuneStorm. All Rights Reserved.
//=============================================================================
class DTM14RifleHead extends DT_BWBullet;

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
     DeathStrings(0)="%o's neck was cleanly severed by %k's SRS Mod-2."
     DeathStrings(1)="%o learned %ve should look both ways before crosssing %k's SRS M2."
     DeathStrings(2)="%k relocated %o's brain to the wall with an SRS Mod-2."
     WeaponClass=Class'BWBP_SKC_Fix.SRSM2BattleRifle'
     DeathString="%o's neck was cleanly severed by %k's SRS Mod-2."
     FemaleSuicide="%o ate her SRS M2 rifle."
     MaleSuicide="%o ate his SRS M2 rifle."
     bFastInstantHit=True
     bAlwaysSevers=True
     bSpecial=True
     PawnDamageSounds(0)=SoundGroup'BallisticSounds2.BulletImpacts.Headshot'
     GibPerterbation=0.200000
     KDamageImpulse=1000.000000
     VehicleDamageScaling=0.650000
}
