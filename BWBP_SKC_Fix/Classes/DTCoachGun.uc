//=============================================================================
// DTCOACHGUN.
//
// Coach has a gun! :(
//
// by Nolan "Dark Carnivour" Richert.
// Copyright(c) 2005 RuneStorm. All Rights Reserved.
//=============================================================================
class DTCoachGun extends DT_BWShell;

defaultproperties
{
     DeathStrings(0)="%k hunted down a cowering %o with %kh coach gun."
     DeathStrings(1)="%k's break-open shotgun tore %o to shreds."
     DeathStrings(2)="%o was blasted away by %k's coach gun."
     WeaponClass=Class'BWBP_SKC_Fix.CoachGun'
     DeathString="%k hunted down a cowering %o with %kh coach gun."
     FemaleSuicide="%o doesn't know how to aim."
     MaleSuicide="%o can't aim very well."
     GibModifier=1.500000
     GibPerterbation=0.400000
     KDamageImpulse=15000.000000
     VehicleDamageScaling=0.300000
}
