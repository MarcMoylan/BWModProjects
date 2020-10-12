//=============================================================================
// DTA73StabHead.
//
// Damagetype for the A73 bayonette attack
//
// by Nolan "Dark Carnivour" Richert.
// Copyright(c) 2005 RuneStorm. All Rights Reserved.
//=============================================================================
class DTCYLOMk2StabHead extends DT_BWBlade;

defaultproperties
{
     DeathStrings(0)="%o lost an eye to %k's CYLO blade."
     DeathStrings(1)="%k lobotomized %o with %kh CYLO blade"
     DeathStrings(2)="%k's CYLO amputated %o's head."
     DamageDescription=",Stab,"
     WeaponClass=Class'BWBP_SKC_Fix.CYLOFS_AssaultWeapon'
     DeathString="%o was was mauled by %k's CYLO."
     FemaleSuicide="%o sliced her own head in half with the CYLO."
     MaleSuicide="%o sliced his own head in half with the CYLO."
     bArmorStops=False
     bAlwaysSevers=True
     bSpecial=True
     PawnDamageSounds(0)=Sound'BallisticSounds2.A73.A73StabFlesh'
     KDamageImpulse=2000.000000
}
