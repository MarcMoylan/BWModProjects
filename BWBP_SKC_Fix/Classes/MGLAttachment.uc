class MGLAttachment extends BallisticAttachment;

defaultproperties
{
     MuzzleFlashClass=Class'BallisticFix.M50FlashEmitter'
     AltMuzzleFlashClass=Class'BallisticFix.M50FlashEmitter'
     ImpactManager=Class'BallisticFix.IM_Bullet'
     BrassClass=Class'BWBP_SKC_Fix.Brass_Longhorn'
     BrassMode=MU_None
     InstantMode=MU_Both
     FlashMode=MU_Both
     LightMode=MU_Both
     TracerClass=Class'BallisticFix.TraceEmitter_Default'
     TracerMix=-3
     WaterTracerClass=Class'BallisticFix.TraceEmitter_WaterBullet'
     WaterTracerMode=MU_Both
     FlyBySound=(Sound=SoundGroup'BallisticSounds2.FlyBys.Bullet-Whizz',Volume=0.700000)
     ReloadAnim="Reload_AR"
     ReloadAnimRate=0.500000
     bRapidFire=True
     bAltRapidFire=True
     Mesh=SkeletalMesh'BWBP_SKC_AnimExp.Conqueror_TP'
     RelativeRotation=(Pitch=32768)
     DrawScale=0.300000
}