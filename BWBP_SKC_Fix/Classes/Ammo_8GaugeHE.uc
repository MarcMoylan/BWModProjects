//=============================================================================
// Ammo_8GuageHE.
//
// 8 Guage HE shotgun ammo. Used by SK410
//
// by Nolan "Dark Carnivour" Richert.
// Copyright(c) 2005 RuneStorm. All Rights Reserved.
//=============================================================================
class Ammo_8GaugeHE extends BallisticAmmo;

defaultproperties
{
     MaxAmmo=48
     InitialAmount=24
     IconFlashMaterial=Shader'BWBP_SKC_Tex.SK410.AmmoIcon_SK410Flash'
     PickupClass=Class'BWBP_SKC_Fix.AP_8Gauge'
     IconMaterial=Texture'BWBP_SKC_Tex.SK410.AmmoIcon_SK410'
     ItemName="8 Gauge HE Shells"
     IconCoords=(X2=64,Y2=64)
}
