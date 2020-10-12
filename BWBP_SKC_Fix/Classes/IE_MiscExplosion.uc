//===============================
//Butts
//
//================================
class IE_MiscExplosion extends BallisticEmitter
	placeable;

simulated event PreBeginPlay()
{
	if (Level.DetailMode < DM_SuperHigh)
		Emitters[2].Disabled=true;
	if (Level.DetailMode < DM_High)
		Emitters[1].Disabled=true;
	Super.PreBeginPlay();
}

simulated event PostBeginPlay()
{
	Super.PostBeginPlay();
	bDynamicLight = true;
	SetTimer(0.2, false);
}

simulated event Timer()
{
	Super.Timer();
	bDynamicLight = false;
}


defaultproperties
{
    Begin Object Class=SpriteEmitter Name=SpriteEmitter77
        UseColorScale=True
        FadeOut=True
        RespawnDeadParticles=False
        SpinParticles=True
        UseSizeScale=True
        UseRegularSizeScale=False
        UniformSize=True
        AutomaticInitialSpawning=False
        BlendBetweenSubdivisions=True
        ColorScale(0)=(Color=(B=255,G=255,R=255,A=255))
        ColorScale(1)=(RelativeTime=0.907143,Color=(B=225,G=225,R=225,A=160))
        ColorScale(2)=(RelativeTime=1.000000)
        ColorScale(3)=(RelativeTime=1.000000,Color=(B=255,G=255,R=255,A=255))
        ColorScale(4)=(RelativeTime=1.000000)
        FadeOutStartTime=0.686190
      
        DetailMode=DM_High
        StartLocationRange=(X=(Min=-299.250000,Max=299.250000),Y=(Min=-299.250000,Max=299.250000),Z=(Max=239.399994))
        SphereRadiusRange=(Min=180.000000,Max=180.000000)
        SpinsPerSecondRange=(X=(Min=-0.020000,Max=0.020000))
        StartSpinRange=(X=(Min=-1.000000,Max=1.000000))
        SizeScale(1)=(RelativeTime=0.070000,RelativeSize=0.650000)
        SizeScale(2)=(RelativeTime=1.000000,RelativeSize=2.000000)
        StartSizeRange=(X=(Min=5.750000,Max=550.000000),Y=(Min=5.750000,Max=550.000000),Z=(Min=5.750000,Max=550.000000))
        InitialParticlesPerSecond=80.000000
        DrawStyle=PTDS_AlphaBlend
        Texture=Texture'AW-2004Explosions.Fire.Part_explode3'
        TextureUSubdivisions=4
        TextureVSubdivisions=4
        SecondsBeforeInactive=0.000000
        LifetimeRange=(Min=3.000000)
        StartVelocityRange=(X=(Min=-239.399994,Max=239.399994),Y=(Min=-239.399994,Max=239.399994))
        VelocityLossRange=(X=(Min=1.750000,Max=1.750000),Y=(Min=1.750000,Max=1.750000),Z=(Min=1.500000,Max=1.500000))
    End Object
    Emitters(0)=SpriteEmitter'BWBP_SKC_Fix.IE_MiscExplosion.SpriteEmitter77'

    Begin Object Class=SpriteEmitter Name=SpriteEmitter78
        FadeOut=True
        RespawnDeadParticles=False
        SpinParticles=True
        UseSizeScale=True
        UseRegularSizeScale=False
        UniformSize=True
        AutomaticInitialSpawning=False
        BlendBetweenSubdivisions=True
        UseRandomSubdivision=True
        ColorScale(0)=(Color=(B=255,G=255,R=255,A=255))
        ColorScale(1)=(RelativeTime=1.000000,Color=(B=255,G=255,R=255,A=255))
        ColorMultiplierRange=(X=(Min=0.500000,Max=0.500000),Y=(Min=0.250000,Max=0.250000),Z=(Min=0.000000,Max=0.000000))
        Opacity=0.700000
        FadeOutStartTime=0.119000
        MaxParticles=6
      
        StartLocationRange=(Z=(Min=0.399000,Max=0.399000))
        AddLocationFromOtherEmitter=0
        StartSpinRange=(X=(Min=-1.000000,Max=1.000000))
        SizeScale(0)=(RelativeSize=1.010000)
        SizeScale(1)=(RelativeSize=2.000000)
        SizeScale(2)=(RelativeTime=0.250000,RelativeSize=3.000000)
        SizeScale(3)=(RelativeTime=1.000000,RelativeSize=5.000000)
        StartSizeRange=(X=(Min=191.520004,Max=191.520004),Y=(Min=191.520004,Max=191.520004),Z=(Min=191.520004,Max=191.520004))
        InitialParticlesPerSecond=300.000000
        Texture=Texture'BallisticEffects.Particles.Explode2'
        SecondsBeforeInactive=0.000000
        LifetimeRange=(Min=0.500000,Max=1.500000)
        InitialDelayRange=(Max=0.500000)
    End Object
    Emitters(1)=SpriteEmitter'BWBP_SKC_Fix.IE_MiscExplosion.SpriteEmitter78'

    Begin Object Class=SpriteEmitter Name=SpriteEmitter80
        UseDirectionAs=PTDU_Normal
        FadeOut=True
        RespawnDeadParticles=False
        SpinParticles=True
        UseSizeScale=True
        UseRegularSizeScale=False
        UniformSize=True
        AutomaticInitialSpawning=False
        ColorScale(0)=(Color=(B=255,G=255,R=255,A=255))
        ColorScale(1)=(RelativeTime=1.000000,Color=(B=255,G=255,R=255,A=255))
        Opacity=0.500000
        MaxParticles=1
      
        SpinsPerSecondRange=(X=(Min=0.050000,Max=0.100000),Y=(Min=0.050000,Max=0.100000),Z=(Min=0.050000,Max=0.100000))
        StartSpinRange=(X=(Max=1.000000),Y=(Max=1.000000),Z=(Max=1.000000))
        SizeScale(0)=(RelativeTime=1.000000,RelativeSize=100.000000)
        StartSizeRange=(X=(Min=29.924999,Max=29.924999),Y=(Min=29.924999,Max=29.924999),Z=(Min=29.924999,Max=29.924999))
        InitialParticlesPerSecond=5000.000000
        Texture=Texture'BallisticEffects.Particles.Shockwave'
        LifetimeRange=(Min=0.500000,Max=0.500000)
    End Object
    Emitters(2)=SpriteEmitter'BWBP_SKC_Fix.IE_MiscExplosion.SpriteEmitter80'

    Begin Object Class=SpriteEmitter Name=SpriteEmitter81
        UseColorScale=True
        FadeOut=True
        FadeIn=True
        RespawnDeadParticles=False
        SpinParticles=True
        UniformSize=True
        AutomaticInitialSpawning=False
        BlendBetweenSubdivisions=True
        UseRandomSubdivision=True
        ColorScale(0)=(Color=(G=255,R=255,A=255))
        ColorScale(1)=(RelativeTime=0.150000,Color=(B=150,G=255,R=255,A=255))
        ColorScale(2)=(RelativeTime=0.300000,Color=(B=255,G=255,R=255,A=255))
        ColorScale(3)=(RelativeTime=1.000000,Color=(B=255,G=255,R=255,A=255))
        Opacity=0.500000
        FadeOutStartTime=5.475000
        FadeInEndTime=1.950000
        MaxParticles=15
      
        StartLocationOffset=(Z=150.000000)
        StartLocationRange=(X=(Min=-349.125000,Max=349.125000),Y=(Min=-349.125000,Max=349.125000),Z=(Min=-200.000000,Max=200.000000))
        SpinsPerSecondRange=(X=(Max=0.050000),Y=(Min=0.050000,Max=0.100000),Z=(Min=0.050000,Max=0.100000))
        StartSpinRange=(X=(Max=1.000000),Y=(Max=1.000000),Z=(Max=1.000000))
        StartSizeRange=(X=(Min=399.000000,Max=399.000000),Y=(Min=399.000000,Max=399.000000),Z=(Min=399.000000,Max=399.000000))
        InitialParticlesPerSecond=5000.000000
        DrawStyle=PTDS_AlphaBlend
        Texture=Texture'BallisticEffects2.Particles.NewSmoke1f'
        LifetimeRange=(Min=7.000000,Max=7.500000)
        InitialDelayRange=(Min=1.000000,Max=1.000000)
        StartVelocityRange=(Z=(Min=20.000000,Max=20.000000))
    End Object
    Emitters(3)=SpriteEmitter'BWBP_SKC_Fix.IE_MiscExplosion.SpriteEmitter81'

    Begin Object Class=SpriteEmitter Name=SpriteEmitter84
        FadeOut=True
        RespawnDeadParticles=False
        SpinParticles=True
        UseSizeScale=True
        UseRegularSizeScale=False
        UniformSize=True
        AutomaticInitialSpawning=False
        BlendBetweenSubdivisions=True
        UseRandomSubdivision=True
        ColorScale(0)=(Color=(B=255,G=255,R=255,A=255))
        ColorScale(1)=(RelativeTime=1.000000,Color=(B=255,G=255,R=255,A=255))
        MaxParticles=2
      
        StartSpinRange=(X=(Max=1.000000),Y=(Max=1.000000),Z=(Max=1.000000))
        SizeScale(0)=(RelativeTime=0.140000,RelativeSize=10.000000)
        SizeScale(1)=(RelativeTime=0.170000,RelativeSize=11.000000)
        SizeScale(2)=(RelativeTime=0.500000,RelativeSize=12.000000)
        SizeScale(3)=(RelativeTime=1.000000,RelativeSize=13.000000)
        StartSizeRange=(X=(Min=99.750000,Max=99.750000),Y=(Min=99.750000,Max=99.750000),Z=(Min=99.750000,Max=99.750000))
        InitialParticlesPerSecond=5000.000000
        Texture=Texture'BallisticEffects.Particles.FlareB2'
        LifetimeRange=(Min=1.000000,Max=1.000000)
    End Object
    Emitters(4)=SpriteEmitter'BWBP_SKC_Fix.IE_MiscExplosion.SpriteEmitter84'

    Begin Object Class=SpriteEmitter Name=SpriteEmitter85
        UseColorScale=True
        FadeOut=True
        FadeIn=True
        RespawnDeadParticles=False
        SpinParticles=True
        UniformSize=True
        AutomaticInitialSpawning=False
        Acceleration=(Z=-558.600037)
        ColorScale(0)=(Color=(G=200,R=255,A=255))
        ColorScale(1)=(RelativeTime=1.000000,Color=(G=150,R=200,A=255))
        FadeOutStartTime=2.000000
        FadeInEndTime=2.000000
        MaxParticles=12
      
        SpinsPerSecondRange=(X=(Min=0.050000,Max=0.100000),Y=(Min=0.050000,Max=0.100000),Z=(Min=0.050000,Max=0.100000))
        StartSpinRange=(X=(Max=1.000000),Y=(Max=1.000000),Z=(Max=1.000000))
        StartSizeRange=(X=(Min=20.000000,Max=20.000000),Y=(Min=20.000000,Max=20.000000),Z=(Min=20.000000,Max=20.000000))
        InitialParticlesPerSecond=5000.000000
        Texture=Texture'AW-2004Particles.Energy.BurnFlare'
        StartVelocityRange=(X=(Min=-598.500000,Max=598.500000),Y=(Min=-598.500000,Max=598.500000),Z=(Min=798.000061,Max=997.500000))
    End Object
    Emitters(5)=SpriteEmitter'BWBP_SKC_Fix.IE_MiscExplosion.SpriteEmitter85'

    Begin Object Class=SpriteEmitter Name=SpriteEmitter90
        FadeOut=True
        RespawnDeadParticles=False
        SpinParticles=True
        UniformSize=True
        AutomaticInitialSpawning=False
        ColorScale(0)=(Color=(B=255,G=255,R=255,A=255))
        ColorScale(1)=(RelativeTime=1.000000,Color=(B=255,G=255,R=255,A=255))
        Opacity=0.500000
        MaxParticles=400
      
        AddLocationFromOtherEmitter=5
        SpinsPerSecondRange=(X=(Min=0.050000,Max=0.100000),Y=(Min=0.050000,Max=0.100000),Z=(Min=0.050000,Max=0.100000))
        StartSpinRange=(X=(Max=1.000000),Y=(Max=1.000000),Z=(Max=1.000000))
        StartSizeRange=(X=(Min=15.000000,Max=15.000000),Y=(Min=15.000000,Max=15.000000),Z=(Min=15.000000,Max=15.000000))
        InitialParticlesPerSecond=150.000000
        DrawStyle=PTDS_AlphaBlend
        Texture=Texture'AW-2004Particles.Fire.SmokeFragment'
    End Object
    Emitters(6)=SpriteEmitter'BWBP_SKC_Fix.IE_MiscExplosion.SpriteEmitter90'

    Begin Object Class=SpriteEmitter Name=SpriteEmitter92
        FadeOut=True
        RespawnDeadParticles=False
        SpinParticles=True
        UseSizeScale=True
        UseRegularSizeScale=False
        UniformSize=True
        AutomaticInitialSpawning=False
        ColorScale(0)=(Color=(B=255,G=255,R=255,A=255))
        ColorScale(1)=(RelativeTime=1.000000,Color=(B=255,G=255,R=255,A=255))
        Opacity=0.500000
        MaxParticles=1
      
        SpinsPerSecondRange=(X=(Min=0.050000,Max=0.100000),Y=(Min=0.050000,Max=0.100000),Z=(Min=0.050000,Max=0.100000))
        StartSpinRange=(X=(Max=1.000000),Y=(Max=1.000000),Z=(Max=1.000000))
        SizeScale(0)=(RelativeTime=1.000000,RelativeSize=100.000000)
        StartSizeRange=(X=(Min=29.925001,Max=29.925001),Y=(Min=29.925001,Max=29.925001),Z=(Min=29.925001,Max=29.925001))
        InitialParticlesPerSecond=5000.000000
        Texture=Texture'BallisticEffects.Particles.Shockwave'
        LifetimeRange=(Min=0.500000,Max=0.500000)
    End Object
    Emitters(7)=SpriteEmitter'BWBP_SKC_Fix.IE_MiscExplosion.SpriteEmitter92'

    Begin Object Class=SpriteEmitter Name=SpriteEmitter93
        FadeOut=True
        FadeIn=True
        RespawnDeadParticles=False
        SpinParticles=True
        UniformSize=True
        AutomaticInitialSpawning=False
        BlendBetweenSubdivisions=True
        ColorScale(0)=(Color=(B=255,G=255,R=255,A=255))
        ColorScale(1)=(RelativeTime=1.000000,Color=(B=255,G=255,R=255,A=255))
        Opacity=0.590000
        FadeOutStartTime=0.093333
        FadeInEndTime=0.093333
        MaxParticles=50
      
        StartLocationRange=(Z=(Max=249.375000))
        StartLocationShape=PTLS_Sphere
        SpinsPerSecondRange=(X=(Min=0.075000,Max=0.150000),Y=(Min=0.075000,Max=0.150000),Z=(Min=0.075000,Max=0.150000))
        StartSpinRange=(X=(Max=1.000000),Y=(Max=1.000000),Z=(Max=1.000000))
        StartSizeRange=(X=(Min=249.375000,Max=249.375000),Y=(Min=249.375000,Max=249.375000),Z=(Min=249.375000,Max=249.375000))
        InitialParticlesPerSecond=7500.000000
        Texture=Texture'AW-2004Explosions.Fire.Part_explode2'
        TextureUSubdivisions=4
        TextureVSubdivisions=4
        LifetimeRange=(Min=1.333333,Max=1.333333)
        StartVelocityRange=(X=(Min=-997.500000,Max=997.500000),Y=(Min=-997.500000,Max=997.500000),Z=(Min=-1000.000000,Max=1000.000000))
        VelocityLossRange=(X=(Min=1.000000,Max=1.000000),Y=(Min=1.000000,Max=1.000000),Z=(Min=1.000000,Max=1.000000))
    End Object
    Emitters(8)=SpriteEmitter'BWBP_SKC_Fix.IE_MiscExplosion.SpriteEmitter93'

    Begin Object Class=SpriteEmitter Name=SpriteEmitter97
        UseColorScale=True
        FadeOut=True
        RespawnDeadParticles=False
        SpinParticles=True
        UniformSize=True
        AutomaticInitialSpawning=False
        ColorScale(0)=(Color=(G=255,R=255,A=255))
        ColorScale(1)=(RelativeTime=1.000000,Color=(G=150,R=250,A=255))
        Opacity=0.500000
      
        StartLocationRange=(X=(Min=-498.750000,Max=498.750000),Y=(Min=-498.750000,Max=498.750000),Z=(Min=-299.250000,Max=99.750000))
        AddLocationFromOtherEmitter=3
        StartLocationShape=PTLS_Sphere
        SphereRadiusRange=(Min=150.000000,Max=250.000000)
        SpinsPerSecondRange=(X=(Min=0.050000,Max=0.100000),Y=(Min=0.050000,Max=0.100000),Z=(Min=0.050000,Max=0.100000))
        StartSpinRange=(X=(Max=1.000000),Y=(Max=1.000000),Z=(Max=1.000000))
        StartSizeRange=(X=(Min=266.000000,Max=266.000000),Y=(Min=266.000000,Max=266.000000),Z=(Min=266.000000,Max=266.000000))
        InitialParticlesPerSecond=5000.000000
        Texture=Texture'AW-2004Particles.Energy.CloudLightning'
        LifetimeRange=(Min=7.000000,Max=8.000000)
        InitialDelayRange=(Max=0.500000)
        StartVelocityRange=(Z=(Min=20.750000,Max=20.750000))
    End Object
    Emitters(9)=SpriteEmitter'BWBP_SKC_Fix.IE_MiscExplosion.SpriteEmitter97'

   
   

     AutoDestroy=True
     LightType=LT_Pulse
     LightEffect=LE_NonIncidence
     LightHue=30
     LightSaturation=150
     LightBrightness=150.000000
     LightRadius=252.000000
     LightPeriod=3
     bNoDelete=False
}