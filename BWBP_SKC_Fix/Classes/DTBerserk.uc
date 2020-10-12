//=============================================================================
// DTBerserk.
//
// Damagetype for BERSERK FISTS OF PUNCHING. AAAAAAAAAAH.
//
// by Nolan "Dark Carnivour" Richert.
// Copyright(c) 2005 RuneStorm. All Rights Reserved.
//=============================================================================
class DTBerserk extends DT_BWBlunt;

defaultproperties
{
     DeathStrings(0)="%k ripped %o to shreds!"
     DeathStrings(1)="%k pulverized %o in a berserk rage!"
     DeathStrings(2)="%k tore %o limb from limb!"
     DeathStrings(3)="%o's spine was ripped out by berserk %k!"
     WeaponClass=Class'BWBP_SKC_Fix.DoomFists'
     DeathString="%k ripped %o to shreds!"
     FemaleSuicide="%o EXPLODED IN ANGER."
     MaleSuicide="%o EXPLODED IN ANGER."
     bAlwaysGibs=True
     bLocationalHit=False
     bAlwaysSevers=True
     PawnDamageSounds(0)=Sound'BWBP_SKC_Sounds.Berserk.Berserk-Squish'
     GibPerterbation=4.000000
     KDamageImpulse=1000.000000
     VehicleDamageScaling=0.100000
     VehicleMomentumScaling=1.300000
}
