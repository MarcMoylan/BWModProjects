//=============================================================================
// DT_A73BPower.
//
// Damage for DarkStar Fire Ball
//
// by Nolan "Dark Carnivour" Richert.
// Copyright(c) 2007 RuneStorm. All Rights Reserved.
//=============================================================================
class DT_A73BPower extends DT_BWMiscDamage;

defaultproperties
{
     DeathStrings(0)="%o caught %k's plasma ball."
     DeathStrings(1)="%o was bombarded by %k's Elite A73."
     DeathStrings(2)="%k launched a plasma bomb at %o's torso with %kh A73 Elite."
     DeathStrings(3)="%o was blown away by %k's plasma bomb."
     DeathStrings(4)="%k's plasma ball burned through %o."
     BloodManagerName="BWBP_SKC_Fix.BloodMan_A73B"
     bIgniteFires=True
     DamageDescription=",Flame,Hazard,NonSniper,Plasma,"
     WeaponClass=Class'BWBP_SKC_Fix.A73BSkrithRifle'
     DeathString="%k's plasma ball burned through %o."
     FemaleSuicide="%o attempted to shoot her feet."
     MaleSuicide="%o attempted to shoot his feet."
     bDelayedDamage=True
     bFlaming=True
     GibModifier=2.000000
     GibPerterbation=0.200000
     KDamageImpulse=2000.000000
     VehicleDamageScaling=1.500000
}
