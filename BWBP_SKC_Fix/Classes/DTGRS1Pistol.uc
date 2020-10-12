//=============================================================================
// DTGRS1Pistol.
//
// Damage type for the GRS1 Machine Pistol
//
// by Nolan "Dark Carnivour" Richert.
// Copyright(c) 2007 RuneStorm. All Rights Reserved.
//=============================================================================
class DTGRS1Pistol extends DT_BWBullet;

defaultproperties
{
     DeathStrings(0)="%k shot %o up in the hood."
     DeathStrings(1)="%o dissed %k, so %ve was laid out by the T9CN."
     DeathStrings(2)="%o was murdered by %k the gangster."
     DeathStrings(3)="%k executed %o for jacking %kh bling."
     WeaponClass=Class'BWBP_SKC_Fix.T9CNMachinePistol'
     DeathString="%k shot %o up in the hood."
     FemaleSuicide="%o tilted her gun a bit too far..."
     MaleSuicide="%o tilted his gun a bit too far..."
     VehicleDamageScaling=0.750000
}
