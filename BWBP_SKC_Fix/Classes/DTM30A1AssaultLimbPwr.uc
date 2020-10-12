//=============================================================================
// DTM30A1AssaultLimbPwr.
//
// DamageType for the M30A1 assault rifle sniper mode
//
// by Nolan "Dark Carnivour" Richert.
// Copyright(c) 2003 RuneStorm. All Rights Reserved.
//=============================================================================
class DTM30A1AssaultLimbPwr extends DT_BWBullet;

defaultproperties
{
     DeathStrings(0)="%k's M30A1 gaussed off %o's hand."
     DeathStrings(1)="%o's foot was shattered by %k's M30A1 Gauss Mode."
     DeathStrings(2)="%k blew an arm off of %o with an upgraded M30 Gauss Rifle."
     DeathStrings(3)="%o got a limb gaussed off by %k's M30A1 bullets."
     ShieldDamage=75
     WeaponClass=Class'BWBP_SKC_Fix.M30A2AssaultRifle'
     DeathString="%k's M30A1 gaussed off %o's hand."
     FemaleSuicide="%o nailed herself with the M30."
     MaleSuicide="%o nailed himself with the M30."
     bFastInstantHit=True
     GibPerterbation=0.100000
     KDamageImpulse=3000.000000
}
