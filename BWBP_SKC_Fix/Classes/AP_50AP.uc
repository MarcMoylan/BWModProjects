//=============================================================================
// AP_6Magnum.
//
// 12 .44 magnum rounds.
//
// by Nolan "Dark Carnivour" Richert.
// Copyright(c) 2005 RuneStorm. All Rights Reserved.
//=============================================================================
class AP_50AP extends BallisticAmmoPickup;

defaultproperties
{
     AmmoAmount=14
     InventoryType=Class'BWBP_SKC_Fix.Ammo_50AP'
     PickupMessage="You got 14 .600 HEAP rounds"
     PickupSound=Sound'BallisticSounds2.Ammo.ClipPickup'
     StaticMesh=StaticMesh'BallisticHardware2.D49.D49AmmoBox'
     DrawScale=0.400000
     PrePivot=(Z=75.000000)
     Skins(0)=Texture'BWBP_SKC_Tex.AH104.AH104AmmoSkin'
     CollisionRadius=8.000000
     CollisionHeight=18.000000
}
