/**
* Name: HospitalIndividuals
* Based on the internal empty template. 
* Author: minhduc0711
* Tags: 
*/


model HospitalIndividuals

import "./BuildingIndividual.gaml"

species Doctor parent: BuildingIndividual {
	init {
		map<date,BuildingActivity> agenda_day;
		
		location <- any_location_in(one_of(BuildingEntrance).init_place);
		working_place <- one_of(Room where (each.type = DOCTOR_ROOM or each.type = HEAD_DOCTOR_ROOM));
		
		working_place.nb_affected <- working_place.nb_affected + 1;
		if not(working_place.is_available()) {
			available_offices >> working_place;
		}
		
		working_desk <- working_place.get_target(self,false);
		if (working_place = nil) {
			do die;
		}
		date cd <- current_date + rnd(arrival_time_interval);
		if cd.hour >= 6 {
			agenda_day[cd] <- first(ActivityGoToMeeting);
		} else {
			agenda_day[cd] <- first(ActivityGoToOffice);
			date meeting_time <- date([cd.year,cd.month,cd.day,6,0,0]);
			agenda_day[meeting_time] <- first(ActivityGoToMeeting);
		}
		
		date work_time <- date([cd.year,cd.month,cd.day,7,0,0]);
		if (flip(0.5)) {
			agenda_day[work_time] <- first(ActivityVisitInpatient); 
		} else {
			agenda_day[work_time] <- first(ActivityGoToAdmissionRoom);
		}
		
		date lunch_time <- date([cd.year,cd.month,cd.day,12,0,0]) + rnd(30#mn);

		loop i from: 0 to: 5 {
			loop d over: agenda_day.keys {
				agenda_week[d add_days i] <- agenda_day[d];
			}
		}
		current_agenda_week <- copy(agenda_week);
	}

	aspect default {
		if !is_outside {
			loop angle over: [0, 180] {
				draw triangle(1.3) color: get_color() rotate: angle;
			}
		}
	}
}

species Nurse parent: BuildingIndividual {
	init {
		map<date,BuildingActivity> agenda_day;
		
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
		date cd <- current_date + rnd(arrival_time_interval);

		if cd.hour >= 6 {
			agenda_day[cd] <- first(ActivityGoToMeeting);
		} else {
			agenda_day[cd] <- first(ActivityGoToOffice);
			date meeting_time <- date([cd.year,cd.month,cd.day,6,0,0]);
			agenda_day[meeting_time] <- first(ActivityGoToMeeting);
		}
		
		date work_time <- date([cd.year,cd.month,cd.day,7,0,0]);
		
		loop while: work_time.hour < 12 {
			if flip(0.7) {
				agenda_day[work_time] <- first(ActivityVisitInpatient);
				work_time <- work_time + rnd(5#mn); 
			} else {
				agenda_day[work_time] <- first(ActivityGoToAdmissionRoom);
				work_time <- work_time + rnd(30#mn); 
			}
		}

		date lunch_time <- work_time;

		loop i from: 0 to: 5 {
			loop d over: agenda_day.keys {
				agenda_week[d add_days i] <- agenda_day[d];
			}
		}
		current_agenda_week <- copy(agenda_week);
	}

	aspect default {
		if !is_outside {
			draw square(1) color: get_color() border: #black;
		}
	}
}

species Inpatient parent: BuildingIndividual {
	init {
		is_outside <- false;
		Room assigned_ward <- one_of(Room where (each.type = WARD and each.nb_affected < 5));
		assigned_ward.nb_affected <- assigned_ward.nb_affected + 1;
		assigned_ward.people_inside << self;
		location <- any_location_in(one_of(assigned_ward.available_places));
		map<date,BuildingActivity> agenda_day;
	}

	aspect default {
		if !is_outside {
			draw circle(0.5) color: get_color();
		}
	}
}

species Visitor parent: BuildingIndividual {
	init {
		location <- any_location_in(one_of(BuildingEntrance).init_place);
		
		if (flip(1.0)) {
			do define_new_case;
			latent_period <- 0.0;
		}

		map<date, BuildingActivity> agenda_day;
		
		date work_time <- current_date + 10;
		loop while: work_time.hour < 12 {
			agenda_day[work_time] <- first(ActivityVisitInpatient);
			work_time <- work_time + 10#mn; 
		}
		loop i from: 0 to: 5 {
			loop d over: agenda_day.keys {
				agenda_week[d add_days i] <- agenda_day[d];
			}
		}
		current_agenda_week <- copy(agenda_week);
	}
	
	aspect default {
		if !is_outside {
			draw triangle(2) color: get_color() border: #black;
		}
	}
}

species Outpatient parent: BuildingIndividual {
	init {
		map<date,BuildingActivity> agenda_day;
		location <- any_location_in(one_of(BuildingEntrance).init_place);

		if (flip(1.0)) {
			do define_new_case;
			latent_period <- 0.0;
		}

		date visit_time <- current_date + 10#s;
		date leave_time <- visit_time + rnd(15#mn);
		agenda_day[visit_time] <- first(ActivityGoToAdmissionRoom);
		agenda_day[leave_time] <- first(ActivityLeaveBuilding);
		
		loop i from: 0 to: 5 {
			loop d over: agenda_day.keys {
				agenda_week[d add_days i] <- agenda_day[d];
			}
		}
		current_agenda_week <- copy(agenda_week);
	}

	aspect default {
		if !is_outside {
			draw triangle(1.2) color: get_color() border: #black;
		}
	}
}
