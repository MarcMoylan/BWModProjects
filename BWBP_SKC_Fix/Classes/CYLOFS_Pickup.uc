//=============================================================================
// M50Pickup.
//=============================================================================
class CYLOFS_Pickup extends BallisticCamoPickup
	placeable;

var float	HeatLevel;
var float	HeatTime;

#exec OBJ LOAD FILE=BWBP_SKC_Tex.utx

function InitDroppedPickupFor(Inventory Inv)
{
    Super.InitDroppedPickupFor(None);

    if (CYLOFS_AssaultWeapon(Inv) != None)
    {
    	HeatLevel = CYLOFS_AssaultWeapon(Inv).HeatLevel;
    	HeatTime = level.TimeSeconds;
    }

}

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
     InventoryType=Class'BWBP_SKC_Fix.CYLOFS_AssaultWeapon'
     RespawnTime=20.000000
     PickupMessage="You picked up the CYLO Firestorm IV"
     PickupSound=Sound'BallisticSounds2.M50.M50Putaway'
     StaticMesh=StaticMesh'BWBP_SKC_Static.CYLO.CYLOPickupHi'
     Physics=PHYS_None
     DrawScale=2.350000
     Skins(0)=Shader'BWBP_SKC_Tex.CYLO.CYLO-MainShine'
     CollisionHeight=4.000000
}
