//=============================================================================
// DTM30A2Assault.
//
// DamageType for the M30A2 assault rifle primary fire
//
// by Nolan "Dark Carnivour" Richert.
// Copyright(c) 2005 RuneStorm. All Rights Reserved.
//=============================================================================
class DT_AIMS20Body extends DT_BWBullet;

defaultproperties
{
     DeathStrings(0)="%k's AIMS-20 terminated %o with extreme prejudice."
     DeathStrings(1)="%o was tactically deleted by %k's AIMS-20."
     DeathStrings(2)="%k neutralized %o with the AIMS-20 weapon system."
     WeaponClass=Class'BWBP_SKC_Fix.AIMS20AssaultRifle'
     DeathString="%k's AIMS-20 terminated %o with extreme prejudice."
     FemaleSuicide="%o removed herself from the battlefield."
     MaleSuicide="%o removed himself from the battlefield."
     bFastInstantHit=True
     GibPerterbation=0.100000
     KDamageImpulse=3000.000000
     VehicleDamageScaling=0.850000
}
