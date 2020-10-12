//=============================================================================
// MGL870Grenade.
//
// Grenade fired by MGL-870 grenade launcher.
//
// by Nolan "Dark Carnivour" Richert.
// Copyright(c) 2005 RuneStorm. All Rights Reserved.
//=============================================================================
class MGLGrenadeTimed extends BallisticGrenade;


simulated event HitWall(vector HitNormal, actor Wall)
{
    local Vector VNorm;

	if (DetonateOn == DT_Impact)
	{
		Explode(Location, HitNormal);
		return;
	}
	else if (DetonateOn == DT_ImpactTimed && !bHasImpacted)
	{
		SetTimer(DetonateDelay, false);
	}
	if (Pawn(Wall) != None)
	{
		DampenFactor *= 0.21;
		DampenFactorParallel *= 0.21;
	}

	bCanHitOwner=true;
	bHasImpacted=true;

    VNorm = (Velocity dot HitNormal) * HitNormal;
    Velocity = -VNorm * DampenFactor + (Velocity - VNorm) * DampenFactorParallel;

	if (RandomSpin != 0)
		RandSpin(100000);
	
	Speed = VSize(Velocity/2);

	if (Speed < 20)
	{
		bBounce = False;
		SetPhysics(PHYS_None);
		if (Trail != None && !TrailWhenStill)
		{
			DestroyEffects();
		}
	}
	else if (Pawn(Wall) == None && (Level.NetMode != NM_DedicatedServer) && (Speed > 100) && (!Level.bDropDetail) && (Level.DetailMode != DM_Low) && EffectIsRelevant(Location,false))
	{
		if (ImpactSound != None)
			PlaySound(ImpactSound, SLOT_Misc, 1.5);
		if (ImpactManager != None)
			ImpactManager.static.StartSpawn(Location, HitNormal, Wall.SurfaceType, Owner);
    	}
}

defaultproperties
{
     bAlignToVelocity=True
     bNoInitialSpin=True
     Damage=140.000000
     DamageRadius=356.000000
     DetonateDelay=3.000000
	 DampenFactor=0.150000
     DampenFactorParallel=0.300000
     DetonateOn=DT_Timer
     FlakClass=Class'XWeapons.FlakChunk'
     ImpactDamage=180
     ImpactDamageType=Class'BallisticFix.DTM50Grenade'
     ImpactManager=Class'BWBP_SKC_Fix.IM_MGLGrenade'
     ImpactSound=Sound'BWBP_SKC_Sounds.Misc.FLAK-GrenadeBounce'
     MotionBlurFactor=3.000000
     MotionBlurRadius=400.000000
     MotionBlurTime=4.000000
     MyDamageType=Class'BallisticFix.DTM50GrenadeRadius'
     MyRadiusDamageType=Class'BallisticFix.DTM50GrenadeRadius'
     PlayerImpactType=PIT_Detonate
     ShakeRadius=512.000000
     Speed=2000.000000
     SplashManager=Class'BallisticFix.IM_ProjWater'
     StaticMesh=StaticMesh'BallisticHardware2.M900.M900Grenade'
     TrailClass=Class'BWBP_SKC_Fix.MGLNadeTrail'
//     Speed=7000.000000
}
