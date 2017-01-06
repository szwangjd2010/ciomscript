/*
 * remove useless data
 */

load(getConfFile());

const DaySeconds = 24 * 3600;

var Timestamp = getMidnightTimestamp();

function getConfFile() {
	return "./" + ConfName + ".meta.js";
}

function getMidnightTimestamp() {
	var timestamp = (new ObjectId()).getTimestamp().getTime() / 1000;
	return timestamp - timestamp % DaySeconds;
}

function getBreakpoint(cname) {
	var lifetime = CollectionsLifetime.hasOwnProperty(cname) ? CollectionsLifetime[cname] : DefaultLifetime;
	var breakpointMicrosec = Timestamp - lifetime * DaySeconds;

	return {
		"microsec": breakpointMicrosec,
		// var objIdMax = ObjectId(Math.floor((new Date('2011/10/10'))/1000).toString(16) + "0000000000000000")
		"objectId": ObjectId(breakpointMicrosec.toString(16) + "0000000000000000")
	};
}

function cleanCollection(c, breakpoint) {
	if (breakpoint.microsec > Timestamp) {
		return -1;
	}

    var queryJson = {
        "$or": [
	        {"_id" : {"$lt" : breakpoint.microsec}},
	       	{"_id" : {"$lt" : breakpoint.objectId}}
        ]
    };
    var cnt = c.count(queryJson);
    c.remove(queryJson);
    return cnt;
}

(function main() {
    print("-----------------------------------------------");
    print(new Date() + ",  begin to clean:");

    var db = connect(DatabaseURL);
    var cnames = db.getCollectionNames();
    
    for (var i = 0; i < cnames.length; i++) {
        cname = cnames[i];
        if (cname === "system.indexes") {
            continue;
        }
        print(cname + " ... ");
        var cnt = cleanCollection(db.getCollection(cname), getBreakpoint(cname));
        print(cnt + " records cleaned");
    }

    print("finished!");
})();
