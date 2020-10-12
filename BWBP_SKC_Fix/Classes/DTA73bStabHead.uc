//=============================================================================
// DTA73StabHead.
//
// Damagetype for the A73 bayonette attack
//
// by Nolan "Dark Carnivour" Richert.
// Copyright(c) 2005 RuneStorm. All Rights Reserved.
//=============================================================================
class DTA73bStabHead extends DT_BWBlade;

defaultproperties
{
     DeathStrings(0)="%k rammed the blades of %kh Elite A73 into %o's head."
     DeathStrings(1)="%o was jabbed in the jaw by %k's Elite A73."
     DeathStrings(2)="%o tried to chew on %k's Elite A73."
     DamageDescription=",Stab,"
     WeaponClass=Class'BWBP_SKC_Fix.A73BSkrithRifle'
     DeathString="%k rammed the blades of an Elite A73 into %o's head."
     FemaleSuicide="%o sliced her own head in half with the Elite A73."
     MaleSuicide="%o sliced his own head in half with the Elite A73."
     bArmorStops=False
     bAlwaysSevers=True
     bSpecial=True
     PawnDamageSounds(0)=Sound'BallisticSounds2.A73.A73StabFlesh'
     KDamageImpulse=2000.000000
}
