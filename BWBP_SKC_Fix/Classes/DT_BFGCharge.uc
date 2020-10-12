//=============================================================================
// DTA73Skrith.
//
// Damage type for A73 projectiles
//
// by Nolan "Dark Carnivour" Richert.
// Copyright(c) 2005 RuneStorm. All Rights Reserved.
//=============================================================================
class DT_BFGCharge extends DT_BWMiscDamage;

defaultproperties
{
     DeathStrings(0)="%k destroyed %o with a giant green ball of death."
     DeathStrings(1)="%o was annihilated in a big ball of %k's plasma."
     DeathStrings(2)="%o exploded at the sight of %k's E-V HPC."
     DeathStrings(3)="%k's E-V HPC pasted %o all over the walls."
     BloodManagerName="BWBP_SKC_Fix.BloodMan_HVPC"
     bIgniteFires=True
     DamageDescription=",Plasma,"
     WeaponClass=Class'BWBP_SKC_Fix.HVPCMk66PlasmaCannon'
     DeathString="%k destroyed %o with a giant green ball of death."
     FemaleSuicide="%o ANNIHILATED herself."
     MaleSuicide="%o OBLITERATED himself."
     bFlaming=True
     GibModifier=3.000000
     GibPerterbation=0.500000
     KDamageImpulse=1000.000000
     VehicleDamageScaling=0.650000
     VehicleMomentumScaling=1.750000
}
