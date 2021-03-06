//=============================================================================
// DTCYLOMk2Hot
//
// Damage type for overheated CYLO Firestorm shots
//
// by Nolan "Dark Carnivour" Richert.
// Copyright(c) 2007 RuneStorm. All Rights Reserved.
//=============================================================================
class DTCYLOMk2Hot extends DT_BWMiscDamage;

defaultproperties
{
     DeathStrings(0)="%o's chest was flared by %k's burning hot Firestorm."
     DeathStrings(1)="%k charred %o with %kh overheating Firestorm."
     DeathStrings(2)="%k's scalding Firestorm turned %o into roast meat."
     EffectChance=1.000000
     BloodManagerName="BallisticFix.BloodMan_GRS9Laser"
     bIgniteFires=True
     MinMotionBlurDamage=5.000000
     MotionBlurDamageRange=20.000000
     MotionBlurFactor=3.000000
     bUseMotionBlur=True
     DamageDescription=",Bullet,Flame,Hazard,"
     WeaponClass=Class'BWBP_SKC_Fix.CYLOFS_AssaultWeapon'
     DeathString="%o's chest was flared by %k's burning hot Firestorm."
     FemaleSuicide="%o melted herself with a CYLO."
     MaleSuicide="%o melted himself with a CYLO?"
     bFastInstantHit=True
     GibModifier=1.500000
     GibPerterbation=0.200000
     KDamageImpulse=3000.000000
     VehicleDamageScaling=1.100000
}
