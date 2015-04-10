#!/usr/bin/perl -W
# 
#
use strict;
use English;
use Data::Dumper;
use Data::UUID;
use String::Buffer;

#define benchmark data magnitude
my $profile = $ARGV[0] || 'verification';
my $ConstMagnitude = {
	verification => {
		#org count
		core_org => 1,

		#group count per org
		core_group => 2,

		#user count per org
		core_orguser => 2,

		#1st-class department count per org
		#2nd-class department count per 1st-class department
		#3rd-class department count per 2nd-class department
		core_department_1st => 2,
		core_department_2nd => 1,
		core_department_3rd => 1,

		#knowledge count per org
		#convert item count per file
		core_knowledge => 5,
		core_convert_item => 2
	},

	profile_0 => {
		core_org => 50000,
		core_group => 20,
		core_orguser => 50,
		core_department_1st => 10,
		core_department_2nd => 5,
		core_department_3rd => 5,
		core_knowledge => 100,
		core_convert_item => 5
	},
	
	profile_1 => {
		core_org => 50,
		core_group => 20,
		core_orguser => 50,
		core_department_1st => 10,
		core_department_2nd => 5,
		core_department_3rd => 5,
		core_knowledge => 100,
		core_convert_item => 5
	},
};

#echo -n 123456 | sha256sum
my $UPWD= '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92';
my $Tabs= {
	#org, user, group, department, knowledge
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
		cols => 'pid,orgId,password,email,fullName,mobile,status,type,points,loginfailcount,lockstatus'
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
		cols => 'pid,orgId,userId,userType,departmentId'
	},
	core_user_group_map => {
		h => undef,
		counter => 0,
		file=>'/tmp/ciom/core_user_group_map.csv',
		buf => String::Buffer->new(),
		cols => 'pid,orgId,groupId,userId,type'
	},
	core_user_knowledge => {
		h => undef,
		counter => 0,
		file=>'/tmp/ciom/core_user_knowledge.csv',
		buf => String::Buffer->new(),
		cols => 'pid,orgId,userId,knowledgeId'
	},

	#study 
	sty_study_plan => {
		h => undef,
		counter => 0,
		file=>'/tmp/ciom/sty_study_plan.csv',
		buf => String::Buffer->new(),
		cols => 'pid,orgId,createUserID,planName,status,knowledgeCount,studyHours'		
	},
	sty_study_plan_content => {
		h => undef,
		counter => 0,
		file=>'/tmp/ciom/sty_study_plan_content.csv',
		buf => String::Buffer->new(),
		cols => 'pid,orgId,studyPlanID,knowledgeID,title'		
	},
	sty_user_study_plan => {
		h => undef,
		counter => 0,
		file=>'/tmp/ciom/sty_user_study_plan.csv',
		buf => String::Buffer->new(),
		cols => 'pid,orgId,userId,parentPlanID,planName'		
	},

	#component
	core_activity => {
		h => undef,
		counter => 0,
		file=>'/tmp/ciom/core_activity.csv',
		buf => String::Buffer->new(),
		#targetId -> knowledgeId
		#targetName: targetName
		#type: 21
		#status: 1
		cols => 'pid,orgId,targetId,targetName,creator,updater,type,status'
	},	
	core_comment => {
		h => undef,
		counter => 0,
		file=>'/tmp/ciom/core_comment.csv',
		buf => String::Buffer->new(),
		#targetId -> knowledgeId
		#targetName: targetName
		#type: 1
		#status: 1
		cols => 'pid,orgId,targetId,targetName,creator,updater,type,status'
	},
	core_favorite => {
		h => undef,
		counter => 0,
		file=>'/tmp/ciom/core_favorite.csv',
		buf => String::Buffer->new(),
		#targetId -> knowledgeId
		#targetName: targetName
		#type: 1
		#status: 1
		cols => 'pid,orgId,targetId,targetName,creator,updater,type,status'
	},
	core_note => {
		h => undef,
		counter => 0,
		file=>'/tmp/ciom/core_note.csv',
		buf => String::Buffer->new(),
		#targetId -> knowledgeId
		#targetName: targetName
		#type: 1
		#status: 1
		cols => 'pid,orgId,targetId,targetName,creator,updater,type,status'
	},	
	core_praise => {
		h => undef,
		counter => 0,
		file=>'/tmp/ciom/core_praise.csv',
		buf => String::Buffer->new(),
		#targetId -> knowledgeId
		#targetName: targetName
		#type: 1
		cols => 'pid,orgId,targetId,creator,type'
	},
	core_rating => {
		h => undef,
		counter => 0,
		file=>'/tmp/ciom/core_rating.csv',
		buf => String::Buffer->new(),
		#targetId -> knowledgeId
		#targetName: targetName
		#type: 1
		#status: 1
		cols => 'pid,orgId,targetId,creator,updater,type,status'
	},
	core_tag_target_map => {
		h => undef,
		counter => 0,
		file=>'/tmp/ciom/core_tag_target_map.csv',
		buf => String::Buffer->new(),
		#targetId -> knowledgeId
		#tagId: 0
		#tagType: 1
		#tagName: tagName
		cols => 'pid,orgId,targetId,createUserId,updateUserId,tagId,tagType,tagName'
	},
	core_browse_history => {
		h => undef,
		counter => 0,
		file=>'/tmp/ciom/core_browse_history.csv',
		buf => String::Buffer->new(),
		#targetId -> knowledgeId
		#targetName: targetName
		#type: 1
		cols => 'pid,orgId,targetId,targetName,creator,type'
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


sub importCsv2Db($$$) {
	my $host = shift;
	my $user = shift;
	my $pwd = shift;
	while ( my ($k, $v) = each(%{$Tabs}) ) {
		print("import $k ... \n");
		system("perl -pE 's|#File#|$v->{file}|mg; s|#Table#|$k|mg; s|#Column#|$v->{cols}|mg;' mysql.load.data.from.file.tpl > _tmp_");
		system("mysql -h $host -u$user -p'$pwd' -e 'source ./_tmp_' yxt");
    }	
}

sub flushLeftBuf2File() {
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
	$tab->{buf}->writeln("'$orgId','code-$orgId','orgName-$orgId','siteName-$orgId','domain-$orgId'");
	increaseCounterAndFlush($tab);
}

sub core_orguser_line($$) {
	#cols => 'pid,orgId,password,email,fullName,mobile,status,type,points,loginfailcount,lockstatus'
	my $orgId = shift;
	my $userId = shift;

	my $tab = $Tabs->{core_orguser};
	$tab->{buf}->writeln("'$userId','$orgId','$UPWD','$userId\@yxt.cn','fullName-$userId','mobile-$userId',1,1,0,0,0");
	increaseCounterAndFlush($tab);		
}

sub core_user_role_map_line($$$) {
	#cols => 'pid,userId,roleId'
	my $pid = shift;
	my $userId = shift;
	my $roleId = shift;

	my $tab = $Tabs->{core_user_role_map};
	$tab->{buf}->writeln("'$pid','$userId','$roleId'");
	increaseCounterAndFlush($tab);		
}

sub core_group_line($$$) {
	#cols => 'pid,orgId,name,description,type,status'#type: 1, status: 0-1
	my $orgId = shift;
	my $groupId = shift;
	my $status = shift;

	my $tab = $Tabs->{core_group};
	$tab->{buf}->writeln("'$groupId','$orgId','groupName-$groupId','groupDescription-$groupId',1,$status");
	increaseCounterAndFlush($tab);		
}

sub core_department_line($$$) {
	#cols => 'pid,orgId,parentId,departmentName'
	my $orgId = shift;
	my $departmentId = shift;
	my $parentId = shift;

	my $tab = $Tabs->{core_department};
	$tab->{buf}->writeln("'$departmentId','$orgId','$parentId','departmentName-$departmentId'");
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
	$tab->{buf}->writeln("'$knowledgeId','$orgId','title-$knowledgeId','$kngType','$fileType','$fileId'");
	increaseCounterAndFlush($tab);		
}

sub core_file_info_line($) {
	#cols => 'pid,name'
	my $fileId = shift;

	my $tab = $Tabs->{core_file_info};
	$tab->{buf}->writeln("'$fileId','fileName-$fileId'");
	increaseCounterAndFlush($tab);		
}

sub core_convert_item_line($$$$) {
	#cols => 'pid,knowledgeId,fileId,format'
	my $itemId = shift;
	my $knowledgeId = shift;
	my $fileId = shift;
	my $format = shift;

	my $tab = $Tabs->{core_convert_item};
	$tab->{buf}->writeln("'$itemId','$knowledgeId','$fileId','$format'");
	increaseCounterAndFlush($tab);		
}

sub core_user_group_map_line($$$$$) {
	#cols => 'pid,orgId,groupId,userId,type'
	my $pid = shift;
	my $orgId = shift;
	my $groupId = shift;
	my $userId = shift;
	my $type = shift;

	my $tab = $Tabs->{core_user_group_map};
	$tab->{buf}->writeln("'$pid','$orgId','$groupId','$userId',$type");
	increaseCounterAndFlush($tab);		
}
sub generate_core_user_group_map($$$) {
	my $orgId = shift;	
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
			core_user_group_map_line($pid, $orgId, $groupId, $userId, $type);
		}
	}
}


