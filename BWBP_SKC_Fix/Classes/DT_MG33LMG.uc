//=============================================================================
// DT_MG33LMG.
//
// DamageType for the MG33 Light Machine Gun
//
// by Nolan "Dark Carnivour" Richert.
// Copyright(c) 2005 RuneStorm. All Rights Reserved.
//=============================================================================
class DT_MG33LMG extends DT_BWBullet;

defaultproperties
{
     DeathStrings(0)="%k let %kh MG33 do the talking to %o."
     DeathStrings(1)="%k's MG33 talked some sense into %o."
     DeathStrings(2)="%o's corpse is on the filleted thanks to %k's LMG."
     DeathStrings(3)="%k disciplined %o with M36 fire."
     DeathStrings(4)="%k's MG33 put %o to sleep with the fishes."
     DeathStrings(5)="%k's MG33 reduced %o to bloody strips."
     WeaponClass=Class'BWBP_SKC_Fix.MG33MachineGun'
     DeathString="%k let %kh MG33 do the talking to %o."
     FemaleSuicide="%o LMG'd her own face off."
     MaleSuicide="%o LMG'd off his own face."
     bFastInstantHit=True
     GibPerterbation=0.100000
     KDamageImpulse=3000.000000
     VehicleDamageScaling=0.650000
}
