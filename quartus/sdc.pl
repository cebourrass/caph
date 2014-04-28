#!/usr/bin/perl -w
use strict;
use warnings;


# READING INPUT ARGUMENTS
#################################################
my $period   = 20.0;
my $waveform = 0.5;
my $input_min = 0.2;
my $input_max = 0.5;
my $output_min = 0.3;
my $output_max = 0.6;


my $vhdfile="../hog_net.vhd";
my $sdcfile="hog.sdc";
my $clockname="clock";

my $argnum=0;
my $numArgs = $#ARGV + 1;

# si ./sdc.pl -h => Display Help
if ( $numArgs==1 and  $ARGV[0] eq "-h" ) {
	print ("Usage: ./sdc.pl  -i vhdl_file -o sdc_file [OPTION] ...\n\n");
	print ("   -i vhdl_file \n\t Input file : PATH to vhdl top_level file\n");
	print ("   -o sdc_file \n\t Output file : sdc file \n");
	print ("   \nOPTIONS (options order is not important):\n\n");
	print ("   -period t (ns)\n\t clock period :default = 20 ns\n");
	print ("   -waveform (%)\n\t duty cyle (of clock)  : default= 50% \n");
	print ("   -input_min_delay t(ns) \n\t Hold constraints for inputs\n"); 
	print ("   -input_max_delay t(ns) \n\t Setup time for inputs \n");
	print ("   -output_min_delay t(ns) \n\t Hold time for outputs pins\n"); 
	print ("   -output_max_delay t(ns) \n\t Setup tiime for outputs pins\n");
	print ("   -clock_name \n\t Specify the clock's name in VHDL entity if different from clock\n");
	die "\n";
}

# if input and output are not present
 if ($numArgs < 4){
	die("Error in Command Line\nUsage: ./sdc.pl  -i vhdl_file -o sdc_file [OPTION] ...\nMake ./sdc.pl -h for more help\n");
 }

 if ($ARGV[0] eq "-i"){
	$vhdfile = $ARGV[1];
 }else {
	die("Usage: ./sdc.pl  -i vhdl_file -o sdc_file [OPTION] ...\n, stopped");
 }

 if ($ARGV[2] eq "-o"){
	$sdcfile = $ARGV[3];
 }else {
	die("Usage: ./sdc.pl  -i vhdl_file -o sdc_file [OPTION] ...\n, stopped");}
 

foreach $argnum (4 .. $#ARGV) {

  if ($ARGV[$argnum] eq "-period"){
	$period = $ARGV[$argnum+1];
 }
  if ($ARGV[$argnum] eq "-waveform"){
	$waveform = $ARGV[$argnum+1];
 }
  if ($ARGV[$argnum] eq "-input_min_delay"){
	$input_min = $ARGV[$argnum+1];
 }
  if ($ARGV[$argnum] eq "-input_max_delay"){
	$input_max = $ARGV[$argnum+1];
 }
  if ($ARGV[$argnum] eq "-output_min_delay"){
	$output_min = $ARGV[$argnum+1];
 }
  if ($ARGV[$argnum] eq "-output_max_delay"){
	$output_max = $ARGV[$argnum+1];
 }

  if ($ARGV[$argnum] eq "-clock_name"){
	$clockname = $ARGV[$argnum+1];
 }

}

#################################################


open(FIC,"< $vhdfile") or die"open: $!";
open(FIC2,"+> $sdcfile") or die"open: $!";


my @t = <FIC>; #lecture tout le fichier VHD
my @input;
my @output;
my @in_bus;
my @out_bus;

my @tmp;

my $i=0;

my $incpt=0;
my $outcpt=0;

my $inbus_cpt=0;
my $outbus_cpt=0;

