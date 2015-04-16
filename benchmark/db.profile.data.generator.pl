#!/usr/bin/perl -W
# 
#
use strict;
use English;
use Data::Dumper;
use Data::UUID;
use String::Buffer;

#define benchmark data magnitude
my $profile = $ARGV[0] || 'bvt';
my $ConstMagnitude = {
	bvt => {
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
	xbvt=> {
		core_org => 5,
		core_group => 20,
		core_orguser => 50,
		core_department_1st => 6,
		core_department_2nd => 2,
		core_department_3rd => 2,
		core_knowledge => 100,
		core_convert_item => 5
	},
	profile_0 => {
		core_org => 50000,
		core_group => 20,
		core_orguser => 50,
		core_department_1st => 6,
		core_department_2nd => 2,
		core_department_3rd => 2,
		core_knowledge => 100,
		core_convert_item => 5
	},
	profile_1 => {
		core_org => 100000,
		core_group => 20,
		core_orguser => 100,
		core_department_1st => 6,
		core_department_2nd => 2,
		core_department_3rd => 2,
		core_knowledge => 100,
		core_convert_item => 5
	},
};
my $Magnitude = $ConstMagnitude->{$profile};

#echo -n 123456 | sha256sum
my $UPWD= '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92';
my $Tabs= {
	#org, user, group, department, knowledge
	core_org => {
		h => undef,
		counter => 0,
		file=>'/tmp/ciom/core_org.csv',
		buf => String::Buffer->new(),
		cols => 'pid,code,orgName,siteName,domain',
		vals => "'#pid#','code-#pid#','orgName-#pid#','siteName-#pid#','domain-#pid#'"
	},
	core_orguser => {
		h => undef,
		counter => 0,
		file=>'/tmp/ciom/core_orguser.csv',
		buf => String::Buffer->new(),
		cols => 'pid,orgId,password,email,fullName,mobile,status,type,points,loginfailcount,lockstatus,gendar',
		vals => "'#pid#','#orgId#','$UPWD','#pid#\@yxt.com','fullName-#pid#','mobile-#pid#',1,1,0,0,0,1"
	},
	core_user_role_map => {
		h => undef,
		counter => 0,
		file=>'/tmp/ciom/core_user_role_map.csv',
		buf => String::Buffer->new(),
		cols => 'pid,userId,roleId', #roleId: 100001-100005
		vals => "'#pid#','#userId#','#roleId#'"
	},	
	core_group => {
		h => undef,
		counter => 0,
		file=>'/tmp/ciom/core_group.csv',
		buf => String::Buffer->new(),
		cols => 'pid,orgId,name,description,type,status', #type: 1, status: 0-1
		vals => "'#pid#','#orgId#','name-#pid#','description-#pid#',1,#status#"
	},
	core_department => {
		h => undef,
		counter => 0,
		file=>'/tmp/ciom/core_department.csv',
		buf => String::Buffer->new(),
		cols => 'pid,orgId,parentId,departmentName',
		vals => "'#pid#','#orgId#','#parentId#','departmentName-#pid#'"
	},
	core_knowledge => {
		h => undef,
		counter => 0,
		file=>'/tmp/ciom/core_knowledge.csv',
		buf => String::Buffer->new(),
		cols => 'pid,orgId,title,kngType,fileType,fileId', #kngType: 1-6, fileType, 1-2
		vals => "'#pid#','#orgId#','title-#pid#','#kngType#','#fileType#','#fileId#'"
	},
	core_file_info => {
		h => undef,
		counter => 0,
		file=>'/tmp/ciom/core_file_info.csv',
		buf => String::Buffer->new(),
		cols => 'pid,name',
		vals => "'#pid#','name-#pid#'"
	},
	core_convert_item => {
		h => undef,
		counter => 0,
		file=>'/tmp/ciom/core_convert_item.csv',
		buf => String::Buffer->new(),
		cols => 'pid,knowledgeId,fileId,format',
		vals => "'#pid#','#knowledgeId#','#fileId#','#format#'"
	},
	core_user_department_map => {
		h => undef,
		counter => 0,
		file=>'/tmp/ciom/core_user_department_map.csv',
		buf => String::Buffer->new(),
		cols => 'pid,orgId,userId,userType,departmentId',
		vals => "'#pid#','#orgId#','#userId#',#userType#,'#departmentId#'"
	},
	core_user_group_map => {
		h => undef,
		counter => 0,
		file=>'/tmp/ciom/core_user_group_map.csv',
		buf => String::Buffer->new(),
		cols => 'pid,orgId,groupId,userId,type',
		vals => "'#pid#','#orgId#','#groupId#','#userId#',#type#"
	},
	core_user_knowledge => {
		h => undef,
		counter => 0,
		file=>'/tmp/ciom/core_user_knowledge.csv',
		buf => String::Buffer->new(),
		cols => 'pid,orgId,userId,knowledgeId',
		vals => "'#pid#','#orgId#','#userId#','#knowledgeId#'"
	},

	#study 
	sty_study_plan => {
		h => undef,
		counter => 0,
		file=>'/tmp/ciom/sty_study_plan.csv',
		buf => String::Buffer->new(),
		cols => 'pid,orgId,createUserID,planName,status,knowledgeCount,studyHours',
		vals => "'#pid#','#orgId#','#createUserID#','planName-#pid#',-1,3,3"
	},
	sty_study_plan_content => {
		h => undef,
		counter => 0,
		file=>'/tmp/ciom/sty_study_plan_content.csv',
		buf => String::Buffer->new(),
		cols => 'pid,orgId,studyPlanID,knowledgeID,title',
		vals => "'#pid#','#orgId#','#studyPlanID#','#knowledgeID#','title-#pid#'"
	},
	sty_user_study_plan => {
		h => undef,
		counter => 0,
		file=>'/tmp/ciom/sty_user_study_plan.csv',
		buf => String::Buffer->new(),
		cols => 'pid,orgId,userId,parentPlanID,planName',
		vals => "'#pid#','#orgId#','#userId#','#parentPlanID#','planName-#pid#'"
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
		cols => 'pid,orgId,targetId,targetName,creator,updater,type,status',
		vals => "'#pid#','#orgId#','#targetId#','targetName-#targetId#','#creator#','#creator#',21,1"
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
		cols => 'pid,orgId,targetId,targetName,creator,updater,type,status',
		vals => "'#pid#','#orgId#','#targetId#','targetName-#targetId#','#creator#','#creator#',1,1"
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
		cols => 'pid,orgId,targetId,targetName,creator,updater,type,status',
		vals => "'#pid#','#orgId#','#targetId#','targetName-#targetId#','#creator#','#creator#',1,1"
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
		cols => 'pid,orgId,targetId,targetName,creator,updater,type,status',
		vals => "'#pid#','#orgId#','#targetId#','targetName-#targetId#','#creator#','#creator#',1,1"
	},	
	core_praise => {
		h => undef,
		counter => 0,
		file=>'/tmp/ciom/core_praise.csv',
		buf => String::Buffer->new(),
		#targetId -> knowledgeId
		#targetName: targetName
		#type: 1
		cols => 'pid,orgId,targetId,creator,type',
		vals => "'#pid#','#orgId#','#targetId#','#creator#',1"
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
		cols => 'pid,orgId,targetId,creator,updater,type,status',
		vals => "'#pid#','#orgId#','#targetId#','#creator#','#creator#',1,1"
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
		cols => 'pid,orgId,targetId,createUserId,updateUserId,tagId,tagType,tagName',
		vals => "'#pid#','#orgId#','#targetId#','#createUserId#','#createUserId#',0,1,'tagName-#pid#'"
	},
	core_browse_history => {
		h => undef,
		counter => 0,
		file=>'/tmp/ciom/core_browse_history.csv',
		buf => String::Buffer->new(),
		#targetId -> knowledgeId
		#targetName: targetName
		#type: 1
		cols => 'pid,orgId,targetId,targetName,creator,type',
		vals => "'#pid#','#orgId#','#targetId#','targetName-#targetId#','#creator#',1"
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
        	exit 1;
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

sub new_tab_line($$) {
	my $tabName = shift;
	my $pms = shift;

	my $tab = $Tabs->{$tabName};
	my $vals = $tab->{vals};
	for my $key (keys %{$pms}) {
		my $v = $pms->{$key};
		$vals =~ s/#$key#/$v/g;
	}

	$tab->{buf}->writeln($vals);
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

			new_tab_line('core_user_group_map', {
				pid => $pid,
				orgId => $orgId,
				groupId => $groupId,
				userId => $userId,
				type => $type
			});				
		}
	}
}


#begin study
sub generate_sty_tabs($$$) {
	my $orgId = shift;	
	my $Users = shift;
	my $Knowledges = shift;

	my $userCnt = $#{$Users} + 1;
	for (my $i = 0; $i < $userCnt; $i++) {
		my $studyPlanID= getUuid();
		my $userId = $Users->[$i];

		new_tab_line('sty_study_plan', {
			pid => $studyPlanID,
			orgId => $orgId,
			createUserID => $userId
		});			

		for (my $j = 0; $j < 3; $j++) {
			my $knowledgeId = $Knowledges->[$i + $j] || $Knowledges->[0];
			new_tab_line('sty_study_plan_content', {
				pid => getUuid(),
				orgId => $orgId,
				studyPlanID => $studyPlanID,
				knowledgeID => $knowledgeId
			});			
		}

		for (my $j = 0; $j < 10; $j++) {
			new_tab_line('sty_user_study_plan', {
				pid => getUuid(),
				orgId => $orgId,
				userId => $userId,
				parentPlanID => $studyPlanID
			});				
		}
	}
}
#End study


#start component
sub generate_component_tabs($$$) {
	my $orgId = shift;	
	my $Users = shift;
	my $Knowledges = shift;

	my $fnRefreshUuid = sub($) {
		my $pms = shift;
		$pms->{pid} = getUuid();
		return $pms
	};

	my $userCnt = $#{$Users} + 1;
	my $knowledgeCnt = $#{$Knowledges} + 1;
	my $knowledgePerUser = int($knowledgeCnt / $userCnt);
	for (my $i = 0; $i < $userCnt; $i++) {
		my $userId = $Users->[$i];
		
		for (my $j = 0; $j < $knowledgePerUser; $j++) {
			my $knowledgeId = $Knowledges->[$i * $knowledgePerUser + $j];
			my $pms = {
				orgId => $orgId,
				targetId => $knowledgeId,
				creator => $userId
			};

			new_tab_line('core_activity', 		$fnRefreshUuid->($pms));
			new_tab_line('core_comment', 		$fnRefreshUuid->($pms));
			new_tab_line('core_favorite', 		$fnRefreshUuid->($pms));						
			new_tab_line('core_note', 			$fnRefreshUuid->($pms));
			new_tab_line('core_praise', 		$fnRefreshUuid->($pms));
			new_tab_line('core_rating', 		$fnRefreshUuid->($pms));
			new_tab_line('core_browse_history', $fnRefreshUuid->($pms));
			new_tab_line('core_tag_target_map', $fnRefreshUuid->($pms));			
		}
	}
}
#End component

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
		new_tab_line('core_user_knowledge', {
			pid => $pid,
			orgId => $orgId,
			userId => $userId,
			knowledgeId => $knowledgeId
		});		
	}
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
		new_tab_line('core_user_department_map', {
			pid => $pid,
			orgId => $orgId,
			userId => $userId,
			userType => $type,
			departmentId => $departmentId
		});

		$globalIdx++;
	}
	for (my $i = 0; $i < $department_2ndCnt; $i++) {
		my $pid= getUuid();
		my $userId = $Users->[$globalIdx] || $Users->[0];
		my $type = 1;
		my $departmentId = $Departments_2nd->[$i];
		new_tab_line('core_user_department_map', {
			pid => $pid,
			orgId => $orgId,
			userId => $userId,
			userType => $type,
			departmentId => $departmentId
		});		

		$globalIdx++;
	}
	for (my $i = 0; $i < $department_3rdCnt; $i++) {
		my $pid= getUuid();
		my $userId = $Users->[$globalIdx] || $Users->[0];
		my $type = $i == 0 ? 0 : 1;
		my $departmentId = $Departments_3rd->[$i];
		new_tab_line('core_user_department_map', {
			pid => $pid,
			orgId => $orgId,
			userId => $userId,
			userType => $type,
			departmentId => $departmentId
		});		

		$globalIdx++;
	}
}

