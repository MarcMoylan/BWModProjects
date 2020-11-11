//=============================================================================
// TraceEmitter_LS14RR. Effects for the laser replicator refractor.
//
// by Nolan "Dark Carnivour" Richert.
// Copyright(c) 2005 RuneStorm. All Rights Reserved.
//=============================================================================
class TraceEmitter_LS14RR extends BCTraceEmitter;

simulated function Initialize(float Distance, optional float Power)
{
	Power = Power/255;
	BeamEmitter(Emitters[0]).BeamDistanceRange.Min = FMax(0, Distance-100);
	BeamEmitter(Emitters[0]).BeamDistanceRange.Max = FMax(0, Distance-100);
//	Emitters[0].Opacity = Emitters[0].default.Opacity * Power;
//	Emitters[1].Opacity = Emitters[1].default.Opacity * Power;
//	Emitters[3].Opacity = Emitters[3].default.Opacity * Power;
	BeamEmitter(Emitters[1]).BeamDistanceRange.Min = Distance;
	BeamEmitter(Emitters[1]).BeamDistanceRange.Max = Distance;
	BeamEmitter(Emitters[5]).BeamDistanceRange.Min = Distance;
	BeamEmitter(Emitters[5]).BeamDistanceRange.Max = Distance;
	Emitters[6].LifeTimeRange.Min = Distance / 8000;
	Emitters[6].LifeTimeRange.Max = Distance / 8000;
}

