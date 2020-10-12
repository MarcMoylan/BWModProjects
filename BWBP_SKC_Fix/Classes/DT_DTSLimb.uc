//=============================================================================
// DT_DTSLimb
//
// Damagetype for DTS limb slices.
//
// by Nolan "Dark Carnivour" Richert.
// Copyright(c) 2005 RuneStorm. All Rights Reserved.
//=============================================================================
class DT_DTSLimb extends DT_BWBlade;

defaultproperties
{
     DeathStrings(0)="%k chopped %o down with the Dragon's Tooth."
     DeathStrings(1)="%o was eviscerated by %k's nanosword."
     DeathStrings(2)="%k sliced a chunk off %o with %kh nanosword."
     DeathStrings(3)="%o's limbs were amputated by %k's swinging DTS."
     WeaponClass=Class'BWBP_SKC_Fix.DragonsToothSword'
     DeathString="%k chopped %o down with the Dragon's Tooth."
     FemaleSuicide="%o's Dragon Tooth bit off her arm."
     MaleSuicide="%o's Dragon Tooth bit off his arm."
     bArmorStops=False
     PawnDamageSounds(0)=Sound'BWBP_SKC_Sounds.DTS.NanoSwordHitFlesh'
     KDamageImpulse=1000.000000
}