#begin study
sub sty_study_plan_line($$$) {
	#cols => 'pid,orgId,createUserID,planName,status,knowledgeCount,studyHours'
	my $pid = shift;
	my $orgId = shift;
	my $userId = shift;

	my $tab = $Tabs->{sty_study_plan};
	$tab->{buf}->writeln("'$pid','$orgId','$userId','planName-$pid',-1,3,3");
	increaseCounterAndFlush($tab);		
}
sub sty_study_plan_content_line($$$$) {
	#cols => 'pid,orgId,studyPlanID,knowledgeID,title'	
	my $pid = shift;
	my $orgId = shift;
	my $studyPlanID = shift;
	my $knowledgeID = shift;

	my $tab = $Tabs->{sty_study_plan_content};
	$tab->{buf}->writeln("'$pid','$orgId','$studyPlanID','knowledgeID','title-$pid'");
	increaseCounterAndFlush($tab);		
}
sub sty_user_study_plan_line($$$$) {
	#cols => 'pid,orgId,userId,parentPlanID,planName'
	my $pid = shift;
	my $orgId = shift;
	my $userId = shift;
	my $parentPlanID = shift;

	my $tab = $Tabs->{sty_user_study_plan};
	$tab->{buf}->writeln("'$pid','$orgId','$userId','parentPlanID','planName-$pid'");
	increaseCounterAndFlush($tab);		
}
sub generate_sty_tabs($$$) {
	my $orgId = shift;	
	my $Users = shift;
	my $Knowledges = shift;

	my $userCnt = $#{$Users} + 1;
	for (my $i = 0; $i < $userCnt; $i++) {
		my $studyPlanID= getUuid();
		my $userId = $Users->[$i];
		sty_study_plan_line($studyPlanID, $orgId, $userId);

		for (my $j = 0; $j < 3; $j++) {
			my $knowledgeId = $Knowledges->[$i + $j] || $Knowledges->[0];
			sty_study_plan_content_line(getUuid(), $orgId, $studyPlanID, $knowledgeId);	
		}

		for (my $j = 0; $j < 10; $j++) {
			sty_user_study_plan_line(getUuid(), $orgId, $userId, $studyPlanID);		
		}
	}
}
#End study


