//-----------------------------------------------------------
//
//-----------------------------------------------------------
class IE_SgtKellyNuke extends BallisticEmitter;

#exec OBJ LOAD FILE="..\Textures\AW-2004Explosions.utx"
#exec OBJ LOAD FILE="..\Textures\AW-2004Particles.utx"

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


     Begin Object Class=SpriteEmitter Name=SpriteEmitter46
        UseColorScale=True
        FadeOut=True
        FadeIn=True
        RespawnDeadParticles=False
        SpinParticles=True
        UniformSize=True
        AutomaticInitialSpawning=False
        BlendBetweenSubdivisions=True
        UseRandomSubdivision=True
        ColorScale(0)=(Color=(B=255,G=255,R=255,A=255))
        ColorScale(1)=(RelativeTime=0.300000,Color=(B=100,G=100,R=100,A=255))
        ColorScale(2)=(RelativeTime=0.346429,Color=(B=75,G=75,R=75,A=255))
        ColorScale(3)=(RelativeTime=1.000000,Color=(B=50,G=50,R=50,A=255))
        FadeOutStartTime=27.600000
        FadeInEndTime=1.200000
        MaxParticles=50
      
        StartLocationRange=(X=(Min=-562.500000,Max=562.500000),Y=(Min=-562.500000,Max=562.500000),Z=(Min=-112.500000,Max=112.500000))
        StartLocationPolarRange=(X=(Min=16.000000,Max=16.000000),Y=(Min=32.000000,Max=32.000000))
        SpinsPerSecondRange=(X=(Min=0.050000,Max=0.050000),Y=(Min=0.050000,Max=0.100000),Z=(Min=0.050000,Max=0.100000))
        StartSpinRange=(X=(Max=1.000000),Y=(Max=1.000000),Z=(Max=1.000000))
        StartSizeRange=(X=(Min=562.500000,Max=562.500000),Y=(Min=562.500000,Max=562.500000),Z=(Min=562.500000,Max=562.500000))
        InitialParticlesPerSecond=5000.000000
        DrawStyle=PTDS_AlphaBlend
        Texture=Texture'BallisticEffects2.Particles.NewSmoke1f'
        LifetimeRange=(Min=0.100000,Max=0.100000)
        StartVelocityRange=(Z=(Min=168.750000,Max=168.750000))
        VelocityLossRange=(Z=(Min=0.050000,Max=0.050000))
    End Object
    Emitters(0)=SpriteEmitter'SpriteEmitter46'

    Begin Object Class=SpriteEmitter Name=SpriteEmitter47
        UseColorScale=True
        FadeOut=True
        FadeIn=True
        RespawnDeadParticles=False
        SpinParticles=True
        UniformSize=True
        AutomaticInitialSpawning=False
        BlendBetweenSubdivisions=True
        UseRandomSubdivision=True
        ColorScale(0)=(Color=(B=255,G=255,R=255,A=255))
        ColorScale(1)=(RelativeTime=0.300000,Color=(B=100,G=100,R=100,A=255))
        ColorScale(2)=(RelativeTime=0.346429,Color=(B=75,G=75,R=75,A=255))
        ColorScale(3)=(RelativeTime=1.000000,Color=(B=50,G=50,R=50,A=255))
        FadeOutStartTime=4.600000
        FadeInEndTime=1.200000
        MaxParticles=50
      
        StartLocationOffset=(Z=375.000000)
        StartLocationRange=(X=(Min=-337.500000,Max=337.500000),Y=(Min=-337.500000,Max=337.500000),Z=(Min=-112.500000,Max=112.500000))
        StartLocationPolarRange=(X=(Min=16.000000,Max=16.000000),Y=(Min=32.000000,Max=32.000000))
        SpinsPerSecondRange=(X=(Min=0.050000,Max=0.050000),Y=(Min=0.050000,Max=0.100000),Z=(Min=0.050000,Max=0.100000))
        StartSpinRange=(X=(Max=1.000000),Y=(Max=1.000000),Z=(Max=1.000000))
        StartSizeRange=(X=(Min=562.500000,Max=562.500000),Y=(Min=562.500000,Max=562.500000),Z=(Min=562.500000,Max=562.500000))
        InitialParticlesPerSecond=5000.000000
        DrawStyle=PTDS_AlphaBlend
        Texture=Texture'BallisticEffects2.Particles.NewSmoke1f'
        LifetimeRange=(Min=10.000000,Max=10.000000)
        StartVelocityRange=(Z=(Min=168.750000,Max=168.750000))
        VelocityLossRange=(Z=(Min=0.050000,Max=0.050000))
    End Object
    Emitters(1)=SpriteEmitter'SpriteEmitter47'

    Begin Object Class=SpriteEmitter Name=SpriteEmitter48
        UseColorScale=True
        FadeOut=True
        FadeIn=True
        RespawnDeadParticles=False
        SpinParticles=True
        UniformSize=True
        AutomaticInitialSpawning=False
        BlendBetweenSubdivisions=True
        UseRandomSubdivision=True
        ColorScale(0)=(Color=(B=150,G=150,R=150,A=255))
        ColorScale(1)=(RelativeTime=1.000000,Color=(B=100,G=100,R=100,A=255))
        FadeOutStartTime=4.200000
        FadeInEndTime=1.300000
        MaxParticles=125
      
        StartLocationRange=(X=(Min=-1500.000000,Max=1500.000000),Y=(Min=-1500.000000,Max=1500.000000))
        SpinsPerSecondRange=(X=(Min=0.050000,Max=0.100000),Y=(Min=0.050000,Max=0.100000),Z=(Min=0.050000,Max=0.100000))
        StartSpinRange=(X=(Max=1.000000),Y=(Max=1.000000),Z=(Max=1.000000))
        StartSizeRange=(X=(Min=187.500000,Max=187.500000),Y=(Min=187.500000,Max=187.500000),Z=(Min=187.500000,Max=187.500000))
        InitialParticlesPerSecond=12.500000
        DrawStyle=PTDS_AlphaBlend
        Texture=Texture'AW-2004Particles.Weapons.SmokePanels1'
        TextureUSubdivisions=4
        TextureVSubdivisions=4
        LifetimeRange=(Min=5.000000,Max=5.000000)
        InitialDelayRange=(Max=0.500000)
        StartVelocityRadialRange=(Min=50.000000,Max=50.000000)
        GetVelocityDirectionFrom=PTVD_AddRadial
    End Object
    Emitters(2)=SpriteEmitter'SpriteEmitter48'

    Begin Object Class=SpriteEmitter Name=SpriteEmitter49
        UseColorScale=True
        FadeOut=True
        FadeIn=True
        RespawnDeadParticles=False
        SpinParticles=True
        UniformSize=True
        BlendBetweenSubdivisions=True
        UseRandomSubdivision=True
        ColorScale(0)=(Color=(B=150,G=150,R=150,A=255))
        ColorScale(1)=(RelativeTime=1.000000,Color=(B=100,G=100,R=100,A=255))
        FadeOutStartTime=7.200000
        FadeInEndTime=1.200000
        MaxParticles=500
      
        StartLocationRange=(X=(Min=-75.000000,Max=75.000000),Y=(Min=-75.000000,Max=75.000000))
        SpinsPerSecondRange=(X=(Min=0.050000,Max=0.100000),Y=(Min=0.050000,Max=0.100000),Z=(Min=0.050000,Max=0.100000))
        StartSpinRange=(X=(Max=1.000000),Y=(Max=1.000000),Z=(Max=1.000000))
        StartSizeRange=(X=(Min=140.625000,Max=140.625000),Y=(Min=140.625000,Max=140.625000),Z=(Min=140.625000,Max=140.625000))
        InitialParticlesPerSecond=25.000000
        DrawStyle=PTDS_AlphaBlend
        Texture=Texture'AW-2004Particles.Weapons.SmokePanels1'
        TextureUSubdivisions=4
        TextureVSubdivisions=4
        LifetimeRange=(Min=5.500000,Max=5.500000)
        StartVelocityRange=(Z=(Min=168.750000,Max=168.750000))
        StartVelocityRadialRange=(Min=100.000000,Max=100.000000)
    End Object
    Emitters(3)=SpriteEmitter'SpriteEmitter49'

    Begin Object Class=SpriteEmitter Name=SpriteEmitter50
        UseDirectionAs=PTDU_Normal
        FadeOut=True
        RespawnDeadParticles=False
        UseSizeScale=True
        UseRegularSizeScale=False
        UniformSize=True
        AutomaticInitialSpawning=False
        ColorScale(0)=(Color=(G=175,R=255,A=255))
        ColorScale(1)=(RelativeTime=1.000000,Color=(G=175,R=255,A=255))
        Opacity=0.500000
        MaxParticles=1
      
        SpinsPerSecondRange=(X=(Min=0.050000,Max=0.100000),Y=(Min=0.050000,Max=0.100000),Z=(Min=0.050000,Max=0.100000))
        StartSpinRange=(X=(Max=1.000000),Y=(Max=1.000000),Z=(Max=1.000000))
        RotationNormal=(Z=1.000000)
        SizeScale(0)=(RelativeTime=1.000000,RelativeSize=6.000000)
        StartSizeRange=(X=(Min=562.500000,Max=562.500000),Y=(Min=562.500000,Max=562.500000),Z=(Min=562.500000,Max=562.500000))
        InitialParticlesPerSecond=50000.000000
        Texture=Texture'AW-2004Particles.Energy.SmoothRing'
        LifetimeRange=(Min=0.500000,Max=0.500000)
    End Object
    Emitters(4)=SpriteEmitter'SpriteEmitter50'

    Begin Object Class=SpriteEmitter Name=SpriteEmitter51
        UseColorScale=True
        FadeOut=True
        RespawnDeadParticles=False
        SpinParticles=True
        UseSizeScale=True
        UseRegularSizeScale=False
        UniformSize=True
        AutomaticInitialSpawning=False
        ColorScale(0)=(Color=(B=255,G=255,R=255,A=255))
        ColorScale(1)=(RelativeTime=0.250000,Color=(G=200,R=200,A=255))
        ColorScale(2)=(RelativeTime=0.500000,Color=(B=50,G=125,R=150,A=255))
        ColorScale(3)=(RelativeTime=1.000000,Color=(B=50,G=100,R=150,A=255))
        MaxParticles=5
      
        StartLocationOffset=(Z=500.000000)
        SpinsPerSecondRange=(X=(Min=0.020000,Max=0.020000))
        StartSpinRange=(X=(Max=1.000000))
        SizeScale(0)=(RelativeTime=0.250000,RelativeSize=0.750000)
        SizeScale(1)=(RelativeTime=1.000000,RelativeSize=0.750000)
        StartSizeRange=(X=(Min=3500.000000,Max=3500.000000),Y=(Min=3500.000000,Max=3500.000000),Z=(Min=3500.000000,Max=3500.000000))
        InitialParticlesPerSecond=5000.000000
        Texture=Texture'BallisticEffects.Specularity.BWSpecularity'
        LifetimeRange=(Min=6.000000,Max=6.000000)
        AddVelocityFromOtherEmitter=1
    End Object
    Emitters(5)=SpriteEmitter'SpriteEmitter51'

    Begin Object Class=SpriteEmitter Name=SpriteEmitter52
        FadeOut=True
        FadeIn=True
        RespawnDeadParticles=False
        SpinParticles=True
        UniformSize=True
        AutomaticInitialSpawning=False
        BlendBetweenSubdivisions=True
        UseRandomSubdivision=True
        ColorScale(0)=(Color=(B=255,G=255,R=255,A=255))
        ColorScale(1)=(RelativeTime=1.000000,Color=(B=255,G=255,R=255,A=255))
        FadeOutStartTime=2.500000
        FadeInEndTime=2.500000
        MaxParticles=100
      
        AddLocationFromOtherEmitter=1
        SpinsPerSecondRange=(X=(Min=0.050000,Max=0.100000),Y=(Min=0.050000,Max=0.100000),Z=(Min=0.050000,Max=0.100000))
        StartSpinRange=(X=(Max=1.000000),Y=(Max=1.000000),Z=(Max=1.000000))
        StartSizeRange=(X=(Min=300.000000,Max=300.000000),Y=(Min=300.000000,Max=300.000000),Z=(Min=300.000000,Max=300.000000))
        InitialParticlesPerSecond=30.000000
        DrawStyle=PTDS_AlphaBlend
        Texture=Texture'ExplosionTex.Framed.exp2_frames'
        TextureUSubdivisions=4
        TextureVSubdivisions=4
        LifetimeRange=(Min=2.000000,Max=3.000000)
        InitialDelayRange=(Min=1.000000,Max=2.000000)
        StartVelocityRange=(Z=(Min=2.000000,Max=2.000000))
        VelocityLossRange=(Z=(Min=0.050000,Max=0.050000))
        AddVelocityFromOtherEmitter=1
    End Object
    Emitters(6)=SpriteEmitter'SpriteEmitter52'

    Begin Object Class=SpriteEmitter Name=SpriteEmitter53
        FadeOut=True
        FadeIn=True
        RespawnDeadParticles=False
        SpinParticles=True
        UniformSize=True
        AutomaticInitialSpawning=False
        BlendBetweenSubdivisions=True
        UseRandomSubdivision=True
        ColorScale(0)=(Color=(B=255,G=255,R=255,A=255))
        ColorScale(1)=(RelativeTime=1.000000,Color=(B=255,G=255,R=255,A=255))
        FadeOutStartTime=2.500000
        FadeInEndTime=2.500000
        MaxParticles=100
      
        AddLocationFromOtherEmitter=0
        SpinsPerSecondRange=(X=(Min=0.050000,Max=0.100000),Y=(Min=0.050000,Max=0.100000),Z=(Min=0.050000,Max=0.100000))
        StartSpinRange=(X=(Max=1.000000),Y=(Max=1.000000),Z=(Max=1.000000))
        StartSizeRange=(X=(Min=300.000000,Max=300.000000),Y=(Min=300.000000,Max=300.000000),Z=(Min=300.000000,Max=300.000000))
        InitialParticlesPerSecond=30.000000
        DrawStyle=PTDS_AlphaBlend
        Texture=Texture'ExplosionTex.Framed.exp2_frames'
        TextureUSubdivisions=4
        TextureVSubdivisions=4
        LifetimeRange=(Min=2.000000,Max=3.000000)
        InitialDelayRange=(Min=1.000000,Max=2.000000)
        StartVelocityRange=(Z=(Min=2.000000,Max=2.000000))
        VelocityLossRange=(Z=(Min=0.050000,Max=0.050000))
        AddVelocityFromOtherEmitter=1
    End Object
    Emitters(7)=SpriteEmitter'SpriteEmitter53'

    Begin Object Class=MeshEmitter Name=MeshEmitter1
        StaticMesh=StaticMesh'VMmeshEmitted.EJECTA.Sphere'
        UseMeshBlendMode=False
        RenderTwoSided=True
        UseParticleColor=True
        FadeOut=True
        FadeIn=True
        RespawnDeadParticles=False
        UseSizeScale=True
        UseRegularSizeScale=False
        AutomaticInitialSpawning=False
        ColorScale(0)=(Color=(B=255,G=255,R=255,A=255))
        ColorScale(1)=(RelativeTime=1.000000,Color=(B=255,G=255,R=255,A=255))
        Opacity=0.250000
        FadeOutStartTime=0.100000
        FadeInEndTime=0.100000
        MaxParticles=1
      
        StartSpinRange=(X=(Max=1.000000),Y=(Max=1.000000),Z=(Max=1.000000))
        SizeScale(0)=(RelativeTime=1.000000,RelativeSize=10.000000)
        StartSizeRange=(X=(Min=100.000000,Max=100.000000),Y=(Min=100.000000,Max=100.000000),Z=(Min=100.000000,Max=100.000000))
        InitialParticlesPerSecond=5000.000000
        LifetimeRange=(Min=1.000000,Max=1.000000)
    End Object
    Emitters(8)=MeshEmitter'MeshEmitter1'

    Begin Object Class=SpriteEmitter Name=SpriteEmitter57
        UseCollision=True
        UseColorScale=True
        FadeOut=True
        FadeIn=True
        RespawnDeadParticles=False
        VelocityFromMesh=True
        UniformMeshScale=False
        UniformVelocityScale=False
        SpawnOnlyInDirectionOfNormal=True
        SpinParticles=True
        UniformSize=True
        AutomaticInitialSpawning=False
        BlendBetweenSubdivisions=True
        UseRandomSubdivision=True
        DampingFactorRange=(X=(Min=0.000000,Max=0.000000),Y=(Min=0.000000,Max=0.000000),Z=(Min=0.000000,Max=0.000000))
        ColorScale(0)=(Color=(B=150,G=150,R=150,A=255))
        ColorScale(1)=(RelativeTime=1.000000,Color=(B=100,G=100,R=100,A=255))
        Opacity=0.750000
        FadeOutStartTime=7.500000
        FadeInEndTime=3.600000
        MaxParticles=250
      
        StartLocationPolarRange=(X=(Min=1024.000000,Max=1024.000000),Y=(Min=1024.000000,Max=1024.000000),Z=(Min=1000.000000,Max=1000.000000))
        MeshSpawningStaticMesh=StaticMesh'ParticleMeshes.Simple.ParticleRing'
        MeshSpawning=PTMS_Random
        VelocityScaleRange=(X=(Min=0.000000,Max=0.000000),Y=(Min=0.000000,Max=0.000000),Z=(Min=0.000000,Max=0.000000))
        MeshScaleRange=(X=(Min=10.000000,Max=50.000000),Y=(Min=10.000000,Max=50.000000),Z=(Min=0.010000,Max=0.010000))
        MeshNormal=(X=16384.000000,Y=16384.000000,Z=0.000000)
        MeshNormalThresholdRange=(Min=16384.000000,Max=16384.000000)
        SpinsPerSecondRange=(X=(Min=0.050000,Max=0.100000),Y=(Min=0.050000,Max=0.100000),Z=(Min=0.050000,Max=0.100000))
        StartSpinRange=(X=(Max=1.000000),Y=(Max=1.000000),Z=(Max=1.000000))
        StartSizeRange=(X=(Min=200.000000,Max=200.000000),Y=(Min=200.000000,Max=200.000000),Z=(Min=200.000000,Max=200.000000))
        InitialParticlesPerSecond=500000.000000
        DrawStyle=PTDS_AlphaBlend
        Texture=Texture'AW-2004Particles.Weapons.SmokePanels1'
        TextureUSubdivisions=4
        TextureVSubdivisions=4
        LifetimeRange=(Min=9.000000,Max=10.000000)
        StartVelocityRange=(Z=(Min=-500.000000,Max=-500.000000))
        StartVelocityRadialRange=(Min=-1000.000000,Max=1000.000000)
    End Object
    Emitters(9)=SpriteEmitter'SpriteEmitter57'

    Begin Object Class=SpriteEmitter Name=SpriteEmitter58
        FadeOut=True
        RespawnDeadParticles=False
        UseSizeScale=True
        UseRegularSizeScale=False
        UniformSize=True
        AutomaticInitialSpawning=False
        ColorScale(0)=(Color=(G=175,R=255,A=255))
        ColorScale(1)=(RelativeTime=1.000000,Color=(G=175,R=255,A=255))
        Opacity=0.500000
        MaxParticles=1
      
        SpinsPerSecondRange=(X=(Min=0.050000,Max=0.100000),Y=(Min=0.050000,Max=0.100000),Z=(Min=0.050000,Max=0.100000))
        StartSpinRange=(X=(Max=1.000000),Y=(Max=1.000000),Z=(Max=1.000000))
        RotationNormal=(Z=1.000000)
        SizeScale(0)=(RelativeTime=1.000000,RelativeSize=6.000000)
        StartSizeRange=(X=(Min=562.500000,Max=562.500000),Y=(Min=562.500000,Max=562.500000),Z=(Min=562.500000,Max=562.500000))
        InitialParticlesPerSecond=5000.000000
        DrawStyle=PTDS_AlphaBlend
        Texture=Texture'AW-2004Particles.Energy.SmoothRing'
        LifetimeRange=(Min=1.000000,Max=1.000000)
    End Object
    Emitters(10)=SpriteEmitter'SpriteEmitter58'

    Begin Object Class=SpriteEmitter Name=SpriteEmitter59
        UseColorScale=True
        FadeOut=True
        FadeIn=True
        RespawnDeadParticles=False
        SpinParticles=True
        UniformSize=True
        AutomaticInitialSpawning=False
        BlendBetweenSubdivisions=True
        UseRandomSubdivision=True
        Acceleration=(Z=5.000000)
        ColorScale(0)=(Color=(B=150,G=150,R=150,A=255))
        ColorScale(1)=(RelativeTime=1.000000,Color=(B=100,G=100,R=100,A=255))
        FadeOutStartTime=2.200000
        FadeInEndTime=1.300000
        MaxParticles=250
      
        StartLocationRange=(X=(Min=-750.000000,Max=750.000000),Y=(Min=-750.000000,Max=750.000000))
        SpinsPerSecondRange=(X=(Min=0.050000,Max=0.100000),Y=(Min=0.050000,Max=0.100000),Z=(Min=0.050000,Max=0.100000))
        StartSpinRange=(X=(Max=1.000000),Y=(Max=1.000000),Z=(Max=1.000000))
        StartSizeRange=(X=(Min=187.500000,Max=187.500000),Y=(Min=187.500000,Max=187.500000),Z=(Min=187.500000,Max=187.500000))
        InitialParticlesPerSecond=25.000000
        DrawStyle=PTDS_AlphaBlend
        Texture=Texture'AW-2004Particles.Weapons.SmokePanels1'
        TextureUSubdivisions=4
        TextureVSubdivisions=4
        LifetimeRange=(Min=5.000000,Max=5.000000)
        InitialDelayRange=(Max=0.500000)
        StartVelocityRadialRange=(Min=50.000000,Max=50.000000)
        GetVelocityDirectionFrom=PTVD_AddRadial
    End Object
    Emitters(11)=SpriteEmitter'SpriteEmitter59'

    Begin Object Class=SpriteEmitter Name=SpriteEmitter60
        FadeOut=True
        RespawnDeadParticles=False
        SpinParticles=True
        UseSizeScale=True
        UseRegularSizeScale=False
        UniformSize=True
        AutomaticInitialSpawning=False
        BlendBetweenSubdivisions=True
        ColorScale(0)=(Color=(B=255,G=255,R=255,A=255))
        ColorScale(1)=(RelativeTime=1.000000,Color=(B=255,G=255,R=255,A=255))
        MaxParticles=5
      
        StartSpinRange=(X=(Max=1.000000),Y=(Max=1.000000),Z=(Max=1.000000))
        SizeScale(0)=(RelativeTime=0.140000,RelativeSize=10.000000)
        SizeScale(1)=(RelativeTime=0.170000,RelativeSize=11.000000)
        SizeScale(2)=(RelativeTime=0.500000,RelativeSize=12.000000)
        SizeScale(3)=(RelativeTime=1.000000,RelativeSize=13.000000)
        StartSizeRange=(X=(Min=250.000000,Max=250.000000),Y=(Min=250.000000,Max=250.000000),Z=(Min=250.000000,Max=250.000000))
        InitialParticlesPerSecond=5000.000000
        Texture=Texture'AW-2004Explosions.Fire.Part_explode2s'
        TextureUSubdivisions=4
        TextureVSubdivisions=4
        LifetimeRange=(Min=0.600000,Max=0.600000)
        InitialDelayRange=(Min=0.250000,Max=0.250000)
    End Object
    Emitters(12)=SpriteEmitter'SpriteEmitter60'

    Begin Object Class=SpriteEmitter Name=SpriteEmitter61
        FadeOut=True
        FadeIn=True
        RespawnDeadParticles=False
        SpinParticles=True
        UseRegularSizeScale=False
        UniformSize=True
        AutomaticInitialSpawning=False
        ColorScale(0)=(Color=(B=255,G=255,R=255,A=255))
        ColorScale(1)=(RelativeTime=1.000000,Color=(B=255,G=255,R=255,A=255))
        FadeOutStartTime=0.640000
        FadeInEndTime=0.640000
      
        StartLocationRange=(X=(Min=-100.000000,Max=100.000000),Y=(Min=-100.000000,Max=100.000000))
        SpinsPerSecondRange=(X=(Min=0.050000,Max=0.050000))
        StartSpinRange=(X=(Max=1.000000))
        StartSizeRange=(X=(Min=2500.000000,Max=2500.000000),Y=(Min=2500.000000,Max=2500.000000),Z=(Min=2500.000000,Max=2500.000000))
        InitialParticlesPerSecond=5000.000000
        Texture=Texture'EmitterTextures.Flares.EFlareOY'
        LifetimeRange=(Min=2.000000,Max=3.000000)
        AddVelocityFromOtherEmitter=0
    End Object
    Emitters(13)=SpriteEmitter'SpriteEmitter61'

    Begin Object Class=SpriteEmitter Name=SpriteEmitter62
        UseColorScale=True
        FadeOut=True
        FadeIn=True
        RespawnDeadParticles=False
        SpinParticles=True
        UniformSize=True
        AutomaticInitialSpawning=False
        BlendBetweenSubdivisions=True
        UseRandomSubdivision=True
        ColorScale(0)=(Color=(B=50,G=75,R=100,A=255))
        ColorScale(1)=(RelativeTime=1.000000,Color=(B=50,G=75,R=100,A=255))
        FadeOutStartTime=1.900000
        FadeInEndTime=1.200000
        MaxParticles=300
      
        StartLocationRange=(X=(Min=-50.000000,Max=50.000000),Y=(Min=-50.000000,Max=50.000000))
        AddLocationFromOtherEmitter=3
        SpinsPerSecondRange=(X=(Min=0.050000,Max=0.100000),Y=(Min=0.050000,Max=0.100000),Z=(Min=0.050000,Max=0.100000))
        StartSpinRange=(X=(Max=1.000000),Y=(Max=1.000000),Z=(Max=1.000000))
        StartSizeRange=(X=(Min=75.000000,Max=75.000000),Y=(Min=75.000000,Max=75.000000),Z=(Min=75.000000,Max=75.000000))
        InitialParticlesPerSecond=50.000000
        Texture=Texture'AW-2004Explosions.Fire.Part_explode2'
        TextureUSubdivisions=4
        TextureVSubdivisions=4
        LifetimeRange=(Min=2.000000,Max=3.000000)
        InitialDelayRange=(Min=3.000000,Max=4.000000)
        StartVelocityRange=(Z=(Min=168.750000,Max=168.750000))
        StartVelocityRadialRange=(Min=100.000000,Max=100.000000)
    End Object
    Emitters(14)=SpriteEmitter'SpriteEmitter62'

    Begin Object Class=SpriteEmitter Name=SpriteEmitter63
        UseColorScale=True
        FadeOut=True
        RespawnDeadParticles=False
        SpinParticles=True
        UseSizeScale=True
        UseRegularSizeScale=False
        UniformSize=True
        AutomaticInitialSpawning=False
        ColorScale(0)=(Color=(B=255,G=255,R=255,A=255))
        ColorScale(1)=(RelativeTime=1.000000,Color=(G=175,R=255,A=255))
        FadeOutStartTime=2.000000
        MaxParticles=2
      
        StartLocationOffset=(Z=150.000000)
        SpinsPerSecondRange=(X=(Min=0.050000,Max=0.100000),Y=(Min=0.050000,Max=0.100000),Z=(Min=0.050000,Max=0.100000))
        StartSpinRange=(X=(Max=1.000000),Y=(Max=1.000000),Z=(Max=1.000000))
        SizeScale(0)=(RelativeSize=10.000000)
        SizeScale(1)=(RelativeTime=0.070000,RelativeSize=25.000000)
        SizeScale(2)=(RelativeTime=1.000000,RelativeSize=27.000000)
        StartSizeRange=(X=(Min=50.000000,Max=50.000000),Y=(Min=50.000000,Max=50.000000),Z=(Min=50.000000,Max=50.000000))
        InitialParticlesPerSecond=5000.000000
        Texture=Texture'EpicParticles.Flares.SoftFlare'
        LifetimeRange=(Min=5.000000,Max=5.000000)
        VelocityLossRange=(Z=(Min=0.025000,Max=0.025000))
        AddVelocityFromOtherEmitter=0
    End Object
    Emitters(15)=SpriteEmitter'SpriteEmitter63'

    Begin Object Class=SpriteEmitter Name=SpriteEmitter65
        FadeOut=True
        FadeIn=True
        RespawnDeadParticles=False
        SpinParticles=True
        UniformSize=True
        AutomaticInitialSpawning=False
        BlendBetweenSubdivisions=True
        UseRandomSubdivision=True
        ColorScale(0)=(Color=(B=255,G=255,R=255,A=255))
        ColorScale(1)=(RelativeTime=1.000000,Color=(B=255,G=255,R=255,A=255))
        FadeOutStartTime=2.500000
        FadeInEndTime=2.500000
        MaxParticles=100
      
        AddLocationFromOtherEmitter=1
        SpinsPerSecondRange=(X=(Min=0.050000,Max=0.100000),Y=(Min=0.050000,Max=0.100000),Z=(Min=0.050000,Max=0.100000))
        StartSpinRange=(X=(Max=1.000000),Y=(Max=1.000000),Z=(Max=1.000000))
        StartSizeRange=(X=(Min=225.000000,Max=225.000000),Y=(Min=225.000000,Max=225.000000),Z=(Min=225.000000,Max=225.000000))
        InitialParticlesPerSecond=30.000000
        Texture=Texture'ONSBPTextures.fX.ExploTrans'
        TextureUSubdivisions=2
        TextureVSubdivisions=2
        LifetimeRange=(Min=2.000000,Max=4.000000)
        InitialDelayRange=(Min=1.000000,Max=2.000000)
        StartVelocityRange=(Z=(Min=2.000000,Max=2.000000))
        AddVelocityFromOtherEmitter=1
    End Object
    Emitters(16)=SpriteEmitter'SpriteEmitter65'

    Begin Object Class=SpriteEmitter Name=SpriteEmitter66
        FadeOut=True
        FadeIn=True
        RespawnDeadParticles=False
        SpinParticles=True
        UniformSize=True
        AutomaticInitialSpawning=False
        BlendBetweenSubdivisions=True
        UseRandomSubdivision=True
        ColorScale(0)=(Color=(B=255,G=255,R=255,A=255))
        ColorScale(1)=(RelativeTime=1.000000,Color=(B=255,G=255,R=255,A=255))
        FadeOutStartTime=2.500000
        FadeInEndTime=2.500000
        MaxParticles=100
      
        AddLocationFromOtherEmitter=0
        SpinsPerSecondRange=(X=(Min=0.050000,Max=0.100000),Y=(Min=0.050000,Max=0.100000),Z=(Min=0.050000,Max=0.100000))
        StartSpinRange=(X=(Max=1.000000),Y=(Max=1.000000),Z=(Max=1.000000))
        StartSizeRange=(X=(Min=225.000000,Max=225.000000),Y=(Min=225.000000,Max=225.000000),Z=(Min=225.000000,Max=225.000000))
        InitialParticlesPerSecond=30.000000
        Texture=Texture'ONSBPTextures.fX.ExploTrans'
        TextureUSubdivisions=2
        TextureVSubdivisions=2
        LifetimeRange=(Min=2.000000,Max=4.000000)
        InitialDelayRange=(Min=1.000000,Max=2.000000)
        StartVelocityRange=(Z=(Min=2.000000,Max=2.000000))
        AddVelocityFromOtherEmitter=1
    End Object
    Emitters(17)=SpriteEmitter'SpriteEmitter66'

    Begin Object Class=SpriteEmitter Name=SpriteEmitter67
        UseDirectionAs=PTDU_Normal
        FadeOut=True
        RespawnDeadParticles=False
        UseSizeScale=True
        UseRegularSizeScale=False
        UniformSize=True
        AutomaticInitialSpawning=False
        ColorScale(0)=(Color=(G=175,R=255,A=255))
        ColorScale(1)=(RelativeTime=1.000000,Color=(G=175,R=255,A=255))
        Opacity=0.010000
        MaxParticles=120
      
        SpinsPerSecondRange=(X=(Min=0.050000,Max=0.100000),Y=(Min=0.050000,Max=0.100000),Z=(Min=0.050000,Max=0.100000))
        StartSpinRange=(X=(Max=1.000000),Y=(Max=1.000000),Z=(Max=1.000000))
        RotationNormal=(Z=1.000000)
        SizeScale(0)=(RelativeTime=1.000000,RelativeSize=6.000000)
        StartSizeRange=(X=(Max=400.000000),Y=(Max=400.000000),Z=(Max=400.000000))
        InitialParticlesPerSecond=180.000000
        Texture=Texture'AW-2004Particles.Weapons.PlasmaRing'
        LifetimeRange=(Min=1.000000,Max=1.000000)
    End Object
    Emitters(18)=SpriteEmitter'SpriteEmitter67'

        Begin Object Class=SpriteEmitter Name=SpriteEmitter0
         UseCollision=True
         UseColorScale=True
         FadeOut=True
         RespawnDeadParticles=False
         AlphaTest=False
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         AutomaticInitialSpawning=False
         Acceleration=(Z=100.000000)
         ExtentMultiplier=(X=0.400000,Y=0.400000,Z=0.400000)
         ColorScale(0)=(Color=(B=255,G=255,R=225,A=255))
         ColorScale(1)=(RelativeTime=0.032143,Color=(B=128,G=255,R=255,A=255))
         ColorScale(2)=(RelativeTime=0.064286,Color=(B=64,G=128,R=255,A=255))
         ColorScale(3)=(RelativeTime=0.121429,Color=(B=128,G=128,R=128,A=255))
         ColorScale(4)=(RelativeTime=1.000000,Color=(B=150,G=128,R=128,A=255))
         Opacity=0.650000
         FadeOutStartTime=3.000000
         FadeInEndTime=1.300000
         MaxParticles=30
         StartLocationShape=PTLS_Sphere
         SphereRadiusRange=(Min=2.000000,Max=5.000000)
         SpinsPerSecondRange=(X=(Max=0.050000))
         StartSpinRange=(X=(Max=1.000000))
         SizeScale(0)=(RelativeSize=0.100000)
         SizeScale(1)=(RelativeTime=0.070000,RelativeSize=0.500000)
         SizeScale(2)=(RelativeTime=0.140000,RelativeSize=0.700000)
         SizeScale(3)=(RelativeTime=0.340000,RelativeSize=0.900000)
         SizeScale(4)=(RelativeTime=1.000000,RelativeSize=1.000000)
         StartSizeRange=(X=(Max=300.000000),Y=(Max=300.000000),Z=(Max=300.000000))
         InitialParticlesPerSecond=50000.000000
         DrawStyle=PTDS_AlphaBlend
         Texture=Texture'BallisticEffects2.Particles.NewSmoke1g'
         SecondsBeforeInactive=0.000000
         LifetimeRange=(Min=10.000000,Max=10.000000)
         StartVelocityRange=(Z=(Min=-200.000000,Max=800.000000))
         StartVelocityRadialRange=(Min=-600.000000,Max=-300.000000)
         VelocityLossRange=(X=(Min=2.000000,Max=2.000000),Y=(Min=2.000000,Max=2.000000),Z=(Min=5.000000,Max=5.000000))
         GetVelocityDirectionFrom=PTVD_AddRadial
     End Object
     Emitters(19)=SpriteEmitter'BWBP_SKC_Fix.IE_SgtKellyNuke.SpriteEmitter0'

     Begin Object Class=SpriteEmitter Name=SpriteEmitter17
         UseDirectionAs=PTDU_Up
         UseColorScale=True
         FadeOut=True
         RespawnDeadParticles=False
         SpinParticles=True
         UniformSize=True
         ScaleSizeYByVelocity=True
         AutomaticInitialSpawning=False
         ColorScale(0)=(Color=(B=45,G=140,R=255,A=255))
         ColorScale(1)=(RelativeTime=0.214286,Color=(B=160,G=160,R=160,A=255))
         ColorScale(2)=(RelativeTime=1.000000,Color=(B=128,G=128,R=128,A=255))
         Opacity=0.680000
         FadeOutStartTime=0.200000
         MaxParticles=140
         StartLocationRange=(X=(Min=-2.000000,Max=2.000000),Y=(Min=-2.000000,Max=2.000000),Z=(Min=-2.000000,Max=2.000000))
         AddLocationFromOtherEmitter=2
         StartSpinRange=(X=(Min=0.250000,Max=0.250000))
         StartSizeRange=(X=(Min=40.000000,Max=50.000000),Y=(Min=40.000000,Max=50.000000),Z=(Min=40.000000,Max=50.000000))
         ScaleSizeByVelocityMultiplier=(Y=0.003000)
         InitialParticlesPerSecond=140.000000
         DrawStyle=PTDS_AlphaBlend
         Texture=Texture'BallisticEffects.Particles.Smoke6'
         SecondsBeforeInactive=0.000000
         LifetimeRange=(Min=1.800000,Max=1.800000)
         AddVelocityFromOtherEmitter=2
         AddVelocityMultiplierRange=(X=(Min=0.100000,Max=0.150000),Y=(Min=0.100000,Max=0.150000),Z=(Min=0.100000,Max=0.150000))
     End Object
     Emitters(20)=SpriteEmitter'BWBP_SKC_Fix.IE_SgtKellyNuke.SpriteEmitter17'

     Begin Object Class=MeshEmitter Name=MeshEmitter2
         StaticMesh=StaticMesh'BallisticHardware2.Impact.ConcreteChip2'
         UseMeshBlendMode=False
         UseParticleColor=True
         UseCollision=True
         FadeOut=True
         RespawnDeadParticles=False
         SpinParticles=True
         AutomaticInitialSpawning=False
         Acceleration=(Z=-800.000000)
         ExtentMultiplier=(X=0.500000,Y=0.500000,Z=0.500000)
         DampingFactorRange=(X=(Min=0.500000,Max=0.500000),Y=(Min=0.500000,Max=0.500000),Z=(Min=0.500000,Max=0.500000))
         ColorScale(0)=(Color=(B=255,G=255,R=255,A=255))
         ColorScale(1)=(RelativeTime=1.000000,Color=(B=255,G=255,R=255,A=255))
         ColorMultiplierRange=(Y=(Min=0.800000,Max=0.800000),Z=(Min=0.000000,Max=0.000000))
         FadeOutStartTime=0.370000
         MaxParticles=18
         SpinsPerSecondRange=(X=(Max=4.000000),Y=(Max=4.000000),Z=(Max=4.000000))
         StartSpinRange=(X=(Max=1.000000),Y=(Max=1.000000),Z=(Max=1.000000))
         StartSizeRange=(X=(Min=0.800000,Max=1.900000),Y=(Min=0.800000,Max=1.900000),Z=(Min=0.800000,Max=1.900000))
         InitialParticlesPerSecond=5000.000000
         SecondsBeforeInactive=0.000000
         MinSquaredVelocity=5000.000000
         LifetimeRange=(Min=2.000000,Max=2.000000)
         StartVelocityRange=(X=(Min=-700.000000,Max=700.000000),Y=(Min=-700.000000,Max=700.000000),Z=(Min=-100.000000,Max=800.000000))
     End Object
     Emitters(21)=MeshEmitter'BWBP_SKC_Fix.IE_SgtKellyNuke.MeshEmitter2'

     Begin Object Class=SpriteEmitter Name=SpriteEmitter1
         FadeOut=True
         RespawnDeadParticles=False
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         AutomaticInitialSpawning=False
         ColorScale(0)=(Color=(B=255,G=255,R=255,A=255))
         ColorScale(1)=(RelativeTime=1.000000,Color=(B=255,G=255,R=255,A=255))
         ColorMultiplierRange=(X=(Min=0.200000,Max=0.200000),Y=(Min=0.200000,Max=0.200000),Z=(Min=0.600000,Max=0.600000))
         FadeOutStartTime=0.200000
         MaxParticles=1
         SizeScale(1)=(RelativeTime=1.000000,RelativeSize=5.000000)
         StartSizeRange=(X=(Min=1500.000000,Max=1500.000000))
         InitialParticlesPerSecond=50000.000000
         DrawStyle=PTDS_Brighten
         Texture=Texture'BallisticEffects.Particles.Shockwave'
         SecondsBeforeInactive=0.000000
         LifetimeRange=(Min=0.900000,Max=0.900000)
     End Object
     Emitters(22)=SpriteEmitter'BWBP_SKC_Fix.IE_SgtKellyNuke.SpriteEmitter1'

     Begin Object Class=SpriteEmitter Name=SpriteEmitter24
         FadeOut=True
         FadeIn=True
         RespawnDeadParticles=False
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         AutomaticInitialSpawning=False
         ColorScale(0)=(Color=(B=255,G=255,R=255,A=255))
         ColorScale(1)=(RelativeTime=1.000000,Color=(B=255,G=255,R=255,A=255))
         ColorMultiplierRange=(X=(Min=0.900000),Y=(Min=0.760000,Max=0.760000),Z=(Min=0.400000,Max=0.400000))
         Opacity=0.320000
         FadeOutStartTime=0.090000
         FadeInEndTime=0.044000
         MaxParticles=12
         StartLocationRange=(X=(Min=-40.000000,Max=40.000000),Y=(Min=-40.000000,Max=40.000000),Z=(Min=-40.000000,Max=40.000000))
         SpinsPerSecondRange=(X=(Max=2.000000))
         StartSpinRange=(X=(Max=1.000000))
         SizeScale(0)=(RelativeSize=0.100000)
         SizeScale(1)=(RelativeTime=0.280000,RelativeSize=3.000000)
         SizeScale(2)=(RelativeTime=1.000000,RelativeSize=6.000000)
         StartSizeRange=(X=(Min=150.000000,Max=260.000000),Y=(Min=150.000000,Max=300.000000),Z=(Min=150.000000,Max=300.000000))
         InitialParticlesPerSecond=15.000000
         Texture=Texture'BallisticEffects.Particles.Explode2'
         SecondsBeforeInactive=0.000000
         LifetimeRange=(Min=0.400000,Max=0.400000)
         StartVelocityRange=(X=(Min=-70.000000,Max=70.000000),Y=(Min=-70.000000,Max=70.000000))
     End Object
     Emitters(23)=SpriteEmitter'BWBP_SKC_Fix.IE_SgtKellyNuke.SpriteEmitter24'

     Begin Object Class=SpriteEmitter Name=SpriteEmitter3
         FadeOut=True
         RespawnDeadParticles=False
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         AutomaticInitialSpawning=False
         ColorScale(0)=(Color=(B=255,G=255,R=255,A=255))
         ColorScale(1)=(RelativeTime=1.000000,Color=(B=255,G=155,R=155,A=255))
         FadeOutStartTime=0.100000
         MaxParticles=1
         StartSpinRange=(X=(Max=1.000000))
         SizeScale(1)=(RelativeTime=1.000000,RelativeSize=10.000000)
         InitialParticlesPerSecond=50000.000000
         Texture=Texture'BallisticEffects.Particles.Explode2'
         SecondsBeforeInactive=0.000000
         LifetimeRange=(Min=0.900000,Max=0.900000)
     End Object
     Emitters(24)=SpriteEmitter'BWBP_SKC_Fix.IE_SgtKellyNuke.SpriteEmitter3'

     Begin Object Class=SpriteEmitter Name=SpriteEmitter4
         UseCollision=True
         RespawnDeadParticles=False
         SpinParticles=True
         UniformSize=True
         AutomaticInitialSpawning=False
         ExtentMultiplier=(X=0.300000,Y=0.300000,Z=0.300000)
         DampingFactorRange=(X=(Min=0.500000,Max=0.500000),Y=(Min=0.500000,Max=0.500000),Z=(Min=0.700000,Max=0.700000))
         ColorScale(0)=(Color=(B=255,G=255,R=255,A=255))
         ColorScale(1)=(RelativeTime=1.000000,Color=(B=255,G=255,R=255,A=255))
         ColorMultiplierRange=(X=(Min=0.800000),Y=(Min=0.700000,Max=0.800000),Z=(Min=0.100000,Max=0.200000))
         Opacity=0.630000
         FadeOutStartTime=0.050000
         MaxParticles=9
         AddLocationFromOtherEmitter=5
         AlphaRef=128
         SpinsPerSecondRange=(X=(Max=2.000000))
         StartSizeRange=(X=(Min=70.000000,Max=80.000000),Y=(Min=70.000000,Max=80.000000),Z=(Min=70.000000,Max=80.000000))
         InitialParticlesPerSecond=50000.000000
         Texture=Texture'BallisticEffects.Particles.FlareB1'
         SecondsBeforeInactive=0.000000
         LifetimeRange=(Min=0.050000,Max=0.050000)
         StartVelocityRange=(Z=(Min=-100.000000))
         VelocityLossRange=(X=(Min=0.400000,Max=0.400000),Y=(Min=0.400000,Max=0.400000),Z=(Min=0.300000,Max=0.400000))
         AddVelocityFromOtherEmitter=5
     End Object
     Emitters(25)=SpriteEmitter'BWBP_SKC_Fix.IE_SgtKellyNuke.SpriteEmitter4'

       Begin Object Class=SpriteEmitter Name=SpriteEmitter5
         FadeOut=True
         FadeIn=True
         RespawnDeadParticles=False
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         AutomaticInitialSpawning=False
         ColorScale(0)=(Color=(B=255,G=255,R=255,A=255))
         ColorScale(1)=(RelativeTime=1.000000,Color=(B=255,G=255,R=255,A=255))
         ColorMultiplierRange=(X=(Min=0.900000),Y=(Min=0.080000,Max=0.160000),Z=(Min=0.400000,Max=0.400000))
         Opacity=0.320000
         FadeOutStartTime=0.189000
         FadeInEndTime=0.038500
         MaxParticles=12
         StartLocationRange=(X=(Min=-75.000000,Max=75.000000),Y=(Min=-75.000000,Max=75.000000))
         SpinsPerSecondRange=(X=(Max=0.250000))
         StartSpinRange=(X=(Max=1.000000))
         SizeScale(0)=(RelativeSize=0.250000)
         SizeScale(1)=(RelativeTime=1.000000,RelativeSize=3.000000)
         StartSizeRange=(X=(Min=600.000000,Max=1200.000000),Y=(Min=600.000000,Max=1200.000000),Z=(Min=600.000000,Max=1200.000000))
         InitialParticlesPerSecond=40.000000
         DrawStyle=PTDS_Brighten
         Texture=Texture'BWBP_SKC_Tex.BFG.BFGProj2'
         SecondsBeforeInactive=0.000000
         LifetimeRange=(Min=0.650000,Max=0.650000)
     End Object
     Emitters(26)=SpriteEmitter'BWBP_SKC_Fix.IE_SgtKellyNuke.SpriteEmitter5'

   
   
   
   
   
    bUnlit=True
    AutoDestroy=True
    bNetTemporary=True
    RemoteRole=ROLE_DumbProxy
    bNoDelete=False
   
  
     LightType=LT_Pulse
     LightEffect=LE_NonIncidence
     LightHue=30
     LightSaturation=150
     LightBrightness=150.000000
     LightRadius=252.000000
     LightPeriod=3


   
   
    Skins(0)=Texture'EpicParticles.Beams.RadialBands'
//    bUnlit=False
}
