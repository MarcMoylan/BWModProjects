//=============================================================================
// AP_A73BClip
//
// The charge module from the A73 Skrith Rifle. Gives ammo between 10 amd 25.
//
// by Nolan "Dark Carnivour" Richert.
// Copyright(c) 2005 RuneStorm. All Rights Reserved.
//=============================================================================
class AP_A73BClip extends BallisticAmmoPickup;

// Some of these are good, some not so good
auto state Pickup
{
	function BeginState()
	{
		AmmoAmount = default.AmmoAmount + (-10 + Rand(25));
		Super.BeginState();
	}
}

defaultproperties
{
     AmmoAmount=80
     InventoryType=Class'BallisticFix.Ammo_Cells'
     PickupMessage="You picked up an energy cell"
     PickupSound=Sound'BallisticSounds2.Ammo.A73CellPickup'
     StaticMesh=StaticMesh'BallisticHardware2.Ammo.A73Clip'
     DrawScale=0.300000
     Skins(0)=Texture'BWBP_SKC_Tex.A73b.A73BAmmoSkin'
     Skins(1)=Texture'BWBP_SKC_Tex.A73b.A73BAmmoSkin'
     CollisionRadius=8.000000
     CollisionHeight=4.800000
}
