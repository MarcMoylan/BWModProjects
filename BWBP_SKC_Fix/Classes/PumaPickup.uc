//=============================================================================
// PumaPickup.
//[1:25:41 AM] Marc Moylan: I HATE POSELIB
//[1:25:43 AM] Captain Xavious: lol
//[1:25:44 AM] Marc Moylan: TOO MUCH MOVEMENT
//[1:25:50 AM] Captain Xavious: noooooooo
//=============================================================================
class PumaPickup extends BallisticCamoPickup
	placeable;

#exec OBJ LOAD FILE=BWBP_SKC_TexExp.utx
#exec OBJ LOAD FILE=BWBP_SKC_StaticExp.usx

simulated function UpdatePrecacheMaterials()
{
	Level.AddPrecacheMaterial(Texture'BWBP_SKC_TexExp.PUMA.PUMA-Main');
	Level.AddPrecacheMaterial(Texture'BWBP_SKC_TexExp.PUMA.PUMA-Mag');
	Level.AddPrecacheMaterial(Texture'BWBP_SKC_TexExp.PUMA.PUMA-Misc');
}
simulated function UpdatePrecacheStaticMeshes()
{
	Level.AddPrecacheStaticMesh(StaticMesh'BWBP_SKC_StaticExp.PUMA.PUMAPickup');
}

defaultproperties
{
     LowPolyStaticMesh=StaticMesh'BWBP_SKC_StaticExp.PUMA.PUMAPickup'
     InventoryType=Class'BWBP_SKC_Fix.PumaRepeater'
     RespawnTime=20.000000
     PickupMessage="You picked up the PUMA-77 Repeater"
     PickupSound=Sound'BWBP_SKC_SoundsExp.PUMA.PUMA-Pickup'
     StaticMesh=StaticMesh'BWBP_SKC_StaticExp.PUMA.PUMAPickup'
     Physics=PHYS_None
     DrawScale=0.220000
     PickupDrawScale=0.200000
     CollisionHeight=4.000000
}
