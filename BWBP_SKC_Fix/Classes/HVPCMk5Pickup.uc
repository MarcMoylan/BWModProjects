//=============================================================================
// HVCMk9Pickup.
//=============================================================================
class HVPCMk5Pickup extends BallisticWeaponPickup
	placeable;

#exec OBJ LOAD FILE=BWBP_SKC_Tex.utx
#exec OBJ LOAD FILE=BWBP2-Tex.utx
#exec OBJ LOAD FILE=BWBP2-FX.utx
#exec OBJ LOAD FILE=BWBP2Hardware.usx


var float	HeatLevel;
var float	HeatTime;

function InitDroppedPickupFor(Inventory Inv)
{
    Super.InitDroppedPickupFor(None);

    if (HVPCMk5PlasmaCannon(Inv) != None)
    {
    	HeatLevel = HVPCMk5PlasmaCannon(Inv).HeatLevel;
    	HeatTime = level.TimeSeconds;
    }
}



simulated function UpdatePrecacheMaterials()
{
	Level.AddPrecacheMaterial(Texture'BWBP_SKC_Tex.XavPlasCannon.Xav-SkinMk2');
	Level.AddPrecacheMaterial(Texture'BWBP2-Tex.Lighter.LightGlassSkin');
	Level.AddPrecacheMaterial(Texture'BWBP_SKC_Tex.XavPlasCannon.XavPackSkin');
	Level.AddPrecacheMaterial(Texture'BWBP_SKC_Tex.XavPlasCannon.XavAmmoSkin');
	Level.AddPrecacheMaterial(Texture'BWBP2-FX.Particles.SparkA1');
	Level.AddPrecacheMaterial(Texture'BWBP2-FX.Particles.FlareC2');
	Level.AddPrecacheMaterial(Texture'BWBP2-FX.Particles.LightningBolt2');
	Level.AddPrecacheMaterial(Texture'BWBP2-FX.Particles.LightningBoltCut2');
}
simulated function UpdatePrecacheStaticMeshes()
{
	Level.AddPrecacheStaticMesh(StaticMesh'BWBP2Hardware.LightningGun.LighterAmmo');
	Level.AddPrecacheStaticMesh(StaticMesh'BWBP2Hardware.LightningGun.LighterPack');
	Level.AddPrecacheStaticMesh(StaticMesh'BWBP2Hardware.LightningGun.LighterPickupHD');
	Level.AddPrecacheStaticMesh(StaticMesh'BWBP2Hardware.LightningGun.LighterPickupLD');
}

defaultproperties
{
     bOnSide=False
     LowPolyStaticMesh=StaticMesh'BWBP2Hardware.LightningGun.LighterPickupLD'
     PickupDrawScale=0.250000
     InventoryType=Class'BWBP_SKC_Fix.HVPCMk5PlasmaCannon'
     RespawnTime=20.000000
     PickupMessage="You got the High-Voltage Plasma Cannon Mk5"
     PickupSound=Sound'BWBP2-Sounds.LightningGun.LG-Putaway'
     StaticMesh=StaticMesh'BWBP2Hardware.LightningGun.LighterPickupHD'
     Physics=PHYS_None
     DrawScale=0.400000
     PrePivot=(Z=-3.000000)
     Skins(0)=Texture'BWBP_SKC_Tex.XavPlasCannon.Xav-SkinMk2'
     Skins(1)=FinalBlend'BWBP2-Tex.Lighter.LightGlassFinal'
     Skins(2)=Texture'BWBP_SKC_Tex.XavPlasCannon.XavPackSkin'
     CollisionHeight=4.500000
}
