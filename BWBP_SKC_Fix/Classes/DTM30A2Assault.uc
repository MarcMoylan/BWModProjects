//=============================================================================
// DTM30A2Assault.
//
// DamageType for the M30A2 assault rifle primary fire
//
// by Nolan "Dark Carnivour" Richert.
// Copyright(c) 2005 RuneStorm. All Rights Reserved.
//=============================================================================
class DTM30A2Assault extends DT_BWBullet;

defaultproperties
{
     DeathStrings(0)="%k pierced %o with the M30A2."
     DeathStrings(1)="%o was punctured by %k's M30A2."
     DeathStrings(2)="%k ripped through %o with M30A2 7.62mm rounds."
     WeaponClass=Class'BWBP_SKC_Fix.M30A2AssaultRifle'
     DeathString="%k pierced %o with the M30A2."
     FemaleSuicide="%o nailed herself with the M30A2."
     MaleSuicide="%o nailed himself with the M30A2."
     bFastInstantHit=True
     GibPerterbation=0.100000
     KDamageImpulse=3000.000000
     VehicleDamageScaling=0.650000
}
