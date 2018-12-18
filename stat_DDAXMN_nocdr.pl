#!/usr/bin/perl     -w
 use strict;
use warnings;
use POSIX;

 
    
my @tmp=(); 
my @ex_tmp=(); 
my $key;
my %hash1;
my $ok=0;
my $DefineFilename="allData.2";    #定义Area文件
my $searchkey="";
 open (DefineFile,$DefineFilename);

my %hash_operator=('86134','China Mobile','86135','China Mobile','86136','China Mobile','86137','China Mobile','86138','China Mobile','86139','China Mobile','86147','China Mobile','86150','China Mobile','86151','China Mobile','86152','China Mobile','86157','China Mobile','86158','China Mobile','86159','China Mobile','86178','China Mobile','86182','China Mobile','86183','China Mobile','86184','China Mobile','86187','China Mobile','86188','China Mobile','86130','China Unicom','86131','China Unicom','86132','China Unicom','86145','China Unicom','86155','China Unicom','86156','China Unicom','86171','China Unicom','86175','China Unicom','86176','China Unicom','86185','China Unicom','86186','China Unicom','86133','China Telcom','86149','China Telcom','86153','China Telcom','86173','China Telcom','86177','China Telcom','86180','China Telcom','86181','China Telcom','86189','China Telcom','86170','Virtual Mobile');
 
  
my $DIR_INPUTBILL="/home/see/nginrun/record/troubleshooting/TXMTApp/completed"; #定义输入目录
my $DIR_OUTPUTBILL="/home/see/nginrun/record/CheckScript/stat"; #定义输出目录
 
my $nowtime=strftime("%Y%m%d_%H%M%S", localtime(time()));

my $hourago =$ARGV[0]; #手工输入时间格式：2016092708
my $operator ="ALL";
my $argLength=@ARGV;

if($hourago &&$hourago =~ /[0-9]+/) 
{
	
} 
else{
	print "输入时间格式错误，初始化为前一个小时";
	  $hourago=strftime("%Y%m%d%H%M", localtime(time()-180));#请一个小时
         print $hourago
}

if ($argLength==2)
{
	$operator=$ARGV[1]; #手工输入运营商格式：yd,dx,lt
}


#chdir($DIR_INPUTBILL);

 
while (<DefineFile>) { 
	chomp; 
	@tmp=split(/\|/);	
	#print ; 
	 
	$hash1{$tmp[0]}=$tmp[1]; #按照hash{8618581059374}=23，存入hash表
 
 }
 
 
close(DefineFile); 






chdir($DIR_INPUTBILL);
my @sorted = sort { (stat $a)[9] <=> (stat $b)[9] } glob "AXMNApp.TXMTCall*".$hourago."*.dat" ; #//输入文件名格式
 
 
 
 
 my %hash_success;
 my %hash_fail;
 my %hash_nobind;
 my %hash_Abandon;
 my %hash_Busy;
 my %hash_NoAnswer;

 
 
 foreach $key ( sort keys %hash1)  
 {
 	if(! exists 	$hash_success{$hash1{$key}})
 	{
 	$hash_success{$hash1{$key}} =1; 
 	
}

	if(! exists 	$hash_fail{$hash1{$key}})
 	{
 #	$hash_success{$hash1{$keys}} =0; 
 	
 	 	$hash_fail{$hash1{$key}} =0; 
 	
}

if(! exists 	$hash_nobind{$hash1{$key}})
 	{
 	
 	 	$hash_nobind{$hash1{$key}} =0; 
 	
}

if(! exists 	$hash_Abandon{$hash1{$key}})
 	{
 	
 	 	$hash_Abandon{$hash1{$key}} =0; 
 	
}

if(! exists 	$hash_Busy{$hash1{$key}})
 	{
 	
 	 	$hash_Busy{$hash1{$key}} =0; 
 	
}

if(! exists 	$hash_NoAnswer{$hash1{$key}})
 	{
 	
 	 	$hash_NoAnswer{$hash1{$key}} =0; 
 	
}

 	
}

chdir($DIR_OUTPUTBILL);

#open (OUTFILE,">NEW_CAllLOG_".$hourago.".txt"); #定义输出文件名
open (OUTFILEERROR,">CAllLOGN_OArea_AXMNTXMT".$hourago.".txt"); #出错文件名


chdir($DIR_INPUTBILL);
 
