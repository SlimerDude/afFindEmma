
@Js class Object : Describe {
	const	Uri			id
	const	Str			name
	const	Str			namePrefix
			Str			desc
			Bool		canPickUp
			Bool		canDrop
			Bool		canWear
			Bool		canTakeOff
//			Bool		canUse		// this makes no sense as it is queried *after* onUse() is called! There is no default use action.
//			Bool		canHi5		// as above - not needed if there is no default action
			Str[]		aliases
			Str[]		verbs
			Str:Obj?	meta		:= Str:Obj?[:]

	|Object, Player -> Describe?|?	onLook
	|Object, Player -> Describe?|?	onPickUp
	|Object, Player -> Describe?|?	onDrop
	|Object, Player -> Describe?|?	onWear
	|Object, Player -> Describe?|?	onTakeOff
	|Object, Player -> Describe?|?	onHi5
	|Object, Player -> Describe?|?	onUse	

	private new make(|This| f) { f(this) }

	new makeName(Str name, Str desc, |This|? f := null) {
		this.id			= `obj:${name.fromDisplayName}`
		this.name		= name
		this.desc		= desc
		this.canPickUp	= false
		this.canDrop	= true
//		this.canUse		= true
		this.canWear	= false
		this.canTakeOff	= true
		this.aliases	= Str#.emptyList
		this.verbs		= Str#.emptyList	// "use" added to verbs lower
		
		f?.call(this)
		
		if (namePrefix == null)
			namePrefix = "iouae".chars.contains(name[0].lower) ? "an" : "a"
		if (!namePrefix.endsWith(" ") && namePrefix.size > 0)
			namePrefix = namePrefix + " "
	}
	
	override Str describe() {
		describe := desc
		if (!describe.endsWith("\n")) describe = describe + "\n"
		return describe
	}
	
	internal Str fullName() {
		namePrefix + name
	}
	
	internal Bool matches(Str str) {
		name.lower == str || id.path.last == str || aliasesLower.contains(str)
	}

	internal Str? startsWith(Str str) {
		if (str.startsWith(name.lower))
			return name
		if (str.startsWith(id.path.last))
			return id.path.last
		return aliasesLower.find { str.startsWith(it) }
	}
	
	override Bool equals(Obj? that) { (that as Object)?.id == id }
	override Int hash() { id.hash }
	override Str toStr() { id.toStr }
	
	private once Str[] aliasesLower() {
		// do the lowering here, so we don't have to set aliases in the ctor
		aliases.map { it.lower }
	}
	
	internal once Str[] verbsLower() {
		// do the lowering here, so we don't have to set verbs in the ctor
		["use"].addAll(verbs.map { it.lower })
	}
	
	Void openExit(Str objStr, Str exitStr, Str onOpenMsg, |Object, Exit, Player|? onOpen := null) {
		verbs = verbs.rw.addAll("open".split)
		onUse = openExitFn(objStr, exitStr, onOpenMsg, onOpen)
	}
	
	Void edible(Str desc) {
		canPickUp = true
		verbs = verbs.rw.addAll("eat chomp gnaw chew trough swallow gulp scoff".split)
		onUse = edibleFn(desc)
	}
	
	Void inedible(Str desc) {
		canPickUp = true
		verbs = verbs.rw.addAll("eat chomp gnaw chew trough swallow gulp scoff".split)
		onUse = inedibleFn(desc)
	}
	
	Void redirectOnUse(|Object, Player->Describe?| event) {
		onUse = redirectOnUseFn(event)
	}
	
	Void redirectOnUseTo(Str[] objs) {
		if (objs.any { this.matches(it) })
			throw Err("Redirection causes recursion!")
		onUse = redirectOnUseToFn(objs)
	}
	
	static |Object, Player->Describe?| redirectOnUseToFn(Str[] objs) {
		|Object me, Player player -> Describe?| {
			obj := (Object?) objs.eachrWhile { player.room.findObject(it) }
			if (obj != null)
				return obj.onUse?.call(obj, player)
			return null
		}
	}
	
	static |Object, Player->Describe?| redirectOnUseFn(|Object, Player->Describe?| event) {
		|Object me, Player player -> Describe?| {
			event.call(me, player)
		}
	}

	static |Object, Player->Describe?| edibleFn(Str desc, |Object, Exit, Player|? onOpen := null) {
		|Object food, Player player -> Describe?| {
			descs := Describe?[,]
			player.inventory.remove(food)		// we're not sure where the food came from
			player.room.objects.remove(food)	// we're not sure where the food came from
			descs.add(Describe(desc))
			descs.add(player.gameStats.incSnacks)
			return Describe(descs)
		}
	}

	static |Object, Player->Describe?| inedibleFn(Str desc, |Object, Object?, Exit, Player|? onOpen := null) {
		|Object food, Player player -> Describe?| {
			descs := Describe?[,]
			player.inventory.remove(food)		// we're not sure where the food came from
			player.room.objects.remove(food)	// we're not sure where the food came from
			descs.add(Describe(desc))
			descs.add(player.gameStats.decBellySize)
			return Describe(descs)
		}
	}

	static |Object, Player->Describe?| openExitFn(Str objStr, Str exitStr, Str onUseMsg, |Object, Exit, Player|? onOpen := null) {
		|Object door, Player player -> Describe?| {
			if (player.has(objStr)) {
				exit := player.room.findExit(exitStr) ?: throw Err("$player.room has no exit $exitStr")
				exit.isBlocked = false
				player.room.objects.remove(door)
				onOpen?.call(door, exit, player)
				return Describe(onUseMsg)
			}
			return Describe("How would you do that?")
		}		
	}
}
