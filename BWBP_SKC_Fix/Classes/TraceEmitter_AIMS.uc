//=============================================================================
// TraceEmitter_AIMS. Many tracers.
//
// by Nolan "Dark Carnivour" Richert.
// Copyright(c) 2005 RuneStorm. All Rights Reserved.
//=============================================================================
class TraceEmitter_AIMS extends BCTraceEmitter;

defaultproperties
{
    Begin Object Class=MeshEmitter Name=MeshEmitter1
        StaticMesh=StaticMesh'BallisticHardware2.Effects.TracerA1'
        UseMeshBlendMode=False
        RenderTwoSided=True
        RespawnDeadParticles=False
        SpinParticles=True
        AutomaticInitialSpawning=False
        TriggerDisabled=False
        ColorScale(0)=(Color=(B=255,G=255,R=255,A=255))
        ColorScale(1)=(RelativeTime=1.000000,Color=(B=255,G=255,R=255,A=255))
        ColorMultiplierRange=(X=(Min=0.500000,Max=0.500000),Y=(Min=0.500000,Max=0.500000))
        Opacity=1.000000
        CoordinateSystem=PTCS_Relative
        MaxParticles=1
      
        SpinsPerSecondRange=(Z=(Min=2.000000,Max=4.000000))
        StartSizeRange=(X=(Min=0.500000),Y=(Min=0.200000,Max=0.250000),Z=(Min=0.200000,Max=0.250000))
        InitialParticlesPerSecond=50000.000000
        SecondsBeforeInactive=0.000000
        LifetimeRange=(Min=2.000000,Max=2.000000)
        StartVelocityRange=(X=(Min=8000.000000,Max=8000.000000))
    End Object
     Emitters(0)=MeshEmitter'BWBP_SKC_Fix.TraceEmitter_AIMS.MeshEmitter1'

    Begin Object Class=MeshEmitter Name=MeshEmitter2
        StaticMesh=StaticMesh'BallisticHardware2.Effects.TracerA1'
        UseMeshBlendMode=False
        RenderTwoSided=True
        RespawnDeadParticles=False
        SpinParticles=True
        AutomaticInitialSpawning=False
        TriggerDisabled=False
        ColorScale(0)=(Color=(B=255,G=255,R=255,A=255))
        ColorScale(1)=(RelativeTime=1.000000,Color=(B=255,G=255,R=255,A=255))
        ColorMultiplierRange=(X=(Min=0.500000,Max=0.500000),Y=(Min=0.500000,Max=0.500000))
        Opacity=1.000000
        CoordinateSystem=PTCS_Relative
        MaxParticles=5
      
        StartLocationRange=(X=(Min=-100.000000,Max=100.000000),Y=(Min=-20.000000,Max=20.000000),Z=(Min=-40.000000,Max=0.000000))
        SpinsPerSecondRange=(Z=(Min=2.000000,Max=4.000000))
        StartSizeRange=(X=(Min=0.500000),Y=(Min=0.200000,Max=0.250000),Z=(Min=0.200000,Max=0.250000))
        InitialParticlesPerSecond=50000.000000
        SecondsBeforeInactive=0.000000
        LifetimeRange=(Min=2.000000,Max=2.000000)
        StartVelocityRange=(X=(Min=5000.000000,Max=8000.000000))
    End Object
     Emitters(1)=MeshEmitter'BWBP_SKC_Fix.TraceEmitter_AIMS.MeshEmitter2'

}
