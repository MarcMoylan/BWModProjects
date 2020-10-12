//=============================================================================
// DTLAW.
//
// NUKES. NUKES EVERYWHERE.
//
// by Nolan "Dark Carnivour" Richert.
// Copyright(c) 2005 RuneStorm. All Rights Reserved.
//=============================================================================
class DTLAW extends DT_BWExplode;

defaultproperties
{
     DeathStrings(0)="%o wandered into %k's flying mini-nuke."
     DeathStrings(1)="%o unwittingly caught %k's firey mini-nuke."
     DeathStrings(2)="%k launched a mini-nuke at %o, who successfully caught it."
     WeaponClass=Class'BWBP_SKC_Fix.LAWLauncher'
     DeathString="%o was disintigrated by %k's mini-nuke."
     FemaleSuicide="%o ran in front of her own mini-nuke."
     MaleSuicide="%o ran in front of his own mini-nuke."
//	bSuperWeapon=True
     bDelayedDamage=True
     VehicleDamageScaling=7.200000
     bAlwaysGibs=True
     bLocationalHit=False
     bAlwaysSevers=True
     GibPerterbation=4.000000
}
