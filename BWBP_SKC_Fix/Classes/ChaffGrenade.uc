//=============================================================================
// ChaffGrenade.
//
// Handheld version of the chaff grenade.
// This projectile comprises both the grenade and the explosive stick.
// Does more damage but must be thrown by hand.
//
// by Nolan "Dark Carnivour" Richert.
// Copyright(c) 2005 RuneStorm. All Rights Reserved.
//=============================================================================
class ChaffGrenade extends BallisticGrenade;

simulated function Explode(vector HitLocation, vector HitNormal)
{
  	local RX22AActorFire BurnA;
  	local FP7ActorBurner BurnB;
  	local BOGPFlareActorBurner BurnC;

	if (ShakeRadius > 0)
		ShakeView(HitLocation);
	BlowUp(HitLocation);
	
    if (ImpactManager != None)
	{
		if (Instigator == None)
			ImpactManager.static.StartSpawn(HitLocation, HitNormal, 0, Level.GetLocalPlayerController()/*.Pawn*/);
		else
			ImpactManager.static.StartSpawn(HitLocation, HitNormal, 0, Instigator);
	}

   	foreach RadiusActors( class 'RX22AActorFire', BurnA, 100, HitLocation )
   	{
    	BurnA.FuelOut();
   	}
   	foreach RadiusActors( class 'FP7ActorBurner', BurnB, 100, HitLocation )
   	{
    	BurnB.bDynamicLight=False;
    	BurnB.Destroy();
   	}
   	foreach RadiusActors( class 'BOGPFlareActorBurner', BurnC, 100, HitLocation )
   	{
    	BurnC.bDynamicLight=False;
    	BurnC.Destroy();
   	} 
	Destroy();
}

defaultproperties
{
	 bUnlit=False
	 MaxSpeed=1400
	 Speed=1400
     Damage=65.000000
     DamageRadius=256.000000
     DetonateOn=DT_Impact
     DrawScale=0.120000
     ImpactDamage=70
     ImpactDamageType=Class'BWBP_SKC_Fix.DTChaffGrenade'
     ImpactManager=Class'BWBP_SKC_Fix.IM_ChaffGrenade'
     MotionBlurFactor=2.000000
     MotionBlurRadius=768.000000
     MotionBlurTime=10.000000
     MyDamageType=Class'BWBP_SKC_Fix.DTChaffGrenadeRadius'
     MyRadiusDamageType=Class'BWBP_SKC_Fix.DTChaffGrenadeRadius'
     ShakeOffsetMag=(X=20.000000,Y=30.000000,Z=30.000000)
     ShakeRadius=512.000000
     ShakeRotMag=(X=512.000000,Y=400.000000)
     ShakeRotRate=(X=3000.000000,Z=3000.000000)
     SplashManager=Class'BallisticFix.IM_ProjWater'
     StaticMesh=StaticMesh'BWBP_SKC_StaticExp.MOAC.MOACProj'
     TrailClass=Class'BWBP_SKC_Fix.ChaffTrail'
     TrailOffset=(X=1.600000,Z=6.400000)
}
