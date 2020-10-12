//=============================================================================
// GRSXXPickup.
//=============================================================================
class GRSXXPickup extends BallisticHandgunPickup
	placeable;

#exec OBJ LOAD FILE=BWBP_SKC_Tex.utx
#exec OBJ LOAD FILE=BWBP4-Tex.utx
#exec OBJ LOAD FILE=BWBP4-Hardware.usx

static function StaticPrecache(LevelInfo L)
{
	L.AddPrecacheMaterial(Texture'BWBP4-Tex.Brass.Cart_Silver');
	L.AddPrecacheMaterial(Texture'BWBP_SKC_Tex.Glock_Gold.Glock_GoldMain');
	L.AddPrecacheMaterial(Texture'BWBP4-Tex.Glock.Glock_SpecMask');
	L.AddPrecacheMaterial(Texture'BWBP_SKC_Tex.Glock_Gold.GoldLaserBeam');

	L.AddPrecacheStaticMesh(StaticMesh'BWBP4-Hardware.Glock.Glock-LD');
	L.AddPrecacheStaticMesh(StaticMesh'BWBP4-Hardware.Glock.Glock-HD');
	L.AddPrecacheStaticMesh(StaticMesh'BWBP4-Hardware.Glock.Glock-Ammo');
}
simulated function UpdatePrecacheMaterials()
{
	Level.AddPrecacheMaterial(Texture'BWBP4-Tex.Brass.Cart_Silver');
	Level.AddPrecacheMaterial(Texture'BWBP_SKC_Tex.Glock_Gold.Glock_GoldMain');
	Level.AddPrecacheMaterial(Texture'BWBP4-Tex.Glock.Glock_SpecMask');
	Level.AddPrecacheMaterial(Texture'BWBP_SKC_Tex.Glock_Gold.GoldLaserBeam');
}

simulated function UpdatePrecacheStaticMeshes()
{
	Level.AddPrecacheStaticMesh(StaticMesh'BWBP4-Hardware.Glock.Glock-LD');
	Level.AddPrecacheStaticMesh(StaticMesh'BWBP4-Hardware.Glock.Glock-HD');
	Level.AddPrecacheStaticMesh(StaticMesh'BWBP4-Hardware.Glock.Glock-Ammo');
}

defaultproperties
{
     LowPolyStaticMesh=StaticMesh'BWBP4-Hardware.Glock.Glock-LD'
     PickupDrawScale=0.160000
     InventoryType=Class'BWBP_SKC_Fix.GRSXXPistol'
     RespawnTime=90.000000
     PickupMessage="You picked up the GRSXX Golden Pistol"
     PickupSound=Sound'BallisticSounds2.M806.M806Putaway'
     StaticMesh=StaticMesh'BWBP4-Hardware.Glock.Glock-HD'
     Physics=PHYS_None
     DrawScale=0.340000
     PrePivot=(Y=-40.000000)
     Skins(0)=Shader'BWBP_SKC_Tex.Glock_Gold.Glock_GoldShine'
     Skins(1)=Shader'BWBP_SKC_Tex.Glock_Gold.Glock_GoldShine'
     Skins(2)=Shader'BWBP_SKC_Tex.Glock_Gold.Glock_GoldShine'
     CollisionHeight=4.000000
}
