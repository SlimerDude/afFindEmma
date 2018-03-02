
class TestPlayGame : Test {
	
	Game?	game
	Player?	player
	Syntax?	syntax

	Void testRunThrough() {
		game	= Game.load
		player	= game.player
		syntax	= Syntax()
		
		log("\nSTART\n-----\n\n")
		log(game.start)
		
"
 		look photo
 		move out
 		pickup lead
 		north
 		use lead on door
 		west
 		use lead on door
 		
 		rollover
 		eat snack
 		hi5 postman
 		rip open parcel
 		wear boots
 		
 		east
 		south
 		west
 		use lead on door
 		stats
 		
 ".splitLines.each { executeCmd(it) }
		
//		 executeCmd("eat snack")
		
		log("\n---\nEND\n\n")
	}
	
	Void executeCmd(Str cmdStr) {
		cmdStr = cmdStr.trim
		if (cmdStr.startsWith("//") || cmdStr.trim.isEmpty) return
		log("\n> ${cmdStr.upper}\n")
	
		cmd := syntax.compile(player, cmdStr)
		old := player.room
		des := cmd?.execute(player)
		if (des != null) {
			log("\n")
			log(des)
		}
	
		if (cmd == null)
			log("\nI do not understand.")
	
		if (player.room != old) {
			log("\n")
//			log(divider)
			log(player.look)
		}
	}
	
	Str divider() {
		"\n----\n\n"
	}
	
	Void log(Obj? obj) {
		des := obj as Describe ?: Describe(obj?.toStr)
		des?.with { Env.cur.out.print(des.describe) }
	}
}
