//=============================================================================
// AP_Tranq
//
// A box of 20 tranquilizer darts.
//
// by Nolan "Dark Carnivour" Richert.
// Copyright(c) 2005 RuneStorm. All Rights Reserved.
//=============================================================================
class AP_Tranq extends BallisticAmmoPickup;

defaultproperties
{
     AmmoAmount=20
     InventoryType=Class'BWBP_SKC_Fix.Ammo_Tranq'
     PickupMessage="You got 20 tranquilizer darts"
     PickupSound=Sound'BWBP_SKC_SoundsExp.VSK.VSK-Holster'
     StaticMesh=StaticMesh'BallisticHardware2.Ammo.M50Magazine'
     DrawScale=0.400000
     Skins(0)=Texture'BWBP_SKC_Tex.M30A2.M30A2-SB'
     CollisionRadius=8.000000
     CollisionHeight=5.200000
}
