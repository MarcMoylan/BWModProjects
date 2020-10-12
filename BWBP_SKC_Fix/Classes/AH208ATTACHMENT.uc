//=============================================================================
// AH208Attachment.
//
// 3rd person weapon attachment for AH208 Pistol
//
// by Nolan "Dark Carnivour" Richert.
// Copyright(c) 2006 RuneStorm. All Rights Reserved.
//=============================================================================
class AH208Attachment extends BallisticCamoAttachment;

var bool bLaserOn;

simulated function InstantFireEffects(byte Mode)
{
	if (FiringMode != 0)
		MeleeFireEffects();
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



//Do your camo changes here
simulated function PostNetBeginPlay()
{
	Super.PostNetBeginPlay();
	

	if (CamoIndex != default.CamoIndex) 
	{
		if (CamoIndex == 6) //Golden
		{
			Skins[1]=CamoWeapon.default.CamoMaterials[4];
			SetBoneScale (0, 0.0, 'Scope');
			SetBoneScale (1, 0.0, 'LAM');
			SetBoneScale (2, 0.0, 'RedDotSight');
			SetBoneScale (3, 0.0, 'Compensator');
		}
		else if (CamoIndex == 5) //Silver Scopeless!
		{
			Skins[1]=CamoWeapon.default.CamoMaterials[3];
			SetBoneScale (2, 0.0, 'RedDotSight');
			SetBoneScale (3, 0.0, 'Compensator');
		}
		else if (CamoIndex == 4) //Black RDS + Comp
		{
			Skins[1]=CamoWeapon.default.CamoMaterials[2];
			Skins[2]=CamoWeapon.default.CamoMaterials[6];
     			Skins[4]=CamoWeapon.default.CamoMaterials[7];
     			Skins[5]=CamoWeapon.default.CamoMaterials[8];
			SetBoneScale (0, 0.0, 'Scope');
		}
		else if (CamoIndex == 3)  //Silver RDS
		{
			Skins[1]=CamoWeapon.default.CamoMaterials[0];
			SetBoneScale (0, 0.0, 'Scope');
		}
		else if (CamoIndex == 2)  //BLAPCK
		{
			Skins[1]=CamoWeapon.default.CamoMaterials[2];
			Skins[2]=CamoWeapon.default.CamoMaterials[6];
			SetBoneScale (0, 0.0, 'Scope');
			SetBoneScale (2, 0.0, 'RedDotSight');
			SetBoneScale (3, 0.0, 'Compensator');
		}
		else if (CamoIndex == 1)  //Toinesd2525255252525252
		{
			Skins[1]=CamoWeapon.default.CamoMaterials[1];
			SetBoneScale (0, 0.0, 'Scope');
			SetBoneScale (2, 0.0, 'RedDotSight');
			SetBoneScale (3, 0.0, 'Compensator');
		}
		else
		{
			Skins[1]=CamoWeapon.default.CamoMaterials[0];
			SetBoneScale (0, 0.0, 'Scope');
			SetBoneScale (2, 0.0, 'RedDotSight');
			SetBoneScale (3, 0.0, 'Compensator');
		}
	}
}



defaultproperties
{
     CamoWeapon=Class'BWBP_SKC_Fix.AH208Pistol'
     MuzzleFlashClass=Class'BallisticFix.D49FlashEmitter'
     ImpactManager=Class'BallisticFix.IM_BigBullet'
     FlashScale=0.250000
     BrassClass=Class'BallisticFix.Brass_Pistol'
     TracerClass=Class'BallisticFix.TraceEmitter_Pistol'
     WaterTracerClass=Class'BallisticFix.TraceEmitter_WaterBullet'
     FlyBySound=(Sound=SoundGroup'BallisticSounds2.FlyBys.Bullet-Whizz',Volume=0.700000)
     Mesh=SkeletalMesh'BWBP_SKC_Anim.TP_Eagle'
     RelativeLocation=(X=3.000000,Y=-1.000000,Z=4.000000)
     RelativeRotation=(Pitch=32768)
     DrawScale=0.540000
}
