//=============================================================================
// DT_MD402Flak.
//
// Damagetype for the 61mm SHOTGUN
//
// by Nolan "Dark Carnivour" Richert.
// Copyright(c) 2005 RuneStorm. All Rights Reserved.
//=============================================================================
class DT_MD402Flak extends DT_BWExplode;

defaultproperties
{
     DeathStrings(0)="%k completely and utterly shredded %o!"
     DeathStrings(1)="%k ripped %o to bloody ribbons!"
     DeathStrings(2)="%k's CAWS utterly annihilated %o!"
     DeathStrings(3)="%o was decimated by %k's CAWS!"
     WeaponClass=Class'BWBP_SKC_Fix.FLAKLauncher'
     DeathString="%k completely and utterly shredded %o!"
     FemaleSuicide="%o made a severe tactical error."
     MaleSuicide="%o made a severe tactical error."
//     bAlwaysGibs=True
//     bLocationalHit=False
//     bAlwaysSevers=True
     PawnDamageSounds(0)=Sound'BWBP_SKC_Sounds.Berserk.Berserk-Squish'
     GibPerterbation=4.000000
     KDamageImpulse=1000.000000
     VehicleDamageScaling=0.050000
     VehicleMomentumScaling=1.300000
}
