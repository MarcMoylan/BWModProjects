//=============================================================================
// CX61's flame projectile.
//=============================================================================
class CX61FlameProjectile extends RSDarkFlameProjectile;

event Tick(float DT)
{
	super(BallisticProjectile).Tick(DT);
	if (vector(Rotation) Dot Normal(EndPoint-Location) < 0.0)
	{
		if (bHitWall)
			HurtRadius(Damage, DamageRadius, MyRadiusDamageType, MomentumTransfer, EndPoint);
		Destroy();
	}
}

// Hit something interesting
simulated function ProcessTouch (Actor Other, vector HitLocation)
{
    local int i;
	local CX61ActorFire Burner;

	if (Other == None || (!bCanHitOwner && (Other == Instigator || Other == Owner)))
		return;
	if (Other.Base == Instigator)
		return;
	for(i=0;i<AlreadyHit.length;i++)
		if (AlreadyHit[i] == Other)
			return;

	if (Role == ROLE_Authority)
	{
		DoDamage(Other, HitLocation);

		if (Pawn(other) != None && Pawn(Other).Health > 0 && Vehicle(Other) == None)
		{
			for (i=0;i<Other.Attached.length;i++)
			{
				if (CX61ActorFire(Other.Attached[i])!=None)
				{
					CX61ActorFire(Other.Attached[i]).AddFuel(0.15);
					break;
				}
			}
			if (i>=Other.Attached.length)
			{
				Burner = Spawn(class'CX61ActorFire',Other,,Other.Location);
				Burner.Initialize(Other);
				if (Instigator!=None)
				{
					Burner.Instigator = Instigator;
					Burner.InstigatorController = Instigator.Controller;
				}
			}
		}
	}
	if (CanPenetrate(Other) && Other != HitActor)
	{	// Projectile can go right through enemies
		AlreadyHit[AlreadyHit.length] = Other;
		HitActor = Other;
	}
	else
	{
		HurtRadius(Damage, DamageRadius, MyRadiusDamageType, MomentumTransfer, EndPoint);
		Destroy();
	}
}


defaultproperties
{
     Speed=3000.000000
     Damage=4.000000
     MyDamageType=Class'BWBP_SKC_Fix.DT_CX61Burned'
     LifeSpan=0.300000
     CollisionRadius=32.000000
     CollisionHeight=32.000000

}
