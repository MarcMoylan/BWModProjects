//=============================================================================
// DT_DTSChest.
//
// Damagetype for the almighty nanosword.
//
// by Nolan "Dark Carnivour" Richert.
// Copyright(c) 2007 RuneStorm. All Rights Reserved.
//=============================================================================
class DT_DTSChest extends DT_BWBlade;

defaultproperties
{
     DeathStrings(0)="%o's torso was cut open by %k and %kh DTS."
     DeathStrings(1)="%k's Dragon's Tooth Sword ripped %o open."
     DeathStrings(2)="%k cut %o open with the Dragon's Tooth Sword."
     DeathStrings(3)="%o was sliced in half by %k's nanosword."
     DeathStrings(4)="%o lost a vital organ to %k's DTS."
     WeaponClass=Class'BWBP_SKC_Fix.DragonsToothSword'
     DeathString="%o's torso was cut open by %k and %kh DTS."
     FemaleSuicide="%o activated her DTS backwards."
     MaleSuicide="%o activated his DTS backwards."
     bArmorStops=False
     bNeverSevers=True
     GibModifier=4.000000
     PawnDamageSounds(0)=Sound'BWBP_SKC_Sounds.DTS.NanoSwordHitFlesh'
     GibPerterbation=0.200000
     KDamageImpulse=1000.000000
     VehicleDamageScaling=0.500000
}
