//=============================================================================
// DT_AK47Assault.
//
// DamageType for the AK-490 assault rifle primary fire
// AP ammo will do extra damage to both the target and the target's armor
// Does 10% extra damage through armor and to armor.
// Does 80% damage to vehicles.
//
// by Nolan "Dark Carnivour" Richert.
// Copyright(c) 2005 RuneStorm. All Rights Reserved.
//=============================================================================
class DT_AK47Assault extends DT_BWBullet;

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
     ArmorDrain=0.100000
     DeathStrings(0)="%o was destroyed by the Russian might of %k."
     DeathStrings(1)="%o lost %vh vodka and life to %k and an AK-490."
     DeathStrings(2)="%k's AK-490 turned %o into a leaky barrel of blood."
     DeathStrings(3)="%o was executed under the order of Czar %k and %kh AK."
     DeathStrings(4)="Comrade %k executed %o with %kh AK-490."
     WeaponClass=Class'BWBP_SKC_Fix.AK47AssaultRifle'
     DeathString="%o was destroyed by the Russian might of %k."
     FemaleSuicide="%o shot herself with an Awesome Kelly-490."
     MaleSuicide="%o shot himself with an Awesome Kelly-490."
     bFastInstantHit=True
     GibPerterbation=0.100000
     KDamageImpulse=3000.000000
     VehicleDamageScaling=0.800000
}
