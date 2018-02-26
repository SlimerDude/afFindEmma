
class Syntax {

	static const Str[]	lookSynonyms		:= "look "							.split('|', false)
	static const Str[]	moveSynonyms		:= "move |go |exit "				.split('|', false)
	static const Str[]	pickupSynonyms		:= "pickup |pick up |take |get "	.split('|', false)
	static const Str[]	dropSynonyms		:= "drop "							.split('|', false)
	static const Str[]	useSynonyms			:= "use "							.split('|', false)
	static const Str[]	useJoins			:= "to |on |at |with "				.split('|', false)
	static const Str[]	statsSynonyms		:= "stats |statistics "				.split('|', false)
	static const Str[]	inventorySynonyms	:= "inventory "						.split('|', false)
	static const Str[]	hi5Synonyms			:= "hi5 |high five "				.split('|', false)
	
//	static const Str	lookSyntax			:= "^(?:CMD)(?: (EXIT|ROOM.OBJECT|USER.OBJECT))?\$"
//	static const Str	moveSyntax			:= "^(?:CMD) (EXIT)\$"
//	static const Str	pickupSyntax		:= "^(?:CMD) (ROOM.OBJECT)\$"
//	static const Str	dropSyntax			:= "^(?:CMD) (USER.OBJECT)\$"
//	static const Str	useSyntax			:= "^[USER.OBJECT.VERB] (USER.OBJECT) [to|on|at|with] (ROOM.OBJECT)\$"
//	static const Str	statsSyntax			:= "^(?:CMD)\$"
//	static const Str	inventorySyntax		:= "^(?:CMD)\$"
//	static const Str	hi5Syntax			:= "^(?:CMD) (ROOM.OBJECT)?\$"
	
	
	** Note there are game cmds and sys cmds
	Cmd? compile(Player player, Str cmdStr) {
		cmdStr = cmdStr.trim.lower
		cmd := null as Cmd
		
		// do custom matching so we keep parsing context and are able to give customised error messages
		// regex's just give a yes / no, it worked / it didn't work answer
		
		if (cmd == null)
			cmd = matchLook(player, cmdStr)		
		if (cmd == null)
			cmd = matchMove(player, cmdStr)		
		if (cmd == null)
			cmd = matchPickup(player, cmdStr)		
		if (cmd == null)
			cmd = matchDrop(player, cmdStr)		
		if (cmd == null)
			cmd = matchUse(player, cmdStr)		

		return cmd
	}
	
	Cmd? matchLook(Player player, Str cmdStr) {
		lookCmd := lookSynonyms.find { cmdStr.startsWith(it) || cmdStr == it.trimEnd }
		if (lookCmd == null) return null
		
		if (cmdStr == lookCmd.trimEnd)
			return Cmd {
				it.method	= Player#look
				it.args		= Obj#.emptyList
			}

		cmdStr = cmdStr[lookCmd.size..-1] 
		lookAt := null as Describe

		if (lookAt == null)
			lookAt = player.room.findExit(cmdStr)

		if (lookAt == null)
			lookAt = player.room.findObject(cmdStr)

		if (lookAt == null)
			lookAt = player.findObject(cmdStr)

		if (lookAt == null)
			return Cmd("404 - ${cmdStr.upper} not found.")

		return Cmd {
			it.method	= Player#look
			it.args		= [lookAt]
		}
	}

	Cmd? matchMove(Player player, Str cmdStr) {
		moveCmd := moveSynonyms.find { cmdStr.startsWith(it) || cmdStr == it.trimEnd }
		if (moveCmd == null) return null
		
		if (cmdStr == moveCmd.trimEnd)
			return Cmd("Move where?")

		cmdStr = cmdStr[moveCmd.size..-1] 
		exit := player.room.findExit(cmdStr)
		if (exit == null)
			return Cmd("There is no ${cmdStr.upper}.")

		return Cmd {
			it.method	= Player#move
			it.args		= [exit]
		}
	}

	Cmd? matchPickup(Player player, Str cmdStr) {
		pickupCmd := pickupSynonyms.find { cmdStr.startsWith(it) || cmdStr == it.trimEnd }
		if (pickupCmd == null) return null
		
		if (cmdStr == pickupCmd.trimEnd)
			return Cmd("Pick up what?")

		cmdStr = cmdStr[pickupCmd.size..-1] 
		object := player.room.findObject(cmdStr)
		if (object == null)
			return Cmd("There is no ${cmdStr.upper}.")

		return Cmd {
			it.method	= Player#pickup
			it.args		= [object]
		}
	}

	Cmd? matchDrop(Player player, Str cmdStr) {
		dropCmd := dropSynonyms.find { cmdStr.startsWith(it) || cmdStr == it.trimEnd }
		if (dropCmd == null) return null
		
		if (cmdStr == dropCmd.trimEnd)
			return Cmd("Pick up what?")

		cmdStr = cmdStr[dropCmd.size..-1] 
		object := player.findObject(cmdStr)
		if (object == null)
			return Cmd("There is no ${cmdStr.upper}.")

		return Cmd {
			it.method	= Player#drop
			it.args		= [object]
		}
	}

	Cmd? matchUse(Player player, Str cmdStr) {
		object := null as Object

		useCmd := useSynonyms.find { cmdStr.startsWith(it) || cmdStr == it.trimEnd }
		if (useCmd != null) {
			if (cmdStr == useCmd.trimEnd)
				return Cmd("Use what?")
			
			cmdStr = cmdStr[useCmd.size..-1] 
			object = player.inventory.find |obj->Bool| {
				objStr := obj.startsWith(cmdStr)
				if (objStr != null) {
					cmdStr = cmdStr[objStr.size..-1].trimStart
					return true
				}
				return false
			}
			if (object == null)
				return Cmd("There is no ${cmdStr.upper}.")
		}

		if (useCmd == null) {
			object = player.inventory.find |obj| {
				verbCmd := obj.verbsLower.find { cmdStr == it || cmdStr.startsWith(it + " ") }
				if (cmdStr == verbCmd)
					return false	// Cmd("Use what?")				
			
				verbStr := cmdStr[verbCmd.size+1..-1] 

				// check that the verb belongs to the obj
				objStr := obj.startsWith(verbStr)
				if (objStr != null) {
					cmdStr = verbStr[objStr.size..-1].trimStart
					return true
				}
				return false
			}
		}
		
		if (object == null)
			return Cmd("Use what?")				

		if (cmdStr.trimEnd.isEmpty)
			return Cmd {
				it.method	= Player#use
				it.args		= [object, null]
			}
		
		joinCmd := useJoins.find { cmdStr.startsWith(it) || cmdStr == it.trimEnd }
		if (joinCmd == null) return Cmd("Please rephrase.")
		
		if (cmdStr == joinCmd.trimEnd)
			return Cmd("Use ${object.name} on what?")

		cmdStr = cmdStr[joinCmd.size..-1] 
		object2 := player.room.findObject(cmdStr)
		if (object2 == null)
			return Cmd("There is no ${cmdStr.upper}.")

		return Cmd {
			it.method	= Player#use
			it.args		= [object, object2]
		}
	}
}

class Cmd {
	Method?	method
	Obj?[]?	args
	Str?	msg
	
	new make(|This| f) { f(this) }

	new makeMsg(Str msg) { this.msg = msg }
	
	Describe? execute(Player player) {
		msg != null
			? Describe(msg)
			: method.callOn(player, args)
	}
	
	override Str toStr() {
		msg != null
			? msg
			: method.name + "(" + args.join(", ") { it.toStr.upper } + ")"
	}
}