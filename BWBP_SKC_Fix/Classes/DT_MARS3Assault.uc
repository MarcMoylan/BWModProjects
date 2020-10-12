//=============================================================================
// DT_MARS3Assault.
//
// DamageType for the MARS-3 assault rifle primary fire
//
// by Nolan "Dark Carnivour" Richert.
// Copyright(c) 2005 RuneStorm. All Rights Reserved.
//=============================================================================
class DT_MARS3Assault extends DT_BWBullet;

defaultproperties
{
     DeathStrings(0)="%k sent a hailstorm of MARS-3 rounds in %o's general direction."
     DeathStrings(1)="%o was shredded by %k's MARS-3 fusilade."
     DeathStrings(2)="%k's MARS-3 flooded %o with a sea of lead."
     DeathStrings(3)="%k's rapid fire MARS-3 quickly shut down %o."
     WeaponClass=Class'BWBP_SKC_Fix.F2000AssaultRifle'
     DeathString="%k sent a hailstorm of MARS-3 rounds in %o's general direction."
     FemaleSuicide="%o tactically missed with the planet Mars."
     MaleSuicide="%o tactically missed with a Mars bar."
     bFastInstantHit=True
     GibPerterbation=0.100000
     KDamageImpulse=3000.000000
     VehicleDamageScaling=0.600000
}
