//=============================================================================
// AH104Pickup.
//=============================================================================
class AH104Pickup extends BallisticHandgunPickup
	placeable;

#exec OBJ LOAD FILE=BWBP_SKC_Tex.utx
#exec OBJ LOAD FILE=BallisticHardware2.usx

simulated function UpdatePrecacheMaterials()
{
	Level.AddPrecacheMaterial(Texture'BWBP_SKC_Tex.AH104.AH104-MainMk2');
}
simulated function UpdatePrecacheStaticMeshes()
{
	Level.AddPrecacheStaticMesh(StaticMesh'BallisticHardware2.M806.PistolMuzzleFlash');
	Level.AddPrecacheStaticMesh(StaticMesh'BallisticHardware2.AM67.AM67Clips');
}

defaultproperties
{
     LowPolyStaticMesh=StaticMesh'BallisticHardware2.AM67.PickupLD'
     PickupDrawScale=0.190000
     InventoryType=Class'BWBP_SKC_Fix.AH104Pistol'
     RespawnTime=10.000000
     PickupMessage="You picked up the AH104 Pounder"
     PickupSound=Sound'BallisticSounds2.M806.M806Putaway'
     StaticMesh=StaticMesh'BallisticHardware2.AM67.PickupLD'
     Physics=PHYS_None
     DrawScale=0.400000
     PrePivot=(Y=-26.000000)
     Skins(0)=Texture'BWBP_SKC_Tex.AH104.AH104-MainMk2'
     CollisionHeight=4.000000
}
