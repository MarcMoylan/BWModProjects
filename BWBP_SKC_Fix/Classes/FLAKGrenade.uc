//=============================================================================
// FLAKGrenade.
//
// Anti-Air projectile.
// If launched in the air, it will begin to detect for actors in a radius to
// airburst on. This will launch lots of flak bomblets.
//
// Otherwise it'll just blow up a short time after hitting a wall.
//
//
// by Nolan "Dark Carnivour" Richert.
// Copyright(c) 2005 RuneStorm. All Rights Reserved.
//=============================================================================
class FLAKGrenade extends BallisticGrenade;


var bool bPrimed;
var bool bQuickDet;
var float DetectRadius;
var float DetectDelay;

simulated function PostBeginPlay()
{
	SetTimer(DetectDelay, false);
	super.PostBeginPlay();
}

simulated event Timer()
{
	if (bQuickDet)
	{
		FlakCount=12;
		DamageRadius*=1.5;
		Explode(Location, vect(0,0,1));
	}
	if (!bPrimed)
	{
		bPrimed=true;
		return;
	}
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
	Explode(Location, vect(0,0,1));
}

// Make the thing look like its pointing in the direction its going
simulated event Tick( float DT )
{

	local Actor Target;

	if (bAlignToVelocity && ( RandomSpin == 0 || (bNoInitialSpin && !bHasImpacted) ))
		SetRotation(Rotator(Velocity));

	foreach VisibleCollidingActors( class 'Actor', Target, DetectRadius, Location )
	{

		if (Target.bCanBeDamaged && bPrimed && !bHasImpacted)
		{
			bQuickDet=true;
			SetTimer(0.01, false);
		}

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
		bPrimed=True;
		SetTimer(DetonateDelay, false);
	}
	if (Pawn(Wall) != None)
	{
		DampenFactor *= 0.5;
		DampenFactorParallel *= 0.5;
	}

	bCanHitOwner=true;
	bHasImpacted=true;

    VNorm = (Velocity dot HitNormal) * HitNormal;
    Velocity = -VNorm * DampenFactor + (Velocity - VNorm) * DampenFactorParallel;

	if (RandomSpin != 0)
		RandSpin(100000);
	Speed = VSize(Velocity);

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
     Speed=3500.000000
     bNoInitialSpin=True
     bAlignToVelocity=True
     bQuickDet=false
     bIgnoreTerminalVelocity=True
     DetonateDelay=0.600000
     DetectDelay=1.000000
     ImpactDamage=80
     FlakClass=Class'BWBP_SKC_Fix.FlakGrenadeCluster'
     FlakCount=0
    DetonateOn=DT_ImpactTimed
    ImpactManager=Class'BWBP_SKC_Fix.IM_FLAKGrenade'
    TrailClass=Class'BWBP_SKC_Fix.MGLNadeTrail'
    PlayerImpactType=PIT_Bounce
     ImpactSound=Sound'BWBP_SKC_Sounds.Misc.FLAK-GrenadeBounce'
    DamageRadius=512.000000
    DetectRadius=384.000000
    Damage=140.000000
    ShakeRadius=1000.000000
    MotionBlurRadius=700.000000
     ImpactDamageType=Class'BallisticFix.DTM50Grenade'
     MyRadiusDamageType=Class'BallisticFix.DTM50GrenadeRadius'
     SplashManager=Class'BallisticFix.IM_ProjWater'
     MotionBlurFactor=4.000000
     MotionBlurTime=4.000000
     DrawScale=1.00000
     MyDamageType=Class'BallisticFix.DTM50GrenadeRadius'
     StaticMesh=StaticMesh'BWBP4-Hardware.MRL.MRLRocket'
}
