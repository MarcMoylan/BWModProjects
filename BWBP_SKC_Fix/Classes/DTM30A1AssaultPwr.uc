//=============================================================================
// DTM30A1AssaultPwr.
//
// DamageType for the M30A1 assault rifle sniper fire
//
// by Nolan "Dark Carnivour" Richert.
// Copyright(c) 2003 RuneStorm. All Rights Reserved.
//=============================================================================
class DTM30A1AssaultPwr extends DT_BWBullet;

defaultproperties
{
     DeathStrings(0)="%k tore through %o with the M30A1 sniper mode."
     DeathStrings(1)="%o was outgunned by %k's superior M30A1 gauss firepower."
     DeathStrings(2)="%k ripped %o a new one with an accelerated M30A1 round."
     ShieldDamage=150
     ImpactManager=Class'BWBP_SKC_Fix.IM_ExpBullet'
     WeaponClass=Class'BWBP_SKC_Fix.M30A2AssaultRifle'
     DeathString="%k tore through %o with the M30A1 sniper mode."
     FemaleSuicide="%o used the M30A1's alt incorrectly."
     MaleSuicide="%o used the M30A1's alt incorrectly."
     bFastInstantHit=True
     GibPerterbation=0.100000
     KDamageImpulse=3000.000000
     VehicleDamageScaling=1.200000
}
