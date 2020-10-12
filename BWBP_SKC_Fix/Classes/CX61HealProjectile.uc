//=============================================================================
// CX61's flame projectile.
//=============================================================================
class CX61HealProjectile extends RSDarkFlameProjectile;

event Tick(float DT)
{
	super(BallisticProjectile).Tick(DT);
	if (vector(Rotation) Dot Normal(EndPoint-Location) < 0.0)
	{
		if (bHitWall)
			Destroy();
	}
}

function DoDamage (Actor Other, vector HitLocation)
{
	local Pawn	HealTarget;
	
	HealTarget = Pawn(Other);
	
	if (HealTarget == None)
		return;

	//bProjTarget is set False when a pawn is frozen in Freon.
	if (Instigator.Controller != None && HealTarget.Controller != None && HealTarget.Controller.SameTeamAs(Instigator.Controller))
	{
		if (BallisticPawn(Other) != None)
			BallisticPawn(HealTarget).GiveHealth(Damage, HealTarget.SuperHealthMax);
		else HealTarget.GiveHealth(Damage, HealTarget.SuperHealthMax);
		return;
	}
}

// Hit something interesting
simulated function ProcessTouch (Actor Other, vector HitLocation)
{
    local int i;

	if (Other == None || (!bCanHitOwner && (Other == Instigator || Other == Owner)))
		return;
	if (Other.Base == Instigator)
		return;
	for(i=0;i<AlreadyHit.length;i++)
		if (AlreadyHit[i] == Other)
			return;

	if (Role == ROLE_Authority)
		DoDamage(Other, HitLocation);
	
	if (CanPenetrate(Other) && Other != HitActor)
	{	// Projectile can go right through enemies
		AlreadyHit[AlreadyHit.length] = Other;
		HitActor = Other;
	}
	else	Destroy();
}


defaultproperties
{
     Speed=3000.000000
     Damage=3.000000
     MyDamageType=Class'BWBP_SKC_Fix.DT_CX61Burned'
     LifeSpan=0.300000
     CollisionRadius=32.000000
     CollisionHeight=32.000000

}
