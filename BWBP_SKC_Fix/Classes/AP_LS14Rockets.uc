//=============================================================================
// AP_LS14Rockets
//
// 2 rocket packs for the LS14 Carbine
//
// by Nolan "Dark Carnivour" Richert.
// Copyright(c) 2005 RuneStorm. All Rights Reserved.
//=============================================================================
class AP_LS14Rockets extends BallisticAmmoPickup;

simulated event PreBeginplay()
{
}

defaultproperties
{
     AmmoAmount=6
     InventoryType=Class'BWBP_SKC_Fix.Ammo_LS14Rocket'
     PickupMessage="You picked up 6 rockets for the LS14"
     PickupSound=Sound'BallisticSounds2.Ammo.GrenadePickup'
     StaticMesh=StaticMesh'BWBP_SKC_Static.LaserCarbine.LS14RocketPickup'
     DrawScale=1.200000
     CollisionRadius=8.000000
     CollisionHeight=10.000000
}
