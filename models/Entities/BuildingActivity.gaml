/******************************************************************
* This file is part of COMOKIT, the GAMA CoVid19 Modeling Kit
* Relase 1.0, May 2020. See http://comokit.org for support and updates
* 
* An activity that can perform in a building.
* 
* Author:Patrick Taillandier
* Tags: covid19,epidemiology
******************************************************************/

@no_experiment

model CoVid19

import "BuildingIndividual.gaml"

import "../Constants.gaml"

import "Building Spatial Entities.gaml"

import "../../COMOKIT-Model/COMOKIT/Model/Entities/Biological Entity.gaml"


global {
	action create_activities {
		map<string, list<Room>> rooms_type <- Room group_by each.type;
		sanitation_rooms <- rooms_type[sanitation];
		if (use_sanitation and not empty(sanitation_rooms)) {
			create BuildingSanitation with:[activity_places:: sanitation_rooms];
		}
		
		loop ty over: rooms_type.keys  - [workplace_layer, entrance, sanitation]{
			create BuildingActivity {
				name <-  ty;
				activity_places <- rooms_type[ty];
			}
		}
		
		create BuildingWorking;
		create ActivityGoHome with:[activity_places:: BuildingEntrance as list];
		create ActivityEatOutside with:[activity_places:: BuildingEntrance as list];
		create BuildingMultiActivity with:[activity_places::CommonArea where (each.type = multi_act)];
		create ActivityGoToOffice;
		create ActivityVisitInpatient;
		create ActivityGoToMeeting;
		create ActivityGoToAdmissionRoom;
	}
}

species BuildingActivity {
	list<Room> activity_places;
	
	Room get_place(BuildingIndividual p) {
		if flip(0.3) {
			return activity_places with_max_of length(each.available_places);
		} else {
			list<Room> rs <- (activity_places where not empty(each.available_places));
			if empty(rs) {
				rs <- activity_places;
			}
			return rs closest_to p;
		}
	}
}

species ActivityGoToOffice parent: BuildingActivity {
	Room get_place(BuildingIndividual p) {
		return p.working_place;
	}
}

species ActivityVisitInpatient parent: BuildingActivity {
	Room get_place(BuildingIndividual p) {
		return one_of((Room where (each.type = WARD)) - p.current_room); 
	}
}

species ActivityGoToAdmissionRoom parent: BuildingActivity {
	Room get_place(BuildingIndividual p) {
		return one_of(Room where (each.type = ADMISSION_ROOM)); 
	}
}

species ActivityGoToMeeting parent: BuildingActivity {
	Room get_place(BuildingIndividual p) {
		return one_of(Room where (each.type = MEETING_ROOM)); 
	}
}

species BuildingMultiActivity parent: BuildingActivity {
	Room get_place(BuildingIndividual p) {
		return first(activity_places);
	}
}

species BuildingWorking parent: BuildingActivity {
	Room get_place(BuildingIndividual p) {
		return p.working_place;
	}
}

species ActivityGoHome parent: BuildingActivity  {
	string name <- going_home;
	Room get_place(BuildingIndividual p) {
		return BuildingEntrance closest_to p;
	}
}

species ActivityEatOutside parent: BuildingActivity  {
	string name <- eating_outside;
	Room get_place(BuildingIndividual p) {
		return BuildingEntrance closest_to p;
	}
}

species BuildingSanitation parent: BuildingActivity{
	Room get_place(BuildingIndividual p) {
		if flip(0.3) {
			return shuffle(activity_places) with_min_of length(first(each.entrances).people_waiting);
		} else {
			return activity_places closest_to p;
		}
	}
}
