//=============================================================================
// X007Projectile.
//
// An electrical bolt
//
// by Nolan "Dark Carnivour" Richert.
// Copyright(c) 2005 RuneStorm. All Rights Reserved.
//=============================================================================
class Mk781PulseProjectile extends BallisticProjectile;
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
     AmbientSound=Sound'WeaponSounds.ShockRifleProjectile'
     ImpactManager=Class'BWBP_SKC_Fix.IM_EMPRocketAlt'
     bCheckHitSurface=True
     bRandomStartRotaion=False
     TrailClass=Class'Onslaught.ONSBluePlasmaSmallFireEffect'
     MyRadiusDamageType=Class'BWBP_SKC_Fix.DT_Mk781Bolt'
     SplashManager=Class'BallisticFix.IM_ProjWater'
     ShakeRadius=1024.000000
     MotionBlurRadius=200.000000
     Speed=3600.000000
     AccelSpeed=1200.000000
     MaxSpeed=1000000.000000
     Damage=100.000000
     DamageRadius=300.000000
     MomentumTransfer=10000.000000
     MyDamageType=Class'BWBP_SKC_Fix.DT_Mk781Bolt'
     StaticMesh=StaticMesh'BWBP4-Hardware.DarkStar.DarkProjBig'
     LifeSpan=16.000000
     Skins(0)=FinalBlend'BWBP_SKC_Tex.LS14.EMPProjFB'
     Skins(1)=FinalBlend'BWBP_SKC_Tex.LS14.EMPProjFB'
     Style=STY_Additive
//     Physics=PHYS_Falling
     LightHue=180
     LightSaturation=100
     LightBrightness=160.000000
     LightRadius=8.000000
     SoundVolume=255
     SoundRadius=75.000000
     bFixedRotationDir=True
     RotationRate=(Roll=32768)
}
