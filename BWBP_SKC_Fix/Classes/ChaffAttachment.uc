//=============================================================================
// ChaffAttachment.
//
// 3rd person weapon attachment for MOA-C Grenade.
//
// by Nolan "Dark Carnivour" Richert.
// Copyright(c) 2005 RuneStorm. All Rights Reserved.
//=============================================================================
class ChaffAttachment extends BallisticGrenadeAttachment;

simulated function InstantFireEffects(byte Mode)
{
	if (FiringMode != 0)
		MeleeFireEffects();
	else
		Super.InstantFireEffects(FiringMode);
}

simulated event ThirdPersonEffects()
{
	//Throw
	if (FiringMode == 0)
	{
		if (Level.NetMode != NM_DedicatedServer)
			PlayPawnFiring(FiringMode);
		if (GrenadeSmoke != None)
			class'BallisticEmitter'.static.StopParticles(GrenadeSmoke);
	}
	//Hit
	else if ( Level.NetMode != NM_DedicatedServer && Instigator != None)
	{
		//Spawn impacts, streaks, etc
		InstantFireEffects(FiringMode);
		//Play pawn anims
		PlayPawnFiring(FiringMode);
    }
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
	class'IM_GunHit'.static.StartSpawn(HitLocation, mHitNormal, mHitSurf, instigator);	
}

defaultproperties
{
     DrawScale=0.6500000
     ExplodeManager=Class'BWBP_SKC_Fix.IM_ChaffGrenade'
     GrenadeSmokeClass=Class'BWBP_SKC_Fix.ChaffTrail'
     Mesh=SkeletalMesh'BWBP_SKC_AnimExp.TP_MOAC'
     RelativeLocation=(X=-2.000000,Y=-3.000000,Z=20.000000)
     RelativeRotation=(Pitch=32768)
     TrackAnimMode=MU_Both
	 InstantMode=MU_Secondary
}
