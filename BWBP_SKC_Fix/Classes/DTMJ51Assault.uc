//=============================================================================
// DTMJ51Assault.
//
// DamageType for the MJ51 assault rifle primary fire
//
// by Nolan "Dark Carnivour" Richert.
// Copyright(c) 2005 RuneStorm. All Rights Reserved.
//=============================================================================
class DTMJ51Assault extends DT_BWBullet;

defaultproperties
{
     DeathStrings(0)="%k shot through %o with the MJ51."
     DeathStrings(1)="%o was fatally preforated by %k's MJ51."
     DeathStrings(2)="%k removed %o's spine with MJ51 rounds."
     WeaponClass=Class'BWBP_SKC_Fix.MJ51Carbine'
     DeathString="%k shot through %o with the MJ51."
     FemaleSuicide="%o nailed herself with the MJ51."
     MaleSuicide="%o nailed himself with the MJ51."
     bFastInstantHit=True
     GibPerterbation=0.100000
     KDamageImpulse=3000.000000
     VehicleDamageScaling=0.650000
}
