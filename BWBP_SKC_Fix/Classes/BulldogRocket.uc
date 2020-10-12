//=============================================================================
// BulldogRocket.
//
// FRAG-12 explosive charge
//
// by Nolan "Dark Carnivour" Richert.
// Copyright(c) 2005 RuneStorm. All Rights Reserved.
//=============================================================================
class BulldogRocket extends BallisticProjectile;
var() Sound FlySound;

simulated function PostBeginPlay()
{
	SetTimer(0.15, false);
	super.PostBeginPlay();
	if (FastTrace(Location + vector(rotation) * 3000, Location))
		PlaySound(FlySound, SLOT_Interact, 1.0, , 512, , false);
}

simulated event Landed( vector HitNormal )
{
	HitWall(HitNormal, None);
}

simulated event HitWall(vector HitNormal, actor Wall)
{
	Explode(Location, HitNormal);
}

simulated event Tick(float DT)
{
	local Rotator R;

	R.Roll = Rotation.Roll;
	SetRotation(Rotator(velocity)+R);
}
// Hit something interesting
simulated function ProcessTouch (Actor Other, vector HitLocation)
{
	if (Other == None || (!bCanHitOwner && (Other == Instigator || Other == Owner || ( vehicle(Instigator)!=None&&Other==Vehicle(Instigator).Driver ) )))
		return;

	if (Role == ROLE_Authority)		// Do damage for direct hits
		DoDamage(Other, HitLocation);

	// Spawn projectile death effects and try radius damage
	HitActor = Other;
	Explode(HitLocation, vect(0,0,1));
}

simulated event Timer()
{
	SetPhysics(PHYS_Falling);
}


defaultproperties
{
     FlySound=Sound'BWBP4-Sounds.Artillery.Art-FlyBy'
     ImpactManager=Class'BWBP_SKC_Fix.IM_BulldogFRAG'
     bCheckHitSurface=True
     bRandomStartRotaion=False
     TrailClass=Class'BallisticFix.HAMRShellTrail'
     MyRadiusDamageType=Class'BWBP_SKC_Fix.DTBulldogFRAGRadius'
     SplashManager=Class'BallisticFix.IM_ProjWater'
     ShakeRadius=1024.000000
     MotionBlurRadius=200.000000
     Speed=2000.000000
     AccelSpeed=35000.000000
     MaxSpeed=35000.000000
     Damage=110.000000
     DamageRadius=180.000000
     MomentumTransfer=30000.000000
     MyDamageType=Class'BWBP_SKC_Fix.DTBulldogFRAG'
     StaticMesh=StaticMesh'BWBP_SKC_Static.Bulldog.BulldogFRAG'
//     Physics=PHYS_Falling
     DrawScale=0.300000
     SoundVolume=192
     SoundRadius=128.000000
     bFixedRotationDir=True
     RotationRate=(Roll=32768)
}