defaultproperties
{
    Begin Object Class=BeamEmitter Name=BeamEmitter0
        BeamDistanceRange=(Min=5000.000000,Max=5000.000000)
        DetermineEndPointBy=PTEP_Distance
        BeamTextureUScale=8.000000
        UseColorScale=True
        FadeOut=True
        RespawnDeadParticles=False
        UseSizeScale=True
        UseRegularSizeScale=False
        AutomaticInitialSpawning=False
        ColorScale(0)=(Color=(B=255,G=255,R=255,A=255))
        ColorScale(1)=(RelativeTime=1.000000,Color=(R=255,A=255))
        ColorMultiplierRange=(X=(Min=0.800000,Max=0.800000),Y=(Min=0.800000,Max=0.800000),Z=(Min=0.800000,Max=0.800000))
        FadeOutStartTime=0.025000
        CoordinateSystem=PTCS_Relative
        MaxParticles=1
      
        DetailMode=DM_SuperHigh
        StartLocationOffset=(X=100.000000)
        SizeScale(1)=(RelativeTime=0.680000,RelativeSize=0.300000)
        SizeScale(2)=(RelativeTime=1.000000,RelativeSize=1.000000)
        StartSizeRange=(X=(Min=25.000000,Max=25.000000),Y=(Min=25.000000,Max=25.000000),Z=(Min=25.000000,Max=25.000000))
        InitialParticlesPerSecond=50000.000000
        Texture=Texture'BallisticEffects.GunFire.RailCoreWave'
        LifetimeRange=(Min=0.350000,Max=0.350000)
        StartVelocityRange=(X=(Min=0.010000,Max=0.010000))
    End Object
     Emitters(0)=BeamEmitter'BWBP_SKC_Fix.TraceEmitter_LS14RR.BeamEmitter0'

    Begin Object Class=BeamEmitter Name=BeamEmitter1
        BeamDistanceRange=(Min=5000.000000,Max=5000.000000)
        DetermineEndPointBy=PTEP_Distance
        BeamTextureUScale=8.000000
        UseColorScale=True
        FadeOut=True
        RespawnDeadParticles=False
        UseSizeScale=True
        UseRegularSizeScale=False
        AutomaticInitialSpawning=False
        ColorScale(0)=(Color=(B=3,G=32,R=255,A=255))
        ColorScale(1)=(RelativeTime=0.275000,Color=(B=255,G=255,R=255,A=255))
        ColorScale(2)=(RelativeTime=0.521429,Color=(R=255,A=255))
        ColorScale(3)=(RelativeTime=1.000000,Color=(B=27,G=24,R=122,A=255))
        ColorMultiplierRange=(X=(Min=0.800000,Max=0.900000),Y=(Min=0.900000))
        FadeOutStartTime=0.192000
        CoordinateSystem=PTCS_Relative
        MaxParticles=1
      
        SizeScale(0)=(RelativeSize=0.200000)
        SizeScale(1)=(RelativeTime=0.280000,RelativeSize=0.800000)
        SizeScale(2)=(RelativeTime=1.000000,RelativeSize=1.000000)
        StartSizeRange=(X=(Min=3.000000,Max=4.000000),Y=(Min=3.000000,Max=4.000000),Z=(Min=3.000000,Max=4.000000))
        InitialParticlesPerSecond=50000.000000
        Texture=Texture'BWBP_SKC_Tex.BeamCannon.HMCSmokeCore2'
        LifetimeRange=(Min=0.300000,Max=0.300000)
        StartVelocityRange=(X=(Min=1.000000,Max=1.000000))
    End Object
     Emitters(1)=BeamEmitter'BWBP_SKC_Fix.TraceEmitter_LS14RR.BeamEmitter1'

    Begin Object Class=SpriteEmitter Name=SpriteEmitter0
        FadeOut=True
        FadeIn=True
        RespawnDeadParticles=False
        SpinParticles=True
        UseSizeScale=True
        UseRegularSizeScale=False
        UniformSize=True
        AutomaticInitialSpawning=False
        UseRandomSubdivision=True
        Acceleration=(Z=2.000000)
        ColorScale(0)=(Color=(B=255,G=255,R=255,A=255))
        ColorScale(1)=(RelativeTime=1.000000,Color=(B=255,G=255,R=255,A=255))
        ColorMultiplierRange=(X=(Min=0.400000),Y=(Min=0.000000,Max=0.000000),Z=(Min=0.000000,Max=0.000000))
        Opacity=0.350000
        FadeOutStartTime=1.034000
        FadeInEndTime=0.396000
        CoordinateSystem=PTCS_Relative
        MaxParticles=3
      
        DetailMode=DM_High
        StartLocationRange=(X=(Min=-15.000000,Max=10.000000))
        StartSpinRange=(X=(Max=1.000000))
        SizeScale(0)=(RelativeSize=0.300000)
        SizeScale(1)=(RelativeTime=0.370000,RelativeSize=0.800000)
        SizeScale(2)=(RelativeTime=1.000000,RelativeSize=1.200000)
        StartSizeRange=(X=(Min=5.000000,Max=20.000000),Y=(Min=5.000000,Max=20.000000),Z=(Min=5.000000,Max=20.000000))
        InitialParticlesPerSecond=50000.000000
        Texture=Texture'BWBP_SKC_Tex.BFG.PlasmaSubdivide'
        TextureUSubdivisions=4
        TextureVSubdivisions=2
        LifetimeRange=(Min=1.500000,Max=1.500000)
        StartVelocityRange=(X=(Max=5.000000))
    End Object
     Emitters(2)=SpriteEmitter'BWBP_SKC_Fix.TraceEmitter_LS14RR.SpriteEmitter0'

    Begin Object Class=BeamEmitter Name=BeamEmitter2
        BeamDistanceRange=(Min=100.000000,Max=100.000000)
        DetermineEndPointBy=PTEP_Distance
        UseColorScale=True
        FadeOut=True
        RespawnDeadParticles=False
        UseSizeScale=True
        UseRegularSizeScale=False
        AutomaticInitialSpawning=False
        ColorScale(0)=(Color=(B=255,G=255,R=255,A=255))
        ColorScale(1)=(RelativeTime=1.000000,Color=(B=129,G=128,R=255,A=255))
        ColorMultiplierRange=(Y=(Min=0.000000,Max=0.000000),Z=(Min=0.000000,Max=0.000000))
        FadeOutStartTime=0.025000
        CoordinateSystem=PTCS_Relative
        MaxParticles=1
      
        DetailMode=DM_SuperHigh
        SizeScale(1)=(RelativeTime=0.680000,RelativeSize=0.300000)
        SizeScale(2)=(RelativeTime=1.000000,RelativeSize=1.000000)
        StartSizeRange=(X=(Min=25.000000,Max=25.000000),Y=(Min=25.000000,Max=25.000000),Z=(Min=25.000000,Max=25.000000))
        InitialParticlesPerSecond=50000.000000
        Texture=Texture'BallisticEffects.GunFire.RailCoreWaveCap'
        LifetimeRange=(Min=0.350000,Max=0.350000)
        StartVelocityRange=(X=(Min=1.000000,Max=1.000000))
    End Object
     Emitters(3)=BeamEmitter'BWBP_SKC_Fix.TraceEmitter_LS14RR.BeamEmitter2'

    Begin Object Class=SparkEmitter Name=SparkEmitter0
        LineSegmentsRange=(Min=1.000000,Max=1.000000)
        TimeBetweenSegmentsRange=(Min=0.100000,Max=0.100000)
        UseColorScale=True
        FadeOut=True
        RespawnDeadParticles=False
        AutomaticInitialSpawning=False
        Acceleration=(Z=-200.000000)
        ColorScale(0)=(Color=(B=64,G=192,R=255,A=255))
        ColorScale(1)=(RelativeTime=0.764286,Color=(R=255,A=255))
        ColorScale(2)=(RelativeTime=1.000000,Color=(G=128,R=255,A=255))
        ColorMultiplierRange=(X=(Min=0.800000),Y=(Min=0.800000),Z=(Min=0.800000))
        FadeOutStartTime=0.530000
        CoordinateSystem=PTCS_Relative
      
        DetailMode=DM_SuperHigh
        InitialParticlesPerSecond=50000.000000
        Texture=Texture'BallisticEffects.Particles.HotFlareA1'
        SecondsBeforeInactive=0.000000
        LifetimeRange=(Min=1.000000,Max=1.000000)
        StartVelocityRange=(X=(Min=50.000000,Max=1000.000000),Y=(Min=-200.000000,Max=200.000000),Z=(Min=-200.000000,Max=200.000000))
    End Object
     Emitters(4)=SparkEmitter'BWBP_SKC_Fix.TraceEmitter_LS14RR.SparkEmitter0'

    Begin Object Class=BeamEmitter Name=BeamEmitter3
        BeamDistanceRange=(Min=5000.000000,Max=5000.000000)
        DetermineEndPointBy=PTEP_Distance
        BeamTextureUScale=16.000000
        UseColorScale=True
        FadeOut=True
        RespawnDeadParticles=False
        UseSizeScale=True
        UseRegularSizeScale=False
        AutomaticInitialSpawning=False
        ColorScale(0)=(Color=(B=64,G=192,R=255,A=255))
        ColorScale(1)=(RelativeTime=0.114286,Color=(R=255,A=255))
        ColorScale(2)=(RelativeTime=0.257143,Color=(B=160,G=160,R=160,A=255))
        ColorScale(3)=(RelativeTime=0.521429,Color=(R=200,A=255))
        ColorScale(4)=(RelativeTime=1.000000,Color=(B=255,G=255,R=255,A=255))
        ColorMultiplierRange=(X=(Min=0.800000,Max=0.900000),Y=(Min=0.900000))
        FadeOutStartTime=0.180000
        CoordinateSystem=PTCS_Relative
        MaxParticles=1
      
        SizeScale(0)=(RelativeSize=0.300000)
        SizeScale(1)=(RelativeTime=1.000000,RelativeSize=1.000000)
        StartSizeRange=(X=(Min=4.000000,Max=4.000000),Y=(Min=4.000000,Max=4.000000),Z=(Min=4.000000,Max=4.000000))
        InitialParticlesPerSecond=50000.000000
        DrawStyle=PTDS_Brighten
        Texture=Texture'BWBP_SKC_Tex.BeamCannon.HMCSmokeCore2'
        LifetimeRange=(Min=0.500000,Max=0.700000)
        StartVelocityRange=(X=(Min=1.000000,Max=1.000000))
    End Object
     Emitters(5)=BeamEmitter'BWBP_SKC_Fix.TraceEmitter_LS14RR.BeamEmitter3'

    Begin Object Class=SpriteEmitter Name=SpriteEmitter1
        FadeOut=True
        RespawnDeadParticles=False
        SpinParticles=True
        UniformSize=True
        AutomaticInitialSpawning=False
        ColorScale(0)=(Color=(B=255,G=255,R=255,A=255))
        ColorScale(1)=(RelativeTime=1.000000,Color=(B=255,G=255,R=255,A=255))
        ColorMultiplierRange=(X=(Min=0.700000,Max=0.800000),Y=(Min=0.100000,Max=0.200000),Z=(Min=0.800000))
        Opacity=0.530000
        FadeOutStartTime=0.525000
        CoordinateSystem=PTCS_Relative
        MaxParticles=100
      
        SpinsPerSecondRange=(X=(Max=4.000000))
        StartSpinRange=(X=(Max=1.000000))
        StartSizeRange=(X=(Min=2.000000,Max=4.500000),Y=(Min=2.000000,Max=4.500000),Z=(Min=2.000000,Max=4.500000))
        InitialParticlesPerSecond=50000.000000
        Texture=Texture'BWBP_SKC_Tex.BFG.PlasmaSubdivide'
        TextureUSubdivisions=4
        TextureVSubdivisions=2
        SecondsBeforeInactive=0.000000
        LifetimeRange=(Min=0.625000,Max=0.625000)
        StartVelocityRange=(X=(Max=8000.000000))
    End Object
     Emitters(6)=SpriteEmitter'BWBP_SKC_Fix.TraceEmitter_LS14RR.SpriteEmitter1'



    Begin Object Class=BeamEmitter Name=BeamEmitter4
        BeamDistanceRange=(Min=512.000000,Max=512.000000)
        DetermineEndPointBy=PTEP_Distance
        RotatingSheets=3
        LowFrequencyPoints=2
        HighFrequencyPoints=2
        BranchProbability=(Max=1.000000)
        BranchSpawnAmountRange=(Max=2.000000)
        UseColorScale=True
        RespawnDeadParticles=False
        AlphaTest=False
        UseSizeScale=True
        UseRegularSizeScale=False
        AutomaticInitialSpawning=False
        ColorScale(0)=(Color=(B=32,G=32,R=192))
        ColorScale(1)=(RelativeTime=0.800000,Color=(B=128,G=128,R=255))
        ColorScale(2)=(RelativeTime=1.000000)
        MaxParticles=1
      
        UseRotationFrom=PTRS_Actor
        SizeScale(0)=(RelativeSize=1.000000)
        SizeScale(1)=(RelativeTime=1.000000,RelativeSize=0.500000)
        StartSizeRange=(X=(Min=40.000000,Max=40.000000),Y=(Min=20.000000,Max=20.000000))
        InitialParticlesPerSecond=5000.000000
        Texture=Texture'TurretParticles.Beams.TurretBeam5'
        LifetimeRange=(Min=0.150000,Max=0.150000)
        StartVelocityRange=(X=(Min=500.000000,Max=500.000000))
    End Object
    Emitters(7)=BeamEmitter'BWBP_SKC_Fix.TraceEmitter_LS14RR.BeamEmitter4'

    Begin Object Class=BeamEmitter Name=BeamEmitter5
        BeamDistanceRange=(Min=512.000000,Max=512.000000)
        DetermineEndPointBy=PTEP_Distance
        RotatingSheets=3
        LowFrequencyPoints=2
        HighFrequencyPoints=2
        BranchProbability=(Max=1.000000)
        BranchSpawnAmountRange=(Max=2.000000)
        UseColorScale=True
        RespawnDeadParticles=False
        AlphaTest=False
        UseSizeScale=True
        UseRegularSizeScale=False
        AutomaticInitialSpawning=False
        ColorScale(0)=(Color=(B=64,G=64,R=255))
        ColorScale(1)=(RelativeTime=0.800000,Color=(B=255,R=255))
        ColorScale(2)=(RelativeTime=1.000000)
        Opacity=0.800000
        MaxParticles=1
      
        UseRotationFrom=PTRS_Actor
        SizeScale(0)=(RelativeSize=1.000000)
        SizeScale(1)=(RelativeTime=1.000000)
        StartSizeRange=(Y=(Min=20.000000,Max=20.000000))
        InitialParticlesPerSecond=5000.000000
        Texture=Texture'EpicParticles.Flares.SoftFlare'
        LifetimeRange=(Min=0.500000,Max=0.500000)
        StartVelocityRange=(X=(Min=500.000000,Max=500.000000))
    End Object
    Emitters(8)=BeamEmitter'BWBP_SKC_Fix.TraceEmitter_LS14RR.BeamEmitter5'

    Begin Object Class=SpriteEmitter Name=SpriteEmitter12
        UseDirectionAs=PTDU_Normal
        ProjectionNormal=(X=1.000000,Z=0.000000)
        UseColorScale=True
        RespawnDeadParticles=False
        SpinParticles=True
        UseSizeScale=True
        UseRegularSizeScale=False
        UniformSize=True
        AutomaticInitialSpawning=False
        ColorScale(0)=(Color=(B=128,G=128,R=255))
        ColorScale(1)=(RelativeTime=1.000000,Color=(B=64,G=64,R=255))
        MaxParticles=2
      
        UseRotationFrom=PTRS_Actor
        StartSpinRange=(X=(Max=1.000000))
        SizeScale(0)=(RelativeSize=1.000000)
        SizeScale(1)=(RelativeTime=1.000000)
        StartSizeRange=(X=(Min=150.000000,Max=200.000000))
        InitialParticlesPerSecond=20.000000
        Texture=Texture'AW-2004Particles.Weapons.PlasmaStar2'
        LifetimeRange=(Min=0.200000,Max=0.200000)
    End Object
    Emitters(9)=SpriteEmitter'BWBP_SKC_Fix.TraceEmitter_LS14RR.SpriteEmitter12'

    Begin Object Class=SpriteEmitter Name=SpriteEmitter13
        UseColorScale=True
        RespawnDeadParticles=False
        UseSizeScale=True
        UseRegularSizeScale=False
        UniformSize=True
        AutomaticInitialSpawning=False
        BlendBetweenSubdivisions=True
        UseRandomSubdivision=True
        Acceleration=(X=15.000000,Y=15.000000,Z=15.000000)
        ColorScale(0)=(Color=(B=128,G=128,R=255))
        ColorScale(1)=(RelativeTime=0.646429,Color=(G=23,R=132))
        ColorScale(2)=(RelativeTime=1.000000)
        ColorMultiplierRange=(Y=(Min=0.000000,Max=0.000000))
        MaxParticles=8
      
        StartLocationOffset=(X=16.000000)
        StartLocationRange=(X=(Max=64.000000),Z=(Max=2.000000))
        UseRotationFrom=PTRS_Actor
        StartSpinRange=(X=(Max=0.025000))
        SizeScale(0)=(RelativeSize=0.250000)
        SizeScale(1)=(RelativeTime=1.000000,RelativeSize=1.000000)
        StartSizeRange=(X=(Min=20.000000,Max=50.000000))
        InitialParticlesPerSecond=900.000000
        Texture=Texture'BWBP_SKC_Tex.BFG.PlasmaSubdivide'
        TextureUSubdivisions=4
        TextureVSubdivisions=2
        LifetimeRange=(Min=1.000000,Max=1.000000)
        StartVelocityRange=(X=(Min=-15.000000,Max=15.000000),Y=(Min=-15.000000,Max=15.000000),Z=(Min=-15.000000,Max=15.000000))
        WarmupTicksPerSecond=1.000000
        RelativeWarmupTime=0.200000
    End Object
    Emitters(10)=SpriteEmitter'BWBP_SKC_Fix.TraceEmitter_LS14RR.SpriteEmitter13'

    Begin Object Class=SpriteEmitter Name=SpriteEmitter14
        UseColorScale=True
        RespawnDeadParticles=False
        UseSizeScale=True
        UseRegularSizeScale=False
        UniformSize=True
        AutomaticInitialSpawning=False
        BlendBetweenSubdivisions=True
        UseRandomSubdivision=True
        ColorScale(0)=(Color=(B=32,G=32,R=255))
        ColorScale(1)=(RelativeTime=0.100000,Color=(B=32,G=32,R=255))
        ColorScale(2)=(RelativeTime=0.800000,Color=(B=64,G=64,R=255))
        ColorScale(3)=(RelativeTime=1.000000)
        ColorMultiplierRange=(Y=(Min=0.000000,Max=0.000000))
        MaxParticles=3
      
        StartLocationOffset=(X=10.000000)
        StartLocationRange=(X=(Max=20.000000))
        UseRotationFrom=PTRS_Actor
        SizeScale(0)=(RelativeSize=0.100000)
        SizeScale(1)=(RelativeTime=1.000000,RelativeSize=1.000000)
        StartSizeRange=(X=(Min=40.000000,Max=60.000000))
        InitialParticlesPerSecond=2000.000000
        Texture=Texture'BWBP_SKC_Tex.BFG.PlasmaSubdivide'
        TextureUSubdivisions=4
        TextureVSubdivisions=2
        LifetimeRange=(Min=0.200000,Max=0.200000)
    End Object
    Emitters(11)=SpriteEmitter'BWBP_SKC_Fix.TraceEmitter_LS14RR.SpriteEmitter14'



}
