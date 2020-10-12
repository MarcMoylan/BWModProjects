//=============================================================================
// SK410Attachment.
//
// 3rd person weapon attachment for SK410 Shotgun
//
// by Nolan "Dark Carnivour" Richert.
// Copyright(c) 2005 RuneStorm. All Rights Reserved.
//=============================================================================
class SK410Attachment extends BallisticCamoShotgunAttachment;

var bool		bNoEffect; //silencer bolt will not spawn tracers


replication
{
	// Things the server should send to the client.
	reliable if(Role==ROLE_Authority)
		bNoEffect;
}


//Do your camo changes here
simulated function PostNetBeginPlay()
{
	if (CamoIndex != default.CamoIndex) 
		Skins[2] = CamoWeapon.default.CamoMaterials[CamoIndex];
}


simulated function InstantFireEffects(byte Mode)
{
	if (FiringMode != 0)
		MeleeFireEffects();
	else if (bNoEffect)
		return;
	else
		Super.InstantFireEffects(FiringMode);
}


// Do trace to find impact info and then spawn the effect
simulated function MeleeFireEffects()
{
	local Vector HitLocation, Dir, Start;
	local Material HitMat;

	if (mHitLocation == vect(0,0,0))
		return;

	if (Level.NetMode == NM_Client)
	{
		mHitActor = None;
		Start = Instigator.Location + Instigator.EyePosition();
		Dir = Normal(mHitLocation - Start);
		mHitActor = Trace (HitLocation, mHitNormal, mHitLocation + Dir*10, mHitLocation - Dir*10, false,, HitMat);
		if (mHitActor == None || (!mHitActor.bWorldGeometry))
			return;

		if (HitMat == None)
			mHitSurf = int(mHitActor.SurfaceType);
		else
			mHitSurf = int(HitMat.SurfaceType);
	}
	else
		HitLocation = mHitLocation;
	if (mHitActor == None || (!mHitActor.bWorldGeometry && Mover(mHitActor) == None && Vehicle(mHitActor) == None))
		return;
//	if (ImpactManager != None)
		class'IM_GunHit'.static.StartSpawn(HitLocation, mHitNormal, mHitSurf, instigator);
}

defaultproperties
{
     CamoWeapon=Class'BWBP_SKC_Fix.SK410Shotgun'
     FireClass=Class'BWBP_SKC_Fix.SK410PrimaryFire'
     MuzzleFlashClass=Class'BWBP_SKC_Fix.SK410HeatEmitter'
     ImpactManager=Class'BWBP_SKC_Fix.IM_ShellHE'
     FlashScale=1.800000
     BrassClass=Class'BWBP_SKC_Fix.Brass_ShotgunHE'
     TrackAnimMode=MU_Secondary
     TracerClass=Class'BWBP_SKC_Fix.TraceEmitter_ShotgunHE'
     TracerChance=0.500000
     RelativeRotation=(Pitch=32768)
     PrePivot=(X=1.000000,Z=-5.000000)
     Mesh=SkeletalMesh'BWBP_SKC_Anim.SK410Third'
     DrawScale=0.200000
}
