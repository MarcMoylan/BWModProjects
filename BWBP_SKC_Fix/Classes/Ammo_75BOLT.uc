//=============================================================================
// Ammo_75BOLT.
//
// by Nolan "Dark Carnivour" Richert.
// Copyright(c) 2006 RuneStorm. All Rights Reserved.
//=============================================================================
class Ammo_75BOLT extends BallisticAmmo;

defaultproperties
{
     MaxAmmo=60
     InitialAmount=10
     bTryHeadShot=True
     IconFlashMaterial=Shader'BWBP_SKC_Tex.Bulldog.AmmoIcon_BOLTFlash'
     PickupClass=Class'BWBP_SKC_Fix.AP_75BOLTClip'
     IconMaterial=Texture'BWBP_SKC_Tex.Bulldog.AmmoIcon_BOLT'
     IconCoords=(X2=64,Y2=64)
     ItemName=".75 BOLT slugs"
}
