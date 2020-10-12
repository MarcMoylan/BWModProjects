//=============================================================================
// DTM30A2AssaultHead.
//
// DamageType for M30A2 headshots
//
// by Nolan "Dark Carnivour" Richert.
// Copyright(c) 2005 RuneStorm. All Rights Reserved.
//=============================================================================
class DTM30A2AssaultHead extends DT_BWBullet;

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
     DeathStrings(0)="%o's head was shot away by %k with the M30A2."
     DeathStrings(1)="%o opened wide for %k's M30A2 lead."
     DeathStrings(2)="%k freed %o's gray matter with the M30A2."
     WeaponClass=Class'BWBP_SKC_Fix.M30A2AssaultRifle'
     DeathString="%o's head was shot away by %k with the M30A2."
     FemaleSuicide="%o saw a bullet coming up the barrel of her M30A2."
     MaleSuicide="%o saw a bullet coming up the barrel of his M30A2."
     bFastInstantHit=True
     bAlwaysSevers=True
     bSpecial=True
     PawnDamageSounds(0)=SoundGroup'BallisticSounds2.BulletImpacts.Headshot'
     GibPerterbation=0.200000
     KDamageImpulse=1000.000000
     VehicleDamageScaling=0.650000
}
