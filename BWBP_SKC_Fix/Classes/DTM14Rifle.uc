//=============================================================================
// DTM14Rifle.
//
// DamageType for the SRS M2 Battle Rifle
//
// by Nolan "Dark Carnivour" Richert.
// Copyright(c) 2005 RuneStorm. All Rights Reserved.
//=============================================================================
class DTM14Rifle extends DT_BWBullet;

defaultproperties
{
     DeathStrings(0)="%k pounded 7.62s into %o's chest."
     DeathStrings(1)="%o was executed by %k's SRS Mod-2 Battle Rifle."
     DeathStrings(2)="%k's SRS Mod-2 dropped %o where %ve stood."
     WeaponClass=Class'BWBP_SKC_Fix.SRSM2BattleRifle'
     DeathString="%k pounded 7.62s into %o's chest."
     FemaleSuicide="%o committed suicide with her SRS."
     MaleSuicide="%o committed suicide with his SRS."
     bFastInstantHit=True
     GibPerterbation=0.100000
     KDamageImpulse=3000.000000
     VehicleDamageScaling=0.650000
}
