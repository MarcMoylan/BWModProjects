//=============================================================================
// IE_FLAKAirBurst.
//
// by Nolan "Dark Carnivour" Richert.
// Copyright(c) 2005 RuneStorm. All Rights Reserved.
//=============================================================================
class IE_FLAKAirBurst extends BallisticEmitter
	placeable;

simulated event PostBeginPlay()
{
	Super.PostBeginPlay();
	bDynamicLight = true;
	SetTimer(0.2, false);
}

simulated event PreBeginPlay()
{
	if (Level.DetailMode < DM_SuperHigh)
		Emitters[3].Disabled=true;
		Emitters[9].Disabled=true;
	if (Level.DetailMode < DM_High)
	{
		Emitters[1].Disabled=true;
		Emitters[2].Disabled=true;
		Emitters[7].Disabled=true;
		Emitters[8].Disabled=true;
	}
	Super.PreBeginPlay();
}

simulated event Timer()
{
	Super.Timer();
	bDynamicLight = false;
}

defaultproperties
{
     Begin Object Class=SpriteEmitter Name=SpriteEmitter16
         UseCollision=True
         UseColorScale=True
         FadeOut=True
         FadeIn=True
         RespawnDeadParticles=False
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         AutomaticInitialSpawning=False
         Acceleration=(Z=100.000000)
         ExtentMultiplier=(X=0.400000,Y=0.400000,Z=0.400000)
         ColorScale(0)=(Color=(B=255,G=255,R=225,A=255))
         ColorScale(1)=(RelativeTime=0.114286,Color=(B=128,G=128,R=128,A=255))
         ColorScale(2)=(RelativeTime=1.000000,Color=(B=128,G=128,R=128,A=255))
         Opacity=0.590000
         FadeOutStartTime=2.080000
         FadeInEndTime=1.120000
         MaxParticles=20
         StartLocationShape=PTLS_Sphere
         SphereRadiusRange=(Min=10.000000,Max=20.000000)
         SpinsPerSecondRange=(X=(Max=0.100000))
         StartSpinRange=(X=(Max=1.000000))
         SizeScale(0)=(RelativeSize=0.200000)
         SizeScale(1)=(RelativeTime=0.070000,RelativeSize=1.000000)
         SizeScale(2)=(RelativeTime=1.000000,RelativeSize=1.000000)
         SizeScale(3)=(RelativeTime=0.370000,RelativeSize=0.900000)
         SizeScale(4)=(RelativeTime=1.000000,RelativeSize=1.000000)
         StartSizeRange=(X=(Max=120.000000),Y=(Max=120.000000),Z=(Max=120.000000))
         InitialParticlesPerSecond=50000.000000
         DrawStyle=PTDS_AlphaBlend
         Texture=Texture'BallisticEffects2.Particles.NewSmoke1g'
         SecondsBeforeInactive=0.000000
         StartVelocityRadialRange=(Min=-500.000000,Max=-300.000000)
         VelocityLossRange=(X=(Min=1.800000,Max=1.800000),Y=(Min=1.800000,Max=1.800000),Z=(Min=4.000000,Max=4.000000))
         GetVelocityDirectionFrom=PTVD_AddRadial
     End Object
     Emitters(0)=SpriteEmitter'BWBP_SKC_Fix.IE_FLAKAirBurst.SpriteEmitter16'

     Begin Object Class=MeshEmitter Name=MeshEmitter3
         StaticMesh=StaticMesh'BallisticHardware2.Impact.ConcreteChip2'
         UseMeshBlendMode=False
         UseParticleColor=True
         UseCollision=True
         FadeOut=True
         RespawnDeadParticles=False
         SpinParticles=True
         AutomaticInitialSpawning=False
         Acceleration=(Z=-800.000000)
         ExtentMultiplier=(X=0.500000,Y=0.500000,Z=0.500000)
         DampingFactorRange=(X=(Min=0.500000,Max=0.500000),Y=(Min=0.500000,Max=0.500000),Z=(Min=0.500000,Max=0.500000))
         ColorScale(0)=(Color=(B=255,G=255,R=255,A=255))
         ColorScale(1)=(RelativeTime=1.000000,Color=(B=255,G=255,R=255,A=255))
         ColorMultiplierRange=(Y=(Min=0.800000,Max=0.800000),Z=(Min=0.000000,Max=0.000000))
         FadeOutStartTime=0.370000
         MaxParticles=8
         SpinsPerSecondRange=(X=(Max=4.000000),Y=(Max=4.000000),Z=(Max=4.000000))
         StartSpinRange=(X=(Max=1.000000),Y=(Max=1.000000),Z=(Max=1.000000))
         StartSizeRange=(X=(Min=0.400000,Max=0.600000),Y=(Min=0.400000,Max=0.600000),Z=(Min=0.400000,Max=0.600000))
         InitialParticlesPerSecond=5000.000000
         SecondsBeforeInactive=0.000000
         MinSquaredVelocity=5000.000000
         LifetimeRange=(Min=1.500000,Max=1.500000)
         StartVelocityRange=(X=(Min=-600.000000,Max=600.000000),Y=(Min=-600.000000,Max=600.000000),Z=(Min=-100.000000,Max=600.000000))
     End Object
     Emitters(1)=MeshEmitter'BWBP_SKC_Fix.IE_FLAKAirBurst.MeshEmitter3'

     Begin Object Class=SpriteEmitter Name=SpriteEmitter23
         UseDirectionAs=PTDU_Up
         UseColorScale=True
         FadeOut=True
         RespawnDeadParticles=False
         SpinParticles=True
         UniformSize=True
         ScaleSizeYByVelocity=True
         AutomaticInitialSpawning=False
         ColorScale(0)=(Color=(G=128,R=255,A=255))
         ColorScale(1)=(RelativeTime=0.117857,Color=(B=128,G=128,R=128,A=255))
         ColorScale(2)=(RelativeTime=1.000000,Color=(B=128,G=128,R=128,A=255))
         Opacity=0.680000
         FadeOutStartTime=0.200000
         MaxParticles=120
         StartLocationRange=(X=(Min=-2.000000,Max=2.000000),Y=(Min=-2.000000,Max=2.000000),Z=(Min=-2.000000,Max=2.000000))
         AddLocationFromOtherEmitter=1
         StartSpinRange=(X=(Min=0.250000,Max=0.250000))
         StartSizeRange=(X=(Min=40.000000,Max=50.000000),Y=(Min=40.000000,Max=50.000000),Z=(Min=40.000000,Max=50.000000))
         ScaleSizeByVelocityMultiplier=(Y=0.001500)
         InitialParticlesPerSecond=120.000000
         DrawStyle=PTDS_AlphaBlend
         Texture=Texture'BallisticEffects.Particles.Smoke6'
         SecondsBeforeInactive=0.000000
         LifetimeRange=(Min=0.800000,Max=0.800000)
         AddVelocityFromOtherEmitter=1
         AddVelocityMultiplierRange=(X=(Min=0.100000,Max=0.150000),Y=(Min=0.100000,Max=0.150000),Z=(Min=0.100000,Max=0.150000))
     End Object
     Emitters(2)=SpriteEmitter'BWBP_SKC_Fix.IE_FLAKAirBurst.SpriteEmitter23'

     Begin Object Class=SpriteEmitter Name=SpriteEmitter17
         FadeOut=True
         RespawnDeadParticles=False
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         AutomaticInitialSpawning=False
         ColorScale(0)=(Color=(B=255,G=255,R=255,A=255))
         ColorScale(1)=(RelativeTime=1.000000,Color=(B=255,G=255,R=255,A=255))
         ColorMultiplierRange=(X=(Min=0.200000,Max=0.200000),Y=(Min=0.200000,Max=0.200000),Z=(Min=0.200000,Max=0.200000))
         FadeOutStartTime=0.110000
         MaxParticles=1
         SizeScale(1)=(RelativeTime=1.000000,RelativeSize=5.000000)
         StartSizeRange=(X=(Min=200.000000,Max=200.000000))
         InitialParticlesPerSecond=50000.000000
         DrawStyle=PTDS_Brighten
         Texture=Texture'BallisticEffects.Particles.Shockwave'
         SecondsBeforeInactive=0.000000
         LifetimeRange=(Min=0.500000,Max=0.500000)
     End Object
     Emitters(3)=SpriteEmitter'BWBP_SKC_Fix.IE_FLAKAirBurst.SpriteEmitter17'

     Begin Object Class=SpriteEmitter Name=SpriteEmitter20
         UseDirectionAs=PTDU_Normal
         FadeOut=True
         RespawnDeadParticles=False
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         AutomaticInitialSpawning=False
         BlendBetweenSubdivisions=True
         ColorScale(0)=(Color=(B=255,G=255,R=255,A=255))
         ColorScale(1)=(RelativeTime=1.000000,Color=(B=255,G=255,R=255,A=255))
         ColorMultiplierRange=(X=(Min=0.200000,Max=0.200000),Y=(Min=0.200000,Max=0.200000),Z=(Min=0.200000,Max=0.200000))
         FadeOutStartTime=0.200000
         MaxParticles=1
         SizeScale(1)=(RelativeTime=1.000000,RelativeSize=5.000000)
         StartSizeRange=(X=(Min=200.000000,Max=200.000000))
         InitialParticlesPerSecond=50000.000000
         DrawStyle=PTDS_Brighten
         Texture=Texture'BallisticEffects.Particles.Shockwave'
         SecondsBeforeInactive=0.000000
         LifetimeRange=(Min=0.500000,Max=0.500000)
     End Object
     Emitters(4)=SpriteEmitter'BWBP_SKC_Fix.IE_FLAKAirBurst.SpriteEmitter20'

     Begin Object Class=SpriteEmitter Name=SpriteEmitter21
         FadeOut=True
         RespawnDeadParticles=False
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         AutomaticInitialSpawning=False
         ColorScale(0)=(Color=(B=255,G=255,R=255,A=255))
         ColorScale(1)=(RelativeTime=1.000000,Color=(B=255,G=255,R=255,A=255))
         ColorMultiplierRange=(Y=(Min=0.700000,Max=0.800000),Z=(Min=0.700000,Max=0.800000))
         FadeOutStartTime=0.052500
         MaxParticles=3
         StartLocationRange=(X=(Min=-80.000000,Max=80.000000),Y=(Min=-80.000000,Max=80.000000),Z=(Min=-80.000000,Max=80.000000))
         StartSpinRange=(X=(Max=1.000000))
         SizeScale(1)=(RelativeTime=0.560000,RelativeSize=4.000000)
         SizeScale(2)=(RelativeTime=1.000000,RelativeSize=5.000000)
         StartSizeRange=(X=(Min=50.000000,Max=50.000000),Y=(Min=50.000000,Max=50.000000),Z=(Min=50.000000,Max=50.000000))
         InitialParticlesPerSecond=8.000000
         Texture=Texture'BallisticEffects.Particles.Explode2'
         SecondsBeforeInactive=0.000000
         LifetimeRange=(Min=0.250000,Max=0.250000)
     End Object
     Emitters(5)=SpriteEmitter'BWBP_SKC_Fix.IE_FLAKAirBurst.SpriteEmitter21'

     Begin Object Class=SpriteEmitter Name=SpriteEmitter19
         FadeOut=True
         RespawnDeadParticles=False
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         AutomaticInitialSpawning=False
         ColorScale(0)=(Color=(B=255,G=255,R=255,A=255))
         ColorScale(1)=(RelativeTime=1.000000,Color=(B=255,G=255,R=255,A=255))
         FadeOutStartTime=0.100000
         MaxParticles=1
         StartSpinRange=(X=(Max=1.000000))
         SizeScale(1)=(RelativeTime=0.560000,RelativeSize=4.000000)
         SizeScale(2)=(RelativeTime=1.000000,RelativeSize=5.000000)
         InitialParticlesPerSecond=50000.000000
         Texture=Texture'BallisticEffects.Particles.Explode2'
         SecondsBeforeInactive=0.000000
         LifetimeRange=(Min=0.400000,Max=0.400000)
     End Object
     Emitters(6)=SpriteEmitter'BWBP_SKC_Fix.IE_FLAKAirBurst.SpriteEmitter19'

  Begin Object Class=SpriteEmitter Name=SpriteEmitter46
         UseCollision=True
         UseColorScale=True
         FadeOut=True
         RespawnDeadParticles=False
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         AutomaticInitialSpawning=False
         Acceleration=(Z=100.000000)
         ExtentMultiplier=(X=0.400000,Y=0.400000,Z=0.400000)
         ColorScale(0)=(Color=(B=255,G=255,R=225,A=255))
         ColorScale(1)=(RelativeTime=0.032143,Color=(B=128,G=192,R=255,A=255))
         ColorScale(2)=(RelativeTime=0.064286,Color=(B=64,G=128,R=255,A=255))
         ColorScale(3)=(RelativeTime=0.117857,Color=(B=128,G=128,R=128,A=255))
         ColorScale(4)=(RelativeTime=1.000000,Color=(B=128,G=128,R=128,A=255))
         Opacity=0.700000
         FadeOutStartTime=2.120000
         MaxParticles=20
         StartLocationShape=PTLS_Sphere
         SphereRadiusRange=(Min=10.000000,Max=20.000000)
         SpinsPerSecondRange=(X=(Max=0.100000))
         StartSpinRange=(X=(Max=1.000000))
         SizeScale(0)=(RelativeSize=0.200000)
         SizeScale(1)=(RelativeTime=0.070000,RelativeSize=1.000000)
         SizeScale(2)=(RelativeTime=1.000000,RelativeSize=1.000000)
         SizeScale(3)=(RelativeTime=0.370000,RelativeSize=0.900000)
         SizeScale(4)=(RelativeTime=1.000000,RelativeSize=1.000000)
         StartSizeRange=(X=(Max=120.000000),Y=(Max=120.000000),Z=(Max=120.000000))
         InitialParticlesPerSecond=50000.000000
         DrawStyle=PTDS_AlphaBlend
         Texture=Texture'BallisticEffects.Particles.Smoke6'
         SecondsBeforeInactive=0.000000
    	    InitialDelayRange=(Min=0.200000,Max=0.200000)
         StartVelocityRadialRange=(Min=-500.000000,Max=-300.000000)
         VelocityLossRange=(X=(Min=2.000000,Max=2.000000),Y=(Min=2.000000,Max=2.000000),Z=(Min=4.000000,Max=4.000000))
         GetVelocityDirectionFrom=PTVD_AddRadial
     End Object
     Emitters(7)=SpriteEmitter'BWBP_SKC_Fix.IE_FLAKAirBurst.SpriteEmitter46'

     Begin Object Class=SpriteEmitter Name=SpriteEmitter40
         UseDirectionAs=PTDU_Normal
         FadeOut=True
         RespawnDeadParticles=False
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         AutomaticInitialSpawning=False
         BlendBetweenSubdivisions=True
         ColorScale(0)=(Color=(B=255,G=255,R=255,A=255))
         ColorScale(1)=(RelativeTime=1.000000,Color=(B=255,G=255,R=255,A=255))
         ColorMultiplierRange=(X=(Min=0.200000,Max=0.200000),Y=(Min=0.200000,Max=0.200000),Z=(Min=0.200000,Max=0.200000))
         FadeOutStartTime=0.200000
         MaxParticles=1
         SizeScale(1)=(RelativeTime=1.000000,RelativeSize=5.000000)
         StartSizeRange=(X=(Min=200.000000,Max=200.000000))
         InitialParticlesPerSecond=50000.000000
         DrawStyle=PTDS_Brighten
         Texture=Texture'BallisticEffects.Particles.Shockwave'
         SecondsBeforeInactive=0.000000
         LifetimeRange=(Min=0.500000,Max=0.500000)
    	    InitialDelayRange=(Min=0.200000,Max=0.200000)
     End Object
     Emitters(8)=SpriteEmitter'BWBP_SKC_Fix.IE_FLAKAirBurst.SpriteEmitter40'

     Begin Object Class=SpriteEmitter Name=SpriteEmitter47
         FadeOut=True
         RespawnDeadParticles=False
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         AutomaticInitialSpawning=False
         ColorScale(0)=(Color=(B=255,G=255,R=255,A=255))
         ColorScale(1)=(RelativeTime=1.000000,Color=(B=255,G=255,R=255,A=255))
         ColorMultiplierRange=(X=(Min=0.200000,Max=0.200000),Y=(Min=0.200000,Max=0.200000),Z=(Min=0.200000,Max=0.200000))
         FadeOutStartTime=0.200000
         MaxParticles=1
         SizeScale(1)=(RelativeTime=1.000000,RelativeSize=5.000000)
         StartSizeRange=(X=(Min=200.000000,Max=200.000000))
         InitialParticlesPerSecond=50000.000000
         DrawStyle=PTDS_Brighten
         Texture=Texture'BallisticEffects.Particles.Shockwave'
         SecondsBeforeInactive=0.000000
         LifetimeRange=(Min=0.500000,Max=0.500000)
    	    InitialDelayRange=(Min=0.200000,Max=0.200000)
     End Object
     Emitters(9)=SpriteEmitter'BWBP_SKC_Fix.IE_FLAKAirBurst.SpriteEmitter47'

     Begin Object Class=SpriteEmitter Name=SpriteEmitter48
         UseCollision=True
         UseMaxCollisions=True
         FadeOut=True
         RespawnDeadParticles=False
         UniformSize=True
         AutomaticInitialSpawning=False
         Acceleration=(Z=-400.000000)
         ExtentMultiplier=(X=0.700000,Y=0.700000,Z=0.700000)
         DampingFactorRange=(X=(Min=0.000000,Max=0.000000),Y=(Min=0.000000,Max=0.000000),Z=(Min=0.000000,Max=0.000000))
         MaxCollisions=(Min=1.000000,Max=1.000000)
         ColorScale(0)=(Color=(B=255,G=255,R=255))
         ColorScale(1)=(RelativeTime=1.000000,Color=(B=255,G=255,R=255))
         FadeOutStartTime=1.120000
         MaxParticles=100
         StartLocationShape=PTLS_Sphere
         SphereRadiusRange=(Min=10.000000,Max=20.000000)
         StartSizeRange=(X=(Min=5.000000,Max=10.000000))
         InitialParticlesPerSecond=50000.000000
         DrawStyle=PTDS_Brighten
         Texture=Texture'BallisticEffects.Particles.Explode2'
         SecondsBeforeInactive=0.000000
         LifetimeRange=(Min=2.000000,Max=2.000000)
    	    InitialDelayRange=(Min=0.200000,Max=0.200000)
         StartVelocityRange=(Z=(Min=100.000000,Max=300.000000))
         StartVelocityRadialRange=(Min=-800.000000,Max=-500.000000)
         GetVelocityDirectionFrom=PTVD_AddRadial
     End Object
     Emitters(10)=SpriteEmitter'BWBP_SKC_Fix.IE_FLAKAirBurst.SpriteEmitter48'

     Begin Object Class=SpriteEmitter Name=SpriteEmitter49
         FadeOut=True
         RespawnDeadParticles=False
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         AutomaticInitialSpawning=False
         ColorScale(0)=(Color=(B=255,G=255,R=255,A=255))
         ColorScale(1)=(RelativeTime=1.000000,Color=(B=255,G=255,R=255,A=255))
         FadeOutStartTime=0.100000
         MaxParticles=1
         StartSpinRange=(X=(Max=1.000000))
         SizeScale(1)=(RelativeTime=1.000000,RelativeSize=5.000000)
         InitialParticlesPerSecond=50000.000000
         Texture=Texture'BallisticEffects.Particles.Explode2'
         SecondsBeforeInactive=0.000000
         LifetimeRange=(Min=0.500000,Max=0.500000)
    	    InitialDelayRange=(Min=0.200000,Max=0.200000)
     End Object
     Emitters(11)=SpriteEmitter'BWBP_SKC_Fix.IE_FLAKAirBurst.SpriteEmitter49'


     AutoDestroy=True
     LightType=LT_Pulse
     LightEffect=LE_NonIncidence
     LightHue=30
     LightSaturation=150
     LightBrightness=150.000000
     LightRadius=32.000000
     LightPeriod=3
     bNoDelete=False
}
