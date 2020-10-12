//=============================================================================
// DT_X82.
//
// DamageType for the .50 cal sniper. Strongest non-railgun sniper ingame.
// Does 30% extra damage through armor and to armor.
// Does 30% extra damage to vehicles.
//
// by Nolan "Dark Carnivour" Richert.
// Copyright(c) 2005 RuneStorm. All Rights Reserved.
//=============================================================================
class DT_X82Torso extends DT_BWBullet;

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
defaultproperties
{
     ArmorDrain=0.300000
     DeathStrings(0)="%k tore up %o with a .50 BMG sniper round."
     DeathStrings(1)="%o lost %vh life to %k's X83A1."
     DeathStrings(2)="%o was shattered by %k's .50 Cal sniper."
     bIgniteFires=True
     WeaponClass=Class'BWBP_SKC_Fix.X82Rifle'
     DeathString="%k ripped up %o with a .50 BMG sniper round."
     FemaleSuicide="%o shot herself in the foot."
     MaleSuicide="%o shot himself in the foot."
//     bArmorStops=False
     bFastInstantHit=True
     GibPerterbation=0.100000
     KDamageImpulse=3000.000000
     VehicleDamageScaling=1.300000
}
