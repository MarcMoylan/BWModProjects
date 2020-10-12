//=============================================================================
// AP_CX61Mag.
//
// Two CX61 magaZEEEENS
//
// by George "Sergeant_Kelly" Lopez.
// Copyright(c) 2225 RuneStorm. All Rights Reserved.
//=============================================================================
class AP_CX61Mag extends BallisticAmmoPickup;

defaultproperties
{
     AmmoAmount=32
     InventoryType=Class'BWBP_SKC_Fix.Ammo_CX61Flechette'
     PickupMessage="You got two 10mm DU Flechette magazines"
     PickupSound=Sound'BallisticSounds2.Ammo.ClipPickup'
     StaticMesh=StaticMesh'BallisticHardware2.Ammo.M50Magazine'
     DrawScale=0.400000
     CollisionRadius=8.000000
     CollisionHeight=5.200000
}
