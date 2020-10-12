//=============================================================================
// DTGRSXXLaser.
//
// DT for GRSXX laser non-headshots
//
// by Nolan "Dark Carnivour" Richert.
// Copyright(c) 2007 RuneStorm. All Rights Reserved.
//=============================================================================
class DTGRSXXLaser extends DT_BWMiscDamage;

defaultproperties
{
     DeathStrings(0)="%o submitted to %k's GRSXX laser treatment."
     DeathStrings(1)="%k surgically lasered out parts of %o."
     DeathStrings(2)="%o got some body parts amputated by %k's GRSXX laser."
     DeathStrings(3)="%k cauterized %o with %kh GRSXX laser."
     BloodManagerName="BallisticFix.BloodMan_GRS9Laser"
     bIgniteFires=True
     DamageDescription=",Laser,"
     WeaponClass=Class'BWBP_SKC_Fix.GRSXXPistol'
     DeathString="%o submitted to %k's GRSXX laser treatment."
     FemaleSuicide="%o performed laser surgery on herself."
     MaleSuicide="%o lasered himself in half."
     bInstantHit=True
     GibModifier=4.000000
     GibPerterbation=0.200000
     KDamageImpulse=1000.000000
}
