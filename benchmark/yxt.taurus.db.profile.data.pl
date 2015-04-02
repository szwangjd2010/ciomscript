#!/usr/bin/perl -W
# 
#
use strict;
use English;
use Data::Dumper;
use Data::UUID;
use String::Buffer;

my $UPWD= '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92';
my $Tabs= {
	core_org => {
		h => undef,
		counter => 0,
		file=>'/tmp/ciom/core_org.csv',
		buf => String::Buffer->new(),
		cols => 'pid,code,orgName,siteName,domain'
	},
	core_orguser => {
		h => undef,
		counter => 0,
		file=>'/tmp/ciom/core_orguser.csv',
		buf => String::Buffer->new(),
		cols => 'pid,orgId,password,email,fullName,mobile'
	},
	core_user_role_map => {
		h => undef,
		counter => 0,
		file=>'/tmp/ciom/core_user_role_map.csv',
		buf => String::Buffer->new(),
		cols => 'pid,userId,roleId'#roleId: 100001-100005
	},	
	core_group => {
		h => undef,
		counter => 0,
		file=>'/tmp/ciom/core_group.csv',
		buf => String::Buffer->new(),
		cols => 'pid,orgId,name,description,type,status'#type: 1, status: 0-1
	},
	core_department => {
		h => undef,
		counter => 0,
		file=>'/tmp/ciom/core_department.csv',
		buf => String::Buffer->new(),
		cols => 'pid,orgId,parentId,departmentName'
	},
	core_knowledge => {
		h => undef,
		counter => 0,
		file=>'/tmp/ciom/core_knowledge.csv',
		buf => String::Buffer->new(),
		cols => 'pid,orgId,title,kngType,fileType,fileId'#kngType: 1-6, fileType, 1-2
	},
	core_file_info => {
		h => undef,
		counter => 0,
		file=>'/tmp/ciom/core_file_info.csv',
		buf => String::Buffer->new(),
		cols => 'pid,name'
	},
	core_convert_item => {
		h => undef,
		counter => 0,
		file=>'/tmp/ciom/core_convert_item.csv',
		buf => String::Buffer->new(),
		cols => 'pid,knowledgeId,fileId,format'
	},
	core_user_department_map => {
		h => undef,
		counter => 0,
		file=>'/tmp/ciom/core_user_department_map.csv',
		buf => String::Buffer->new(),
		cols => 'pid,orgId,userId,departmentId'
	},
	core_user_group_map => {
		h => undef,
		counter => 0,
		file=>'/tmp/ciom/core_user_group_map.csv',
		buf => String::Buffer->new(),
		cols => 'pid,groupId,userId,type'
	},
	core_user_knowledge => {
		h => undef,
		counter => 0,
		file=>'/tmp/ciom/core_user_knowledge.csv',
		buf => String::Buffer->new(),
		cols => 'pid,orgId,userId,knowledgeId'
	}
};
my $ug = Data::UUID->new();	

sub getUuid() {
	return $ug->create_str();
}

sub openFile() {
	while ( my ($k, $v) = each(%{$Tabs}) ) {
        if (!open($v->{h}, '>', $v->{file})) {
        	print("Can not open $v->{file} \n");
        }
    }
}

sub closeFile() {
	while ( my ($k, $v) = each(%{$Tabs}) ) {
        close($v->{h});
    }	
}

sub initTabHeader2Buf() {
	while ( my ($k, $v) = each(%{$Tabs}) ) {
        $v->{buf}->writeln("$k - ($v->{cols})");
    }	
}

sub flushBuf2File() {
	while ( my ($k, $v) = each(%{$Tabs}) ) {
		my $h = $v->{h};
		my $str = $v->{buf}->flush();
        if (defined($str)) {
        	print $h $str;
        	print "writing $v->{file} - $v->{counter} lines ...\n";
        }
    }	
}

sub increaseCounterAndFlush($) {
	my $tab = shift;
	$tab->{counter}++;
	if ($tab->{counter} % 100 == 0) {
		my $h = $tab->{h};
		print $h $tab->{buf}->flush() || '';
		print "writing $tab->{file} - $tab->{counter} lines ...\n";
	}
}

