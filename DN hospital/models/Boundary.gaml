model continuous_move
import "Parameters.gaml" 
global{
	init {
		create admin_boundary from: bound_shapefile {}
	}
}
species admin_boundary   { 
//	list<admin_boundary> neighbors;
	geometry center;
	aspect default{
//		write #zoom;
		draw shape color:#gray depth:150 ;
	}
}
 