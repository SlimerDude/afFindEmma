
class Game {
	
	Player?		player
	GameData?	gameData
	
	new make(|This| f) { f(this) }

	
	
	static Game load() {
		gameData := XEscape().load
		player	 := Player {
			it.inventory = Object[,]
			it.room		 = gameData.rooms[gameData.startRoomId]
			it.gameData	 = gameData
		}
		return Game {
			it.player 	= player
			it.gameData	= gameData
		}
	}
	Void save() {
	}
}

@Serializable
class GameData {
	
	Uri:Room 	rooms
	Uri:Object	objects
	Uri			startRoomId
	Uri[]		startInventory
	
	new make(|This| f) { f(this) }

	
	Room room(Uri id) {
		rooms.getOrThrow(id)
	}
	
	Object object(Uri id) {
		objects.getOrThrow(id)
	}
	
	** Walk through all the data, making sure the IDs exist / match up
	This validate() {
		room(startRoomId)
		startInventory.each { object(it) }
		
		rooms.each |room| {
			if (room.desc.isEmpty)
				log.warn("$room.id desc is empty")
			if (room.exits.isEmpty)
				log.warn("$room.id has no exits")
			room.exits.each |exit| {
				this.room(exit.exitToId)
			}
		}
		
		return this
	}
	
	private Log log() { typeof.pod.log }
}

mixin Loader {
	abstract GameData load()
}
