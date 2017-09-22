LOAD DATA LOCAL 
    INFILE 
--  'rpt_all_data.log'
--  'rpt_channel_daily.log'
--  'rpt_channel_monthly.log'
--  'rpt_channel_weekly.log'
--  'rpt_daily.log'
--  'rpt_monthly.log'
--  'rpt_retention.log'
--  'rpt_weekly.log'
--  'rpt_org_study_data.log'

    IGNORE 
--  INTO TABLE rpt_all_data
--  INTO TABLE rpt_channel_daily
--  INTO TABLE rpt_channel_monthly
--  INTO TABLE rpt_channel_weekly
--  INTO TABLE rpt_daily
--  INTO TABLE rpt_monthly
--  INTO TABLE rpt_retention
--  INTO TABLE rpt_weekly
--  INTO TABLE rpt_org_study_data

    FIELDS TERMINATED BY ','
    ENCLOSED BY '"'
    LINES TERMINATED BY '\n'
    (

--  /* rpt_all_data */ pid,rptDate,totalOrg,newOrg,totalUser,newUser,activeLoginOrgCount,loginUserCount,loginOrgUserCount,onlineStudyOrgCount,onlineStudyUserCount,uploadedCourseCount,lecaiStudyCount,todayLecaiStudyCount,documentStudyCount,todayDocumentStudyCount,courseSearchCount,importedUserCount,existingOrgImportedUserCount,studyLevel1OrgCount,studyLevel1UserCount,studyLevel1OrgUserCount,studyLevel1PureCUserCount,studyLevel2OrgCount,studyLevel2UserCount,studyLevel2OrgUserCount,studyLevel2PureCUserCount,studyLevel3OrgCount,studyLevel3UserCount,studyLevel3OrgUserCount,studyLevel3PureCUserCount,studyTotalLevelOrgCount,studyTotalLevelUserCount,activeStudyOrgCount,activeStudyOrgCount_1,loginedCuserTotalCount,loginedOldCuserTotalCount,loginedOrgUserCount,loginedOldOrgUserCount,totalStudyTime,totalOrgStudyTime,totalCuserStudyTime,todayOrderAmount,totalOrderAmount,todayOrder,totalOrder,createTime
--  /* rpt_channel_daily */ pid,startTime,endTime,channelId,totalOrg,newOrg,totalUser,newUser,activeUser,totalOrderAmount,newOrderAmount,totalOrder,newOrder,totalStudyplan,newStudyplan,totalStudyHour,newStudyHour,newOnlineStudyHour,totalKnowledge,newKnowledge,createTime
--  /* rpt_channel_monthly */ pid,startTime,endTime,channelId,totalOrg,newOrg,totalUser,newUser,activeUser,totalOrderAmount,newOrderAmount,totalOrder,newOrder,totalStudyplan,newStudyplan,totalStudyHour,newStudyHour,newOnlineStudyHour,totalKnowledge,newKnowledge,createTime
--  /* rpt_channel_weekly */ pid,startTime,endTime,channelId,totalOrg,newOrg,totalUser,newUser,activeUser,totalOrderAmount,newOrderAmount,totalOrder,newOrder,totalStudyplan,newStudyplan,totalStudyHour,newStudyHour,newOnlineStudyHour,totalKnowledge,newKnowledge,createTime
--  /* rpt_daily */ pid,startTime,endTime,orgId,orgName,channelId,industryId,orgCreateTime,totalUser,newUser,activeUser,totalOrderAmount,newOrderAmount,totalOrder,newOrder,totalStudyplan,newStudyplan,totalStudyHour,newStudyHour,newOnlineStudyHour,totalKnowledge,newKnowledge,createTime
--  /* rpt_monthly */ pid,startTime,endTime,orgId,orgName,channelId,industryId,orgCreateTime,totalUser,newUser,activeUser,totalOrderAmount,newOrderAmount,totalOrder,newOrder,totalStudyplan,newStudyplan,totalStudyHour,newStudyHour,newOnlineStudyHour,totalKnowledge,newKnowledge,createTime
--  /* rpt_retention */ pid,reportDate,createDate,period,channelId,newUser,activeUser
--  /* rpt_weekly */ pid,startTime,endTime,orgId,orgName,channelId,industryId,orgCreateTime,totalUser,newUser,activeUser,totalOrderAmount,newOrderAmount,totalOrder,newOrder,totalStudyplan,newStudyplan,totalStudyHour,newStudyHour,newOnlineStudyHour,totalKnowledge,newKnowledge,createTime
--  /* rpt_org_study_data */  pid,orgId,orgName,industryId,contactPhone,contactEmail,lastLoginTime,sourceId,packageId,creator,orgCreateTime,createTime,userCount,departmentCount,examCount,planCount,packageCount,studyHours,knowledgeCount,siteName,shortName,code,domain,xuankeCount,catalogCount
    
    );