
class XEscape : Loader {
	
	private static const Str openDoorDesc := "You toss the lead into the air and its loop catches on the handle. You grasp the other end with your teeth and give it a tug. The door swings open."
	
	override GameData load() {
		prelude := "You awake from a long cosy slumber and fondly remember the exciting, long walks from yesterday."
		
		postman := Object("Postman", "...") {
			
		}
		
		rooms := Room[
			Room("Cage", "The cage is just small enough for you to fit in and the floor is lined with a soft duvet. There is a pink handkerchief tied across the top, it reads, \"Ssecnirp\".") {
				it.namePrefix = "in a"
				Exit(ExitType.out, `room:diningRoom`, "You see the main dining room of the house and recall many a happy day stretched out in the sun as it streamed in through the wide windows.") {
					it.oneTimeMsg("You crawl out of the cage. You arch your back, stretch out your front legs, and let out a large yawn - it was a good nights sleep!") 
				},
				Object("Photo of Emma", "It is a photo of your favourite play pal, Emma. You really miss her and long for some tender strokes. You remember walks in the long grass, frolics, and sausage surprises. You wish you could do it all again. But where is she? You feel a mission brewing...") {
					it.aliases = ["Photo"]
				},
			},
			
			Room("Dining Room", "The dining room is where you spend the majority of your contented days, sunning yourself in beams of light that stream through the windows.") {
				Exit(ExitType.in, `room:cage`, "The cage is where you sleep at night, dreaming of chasing ducks by the canal."),
				Exit(ExitType.south, `room:lounge`, "An open archway leads to the lounge."),
				Exit(ExitType.west, `room:kitchen`, "The kitchen! That tiled floor looks slippery though.") {
					it.block("You step out onto the slippery tiles. The pads on your little legs have no grip and you start slipping and sliding everywhere. You frantically try to run but your splayed legs are in all directions. With luck and determination you manage to return back to the safety of carpet and the back room.", "")
				},
				Object("Short Lead", "A short black training lead with a loop on one end.") {
					it.aliases = ["Lead"]
					it.verbs = "throw".split
				},
			},
			
			Room("Lounge", "The lounge is where you spend your evenings, happily gnawing bones on the Sofa with Emma and Steve.") {
				Exit(ExitType.north, `room:diningRoom`, "An open archway leads to the dining room."),
				Exit(ExitType.west, `room:hallway`, "A door leads to the hallway.") {
					it.block("You bang your head on the door. It remains closed.", "It is closed.")
				},
				Object("Door", "The door guards the hallway. Its handle looms high overhead, out of your reach.") {
					it.openExit("lead", "west", openDoorDesc)
				},
			},

			Room("Hallway", "You hear a door bell ring.") {
				Exit(ExitType.east, `room:lounge`),
				Exit(ExitType.south, `room:frontLawn`, "The door to the outside world. It looks cold though.") {
					it.block("You bang your head on the door. It remains closed.", "It is closed.")
				},
				Object("Front Door", "It is the main door to the house. Its handle looms high overhead, out of your reach.") {
					it.aliases = "door".split
					it.openExit("lead", "south", openDoorDesc + ".. to reveal a burly Postman!") |door, obj, exit, player| {
						player.room.desc = ""
						player.room.objects.add(postman)
						exit.block("You quickly dash forward but the Postman is quicker. He blocks your exit and ushers you back inside.", "The Postman blocks your path")
					}
				},
			},

			Room("Kitchen", "") {
				Exit(ExitType.east, `room:diningRoom`),
			},

			Room("Front Lawn", "") {
				Exit(ExitType.north, `room:hallway`),
			},
		]
		
		objs := Object[,]

		roomMap 	:= Uri:Room[:].addList(rooms) { it.id }
		objectMap	:= Uri:Object[:].addList(objs) { it.id }
		return GameData {
			it.prelude			= prelude
			it.rooms			= roomMap
			it.objects			= objectMap
			it.startRoomId		= `room:cage`
			it.startInventory	= Uri[,]
			it.onPickUp			= |Object obj, Player player -> Describe?| {
				if (player.inventory.size >= 1) {
					player.canPickUp = false
					return Describe("You are a dog, you have one mouth, you can not carry any more items!")
				}
				player.canPickUp = true
				return null
			}
		}.validate
	}

}
