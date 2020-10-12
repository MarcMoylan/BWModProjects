//=============================================================================
// DT_MG33LMGHead.
//
// DamageType for MG33 headshots
//
// by Nolan "Dark Carnivour" Richert.
// Copyright(c) 2005 RuneStorm. All Rights Reserved.
//=============================================================================
class DT_MG33LMGHead extends DT_BWBullet;

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
     DeathStrings(0)="%o chowed down %k's MG33 firey fusilade."
     DeathStrings(1)="%k's MG33 reduced %o's head to a leaky core."
     DeathStrings(2)="%k emptied %o's already vacant head with an MG33."
     WeaponClass=Class'BWBP_SKC_Fix.MG33MachineGun'
     DeathString="%o chowed down %k's MG33 firey fusilade."
     FemaleSuicide="%o HEADSHOT SELF?! WHAT"
     MaleSuicide="%o HEADSHOT SELF?! WHAT"
     bFastInstantHit=True
     bAlwaysSevers=False
     bSpecial=True
     PawnDamageSounds(0)=SoundGroup'BallisticSounds2.BulletImpacts.Headshot'
     GibPerterbation=0.200000
     KDamageImpulse=1000.000000
     VehicleDamageScaling=0.650000
}