#start component
sub core_tag_target_map_line($$$$) {
	#cols => 'pid,orgId,targetId,createUserId,updateUserId,tagId,tagType,tagName'
	my $pid = shift;
	my $orgId = shift;
	my $targetId = shift;
	my $creator = shift;

	my $tab = $Tabs->{core_tag_target_map};
	$tab->{buf}->writeln("'$pid','$orgId','$targetId','$creator','$creator','0',1,'tagName-$pid'");		
	increaseCounterAndFlush($tab);
}
sub core_component_line($$$$$) {
	#cols => 'pid,orgId,targetId,targetName,creator,updater,type,status'
	my $pid = shift;
	my $orgId = shift;
	my $targetId = shift;
	my $creator = shift;
	my $tabName = shift;

	my $tab = $Tabs->{$tabName};
	my $type = 1;
	if ($tabName eq "core_activity") {
		$type = 21;
	}
	if ($tabName eq "core_browse_history") {
		$tab->{buf}->writeln("'$pid','$orgId','$targetId','targetName-$pid','$creator',$type");
	} elsif ($tabName eq "core_praise") {
		$tab->{buf}->writeln("'$pid','$orgId','$targetId','$creator',$type");	
	} elsif($tabName eq "core_rating") {
		$tab->{buf}->writeln("'$pid','$orgId','$targetId','$creator','$creator',$type,1");		
	} else {
		$tab->{buf}->writeln("'$pid','$orgId','$targetId','targetName-$pid','$creator','$creator',$type,1");		
	}
	
	increaseCounterAndFlush($tab);		
}
sub generate_component_tabs($$$) {
	my $orgId = shift;	
	my $Users = shift;
	my $Knowledges = shift;

	my $userCnt = $#{$Users} + 1;
	my $knowledgeCnt = $#{$Knowledges} + 1;
	my $knowledgePerUser = int($knowledgeCnt / $userCnt);
	for (my $i = 0; $i < $userCnt; $i++) {
		my $userId = $Users->[$i];
		
		for (my $j = 0; $j < $knowledgePerUser; $j++) {
			my $knowledgeId = $Knowledges->[$i * $knowledgePerUser + $j];
			core_component_line(getUuid(), $orgId, $knowledgeId, $userId, 'core_activity');
			core_component_line(getUuid(), $orgId, $knowledgeId, $userId, 'core_comment');
			core_component_line(getUuid(), $orgId, $knowledgeId, $userId, 'core_favorite');
			core_component_line(getUuid(), $orgId, $knowledgeId, $userId, 'core_note');
			core_component_line(getUuid(), $orgId, $knowledgeId, $userId, 'core_praise');
			core_component_line(getUuid(), $orgId, $knowledgeId, $userId, 'core_rating');
			core_component_line(getUuid(), $orgId, $knowledgeId, $userId, 'core_browse_history');
			core_component_line(getUuid(), $orgId, $knowledgeId, $userId, 'core_activity');

			core_tag_target_map_line(getUuid(), $orgId, $knowledgeId, $userId);
		}
	}
}
#End component

