//=============================================================================
// DTM30A1AssaultLimb.
//
// DamageType for the M30A1 assault rifle primary fire
//
// by Nolan "Dark Carnivour" Richert.
// Copyright(c) 2005 RuneStorm. All Rights Reserved.
//=============================================================================
class DTM30A1AssaultLimb extends DT_BWBullet;

defaultproperties
{
     DeathStrings(0)="%o lost a limb to %k's heavy M30A1 rounds."
     DeathStrings(1)="%o's extremities were blown off by %k's M30A1."
     DeathStrings(2)="%k accurately destroyed %o's kneecaps with an M30A1."
     DeathStrings(3)="%k severed some of %o's fingers with the M30A1."
     WeaponClass=Class'BWBP_SKC_Fix.M30A2AssaultRifle'
     DeathString="%o lost a limb to %k's heavy M30A1 rounds."
     FemaleSuicide="%o nailed herself with the M30."
     MaleSuicide="%o nailed himself with the M30."
     bFastInstantHit=True
     GibPerterbation=0.100000
     KDamageImpulse=3000.000000
     VehicleDamageScaling=0.650000
}
