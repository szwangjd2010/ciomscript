#!/usr/bin/perl -W
# 
#
use strict;
use English;
use Data::Dumper;
use Data::UUID;
use CiomUtil;
use String::Buffer;

my $csv_core_org = "/tmp/core_org.csv";
my $csv_core_orguser = "/tmp/core_orguser.csv";
my $csv_core_group = "/tmp/core_group.csv";
my $csv_core_department = "/tmp/core_department.csv";
my $csv_core_knowledge = "/tmp/core_knowledge.csv";
my $csv_core_user_department_map = "/tmp/core_user_department_map.csv";
my $csv_core_user_group_map = "/tmp/core_user_group_map.csv";
my $csv_core_user_knowledge = "/tmp/core_user_knowledge.csv";
my $csv_core_user_role_map = "/tmp/core_user_role_map.csv";

my $buf_core_org = String::Buffer->new();
my $buf_core_orguser = String::Buffer->new();
my $buf_core_group = String::Buffer->new();
my $buf_core_department = String::Buffer->new();
my $buf_core_knowledge = String::Buffer->new();
my $buf_core_user_department_map = String::Buffer->new();
my $buf_core_user_group_map = String::Buffer->new();
my $buf_core_user_knowledge = String::Buffer->new();
my $buf_core_user_role_map = String::Buffer->new();

my $h_core_org;
my $h_core_orguser;
my $h_core_group;
my $h_core_department;
my $h_core_knowledge;
my $h_core_user_department_map;
my $h_core_user_group_map;
my $h_core_user_knowledge;
my $h_core_user_role_map;

my $header_core_org = "pid,code,orgName,siteName,domain";
my $header_core_orguser = "pid,orgId,password,email,fullName,mobile";
my $header_core_group = "pid,orgId,name,description,type,status";#type: 1, status: 0-1
my $header_core_department = "pid,orgId,parentId,departmentName";
my $header_core_knowledge = "pid,orgId,title,kngType,fileType,fileId";#kngType: 1-6, fileType, 1-2
my $header_core_user_department_map = "pid,orgId,userId,userType,departmentId";
my $header_core_user_group_map = "pid,groupId,userId,type";
my $header_core_user_knowledge = "pid,orgId,userId,knowledgeId,kngType";
my $header_core_user_role_map = "pid,userId,roleId";#roleId: 100001-100005

sub openFile() {
	if (!open($h_core_org, '>', $csv_core_org)) {
		output("Can not open $csv_core_org\n");
		return 1;
	}
	if (!open($h_core_orguser, '>', $csv_core_orguser)) {
		output("Can not open $csv_core_orguser\n");
		return 2;
	}
	if (!open($h_core_group, '>', $csv_core_group)) {
		output("Can not open $csv_core_group\n");
		return 3;
	}
	if (!open($h_core_department, '>', $csv_core_department)) {
		output("Can not open $csv_core_department\n");
		return 4;
	}
	if (!open($h_core_knowledge, '>', $csv_core_knowledge)) {
		output("Can not open $csv_core_knowledge\n");
		return 5;
	}
	if (!open($h_core_user_department_map, '>', $csv_core_user_department_map)) {
		output("Can not open $csv_core_user_department_map\n");
		return 6;
	}
	if (!open($h_core_user_group_map, '>', $csv_core_user_group_map)) {
		output("Can not open $csv_core_user_group_map\n");
		return 7;
	}
	if (!open($h_core_user_knowledge, '>', $csv_core_user_knowledge)) {
		output("Can not open $csv_core_user_knowledge\n");
		return 8;
	}
	if (!open($h_core_user_role_map, '>', $csv_core_user_role_map)) {
		output("Can not open $csv_core_user_role_map\n");
		return 9;
	}
}

sub closeFile() {
	close($h_core_org);
	close($h_core_orguser);
	close($h_core_group);
	close($h_core_department);
	close($h_core_knowledge);
	close($h_core_user_department_map);
	close($h_core_user_group_map);
	close($h_core_user_knowledge);
	close($h_core_user_role_map);
}

my $ug = Data::UUID->new();	

sub newLine($$$) {
	my $buf = shift;
	my $current = shift;
	my $next = shift;

	$pid++;
	$buf->writeln("$pid,'$current','$next'");

	if ($pid % 100 == 0) {
		print $hOut $buf->flush();
	}
}

sub generateDataFile() {
	my $head = "pid,currentPosition,nextPosition";
	$buf->writeln($head);
	for (my $m1 = 0; $m1 < $L1; $m1++) {
		$uuid1 = $ug->create_str();

		for (my $m2 = 0; $m2 < $L2; $m2++) {
			$uuid2 = $ug->create_str();
			newLine($uuid1, $uuid2);

			for (my $m3 = 0; $m3 < $L3; $m3++) {
				$uuid3 = $ug->create_str();
				newLine($uuid2, $uuid3);

				for (my $m4 = 0; $m4 < $L4; $m4++) {
					$uuid4 = $ug->create_str();
					newLine($uuid3, $uuid4);
				}								
			}
		}

	}

	print $hOut $buf->flush() || '';
	close($hOut);
}

sub importData2Db() {
	system("perl -pE 's|#File#|$fileCsv|mg; s|#Table#|core_position_position_map|mg; s|#Column#|pid,currentPosition,nextPosition|mg;' mysql.load.data.from.file.tpl > _tmp_");
	system("mysql -h 172.17.128.231 -uroot -ppwdasdwx -e 'source ./_tmp_' yxt");
}

sub main() {
	if ($#ARGV == -1) {
		generateDataFile();
	} else {
		importData2Db();
	}
}

main();
