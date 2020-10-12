//=============================================================================
// AP_MRDRClip.
//
// 2 36 round 9mm clips for the MRDR.
//
// by Nolan "Dark Carnivour" Richert.
// Copyright(c) 2005 RuneStorm. All Rights Reserved.
//=============================================================================
class AP_MRDRClip extends BallisticAmmoPickup;

defaultproperties
{
     AmmoAmount=72
     InventoryType=Class'BallisticFix.Ammo_9mm'
     PickupMessage="You got 72 rounds of 9mm"
     PickupSound=Sound'BallisticSounds2.Ammo.ClipPickup'
     StaticMesh=StaticMesh'BWBP_SKC_Static.MRDR.MRDR88AmmoPickup'
     DrawScale=1.300000
     PrePivot=(Z=9.000000)
     CollisionRadius=8.000000
     CollisionHeight=5.200000
}
