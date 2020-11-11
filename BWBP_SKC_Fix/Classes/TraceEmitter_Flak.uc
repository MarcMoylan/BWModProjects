//=============================================================================
// TraceEmitter_Flak.
//
// by Herr General
// Copyright(c) 2005 RuneStorm. All Rights Reserved.
//=============================================================================
class TraceEmitter_Flak extends BallisticEmitter;

simulated event PostBeginPlay()
{
	Super.PostBeginPlay();
	if (WeaponAttachment(Owner) != None)
		Emitters[1].ZTest = true;
}

defaultproperties
{
    Begin Object Class=SparkEmitter Name=SparkEmitter0
        LineSegmentsRange=(Min=1.000000,Max=1.000000)
        TimeBetweenSegmentsRange=(Min=0.010000,Max=0.050000)
        UseCollision=True
        UseMaxCollisions=True
        UseColorScale=True
        FadeOut=True
        RespawnDeadParticles=False
        AutomaticInitialSpawning=False
        Acceleration=(Z=-100.000000)
        MaxCollisions=(Min=1.000000,Max=1.000000)
        ColorScale(0)=(Color=(B=255,G=255,R=255,A=255))
        ColorScale(1)=(RelativeTime=0.510714,Color=(G=200,R=255,A=255))
        ColorScale(2)=(RelativeTime=1.000000,Color=(G=64,R=255,A=255))
        FadeOutStartTime=0.110000
        CoordinateSystem=PTCS_Relative
        MaxParticles=50
      
        StartSizeRange=(X=(Min=10.000000,Max=10.000000),Y=(Min=10.000000,Max=10.000000),Z=(Min=10.000000,Max=10.000000))
        InitialParticlesPerSecond=50000.000000
        Texture=Texture'BallisticEffects.Particles.HotFlareA1'
        SecondsBeforeInactive=0.000000
        LifetimeRange=(Min=1.000000,Max=1.000000)
        StartVelocityRange=(X=(Min=100.000000,Max=4000.000000),Y=(Min=-100.000000,Max=100.000000),Z=(Min=-100.000000,Max=200.000000))
    End Object
    Emitters(0)=SparkEmitter'BWBP_SKC_Fix.TraceEmitter_Flak.SparkEmitter0'

    Begin Object Class=MeshEmitter Name=MeshEmitter10
        StaticMesh=StaticMesh'BallisticHardware2.Effects.VBlast'
        UseMeshBlendMode=False
        RenderTwoSided=True
        UseParticleColor=True
        FadeOut=True
        FadeIn=True
        RespawnDeadParticles=False
        SpinParticles=True
        UseSizeScale=True
        UseRegularSizeScale=False
        AutomaticInitialSpawning=False
        ColorScale(0)=(Color=(B=255,G=255,R=255,A=255))
        ColorScale(1)=(RelativeTime=1.000000,Color=(B=255,G=255,R=255,A=255))
        Opacity=0.320000
        FadeOutStartTime=0.045000
        FadeInEndTime=0.010000
        CoordinateSystem=PTCS_Relative
        MaxParticles=5
      
        StartSpinRange=(Y=(Min=-0.250000,Max=-0.250000))
        SizeScale(1)=(RelativeTime=0.560000,RelativeSize=0.800000)
        SizeScale(2)=(RelativeTime=1.000000,RelativeSize=1.000000)
        StartSizeRange=(X=(Min=0.500000,Max=1.200000),Y=(Min=0.500000,Max=1.200000),Z=(Min=2.000000,Max=8.000000))
        InitialParticlesPerSecond=50000.000000
        DrawStyle=PTDS_Brighten
        SecondsBeforeInactive=0.000000
        LifetimeRange=(Min=0.200000,Max=0.300000)
        StartVelocityRange=(X=(Min=100.000000,Max=300.000000))
    End Object
    Emitters(1)=MeshEmitter'BWBP_SKC_Fix.TraceEmitter_Flak.MeshEmitter10'

    Begin Object Class=SpriteEmitter Name=SpriteEmitter75
        FadeOut=True
        FadeIn=True
        RespawnDeadParticles=False
        UniformSize=True
        UseRandomSubdivision=True
        ColorScale(0)=(Color=(B=255,G=255,R=255,A=255))
        ColorScale(1)=(RelativeTime=1.000000,Color=(B=255,G=255,R=255,A=255))
        ColorMultiplierRange=(X=(Min=0.000000,Max=0.000000),Y=(Min=0.000000,Max=0.000000),Z=(Min=0.000000,Max=0.000000))
        Opacity=0.600000
        FadeOutStartTime=0.050000
        FadeInEndTime=0.004000
        MaxParticles=2
      
        StartLocationRange=(X=(Min=-5.000000,Max=5.000000),Y=(Min=-5.000000,Max=5.000000),Z=(Min=-5.000000,Max=5.000000))
        StartSizeRange=(X=(Min=20.000000,Max=20.000000),Y=(Min=20.000000,Max=20.000000),Z=(Min=20.000000,Max=20.000000))
        DrawStyle=PTDS_AlphaBlend
        Texture=Texture'BallisticEffects2.Particles.SmokeWisp-Alpha'
        TextureUSubdivisions=4
        TextureVSubdivisions=2
        LifetimeRange=(Min=0.400000,Max=0.400000)
    End Object
    Emitters(2)=SpriteEmitter'BWBP_SKC_Fix.TraceEmitter_Flak.SpriteEmitter75'

    Begin Object Class=BeamEmitter Name=BeamEmitter1
        BeamDistanceRange=(Min=600.000000,Max=900.000000)
        DetermineEndPointBy=PTEP_Distance
        HighFrequencyNoiseRange=(X=(Min=-5.000000,Max=5.000000),Y=(Min=-5.000000,Max=5.000000),Z=(Min=-5.000000,Max=5.000000))
        HighFrequencyPoints=5
        UseBranching=True
        BranchProbability=(Min=1.000000,Max=1.000000)
        BranchEmitter=0
        BranchSpawnAmountRange=(Min=4.000000,Max=4.000000)
        FadeOut=True
        RespawnDeadParticles=False
        AutomaticInitialSpawning=False
        ColorScale(0)=(Color=(R=255,A=255))
        ColorScale(1)=(RelativeTime=1.000000,Color=(A=255))
        Opacity=0.500000
        FadeOutStartTime=0.110600
        CoordinateSystem=PTCS_Relative
        MaxParticles=15
      
        StartSizeRange=(X=(Min=3.000000,Max=3.000000),Y=(Min=3.000000,Max=3.000000),Z=(Min=3.000000,Max=3.000000))
        InitialParticlesPerSecond=5000.000000
        DrawStyle=PTDS_AlphaBlend
        Texture=Texture'BallisticEffects.Particles.WaterSpray1Alpha'
        LifetimeRange=(Min=0.269000,Max=0.269000)
        StartVelocityRange=(X=(Min=70.000000,Max=70.000000),Y=(Min=-10.000000,Max=10.000000),Z=(Min=-10.000000,Max=10.000000))
    End Object
    Emitters(3)=BeamEmitter'BWBP_SKC_Fix.TraceEmitter_Flak.BeamEmitter1'

    Begin Object Class=SpriteEmitter Name=SpriteEmitter76
        UseColorScale=True
        FadeOut=True
        RespawnDeadParticles=False
        SpinParticles=True
        UseSizeScale=True
        UniformSize=True
        AutomaticInitialSpawning=False
        DampingFactorRange=(X=(Min=0.500000,Max=0.500000),Y=(Min=0.500000,Max=0.500000),Z=(Min=0.500000,Max=0.500000))
        ColorScale(0)=(Color=(B=255,G=255,R=255,A=255))
        ColorScale(1)=(RelativeTime=0.792857,Color=(G=155,R=255,A=255))
        ColorScale(2)=(RelativeTime=1.000000,Color=(G=150,R=255,A=255))
        FadeOutStartTime=0.060000
        CoordinateSystem=PTCS_Relative
        MaxParticles=50
      
        SpinsPerSecondRange=(X=(Min=0.050000,Max=0.100000),Y=(Min=0.050000,Max=0.100000),Z=(Min=0.050000,Max=0.100000))
        StartSpinRange=(X=(Max=1.000000),Y=(Max=1.000000),Z=(Max=1.000000))
        StartSizeRange=(X=(Min=2.000000,Max=2.000000),Y=(Min=2.000000,Max=2.000000),Z=(Min=2.000000,Max=2.000000))
        InitialParticlesPerSecond=5000.000000
        Texture=Texture'BallisticEffects.Particles.Smoke5'
        LifetimeRange=(Min=0.700000,Max=1.000000)
        StartVelocityRange=(X=(Min=300.000000,Max=6000.000000),Y=(Min=-200.000000,Max=200.000000),Z=(Min=-200.000000,Max=200.000000))
        VelocityLossRange=(X=(Min=4.000000,Max=5.000000),Y=(Min=4.000000,Max=5.000000),Z=(Min=4.000000,Max=5.000000))
    End Object
    Emitters(4)=SpriteEmitter'BWBP_SKC_Fix.TraceEmitter_Flak.SpriteEmitter76'


     bNoDelete=False
}
