//=============================================================================
// A73FlashEmitter.
//
// by Nolan "Dark Carnivour" Richert.
// Copyright(c) 2005 RuneStorm. All Rights Reserved.
//=============================================================================
class HMCFlashEmitter extends BallisticEmitter;

defaultproperties
{
     Emitters(0)=SpriteEmitter'BallisticFix.RSNovaSlowMuzzleFlash.SpriteEmitter9'

     Emitters(1)=SpriteEmitter'BallisticFix.RSNovaSlowMuzzleFlash.SpriteEmitter10'

     Begin Object Class=SpriteEmitter Name=SpriteEmitter26
         UseColorScale=True
         FadeOut=True
         FadeIn=True
         RespawnDeadParticles=False
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         AutomaticInitialSpawning=False
         UseRandomSubdivision=True
         TriggerDisabled=False
         ColorScale(0)=(Color=(B=255,G=180,R=160,A=255))
         ColorScale(1)=(RelativeTime=0.300000,Color=(B=91,G=91,R=91,A=255))
         ColorScale(2)=(RelativeTime=1.000000,Color=(B=255,G=255,R=255,A=255))
         Opacity=0.860000
         FadeOutStartTime=1.020000
         FadeInEndTime=0.560000
         MaxParticles=40
         StartLocationRange=(X=(Min=-30.000000))
         SpinsPerSecondRange=(X=(Max=0.150000))
         StartSpinRange=(X=(Max=1.000000))
         SizeScale(0)=(RelativeSize=2.000000)
         SizeScale(1)=(RelativeTime=0.620000,RelativeSize=3.500000)
         SizeScale(2)=(RelativeTime=1.000000,RelativeSize=5.000000)
         StartSizeRange=(X=(Min=6.000000,Max=8.000000),Y=(Min=6.000000,Max=8.000000),Z=(Min=6.000000,Max=8.000000))
         DrawStyle=PTDS_AlphaBlend
         Texture=Texture'BallisticEffects2.Particles.SmokeWisp-Alpha'
         TextureUSubdivisions=4
         TextureVSubdivisions=2
         SecondsBeforeInactive=0.000000
         LifetimeRange=(Min=2.000000,Max=2.000000)
         SpawnOnTriggerRange=(Min=4.000000,Max=6.000000)
         SpawnOnTriggerPPS=20.000000
         StartVelocityRange=(X=(Min=-5.000000,Max=5.000000),Y=(Min=-5.000000,Max=5.000000),Z=(Min=50.000000,Max=65.000000))
     End Object
     Emitters(2)=SpriteEmitter'BWBP_SKC_Fix.HMCFlashEmitter.SpriteEmitter26'

     bNoDelete=False
}
