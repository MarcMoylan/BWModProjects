//=============================================================================
// DT_M2020Pwr.
//
// DamageType for the M2020 gauss shot
//
// by Nolan "Dark Carnivour" Richert.
// Copyright(c) 2003 RuneStorm. All Rights Reserved.
//=============================================================================
class DT_M2020Pwr extends DT_BWBullet;

defaultproperties
{
     DeathStrings(0)="%k sent a superaccelerated M2020 gauss round through %o."
     DeathStrings(1)="%o was polarized by %k's heavy gauss rifle."
     DeathStrings(2)="%k hunted down %o with %kh advanced gauss gun."
     DeathStrings(3)="%o experienced the power of %k's magnetic accelerator first hand."
     ShieldDamage=150
     ImpactManager=Class'BWBP_SKC_Fix.IM_ExpBullet'
     WeaponClass=Class'BWBP_SKC_Fix.M2020GaussDMR'
     DeathString="%k sent a superaccelerated M2020 gauss round through %o."
     FemaleSuicide="%o polarized herself."
     MaleSuicide="%o polarized himself."
     bFastInstantHit=True
     GibPerterbation=0.100000
     KDamageImpulse=3000.000000
     VehicleDamageScaling=1.200000
}
