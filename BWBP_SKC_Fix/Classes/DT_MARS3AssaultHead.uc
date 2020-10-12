//=============================================================================
// DT_MASR3AssaultHead.
//
// DamageType for MASRS#3 headshots
//
// by Nolan "Dark Carnivour" Richert.
// Copyright(c) 2005 RuneStorm. All Rights Reserved.
//=============================================================================
class DT_MARS3AssaultHead extends DT_BWBullet;

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
     DeathStrings(0)="%k's MARS-3 replaced %o's brain with lead."
     DeathStrings(1)="%k's MARS-3 performed plastic surgery on %o's face."
     DeathStrings(2)="%k ventilated %o's head with a MARS-3."
     WeaponClass=Class'BWBP_SKC_Fix.F2000AssaultRifle'
     DeathString="%o's brain shut down under %k's MARS-2 fire."
     FemaleSuicide="%o has rather horrible accuracy."
     MaleSuicide="%o had a truly unfortunate accident."
     bFastInstantHit=True
     bAlwaysSevers=True
     bSpecial=True
     PawnDamageSounds(0)=SoundGroup'BallisticSounds2.BulletImpacts.Headshot'
     GibPerterbation=0.200000
     KDamageImpulse=1000.000000
     VehicleDamageScaling=0.650000
}
