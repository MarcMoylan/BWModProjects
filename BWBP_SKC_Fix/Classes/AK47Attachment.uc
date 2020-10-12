//=============================================================================
// AK47Attachment.
//
// 3rd person weapon attachment for AK47 Battle Rifle
//
// by Nolan "Dark Carnivour" Richert.
// Copyright(c) 2005 RuneStorm. All Rights Reserved.
//=============================================================================
class AK47Attachment extends BallisticCamoAttachment;


var	  BallisticWeapon		myWeap;
var Vector		SpawnOffset;
var bool	bPokies;
replication
{
	// Things the server should send to the client.
	reliable if(Role==ROLE_Authority)
		bPokies;
}


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
	if (bPokies)
		class'IM_Knife'.static.StartSpawn(HitLocation, mHitNormal, mHitSurf, instigator);
	else
		class'IM_GunHit'.static.StartSpawn(HitLocation, mHitNormal, mHitSurf, instigator);
}


//Do your camo changes here
simulated function PostNetBeginPlay()
{
	if (CamoIndex != default.CamoIndex) 
		Skins[1] = CamoWeapon.default.CamoMaterials[CamoIndex];
}


defaultproperties
{
     CamoWeapon=Class'BWBP_SKC_Fix.AK47AssaultRifle'
     MuzzleFlashClass=Class'BallisticFix.XK2FlashEmitter'
     ImpactManager=Class'BallisticFix.IM_Bullet'
     BrassClass=Class'BallisticFix.Brass_Rifle'
     TracerClass=Class'BWBP_SKC_Fix.TraceEmitter_Tranq'
     WaterTracerClass=Class'BallisticFix.TraceEmitter_WaterBullet'
     WaterTracerMode=MU_Both
     FlyBySound=(Sound=SoundGroup'BallisticSounds2.FlyBys.Bullet-Whizz',Volume=0.700000)
     bRapidFire=True
     TrackAnimMode=MU_Secondary
     RelativeRotation=(Pitch=32768)
     Mesh=SkeletalMesh'BWBP_SKC_AnimExp.TP_AK490'
     DrawScale=0.250000
     Skins(0)=Texture'BWBP_SKC_TexExp.AK490.AK490-Misc'
     Skins(1)=Texture'BWBP_SKC_TexExp.AK490.AK490-Main'
}
