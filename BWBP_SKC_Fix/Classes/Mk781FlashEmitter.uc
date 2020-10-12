//=============================================================================
// Mk781FlashEmitter.
//
// by Nolan "Dark Carnivour" Richert.
// Copyright(c) 2005 RuneStorm. All Rights Reserved.
//=============================================================================
class Mk781FlashEmitter extends BallisticEmitter;

simulated event PostBeginPlay()
{
	Super.PostBeginPlay();
	if (!class'BallisticMod'.default.bMuzzleSmoke)	{
		Emitters[3].Disabled = true;
	}
	if (WeaponAttachment(Owner) != None)
	{
		Emitters[2].ZTest = true;
		Emitters[3].disabled = true;
	}
}


defaultproperties
{

     Emitters(0)=SpriteEmitter'BallisticFix.MRT6FlashEmitter.SpriteEmitter37'


     Emitters(1)=MeshEmitter'BallisticFix.MRT6FlashEmitter.MeshEmitter10'

     Emitters(2)=SpriteEmitter'BallisticFix.MRT6FlashEmitter.SpriteEmitter18'

     Emitters(3)=TrailEmitter'BallisticFix.MRT6FlashEmitter.TrailEmitter1'

     Begin Object Class=SpriteEmitter Name=SpriteEmitter20
         UseDirectionAs=PTDU_Up
         UseColorScale=True
         FadeOut=True
         FadeIn=True
         RespawnDeadParticles=False
         SpinParticles=True
         UniformSize=True
         AutomaticInitialSpawning=False
         UseRandomSubdivision=True
         TriggerDisabled=False
    	ColorScale(0)=(Color=(B=192,G=224,R=255,A=255))
    	ColorScale(1)=(RelativeTime=0.150000,Color=(B=192,G=192,R=192,A=255))
    	ColorScale(2)=(RelativeTime=1.000000,Color=(G=128,R=255,A=255))
         FadeOutStartTime=0.017500
         FadeInEndTime=0.010000
         CoordinateSystem=PTCS_Relative
         MaxParticles=20
         StartSpinRange=(X=(Min=0.250000,Max=0.250000))
         StartSizeRange=(X=(Min=15.000000,Max=20.000000),Y=(Min=15.000000,Max=20.000000),Z=(Min=15.000000,Max=20.000000))
         Texture=Texture'BallisticWeapons2.Effects.SparkA1'
         TextureUSubdivisions=2
         TextureVSubdivisions=2
         SecondsBeforeInactive=0.000000
         LifetimeRange=(Min=0.250000,Max=0.250000)
         SpawnOnTriggerRange=(Min=16.000000,Max=20.000000)
         SpawnOnTriggerPPS=50000.000000
         StartVelocityRange=(X=(Min=200.000000,Max=2000.000000),Y=(Min=-200.000000,Max=200.000000),Z=(Min=-200.000000,Max=200.000000))
     End Object
     Emitters(4)=SpriteEmitter'BWBP_SKC_Fix.Mk781FlashEmitter.SpriteEmitter20'

     bNoDelete=False
}