while( my $filename =shift(@sorted))
{
 open (INPUTFILE ,$filename)||die("Cannot Openfile".$filename);

		while (<INPUTFILE>) { 
			chomp; 
			@tmp=split(/\,/);
			
			$searchkey = $tmp[6];
			#print $_;
			#print $searchkey;
			my $searchNumber = substr($tmp[5],0,5);
			my $searchNumber2 = substr($tmp[4],0,5);

      next unless ( exists $hash_operator{$searchNumber});		
			
			if(@ARGV==2 && ($operator=~/yd/))
			{
				next unless (($hash_operator{$searchNumber} =~/China Mobile/));
			}
			elsif(@ARGV==2 && ($operator=~/lt/))
			{
				next unless (($hash_operator{$searchNumber} =~/China Unicom/));
			}
			elsif(@ARGV==2 && ($operator=~/dx/))
			{
				next unless (($hash_operator{$searchNumber} =~/China Telcom/));
			}
			else
			{
			}
		 
				 if($tmp[0] =~ /^[0-9]+/)
		{
				

										if( $tmp[2] =~/^NoBind/ || $tmp[2] =~/^Expired/ )   #AXMN NoBind and Expired 
										{
											$hash_nobind{$hash1{$searchkey}} = 	$hash_nobind{$hash1{$searchkey}}+1;   
										}
										elsif($tmp[18] =~/Call/)    #Caller Hang up,Called Hang up
										{
											$hash_success{$tmp[21]} = 	$hash_success{$tmp[21]}+1;   
										}
										else
										{
											$hash_fail{$tmp[21]} = $hash_fail{$tmp[21]}+1;
											if($tmp[18] =~/Abandon/)
											{
												$hash_Abandon{$tmp[21]} = 	$hash_Abandon{$tmp[21]}+1; 
											}
											elsif($tmp[18] =~/Busy/)    #Caller Hang up,Called Hang up
											{
												$hash_Busy{$tmp[21]} = 	$hash_Busy{$tmp[21]}+1;  
											}
											elsif($tmp[18] =~/No/)    #Caller Hang up,Called Hang up
											{
												$hash_NoAnswer{$tmp[21]} = 	$hash_NoAnswer{$tmp[21]}+1;  
											}
											else
											{
												}
											
										}

 		}
	

	}
	
	close (INPUTFILE);
}

 my %hash_Bind;
 my %hash_UnBind;
 foreach $key ( sort keys %hash1)  
 { 
if(! exists $hash_Bind{$hash1{$key}})
 	{
 	
 	 	$hash_Bind{$hash1{$key}} =0; 
 	
}

if(! exists $hash_UnBind{$hash1{$key}})
 	{
 	
 	 	$hash_UnBind{$hash1{$key}} =0; 
 	
}
}

####增加绑定和解绑的统计
##AXBind的统计
$DIR_INPUTBILL="/home/see/rbirun/origin/CDRProcess/DIDIXYBApp/DIDIXYBBind"; #定义输入目录
chdir($DIR_INPUTBILL);
@sorted = sort { (stat $a)[9] <=> (stat $b)[9] } glob "Bind.DIDIXYBAXBind.".$hourago."*" ; #//Bind匹配文件

while( my $filename =shift(@sorted))
{
 open (INPUTFILE ,$filename)||die("Cannot Openfile".$filename);

		while (<INPUTFILE>) { 
			chomp; 
			@tmp=split(/\|/);
			
			$searchkey = $tmp[3];
			#print $searchkey."\n";
			my $searchNumber = substr($tmp[4],0,5);

      next unless ( exists $hash_operator{$searchNumber});		
			
			if(@ARGV==2 && ($operator=~/yd/))
			{
				next unless (($hash_operator{$searchNumber} =~/China Mobile/));
			}
			elsif(@ARGV==2 && ($operator=~/lt/))
			{
				next unless (($hash_operator{$searchNumber} =~/China Unicom/));
			}
			elsif(@ARGV==2 && ($operator=~/dx/))
			{
				next unless (($hash_operator{$searchNumber} =~/China Telcom/));
			}
			else
			{
			}
				 if($tmp[0] =~ /^[0-9]+/)
		{
								  
				  $hash_Bind{$tmp[16]} = 	$hash_Bind{$tmp[16]}+1;						 
 		}
	

	}
	
	close (INPUTFILE);
}


##XYBBind的统计
$DIR_INPUTBILL="/home/see/rbirun/origin/CDRProcess/DIDIXYBApp/DIDIXYBXYBBind"; #定义输入目录
chdir($DIR_INPUTBILL);
@sorted = sort { (stat $a)[9] <=> (stat $b)[9] } glob "Bind.DIDIXYBXYBBind.".$hourago."*" ; #//Bind匹配文件

while( my $filename =shift(@sorted))
{
 open (INPUTFILE ,$filename)||die("Cannot Openfile".$filename);

		while (<INPUTFILE>) { 
			chomp; 
			@tmp=split(/\|/);
			
			$searchkey = $tmp[3];
			#print $searchkey."\n";
			my $searchNumber = substr($tmp[4],0,5);

      next unless ( exists $hash_operator{$searchNumber});		
			
			if(@ARGV==2 && ($operator=~/yd/))
			{
				next unless (($hash_operator{$searchNumber} =~/China Mobile/));
			}
			elsif(@ARGV==2 && ($operator=~/lt/))
			{
				next unless (($hash_operator{$searchNumber} =~/China Unicom/));
			}
			elsif(@ARGV==2 && ($operator=~/dx/))
			{
				next unless (($hash_operator{$searchNumber} =~/China Telcom/));
			}
			else
			{
			}
				 if($tmp[0] =~ /^[0-9]+/)
		{
					  $hash_Bind{$tmp[16]} = 	$hash_Bind{$tmp[16]}+1;						 
		 
 		}
	

	}
	
	close (INPUTFILE);
}


