//=============================================================================
// MGL870Grenade.
//
// Grenade fired by MGL-870 grenade launcher.
// Remote detonation. Has a timer so you can't airburst it left and right
//
// by Nolan "Dark Carnivour" Richert.
// Copyright(c) 2005 RuneStorm. All Rights Reserved.
//=============================================================================
class MGLGrenadeRemote extends BallisticGrenade;

var	bool	bReady;

simulated event Timer() //Timer will handle remote det lock
{
	if (StartDelay > 0)
	{
		StartDelay = 0;
		bHidden=false;
		SetPhysics(default.Physics);
		SetCollision (default.bCollideActors, default.bBlockActors, default.bBlockPlayers);
		InitProjectile();
		return;
	}
	if (HitActor != None)
	{
		if ( Instigator == None || Instigator.Controller == None )
			HitActor.SetDelayedDamageInstigatorController( InstigatorController );
		class'BallisticDamageType'.static.GenericHurt (HitActor, Damage, Instigator, Location, MomentumTransfer * (HitActor.Location - Location), MyDamageType);
	}
	bReady=true;
}

simulated function InitProjectile ()
{
	InitEffects();
	Velocity = Speed * Vector(VelocityDir);
	if (RandomSpin != 0 && !bNoInitialSpin)
		RandSpin(RandomSpin);
	SetTimer(DetonateDelay, false);
}

function RemoteDetonate()
{
	if (bReady)
	{
		Explode(Location, vect(0,0,1));
	}
}

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
	 bReady=false
	 DampenFactor=0.150000
     DampenFactorParallel=0.300000
     DetonateOn=DT_None
     PlayerImpactType=PIT_Stick
     bNoInitialSpin=True
     bAlignToVelocity=True
     DetonateDelay=0.35
     FlakClass=Class'XWeapons.FlakChunk'
     ImpactDamage=25
     ImpactSound=Sound'BWBP_SKC_Sounds.Misc.FLAK-GrenadeBounce'
     Speed=4000.000000
	 bUpdateSimulatedPosition=True
	 bNetTemporary=False
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
     Damage=130.000000
     MyDamageType=Class'BallisticFix.DTM50GrenadeRadius'
     StaticMesh=StaticMesh'BallisticHardware2.M900.M900Grenade'
}
