/**
* Name: HospitalIndividuals
* Based on the internal empty template. 
* Author: minhduc0711, Hoang Van Dong
* Tags: 
*/


model HospitalIndividuals

import "./BuildingIndividual.gaml"

species Doctor parent: BuildingIndividual {
	init {
		location <- any_location_in(one_of(BuildingEntrance).init_place);
		working_place <- one_of(Room where (each.type = DOCTOR_ROOM));
		
		working_place.nb_affected <- working_place.nb_affected + 1;
		if not(working_place.is_available()) {
			available_offices >> working_place;
		}
		
		working_desk <- working_place.get_target(self,false);
		if (working_place = nil) {
			do die;
		}
	}
	
	map<date, BuildingActivity> get_daily_agenda {
		map<date, BuildingActivity> agenda;
		
		date arriving_time <- date("05:30", TIME_FORMAT_STR) + rnd(arrival_time_interval);
		// Daily meeting
		date meeting_time <- date("06:00", TIME_FORMAT_STR);
		if arriving_time >= meeting_time {
			agenda[arriving_time] <- first(ActivityGoToMeeting);
		} else {
			// If arrived a bit early, go to office to wait
			agenda[arriving_time] <- first(ActivityGoToOffice);
			agenda[meeting_time] <- first(ActivityGoToMeeting);
		}
		// Morning shift
		date work_time <- date("06:15", TIME_FORMAT_STR);
		// Alternate between working at office, admitting new patients and visit inpatients
		loop while: work_time.hour < 12 {
			int choice <- rnd_choice([0.5, 0.3, 0.2]);
			if choice = 0 {
				agenda[work_time] <- first(ActivityGoToOffice);
				work_time <- work_time + rnd(20#mn, 30#mn); 
			} else if choice = 1 {
				agenda[work_time] <- first(ActivityGoToAdmissionRoom);
				work_time <- work_time + rnd(5#mn, 15#mn);
			} else if choice = 2 {
				agenda[work_time] <- first(ActivityVisitInpatient);
				work_time <- work_time + rnd(5#mn, 10#mn);
			}
		}
		
		// Lunch time
		agenda[work_time] <- first(ActivityLeaveBuilding);
		
		// Afternoon shift
		work_time <- date("13:00", TIME_FORMAT_STR);
		// Alternate between working at office, admitting new patients and visit inpatients
		loop while: work_time.hour < 18 {
			int choice <- rnd_choice([0.5, 0.3, 0.2]);
			if choice = 0 {
				agenda[work_time] <- first(ActivityGoToOffice);
				work_time <- work_time + rnd(20#mn, 30#mn); 
			} else if choice = 1 {
				agenda[work_time] <- first(ActivityGoToAdmissionRoom);
				work_time <- work_time + rnd(5#mn, 15#mn);
			} else if choice = 2 {
				agenda[work_time] <- first(ActivityVisitInpatient);
				work_time <- work_time + rnd(5#mn, 10#mn);
			}
		}
		
		// Leave for dinner / go home
		agenda[work_time] <- first(ActivityLeaveBuilding);
		
		// Might do a night shift
		if flip(0.2) {
			work_time <- date("19:00", TIME_FORMAT_STR);
			agenda[work_time] <- first(ActivityGoToOffice);
		}
		return agenda;
	}

}

species Nurse parent: BuildingIndividual {
	init {
		location <- any_location_in(one_of(BuildingEntrance).init_place);
		working_place <- one_of(Room where (each.type = NURSE_ROOM));
		
		working_place.nb_affected <- working_place.nb_affected + 1;
		if not(working_place.is_available()) {
			available_offices >> working_place;
		}
		
		working_desk <- working_place.get_target(self,false);
		if (working_place = nil) {
			do die;
		}
	}

	map<date, BuildingActivity> get_daily_agenda {
		map<date, BuildingActivity> agenda;
		
		date arriving_time <- date("05:30", TIME_FORMAT_STR) + rnd(arrival_time_interval);
		// Daily meeting
		date meeting_time <- date("06:00", TIME_FORMAT_STR);
		if arriving_time >= meeting_time {
			agenda[arriving_time] <- first(ActivityGoToMeeting);
		} else {
			// If arrived a bit early, go to office to wait
			agenda[arriving_time] <- first(ActivityGoToOffice);
			agenda[meeting_time] <- first(ActivityGoToMeeting);
		}
		
		date work_time <- date("06:15", TIME_FORMAT_STR);
		loop while: work_time.hour < 12 {
			if flip(0.7) {
				agenda[work_time] <- first(ActivityVisitInpatient);
				work_time <- work_time + rnd(3#mn, 5#mn); 
			} else {
				agenda[work_time] <- first(ActivityGoToAdmissionRoom);
				work_time <- work_time + rnd(10#mn, 15#mn); 
			}
		}

		date lunch_time <- work_time;
		agenda[work_time] <- first(ActivityLeaveBuilding);
		
		// Afternoon shift
		work_time <- date("13:00", TIME_FORMAT_STR);
		// Alternate between working at office, admitting new patients and visit inpatients
		loop while: work_time.hour < 18 {
			if flip(0.7) {
				agenda[work_time] <- first(ActivityVisitInpatient);
				work_time <- work_time + rnd(3#mn, 5#mn); 
			} else {
				agenda[work_time] <- first(ActivityGoToAdmissionRoom);
				work_time <- work_time + rnd(10#mn, 15#mn); 
			}
		}

		// Go home
		agenda[work_time] <- first(ActivityLeaveBuilding);

		return agenda;
	}

}

species Staff parent: BuildingIndividual{
	
}

species Inpatient parent: BuildingIndividual {
	Bed mybed;
	Room assigned_ward;
	list<Caregivers> carer;
	init {
		wandering <- true;
		is_outside <- false;
		assigned_ward <- one_of(Room where (each.type = WARD and each.nb_affected < 5));
		assigned_ward.nb_affected <- assigned_ward.nb_affected + 1;
		assigned_ward.people_inside << self;
		current_room <- assigned_ward;
		dst_room <- assigned_ward;
		location <- any_location_in(one_of(assigned_ward.available_places));
		map<date,BuildingActivity> agenda_day;
	}
	
	map<date, BuildingActivity> get_daily_agenda {
		return map<date, BuildingActivity>([]);
	}

}

species Caregivers parent: BuildingIndividual {
	Inpatient sicker;
	BenchWait bench;
	init {
		location <- any_location_in(one_of(BuildingEntrance).init_place);
		// Some visitor might be infectious
		if (flip(0.2)) {
			do define_new_case;
			latent_period <- 0.0;
		}
	}
	
	action initalization{
		sicker <- any(Inpatient where (length(each.carer) < 2));
		ask sicker{
			carer << myself;
		}
	}

	map<date, BuildingActivity> get_daily_agenda {
		map<date, BuildingActivity> agenda;

		date arriving_time <- date("08:30", TIME_FORMAT_STR) + rnd(3#h);
		agenda[arriving_time] <- first(ActivityVisitInpatient);

		date leaving_time <- arriving_time + rnd(1#h, 8#h);
		agenda[leaving_time] <- first(ActivityLeaveBuilding);
		
		return agenda;
	}

}

species interns parent: BuildingIndividual{
	
}


