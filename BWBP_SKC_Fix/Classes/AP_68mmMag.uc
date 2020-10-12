//=============================================================================
// AP_68mmMag.
//
// A 25 round 6.8mm magazine.
//
// by Nolan "Dark Carnivour" Richert.
// Copyright(c) 2005 RuneStorm. All Rights Reserved.
//=============================================================================
class AP_68mmMag extends BallisticAmmoPickup;

defaultproperties
{
     AmmoAmount=25
     InventoryType=Class'BWBP_SKC_Fix.Ammo_68mm'
     PickupMessage="You got one 6.8mm HVHE magazine"
     PickupSound=Sound'BallisticSounds2.Ammo.ClipPickup'
     StaticMesh=StaticMesh'BWBP_SKC_StaticExp.LK05.LK05AmmoPickup'
     DrawScale=0.550000
     PrePivot=(Z=5.000000)
     CollisionRadius=8.000000
     CollisionHeight=5.200000
}
