//=============================================================================
// DTM30SilAssault.
//
// DamageType for the M30 assault rifle secondary fire
//
// by Nolan "Dark Carnivour" Richert.
// Copyright(c) 2005 RuneStorm. All Rights Reserved.
//=============================================================================
class DTM30SilAssault extends DT_BWBullet;

defaultproperties
{
     DeathStrings(0)="%k quietly eliminated %o with the M30."
     DeathStrings(1)="%o was silenced with %k's M30 rounds."
     DeathStrings(2)="%k assasinated %o with a suppressed M30."
     WeaponClass=Class'BWBP_SKC_Fix.MJ51Carbine'
     DeathString="%k quietly eliminated %o with the M30."
     FemaleSuicide="%o nailed herself with the M30."
     MaleSuicide="%o nailed himself with the M30."
     bFastInstantHit=True
     GibPerterbation=0.100000
     KDamageImpulse=3000.000000
     VehicleDamageScaling=0.650000
}
