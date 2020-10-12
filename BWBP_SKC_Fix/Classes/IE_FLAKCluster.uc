//=============================================================================
// IE_FLAKCluster.
//
// by Nolan "Dark Carnivour" Richert.
// Copyright(c) 2005 RuneStorm. All Rights Reserved.
//=============================================================================
class IE_FLAKCluster extends BallisticEmitter
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
    Begin Object Class=SpriteEmitter Name=SpriteEmitter78
        FadeOut=True
        FadeIn=True
        RespawnDeadParticles=False
        SpinParticles=True
        UseSizeScale=True
        UseRegularSizeScale=False
        UniformSize=True
        AutomaticInitialSpawning=False
        Acceleration=(Z=20.000000)
        ColorScale(0)=(Color=(B=255,G=255,R=255,A=255))
        ColorScale(1)=(RelativeTime=1.000000,Color=(B=255,G=255,R=255,A=255))
        FadeOutStartTime=1.200000
        FadeInEndTime=0.680000
        MaxParticles=3
      
        DetailMode=DM_High
        StartLocationRange=(X=(Min=-40.000000,Max=40.000000),Y=(Min=-40.000000,Max=40.000000))
        SpinsPerSecondRange=(X=(Max=0.100000))
        StartSpinRange=(X=(Max=1.000000))
        SizeScale(0)=(RelativeSize=0.200000)
        SizeScale(1)=(RelativeTime=1.000000,RelativeSize=1.000000)
        StartSizeRange=(X=(Min=80.000000,Max=80.000000),Y=(Min=80.000000,Max=80.000000),Z=(Min=80.000000,Max=80.000000))
        InitialParticlesPerSecond=20000.000000
        DrawStyle=PTDS_Brighten
        Texture=Texture'BallisticEffects.Particles.Smoke5'
        SecondsBeforeInactive=0.000000
        LifetimeRange=(Min=3.000000)
        StartVelocityRange=(X=(Min=-50.000000,Max=50.000000),Y=(Min=-50.000000,Max=50.000000),Z=(Min=80.000000,Max=200.000000))
        VelocityLossRange=(X=(Min=1.000000,Max=1.000000),Y=(Min=1.000000,Max=1.000000),Z=(Min=2.000000,Max=3.000000))
    End Object
    Emitters(0)=SpriteEmitter'BWBP_SKC_Fix.IE_FLAKCluster.SpriteEmitter78'

    Begin Object Class=TrailEmitter Name=TrailEmitter2
        TrailShadeType=PTTST_PointLife
        MaxPointsPerTrail=100
        DistanceThreshold=10.000000
        PointLifeTime=3.500000
        FadeOut=True
        RespawnDeadParticles=False
        AutomaticInitialSpawning=False
        Acceleration=(Z=-450.000000)
        FadeOutStartTime=1.000000
        FadeInEndTime=1.000000
        MaxParticles=15
      
        AddLocationFromOtherEmitter=3
        StartSizeRange=(X=(Min=8.000000,Max=9.000000))
        InitialParticlesPerSecond=50000.000000
        DrawStyle=PTDS_Darken
        Texture=Texture'BallisticEffects.Particles.Smoke2'
        SecondsBeforeInactive=0.000000
        LifetimeRange=(Min=3.500000,Max=3.500000)
        VelocityLossRange=(X=(Min=0.600000,Max=0.600000),Y=(Min=0.600000,Max=0.600000))
        AddVelocityFromOtherEmitter=3
    End Object
    Emitters(1)=TrailEmitter'BWBP_SKC_Fix.IE_FLAKCluster.TrailEmitter2'

    Begin Object Class=SpriteEmitter Name=SpriteEmitter83
        FadeOut=True
        RespawnDeadParticles=False
        UseSizeScale=True
        UseRegularSizeScale=False
        UniformSize=True
        AutomaticInitialSpawning=False
        ColorScale(0)=(Color=(B=255,G=255,R=255,A=255))
        ColorScale(1)=(RelativeTime=1.000000,Color=(B=255,G=255,R=255,A=255))
        ColorMultiplierRange=(Y=(Min=0.600000,Max=0.800000),Z=(Min=0.500000,Max=0.600000))
        MaxParticles=1
      
        DetailMode=DM_High
        SizeScale(1)=(RelativeTime=1.000000,RelativeSize=1.000000)
        StartSizeRange=(X=(Min=90.000000,Max=90.000000),Y=(Min=30.000002,Max=30.000002),Z=(Min=30.000002,Max=30.000002))
        InitialParticlesPerSecond=50000.000000
        Texture=Texture'BallisticEffects.Particles.Shockwave'
        SecondsBeforeInactive=0.000000
        LifetimeRange=(Min=0.400000,Max=0.400000)
    End Object
    Emitters(2)=SpriteEmitter'BWBP_SKC_Fix.IE_FLAKCluster.SpriteEmitter83'

    Begin Object Class=SpriteEmitter Name=SpriteEmitter85
        UseColorScale=True
        FadeOut=True
        RespawnDeadParticles=False
        SpinParticles=True
        UseSizeScale=True
        UseRegularSizeScale=False
        UniformSize=True
        AutomaticInitialSpawning=False
        ColorScale(0)=(Color=(B=255,G=255,R=255))
        ColorScale(1)=(RelativeTime=1.000000,Color=(B=128,G=192,R=255))
        ColorMultiplierRange=(X=(Min=0.800000),Y=(Min=0.800000),Z=(Max=1.500000))
        FadeOutStartTime=0.200000
        MaxParticles=2
      
        AlphaRef=128
        StartSpinRange=(X=(Max=1.000000))
        SizeScale(1)=(RelativeTime=0.370000,RelativeSize=0.500000)
        SizeScale(2)=(RelativeTime=1.000000,RelativeSize=1.100000)
        StartSizeRange=(X=(Min=80.000000,Max=120.000000),Y=(Min=40.000000,Max=40.000000),Z=(Min=40.000000,Max=40.000000))
        InitialParticlesPerSecond=20.000000
        Texture=Texture'BallisticEffects.Particles.Explode2'
        SecondsBeforeInactive=0.000000
        LifetimeRange=(Min=0.500000,Max=0.500000)
        StartVelocityRange=(X=(Min=-20.000000,Max=20.000000),Y=(Min=-20.000000,Max=20.000000))
    End Object
    Emitters(3)=SpriteEmitter'BWBP_SKC_Fix.IE_FLAKCluster.SpriteEmitter85'

    Begin Object Class=SpriteEmitter Name=SpriteEmitter86
        UseDirectionAs=PTDU_Up
        ProjectionNormal=(Y=-2.000000)
        FadeOut=True
        FadeIn=True
        RespawnDeadParticles=False
        SpinParticles=True
        UseSizeScale=True
        UseRegularSizeScale=False
        UniformSize=True
        AutomaticInitialSpawning=False
        ColorScale(0)=(Color=(B=255,G=255,R=255,A=255))
        ColorScale(1)=(RelativeTime=1.000000,Color=(B=255,G=255,R=255,A=255))
        FadeOutStartTime=0.230000
        FadeInEndTime=0.050000
        MaxParticles=8
      
        UseRotationFrom=PTRS_Actor
        StartSpinRange=(X=(Min=-0.200000,Max=0.200000))
        SizeScale(0)=(RelativeTime=0.140000,RelativeSize=3.000000)
        SizeScale(1)=(RelativeTime=0.550000,RelativeSize=4.000000)
        SizeScale(2)=(RelativeTime=1.000000,RelativeSize=4.500000)
        StartSizeRange=(X=(Min=40.000000,Max=40.000000),Y=(Min=40.000000,Max=40.000000),Z=(Min=40.000000,Max=40.000000))
        InitialParticlesPerSecond=5000.000000
        DrawStyle=PTDS_AlphaBlend
        Texture=Texture'AW-2004Particles.Dirt.BlastSpray2a'
        LifetimeRange=(Min=1.500000,Max=1.500000)
        StartVelocityRange=(X=(Min=0.400000,Max=2.000000))
    End Object
    Emitters(4)=SpriteEmitter'BWBP_SKC_Fix.IE_FLAKCluster.SpriteEmitter86'

    Begin Object Class=SpriteEmitter Name=SpriteEmitter87
        FadeOut=True
        FadeIn=True
        RespawnDeadParticles=False
        SpinParticles=True
        UseSizeScale=True
        UseRegularSizeScale=False
        UniformSize=True
        AutomaticInitialSpawning=False
        ColorScale(0)=(Color=(B=255,G=255,R=255,A=255))
        ColorScale(1)=(RelativeTime=1.000000,Color=(B=255,G=255,R=255,A=255))
        Opacity=0.600000
        FadeOutStartTime=2.640000
        FadeInEndTime=0.360000
        MaxParticles=7
      
        StartLocationRange=(X=(Min=-40.000000,Max=40.000000),Y=(Min=-40.000000,Max=40.000000),Z=(Max=60.000000))
        SpinsPerSecondRange=(X=(Min=0.050000,Max=0.100000),Y=(Min=0.050000,Max=0.100000),Z=(Min=0.050000,Max=0.100000))
        StartSpinRange=(X=(Max=1.000000),Y=(Max=1.000000),Z=(Max=1.000000))
        SizeScale(0)=(RelativeTime=0.070000,RelativeSize=2.000000)
        SizeScale(1)=(RelativeTime=0.740000,RelativeSize=3.400000)
        SizeScale(2)=(RelativeTime=1.000000,RelativeSize=3.500000)
        SizeScale(3)=(RelativeTime=0.370000,RelativeSize=3.200000)
        SizeScale(4)=(RelativeTime=0.310000,RelativeSize=2.700000)
        StartSizeRange=(X=(Min=20.000000,Max=20.000000),Y=(Min=20.000000,Max=20.000000),Z=(Min=20.000000,Max=20.000000))
        InitialParticlesPerSecond=5000.000000
        DrawStyle=PTDS_AlphaBlend
        Texture=Texture'BallisticEffects.Particles.Smoke3'
        LifetimeRange=(Min=3.000000)
        StartVelocityRange=(Z=(Min=8.000000,Max=8.000000))
    End Object
    Emitters(5)=SpriteEmitter'BWBP_SKC_Fix.IE_FLAKCluster.SpriteEmitter87'

    Begin Object Class=SpriteEmitter Name=SpriteEmitter88
        FadeOut=True
        RespawnDeadParticles=False
        SpinParticles=True
        UniformSize=True
        AutomaticInitialSpawning=False
        ColorScale(0)=(Color=(B=255,G=255,R=255,A=255))
        ColorScale(1)=(RelativeTime=1.000000,Color=(B=255,G=255,R=255,A=255))
        FadeOutStartTime=0.100000
        MaxParticles=1
      
        SpinsPerSecondRange=(X=(Min=0.050000,Max=0.100000),Y=(Min=0.050000,Max=0.100000),Z=(Min=0.050000,Max=0.100000))
        StartSpinRange=(X=(Max=1.000000),Y=(Max=1.000000),Z=(Max=1.000000))
        StartSizeRange=(X=(Min=160.000000,Max=160.000000),Y=(Min=160.000000,Max=160.000000),Z=(Min=160.000000,Max=160.000000))
        InitialParticlesPerSecond=5000.000000
        Texture=Texture'BallisticEffects.Specularity.BWSpecularity'
        LifetimeRange=(Min=0.200000,Max=0.200000)
    End Object
    Emitters(6)=SpriteEmitter'BWBP_SKC_Fix.IE_FLAKCluster.SpriteEmitter88'

    Begin Object Class=SpriteEmitter Name=SpriteEmitter89
        FadeOut=True
        RespawnDeadParticles=False
        SpinParticles=True
        UseSizeScale=True
        UseRegularSizeScale=False
        UniformSize=True
        AutomaticInitialSpawning=False
        BlendBetweenSubdivisions=True
        ColorScale(0)=(Color=(B=255,G=255,R=255,A=255))
        ColorScale(1)=(RelativeTime=1.000000,Color=(B=255,G=255,R=255,A=255))
        Opacity=0.600000
        FadeOutStartTime=0.100000
        MaxParticles=2
      
        SpinsPerSecondRange=(X=(Min=0.050000,Max=0.100000),Y=(Min=0.050000,Max=0.100000),Z=(Min=0.050000,Max=0.100000))
        StartSpinRange=(X=(Max=1.000000),Y=(Max=1.000000),Z=(Max=1.000000))
        SizeScale(0)=(RelativeTime=1.000000,RelativeSize=6.000000)
        StartSizeRange=(X=(Min=20.000000,Max=20.000000),Y=(Min=20.000000,Max=20.000000),Z=(Min=20.000000,Max=20.000000))
        InitialParticlesPerSecond=5000.000000
        Texture=Texture'ONSBPTextures.fX.ExploTrans'
        TextureUSubdivisions=2
        TextureVSubdivisions=2
        LifetimeRange=(Min=0.900000,Max=0.900000)
    End Object
    Emitters(7)=SpriteEmitter'BWBP_SKC_Fix.IE_FLAKCluster.SpriteEmitter89'

    Begin Object Class=SpriteEmitter Name=SpriteEmitter90
        UseCollision=True
        UseColorScale=True
        FadeOut=True
        FadeIn=True
        RespawnDeadParticles=False
        SpinParticles=True
        UseSizeScale=True
        UniformSize=True
        AutomaticInitialSpawning=False
        DampingFactorRange=(X=(Min=0.500000,Max=0.500000),Y=(Min=0.500000,Max=0.500000),Z=(Min=0.500000,Max=0.500000))
        ColorScale(0)=(Color=(B=255,G=255,R=255,A=255))
        ColorScale(1)=(RelativeTime=1.000000,Color=(G=150,R=255,A=255))
        FadeOutStartTime=0.160000
        FadeInEndTime=0.160000
        CoordinateSystem=PTCS_Relative
      
        SpinsPerSecondRange=(X=(Min=0.050000,Max=0.100000),Y=(Min=0.050000,Max=0.100000),Z=(Min=0.050000,Max=0.100000))
        StartSpinRange=(X=(Max=1.000000),Y=(Max=1.000000),Z=(Max=1.000000))
        StartSizeRange=(X=(Min=5.000000,Max=5.000000),Y=(Min=5.000000,Max=5.000000),Z=(Min=5.000000,Max=5.000000))
        InitialParticlesPerSecond=5000.000000
        Texture=Texture'EpicParticles.Flares.FlashFlare1'
        LifetimeRange=(Min=1.000000,Max=1.500000)
        StartVelocityRange=(X=(Min=50.000000,Max=200.000000),Y=(Min=-130.000000,Max=130.000000),Z=(Min=-130.000000,Max=130.000000))
        VelocityLossRange=(X=(Min=0.950000,Max=0.950000),Y=(Min=0.950000,Max=0.950000),Z=(Min=0.950000,Max=0.950000))
    End Object
    Emitters(8)=SpriteEmitter'BWBP_SKC_Fix.IE_FLAKCluster.SpriteEmitter90'


    Rotation=(Pitch=23304,Roll=932)
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