sub core_org_line($) {
	#cols => 'pid,code,orgName,siteName,domain'
	my $orgId = shift;

	my $tab = $Tabs->{core_org};
	$tab->{buf}->writeln("$orgId,code-$orgId,orgName-$orgId,siteName-$orgId,domain-$orgId");
	increaseCounterAndFlush($tab);
}

sub core_orguser_line($$) {
	#cols => 'pid,orgId,password,email,fullName,mobile'
	my $orgId = shift;
	my $userId = shift;

	my $tab = $Tabs->{core_orguser};
	$tab->{buf}->writeln("$userId,$orgId,$UPWD,$userId\@yxt.cn,fullName-$userId,mobile-$userId");
	increaseCounterAndFlush($tab);		
}

sub core_user_role_map_line($$$) {
	#cols => 'pid,userId,roleId'
	my $pid = shift;
	my $userId = shift;
	my $roleId = shift;

	my $tab = $Tabs->{core_user_role_map};
	$tab->{buf}->writeln("$pid,$userId,$roleId");
	increaseCounterAndFlush($tab);		
}

sub core_group_line($$$) {
	#cols => 'pid,orgId,name,description,type,status'#type: 1, status: 0-1
	my $orgId = shift;
	my $groupId = shift;
	my $status = shift;

	my $tab = $Tabs->{core_group};
	$tab->{buf}->writeln("$groupId,$orgId,groupName-$groupId,groupDescription-$groupId,1,$status");
	increaseCounterAndFlush($tab);		
}

sub core_department_line($$$) {
	#cols => 'pid,orgId,parentId,departmentName'
	my $orgId = shift;
	my $departmentId = shift;
	my $parentId = shift;

	my $tab = $Tabs->{core_department};
	$tab->{buf}->writeln("$departmentId,$orgId,$parentId,departmentName-$departmentId");
	increaseCounterAndFlush($tab);	
}

sub core_knowledge_line($$$$$) {
	#cols => 'pid,orgId,title,kngType,fileType,fileId'#kngType: 1-6, fileType, 1-2
	my $orgId = shift;
	my $knowledgeId = shift;
	my $fileId = shift;
	my $kngType = shift;
	my $fileType = shift;

	my $tab = $Tabs->{core_knowledge};
	$tab->{buf}->writeln("$knowledgeId,$orgId,title-$knowledgeId,$kngType,$fileType,$fileId");
	increaseCounterAndFlush($tab);		
}

sub core_file_info_line($) {
	#cols => 'pid,name'
	my $fileId = shift;

	my $tab = $Tabs->{core_file_info};
	$tab->{buf}->writeln("$fileId,fileName-$fileId");
	increaseCounterAndFlush($tab);		
}

sub core_convert_item_line($$$$) {
	#cols => 'pid,knowledgeId,fileId,format'
	my $itemId = shift;
	my $knowledgeId = shift;
	my $fileId = shift;
	my $format = shift;

	my $tab = $Tabs->{core_convert_item};
	$tab->{buf}->writeln("$itemId,$knowledgeId,$fileId,$format");
	increaseCounterAndFlush($tab);		
}

sub core_user_group_map_line($$$$) {
	#cols => 'pid,groupId,userId,type'
	my $pid = shift;
	my $groupId = shift;
	my $userId = shift;
	my $type = shift;

	my $tab = $Tabs->{core_user_group_map};
	$tab->{buf}->writeln("$pid,$groupId,$userId,$type");
	increaseCounterAndFlush($tab);		
}
sub generate_core_user_group_map($$) {
	#cols => 'pid,groupId,userId,type'	
	my $Users = shift;
	my $Groups = shift;

	my $groupCnt = $#{$Groups} + 1;
	my $userCnt = $#{$Users} + 1;

	my $userPerGroup = int($userCnt / $groupCnt);

	for (my $i = 0; $i < $groupCnt; $i++) {
		for (my $j = 0; $j < $userPerGroup; $j++) {
			my $pid= getUuid();
			my $groupId = $Groups->[$i];
			my $userId = $Users->[$userPerGroup * $i + $j];
			my $type = ($j > 1 ? 3 : ($j + 1));
			core_user_group_map_line($pid, $groupId, $userId, $type);
		}
	}
}

