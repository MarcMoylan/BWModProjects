//=============================================================================
// IE_BulletGrass.
//
// by Nolan "Dark Carnivour" Richert.
// Copyright(c) 2005 RuneStorm. All Rights Reserved.
//=============================================================================
class IE_IncBulletGrass extends DGVEmitter
	placeable;

simulated event PostBeginPlay()
{
	if ( PhysicsVolume.bWaterVolume )
	{
		Emitters[1].Acceleration.Z = 50.0;
		Emitters[1].VelocityLossRange.X.Min=0.500000;
		Emitters[1].VelocityLossRange.X.Max=0.500000;
		Emitters[1].VelocityLossRange.Y.Min=0.500000;
		Emitters[1].VelocityLossRange.Y.Max=0.500000;
		Emitters[1].VelocityLossRange.Z.Min=0.500000;
		Emitters[1].VelocityLossRange.Z.Max=0.500000;
		Emitters[2].Acceleration.Z = 50.0;
		Emitters[2].VelocityLossRange.X.Min=1.000000;
		Emitters[2].VelocityLossRange.X.Max=1.000000;
		Emitters[2].VelocityLossRange.Y.Min=1.000000;
		Emitters[2].VelocityLossRange.Y.Max=1.000000;
		Emitters[2].VelocityLossRange.Z.Min=1.000000;
		Emitters[2].VelocityLossRange.Z.Max=1.000000;
	}
	super.PostBeginPlay();
}

defaultproperties
{
     DisableDGV(1)=1
     bModifyLossRange=False
     Emitters(0)=SpriteEmitter'BallisticFix.IE_BulletGrass.SpriteEmitter30'

     Emitters(1)=MeshEmitter'BallisticFix.IE_BulletGrass.MeshEmitter15'

     Emitters(2)=SpriteEmitter'BallisticFix.IE_BulletGrass.SpriteEmitter31'

     Begin Object Class=SpriteEmitter Name=SpriteEmitter12
         UseColorScale=True
         FadeOut=True
         RespawnDeadParticles=False
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         AutomaticInitialSpawning=False
         UseRandomSubdivision=True
         Acceleration=(Z=-5.000000)
         ColorScale(0)=(Color=(B=192,G=255,R=255,A=255))
         ColorScale(1)=(RelativeTime=0.220000,Color=(B=255,G=255,R=255,A=255))
         ColorScale(2)=(RelativeTime=0.350000,Color=(B=255,G=255,R=255,A=255))
         ColorScale(3)=(RelativeTime=1.000000,Color=(B=255,G=254,R=255,A=255))
         ColorMultiplierRange=(X=(Min=5.500000,Max=0.600000),Z=(Min=0.400000,Max=0.400000))
         FadeOutStartTime=0.150000
         MaxParticles=5
         SpinsPerSecondRange=(X=(Max=0.100000))
         StartSpinRange=(X=(Min=0.450000,Max=0.550000))
         SizeScale(1)=(RelativeTime=1.000000,RelativeSize=1.200000)
         StartSizeRange=(X=(Min=6.000000,Max=6.000000),Y=(Min=6.000000,Max=6.000000),Z=(Min=6.000000,Max=6.000000))
         InitialParticlesPerSecond=50000.000000
         Texture=Texture'BallisticEffects.Particles.BlazingSubdivide'
         TextureUSubdivisions=4
         TextureVSubdivisions=2
         SecondsBeforeInactive=0.000000
         LifetimeRange=(Min=0.500000,Max=0.500000)
     End Object
     Emitters(3)=SpriteEmitter'BWBP_SKC_Fix.IE_IncBulletGrass.SpriteEmitter12'

     Begin Object Class=SpriteEmitter Name=SpriteEmitter14
         FadeOut=True
         RespawnDeadParticles=False
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         AutomaticInitialSpawning=False
         UseRandomSubdivision=True
         ColorScale(0)=(Color=(B=255,G=255,R=255,A=255))
         ColorScale(1)=(RelativeTime=1.000000,Color=(B=255,G=255,R=255,A=255))
         ColorMultiplierRange=(X=(Min=0.800000,Max=0.800000),Y=(Min=0.300000,Max=0.300000),Z=(Min=0.200000,Max=0.200000))
         FadeOutStartTime=0.100000
         MaxParticles=1
         StartSpinRange=(X=(Max=1.000000))
         SizeScale(1)=(RelativeTime=1.000000,RelativeSize=2.000000)
         StartSizeRange=(X=(Min=6.500000,Max=6.500000),Y=(Min=6.500000,Max=6.500000),Z=(Min=6.500000,Max=6.500000))
         InitialParticlesPerSecond=50000.000000
         Texture=Texture'BallisticEffects.Particles.FlameParts'
         TextureUSubdivisions=4
         TextureVSubdivisions=4
         SecondsBeforeInactive=0.000000
         LifetimeRange=(Min=0.400000,Max=0.400000)
     End Object
     Emitters(4)=SpriteEmitter'BWBP_SKC_Fix.IE_IncBulletGrass.SpriteEmitter14'

     AutoDestroy=True
}