sub core_user_knowledge_line($$$$) {#($pid, $orgId, $userId, $knowledgeId)
	#cols => 'pid,orgId,userId,knowledgeId'
	my $pid = shift;
	my $orgId = shift;
	my $userId = shift;
	my $knowledgeId = shift;

	my $tab = $Tabs->{core_user_knowledge};
	$tab->{buf}->writeln("'$pid','$orgId','$userId','$knowledgeId'");
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
	$tab->{buf}->writeln("'$pid','$orgId','$userId',$userType,'$departmentId'");
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
		my $userId = $Users->[$globalIdx] || $Users->[0];
		my $type = 1;
		my $departmentId = $Departments_1st->[$i];
		core_user_department_map_line($pid, $orgId, $userId, $type, $departmentId);

		$globalIdx++;
	}
	for (my $i = 0; $i < $department_2ndCnt; $i++) {
		my $pid= getUuid();
		my $userId = $Users->[$globalIdx] || $Users->[0];
		my $type = 1;
		my $departmentId = $Departments_2nd->[$i];
		core_user_department_map_line($pid, $orgId, $userId, $type, $departmentId);

		$globalIdx++;
	}
	for (my $i = 0; $i < $department_3rdCnt; $i++) {
		my $pid= getUuid();
		my $userId = $Users->[$globalIdx] || $Users->[0];
		my $type = $i == 0 ? 0 : 1;
		my $departmentId = $Departments_3rd->[$i];
		core_user_department_map_line($pid, $orgId, $userId, $type, $departmentId);

		$globalIdx++;
	}
}