sub core_user_knowledge_line($$$$) {#($pid, $orgId, $userId, $knowledgeId)
	#cols => 'pid,orgId,userId,knowledgeId'
	my $pid = shift;
	my $orgId = shift;
	my $userId = shift;
	my $knowledgeId = shift;

	my $tab = $Tabs->{core_user_knowledge};
	$tab->{buf}->writeln("$pid,$orgId,$userId,$knowledgeId");
	increaseCounterAndFlush($tab);	
}
sub generate_core_user_knowledge($$$) {
	#cols => 'pid,orgId,userId,knowledgeId'
	my $orgId = shift;
	my $Users = shift;
	my $Knowledges = shift;

	my $knowledgeCnt = $#{$Knowledges} + 1;
	my $userCnt = $#{$Users} + 1;

	my $min = $knowledgeCnt > $userCnt ? $userCnt : $knowledgeCnt;

	for (my $i = 0; $i < $min; $i++) {
		my $pid= getUuid();
		my $userId = $Users->[$i];
		my $knowledgeId = $Knowledges->[$i];
		core_user_knowledge_line($pid, $orgId, $userId, $knowledgeId);
	}
}

sub core_user_department_map_line($$$$$) {
	#cols => 'pid,orgId,userId,userType,departmentId'
	my $pid = shift;
	my $orgId = shift;
	my $userId = shift;
	my $userType = shift;
	my $departmentId = shift;

	my $tab = $Tabs->{core_user_department_map};
	$tab->{buf}->writeln("$pid,$orgId,$userId,$userType,$departmentId");
	increaseCounterAndFlush($tab);		
}
sub generate_core_user_department_map($$$$$) {
	#cols => 'pid,orgId,userId,userType,departmentId'
	my $orgId = shift;
	my $Departments_1st = shift;
	my $Departments_2nd = shift;
	my $Departments_3rd = shift;
	my $Users = shift;
	
	my $department_1stCnt = $#{$Departments_1st} + 1;
	my $department_2ndCnt = $#{$Departments_2nd} + 1;
	my $department_3rdCnt = $#{$Departments_3rd} + 1;
	my $userCnt = $#{$Users} + 1;

	my $userPerDepartment = int($userCnt / ($department_1stCnt + $department_2ndCnt + $department_3rdCnt));
	my $userPer1st = 1;
	my $userPer2nd = 1;
	my $userPer3rd = $userPerDepartment - 2;

	my $globalIdx = 0;
	for (my $i = 0; $i < $department_1stCnt; $i++) {
		my $pid= getUuid();
		my $userId = $Users->[$globalIdx];
		my $type = 1;
		my $departmentId = $Departments_1st->[$i];
		core_user_department_map_line($pid, $orgId, $userId, $type, $departmentId);

		$globalIdx++;
	}
	for (my $i = 0; $i < $department_2ndCnt; $i++) {
		my $pid= getUuid();
		my $userId = $Users->[$globalIdx];
		my $type = 1;
		my $departmentId = $Departments_2nd->[$i];
		core_user_department_map_line($pid, $orgId, $userId, $type, $departmentId);

		$globalIdx++;
	}
	for (my $i = 0; $i < $department_3rdCnt; $i++) {
		my $pid= getUuid();
		my $userId = $Users->[$globalIdx];
		my $type = $i == 0 ? 0 : 1;
		my $departmentId = $Departments_3rd->[$i];
		core_user_department_map_line($pid, $orgId, $userId, $type, $departmentId);

		$globalIdx++;
	}

}

sub SetCounts() {
	#org count
	our $core_org_count = 10000;

	#100 group per org
	our $core_group_count = 100;

	#1000 user per org
	our $core_orguser_count = 1000;

	#10 1st-class department per org
	#5  2nd-class department per 1st-class department
	#5  3rd-class department per 2nd-class department
	our $core_department_count_1st = 10;
	our $core_department_count_2nd = 5;
	our $core_department_count_3rd = 5;

	#1000 knowledge per org
	#5 differnt convert item file per file
	our $core_knowledge_count = 300;
	our $core_convert_item_count = 5;	
}

sub SetCounts_test() {
	#org count
	our $core_org_count = 1;

	#100 group per org
	our $core_group_count = 2;

	#1000 user per org
	our $core_orguser_count = 10;

	#10 1st-class department per org
	#5  2nd-class department per 1st-class department
	#5  3rd-class department per 2nd-class department
	our $core_department_count_1st = 2;
	our $core_department_count_2nd = 1;
	our $core_department_count_3rd = 1;

	#1000 knowledge per org
	#5 differnt convert item file per file
	our $core_knowledge_count = 3;
	our $core_convert_item_count = 2;	
}

