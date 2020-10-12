//=============================================================================
// ICISPrimaryFire.
//
// Self injection with the stimulant pack
//
// by Nolan "Dark Carnivour" Richert.
// Copyright(c) 2006 RuneStorm. All Rights Reserved.
//=============================================================================
class ICISPrimaryFire extends BallisticFire;

defaultproperties
{
     bAISilent=True
     bWaitForRelease=True
     bReleaseFireOnDie=True
     bFireOnRelease=True
     FireRate=1.700000
     AmmoPerFire=0
     BallisticFireSound=(Sound=SoundGroup'BallisticSounds_25.X4.X4_Melee',Radius=4.000000,bAtten=True)
     PreFireAnim="PrepSelfMedicate"
     FireAnim="SelfMedicate"
     AmmoClass=Class'BWBP_SKC_Fix.Ammo_ICISStim'
     ShakeRotMag=(X=32.000000,Y=8.000000)
     ShakeRotRate=(X=10000.000000,Y=10000.000000,Z=10000.000000)
     ShakeRotTime=1.500000
     ShakeOffsetMag=(X=-3.000000)
     ShakeOffsetRate=(X=-1000.000000)
     ShakeOffsetTime=1.500000
}