my $ConvertedFormat = ['pdf', 'html4', 'html5', 'mp4', 'flv'];
my $Role = [100001, 100002, 100003, 100004, 100005];
sub genTabData2BufAndFlush2File() {
	for (my $idx_core_org = 0; $idx_core_org < $ConstMagnitude->{$profile}->{core_org}; $idx_core_org++) {
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

		for (my $idx_core_group = 0; $idx_core_group < $ConstMagnitude->{$profile}->{core_group}; $idx_core_group++) {
			my $groupId= getUuid();
			my $status = $idx_core_group % 2;
			core_group_line($orgId, $groupId, $status);

			push(@{$Groups}, $groupId);
		}

		for (my $idx_core_orguser = 0; $idx_core_orguser < $ConstMagnitude->{$profile}->{core_orguser}; $idx_core_orguser++) {
			my $userId= getUuid();	
			core_orguser_line($orgId, $userId);
			
			my $pid= getUuid();
			my $roleId = $Role->[$idx_core_orguser % 5];
			core_user_role_map_line($pid, $userId, $roleId);

			push(@{$Users}, $userId);
		}

		
		for (my $idx_core_department_1st = 0; $idx_core_department_1st < $ConstMagnitude->{$profile}->{core_department_1st}; $idx_core_department_1st++) {
			my $departmentId_1st= getUuid();
			core_department_line($orgId, $departmentId_1st, 'NULL');

			push(@{$Departments_1st}, $departmentId_1st);

			for (my $idx_core_department_2nd = 0; $idx_core_department_2nd < $ConstMagnitude->{$profile}->{core_department_2nd}; $idx_core_department_2nd++) {
				my $departmentId_2nd= getUuid();
				core_department_line($orgId, $departmentId_2nd ,$departmentId_1st);

				push(@{$Departments_2nd}, $departmentId_2nd);

				for (my $idx_core_department_3rd = 0; $idx_core_department_3rd < $ConstMagnitude->{$profile}->{core_department_3rd}; $idx_core_department_3rd++) {
					my $departmentId_3rd= getUuid();
					core_department_line($orgId, $departmentId_3rd ,$departmentId_2nd);

					push(@{$Departments_3rd}, $departmentId_3rd);
				}
			}
		}

		for (my $idx_core_knowledge = 0; $idx_core_knowledge < $ConstMagnitude->{$profile}->{core_knowledge}; $idx_core_knowledge++) {
			my $knowledgeId= getUuid();
			my $fileId= getUuid();
			my $kngType = $idx_core_knowledge % 7 || 1;
			my $fileType = $idx_core_knowledge % 3 || 1;

			core_knowledge_line($orgId, $knowledgeId, $fileId, $kngType, $fileType);
			core_file_info_line($fileId);

			push(@{$Knowledges}, $knowledgeId);

			for (my $idx_core_convert_info = 0; $idx_core_convert_info < $ConstMagnitude->{$profile}->{core_convert_item}; $idx_core_convert_info++) {
				my $itemId= getUuid();
				my $format = $ConvertedFormat->[$idx_core_convert_info];
				core_convert_item_line($itemId, $knowledgeId, $fileId, $format);
			}
		}

		generate_core_user_group_map($orgId, $Users, $Groups);
		generate_core_user_department_map($orgId, $Departments_1st, $Departments_2nd, $Departments_3rd, $Users);
		generate_core_user_knowledge($orgId, $Users, $Knowledges);
		generate_sty_tabs($orgId, $Users, $Knowledges);
		generate_component_tabs($orgId, $Users, $Knowledges);
	}
}

sub main() {
	openFile();
	initTabHeader2Buf();
	genTabData2BufAndFlush2File();
	flushLeftBuf2File();
	closeFile();

	if (defined($ARGV[1])) {
		importCsv2Db($ARGV[1], $ARGV[2], $ARGV[3]);
	}
}

main();
