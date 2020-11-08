//=============================================================================
// AP_75BOLTClip.
//
// 15 BOLT slugs, well.. 12 after the mag size got reduced
//
// by Nolan "Dark Carnivour" Richert.
// Copyright(c) 2005 RuneStorm. All Rights Reserved.
//=============================================================================
class AP_75BOLTClip extends BallisticAmmoPickup;

var   Pickup			M900Ammo;
var() class<Pickup>		M900AmmoClass;

event PostBeginPlay()
{
	local Vector S, V, HitLoc, HitNorm, E;
	local Actor T;
	local Rotator R;

	Super.PostBeginPlay();

	V = VRand()*64;
	V.Z = 0;
	S = Location;
	S.Z += M900AmmoClass.default.CollisionHeight - CollisionHeight;
	E.X = M900AmmoClass.default.CollisionRadius;
	E.Y = M900AmmoClass.default.CollisionRadius;
	E.Z = M900AmmoClass.default.CollisionHeight;

	T = Trace(HitLoc, HitNorm, S+V, S, false, E);
	if (T == None)
		HitLoc = S+V;

	R.Yaw = Rand(65536);
	M900Ammo = Spawn(M900AmmoClass,,,HitLoc, R);
}

simulated function Destroyed()
{
	if (M900Ammo != None)
		M900Ammo.Destroy();
	 super.Destroyed();
}

defaultproperties
{
     M900AmmoClass=Class'BWBP_SKC_Fix.AP_FRAG12Box'
     AmmoAmount=12
     InventoryType=Class'BWBP_SKC_Fix.Ammo_75BOLT'
     PickupMessage="You got 12 .75 BOLTs"
     PickupSound=Sound'BallisticSounds2.Ammo.ClipPickup'
     StaticMesh=StaticMesh'BWBP_SKC_Static.Bulldog.BulldogAmmo'
     DrawScale=0.700000
     PrePivot=(Z=5.000000)
//     PrePivot=(Z=75.000000)
     CollisionRadius=8.000000
     CollisionHeight=18.000000
}
