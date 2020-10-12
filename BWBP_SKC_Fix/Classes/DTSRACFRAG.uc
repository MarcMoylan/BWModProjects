//=============================================================================
// DTSRACFrag.
//
// DamageType for the autocannon direct hits
//
// by Nolan "Dark Carnivour" Richert.
// Copyright(c) 2005 RuneStorm. All Rights Reserved.
//=============================================================================
class DTSRACFRAG extends DT_BWExplode;

defaultproperties
{
     DeathStrings(0)="%k's SRAC terminated %o with extreme prejudice."
     DeathStrings(1)="%o erroneously stepped in front of %k's SRAC."
     DeathStrings(2)="%k's SRAC blasted an explosive round into %o."
     DeathStrings(3)="%o was pulverized by %k's explosive barrage."
     WeaponClass=Class'BWBP_SKC_Fix.SRACGrenadeLauncher'
     DeathString="%k's SRAC terminated %o with extreme prejudice."
     FemaleSuicide="%o launched a FRAG-12 and ran screaming after it."
     MaleSuicide="%o ran screaming into the path of his own FRAG-12."
     bDelayedDamage=True
     VehicleDamageScaling=0.900000
}
