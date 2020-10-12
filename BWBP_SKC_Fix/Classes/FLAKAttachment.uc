//=============================================================================
// SMATAttachment.
//
// 3rd person weapon attachment for SMAT Bazooka
//
// by Nolan "Dark Carnivour" Richert.
// Copyright(c) 2005 RuneStorm. All Rights Reserved.
//=============================================================================
class FLAKAttachment extends BallisticShotgunAttachment;


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

defaultproperties
{
     FireClass=Class'BWBP_SKC_Fix.FLAKPrimaryFire'
     MuzzleFlashClass=Class'BWBP_SKC_Fix.TraceEmitter_Flak'
     ImpactManager=Class'BallisticFix.IM_Shell'
     FlashScale=1.800000
     BrassClass=Class'BallisticFix.Brass_HAMR'
     TrackAnimMode=MU_Secondary
     TracerClass=Class'BallisticFix.TraceEmitter_Shotgun'
     TracerChance=0.500000
     Mesh=SkeletalMesh'BallisticAnims2.M763-3rd'
     DrawScale=0.080000
}
