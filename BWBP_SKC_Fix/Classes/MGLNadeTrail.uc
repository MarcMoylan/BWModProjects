//-----------------------------------------------------------
//Rocket Trail for Tarntula rocket projectile
//-----------------------------------------------------------
class MGLNadeTrail extends BallisticEmitter;

#exec OBJ LOAD FILE=AS_FX_TX.utx

defaultproperties
{

	Begin Object Class=SpriteEmitter Name=SpriteEmitter0
    FadeOut=True
    SpinParticles=True
    UniformSize=True
    AutomaticInitialSpawning=False
    ColorScale(0)=(Color=(G=255,R=255,A=255))
    ColorScale(1)=(RelativeTime=1.000000,Color=(G=128,R=196,A=255))
    ColorMultiplierRange=(Y=(Min=0.000000,Max=0.000000),Z=(Min=0.000000,Max=0.000000))
    FadeOutStartTime=0.160400
    CoordinateSystem=PTCS_Relative
    MaxParticles=1
    Name="SpriteEmitter0"
    SpinsPerSecondRange=(X=(Min=0.300000,Max=0.300000))
    StartSpinRange=(X=(Max=1.000000))
    StartSizeRange=(X=(Min=5.000000,Max=5.000000),Y=(Min=5.000000,Max=5.000000),Z=(Min=5.000000,Max=5.000000))
    InitialParticlesPerSecond=1.000000
    Texture=Texture'BallisticEffects.Particles.FlareA1'
    LifetimeRange=(Min=0.401000,Max=0.401000)
     End Object
     Emitters(0)=SpriteEmitter'BWBP_SKC_Fix.MGLNadeTrail.SpriteEmitter0'


     Begin Object Class=TrailEmitter Name=TrailEmitter0
         TrailShadeType=PTTST_Linear
         TrailLocation=PTTL_FollowEmitter
         MaxPointsPerTrail=350
         DistanceThreshold=30.000000
         PointLifeTime=0.100000
         AutomaticInitialSpawning=False
         MaxParticles=1
    	 ColorMultiplierRange=(Y=(Min=0.000000,Max=0.000000),Z=(Min=0.000000,Max=0.000000))
         StartSizeRange=(X=(Min=1.000000,Max=1.000000))
         InitialParticlesPerSecond=500000.000000
    	 Texture=Texture'BallisticEffects.Particles.FlareA1'
         SecondsBeforeInactive=0.000000
         LifetimeRange=(Min=999999.000000,Max=999999.000000)
     End Object
     Emitters(1)=TrailEmitter'BWBP_SKC_Fix.MGLNadeTrail.TrailEmitter0'
	/*
     Begin Object Class=TrailEmitter Name=TrailEmitter1
         TrailShadeType=PTTST_PointLife
         TrailLocation=PTTL_FollowEmitter
         MaxPointsPerTrail=1000
         DistanceThreshold=1000.000000
         PointLifeTime=0.100000
         FadeOut=True
         UniformSize=True
         AutomaticInitialSpawning=False
         ColorMultiplierRange=(X=(Min=1.000000,Max=1.000000),Y=(Min=0.000000,Max=0.000000),Z=(Min=0.000000,Max=0.000000))
         Opacity=0.400000
         FadeOutStartTime=0.100000
         MaxParticles=1
         DetailMode=DM_SuperHigh
         SizeScale(1)=(RelativeTime=0.550000,RelativeSize=1.200000)
         SizeScale(2)=(RelativeTime=1.500000,RelativeSize=5.000000)
         StartSizeRange=(X=(Min=5.000000,Max=5.000000))
         InitialParticlesPerSecond=500000.000000
         Texture=Texture'BWBP_SKC_Tex.A73b.FlareB1'
         SecondsBeforeInactive=0.000000
         LifetimeRange=(Min=6.000000,Max=6.000000)
     End Object
     Emitters(1)=TrailEmitter'BWBP_SKC_Fix.MGLNadeTrail.TrailEmitter1'
	*/

//     AutoDestroy=True
     bNoDelete=False
     Physics=PHYS_Trailer
     bHardAttach=True
//     bDirectional=True
}