my $ConvertedFormat = ['pdf', 'html4', 'html5', 'mp4', 'flv'];
my $Role = [100001, 100002, 100003, 100004, 100005];
sub genTabData2BufAndFlush2File() {
	for (my $idx_core_org = 0; $idx_core_org < $Magnitude->{core_org}; $idx_core_org++) {
		my $orgId= getUuid();
		new_tab_line('core_org', {
			pid => $orgId
		});


		#Begin for maps#
		my $Groups = [];
		my $Users = [];
		my $Departments_1st = [];
		my $Departments_2nd = [];
		my $Departments_3rd = [];
		my $Knowledges = [];
		#End

		for (my $idx_core_group = 0; $idx_core_group < $Magnitude->{core_group}; $idx_core_group++) {
			my $groupId= getUuid();
			my $status = $idx_core_group % 2;
			new_tab_line('core_group', {
				pid => $groupId, 
				orgId => $orgId, 
				status => $status
			});

			push(@{$Groups}, $groupId);
		}

		for (my $idx_core_orguser = 0; $idx_core_orguser < $Magnitude->{core_orguser}; $idx_core_orguser++) {
			my $userId= getUuid();
			new_tab_line('core_orguser', {
				pid => $userId,
				orgId => $orgId 
			});
			
			my $pid= getUuid();
			my $roleId = $Role->[$idx_core_orguser % 5];
			new_tab_line('core_user_role_map', {
				pid => $pid, 
				userId => $userId, 
				roleId => $roleId
			});

			push(@{$Users}, $userId);
		}

		
		for (my $idx_core_department_1st = 0; $idx_core_department_1st < $Magnitude->{core_department_1st}; $idx_core_department_1st++) {
			my $departmentId_1st= getUuid();
			new_tab_line('core_department', {
				pid => $departmentId_1st, 
				orgId => $orgId, 
				parentId => 'NULL'
			});

			push(@{$Departments_1st}, $departmentId_1st);

			for (my $idx_core_department_2nd = 0; $idx_core_department_2nd < $Magnitude->{core_department_2nd}; $idx_core_department_2nd++) {
				my $departmentId_2nd= getUuid();
				new_tab_line('core_department', {
					pid => $departmentId_2nd, 
					orgId => $orgId, 
					parentId => $departmentId_1st
				});

				push(@{$Departments_2nd}, $departmentId_2nd);

				for (my $idx_core_department_3rd = 0; $idx_core_department_3rd < $Magnitude->{core_department_3rd}; $idx_core_department_3rd++) {
					my $departmentId_3rd= getUuid();
					new_tab_line('core_department', {
						pid => $departmentId_3rd, 
						orgId => $orgId, 
						parentId => $departmentId_2nd
					});

					push(@{$Departments_3rd}, $departmentId_3rd);
				}
			}
		}

		for (my $idx_core_knowledge = 0; $idx_core_knowledge < $Magnitude->{core_knowledge}; $idx_core_knowledge++) {
			my $knowledgeId= getUuid();
			my $fileId= getUuid();
			my $kngType = $idx_core_knowledge % 7 || 1;
			my $fileType = $idx_core_knowledge % 3 || 1;

			new_tab_line('core_knowledge', {
				pid => $knowledgeId, 
				orgId => $orgId, 
				fileId => $fileId, 
				kngType => $kngType, 
				fileType => $fileType
			});
			new_tab_line('core_file_info', {
				pid => $fileId
			});

			push(@{$Knowledges}, $knowledgeId);

			for (my $idx_core_convert_info = 0; $idx_core_convert_info < $Magnitude->{core_convert_item}; $idx_core_convert_info++) {
				my $itemId= getUuid();
				my $format = $ConvertedFormat->[$idx_core_convert_info];
				new_tab_line('core_convert_item', {
					pid => $itemId,
					knowledgeId => $knowledgeId,
					fileId => $fileId,
					format => $format
				});					
			}
		}

		generate_core_user_department_map($orgId, $Departments_1st, $Departments_2nd, $Departments_3rd, $Users);
		generate_core_user_group_map($orgId, $Users, $Groups);
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
