//=============================================================================
// DT_AK47AssaultHead.
//
// DamageType for AK490 headshots
//
// by Nolan "Dark Carnivour" Richert.
// Copyright(c) 2005 RuneStorm. All Rights Reserved.
//=============================================================================
class DT_AK47AssaultHead extends DT_BWBullet;

var() float ArmorDrain;

// Call this to do damage to something. This lets the damagetype modify the things if it needs to
static function Hurt (Actor Victim, float Damage, Pawn Instigator, vector HitLocation, vector Momentum, class<DamageType> DT)
{
	local Armor BestArmor;

	Victim.TakeDamage(Damage, Instigator, HitLocation, Momentum, DT);

	if (Instigator.Controller != None && Pawn(Victim).Controller != Instigator.Controller && Instigator.Controller.SameTeamAs(Pawn(Victim).Controller))
		return; //Yeah no melting teammate armor. that's mean

	// Do additional damage to armor..
	if(Pawn(Victim) != None)
	{
		BestArmor = Pawn(Victim).Inventory.PrioritizeArmor(Damage*Default.ArmorDrain,Default.Class,HitLocation);
		if(BestArmor != None)
		{
			Victim.TakeDamage(Damage*Default.ArmorDrain, Instigator, HitLocation, Momentum, DT);
			BestArmor.ArmorAbsorbDamage(Damage*Default.ArmorDrain,Default.Class,HitLocation);
		}
	}
}


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
     ArmorDrain=0.100000
     bHeaddie=True
     DeathStrings(0)="%o's face was rearranged by Comrade %k's AK490."
     DeathStrings(1)="%k executed a rebellious %o with an AK headshot."
     DeathStrings(2)="%k blew the Borscht out of %o's head with an AK490."
     WeaponClass=Class'BWBP_SKC_Fix.AK47AssaultRifle'
     DeathString="%o's face was rearranged by Comrade %k's AK490."
     FemaleSuicide="%o shot heads with bullets."
     MaleSuicide="%o exploded in a shower of laser."
     bFastInstantHit=True
     bAlwaysSevers=True
     bSpecial=True
     PawnDamageSounds(0)=SoundGroup'BallisticSounds2.BulletImpacts.Headshot'
     GibPerterbation=0.200000
     KDamageImpulse=1000.000000
     VehicleDamageScaling=0.650000
}
