
** hi5 spider to get out, rollover in web? greenhouse
** squirrel? say climb the washling line, that's what we do!
** 
** dig veg patch to find... carrots? potatoes? nom
** dig lawn to find... mole! show photo
** 
** spawn in greenhouse -> use hose to add water
** pickup (endless) spawn (with bucket)
** drop spawn in koi pond -> fish food!
** drop spawn in gold fish pond -> nothing, but set onEnter action (x2 ?) to make frogs -> pressie!
** 
** back lawn -> peanuts -> badger -> pressie
** 
** Wear moar clothes - just because!
** 
** Known Bug - if you take off your coat just before hoisting yourself up the washing line, you can wander the map without it on.
** If can then become trapped inside as you can't go outside without a coat. 
@Js class XEscape : Loader {
	
	private static const Str openDoorDesc := "You toss the lead into the air and its loop catches on the handle. You grasp the other end with your teeth and give it a tug. The door swings open."
	
	override GameData load() {
		prelude := "You awake from a long cosy slumber and fondly remember the exciting, long walks from yesterday."
		
		// todo have factories that make new objects
		
		msgFn := |Str msg-> |->Describe| | { |->Describe| { Describe(msg) } }
		
		newSnack := |->Object| {
			snack := [
				Object("dog biscuit", "A crunchy dog treat."),
				Object("dog chew", "Real rawhide coated with chicken flavouring."),
				Object("dog bone", "A large bone stuffed with extra marrow."),
				Object("dog treat", "A tasty snack for dogs"),
				Object("scooby snack", "Scooby, scooby, doo!"),
			].random
			snack.aliases = "snack biscuit chew bone treat".split
			snack.edible([
				"Om nom nom. Tasty!",
				"Yum, delicious!",
				"Chomp! Chomp! Chomp!",
				"Nom nom nom nom.",
				"Chew. Gnaw. Chomp. Swallow.",
				"Gulp!",
				"Bursting with energy, you feel ready for action like Scrappy Doo!",
			].random)
			return snack
		}

		parcelUp := |Object inside, Str from->Object| {
			Object("parcel", "A small parcel wrapped up in gift paper. I wonder what's inside?") {
				it.canPickUp = true
				it.aliases = Str[,]
				it.verbs = "open|rip open|tear open|rip|tear".split('|')
				it.onUse = |Object me, Player player -> Describe| {
					player.room.objects.add(inside)
					player.room.objects.remove(me)
					player.openParcel(from)
					return Describe("You excitedly rip open the parcel, sending wrapping paper everywhere, to reveal ${inside.fullName}.")
				}
			}
		}

		present1 := Object("bottle of gin", "An expensive bottle of fine English gin.") {
			it.aliases = "gin".split
			it.verbs = "drink swig sip gulp".split
			it.canPickUp = true
			it.onUse = |Object me, Player player -> Describe?| {
				// TODO max 3 swigs - stagger about to exits-2, exits-1
				return Describe("You swig the gin. You feel woozy.") + player.gameStats.incSnacks
			}
		}
		present2 := Object("box of chocolates", "A small box of assorted milk chocolates.") {
			it.aliases = "box chocolates".split
			it.edible("You scoff the chocolates with all the finesse you'd expect from a dog.")
		}
		present3 := Object("box of chocolates", "A small box of assorted milk chocolates.") {
			it.aliases = "box chocolates".split
			it.edible("You scoff the chocolates with all the finesse you'd expect from a dog.")
		}

		photoOfEmma := |->Object| {
				Object("photo of emma", "It is a photo of your favourite play pal, Emma. You really miss her and long for some tender strokes. You remember walks in the long grass, frolics, and sausage surprises. You wish you could do it all again. But where is she? You feel a mission brewing...") {
				it.aliases = "photo emma".split
				it.verbs = "show give".split
				it.canPickUp = true
				it.onUse = |Object me, Player player -> Describe?| {
					if (player.room.has("birds")) {
						desc := Describe("You show the birds the photo of Emma. The birds gather round and chirp excitedly at the sight of their feeder. You point at the photo and shrug your shoulders to ask where Emma may be. A couple of crows land and yell, \"Carr, Carr!\" You think they may be trying to tell you something.")
						if (player.hasOpenedParcel("birds"))
							return desc
						player.room.objects.add(parcelUp(present1, "birds"))
						return desc += "In appreciation of their favourite feeder, the birds drop a present for you."
					}
					if (player.room.has("goldfish")) {
						desc := Describe("You show the goldfish the photo of Emma. They swim around in excited circles - they love the sight of their feeder!")
						if (player.hasOpenedParcel("goldfish"))
							return desc
						player.room.objects.add(parcelUp(present2, "goldfish"))
						return desc += "So much so, they nose up a little gift from the bottom of the pond!"
					}
					if (player.room.has("koi carp")) {
						if (!player.isWearing("snorkel"))
							return Describe("You try to show the koi the photo of Emma, but from the bottom of the pond they can't see it.")

						if (!player.room.has("bubbles")) {
							player.room.add(Object("Bubbles the Koi Carp", "A large joyful, orange and white fish who likes to swim by the surface and blow bubbles!") {
								it.aliases = "bubbles".split
								it.onHi5 = |->Describe| {
									player.incHi5("Bubbles")
									return Describe("Bubbles rolls onto his side to expose a fishy fin. You slap paw and fin and exclaim, \"High five!\" Bubbles then performs a victory roll in acknowledgement.")
								}
							})
						}

						desc1 := Describe("With the mask and snorkel firmly attached, you thrust your head deep into the pond. When the bubbles clear, giant fish appear.\n\n\"I am Ginger.\" said one, \"The king of the wet lands. And this is Bubbles.\" Bubbles blew some. It seems he's quite aptly named.\n\nGinger continued, \"To find the feeder, thou shalt require a water containment vessel.\"")
						desc2 := Describe("You try talking back, but it doesn't work, what with the snorkel and all. So you just wave goodbye instead.")
						if (player.hasOpenedParcel("koi carp"))
							return desc1 + desc2 
						player.room.objects.add(parcelUp(present3, "koi carp"))
						return desc1 + "\"And here is a small gift to help you on your quest.\"" + desc2
					}
					return null
				}
			}
		}

		newBirds := |Room room->Object| {
			Object("birds", "An assortment of tits, sparrows, and chaffinchs. All hopping around, chirping insistently, and scoffing the food.") {
				it.namePrefix = ""
				it.aliases = "bird".split
				it.verbs = "chase eat".split
				room.meta["birdsInGarden"] = true
				it.onPickUp = |Object me, Player player ->Describe?| {
					player.room.objects.remove(me)
					player.room.meta.remove("birdsInGarden")
					return Describe("You let your instinct take over and you manically sprint at the birds, tongue and drool handing out the side of your mouth. But alas, the birds are faster and fly away. All you can do is stand and watch them fly away.")
				}
				it.redirectOnUse(onPickUp)
			}
		}
		
		buzzardCheck := |Player player, Describe desc->Describe| {
			gardens := (Room[]) [`room:lawn`, `room:backLawn`, `room:frontLawn`].map |id->Room| { player.world.room(id) }
			if (gardens.all { it.meta["birdsInGarden"] == true }) {
				desc += "A loud screech pierces the air and all the birds instantly scatter.\n\nDaylight is eclipsed by the shadow of the enormous wingspan of a swooping buzzard. Attracted by the constant hive of activity in the gardens, the buzzard is here to feed. Its talons take a tight grip on your coat and it pounds the air with its wings. You no longer feel the ground under your feet."
				if (player.hasSmallBelly) {
					gardens.each { it.objects = it.objects.exclude { it.id == `obj:birds` } }
					player.transportTo(`room:birdsNest`)
					desc += "Before you know it, you're high above the garden looking down on the ponds below. The buzzard takes you into the trees before dropping you in a large makeshift nest and flying away, leaving you alone once more."
				} else {
					player.transportTo(`room:lawn`)
					desc += "The buzzard struggles with the weight of its new found prey and beats the air furiously. As much as it wanted to carry you to its lair, sheer will is no match for the size your belly. It drops you and powers away empty handed.\n\nAs thankful as you are that the danger has passed, you do wonder where you may have been taken otherwise."
					birds := player.room.findObject("birds")
					player.room.objects.remove(birds)
				}
			}
			return desc
		}
		
		onRollover := |Player player -> Describe?| {
			postman := player.room.findObject("postman")
			if (postman != null) {
				snacksGiven := (postman.meta["snacksGiven"] as Int) ?: 0
				if (snacksGiven >= 3)
					return Describe("Aww, the Postman is all out of dog treats.")
				postman.meta["snacksGiven"] = snacksGiven + 1
				player.room.objects.add(newSnack())
				return Describe("You rollover onto your back and the Postman rubs your belly. Amidst cries of \"You're so cute!\" the Postie digs around in his pocket, fishes out a dog treat, and tosses it into the hall.")
			}
			if (player.room.id == `room:goldfishPond`) {
				goldfish := player.room.findObject("goldfish")
				player.room.objects.remove(goldfish)
				return Describe("You roll on to your back, teeter on the edge of the pond, and loose your balance.\n\nSplosh!\n\nAs fast you fell in, you spring right out again - hoping nobody saw you. You give a little shake, trying to act cool. It may have worked too, if it wasn't for the pond weed on your head!\n\nIt impressed no-one.") 				
			}
			if (player.room.id == `room:koiPond`) {
				koiCarp := player.room.findObject("koi carp")
				bubbles := player.room.findObject("bubbles")
				player.room.objects.remove(koiCarp)
				player.room.objects.remove(bubbles)
				return Describe("You roll on to your back, teeter on the edge of the pond, and loose your balance.\n\nSplosh!\n\nAs fast you fell in, you spring right out again - hoping nobody saw you. You give a little shake, trying to act cool. It may have worked too, if it wasn't for the pond weed on your head!\n\nIt impressed no-one.") 				
			}
			if (player.room.id == `room:garageRoof`) {
				player.room.meta["buzzard.avoided"] = true
				return Describe("A loud screech once again pierces the air and a buzzard swoops in from behind. You react fast and rollover.\n\nSparks explode around you as powerful talons drag across the roof and claws grasp nothing. Momentum carries the buzzard onward and it is forced to fly away empty handed. The danger has passed.") 
			}
			emma := player.room.findObject("emma")
			if (emma!= null) {
				snacksGiven := (emma.meta["snacksGiven"] as Int) ?: 0
				if (snacksGiven >= 5)
					return Describe("Aww, Emma is all out of dog treats.")
				emma.meta["snacksGiven"] = snacksGiven + 1
				player.room.objects.add(newSnack())
				return Describe("You rollover onto your back and Emma rubs your belly. You writhe your head in joy as Emma cries out \"Who's a good girl!?\" She's so impressed!\n\nEmma digs around in her coat pocket and fishes out a dog treat.")
			}
			return null
		}
		
		boots := Object("pair of boots", "A pair of shiny red dog booties with sticky soles.") {
			it.canPickUp = true
			it.aliases = "boots".split
			it.canWear = true
			it.onWear = |->Describe| { Describe("You slip the booties on over your back paws and fasten the velcro. They're a nice snug fit.") }
		}
		
		postman := Object("Postman", "You see a burly figure in red costume carrying a large sack of goodies.") {
			it.onHi5 = |Object me, Player player -> Describe| {
				player.room.objects.add(parcelUp(boots, "Postman"))
				player.room.objects.remove(me)
				player.room.findExit("north")
					.block(
						"But it looks so cold and windy outside.", 
						"As soon as you step outside, the cold hits you. Brr! You dash back in side to the safety of the warm house.", 
						"Your coat keeps you warm."
					) { !player.isWearing("coat") }
				player.incHi5("Postman")
				return Describe("You hang your paw in the air. The Postman kneels down, but instead of a 'high five' he whips out a signature scanner and collects your paw print!\n\n\"Thanks!\" he cheerfully says, tosses a parcel into the hallway, and disappears off down the garden path.")
			}
		}

		climbWashingLine := |Object obj, Player player->Describe?| {
			if (player.room.id != `room:backLawn`) return null

			if (obj.matches("hosepipe")) {
				hosepipe := obj
				if (player.meta["washingLine.clipped"] == true) {

					// drop whatever you're holding - it makes no sense to jump with it
					hose := player.inventory.first
					if (hose != null) {
						player.inventory.remove(hose)
						player.room.add(hose)
					}

					player.transportTo(`room:washingLine`)
					player.meta.remove("washingLine.clipped")
					player.canMove = true
					player.onMove = null
					return Describe("You aim the hosepipe nozzle at the suspended bucket and pull the trigger. Excitement mounts as the bucket begins to fill with water.\n\nAt first, the washing line sags. But then, the line tightens. As the bucket gets heavier, the laws of physics pull you sky ward. Nearing the washing line itself you scrabble and grab hold of the iron pipe support.\n\nYou unclip the lead, drop the hose, and look around.")
				}
				return null
			}
			
			canClimbWashingLine :=
				(player.has("lead"  ) || player.room.has("lead"  )) &&
				(player.has("bucket") || player.room.has("bucket")) &&
				 player.isWearing("harness")

			if (canClimbWashingLine) {
				if (player.meta["washingLine.clipped"] == true) {
					player.meta.remove("washingLine.clipped")
					player.canMove = true
					player.onMove = null
					return Describe("You unclip yourself and the bucket from the home made pully system.")
				} else {
					player.meta["washingLine.clipped"] = true
					player.canMove = false
					player.onMove = |->Describe| { Describe("You move forward but are pulled back by the harness / bucket contraption to which you're attached.") }
					return Describe("You clip one end of the lead to your harness and the other to the bucket, which you swing over the washing line.\n\nLooking at the bucket swaying in the air above you, you note that it could make a good pully system; if only you had something to fill it with to counter balance your weight!")
				}
			}
			return null
		}
		
		rooms := Room[
			Room("cage", "The cage is just small enough for you to fit in and the floor is lined with a soft duvet. There is a pink handkerchief tied across the top, it reads, \"Ssecnirp\".") {
				it.namePrefix = "in a"
				it.meta["inside"] = true
				Exit(ExitType.out, `room:diningRoom`, "You see the main dining room of the house and recall many a happy day stretched out in the sun as it streamed in through the wide windows.")
					.oneTimeMsg("You crawl out of the cage. You arch your back, stretch out your front legs, and let out a large yawn - it was a good nights sleep!"), 
				photoOfEmma(),
				newSnack(),
			},
			
			Room("dining room", "The dining room is where you spend the majority of your contented days, sunning yourself in beams of light that stream through the windows.") {
				it.meta["inside"] = true
				Exit(ExitType.in, `room:cage`, "The cage is where you sleep at night, dreaming of chasing ducks by the canal."),
				Exit(ExitType.north, `room:lounge`, "An open archway leads to the lounge."),
				Exit(ExitType.west, `room:kitchen`, "The kitchen! That tiled floor looks slippery though.") {
					it.block(
						"", 
						"You step out onto the slippery tiles. The pads on your little legs have no grip and you start slipping and sliding everywhere. You frantically try to run but your splayed legs are in all directions. With luck and determination you manage to return back to the safety of carpet and the back room.", 
						"Your little booties give you traction on the slippery tiles."
					) |me, player| { !player.isWearing("boots") }
				},
				Object("short lead", "A short black training lead with a loop on one end.") {
					it.canPickUp = true
					it.aliases = ["Lead"]
					it.verbs = "throw".split
					it.onUse = 	|Object lead, Player player -> Describe?| {
						desc := climbWashingLine(lead, player)
						if (desc != null) return desc
						door := player.room.findObject("door")
						if (door != null)
							return door.onUse?.call(door, player)
						return null
					}
				},
				Object("mystery box", "A cardboard box filled with scrunched up newspaper, although your nose also detects traces of food.") {
					it.aliases = "box".split('|')
					it.verbs   = "lookin|look in|rummage|rummage in".split('|')
					it.onUse   = |Object me, Player player -> Describe?| {
						win := [1, 0, 0, 1, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 1, 0, 0, 0]
						idx := (Int) me.meta.getOrAdd("win") { -1 }
						idx ++
						if (idx >= win.size) idx = 0
						me.meta["win"] = idx
						
						desc  := "You thrust your head into the box and have a good snort around. You rustle around the newspaper to find "
						if (win[idx] == 0)
							return Describe(desc + "nothing.")
						snack := newSnack()
						player.room.objects.add(snack)
						return Describe(desc + snack.fullName + "!")
					}
				},
				newSnack(),
			},
			
			Room("lounge", "The lounge is where you spend your evenings, happily gnawing bones on the Sofa with Emma and Steve.") {
				it.meta["inside"] = true
				Exit(ExitType.south, `room:diningRoom`, "An open archway leads to the dining room."),
				Exit(ExitType.west, `room:hallway`, "A door leads to the hallway.")
					.block("It is closed.", "You move forward and bang your head on the door. It remains closed."),
				Object("door", "The door guards the hallway. Its handle looms high overhead, out of your reach.") {
					it.openExit("lead", "west", openDoorDesc)
				},
				Object("television", "The door guards the hallway. Its handle looms high overhead, out of your reach.") {
					it.aliases = "tv".split
					it.onHi5 = |Object tv, Player player->Describe?| {
						player.incHi5("TV")
						if (tv.meta["on"] == true) {
							tv.meta.remove("on")
							return Describe("You slap the power button once more and the TV flickers off.")
						}
						tv.meta["on"] = true
						return Describe("You high five the TV and slap the power button. The TV blinks, flashes, then tunes in.\n\nIt's a TV show about flying super heros, all dressed in capes and everything! If only Emma and Steve were here to watch it with you!")
					}
				},
			},

			Room("hallway", "You hear a door bell ring.") {
				it.meta["inside"] = true
				Exit(ExitType.east, `room:lounge`),
				Exit(ExitType.north, `room:frontLawn`)
					.block("It is closed.", "You move forward and bang your head on the door. It remains closed."),
				Object("front door", "It is the main door to the house. Its handle looms high overhead, out of your reach.") {
					it.aliases = "door".split
					it.openExit("lead", "north", openDoorDesc + ".. to reveal a burly Postman!") |door, exit, player| {
						player.room.desc = ""
						player.room.objects.add(postman)
						exit.block("The Postman blocks your path.", "You quickly dash forward but the Postman is quicker. He blocks your exit and ushers you back inside.")
					}
				},
			},

			Room("kitchen", "Tall shaker style kitchen cabinets line the walls in a Cheshire Oak finish, with a real Welsh slate worktop peeking over the top. You know that food magically appears from up there somehow, if only you were a little bit taller!") {
				it.meta["inside"] = true
				Exit(ExitType.east, `room:diningRoom`),
				Exit(ExitType.west, `room:backPorch`)
					.block("It is closed.", "You move forward and bang your head on the door. It remains closed."),
				Object("back door", "The tradesman's entrance to the house. Its handle looms high overhead, out of your reach.") {
					it.aliases = "door".split
					it.openExit("lead", "west", openDoorDesc)
				},
				Object("oven", "A frequently used oven where baked delights are born.") {
					it.verbs = "open".split
					it.onLook = |Object oven, Player player -> Describe?| {
						cake := Object("birthday cake", "A fat vanilla sponge with lemon drizzle on top and cream in the middle.") {
							it.aliases = "cake".split
							it.edible("You plunge your head in and devour the cake with all the finesse of a Tazmanian devil. Emma would be proud!")
							it.verbs.add("savage")
						}
						player.room.objects.add(cake)
						oven.onLook = null
						return Describe("You lower the oven door to be greeted with a blast of warm air. The room fills with the sweet fragrance of edible goodies. You peer inside to find to find a Birthday cake!")
					}
					it.redirectOnUse(it.onLook)
				}
			},

			Room("back porch", "You see damp remains of an old coal shed with condensation and filtered rain water dripping from the ceiling.") {
				it.meta["inside"] = true
				Exit(ExitType.west, `room:outHouse`),
				Exit(ExitType.east, `room:kitchen`) {
					it.block(
						"", 
						"You step out onto the slippery tiles. The pads on your little legs have no grip and you start slipping and sliding everywhere. You frantically try to run but your splayed legs are in all directions. With luck and determination you manage to return back to the out house.", 
						"Your little booties give you traction on the slippery tiles."
					) |me, player| { !player.isWearing("boots") }
				},
				Exit(ExitType.north, `room:driveway`)
					.block("It is closed.", "You move forward and bang your head on the door. It remains closed."),
				Exit(ExitType.south, `room:patio`)
					.block("It is closed.", "You move forward and bang your head on the door. It remains closed."),
				Object("door", "The door to the patio outside. Its handle looms high overhead, out of your reach.") {
					it.openExit("lead", "south", openDoorDesc) |door, exit, player| {
						exit.block(
							"But it looks so cold and windy outside.", 
							"As soon as you step outside, the cold hits you. Brr! You dash back in side to the safety of the warmth.", 
							"Your coat keeps you warm."
						) { !player.isWearing("coat") }
					}
				},
				Object("door", "The door to the driveway outside. Its handle looms high overhead, out of your reach.") {
					it.openExit("lead", "north", openDoorDesc) |door, exit, player| {
						exit.block(
							"But it looks so cold and windy outside.", 
							"As soon as you step outside, the cold hits you. Brr! You dash back in side to the safety of the warmth.", 
							"Your coat keeps you warm."
						) { !player.isWearing("coat") }
					}
				},
			},

			Room("out house", "The converted coal shed is now used as a pantry and general utility room. It's been painted in an unusual yellow cream colour.") {
				it.meta["inside"] = true
				Exit(ExitType.east, `room:backPorch`),
				Object("washing machine", "A front loading washing machine. It looks like it's recently finished a wash.") {
					it.verbs = "open".split
					it.onLook = |Object oven, Player player -> Describe?| {
						coat := Object("coat", "A bright pink thermal dog coat, designed to keep the cold at bay.") {
							it.canPickUp = true
							it.canWear	 = true
							it.onWear	 = |->Describe| {
								if (player.meta["tooColdToMove"] == true) {
									player.canMove = true
									player.onMove = null
									player.meta.remove("tooColdToMove")
								}
								return Describe("You pull the coat on over your head and tie the velcro straps around your waist. Ahh, toasty warm!")
							}
							it.onTakeOff = |->Describe?| {
								// taking the coat off outside immobilises you
								if (player.room.meta["inside"] != true) {
									player.meta["tooColdToMove"] = true
									player.canMove = false
									player.onMove = |->Describe?| { Describe("Your mind lunges forward, but your body does not. It is so cold, you've frozen to the spot!") }
									return Describe("You take your coat off and immediately regret it as you start shivering. It's sooo cold out here!")
								}
								return null
							}
						}
						player.room.objects.add(coat)
						oven.onLook = null
						return Describe("You open the washing machine door and pull out a clean and dry, pink dog coat.")
					}
					it.redirectOnUse(it.onLook)
				},
				Object("sack of peanuts", "A large 15Kg sack of peanuts. There's a note pinned to it that reads, \"Larry the Badger's favourite.\"") {
					it.aliases = "peanuts nuts".split
					it.onPickUp = |Object food, Player player -> Describe?| {
						player.inventory.add(Object("peanuts", "A small scoop of peanuts.") {
							it.aliases = "peanuts nuts".split
//							it.verbs = "throw scatter feed".split	// this is for eating!
							it.namePrefix = ""
							it.edible("Unable to contain your desires, you gobble down the nuts.")
							it.onDrop = |Object seed->Describe?| {
								if (player.room.id == `room:outHouse`) {
									seed.canDrop = false
									player.inventory.remove(seed)
									return Describe("You place the peanuts back in the sack.")									
								}
								if (player.room.id == `room:backLawn`) {
									food.canDrop = false
									player.inventory.remove(food)
									// FIXME larry!
									if (player.room.has("badger")) {
										return Describe("????")									
									} else {
										player.room.add(Object("Larry the badger", "?????") {
											it.namePrefix = ""
										})
										return Describe("????")									
									}
								}
								return null
							}
						})
						return Describe("Using a small plastic tray, you grab a scoop of peanuts.")

					}
					it.redirectOnUse(it.onPickUp)
				},
				Object("sack of bird seed", "A large 15Kg sack of bird seed. There's a note pinned to it that reads, \"If you feed them, they will come.\"") {
					it.aliases = "bird seed|birdseed|seed".split('|')
					it.onPickUp = |Object food, Player player -> Describe?| {
						player.inventory.add(Object("bird seed", "A small scoop of bird seed.") {
							it.aliases = "birdseed seed".split
//							it.verbs = "throw scatter feed".split	// this is for eating!
							it.namePrefix = ""
							it.edible("Unable to contain your desires, you lap up the seed.")
							it.onDrop = |Object seed->Describe?| {
								if (player.room.id == `room:outHouse`) {
									seed.canDrop = false
									player.inventory.remove(seed)
									return Describe("You place the seed back in the sack.")									
								}
								if (player.room.meta["isGarden"] == true && player.room.meta["birdsInGarden"] != true) {
									player.room.objects.add(newBirds(player.room))
									seed.canDrop = false
									player.inventory.remove(seed)
									desc := Describe("You scatter the seed around the garden and observe in wonder as a variety of garden birds appear from the hedgerows and start devouring the bird seed.")
									return buzzardCheck(player, desc)
								}
								return null
							}
						})
						return Describe("Using a small plastic tray, you grab a scoop of bird seed.")
					}
					it.redirectOnUse(it.onPickUp)
				},
				Object("box of fish food", "A large biscuit tin full of fish food. There's a note pinned to it that reads, \"If you feed them, they will come.\"") {
					it.aliases = "fish food|fishfood|food".split('|')
					it.onPickUp = |Object tin, Player player -> Describe?| {
						player.inventory.add(Object("fish food", "A small scoop of fish food.") {
							it.aliases = "fishfood food".split
//							it.verbs = "throw scatter feed".split	// this is for eating!
							it.namePrefix = ""
							it.inedible("Out of curiosity you gobble up some fish food. But an instant rumbling in your belly makes you sick it all up again. You ponder if fish food is good for dogs?")
							it.onDrop = |Object food->Describe?| {
								if (player.room.id == `room:outHouse`) {
									food.canDrop = false
									player.inventory.remove(food)
									return Describe("You place the fish food back in the box.")									
								}
								if (player.room.id == `room:goldfishPond`) {
									food.canDrop = false
									player.inventory.remove(food)
									if (player.room.has("goldfish")) {
										return Describe("You scatter the food about the pond and the goldfish dart about, nibbling for nourishment.")									
									} else {
										player.room.add(Object("goldfish", "A plethora of gold, yellow, and mottled white gold fish.") {
											it.namePrefix = ""
										})
										return Describe("You scatter the food about the pond and then, out from behind rocks, weeds, and crevices, goldfish begin to appear!")									
									}
								}
								if (player.room.id == `room:koiPond`) {
									food.canDrop = false
									player.inventory.remove(food)
									if (player.room.has("koi carp")) {
										return Describe("You scatter the food about the pond and the koi largely ignore it, instead waiting for it to sink to the bottom before picking at it. It's not the feeding frenzy you were expecting!")									
									} else {
										player.room.add(Object("koi carp", "You see several orange, white, and gold mottled koi fish - although they keep themselves fairly well hidden at the bottom of the pond.") {
											it.namePrefix = ""
											it.aliases = "koi carp fish".split
										})
										return Describe("You scatter the food about the pond and then, from the murky depths below, several koi carp appear!")									
									}
								}
								return null
							}
						})
						return Describe("Using a small plastic tray, you grab a scoop of fish food.")
					}
					it.redirectOnUse(it.onPickUp)
				},
			},

			Room("front lawn", "The front lawn is an odd triangle shaped piece of land that adjoins the driveway. It is hemmed in by a thick hedge.\n\nThere's a bird table in the middle which suggests Emma feeds the birds here.") {
				it.namePrefix = "on the"
				it.meta["isGarden"] = true
				Exit(ExitType.south, `room:hallway`, "The front door to the house leading to the hallway."),
				Exit(ExitType.north, `room:theAvenue`).block("A heavy iron gate keeps you on the premises.", "A heavy iron gate keeps you on the premises"),
				Exit(ExitType.west, `room:driveway`),
			},

			Room("driveway", "The concrete driveway is adjacent to the front lawn and leads down to the avenue. A car is parked in the middle.") {
				it.namePrefix = "on the"
				Exit(ExitType.south, `room:backPorch`, "A door leads into the back porch."),
				Exit(ExitType.north, `room:theAvenue`).block("A heavy iron gate keeps you on the premises", "A heavy iron gate keeps you on the premises"),
				Exit(ExitType.east, `room:frontLawn`),
				Exit(ExitType.in, `room:garage`, "A small garage fronted with a large bright red, vertical lift, metal door.") {
					it.block("The door is closed.", "You sprint at the door and bounce off with a large clang. The door remains closed.")
				},

				Object("car", "A Golf 1.9 TDI. Colour, shark grey. The car is locked and all the doors are closed."),

				Object("garage door", "It is a large vertical lift, bright red, metal door.") {
					it.aliases = "door garage".split
					it.openExit("silver key", "in", "You use the key to unlock the door. The sprung hinge at the top lifts the door up and into the garage.") |Object door, Exit exit, Player player| {
						key := player.findObject("silver key")
						player.inventory.remove(key)
					}
				},
			},
			Room("garage", "A new paint job hides the drab looking pre-fabricated concrete walls. The garage is filled with boxes and bric-a-brac.") {
				Exit(ExitType.out, `room:driveway`),
				Object("harness", "A black and yellow walking harness adorned with the words, \"Dog's Trust\".") {
					it.canPickUp = true
					it.canWear = true
					it.onWear = |->Describe| { Describe("You slip the harness on over your coat and snap the buckles closed.") }
				},
				Object("mask and snorkel", "A well used, but perfectly adequate, mask and snorkel.") {
					it.aliases = "mask snorkel".split
					it.canPickUp = true
					it.canWear = true
					it.onWear = |->Describe| { Describe("You pull the mask on over your head and fix the snorkel in your mouth.") }
				},
				newSnack(),
			},

			Room("the avenue", "The Avenue, also known as The Ave.") {
				it.meta["noExits"] = true	// no entrance, no exits!
			},

			Room("patio", "Large paving slabs adorn the floor, lined with potted trees and shrubs.") {
				it.namePrefix = "on the"
				Exit(ExitType.north, `room:backPorch`, "A door leads into the back porch."),
				Exit(ExitType.south, `room:goldfishPond`, "A couple of stone steps lead up to the goldfish pond"),
				Object("expandable hosepipe", "A long expandable hosepipe with spray nozzle attachment.") {
					it.aliases = "hose|hosepipe|hose pipe".split('|')
					it.canPickUp = true
					it.onUse = |Object hosepipe, Player player -> Describe?| {
						desc := climbWashingLine(hosepipe, player)
						if (desc != null) return desc
						return null
					}
				}
			},

			Room("goldfish pond", "It is a shallow square pond full of weeds.") {
				it.namePrefix = "next to the"
				Exit(ExitType.east, `room:koiPond`),
				Exit(ExitType.north, `room:patio`, "A couple of stone steps lead down to the patio."),
				Exit(ExitType.south, `room:vegetablePatch`),
			},

			Room("koi pond", "The koi pond is a deep picturesque garden pond with a slate surround, complete with a cascading waterfall feature in the corner.") {
				it.namePrefix = "next to the"
				Exit(ExitType.west, `room:goldfishPond`),
				Exit(ExitType.north, `room:backLawn`),
				Exit(ExitType.south, `room:lawn`),
			},

			Room("back lawn", "The back lawn is a patch of grass that backs up to the dining room window.\n\nIt is a popular feeding ground for birds and other animals as the adjoining hedgerow gives plenty of shelter.") {
				it.namePrefix = "on the"
				it.meta["isGarden"] = true
				Exit(ExitType.south, `room:koiPond`),
				Exit(ExitType.up, `room:washingLine`)
					.block("A tall cast iron pipe sunk deep in the ground leads up into the sky to support the washing line.", "You make like a squirrel and frantically paw, scrabble, and clamber at the washing line support. But as you slide back down the pipe you realise you're not a squirrel.", ""),
				Object("washing line", "A tall cast iron pipe sunk deep in the ground has a series of pullies at the top that holds up a make shift washing line. There must be quite a view from the top!") {
					it.aliases = "line".split
					it.verbs = "climb".split
					it.onUse = |Object washingLine, Player player -> Describe?| {
						desc := climbWashingLine(washingLine, player)
						if (desc != null) return desc
						return null
					}
				}
			},

			Room("lawn", "A featureless patch of grass in front of the summer house that's popular with the local avian wildlife, should there be enough food around.\n\nThe lawn also sports a lot of earth mounds and a couple of small holes.") {
				it.namePrefix = "on the"
				it.meta["isGarden"] = true
				Exit(ExitType.north, `room:koiPond`),
				Exit(ExitType.west, `room:vegetablePatch`),
				Exit(ExitType.in, `room:summerHouse`, "A patchwork of rotting wood that once was decking leads up to a small decaying door.") {
					it.isBlocked	= true
					it.descBlocked	= "A sea of dusty cobwebs roll from the summer house door to the nether reaches of the back walls."
					it.onExit = |Exit exit, Player player -> Describe?| {
						if (!player.has("rhubarb"))
							return Describe("You disturb the sea of dusty cobwebs as you enter. Spiders scuttle out from all directions and then stop. They hunch down, waiting, staring. All eight of their eyes watching, anticipating your next movement. Which, unsurprisingly, is to leg it back out of the summer house!")
						exit.isBlocked = false
						exit.onExit = |->Describe?| { Describe("Without webs to trap and ensnare, the spiders remain in hiding.") }
						return Describe("Gripping the the rhubarb firmly between your teeth you fearlessly bound into the summer house. You swing your head from side to side and brandish the stalk like a crazed sword fighter. With the cobwebs now all but destroyed the spiders retreat into the dark recesses of the cabin.")
					}
				},
			},

			Room("summer house", "Constructed of rotting wood the summer house is a dark and foreboding death trap. Inside, amongst the muddy garden tools a hundred eyes shine back at you from within the dim light.") {
				Exit(ExitType.out, `room:lawn`),
				Object("bucket", "A plastic yellow bucket with a handle, useful for carrying.") {
					it.canPickUp = true
					it.onUse = |Object bucket, Player player -> Describe?| {
						desc := climbWashingLine(bucket, player)
						if (desc != null) return desc
						return null
					}
				},
				Object("spade", "A stout digging utensil.") {
					it.canPickUp = true
					it.onUse = |Object spade, Player player -> Describe?| {
						if (player.room.id == `room:vegetablePatch`) {
							
						}
						if (player.room.id == `room:lawn`) {
							// FIXME mole
						}
						return null
					}
				},
				newSnack(),
			},

			Room("vegetable patch", "An old vegetable patch that's now mostly covered in wild strawberry creepers. In the corner sits a huge crown of rhubarb.") {
				Exit(ExitType.east,  `room:lawn`),
				Exit(ExitType.north, `room:goldfishPond`),
				Exit(ExitType.in,	 `room:greenhouse`),
				Object("rhubarb", "The rhubarb has eagerly grown into huge monster of a plant as if it were auditioning for a role in The Little Shop of Horrors! Its size means it gives a seemingly endless supply of stalks.") {
					it.namePrefix = ""
					it.aliases = "stick|stalk|stalk of rhubarb|stick of rhubarb".split('|')
					it.onPickUp = |Object food, Player player -> Describe?| {
						player.inventory.add(Object("stalk of rhubarb", "A large sturdy red stick of rhubarb. Good for whacking things with!") {
							it.aliases = "rhubarb stick stalk".split
							it.edible("Nibbling on the bulbous red end, you decide it's almost as tasty as rawhide.")
							it.onDrop = |Object rhubarb->Describe?| {
								if (player.room.id == `room:vegetablePatch`) {
									rhubarb.canDrop = false
									player.inventory.remove(rhubarb)
									return Describe("You drop the rhubarb back in the patch.")
								}
								return null
							}
						})
						return Describe("You jam your head into the plant and snap off a juicy stalk.")
					}
					it.redirectOnUse(it.onPickUp)
				},
			},

			Room("greenhouse", "") {
				Exit(ExitType.out, `room:vegetablePatch`),
				// FIXME Spider Fight!
			},
			
			Room("birds nest", "You are high in the trees with no obvious route back. The garden and house is sprawled out below you, and you see the car in the driveway. Wait! Was that movement you saw in the car just now?") {
				it.namePrefix = "in a large"
				Object("large egg", "A freshly laid bird egg.") {
					it.aliases = "egg".split
					it.edible("You gnaw a hole in the top and suck the contents out. A bit runny, but not bad. You use your paw to wipe your mouth and toss the empty husk over the side.")
//					it.canPickUp = false	// ??? it's just for the description
				},
				Exit(ExitType.out, `room:tree2`, "Twigs give way to a precarious looking branch.") {
					it.oneTimeMsg("You climb out of the nest, slip, and tumble on to a branch below. The ground looks a long way down and tree climbing is not strong point of yours!")
				},
			},

			Room("tree", "You are in a maze of twisty tree branches, all alike.") {
				it.namePrefix = "in a"
				it.id = `room:tree1`
				Exit(ExitType.up,    `room:tree4`),
				Exit(ExitType.down,  `room:tree3`),
				Exit(ExitType.north, `room:tree2`),
				Exit(ExitType.south, `room:tree2`),
			},
			Room("tree", "You are in a maze of twisty tree branches, all alike.") {
				it.namePrefix = "in a"
				it.id = `room:tree2`
				Object("silver key", "The silver key must have found its way to the nest the same you did! It's small but looks important.") {
					it.aliases = "key".split
					it.canPickUp = true
				},
				Exit(ExitType.west, `room:tree1`),
				Exit(ExitType.east, `room:tree1`),
				Exit(ExitType.up,   `room:tree3`),
				Exit(ExitType.down, `room:tree4`),
			},
			Room("tree", "You are in a maze of twisty tree branches, all alike.") {
				it.namePrefix = "in a"
				it.id = `room:tree3`
				Exit(ExitType.up,    `room:tree1`),
				Exit(ExitType.north, `room:tree4`),
				Exit(ExitType.south, `room:tree4`),
				Exit(ExitType.down,  `room:summerHouseRoof`, "This part of the tree looks recognisable, maybe all is not lost!") {
					it.oneTimeMsg("You drop down on to the roof of the summer house. Fantastic! Salvation of the garden awaits!\n\nOnly as you look around, you realise it's still a long, bone breaking, drop to the floor. Suddenly you feel a little scared again.")
				},
			},
			Room("tree", "You are in a maze of twisty tree branches, all alike.") {
				it.namePrefix = "in a"
				it.id = `room:tree4`
				Exit(ExitType.down, `room:tree1`),
				Exit(ExitType.up,   `room:tree4`),
				Exit(ExitType.east, `room:tree3`),
				Exit(ExitType.west, `room:tree3`),
			},

			Room("summer house roof", "You sit on the apex and wonder what to do.") {
				it.namePrefix = "on the"
				Object("squirrel", "A grey squirrel with a large bushy tail sits quietly on the opposite end. It stares at you, chewing nonchalantly.") {
					it.verbs = "chase|eat|grab|follow|stare at".split('|')
					it.onUse = |Object me, Player player -> Describe?| {
						player.transportTo(`room:lawn`)
						return Describe("You stare back at the fluffy squeaky thing in front of you. Your eyes widen, you can't contain yourself! Must chase!\n\nThe squirrel senses danger and darts off the roof, climbing down a wooden beam holding up the roof. Without a thought you do the same.\n\nBefore you know it, you're on the lawn. The squirrel has disappeared and you're left wondering how you got there!")
					}
				},
				Exit(ExitType.down, `room:lawn`, "You can see the garden lawn below, but it's way to far to jump!") {
					it.block("", "You teeter to the edge but crawl back when vertigo sets in!")
				},
			},

			Room("washing line", "Yikes! The ground looks much further away than you expected. You cling to the top of the pipe and look around at the garden and all the animals. Looking over the garage you see the car. The sun-roof is open and there appears to be a person inside.") {
				it.namePrefix = "on the"
				Exit(ExitType.down, `room:backLawn`, "You see the back lawn, a long way down.") {
					it.onExit = msgFn("You make like a squirrel and scamper down the pipe head first to the safety of Mother Earth.")
				},
				Exit(ExitType.north, `room:garageRoof`, "A vast expanse of thin air separates you and the corrugated metal roof of the garage.") {
					it.onExit = |Exit exit, Player player -> Describe?| {
						if (!player.isWearing("coat")) {
							exit.isBlocked = true
							return Describe("You have a plan! But it requires your coat...")
						}
						exit.isBlocked = false
						return Describe("All that time watching superhero films on the couch with Emma and Steve seemed to have paid off, because you have a plan! It's quite an easy one too.\n\nYou check your coat. It's loose and flappy enough to be considered a cape. And as every superdog knows, if you have a cape... you can fly!\n\nYou tense all the muscles in your legs then release an enormous burst of energy that sends you hurtling through the sky. But then gravity starts to take hold.\n\nYou begin to fall and the garage roof approaches fast. Your outstretched arms just manage to grab hold, quickly followed by a frantic scrabble of the hind legs.")
					}
				},
			},

			Room("garage roof", "The new roof is of polished corrugated steel. With the garden behind you, you peer over the north edge to see the driveway and the car. Ah, the car! That gateway to wondrous walks.\n\nStaring through the open sun-roof you see... Emma! Your heart quickens, there is no time to waste!") {
				it.namePrefix = "on the"
				Exit(ExitType.north, `room:car`, "The car and the open sun-roof is but a short jump away. You're sure you can make it!") {
					it.onExit = |Exit exit, Player player->Describe?| {
						buzzardAvoided := player.room.meta["buzzard.avoided"] == true
						player.room.meta.remove("buzzard.avoided")
						if (buzzardAvoided) {
							exit.isBlocked = false
							return Describe("Heart racing, you make one final heroic leap towards the car and the open sun-roof. You tuck your head and legs in, travel through the opening, and land on the passenger seat.")
						}
							
						desc := Describe("A loud screech once again pierces the air and you freeze with fear.\n\nFrom behind the buzzard swoops in and snatches you up in huge claws. You rise into the air as the powerful wings beat the air around.") 
						if (player.hasSmallBelly) {
							exit.isBlocked = true
							player.transportTo(`room:birdsNest`)
							desc += "Before you know it, you're high above the garden looking down on the ponds below. The buzzard takes you into the trees, drops you its nest, and flies away.\n\nYou berate yourself for being so close to your goal, and yet so careless. But what could you have done differently?"
						} else { 
							exit.isBlocked = true
							player.transportTo(`room:driveway`)
							desc += "The buzzard's eyes were larger than its stomach and it beats the air furiously as it struggles with your weight. You start to loose altitude, the buzzard finally gives up its breakfast and lets you go.\n\nYou wriggle in mid air to see where you're falling, and it appears to be towards the car! But alas, you bounce off the bonnet and land heavily on the floor. You curse yourself for being so careless, but what could you have done differently?"
						}

						return desc
					}
				},
			},

			Room("car", "\"Oh boy, oh boy, it's Emma the feeder, Emma the walker! Right here, next to me!\" You're so excited!\n\nYou run around on the seat, jump up at her, and lick her face. \"Oh there you are!\" says Emma, pushing you back down on the seat. \"I've been wondering where you got to, I've been waiting to take you out on a walk to the waterfalls, you'd like that wouldn't you!?\"\n\n\"And good, I see you're already dressed and ready to go out! Hop on the back seat then, and we'll go!\"\n\nWow, this all sounds fantastic!") {
				// oh, you're all dressed ready to go out!
				Exit(ExitType.north, `room:backSeatOfTheCar`, "The back seat of the car. It is covered in a dog blanket to keep mud and hair off the seat."),
				Object("Emma", "A beautiful Welsh woman dressed in wellies and a rain jacket.") {
					it.namePrefix = ""
					it.onHi5 = |Object emma, Player player -> Describe| {
						snacksGiven := (emma.meta["snacksGiven"] as Int) ?: 0
						if (snacksGiven >= 5)
							return Describe("Aww, Emma is all out of dog treats.")
						emma.meta["snacksGiven"] = snacksGiven + 1
						player.room.objects.add(newSnack())
						player.incHi5("Emma")
						return Describe("You high five Emma and Emma high fives back. It's what best buddies do! She digs around in her coat pocket and fishes out a dog treat.")
					}
				},
			},

			Room("back seat of the car", "You're so happy you've found Emma, all the morning's adventures were worth it! But the day is not over yet, and there may be more adventures to come.\n\nYou look eagerly out of the window as Emma starts the engine. This is going to be a great day!\n\n  - THE END -\n\n") {
				meta["noExits"] = true
				it.onEnter = |Room room, Player player->Describe?| { player.endThis; return null }
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
			it.onRollover		= onRollover
		}.validate
	}
}
