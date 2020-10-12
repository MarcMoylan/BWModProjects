//=============================================================================
// DT_MRDR88Head.
//
// Damage type for the MRDR SMG Headshots
//
// by Nolan "Dark Carnivour" Richert.
// Copyright(c) 2007 RuneStorm. All Rights Reserved.
//=============================================================================
class DT_MRDR88Head extends DT_BWBullet;

defaultproperties
{
     bHeaddie=True
     DeathStrings(0)="%k nailed %o in the head with an MR-DR88."
     DeathStrings(1)="%o took %k's MR-DR88 bullet in the skull."
     DeathStrings(2)="%k's MR-DR88 put an end to %o's headache."
     DeathStrings(3)="%o fell after %k's MR-DR88 bullet left %vh skull."
     EffectChance=0.500000
     WeaponClass=Class'BWBP_SKC_Fix.MRDRMachinePistol'
     DeathString="%k nailed %o in the head with an MR-DR88."
     FemaleSuicide="%o went out with her MR-DR88."
     MaleSuicide="%o went out with his MR-DR88."
     bFastInstantHit=True
     bAlwaysSevers=False
     bSpecial=True
     VehicleDamageScaling=1.250000
}
