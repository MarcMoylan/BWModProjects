//=============================================================================
// DT_AK47SlashHead.
//
// Damagetype for the AK47SlashHead
//
// by Nolan "Dark Carnivour" Richert.
// Copyright(c) 2005 RuneStorm. All Rights Reserved.
//=============================================================================
class DT_AK47SlashHead extends DT_BWBlade;

defaultproperties
{
     DeathStrings(0)="%k RAGED LIKE BEAR and put knives in %o's head."
     DeathStrings(1)="%k wonders what kind of sick man sends babies like %o to fight %km.
     DeathStrings(2)="%o got a capitalist's shave from %k's bayonet."
     DeathStrings(3)="%k attempted to shove %kh AK490 into %o's mouth."
     DamageDescription=",Stab,"
     WeaponClass=Class'BWBP_SKC_Fix.AK47AssaultRifle'
     DeathString="%k RAGED LIKE BEAR and put knives in %o's head."
     FemaleSuicide="%o got too personal with her vodka soaked blade."
     MaleSuicide="%o had a horrible shaving accident with his AK490 bayonet."
     bArmorStops=False
     bAlwaysSevers=True
     bSpecial=True
     PawnDamageSounds(0)=Sound'BallisticSounds2.A73.A73StabFlesh'
     KDamageImpulse=2000.000000
}
