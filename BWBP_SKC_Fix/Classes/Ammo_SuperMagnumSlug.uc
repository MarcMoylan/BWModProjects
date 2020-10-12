//=============================================================================
// Ammo_SuperMagnumSlug.
//
// Massive slug used by double barrel shotgun
//
// by Nolan "Dark Carnivour" Richert.
// Copyright(c) 2005 RuneStorm. All Rights Reserved.
//=============================================================================
class Ammo_SuperMagnumSlug extends BallisticAmmo;

defaultproperties
{
     MaxAmmo=12
     InitialAmount=6
     IconFlashMaterial=Shader'BWBP_SKC_Tex.SK410.AmmoIcon_SK410Flash'
     PickupClass=Class'BWBP_SKC_Fix.AP_SuperMagnumSlug'
     IconMaterial=Texture'BWBP_SKC_Tex.SK410.AmmoIcon_SK410'
     ItemName="Super Magnum Slugs"
     IconCoords=(X2=64,Y2=64)
}
