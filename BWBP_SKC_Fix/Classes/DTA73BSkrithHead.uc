//=============================================================================
// DTA73BSkrithHead.
//
// Damage type for A73B headshots
//
// by Nolan "Dark Carnivour" Richert.
// Copyright(c) 2006 RuneStorm. All Rights Reserved.
//=============================================================================
class DTA73BSkrithHead extends DT_BWMiscDamage;

defaultproperties
{
     DeathStrings(0)="%k burned through %o's scalp with the A73-E."
     DeathStrings(1)="%o's brain was melted by %k's A73-E."
     DeathStrings(2)="%o intercepted %k's A73-E bolt with %vh head."
     DeathStrings(3)="%k scored a headshot on %o with the A73-E."
     BloodManagerName="BWBP_SKC_Fix.BloodMan_A73B"
     bIgniteFires=True
     DamageDescription=",Flame,Plasma,"
     WeaponClass=Class'BWBP_SKC_Fix.A73BSkrithRifle'
     DeathString="%k burned through %o's scalp with the A73-E."
     FemaleSuicide="%o's A73-E turned on her."
     MaleSuicide="%o's A73-E turned on him."
     bAlwaysSevers=True
     bSpecial=True
     GibPerterbation=0.200000
     KDamageImpulse=1000.000000
}
