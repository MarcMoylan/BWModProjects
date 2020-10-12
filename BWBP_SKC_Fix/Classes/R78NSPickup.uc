//=============================================================================
// R78NSPickup.
//=============================================================================
class R78NSPickup extends BallisticCamoPickup
	placeable;


#exec OBJ LOAD FILE=BallisticWeapons2.utx
#exec OBJ LOAD FILE=BallisticEffects.utx
#exec OBJ LOAD FILE=BWBP_SKC_Tex.utx
#exec OBJ LOAD FILE=BallisticHardware2.usx


simulated function UpdatePrecacheMaterials()
{
	Level.AddPrecacheMaterial(Texture'BallisticWeapons2.R78.RifleSkin');
	Level.AddPrecacheMaterial(Texture'BallisticWeapons2.R78.ScopeSkin');
}
simulated function UpdatePrecacheStaticMeshes()
{
	Level.AddPrecacheStaticMesh(StaticMesh'BallisticHardware2.Brass.EmptyRifleRound');
	Level.AddPrecacheStaticMesh(StaticMesh'BallisticHardware2.R78.RifleMuzzleFlash');
	Level.AddPrecacheStaticMesh(StaticMesh'BallisticHardware2.Ammo.R78Clip');
	Level.AddPrecacheStaticMesh(StaticMesh'BallisticHardware2.R78.R78PickupHi');
	Level.AddPrecacheStaticMesh(StaticMesh'BallisticHardware2.R78.R78PickupLo');
}

defaultproperties
{
     LowPolyStaticMesh=StaticMesh'BallisticHardware2.R78.R78PickupLo'
     PickupDrawScale=0.500000
     InventoryType=Class'BWBP_SKC_Fix.R78NSRifle'
     RespawnTime=20.000000
     PickupMessage="You picked up the R98 Hunting Rifle"
     PickupSound=Sound'BallisticSounds2.R78.R78Putaway'
     StaticMesh=StaticMesh'BallisticHardware2.R78.R78PickupHi'
     Physics=PHYS_None
     DrawScale=0.470000
     CollisionHeight=3.000000
     Skins(1)=Texture'ONSstructureTextures.CoreGroup.Invisible'
}
