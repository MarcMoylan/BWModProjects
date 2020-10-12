//=============================================================================
// MGL870Grenade.
//
// Grenade fired by MGL-870 grenade launcher.
//
// by Nolan "Dark Carnivour" Richert.
// Copyright(c) 2005 RuneStorm. All Rights Reserved.
//=============================================================================
class MGLGrenadeTimedXav extends BallisticGrenade;

var()	float	BounceVelReduct;	// Reduce the velocity by this number each bounce. 

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
	/*if (Pawn(Wall) != None)
	{
		DampenFactor *= 0.01;
		DampenFactorParallel *= 0.01;
	}*/

	if (Pawn(Wall) != None)
	{
		// Probably a horribly complicated way to reduce velocity by BounceVelReduct and make sure it doesn't go past 0
		if ( Abs(Velocity.X) - BounceVelReduct > 0 )
		{
			if ( Velocity.X > 0 )				// Probably horrible way to determine if it should be added or subtracted based on if Velocity is negative or not.
				Velocity.X -= BounceVelReduct;
			else
				Velocity.X += BounceVelReduct;
		}
		else
			Velocity.X = 0;
		// Lets do it again! Wooo!
		if ( Abs(Velocity.Y) - BounceVelReduct > 0 )
		{
			if ( Velocity.Y > 0 )
				Velocity.Y -= BounceVelReduct;
			else
				Velocity.Y += BounceVelReduct;
		}
		else
			Velocity.Y = 0;
		// One last time! Yaaaay. So much fun. Next time I'll do it in tick.
		if ( Abs(Velocity.Z) - BounceVelReduct > 0 )
		{
			if ( Velocity.Z > 0 )	
				Velocity.Z -= BounceVelReduct;
			else
				Velocity.Z += BounceVelReduct;
		}
		else
			Velocity.Z = 0;	
		// Suck it.
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
			PlaySound(ImpactSound, SLOT_Misc );
		if (ImpactManager != None)
			ImpactManager.static.StartSpawn(Location, HitNormal, Wall.SurfaceType, Owner);
    	}
}

defaultproperties
{
	 BounceVelReduct=10.00
     DampenFactor=0.300000
     DampenFactorParallel=0.300000	 
     DetonateOn=DT_Timer
     PlayerImpactType=PIT_Detonate
     bNoInitialSpin=True
     bAlignToVelocity=True
     DetonateDelay=3.000000
     FlakClass=Class'XWeapons.FlakChunk'
     ImpactDamage=180
     Speed=2000.000000
//     Speed=7000.000000
     DamageRadius=356.000000
     ImpactDamageType=Class'BallisticFix.DTM50Grenade'
     ImpactManager=Class'BWBP_SKC_Fix.IM_MGLGrenade'
     TrailClass=Class'BWBP_SKC_Fix.MGLNadeTrail'
     MyRadiusDamageType=Class'BallisticFix.DTM50GrenadeRadius'
     SplashManager=Class'BallisticFix.IM_ProjWater'
     ShakeRadius=512.000000
     MotionBlurRadius=400.000000
     MotionBlurFactor=3.000000
     MotionBlurTime=4.000000
     Damage=140.000000
     MyDamageType=Class'BallisticFix.DTM50GrenadeRadius'
     StaticMesh=StaticMesh'BallisticHardware2.M900.M900Grenade'
}
