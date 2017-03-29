/*
 * useless data meta info
 */

var DbInfo = {
	host: "localhost",
	port: "27017",
	database: "datav_master",
	username: "datav",
	password: "YDVpwdasdwx2910",
	authDatabase: "admin"
};

var DefaultLifetime = 7; // days

var CollectionsLifetime = { // days
	lecai_org_top30: -1,
	lecai_org_users: -1,
	qida_org_top200: -1,
	qida_org_users: -1,

	lecai_api_counter_info: -1,
	lecai_login_count_info: -1,
	qida_login_count: -1,
	wangxiao_login_count: -1,

	lecai_log_count: 1,
	lecai_log_window: 1,
	qida_log_count: 1,
	qida_log_window: 1
};