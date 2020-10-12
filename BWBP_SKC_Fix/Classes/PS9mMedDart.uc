//=============================================================================
// PS9mMedDart.
//
// Dart fired by PS9m ballistic attachment. Heals and cures radiation poisoning
//
// by Logan "BlackEagle" Richert.
// uses code by Nolan "Dark Carnivour" Richert.
// Copyright© 2011 RuneStorm. All Rights Reserved.
//=============================================================================
class PS9mMedDart extends BallisticProjectile;

var	float	HealRadius;
var	float	HealAmount;


// Do radius damage;
function BlowUp(vector HitLocation)
{
	if (Role < ROLE_Authority)
		return;
	if (DamageRadius > 0)
	{
		HealRadiusFunction(HealAmount, HealRadius, HitLocation);
		TargetedHurtRadius(Damage, DamageRadius, MyRadiusDamageType, MomentumTransfer, HitLocation, HitActor);
	}
//	HitActor = None;
	MakeNoise(1.0);
}


simulated function HealRadiusFunction( float HealAmount, float HealRadius, vector RadiusStart)
{
	local actor Victims;
	local float damageScale, dist;
	local vector dir;
	local pawn Target;
	local NukeActorBurner Burn;
	
   	foreach RadiusActors( class 'NukeActorBurner', Burn, 100, RadiusStart )
   	{
    		Burn.Destroy();
   	}

	if(bHurtEntry )
		return;

	bHurtEntry = true;
	foreach VisibleCollidingActors( class 'Actor', Victims, HealRadius, RadiusStart )
	{
		// don't let blast damage affect fluid - VisibleCollisingActors doesn't really work for them - jag
		if(Victims != Self && (Victims.Role == ROLE_Authority) && Victims.bCanBeDamaged && (!Victims.IsA('FluidSurfaceInfo')) && Victims != Instigator)
		{
			Target=Pawn(Victims);
			dir = Victims.Location - RadiusStart;
			dist = FMax(1,VSize(dir));
			dir = dir/dist;
			damageScale = 1 - FMax(0,(dist - Victims.CollisionRadius)/HealRadius);
			Pawn(Victims).GiveHealth(HealAmount * DamageScale, Pawn(Victims).HealthMax);
		}
	}
	bHurtEntry = false;
}

defaultproperties
{
	 HealRadius=300
	 HealAmount=25
     ImpactManager=Class'BallisticFix.IM_XMK5Dart'
     TrailClass=Class'BallisticFix.PineappleTrail'
     MyRadiusDamageType=Class'BWBP_SKC_Fix.DT_PS9mMedDart'
     SplashManager=Class'BallisticFix.IM_ProjWater'
     ShakeRadius=0.000000
     MotionBlurRadius=0.000000
     MotionBlurFactor=0.000000
     MotionBlurTime=0.000000
     Speed=6500.000000
     Damage=30.000000
     MyDamageType=Class'BWBP_SKC_Fix.DT_PS9mMedDart'
     StaticMesh=StaticMesh'BallisticHardware_25.OA-SMG.OA-SMG_Dart'
     LifeSpan=1.500000
}