# We are looking for entity IN/OUT (declared before architecture keyword)
while ($t[$i] !~ m/architecture/)
{
 # print "$t[$i]\n";

  #SEARCH FOR INPUT pins
  if ($t[$i] =~ m/in/){
	 @tmp = split(/:/,$t[$i]);
	 $tmp[0]=~ s/^\s+//; #delete space at the start of string

	if ($tmp[1] =~ m/vector/) { #if input is a bus
		$in_bus[$inbus_cpt++]= join("",$tmp[0],"[*]"); # ADD [*] at the end of the name to specify input bus
	} #put in the the input bus array
	else {
		# remove clock from input list timing 
		 my $test = $tmp[0] cmp $clockname;
		 if ($tmp[0] ne $clockname ){
			 $input[$incpt++] = $tmp[0];
	 	}
	}
  
 } 
  #SEARCH FOR OUTPUT pins
  if ($t[$i] =~ m/out/){
	 @tmp = split(/:/,$t[$i]);
	 $tmp[0]=~ s/^\s+//; #delete space at the start of string

	if ($tmp[1] =~ m/vector/) { #if output is a bus
		$out_bus[$outbus_cpt++]= join('',$tmp[0],"[*]");
	} #put in the the output bus array
	else {
	 $output[$outcpt++] = $tmp[0];
	}
  }

 #SEARCH FOR INOUT PINS

$i++;
}



print( "#########################################\n");
print( "#######  Informations ###################\n");
print "clockname         : $clockname\n";
print "period            : $period ns\n";
print "Setup time Input  : $input_max ns\n";
print "Hold time Input   : $input_min ns\n";
print "Setup time Output : $output_max ns\n";
print "Hold time Output  : $output_min ns\n";
print( "#########################################\n");

print( FIC2 "#**************************************************************\n");
print( FIC2 "#    Generated SDC file hog.sdc by Perl Script\n\n" );
print( FIC2 "#    Author: Cedric Bourrasset \n\n" );
print( FIC2 "#**************************************************************\n");
print( FIC2 "# Time Information\n");
print( FIC2 "#**************************************************************\n\n");
print( FIC2 "set_time_format -unit ns -decimal_places 3\n" );
print( FIC2 "#**************************************************************\n");
print( FIC2 "# Create Clock\n");
print( FIC2 "#**************************************************************\n");

#Calculate duty cycle of clock 
my $dc = $period * $waveform;
print(FIC2 "create_clock -name {$clockname} -period $period -waveform { 0 $dc } [get_ports {$clockname}]\n");

print( FIC2 "#**************************************************************\n");
print( FIC2 "# Create Generated Clock\n");
print( FIC2 "#**************************************************************\n");
print( FIC2 "derive_clocks -period $period \n");
print( FIC2 "#**************************************************************\n");
print( FIC2 "# Set Clock Latency\n");
print( FIC2 "#**************************************************************\n");
print( FIC2 "#**************************************************************\n");
print( FIC2 "# Set Clock Uncertainty\n");
print( FIC2 "#**************************************************************\n");
print( FIC2 "derive_clock_uncertainty\n");
print( FIC2 "#**************************************************************\n");
print( FIC2 "# Set Input Delay\n");
print( FIC2 "#**************************************************************\n");


foreach my $inn (@in_bus){
print (FIC2 "set_input_delay -clock $clockname -min $input_min [get_ports {$inn}]\n"); # bus specification
print (FIC2 "set_input_delay -clock $clockname -max $input_max [get_ports {$inn}]\n");
}   
foreach my $inn (@input){
print (FIC2 "set_input_delay -clock $clockname -min $input_min [get_ports {$inn}]\n");
print (FIC2 "set_input_delay -clock $clockname -max $input_max [get_ports {$inn}]\n");
}   

print( FIC2 "#**************************************************************\n");
print( FIC2 "# Set Output Delay\n");
print( FIC2 "#**************************************************************\n");
foreach my $out (@out_bus){
print (FIC2 "set_output_delay -clock $clockname -min $output_min [get_ports {$out}]\n");
print (FIC2 "set_output_delay -clock $clockname -max $output_max [get_ports {$out}]\n");
}   

foreach my $out (@output){
print (FIC2 "set_output_delay -clock $clockname -min $output_min [get_ports {$out}]\n");
print (FIC2 "set_output_delay -clock $clockname -max $output_max [get_ports {$out}]\n");
}   
close( FIC );
close( FIC2 );
