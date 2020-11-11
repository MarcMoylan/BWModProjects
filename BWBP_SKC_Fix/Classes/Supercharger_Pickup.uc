//=============================================================================
// M50Pickup.
//=============================================================================
class Supercharger_Pickup extends BallisticWeaponPickup
	placeable;

#exec OBJ LOAD FILE=BWBP_SKC_Tex.utx
#exec OBJ LOAD FILE=BWBP_SKC_Tex.utx
#exec OBJ LOAD FILE=BWBP_SKC_Static.usx

simulated function UpdatePrecacheMaterials()
{
	Level.AddPrecacheMaterial(Texture'BWBP_SKC_Tex.CYLO.CYLO-MainMk2');
	Level.AddPrecacheMaterial(Texture'BWBP_SKC_Tex.CYLO.CYLO-MainMk3');
}
simulated function UpdatePrecacheStaticMeshes()
{
	Level.AddPrecacheStaticMesh(StaticMesh'BWBP_SKC_Static.CYLO.CYLOPickupHi');
	Level.AddPrecacheStaticMesh(StaticMesh'BWBP_SKC_Static.CYLO.CYLOPickupLow');
}

defaultproperties
{
     LowPolyStaticMesh=StaticMesh'BWBP_SKC_Static.CYLO.CYLOPickupLow'
     InventoryType=Class'BWBP_SKC_Fix.Supercharger_AssaultWeapon'
     RespawnTime=20.000000
     PickupMessage="You picked up something"
     PickupSound=Sound'BallisticSounds2.M50.M50Putaway'
     StaticMesh=StaticMesh'BWBP_SKC_Static.CYLO.CYLOPickupHi'
     Physics=PHYS_None
     DrawScale=2.350000
     Skins(0)=Shader'BWBP_SKC_Tex.CYLO.CYLO-MainShine'
     CollisionHeight=4.000000
}
