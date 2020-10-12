//=============================================================================
// DTM30SilAssaultLimb.
//
// DamageType for the M30 assault rifle secondaty fire
//
// by Nolan "Dark Carnivour" Richert.
// Copyright(c) 2005 RuneStorm. All Rights Reserved.
//=============================================================================
class DTM30SilAssaultLimb extends DT_BWBullet;

defaultproperties
{
     DeathStrings(0)="%k's M30 secretly crippled %o's limbs."
     DeathStrings(1)="%o's arm was numbed by %k's stealthy M30."
     DeathStrings(2)="%k targetted %o's legs with a silenced M30."
     DeathStrings(3)="%k jammed some silenced M30 rounds into %o's fingers."
     WeaponClass=Class'BWBP_SKC_Fix.MJ51Carbine'
     DeathString="%k's M30 secretly crippled %o's limbs."
     FemaleSuicide="%o nailed herself with the M30."
     MaleSuicide="%o nailed himself with the M30."
     bFastInstantHit=True
     GibPerterbation=0.100000
     KDamageImpulse=3000.000000
     VehicleDamageScaling=0.650000
}