##XYBUnBind的统计
$DIR_INPUTBILL="/home/see/rbirun/origin/CDRProcess/DIDIXYBApp/DIDIXYBXYBUnBind"; #定义输入目录
chdir($DIR_INPUTBILL);
@sorted = sort { (stat $a)[9] <=> (stat $b)[9] } glob "UNBind.DIDIXYBAXBind.".$hourago."*" ; #//Bind匹配文件

while( my $filename =shift(@sorted))
{
 open (INPUTFILE ,$filename)||die("Cannot Openfile".$filename);

		while (<INPUTFILE>) { 
			chomp; 
			@tmp=split(/\|/);
			
			if($tmp[0] =~ /^[0-9]+/)
		{
			
			$searchkey = $tmp[9];
			#print $searchkey."\n";
			my $searchNumber = substr($tmp[9],0,5);

      next unless ( exists $hash_operator{$searchNumber});
      	
			
			if(@ARGV==2 && ($operator=~/yd/))
			{
				next unless (($hash_operator{$searchNumber} =~/China Mobile/));
			}
			elsif(@ARGV==2 && ($operator=~/lt/))
			{
				next unless (($hash_operator{$searchNumber} =~/China Unicom/));
			}
			elsif(@ARGV==2 && ($operator=~/dx/))
			{
				next unless (($hash_operator{$searchNumber} =~/China Telcom/));
			}
			else
			{
			}
				 if($tmp[0] =~ /^[0-9]+/)
		{
					  $hash_UnBind{$tmp[13]} = 	$hash_UnBind{$tmp[13]}+1;						 
		 
 		}
 		
 		}	
 		
	

	}
	
	close (INPUTFILE);
}

my %hash_SMSSend;

 foreach $key ( sort keys %hash1)
 {
if(! exists $hash_SMSSend{$hash1{$key}})
        {

                $hash_SMSSend{$hash1{$key}} =0;

}

}



chdir($DIR_OUTPUTBILL);



if(@ARGV==2 &&(($operator=~/yd/)))
{
	open (OUTFILESTAT,">DDAXMN_stat_".$hourago.".txt.YD");
}
elsif(@ARGV==2 &&(($operator=~/lt/)))
{
	open (OUTFILESTAT,">DDAXMN_stat_".$hourago.".txt.LT"); #统计
}
elsif(@ARGV==2 &&(($operator=~/dx/)))
{
	open (OUTFILESTAT,">DDAXMN_stat_".$hourago.".txt.DX"); #统计
}
else
{
	open (OUTFILESTAT,">DDAXMN_stat_".$hourago.".txt.new"); #统计
}


my $success=1;
my $fail=0;
my $nobind=0;
my $Abandon=0;
my $Busy=0;
my $NoAnswer=0;
my $bind=0;
my $unbind=0;
my $smssend=0;

foreach $key ( sort keys %hash_success)  
 {
 	
 	#if ($hash_success{$key}>0)
 	#{
		
		print OUTFILESTAT "",$key,"|",$hash_success{$key},"|",$hash_fail{$key},"|",$hash_nobind{$key},"|",$hash_Abandon{$key},"|",$hash_Busy{$key},"|",$hash_NoAnswer{$key},"|",($hash_success{$key})/($hash_success{$key}+$hash_fail{$key})*100,"|",$hash_Bind{$key},"|",$hash_UnBind{$key},"|",$hash_SMSSend{$key},"|",($hash_success{$key}+$hash_fail{$key}),"\n";
	#}
	$success=$success+$hash_success{$key};
	$fail=$fail+$hash_Busy{$key}+$hash_Abandon{$key}+$hash_NoAnswer{$key};
	$nobind=$nobind+$hash_nobind{$key};
	$bind=$bind+$hash_Bind{$key};
	$unbind=$unbind+$hash_UnBind{$key};
        $Abandon=$Abandon+$hash_Abandon{$key};
	$Busy=$Busy+$hash_Busy{$key};
	$NoAnswer=$NoAnswer+$hash_NoAnswer{$key};	
	 $smssend=$smssend+$hash_SMSSend{$key};
}

print OUTFILESTAT "Total_Desc","|",$success,"|",$fail,"|",$nobind,
			  "|",($success)/($success+$fail)*100,"|",($nobind)/($success)*100,"|",$bind,"|",$unbind,"|",$Abandon,"|",$Busy,"|",$NoAnswer,"|",$smssend,"|",($nobind)/($success)*100,"\n";



close (OUTFILESTAT);
close (OUTFILEERROR);
#close (OUTFILE);
