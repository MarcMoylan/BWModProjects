//=============================================================================
// TraceEmitter_RedPulse. Uses a different static mesh.
//
// by Nolan "Dark Carnivour" Richert.
// Copyright(c) 2005 RuneStorm. All Rights Reserved.
//=============================================================================
class TraceEmitter_RedPulse extends BCTraceEmitter;

defaultproperties
{
     Begin Object Class=MeshEmitter Name=MeshEmitter0
         StaticMesh=StaticMesh'BWBP_SKC_Static.LaserCarbine.TracerA3'
         UseMeshBlendMode=False
         RenderTwoSided=True
         UseParticleColor=True
         RespawnDeadParticles=False
         SpinParticles=True
         AutomaticInitialSpawning=False
         TriggerDisabled=False
//         ColorMultiplierRange=(X=(Min=0.100000,Max=0.200000),Y=(Min=0.200000,Max=0.300000))
         Opacity=3.250000
         CoordinateSystem=PTCS_Relative
         MaxParticles=1
         SpinsPerSecondRange=(Z=(Min=2.000000,Max=4.000000))
         StartSizeRange=(X=(Min=2.300000,Max=2.350000),Y=(Min=0.300000,Max=0.350000),Z=(Min=0.800000,Max=0.850000))
         InitialParticlesPerSecond=50000.000000
         SecondsBeforeInactive=0.000000
         LifetimeRange=(Min=2.000000,Max=2.000000)
         StartVelocityRange=(X=(Min=7000.000000,Max=7000.000000))
     End Object
     Emitters(0)=MeshEmitter'BWBP_SKC_Fix.TraceEmitter_RedPulse.MeshEmitter0'

}
