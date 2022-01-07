/**
* Name: HiddenStatic
* hidden and static species like benches, walk paths and inpatient's bed 
* Author: dongh
* Tags: 
*/


model HiddenStatic

/* Insert your model definition here */

global{
	
	shape_file walk_path0_shape_file <- shape_file("../includes/wptemp.shp");
	shape_file patient_bed0_shape_file <- shape_file("../includes/patient_bed.shp");
	shape_file department0_shape_file <- shape_file("../includes/department.shp");
	shape_file bench_wait0_shape_file <- shape_file("../includes/bench_wait.shp");
	shape_file door_point0_shape_file <- shape_file("../includes/door_point.shp");
	graph hidden_road;
	
	init{
		create beds from: patient_bed0_shape_file with:[id::int(read('id'))];
		create benches from: bench_wait0_shape_file with:[id::int(read('id'))];
		create walk_path from: walk_path0_shape_file;
		create room from: department0_shape_file with:[type::string(read('type'))];
		create door_point from: door_point0_shape_file;
		hidden_road <- as_edge_graph(walk_path);
	}
}

species walk_path{
	aspect default{
		draw shape color: #black;
	}
}

species beds{
	int id;
	bool occupied <- false;
	aspect default{
		draw rectangle(40, 80) color: #white depth: 32;
	}
}

species benches{
	int id;
	bool occupied <- false;
	aspect default{
		draw circle(20) color: #red;
	}
}

species room{
	string type;
	aspect default{
//		write #zoom;
		draw shape color:#gray depth:150 ;
	}
}

species door_point{
	
}

