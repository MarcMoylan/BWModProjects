//=============================================================================
// AP_STANAGShockwave.
//
// Two 30 round 5.45mm magazines for the MODERN MILITARY RIFLES.
// Comes with F2000 shockwave grenades!
//
// by Nolan "Dark Carnivour" Richert.
// Copyright(c) 2006 RuneStorm. All Rights Reserved.
//=============================================================================
class AP_STANAGShockwave extends BallisticAmmoPickup;

function inventory SpawnCopy( Pawn Other )
{
	local Inventory Copy, Copy2;

	InventoryType = Class'BWBP_SKC_Fix.Ammo_F2000Grenades';
	AmmoAmount = 2;
	Copy = Super.SpawnCopy(Other);
	AmmoAmount = default.AmmoAmount;
	InventoryType = default.InventoryType;

	Copy2 = Super.SpawnCopy(Other);
	Ammo_545mmSTANAG(Copy2).Grenades = Ammo_F2000Grenades(Copy);
	Ammo_F2000Grenades(Copy).Bullets = Ammo_545mmSTANAG(Copy2);
	return Copy2;
}

defaultproperties
{
     AmmoAmount=60
     InventoryType=Class'BWBP_SKC_Fix.Ammo_545mmSTANAG'
     PickupMessage="You got two 30 round 5.45mm STN magazines"
     PickupSound=Sound'BallisticSounds2.Ammo.ClipPickup'
     StaticMesh=StaticMesh'BWBP_SKC_StaticExp.MARS.MARS3AmmoPickup'
     DrawScale=0.600000
     PrePivot=(Z=5.000000)
     CollisionRadius=8.000000
     CollisionHeight=5.200000
}