my $ConvertedFormat = ['pdf', 'html4', 'html5', 'mp4', 'flv'];
my $Role = [100001, 100002, 100003, 100004, 100005];
sub constructFile() {
	openFile();

	our $core_org_count;
	our $core_group_count;
	our $core_orguser_count;
	our $core_department_count_1st;
	our $core_department_count_2nd;
	our $core_department_count_3rd;
	our $core_knowledge_count;
	our $core_convert_item_count;	

	for (my $idx_core_org = 0; $idx_core_org < $core_org_count; $idx_core_org++) {
		my $orgId= getUuid();
		core_org_line($orgId);


		#Begin for maps#
		my $Groups = [];
		my $Users = [];
		my $Departments_1st = [];
		my $Departments_2nd = [];
		my $Departments_3rd = [];
		my $Knowledges = [];
		#End

		for (my $idx_core_group = 0; $idx_core_group < $core_group_count; $idx_core_group++) {
			my $groupId= getUuid();
			my $status = $idx_core_group % 2;
			core_group_line($orgId, $groupId, $status);

			push(@{$Groups}, $groupId);
		}

		for (my $idx_core_orguser = 0; $idx_core_orguser < $core_orguser_count; $idx_core_orguser++) {
			my $userId= getUuid();	
			core_orguser_line($orgId, $userId);
			
			my $pid= getUuid();
			my $roleId = $Role->[$idx_core_orguser % 5];
			core_user_role_map_line($pid, $userId, $roleId);

			push(@{$Users}, $userId);
		}

		
		for (my $idx_core_department_1st = 0; $idx_core_department_1st < $core_department_count_1st; $idx_core_department_1st++) {
			my $departmentId_1st= getUuid();
			core_department_line($orgId, $departmentId_1st, 'NULL');

			push(@{$Departments_1st}, $departmentId_1st);

			for (my $idx_core_department_2nd = 0; $idx_core_department_2nd < $core_department_count_2nd; $idx_core_department_2nd++) {
				my $departmentId_2nd= getUuid();
				core_department_line($orgId, $departmentId_2nd ,$departmentId_1st);

				push(@{$Departments_2nd}, $departmentId_2nd);

				for (my $idx_core_department_3rd = 0; $idx_core_department_3rd < $core_department_count_3rd; $idx_core_department_3rd++) {
					my $departmentId_3rd= getUuid();
					core_department_line($orgId, $departmentId_3rd ,$departmentId_2nd);

					push(@{$Departments_3rd}, $departmentId_3rd);
				}
			}
		}

		for (my $idx_core_knowledge = 0; $idx_core_knowledge < $core_knowledge_count; $idx_core_knowledge++) {
			my $knowledgeId= getUuid();
			my $fileId= getUuid();
			my $kngType = $idx_core_knowledge % 7 || 1;
			my $fileType = $idx_core_knowledge % 3 || 1;

			core_knowledge_line($orgId, $knowledgeId, $fileId, $kngType, $fileType);
			core_file_info_line($fileId);

			push(@{$Knowledges}, $knowledgeId);

			for (my $idx_core_convert_info = 0; $idx_core_convert_info < $core_convert_item_count; $idx_core_convert_info++) {
				my $itemId= getUuid();
				my $format = $ConvertedFormat->[$idx_core_convert_info];
				core_convert_item_line($itemId, $knowledgeId, $fileId, $format);
			}
		}

		generate_core_user_group_map($Users, $Groups);
		generate_core_user_department_map($orgId, $Departments_1st, $Departments_2nd, $Departments_3rd, $Users);
		generate_core_user_knowledge($orgId, $Users, $Knowledges);
	}

	flushBuf2File();
	closeFile();
}

sub importData2Db() {
	system("perl -pE 's|#File#|todo|mg; s|#Table#|core_position_position_map|mg; s|#Column#|pid,currentPosition,nextPosition|mg;' mysql.load.data.from.file.tpl > _tmp_");
	system("mysql -h 172.17.128.231 -uroot -ppwdasdwx -e 'source ./_tmp_' yxt");
}

sub main() {
	#SetCounts_test();
	SetCounts();
	initTabHeader2Buf();
	constructFile();
}

main();